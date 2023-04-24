#Sohan Vidiyala
# suv200000


# width of screen in pixels
.eqv WIDTH 64
# height of screen in pixels
.eqv HEIGHT 64
# colors
.eqv	RED 		0x00FF0000
.eqv 	GREEN	0X0000FF00
.eqv 	BLUE 	0X000000FF
.eqv 	WHITE	0X00FFFFFF
.eqv	YELLOW	0X00FFFF00
.eqv	CYAN	0X0000FFFF
.eqv	ORANGE	0X00FFA500
.eqv	MAGENTA	0X00FF00FF
.eqv	PINK		0X00FFC0CB
.eqv	BROWN	0X00964B00
.eqv	WHITE	0X00FFFFFF
.eqv	GREY	0X00808080
.eqv	DBROWN	0X00654321

.data
colors:		.word	DBROWN, DBROWN, DBROWN, DBROWN	  #array of colors
balloonColors:	.word	RED, BLUE, GREEN, YELLOW, RED, MAGENTA, CYAN, MAGENTA # colors for the ballon
beg:		.asciiz	"Get Carl and Ellie's house to Paradise Falls!\nUse wasd to move up, left, down, and right. Enter space when you get there."
end:		.asciiz	"You made it! Thanks for the adventure!"

.text
main:

	#display Intro text with objective and controls
	li	$v0, 55
	la	$a0, beg
	li	$a1, 3
	syscall

	# draw cliff 
	jal	cliff
	
	#position of house always at bottom right corner
	addi 	$a3, $0, WIDTH    # a3 = X = WIDTH/2
	addi 	$a3, $a3, 306
	addi 	$a1, $0, HEIGHT   # a1 = Y = HEIGHT/2
	addi 	$a1, $a1, -15
	la 	$s0, colors  #s0 holds colors
	li 	$s3, 0
		

loop:

	#draw house
	jal 	draw_house
	# input?
	lw $t0, 0xffff0000  #holds input
    	beq $t0, 0, loop   # if nothing, keep looping
    	
    	# process input
	lw 	$s1, 0xffff0004
	beq	$s1, 32, exit		# space
	beq	$s1, 119, up 		# w
	beq	$s1, 115, down 	# s
	beq	$s1, 97, left  		# a
	beq	$s1, 100, right		# d
	# invalid input, ignore
	j	loop
	
	# process input
up:	li 	$a2, 0		# make the color black
	jal	erase_house	# erase house + balloons
	addi	$a1, $a1, -2	# move by two spaces
	jal	draw_house	# draw house
	j	loop			# jump to loop
	
	# ^^ comments the same for remaining input options

down:	li	$a2, 0		# make the color black
	jal	erase_house
	addi	$a1, $a1, 2
	jal	draw_house
	j	loop
	
left:	li	$a2, 0		# make the color black
	jal	erase_house
	addi	$a3, $a3, -2
	jal	draw_house
	j	loop
	
right:	li	$a2, 0		# make the color black
	jal	erase_house
	addi	$a3, $a3, 2
	jal	draw_house
	j	loop
	
	
	
	

exit:	

#display exit message
li	$v0, 55
la	$a0, end
li	$a1, 3
syscall

#play married Life from UP
jal	married_life

#exit the program
li	$v0, 10
	syscall

	



draw_house:

	#set counter and values for loop
	li $t0, 1
	li $t1, 10
	li $t5, 4
	

rightLoop:
	# s1 = address = $gp + 4*(x + y*width)
	li	$v0, 32
	li	$a0, 5
	syscall

	# ^^ Ended up not using a marquee effect 

	beq 	$t0, $t1, reset1
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	add 	$t9, $t9, $t0
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	beq 	$s3, $t5, resetColorsR 
	lw	$a2, ($s0)	  # load color into $a2 from array 
	sw	$a2, ($t9)	  # store color at memory location
	addi 	$t0, $t0, 1
	addi	$s0, $s0, 4       # move to the next color
	addi 	$s3, $s3, 1       # move counter of color array 
	j rightLoop
	
	
resetColorsR:
	addi $s0, $s0, -16	  # moves back to the first color of the array
	li   $s3, 0		  # resets color array counter
	j rightLoop
	
# reset (number) is used to set values (ie. x and y values) before moving to next loop 
	
reset1:
	li   $t0, 0
	li   $t1, 8
	addi $a3, $a3, 9
	j downLoop
	
downLoop:
	# s1 = address = $gp + 4*(x + y*width)
	li	$v0, 32
	la	$a0, 5
	syscall
	
	beq 	$t0, $t1, reset2
	add 	$t4, $a1, $t0
	mul	$t9, $t4, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	beq 	$s3, $t5, resetColorsD
	lw	$a2, ($s0)
	sw	$a2, ($t9)	  # store color at memory location
	addi 	$t0, $t0, 1
	addi	$s0, $s0, 4
	addi 	$s3, $s3, 1
	j downLoop
	
resetColorsD:
	addi $s0, $s0, -16
	li   $s3, 0
	j downLoop

reset2:
	li   $t0, 1
	li   $t1, 10
	addi $a1, $a1, 7
	j leftLoop
	
leftLoop:
	# s1 = address = $gp + 4*(x + y*width)
	li	$v0, 32
	la	$a0, 5
	syscall
	
	beq 	$t0, $t1, reset3
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	sub 	$t9, $t9, $t0
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	beq 	$s3, $t5, resetColorsL
	lw	$a2, ($s0)
	sw	$a2, ($t9)	  # store color at memory location
	addi 	$t0, $t0, 1
	addi	$s0, $s0, 4
	addi 	$s3, $s3, 1
	j leftLoop
	
resetColorsL:
	addi $s0, $s0, -16
	li   $s3, 0
	j leftLoop
	
reset3:
	li 	$t0, 1
	li	$t1, 8
	addi 	$a3, $a3, -9
	j upLoop
	
upLoop:
	# s1 = address = $gp + 4*(x + y*width)
	li	$v0, 32
	la	$a0, 5
	syscall
	
	beq 	$t0, $t1, reset4
	sub 	$t6, $a1, $t0
	mul	$t9, $t6, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	beq 	$s3, $t5, resetColorsU
	lw	$a2, ($s0)
	sw	$a2, ($t9)	  # store color at memory location
	addi 	$t0, $t0, 1
	addi	$s0, $s0, 4
	addi 	$s3, $s3, 1
	j upLoop
	
resetColorsU:
	addi $s0, $s0, -16
	li   $s3, 0
	j upLoop
	
	
########### ^^ Draws the rectange of the house
	
reset4:
	subi $a1, $a1, 7
	j fillHouse
	
######### 	      FILLHOUSE function draws each pixel and fills house with yellow, green, and pink
#########	     Can be much more optimized by using loops to fill in	
	
fillHouse:
		addi $a2, $0, YELLOW
		addi $a3, $a3, 8
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		#mul	$t9, $a1, WIDTH   # y * WIDTH
		#add	$t9, $t9, $a3	  # add X
		#mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		#add	$t9, $t9, $gp	  # add to base address
		#sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, 1
		
		#mul	$t9, $a1, WIDTH   # y * WIDTH
		#add	$t9, $t9, $a3	  # add X
		#mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		#add	$t9, $t9, $gp	  # add to base address
		#sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a2, $0, GREEN
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -4
		
		addi $a1, $a1, 1
		
		#mul	$t9, $a1, WIDTH   # y * WIDTH
		#add	$t9, $t9, $a3	  # add X
		#mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		#add	$t9, $t9, $gp	  # add to base address
		#sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		#mul	$t9, $a1, WIDTH   # y * WIDTH
		#add	$t9, $t9, $a3	  # add X
		#mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		#add	$t9, $t9, $gp	  # add to base address
		#sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		#mul	$t9, $a1, WIDTH   # y * WIDTH
		#add	$t9, $t9, $a3	  # add X
		#mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		#add	$t9, $t9, $gp	  # add to base address
		#sw	$a2, ($t9)	  # store color at memory location
		
		addi $a2, $0, PINK
		addi $a3, $a3, -2
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location


		
		addi $a3, $a3, -4
		addi $a1, $a1, -1
		j tri1
	
	
## tri1 and tri2 draw the roof of the house and fills it in 
## again pixel by pixel, can be much more optimized using functions + loops
	
tri1:
	addi	$a2, $0, CYAN
	addi	$a1, $a1, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, -1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, -1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, 1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi	$a2, $0, YELLOW
	addi $a1, $a1, 1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a3, $a3, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a3, $a3, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi	$a1, $a1, 1
	addi $a3, $a3, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, 1
	addi $a3, $a3, -1
	j 	tri2
	

tri2:
	addi $a2, $0, CYAN
	addi	$a3, $a3, 4
	addi $a1, $a1, -2
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi 	$a1, $a1, -1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi 	$a1, $a1, -1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi 	$a1, $a1, 1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi 	$a1, $a1, 1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi 	$a1, $a1, 1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	##### FILLING IN
	
	addi $a2, $0, YELLOW
	addi $a3, $a3, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	
	addi $a3, $a3, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	

	
	addi $a3, $a3, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, 2
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	
	addi $a3, $a3, -1

	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, -1

	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi	$a3, $a3, -5
	addi $a1, $a1, 2
	j	chimney
	
################ Draws the chimney of the house
	
chimney:
		addi $a2, $0, BROWN

		addi 	$a3, $a3, 3
		addi 	$a1, $a1, -3
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		

		
		addi $a3, $a3, -4
		addi $a1, $a1, 3
		j	string
		

######## Draws string which is attatched to chimney

string:

		addi $a1, $a1, -6
		addi $a3, $a3, 4
		addi $a2, $0, WHITE
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a1, $a1, 1
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a3, $a3, -1
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a3, $a3, 4
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a3, $a3, -1
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		
		addi $a3, $a3, -5
		addi $a1, $a1, 7
		j 	ballons
		
		
####### Draws balloons, uses loops to draw rows of balloons where each pixel is one balloon

ballons:
		addi $a3, $a3, -7
		addi $a1, $a1, -9
		
		li $t7, 1
		li $t8, 8
		li $t3, 8
		li $s4, 0
		la $s5, balloonColors
		
		
		bLoop:
					beq	$t7, $t3, preBrow2
					mul	$t9, $a1, WIDTH   # y * WIDTH
					add	$t9, $t9, $a3	  # add X
					add 	$t9, $t9, $t0
					mul	$t9, $t9, 4	  # multiply by 4 to get word offset
					add	$t9, $t9, $gp	  # add to base address
					beq 	$s4, $t8, resetBalloonColors
					lw	$a2, ($s5)	  # load color into $a2 from array 
					sw	$a2, ($t9)	  # store color at memory location
					addi 	$t7, $t7, 1
					addi	$s5, $s5, 4       # move to the next color
					addi 	$s4, $s4, 1       # move counter of color array
					
					addi $a3, $a3, 1
					j bLoop
					
		resetBalloonColors:
		addi $s5, $s5, -32
		li $s4, 0
		j bLoop
		
					
		preBrow2:
					li 	$t3, 10
					li 	$t7, 1
					#addi $a3, $a3, 1
					addi $a1, $a1, -1
					j brow2
					
		brow2:
		
					beq	$t7, $t3, prebrow3
					mul	$t9, $a1, WIDTH   # y * WIDTH
					add	$t9, $t9, $a3	  # add X
					add 	$t9, $t9, $t0
					mul	$t9, $t9, 4	  # multiply by 4 to get word offset
					add	$t9, $t9, $gp	  # add to base address
					beq 	$s4, $t8, resetBalloonColors2
					lw	$a2, ($s5)	  # load color into $a2 from array 
					sw	$a2, ($t9)	  # store color at memory location
					addi 	$t7, $t7, 1
					addi	$s5, $s5, 4       # move to the next color
					addi 	$s4, $s4, 1       # move counter of color array
					
					addi $a3, $a3, -1
					j brow2
					
					
		resetBalloonColors2:
				addi $s5, $s5, -32
				li $s4, 0
				j brow2
				
		
		prebrow3:
				li	$t3, 10
				li 	$t7, 1
				addi $a3, $a3, 1
				addi $a1, $a1, -1
				j	brow3
				
				
		brow3:
		
					beq	$t7, $t3, prebrow4
					mul	$t9, $a1, WIDTH   # y * WIDTH
					add	$t9, $t9, $a3	  # add X
					add 	$t9, $t9, $t0
					mul	$t9, $t9, 4	  # multiply by 4 to get word offset
					add	$t9, $t9, $gp	  # add to base address
					beq 	$s4, $t8, resetBalloonColors3
					lw	$a2, ($s5)	  # load color into $a2 from array 
					sw	$a2, ($t9)	  # store color at memory location
					addi 	$t7, $t7, 1
					addi	$s5, $s5, 4       # move to the next color
					addi 	$s4, $s4, 1       # move counter of color array
					
					addi $a3, $a3, 1
					j brow3
					
					
		resetBalloonColors3:
				addi $s5, $s5, -32
				li $s4, 0
				j brow3
				
				
		prebrow4:
				li	$t3, 10
				li 	$t7, 1
				addi $a3, $a3, -1
				addi $a1, $a1, -1
				j	brow4
				
				
		brow4:
		
					beq	$t7, $t3, prebrow5
					mul	$t9, $a1, WIDTH   # y * WIDTH
					add	$t9, $t9, $a3	  # add X
					add 	$t9, $t9, $t0
					mul	$t9, $t9, 4	  # multiply by 4 to get word offset
					add	$t9, $t9, $gp	  # add to base address
					beq 	$s4, $t8, resetBalloonColors4
					lw	$a2, ($s5)	  # load color into $a2 from array 
					sw	$a2, ($t9)	  # store color at memory location
					addi 	$t7, $t7, 1
					addi	$s5, $s5, 4       # move to the next color
					addi 	$s4, $s4, 1       # move counter of color array
					
					addi $a3, $a3, -1
					j brow4
					
					
		resetBalloonColors4:
				addi $s5, $s5, -32
				li $s4, 0
				j brow4
				
				
				
		prebrow5:
				li	$t3, 10
				li 	$t7, 1
				addi $a3, $a3, 1
				addi $a1, $a1, -1
				j	brow5
				
				
		brow5:
		
					beq	$t7, $t3, prebrow6
					mul	$t9, $a1, WIDTH   # y * WIDTH
					add	$t9, $t9, $a3	  # add X
					add 	$t9, $t9, $t0
					mul	$t9, $t9, 4	  # multiply by 4 to get word offset
					add	$t9, $t9, $gp	  # add to base address
					beq 	$s4, $t8, resetBalloonColors5
					lw	$a2, ($s5)	  # load color into $a2 from array 
					sw	$a2, ($t9)	  # store color at memory location
					addi 	$t7, $t7, 1
					addi	$s5, $s5, 4       # move to the next color
					addi 	$s4, $s4, 1       # move counter of color array
					
					addi $a3, $a3, 1
					j brow5
					
					
		resetBalloonColors5:
				addi $s5, $s5, -32
				li $s4, 0
				j brow5
				
				
		prebrow6:
				li	$t3, 8
				li 	$t7, 1
				addi $a3, $a3, -2
				addi $a1, $a1, -1
				j	brow6
				
				
		brow6:
		
					beq	$t7, $t3, prebrow7
					mul	$t9, $a1, WIDTH   # y * WIDTH
					add	$t9, $t9, $a3	  # add X
					add 	$t9, $t9, $t0
					mul	$t9, $t9, 4	  # multiply by 4 to get word offset
					add	$t9, $t9, $gp	  # add to base address
					beq 	$s4, $t8, resetBalloonColors6
					lw	$a2, ($s5)	  # load color into $a2 from array 
					sw	$a2, ($t9)	  # store color at memory location
					addi 	$t7, $t7, 1
					addi	$s5, $s5, 4       # move to the next color
					addi 	$s4, $s4, 1       # move counter of color array
					
					addi $a3, $a3, -1
					j brow6
					
					
		resetBalloonColors6:
				addi $s5, $s5, -32
				li $s4, 0
				j brow6
				
				
				
		prebrow7:
				li	$t3, 6
				li 	$t7, 1
				addi $a3, $a3, 2
				addi $a1, $a1, -1
				j	brow7
				
				
		brow7:
		
					beq	$t7, $t3, resetP
					mul	$t9, $a1, WIDTH   # y * WIDTH
					add	$t9, $t9, $a3	  # add X
					add 	$t9, $t9, $t0
					mul	$t9, $t9, 4	  # multiply by 4 to get word offset
					add	$t9, $t9, $gp	  # add to base address
					beq 	$s4, $t8, resetBalloonColors7
					lw	$a2, ($s5)	  # load color into $a2 from array 
					sw	$a2, ($t9)	  # store color at memory location
					addi 	$t7, $t7, 1
					addi	$s5, $s5, 4       # move to the next color
					addi 	$s4, $s4, 1       # move counter of color array
					
					addi $a3, $a3, 1
					j brow7
					
					
		resetBalloonColors7:
				addi $s5, $s5, -32
				li $s4, 0
				j brow7

				
		
		resetP:
			addi $a3, $a3, 1
			addi $a1, $a1, 15
			j 	endLoop

	
endLoop:
	jr 	$ra
	
	
	
#erase house utilizes the same functions as draw_house
#it goes over each pixel of the house including string + balloons
#with $a2 loaded with 0, it erases the house + baloons
	
erase_house:

	li $t0, 1
	li $t1, 10
	li $t5, 4
	

rightLoop2:
	# s1 = address = $gp + 4*(x + y*width)
	li	$v0, 32
	li	$a0, 5
	syscall

	beq 	$t0, $t1, reset12
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	add 	$t9, $t9, $t0
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address 
	sw	$a2, ($t9)	  # store color at memory location
	addi 	$t0, $t0, 1
	j rightLoop2
	
reset12:
	li   $t0, 0
	li   $t1, 8
	addi $a3, $a3, 9
	j downLoop2
	
downLoop2:
	# s1 = address = $gp + 4*(x + y*width)
	li	$v0, 32
	la	$a0, 5
	syscall
	
	beq 	$t0, $t1, reset22
	add 	$t4, $a1, $t0
	mul	$t9, $t4, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	addi 	$t0, $t0, 1
	j downLoop2

reset22:
	li   $t0, 1
	li   $t1, 10
	addi $a1, $a1, 7
	j leftLoop2
	
leftLoop2:
	# s1 = address = $gp + 4*(x + y*width)
	li	$v0, 32
	la	$a0, 5
	syscall
	
	beq 	$t0, $t1, reset32
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	sub 	$t9, $t9, $t0
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	addi 	$t0, $t0, 1
	j leftLoop2
	
reset32:
	li 	$t0, 1
	li	$t1, 8
	addi 	$a3, $a3, -9
	j upLoop2
	
upLoop2:
	# s1 = address = $gp + 4*(x + y*width)
	li	$v0, 32
	la	$a0, 5
	syscall
	
	beq 	$t0, $t1, reset42
	sub 	$t6, $a1, $t0
	mul	$t9, $t6, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	addi 	$t0, $t0, 1
	j	upLoop2
	
reset42:
	subi $a1, $a1, 7
	j fillhouse2
	
fillhouse2:
	
		addi $a3, $a3, 8
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -4
		
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -2
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location


		
		addi $a3, $a3, -4
		addi $a1, $a1, -1
		j tri12
	
	
tri12:
	addi	$a1, $a1, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, -1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, -1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, 1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, 1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a3, $a3, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a3, $a3, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi	$a1, $a1, 1
	addi $a3, $a3, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, 1
	addi $a3, $a3, -1
	j 	tri22
	

tri22:
	addi	$a3, $a3, 4
	addi $a1, $a1, -2
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi 	$a1, $a1, -1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi 	$a1, $a1, -1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi 	$a1, $a1, 1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi 	$a1, $a1, 1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi 	$a1, $a1, 1
	addi $a3, $a3, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	##### FILLING IN
	

	addi $a3, $a3, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	
	addi $a3, $a3, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	

	
	addi $a3, $a3, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, -1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, 2
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, 1
	
	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a3, $a3, -1

	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, -1

	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi $a1, $a1, -1

	mul	$t9, $a1, WIDTH   # y * WIDTH
	add	$t9, $t9, $a3	  # add X
	mul	$t9, $t9, 4	  # multiply by 4 to get word offset
	add	$t9, $t9, $gp	  # add to base address
	sw	$a2, ($t9)	  # store color at memory location
	
	addi	$a3, $a3, -5
	addi $a1, $a1, 2
	j	chimney2
	
	
chimney2:


		addi 	$a3, $a3, 3
		addi 	$a1, $a1, -3
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a3, $a3, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		

		
		addi $a3, $a3, -4
		addi $a1, $a1, 3
		j	string2
		
string2:

		addi $a1, $a1, -6
		addi $a3, $a3, 4
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a1, $a1, 1
		addi $a3, $a3, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a3, $a3, -1
		addi $a1, $a1, -1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a3, $a3, 4
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		addi $a3, $a3, -1
		addi $a1, $a1, 1
		
		mul	$t9, $a1, WIDTH   # y * WIDTH
		add	$t9, $t9, $a3	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory
		
		
		addi $a3, $a3, -5
		addi $a1, $a1, 7
		j 	ballons2
		
		
		
		
ballons2:
		addi $a3, $a3, -7
		addi $a1, $a1, -9
		
		li $t7, 1
		li $t8, 8
		li $t3, 8
		li $s4, 0
		
		
		bLoop2:
					beq	$t7, $t3, preBrow22
					mul	$t9, $a1, WIDTH   # y * WIDTH
					add	$t9, $t9, $a3	  # add X
					add 	$t9, $t9, $t0
					mul	$t9, $t9, 4	  # multiply by 4 to get word offset
					add	$t9, $t9, $gp	  # add to base address
					sw	$a2, ($t9)	  # store color at memory location
					addi 	$t7, $t7, 1
					
					addi $a3, $a3, 1
					j bLoop2

		
					
		preBrow22:
					li 	$t3, 10
					li 	$t7, 1
					#addi $a3, $a3, 1
					addi $a1, $a1, -1
					j brow22
					
		brow22:
		
					beq	$t7, $t3, prebrow32
					mul	$t9, $a1, WIDTH   # y * WIDTH
					add	$t9, $t9, $a3	  # add X
					add 	$t9, $t9, $t0
					mul	$t9, $t9, 4	  # multiply by 4 to get word offset
					add	$t9, $t9, $gp	  # add to base address
					sw	$a2, ($t9)	  # store color at memory location
					addi 	$t7, $t7, 1
					
					addi $a3, $a3, -1
					j brow22
		
				
		
		prebrow32:
				li	$t3, 10
				li 	$t7, 1
				addi $a3, $a3, 1
				addi $a1, $a1, -1
				j	brow32
				
				
		brow32:
		
					beq	$t7, $t3, prebrow42
					mul	$t9, $a1, WIDTH   # y * WIDTH
					add	$t9, $t9, $a3	  # add X
					add 	$t9, $t9, $t0
					mul	$t9, $t9, 4	  # multiply by 4 to get word offset
					add	$t9, $t9, $gp	  # add to base address
					sw	$a2, ($t9)	  # store color at memory location
					addi 	$t7, $t7, 1
					
					addi $a3, $a3, 1
					j brow32

				
		
		prebrow42:
				li	$t3, 10
				li 	$t7, 1
				addi $a3, $a3, -1
				addi $a1, $a1, -1
				j	brow42
				
				
		brow42:
		
					beq	$t7, $t3, prebrow52
					mul	$t9, $a1, WIDTH   # y * WIDTH
					add	$t9, $t9, $a3	  # add X
					add 	$t9, $t9, $t0
					mul	$t9, $t9, 4	  # multiply by 4 to get word offset
					add	$t9, $t9, $gp	  # add to base address
					beq 	$s4, $t8, resetBalloonColors42
					sw	$a2, ($t9)	  # store color at memory location
					addi 	$t7, $t7, 1
					
					addi $a3, $a3, -1
					j brow42
					
					
		resetBalloonColors42:
				addi $s5, $s5, -32
				li $s4, 0
				j brow42
				
				
				
		prebrow52:
				li	$t3, 10
				li 	$t7, 1
				addi $a3, $a3, 1
				addi $a1, $a1, -1
				j	brow52
				
				
		brow52:
		
					beq	$t7, $t3, prebrow62
					mul	$t9, $a1, WIDTH   # y * WIDTH
					add	$t9, $t9, $a3	  # add X
					add 	$t9, $t9, $t0
					mul	$t9, $t9, 4	  # multiply by 4 to get word offset
					add	$t9, $t9, $gp	  # add to base address
					beq 	$s4, $t8, resetBalloonColors52
					sw	$a2, ($t9)	  # store color at memory location
					addi 	$t7, $t7, 1
					
					addi $a3, $a3, 1
					j brow52
					
					
		resetBalloonColors52:
				addi $s5, $s5, -32
				li $s4, 0
				j brow52
				
				
		prebrow62:
				li	$t3, 8
				li 	$t7, 1
				addi $a3, $a3, -2
				addi $a1, $a1, -1
				j	brow62
				
				
		brow62:
		
					beq	$t7, $t3, prebrow72
					mul	$t9, $a1, WIDTH   # y * WIDTH
					add	$t9, $t9, $a3	  # add X
					add 	$t9, $t9, $t0
					mul	$t9, $t9, 4	  # multiply by 4 to get word offset
					add	$t9, $t9, $gp	  # add to base address
					beq 	$s4, $t8, resetBalloonColors62
					sw	$a2, ($t9)	  # store color at memory location
					addi 	$t7, $t7, 1
					
					addi $a3, $a3, -1
					j brow62
					
					
		resetBalloonColors62:
				addi $s5, $s5, -32
				li $s4, 0
				j brow62
				
				
				
		prebrow72:
				li	$t3, 6
				li 	$t7, 1
				addi $a3, $a3, 2
				addi $a1, $a1, -1
				j	brow72
				
				
		brow72:
		
					beq	$t7, $t3, resetP2
					mul	$t9, $a1, WIDTH   # y * WIDTH
					add	$t9, $t9, $a3	  # add X
					add 	$t9, $t9, $t0
					mul	$t9, $t9, 4	  # multiply by 4 to get word offset
					add	$t9, $t9, $gp	  # add to base address
					beq 	$s4, $t8, resetBalloonColors72
					sw	$a2, ($t9)	  # store color at memory location
					addi 	$t7, $t7, 1
					
					addi $a3, $a3, 1
					j brow72
					
					
		resetBalloonColors72:
				addi $s5, $s5, -32
				li $s4, 0
				j brow72

				
		
		resetP2:
			addi $a3, $a3, 1
			addi $a1, $a1, 15
			j 	endLoop2

	
endLoop2:
	jr 	$ra
	
	
	
	
############## SONG CODE #################

#married life from UP plays when house is on Paradise Falls
#implemented by playing each note from the song
#where each note is a function that's called
# instrument: piano

#multiple notes are played at times to play a chord, done using syscall 31
#rest of the notes utilize syscall 33


married_life:
		addi		$sp, $sp, -12
		sw		$ra, 8($sp)


		li		$t0, 600
		jal		F
		
		li		$t0, 500
		jal		A
		
		li		$t0, 500
		jal		F
		
		li		$t0, 1000
		jal		EC
		
		li		$t0, 1000
		jal		FC
		
		
		li 		$v0, 32
		la		$a0, 1000
		syscall
		
		

		li		$t0, 500
		jal		F
		
		li		$t0, 500
		jal		A
		
		li		$t0, 500
		jal		F
		
		li		$t0, 1000
		jal		DC
		
		li		$t0, 1000
		jal		FC
		
		
		li 		$v0, 32
		la		$a0, 1000
		syscall
		
		
		
		
		li		$t0, 550
		jal		D
		
		li		$t0, 500
		jal		F
		
		li		$t0, 500
		jal		D
		
		li		$t0, 1000
		jal		CC
		
		li		$t0, 1000
		jal		CC
		
		li		$t0, 1000
		jal		CC
		
		li		$t0, 1000
		jal		CC
		
		
		li 		$v0, 32
		la		$a0, 1000
		syscall		
		
		
		
		
		
		li		$t0, 500
		jal		D
		
		li		$t0, 300
		jal		A
		
		li		$t0, 500
		jal		G
		
		li		$t0, 500
		jal		D
		
		li		$t0, 300
		jal		A
		
		li		$t0, 500
		jal		G
		
		li		$t0, 450
		jal		F
	
		li		$t0, 1000
		jal		DC
		
		li		$t0, 1000
		jal		GC
		
		li 		$v0, 32
		la		$a0, 1000
		syscall
		
		
		
		
		li		$t0, 300
		jal		F
		
		li		$t0, 300
		jal		G
	
		li		$t0, 300
		jal		F

		li		$t0, 1000
		jal		EC
		
		li		$t0, 1000
		jal		CC
		
		li		$v0, 32
		la		$a0, 1000
		syscall
		
		
				
				
		li		$t0, 400
		jal		E
		
		li		$t0, 300
		jal		G
	 
		li		$t0, 300
		jal		E

		li		$t0, 1000
		jal		CC
		
		li		$t0, 1000
		jal		CC
		
		li		$t0, 1000
		jal		CC
		
		li		$t0, 1000
		jal		CC
		
		li		$v0, 32
		la		$a0, 1000
		syscall
		
		
		
		
		
		li		$t0, 300
		jal		C
		
		li		$t0, 300
		jal		E
	
		li		$t0, 300
		jal		C

		li		$t0, 800
		jal		Bf
		
		li		$t0, 300
		jal		Bf
	
		li		$t0, 300
		jal		C

		li		$t0, 300
		jal		B
		
		
		
		
		
		
		
		li		$t0, 500
		jal		A
		
		li		$t0, 500
		jal		Bf
	
		li		$t0, 500
		jal		C

		li		$t0, 300
		jal		D
		
		li		$t0, 300
		jal		E
	
		li		$t0, 500
		jal		C

		li		$t0, 500
		jal		D
		
		li		$t0, 1000
		jal		E
		
		lw		$ra, 8($sp)
		addi		$sp, $sp, 12
		
		
		jr		$ra
		
		
		
		
		
####################

######### SYSTEM CALL 33
F:
		li 	$v0, 33
		la 	$a0, 65
		la	$a1, ($t0)
		la	$a2, 7
		la	$a3, 127
		syscall
		
		jr	$ra
		
A:
		li 	$v0, 33
		la 	$a0, 69
		la	$a1, ($t0)
		la	$a2, 7
		la	$a3, 127
		syscall
		
		jr	$ra
		
E:
		li 	$v0, 33
		la 	$a0, 64
		la	$a1, ($t0)
		la	$a2, 7
		la	$a3, 127
		syscall
		
		jr	$ra
		
D:

		li 	$v0, 33
		la 	$a0, 62
		la	$a1, ($t0)
		la	$a2, 7
		la	$a3, 127
		syscall
		
		jr	$ra
		
		
C:

		li 	$v0, 33
		la 	$a0, 72
		la	$a1, ($t0)
		la	$a2, 7
		la	$a3, 127
		syscall
		
		jr	$ra
		
G:

		li 	$v0, 33
		la 	$a0, 67
		la	$a1, ($t0)
		la	$a2, 7
		la	$a3, 127
		syscall
		
		jr	$ra
		
		
Bf:

		li 	$v0, 33
		la 	$a0, 70
		la	$a1, ($t0)
		la	$a2, 7
		la	$a3, 127
		syscall
		
		jr	$ra
		
		
B:

		li 	$v0, 33
		la 	$a0, 71
		la	$a1, ($t0)
		la	$a2, 7
		la	$a3, 127
		syscall
		
		jr	$ra
		
		
		


######## SYSTEM CALL 31
#Use this instead of syscall 33 to play multiple notes at once

FC:
		li 	$v0, 31
		la 	$a0, 65
		la	$a1, ($t0)
		la	$a2, 7
		la	$a3, 127
		syscall
		
		jr	$ra
		
EC:
		li 	$v0, 31
		la 	$a0, 64
		la	$a1, ($t0)
		la	$a2, 7
		la	$a3, 127
		syscall
		
		jr	$ra
		
		
AC:
		li 	$v0, 31
		la 	$a0, 69
		la	$a1, ($t0)
		la	$a2, 7
		la	$a3, 127
		syscall
		
		jr	$ra

CC:

		li 	$v0, 31
		la 	$a0, 72
		la	$a1, ($t0)
		la	$a2, 7
		la	$a3, 127
		syscall
		
		jr	$ra
		
		
DC:

		li 	$v0, 31
		la 	$a0, 62
		la	$a1, ($t0)
		la	$a2, 7
		la	$a3, 127
		syscall
		
		jr	$ra
		
		
GC:

		li 	$v0, 31
		la 	$a0, 67
		la	$a1, ($t0)
		la	$a2, 7
		la	$a3, 127
		syscall
		
		jr	$ra
		
		
		
		
		
######## CLIFF GENERATOR ########

#draws a cliff that's randomly placed each time program is run
#always to the left of the house
#always short enough that house can sit on cliff and be visible

#done by generating random numbers between specified range 
#then adding to x and y values

cliff:

# WIDTH -39 through -2
# HEIGHT -320 through -290


		li $a1, 39
		li $v0, 42
		syscall
		
		addi $a0, $a0, 2
		sub	$a0, $0, $a0
		move $t0, $a0
		li $a0, 0
		
		li $a1, 30
		li $v0, 42
		syscall
		
		addi $a0, $a0, 290
		sub $a0, $0, $a0
		move $t1, $a0

		addi $s7, $0, WIDTH
		add	$s7, $s7, $t0
		addi	$s2, $0, HEIGHT
		add $s2, $s2, $t1
		
		addi $a2, $0, GREY
		
		li $t0, 0
		li $t1, 15
		
#next loops draw the cliff at random spots within range inside the bitmap
		
	cliffLoop:
		
		beq 	$t0, $t1, preCliffSideR
		mul	$t9, $s7, WIDTH   # y * WIDTH
		add	$t9, $t9, $s2	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		addi	$t0, $t0, 1
		addi $s2, $s2, 1
		j 	cliffLoop
		
	preCliffSideR:
		
		li $t0, 0
		li $t1, 256
		j	cliffSideR
		
		
	cliffSideR:
	
		beq 	$t0, $t1, preCliffSideL
		mul	$t9, $s7, WIDTH   # y * WIDTH
		add	$t9, $t9, $s2	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		addi	$t0, $t0, 1
		addi $s7, $s7, 1
		j 	cliffSideR
		
	preCliffSideL:
	
		addi $s2, $s2, -15
		li $t0 0
		li $t1, 256
		j	cliffSideL
		
	cliffSideL:
		
		beq 	$t0, $t1, exitCliff
		mul	$t9, $s7, WIDTH   # y * WIDTH
		add	$t9, $t9, $s2	  # add X
		mul	$t9, $t9, 4	  # multiply by 4 to get word offset
		add	$t9, $t9, $gp	  # add to base address
		sw	$a2, ($t9)	  # store color at memory location
		addi	$t0, $t0, 1
		addi $s7, $s7, -1
		j 	cliffSideL
		
	exitCliff:
		addi $a2, $0, DBROWN
		jr 	$ra
