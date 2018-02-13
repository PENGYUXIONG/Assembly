# The following format is required for all submissions in CMPUT 229
#
# The following copyright notice does not apply to this file
# It is included here because it should be included in all
# solutions submitted by students.
#
#----------------------------------------------------------------
#
# CMPUT 229 Student Submission License
# Version 1.0
# Copyright 2017 <student name>
#
# Redistribution is forbidden in all circumstances. Use of this software
# without explicit authorization from the author is prohibited.
#
# This software was produced as a solution for an assignment in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada. This solution is confidential and remains confidential 
# after it is submitted for grading.
#
# Copying any part of this solution without including this copyright notice
# is illegal.
#
# If any portion of this software is included in a solution submitted for
# grading at an educational institution, the submitter will be subject to
# the sanctions for plagiarism at that institution.
#
# If this software is found in any public website or public repository, the
# person finding it is kindly requested to immediately report, including 
# the URL or other repository locating information, to the following email
# address:
#
#          cmput229@ualberta.ca
#
#---------------------------------------------------------------
# Assignment:           4
# Due Date:             20, Nov, 2017
# Name:                 Pengyu Xiong
# Unix ID:              1501982
# Lecture Section:      A2
# Instructor:           J Nelson Amaral
# Lab Section:         Lab D05 (Wed, 5pm-7pm)
# Teaching Assistant:   Feng, Rong
#---------------------------------------------------------------


#
# CMPUT 229 Public Materials License
# Version 1.1
#
# Copyright 2017 University of Alberta
# Copyright 2017 Austin Crapo
#
# This software is distributed to students in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada. 
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the disclaimer below in the documentation
#    and/or other materials provided with the distribution.
# 
# 2. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
######################
#
# Implementation of Minesweeper using GLIM
# 
# Implements the __start label, which gathers user input that defines
# the following information for the creation of the game board:
# - how many rows and columns the game board should have;
# - how many bombs the board should have;
# - what random seed to use when placing them.
#
# All these parameters are positive integers.
#
# It then places those bombs randomly, ensures that all tiles
# are in their 'covered' and 'unmarked' state, and prints the board
# to the terminal. It is at this point it then passes control
# over to the main method. Throughout this procedure it uses
# some student functions to achieve these results - to see which
# procedures require which student functions to be implemented
# please see the __start label header comment.
#
######################
.data
tile:
	.asciiz "█"
marked:
	.asciiz "●"
has0:
	.asciiz " "
has1:
	.asciiz "1"
has2:
	.asciiz "2"
has3:
	.asciiz "3"
has4:
	.asciiz "4"
has5:
	.asciiz "5"
has6:
	.asciiz "6"
has7:
	.asciiz "7"
has8:
	.asciiz "8"
bomb:
	.asciiz "∅"
prompt1:
	.asciiz "Number of rows for this session: "
prompt2:
	.asciiz "Number of columns for this session: "
prompt3:
	.asciiz "Random seed to use: "
prompt4:
	.asciiz "Number of bombs for this session: "
gameBoard:
	.align 2
	.space 800
gameRows:
	.space 4
gameCols:
	.space 4
totalBombs:
	.space 4
gameLost:
	.asciiz "You LOSE!"
gameWon:
	.asciiz "You WIN!"
	.align 2

.text
.globl __start
__start:
	########################################################################
	# The default exception handler has a __start label that SPIM looks for
	# when starting the execution of a program. In this custom exception
	# handler the code at this  __start label first sets up the game and
	# then calls the main function.
	#
	# This function performs the following tasks:
	#
	# - gathers, through MIPS syscalls, user input to define the size of
	#   the game board, the number of bombs, and the random seed that
	#   will be used to position the bombs on the board. All these input
	#   parameters are integer values.
	#
	# - clears all variables, using fillRand to place hidden bombs in
	#   random board positions.
	#   (hasBomb and setBomb must be implemented)
	#
	# - calls prepareBoard  to cover all the tiles on the board.
	#   (prepareBoard must be implemented)
	#
	# - prints the initial state of the board
	#   (printTile must be implemented)
	#
	# - passes control to main
	#
	# Depending on main's return value, the program will either quit,
	# or loop, repeating the entire above procedure.
	#
	# Register Usage:
	# $s0 = stores the number of Rows user has requested
	# $s1 = stores the number of Columns user has requested
	# $s2 = used as a row scanner when printing
	# $s3 = used as a column scanner when printing
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		# Adjust the stack to save $fp
	sw      $fp, 0($sp)         # Save $fp
	add     $fp, $zero, $sp		# $fp <= $sp
	addi    $sp, $sp, -20		# Adjust stack to save variables
	sw      $ra, -4($fp)
	sw      $s0, -8($fp)
	sw      $s1, -12($fp)
	sw      $s2, -16($fp)
	sw      $s3, -20($fp)
	
	
	startGame:
	
	##read the display size
	#Rows
	li      $v0, 4
	la      $a0, prompt1
	syscall
	li      $v0, 5
	syscall
	move	$s0, $v0
	#Cols
	li      $v0, 4
	la      $a0, prompt2
	syscall
	li      $v0, 5
	syscall
	move	$s1, $v0
	
	#Set the relevant screen data
	la      $t0, gameRows
	sw      $s0, 0($t0)
	la      $t0, gameCols
	sw      $s1, 0($t0)
		
	#Read and set random seed
	li      $v0, 4
	la      $a0, prompt3
	syscall
	li      $v0, 5
	syscall
	move	$a0, $v0
	jal	randInitialize
	
	#Read and set the number of bombs
	li      $v0, 4
	la      $a0, prompt4
	syscall
	li      $v0, 5
	syscall
	la      $t0, totalBombs
	sw      $v0, 0($t0)
	
	
	
	#Clear the entire board and all cursor variables
	li      $t0, 0
	la      $t1, gameBoard
	addi	$t2, $t1, 800		# CONSTANT, the max size of the game board is 800 bytes
	loopClear:
		beq     $t1, $t2, lCend
		sw      $t0, 0($t1)
		addi	$t1, $t1, 4
		j	loopClear
	lCend:
	
	#Clear all the cursor vairables
	la      $t1, cursorRow
	sw      $zero, 0($t1)
	la      $t1, cursorCol
	sw      $zero, 0($t1)
	la      $t1, newCursorRow
	sw      $zero, 0($t1)
	la      $t1, newCursorCol
	sw      $zero, 0($t1)
		
	
	#Place bombs randomly
	move	$a0, $v0
	li      $a1, 1
	jal     fillRand
	
	
	
	
	#Start up the GLIM display
	addi	$a0, $s0, 1
	move	$a1, $s1
	jal     startGLIM
	
	#covers all the tiles in a board
	jal     prepareBoard
	
	#Print the entire board
	li      $s2, 0		#rows
	li      $s3, 0		#cols
	
	loopFill:
        beq     $s2, $s0, lFend	#if rows == gameRows; break
		move	$a0, $s2
		move	$a1, $s3
		jal     printTile
		lFcont:
		addi	$s3, $s3, 1
		bne     $s3, $s1, loopFill	#if cols != gameCols; continue
		addi	$s2, $s2, 1
		li      $s3, 0
		j       loopFill
	lFend:
	
	jal	main
	
	move        $s0, $v0


	#MUST BE CALLED BEFORE ENDING PROGRAM
	#Restores as much as it can and sets the window to a good size
	jal	endGLIM
	
	move    $v0, $s0
	bne     $v0, $zero, startGame
	
	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s0, -8($fp)
	lw      $s1, -12($fp)
	lw      $s2, -16($fp)
	lw      $s3, -20($fp)
	addi	$sp, $sp, 20
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	
	li      $v0, 10
	syscall


.data
cursorRow:
	.space 4
cursorCol:
	.space 4
newCursorRow:
	.space 4
newCursorCol:
	.space 4
.text
updateCursor:
	########################################################################
	# Compares the new cursor value to the current cursor value, then 
	# updates accordingly the screen. After this function is called, 
	# and cursorCol contain the current cursor coordinates.
	#
	# Does not operate on inputs, only the memory addresses
	# newCursorRow, newCursorCol, cursorRow, cursorCol
	#
	#
	# Register Usage
	# 
	# $s0 = newCursorRow storage
	# $s1 = newCursorCol storage
	# $s2 = cursorRow storage
	# $s3 = cursorCol storage
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		# Adjust the stack to save $fp
	sw      $fp, 0($sp)			# Save $fp
	add     $fp, $zero, $sp		# $fp <= $sp
	addi	$sp, $sp, -20		# Adjust stack to save variables
	sw      $ra, -4($fp)		# Save $ra
	sw      $s0, -8($fp)		# Save $s0
	sw      $s1, -12($fp)		# Save $s1
	sw      $s2, -16($fp)		# Save $s2
	sw      $s3, -20($fp)
	
	la      $s0, newCursorRow
	la      $s1, newCursorCol
	la      $s2, cursorRow
	la      $s3, cursorCol
	
	#get the state of the old position
	lw      $a0, 0($s2)
	lw      $a1, 0($s3)
	jal     getTile
	
	#redraw the old position tile
	move	$a0, $v0
	lw      $a1, 0($s2)
	lw      $a2, 0($s3)
	jal     printString
	uColdDone:
	
	#update the cursor pointer position
	lw      $t0, 0($s0)
	sw      $t0, 0($s2)
	lw      $t0, 0($s1)
	sw      $t0, 0($s3)
	
	#set the color to show the cursor pointer
	li      $a0	9
	li      $a1	0
	jal     setColor
	li      $a0	14
	li      $a1	1
	jal     setColor
	
	#get the state of the new position
	lw      $a0, 0($s2)
	lw      $a1, 0($s3)
	jal     getTile
	
	#print the state of the new position with the pointer color
	move	$a0, $v0
	lw      $a1, 0($s2)
	lw      $a2, 0($s3)
	jal     printString
	
	#restore the color
	jal     restoreSettings
	
	
	
	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s0, -8($fp)
	lw      $s1, -12($fp)
	lw      $s2, -16($fp)
	lw      $s3, -20($fp)
	addi	$sp, $sp, 20
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr      $ra


.data
seeds:
	.word 0x75BD0F7, 0x4975CCA9, 0x75BCF8F, 0xBC11F3, 0x4975CDBF, 0x75BCEC3, 0xBC1095, 0x4975CEA1
	#The number of seeds in this list should be updated in the function
multiplier:
	.word 0xBE1761D
multiplicand:
	.word 0x0
.text
randInitialize:
	########################################################################
	# Initialize the random function to a specific value from a list
	# of suitable seeds. The seeds must be chosen as large primes because
	# this is using the linear congruence algorithm.
	# Since the seeds must be pre-chosen, we allocate a list and then
	# force the users' choices to fall into that list of seeds.
	# 
	# $a0 = seed
	#
	########################################################################
	la      $t0, seeds
	li      $t1, 7	#the number of seeds in the list, update if you add
	div     $a0, $t1
	mfhi	$a0
	sll     $a0, $a0, 2
	add     $t0, $t0, $a0
	lw      $t0, 0($t0)
	
	la      $t1, multiplicand
	sw      $t0, 0($t1)
	
	jr      $ra
	
randInt:
	########################################################################
	# Produces a random bit each time it is called. Uses a modulo to
	# determine a maximum value.
	#
	# $a0 = exclusive max value
	#
	# Returns
	# $v0 = x, where 0 <= x < $a0
 	#
	# Register Usage
	# $t0 = memory address multiplier
	# $t1 = memory address multiplicand
	# $t2 = value multiplier
	# $t3 = value multiplicand
	########################################################################
	la      $t0, multiplier
	la      $t1, multiplicand
	lw      $t2, 0($t0)
	lw      $t3, 0($t1)
	
	multu	$t2, $t3
	mfhi	$v0
	mflo	$t2
	sw      $t2, 0($t1)

	divu	$v0, $a0
	mfhi	$v0
	
	jr      $ra
	
fillRand:
	########################################################################
	# Randomly fills the board with the specified number of bombs. Moves
	# about the board in random directions waiting to get a 1 bit randomly
	# and then places the bomb, if the square already has a bomb, it will
	# make a decision based on it's "ensured" value. If "ensured" - it will
	# keep moving until it finds a place for the bomb, if not "ensured" it
	# will move on and the resulting board will have 1 less bomb than asked
	# for. Uses the student implemented functions hasBomb and setBomb to
	# properly achieve this result.
	# 
	# $a0 = # of desired bombs to fill the board with.
	# $a1 = 1 if "ensured", 0 if not "ensured"
	#
	# Register Usage
	# $s0 = row scanner
	# $s1 = column scanner
	# $s2 = gameRows storage
	# $s3 = gameCols storage
	# $s4 = Counter to 0 for how many bombs are left to place
	# $s5 = storage for $a1
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		# Adjust the stack to save $fp
	sw      $fp, 0($sp)			# Save $fp
	add     $fp, $zero, $sp		# $fp <= $sp
	addi	$sp, $sp, -28		# Adjust stack to save variables
	sw      $ra, -4($fp)		# Save $ra
	sw      $s0, -8($fp)		# Save $s0
	sw      $s1, -12($fp)		# Save $s1
	sw      $s2, -16($fp)		# Save $s2
	sw      $s3, -20($fp)
	sw      $s4, -24($fp)
	sw      $s5, -28($fp)
	
	li      $s0, 0	#row
	li      $s1, 0	#col
	la      $s2, gameRows
	lw      $s2, 0($s2)	#gameRows
	la      $s3, gameCols
	lw      $s3, 0($s3)	#gameCols
	move	$s4, $a0	#bombsLeft
	move	$s5, $a1	#ensured
	fRloop:
        beq     $s4, $zero, fRlend	#if bombsLeft == 0; break
		move	$a0, $s2		#generate rand row
		jal     randInt
		move	$s0, $v0
		
		move	$a0, $s3		#generate rand col
		jal     randInt
		move	$s1, $v0

		fRlmoveEnd:
		#at this point we are at a new position, 
		#we now determine if we should set a bomb
		li      $a0, 2
		jal     randInt
		beq     $v0, $zero, fRlcont	#if rand == 0; continue
		#else; set bomb
		
		#first we check if a bomb is already there
		move	$a0, $s0
		move	$a1, $s1
		jal     hasBomb
		
		beq     $v0, $zero, fRlsetBomb	#if tile == bomb, then we need to check if we are ensured
		beq     $s5, $zero, fRlsetBomb	#if ensured
			j	fRlcont			#then continue because this bomb doesn't count
		fRlsetBomb:
		addi	$s4, $s4, -1
		move	$a0, $s0
		move	$a1, $s1
		jal	setBomb
		
		fRlcont:
		j       fRloop
	fRlend:
	
	
	
	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s0, -8($fp)
	lw      $s1, -12($fp)
	lw      $s2, -16($fp)
	lw      $s3, -20($fp)
	lw      $s4, -24($fp)
	lw      $s5, -28($fp)
	addi	$sp, $sp, 28
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr      $ra
	
##############################################################################
#					START OF GLIM
##############################################################################
######################
#Author: Austin Crapo
#Date: June 2017
#Version: 2017.6.30
#
#
# Does not support being run in a tab; Requires a separate window.
#
# Currently printing to negative values does not print. Printing to
# offscreen pixels in the positive directions prints to last pixel
# available on the screen in that direction.
#
#This is a graphics library, supporting drawing pixels, 
# and some basic primitives
#
# High Level documentation is provided in the index.html file.
# Per-method documentation is provided in the block comment 
# following each function definition
######################
.data
.align 2
clearScreenCmd:
	.byte 0x1b, 0x5b, 0x32, 0x4a, 0x00
.text
clearScreen:
	########################################################################
	# Uses xfce4-terminal escape sequence to clear the screen
	#
	# Register Usage
	# Overwrites $v0 and $a0 during operation
	########################################################################
	li      $v0, 4
	la      $a0, clearScreenCmd
	syscall
	
	jr	$ra

.data
setCstring:
	.byte 0x1b, 0x5b, 0x30, 0x30, 0x30, 0x3b, 0x30, 0x30, 0x30, 0x48, 0x00
.text
setCursor:
	########################################################################
	#Moves the cursor to the specified location on the screen. Max location
	# is 3 digits for row number, and 3 digits for column number. (row, col)
	#
	# $a0 = row number to move to
	# $a1 = col number to move to
	#
	# Register Usage
	# Overwrites $v0 and $a0 during operation
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		# Adjust the stack to save $fp
	sw      $fp, 0($sp)		# Save $fp
	add     $fp, $zero, $sp		# $fp <= $sp
	addi	$sp, $sp, -12		# Adjust stack to save variables
	sw      $ra, -4($fp)		# Save $ra
	#skip $s0, this could be cleaned up
	sw      $s1, -8($fp)
	sw      $s2, -12($fp)
	
	#The control sequence we need is "\x1b[$a1;$a2H" where "\x1b"
	#is xfce4-terminal's method of passing the hex value for the ESC key.
	#This moves the cursor to the position, where we can then print.
	
	#The command is preset in memory, with triple zeros as placeholders
	#for the char coords. We translate the args to decimal chars and edit
	# the command string, then print
	
	move	$s1, $a0
	move	$s2, $a1
	
	li      $t0, 0x30	#'0' in ascii, we add according to the number
	#separate the three digits of the passed in number
	#1's = x%10
	#10's = x%100 - x%10
	#100's = x - x$100
	
	# NOTE: we add 1 to each coordinate because we want (0,0) to be the top
	# left corner of the screen, but most terminals define (1,1) as top left
	#ROW
	addi	$a0, $s1, 1
	la      $t2, setCstring
	jal     intToChar
	lb      $t0, 0($v0)
	sb      $t0, 4($t2)
	lb      $t0, 1($v0)
	sb      $t0, 3($t2)
	lb      $t0, 2($v0)
	sb      $t0, 2($t2)
	
	#COL
	addi	$a0, $s2, 1
	la      $t2, setCstring
	jal     intToChar
	lb      $t0, 0($v0)
	sb      $t0, 8($t2)
	lb      $t0, 1($v0)
	sb      $t0, 7($t2)
	lb      $t0, 2($v0)
	sb      $t0, 6($t2)

	#move the cursor
	li      $v0, 4
	la      $a0, setCstring
	syscall
	
	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s1, -8($fp)
	lw      $s2, -12($fp)
	addi	$sp, $sp, 12
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	
	jr      $ra

.text
printString:
	########################################################################
	# Prints the specified null-terminated string started at the
	# specified location to the string and then continues until
	# the end of the string, according to the printing preferences of your
	# terminal (standard terminals print left to right, top to bottom).
	#
	# It is not screen aware. Therefore, paramaters that would print a character
	# off screen have undefined effects on your terminal window. For most
	# terminals the cursor will wrap around to the next row and continue
	# printing. If you have hit the bottom of the terminal window,
	# the xfce4-terminal window default behavior is to scroll the window 
	# down. This can offset your screen without you knowing and is 
	# dangerous since it is undetectable.
	#
	# The most likely use of this
	# function is to print characters. The function expects a string
	# prints so that it can support the printing of escape character sequences
	# around the character. Escape character sequences enable fancy effects.
	#
	# Some other
	# terminals may treat the boundaries of the terminal window different.
	# For example, some may not wrap or scroll. It is up to the user to
	# test their terminal window to finde the default behaviour.
	#
	# printString is built for xfce4-terminal.
	# Position (0, 0) is defined as the top left of the terminal.
	#
	# $a0 = address of string to print
	# $a1 = integer value 0-999, row to print to (y position)
	# $a2 = integer value 0-999, col to print to (x position)
	#
	# Register Usage
	# $t0 - $t3, $t7-$t9 = temp storage of bytes and values
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		# Adjust the stack to save $fp
	sw      $fp, 0($sp)         # Save $fp
	add     $fp, $zero, $sp		# $fp <= $sp
	addi	$sp, $sp, -8		# Adjust stack to save variables
	sw      $ra, -4($fp)
	sw      $s0, -8($fp)
	
	move	$s0, $a0
	
	move	$a0, $a1
	move	$a1, $a2
	jal     setCursor
	
	#print the char
	li      $v0, 4
	move	$a0, $s0
	syscall
	
	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s0, -8($fp)
	addi	$sp, $sp, 8
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr      $ra

batchPrint:
	########################################################################
	# A batch is a list of print jobs. The print jobs are in the format
	# below, and will be printed from start to finish. This function does
	# some basic optimization of color printing (eg. color changing codes
	# are not printed if they do not need to be), but if the list constantly
	# changes color and is not sorted by color, you may notice flickering.
	#
	# List format:
	# Each element contains the following words in order together
	# half words unsigned:[row] [col]
	# bytes unsigned:     [printing code] [foreground color] [background color] 
	#			    [empty] 
	# word: [address of string to print here]
	# total = 3 words
	#
	# The batch must be ended with the halfword sentinel: 0xFFFF
	#
	# Valid Printing codes:
	# 0 = skip printing
	# 1 = standard print, default terminal settings
	# 2 = print using foreground color
	# 3 = print using background color
	# 4 = print using all colors
	# 
	# xfce4-terminal supports the 256 color lookup table assignment, 
	# see the index for a list of color codes.
	#
	# The payload of each job in the list is the address of a string. 
	# Escape sequences for prettier or bolded printing supported by your
	# terminal can be included in the strings. However, including such 
	# escape sequences can effect not just this print, but also future 
	# prints for other GLIM methods.
	#
	# $a0 = address of batch list to print
	#
	# Register Usage
	# $s0 = scanner for the list
	# $s1 = store row info
	# $s2 = store column info
	# $s3 = store print code info
	# $s6 = temporary color info storage accross calls
	# $s7 = temporary color info storage accross calls
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		
	sw      $fp, 0($sp)
	add     $fp, $zero, $sp
	addi	$sp, $sp, -28		
	sw      $ra, -4($fp)
	sw      $s0, -8($fp)
	sw      $s1, -12($fp)
	sw      $s2, -16($fp)
	sw      $s3, -20($fp)
	sw      $s6, -24($fp)
	sw      $s7, -28($fp)
	
	#store the last known colors, to avoid un-needed printing
	li      $s6, -1		#lastFG = -1
	li      $s7, -1		#lastBG = -1
	
	
	move	$s0, $a0		#scanner = list
	#for item in list
	bPscan:
		#extract row and col to vars
		lhu     $s1, 0($s0)		#row
		lhu     $s2, 2($s0)		#col
		
		#if row is 0xFFFF: break
		li      $t0, 0xFFFF
		beq     $s1, $t0, bPsend
		
		#extract printing code
		lbu     $s3, 4($s0)		#print code
		
		#skip if printing code is 0
		beq     $s3, $zero, bPscont
		
		#print to match printing code if needed
		#if standard print, make sure to have clear color
		li      $t0, 1		#if pcode == 1
		beq     $s3, $t0, bPscCend
		bPsclearColor:
			li      $t0, -1	#if lastFG != -1
			bne     $s6, $t0, bPscCreset
			bne     $s7, $t0, bPscCreset	#OR lastBG != -1:
			j       bPscCend
			bPscCreset:
				jal     restoreSettings
				li      $s6, -1
				li      $s7, -1
		bPscCend:

		#change foreground color if needed
		li      $t0, 2		#if pcode == 2 or pcode == 4
		beq     $s3, $t0, bPFGColor
		li      $t0, 4
		beq     $s3, $t0, bPFGColor
		j       bPFCend
		bPFGColor:
			lbu     $t0, 5($s0)
			beq     $t0, $s6, bPFCend	#if color != lastFG
				move	$s6, $t0	#store to lastFG
				move	$a0, $t0	#set as FG color
				li      $a1, 1
				jal     setColor
		bPFCend:
		
		#change background color if needed
		li      $t0, 3		#if pcode == 2 or pcode == 4
		beq     $s3, $t0, bPBGColor
		li      $t0, 4
		beq     $s3, $t0, bPBGColor
		j       bPBCend
		bPBGColor:
			lbu     $t0, 6($s0)
			beq     $t0, $s7, bPBCend	#if color != lastBG
				move	$s7, $t0	#store to lastBG
				move	$a0, $t0	#set as BG color
				li      $a1, 0
				jal     setColor
		bPBCend:
		
		
		#then print string to (row, col)
		lw      $a0, 8($s0)
		move	$a1, $s1
		move	$a2, $s2
		jal     printString
		
		bPscont:
		addi	$s0, $s0, 12
		j       bPscan
	bPsend:

	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s0, -8($fp)
	lw      $s1, -12($fp)
	lw      $s2, -16($fp)
	lw      $s3, -20($fp)
	lw      $s6, -24($fp)
	lw      $s7, -28($fp)
	addi	$sp, $sp, 28
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr      $ra
	
.data
.align 2
intToCharSpace:
	.space	4	#storing 4 bytes, only using 3, because of spacing.
.text
intToChar:
	########################################################################
	# Given an int x where 0 <= x <= 999, converts the integer into 3 bytes,
	# which are the character representation of the int. If the integer
	# requires larger than 3 chars to represent, only the 3 least 
	# significant digits will be converted.
	#
	# $a0 = integer to convert
	#
	# Return Values:
	# $v0 = address of the bytes, in the following order, 1's, 10's, 100's
	#
	# Register Usage
	# $t0-$t9 = temporary value storage
	########################################################################
	li	$t0, 0x30	#'0' in ascii, we add according to the number
	#separate the three digits of the passed in number
	#1's = x%10
	#10's = x%100 - x%10
	#100's = x - x$100
	la      $v0, intToCharSpace
	#ones
	li      $t1, 10
	div     $a0, $t1
	mfhi	$t7			#x%10
	add     $t1, $t0, $t7	#byte = 0x30 + x%10
	sb      $t1, 0($v0)
	#tens
	li      $t1, 100
	div     $a0, $t1
	mfhi	$t8			#x%100
	sub     $t1, $t8, $t7	#byte = 0x30 + (x%100 - x%10)/10
	li      $t3, 10
	div     $t1, $t3
	mflo	$t1
	add     $t1, $t0, $t1
	sb      $t1, 1($v0)
	#100s
	li      $t1, 1000
	div     $a0, $t1
	mfhi	$t9			#x%1000
	sub     $t1, $t9, $t8	#byte = 0x30 + (x%1000 - x%100)/100
	li      $t3, 100
	div     $t1, $t3
	mflo	$t1
	add     $t1, $t0, $t1
	sb      $t1, 2($v0)
	jr      $ra
	
.data
.align 2
setFGorBG:
	.byte 0x1b, 0x5b, 0x34, 0x38, 0x3b, 0x35, 0x3b, 0x30, 0x30, 0x30, 0x6d, 0x00
.text
setColor:
	########################################################################
	# Prints the escape sequence that sets the color of the text to the
	# color specified.
	# 
	# xfce4-terminal supports the 256 color lookup table assignment, 
	# see the index for a list of color codes.
	#
	#
	# $a0 = color code (see index)
	# $a1 = 0 if setting background, 1 if setting foreground
	#
	# Register Usage
	# $s0 = temporary arguement storage accross calls
	# $s1 = temporary arguement storage accross calls
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		
	sw      $fp, 0($sp)
	add     $fp, $zero, $sp
	addi	$sp, $sp, -12		
	sw      $ra, -4($fp)
	sw      $s0, -8($fp)
	sw      $s1, -12($fp)

	move	$s0, $a0
	move	$s1, $a1

	jal     intToChar		#get the digits of the color code to print
	
	move	$a0, $s0
	move	$a1, $s1
	
	la      $t0, setFGorBG
	lb      $t1, 0($v0)		#alter the string to print
	sb      $t1, 9($t0)
	lb      $t1, 1($v0)
	sb      $t1, 8($t0)
	lb      $t1, 2($v0)
	sb      $t1, 7($t0)
	
	beq     $a1, $zero, sCsetBG	#set the code to print FG or BG
		#setting FG
		li      $t1, 0x33
		j       sCset
	sCsetBG:
		li      $t1, 0x34
	sCset:
		sb      $t1, 2($t0)
	
	li      $v0, 4
	move	$a0, $t0
	syscall
		
	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s0, -8($fp)
	lw      $s1, -12($fp)
	addi	$sp, $sp, 12
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra

.data
.align 2
rSstring:
	.byte 0x1b, 0x5b, 0x30, 0x6d, 0x00
.text
restoreSettings:
	########################################################################
	# Prints the escape sequence that restores all default color settings to
	# the terminal
	#
	# Register Usage
	# NA
	########################################################################
	la      $a0, rSstring
	li      $v0, 4
	syscall
	
	jr      $ra

.text
startGLIM:
	########################################################################
	# Sets up the display in order to provide
	# a stable environment. Call endGLIM when program is finished to return
	# to as many defaults and stable settings as possible.
	# Unfortunately screen size changes are not code-reversible, so endGLIM
	# will only return the screen to the hardcoded value of 24x80.
	#
	#
	# $a0 = number of rows to set the screen to
	# $a1 = number of cols to set the screen to
	#
	# Register Usage
	# NA
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		
	sw      $fp, 0($sp)
	add     $fp, $zero, $sp
	addi	$sp, $sp, -4		
	sw      $ra, -4($fp)
	
	jal     setDisplaySize
	jal     restoreSettings
	jal     clearScreen
	jal     hideCursor
	
	#Stack Restore
	lw      $ra, -4($fp)
	addi	$sp, $sp, 4
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr      $ra
	

.text
endGLIM:
	########################################################################
	# Reverts to default as many settings as it can, meant to end a program
	# that was started with startGLIM. The default terminal window in
	# xfce4-terminal is 24x80, so this is the assumed default we want to
	# return to.
	#
	# Register Usage
	# NA
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		
	sw      $fp, 0($sp)
	add     $fp, $zero, $sp
	addi	$sp, $sp, -4		
	sw      $ra, -4($fp)
	
	li      $a0, 24
	li      $a1, 80
	jal     setDisplaySize
	jal     restoreSettings
	jal     clearScreen
	jal     showCursor
	li      $a0, 0
	li      $a1, 0
	jal     setCursor
	
	#Stack Restore
	lw      $ra, -4($fp)
	addi	$sp, $sp, 4
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr      $ra
	
.data
.align 2
hCstring:
	.byte 0x1b, 0x5b, 0x3f, 0x32, 0x35, 0x6c, 0x00
.text
hideCursor:
	########################################################################
	# Prints the escape sequence that hides the cursor
	#
	# Register Usage
	# NA
	########################################################################
	la      $a0, hCstring
	li      $v0, 4
	syscall
	
	jr      $ra

.data
.align 2
sCstring:
	.byte 0x1b, 0x5b, 0x3f, 0x32, 0x35, 0x68, 0x00
.text
showCursor:
	########################################################################
	#Prints the escape sequence that restores the cursor visibility
	#
	# Register Usage
	# NA
	########################################################################
	la      $a0, sCstring
	li      $v0, 4
	syscall
	jr      $ra

.data
.align 2
sDSstring:
	.byte 0x1b, 0x5b, 0x38, 0x3b, 0x30, 0x30, 0x30, 0x3b, 0x30, 0x30, 0x30, 0x74 0x00
.text
setDisplaySize:
	########################################################################
	# Prints the escape sequence that changes the size of the display to 
	# match the parameters passed. The number of rows and cols are 
	# ints x and y s.t.:
	# 0<=x,y<=999
	#
	# $a0 = number of rows
	# $a1 = number of columns
	#
	# Register Usage
	# $s0 = temporary $a0 storage
	# $s1 = temporary $a1 storage
	########################################################################
	# Stack Adjustments
	addi	$sp, $sp, -4		
	sw      $fp, 0($sp)
	add     $fp, $zero, $sp
	addi	$sp, $sp, -12		
	sw      $ra, -4($fp)
	sw      $s0, -8($fp)
	sw      $s1, -12($fp)
	
	move	$s0, $a0
	move	$s1, $a1
	
	#rows
	jal     intToChar		#get the digits of the params to print
	
	la      $t0, sDSstring
	lb      $t1, 0($v0)		#alter the string to print
	sb      $t1, 6($t0)
	lb      $t1, 1($v0)
	sb      $t1, 5($t0)
	lb      $t1, 2($v0)
	sb      $t1, 4($t0)
	
	#cols
	move	$a0, $s1
	jal     intToChar		#get the digits of the params to print
	
	la      $t0, sDSstring
	lb      $t1, 0($v0)		#alter the string to print
	sb      $t1, 10($t0)
	lb      $t1, 1($v0)
	sb      $t1, 9($t0)
	lb      $t1, 2($v0)
	sb      $t1, 8($t0)
	
	li      $v0, 4
	move	$a0, $t0
	syscall
	
	#Stack Restore
	lw      $ra, -4($fp)
	lw      $s0, -8($fp)
	lw      $s1, -12($fp)
	addi	$sp, $sp, 12
	lw      $fp, 0($sp)
	addi	$sp, $sp, 4
	jr      $ra
##############################################################################
#					END OF GLIM
##############################################################################	
##############################################################################
#				STUDENT CODE BELOW THIS LINE
##############################################################################

##############################################################################
#				STUDENT CODE BELOW THIS LINE
##############################################################################
##################################################
# minesweeper.s is a game code that support the usage and 
# allow player to play this game with assembly language in the terminal
# instruction: 2,4,6,8 are up down left right
# 7 to mark, 5 to reveal q to quit and r to restart.
# players need to reveal on the sapces in the given time at left cornor
#####################################################################


# set kernel mode
	.ktext 0x80000180
	.set noat
	move $k1, $at
	.set at
	la $k0, kernelSpace
	sw $a0, 0($k0)
	sw $a1, 4($k0)
	sw $v0, 8($k0)
	sw $ra, 12($k0)

	# modify the status register to make sure the interupts are avaliable
	mfc0 $a0, $12
	li $a1, 0x8801
	or $a0, $a0, $a1
	mtc0 $a0, $12
	
	
	
	
	mfc0 $a0, $13  # Obtain cause register
	andi $v0, $a0, 0x7C  #Check for interrupts
	beq $v0, $zero, reset #if zero it is interrupt so jump
	j Finish

reset:
	mfc0 $a0, $13 
	andi $v0, $a0, 0x8000

	xor $a0, $a0, $v0
	mtc0 $a0, $13 
	mtc0 $zero, $9
		
	addi $a0 $zero 100
	mtc0 $a0 $11
	
Finish:
	lw $a0, 0($k0)
	lw $a1, 4($k0)
	lw $v0, 8($k0)
	lw $ra, 12($k0)
	
	.set noat
	move $at, $k1
	.set at
	mfc0 $k0 $12		# Set Status register
	ori  $k0 0x1		# Interrupts enabled
	mtc0 $k0 $12
	eret
.kdata 
kernelSpace:
	.space 16
.data
.align 2
time:
	.space 4
win:
	.space 4
times:
	.asciiz "123"
.text
#################################################################
# the main function do the exception handlers and replacing the default exceptions
# arguements: NA
# used registers:$t1 - $t3, $s0, $s1, $ra
##################################################################
main:
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $s0, 4($sp) #losing flag
	sw $s1, 8($sp) # space left
	li $s0, 0
	# set the $11 for the time
	li $t0, 100
	mtc0 $t0, $11
	# reset register
	li $s1, 0
	
	#calculate number of spaces to fill in order to win
	lw $t0, totalBombs
	lw $t1, gameRows
	lw $t2, gameCols
	multu $t1, $t2
	mflo $t3
	sub $t3, $t3, $t0
	sw $t3, win
	
	#calculate x
	lw $t0, totalBombs
	lw $t1, gameRows
	lw $t2, gameCols
	multu $t1, $t2
	mflo $t1
	sub $t1, $t1, $t0
	li $t2, 888
	multu $t0, $t2
	mflo $t0
	divu $t0, $t1
	mflo $t0
	li $t2, 5
	bge $t2, $t0, five
	li $t2, 999
	bge $t0, $t2, nine
	sw $t0, time

###########################
# if time exception 
############################
timer:
	# lose
	li $t0, 1
	beq $s1, $t0, Lose
	# wining condition
	lw $t0, win
	beq $t0, $0, Win
	
	lw $t0, time
	li $t1, -1
	beq $t0, $t1, Lose
	
	# check if keyboard exception occured, and  whether to reset the bit back to 0
	lb $t0, 0xffff0000
	li $t1, 1
	and $t2, $t0, $t1
	beq $t2, $t1, keys
	beq $s0, $0, timer
	# check if time exception occured, and  whether to reset the bit back to 0
	mfc0 $t0, $13
	li $t1, 0x8000
	and $t2, $t0, $t1
	bne $t2, $t1, timer
	
	mtc0 $0, $9
	# reset the time exception bit to 0
	mfc0 $t0, $13
	li $t1, 0x8000
	sub $t0, $t0, $t1
	mtc0 $t0, $13
###################
#print time, upload the time
#####################
Printtime:
	# update timer
	lw $t0, time
	addi $t0, $t0, -1
	sw $t0, time
	move $a0, $t0

	jal intToChar

	
	lw $t0, gameRows
	move $a1, $t0
	li $a2, 0
	
	
	lbu $t0, 0($v0)
	lbu $t1, 1($v0)
	lbu $t2, 2($v0)
	la $t3, times
	sb $t2, 0($t3)
	sb $t1, 1($t3)
	sb $t0, 2($t3)
	move $a0, $t3

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printString
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	j timer
###################
#set max time
###################
five:
	li $t0, 5
	sw $t0, time #the max time should be 5
	j timer
#########################
# set max time
############################
nine:
	li $t0, 999
	sw $t0, time
	j timer
#############################
# if keyboard interuption
#############################
keys:
	# set bit 1 of the control register
	lw $a0, 0xffff0000
	addi $a0, $a0, 2
	sw $a0, 0xffff0000
	lb $t0, 0xffff0004
	li $t1, 113
	beq $t0, $t1, quit
	li $t1, 114
	beq $t0, $t1, Restart
	li $t1, 56
	beq $t0, $t1, up
	li $t1, 50
	beq $t0, $t1, down
	li $t1, 52
	beq $t0, $t1, left
	li $t1, 54
	beq $t0, $t1, right
	
	li $t1, 55
	beq $t0, $t1, mark
	li $t1, 53
	bne $t0, $t1, timer
	
	# lose
	li $t0, 1
	beq $s1, $t0, Lose
	# wining condition
	lw $t0, win
	beq $t0, $0, Win
	
	lw $a0, newCursorRow
	lw $a1, newCursorCol
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal Doreveal
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal updateCursor
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	# lose
	li $t0, 1
	beq $s1, $t0, Lose
	# wining condition
	lw $t0, win
	beq $t0, $0, Win
	j timer
	
##########################
# if win the game
########################
Win:
	#reset the $9 to 0
	mtc0 $0, $9
	#reset time interuption
	mfc0 $t0, $12
	li $t1, 0x8000
	not $t1, $t1
	and $t2, $t0, $t1
	mtc0 $t2, $12
	
	la $a0, gameWon
	lw $t0, gameRows
	move $a1, $t0
	li $a2, 0
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printString
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	j wait

##########################
# if lose the game
###############################
Lose:
	li $s1, 1
	#reset the $9 to 0
	mtc0 $0, $9
	#reset time interuption
	mfc0 $t0, $12
	li $t1, 0x8000
	not $t1, $t1
	and $t2, $t0, $t1
	mtc0 $t2, $12
	
	la $a0, gameLost
	lw $t0, gameRows
	move $a1, $t0
	li $a2, 0
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printString
	lw $ra, 0($sp)
	addi $sp, $sp, 4

##############################
# game is over waiting for the keyboard interupts
################################
wait:
	lw $t0, 0xffff0000
	li $t1, 1
	and $t0, $t1, $t0
	beq $t0, $t1, keys
	
	j wait

############################
# quit the game
###########################
quit:
	# reset the registers 
	mfc0 $t0, $13
	and $t0, $t0, $0
	mtc0 $t0, $13	
	
	sw $0, 0xffff0000
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12
	li $v0, 0
	jr $ra

###########################
# restart the game
##########################
Restart:
	#reset the $9 to 0
	mtc0 $0, $9
	# reset control register
	sw $0, 0xffff0000
	
	mtc0 $0, $13
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12
	li $v0, 1
	jr $ra

#######################
# move the cursor upwards
########################
up:
	lw $t1, cursorRow
	beq $t1, $0, timer
	addi $t1, $t1, -1
	sw $t1, newCursorRow
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal updateCursor
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	# stop update time if the game is over
	# lose
	li $t0, 1
	beq $s1, $t0, Lose
	# wining condition
	lw $t0, win
	beq $t0, $0, Win
	j timer
######################
# move the cursor downwards
#####################
down:
	lw $t0, gameRows
	lw $t1, cursorRow
	addi $t0, $t0, -1
	beq $t1, $t0, timer
	addi $t1, $t1, 1
	sw $t1, newCursorRow
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal updateCursor
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	# stop update time if the game is over
	# wining condition
	lw $t0, win
	beq $t0, $0, Win
	# lose
	li $t0, 1
	beq $s1, $t0, Lose
	j timer

######################
# move the cursor leftwards
#####################
left:
	
	lw $t1, cursorCol
	beq $t1, $0, timer
	addi $t1, $t1, -1
	sw $t1, newCursorCol
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal updateCursor
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	# stop update time if the game is over
	# lose
	li $t0, 1
	beq $s1, $t0, Lose
	# wining condition
	lw $t0, win
	beq $t0, $0, Win
	j timer

######################
# move the cursor rightwards
#####################
right:
	lw $t0, gameCols
	lw $t1, cursorCol
	addi $t0, $t0, -1
	beq $t1, $t0, timer
	addi $t1, $t1, 1
	sw $t1, newCursorCol
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal updateCursor
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	# stop update time if the game is over
	# lose
	li $t0, 1
	beq $s1, $t0, Lose
	# wining condition
	lw $t0, win
	beq $t0, $0, Win
	j timer

#########################
# mark the tile
#########################
mark:
	# stop update time if the game is over
	# lose
	li $t0, 1
	beq $s1, $t0, Lose
	# wining condition
	lw $t0, win
	beq $t0, $0, Win
	
	lw $t0, cursorRow
	lw $t1, cursorCol
	lw $t2, gameRows
	lw $t3, gameCols
	la $t4, gameBoard
	multu $t0, $t3
	mflo $t5
	add $t5, $t4, $t5
	add $t5, $t1, $t5
	lbu $t0, 0($t5)
	
	li $t1, 2
	and $t2, $t0, $t1
	# if the tile is already marked then unmark it
	beq $t2, $t1, unmark
	ori $t0, $t0, 2
	
	li $t1, 4
	and $t2, $t0, $t1
	# if the tile is revealed then do nothing 
	beq $t2, $t1, timer
	addi $t0, $t0, -4
	
	# update the tile
	
	sb $t0, 0($t5)
	lw $a0, cursorRow
	lw $a1, cursorCol
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printTile
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	j timer

###########################
# unmark the tile
############################
unmark:
	lw $a0, cursorRow
	lw $a1, cursorCol
	xori $t0, $t0, 6
	sb $t0, 0($t5)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printTile
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	j timer
	
#########################################
# reveal the tiles from each revealed instructin
# arguement:  $a0-$a1
# register usage: $s0-$s1, $t0- $t5, $ra
##################################################
Doreveal:
	
	li $s0, 1 # the first move has been made
	
	# check reveal state
	lw $t0, gameRows
	lw $t1, gameCols
	la $t2, gameBoard
	multu  $a0, $t1
	mflo $t0
	add $t0, $t0, $a1
	add $t0, $t0, $t2
	lbu $t3, 0($t0)
	li $t4, 4
	and $t5, $t3, $t4
	beq $t4, $t5, Stop
	ori $t3, $t3, 4
	sb $t3, 0($t0)
	
	
	# get the tile address
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	jal getTile
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	addi $sp, $sp, 12
	# if marked
	la $t0, marked
	beq $t0, $v0, Stop
	# if bomb
	la $t0, bomb
	beq $t0, $v0, Boom
	# if not space
	la $t0, has0
	bne $t0, $v0, Print
	
	# if space
	# check 8 directions
######################
# check upward direction to see if revealed the neighbor
########################
Checkup:
	# check up
	beq $a0, $0, Checkdown
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	addi $a0, $a0, -1
	jal Doreveal
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	addi $sp $sp, 12

######################
# check downward direction to see if revealed the neighbor
########################
Checkdown:
	#check down
	lw $t0, gameRows
	addi $t0, $t0, -1
	beq $a0, $t0, Checkleft
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	addi $a0, $a0, 1
	jal Doreveal
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	addi $sp $sp, 12

######################
# check leftward direction to see if revealed the neighbor
########################
Checkleft:
	#check left
	beq $a1, $0, Checkright
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	addi $a1, $a1, -1
	jal Doreveal
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	addi $sp $sp, 12

######################
# check rightward direction to see if revealed the neighbor
########################
Checkright:
	#check right
	lw $t0, gameCols
	addi $t0, $t0, -1
	beq $a1, $t0, Checkupleft
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	addi $a1, $a1, 1
	jal Doreveal
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	addi $sp $sp, 12

######################
# check rightward direction to see if revealed the neighbor
########################
Checkupleft:
	beq $a0, $0, Checkupright
	beq $a1, $0, Checkupright
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	addi $a0, $a0, -1
	addi $a1, $a1, -1
	jal Doreveal
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	addi $sp $sp, 12

######################
# check upright direction to see if revealed the neighbor
########################
Checkupright:
	lw $t2, gameCols
	addi $t2, $t2, -1
	beq $a0, $0, Checkdownleft
	beq $a1, $t2, Checkdownleft
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	addi $a0, $a0, -1
	addi $a1, $a1, 1
	jal Doreveal
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	addi $sp $sp, 12

######################
# check downleft direction to see if revealed the neighbor
########################
Checkdownleft:
	lw $t2, gameRows
	addi $t2, $t2, -1
	beq $a1, $0, Checkdownright
	beq $a0, $t2, Checkdownright
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	addi $a0, $a0, 1
	addi $a1, $a1, -1
	jal Doreveal
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	addi $sp $sp, 12

######################
# check downright direction to see if revealed the neighbor
########################
Checkdownright:
	lw $t1, gameRows
	lw $t2, gameCols
	addi $t1, $t1, -1
	addi $t2, $t2, -1
	beq $a0, $t1, Print
	beq $a1, $t2, Print
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	jal Doreveal
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	addi $sp $sp, 12

##################
# print the cursor's position tile
####################
Print:
	lw $t0, win
	addi $t0, $t0, -1
	sw $t0, win
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	jal printTile
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	addi $sp, $sp, 12
	
####################
# has reach the boundry
#######################
Stop:
	jr $ra
#####################
# hit a bomb
####################
Boom: 
	li $s1, 1
	jr $ra

################################################################
# return the address of the byte of the position that is given
# arguement: $a0, $a1
# register usage: $s1, $s2, $s0, $t1-$t3
############################################################
getTile:
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	
	li $s2, 0
	move $s0, $a0
	move $s1, $a1
	
	# check if the position is revealed
	la $t0, gameBoard
	lw $t1 gameCols
	multu $s0, $t1
	mflo $t2
	add $t2, $t2, $s1
	add $t2, $t0, $t2
	lbu $t3, 0($t2)
	sll $t3, $t3, 29
	srl $t3, $t3, 31
	beq $t3, $0, Unreviewed
	
	#check if the position is marked
	la $t0, gameBoard
	lw $t1 gameCols
	multu $s0, $t1
	mflo $t2
	add $t2, $t2, $s1
	add $t2, $t0, $t2
	lbu $t3, 0($t2)
	sll $t3, $t3, 30
	srl $t3, $t3, 31
	bne $t3, $0, Marked
	
	#check if there is a bomb at this position 
	jal hasBomb
	add $s2, $s2, $v0
	bne $s2, $0, Isbomb
checkupleft:
	# if there is no upleft tile
	beq $s0, $0, checkup
	beq $s1, $0, checkup
	# check (row-1, col-1)
	addi $a0, $s0, -1
	addi $a1, $s1, -1
	jal hasBomb
	add $s2, $s2, $v0
checkup:
	#if there is no up tile
	beq $s0, $0, checkupright
	#check (row-1, col)
	addi $a0, $s0, -1
	move $a1, $s1
	jal hasBomb
	add $s2, $s2, $v0
checkupright:
	#if there is no upright tile
	beq $s0, $0, checkleft
	lw $t0, gameCols
	addi $t0, $t0, -1
	beq $s1, $t0, checkleft

upright:
	#check (row-1, col+1)
	addi $a0, $s0, -1
	addi $a1, $s1, 1
	jal hasBomb
	add $s2, $s2, $v0


checkleft:
	# if there is no left tile
	beq $s1, $0, checkright
	#check (row, col-1)
	move $a0, $s0
	addi $a1, $s1, -1
	jal hasBomb
	add $s2, $s2, $v0

checkright:
	# if there is no right tile
	lw $t0, gameCols
	addi $t0, $t0, -1
	beq $t0, $s1, checkdownleft
	# check (row, col+1)
	move $a0, $s0
	addi $a1, $s1, 1
	jal hasBomb
	add $s2, $s2, $v0

checkdownleft:
	# if there is no downleft tile
	beq $s1, $0, checkdown
	lw $t0, gameRows
	addi $t0, $t0, -1
	beq $t0, $s0, checkdown

downleft:
	#check (row+1, col-1)
	addi $a0, $s0, 1
	addi $a1, $s1, -1
	jal hasBomb
	add $s2, $s2, $v0

	

checkdown:
	# if there is no down tile
	lw $t0, gameRows
	addi $t0, $t0, -1
	beq $s0, $t0, checkdownright
	#check (row+1, col)
	addi $a0, $s0, 1
	move $a1, $s1
	jal hasBomb
	add $s2, $s2, $v0

checkdownright:
	# if there is no down right tile
	lw $t0, gameRows
	lw $t1, gameCols
	addi $t0, $t0, -1
	addi $t1, $t1, -1
	beq $s0, $t0, check
	beq $s1, $t1, check
	
downright:
	#check (row+1, col+1)
	addi $a0, $s0, 1
	addi $a1, $s1, 1
	jal hasBomb
	add $s2, $s2, $v0

# add the number of bombs around the neighbor together	
check:
	beq $s2, $0, Has0
	li $t1, 1
	beq $s2, $t1, Has1
	li $t1, 2
	beq $s2, $t1, Has2
	li $t1, 3
	beq $s2, $t1, Has3
	li $t1, 4
	beq $s2, $t1, Has4
	li $t1, 5
	beq $s2, $t1, Has5
	li $t1, 6
	beq $s2, $t1, Has6
	li $t1, 7
	beq $s2, $t1, Has7
	li $t1, 8
	beq $s2, $t1, Has8

Isbomb:
	la $v0, bomb
	j end
	
Marked:
	la $v0, marked
	j end
	
Unreviewed:
	la $v0, tile
	j end

Has0:
	la $v0, has0
	j end
	
Has1:
	la $v0, has1
	j end
	
Has2:
	la $v0, has2
	j end
	
Has3:
	la $v0, has3
	j end
	
Has4:
	la $v0, has4
	j end
	
Has5:
	la $v0, has5
	j end
	
Has6:
	la $v0, has6
	j end
	
Has7:
	la $v0, has7
	j end

Has8:
	la $v0, has8
	j end
###################
# finish the work return the value
###################
end:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra
#######################################################
# indicate if the position contains a bombvb or not
# arguement: $a0, $a1
# used register: $t0 - $t4, $a0 - $a1, $v0
#####################################################
hasBomb:
	lw $t0, gameCols
	move $t1, $a0
	move $t2, $a1
	multu $t1, $t0
	mflo $t3
	add $t3, $t3, $t2
	la $t4 gameBoard
	add $t4, $t4, $t3
	lbu $t3, 0($t4)
	sll $t3, $t3, 31
	srl $t3, $t3, 31
	li $t2, 1
	beq $t3, $t2, yes
	move $v0, $0
	jr $ra
########################
# there is bomb in this tile
######################
yes:
	li $v0, 1
	jr $ra

##################################################
#set the bomb for the game
#arguement: $a0-$a1
#registerusage: $t0-$t5
#################################################
setBomb:
	move $t4, $a0
	move $t5, $a1
	la $t0, gameBoard
	lw $t1, gameCols
	multu $t4, $t1
	mflo $t2
	add $t2, $t2, $t5
	add $t2, $t0, $t2
	lbu $t3, 0($t2)
	li $t0, 1
	or $t3, $t0, $t3
	sb $t3, 0($t2)
	jr $ra
	
########################################################
# I probably don't need this function
#
#
#########################################################
prepareBoard:
	jr $ra

##########################################################
# Use the print string function to print the symbol at the given position on terminal
# Arguement: $a0, $a1
# register usage: $t1-$t2 $a0-$a2
###########################################################
printTile:

	move $t1, $a0
	
	move $t2, $a1
	

	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	jal getTile
	lw $ra, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	addi $sp, $sp, 12
	
	move $a0, $v0
	move $a1, $t1
	move $a2, $t2
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal printString
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
