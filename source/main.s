@ Code section
.section .text

.global main

/*
main:
	loop:
	bl		GraphicsInit
	bl		IndexArray
	ldr		r0, =screenArray
	bl		DrawGrid
*/


main:
	bl		GraphicsInit	// initialize graphics
	bl		IndexArray
	bl		InitializeSNES	// initialize controls
	bl		StartMenu
	
	mov		r4, #0			// 0 if ball not released, 1 if ball is released
	
	mov		r0, #4
	bl		SetPaddleSpeed
	
	gameLoop:
		ldr		r0, =screenArray 
		bl		DrawGrid
		bl 		DrawPaddle
		bl  	snesDriver			// take input
		mov		r5, r0
		
		cmp		r4, #1				// only takes B if ball is in place
		bleq	MoveBall
		beq		skipB
		mov		r0, r5
		bl		CheckB
		cmp		r0, #0
		moveq	r4, #1
		
	skipB:
		mov		r0, r5
		bl		CheckA
		cmp		r0, #0
		moveq	r0, #8
		movne	r0, #4
		bl		SetPaddleSpeed
	
		mov		r0, r5
		bl		CheckLeft
		cmp		r0, #0
		bleq	MovePaddleLeft
		
		mov		r0, r5
		bl		CheckRight
		cmp		r0, #0
		bleq	MovePaddleRight
		
		bl		IndexBall
	
		b gameLoop

	@ stop
	haltLoop$:
		b	haltLoop$
		
@ ceiling pattern
@ indexes the ceiling of the array
CeilingPattern:
	push	{r4, r5, r6, lr}
			
	ldr		r0, =screenArray
	ldr		r1, =CEILINGLABELS
	ldrh	r2, [r1]		// loads leftedge label
	strh	r2, [r0], #2
	
	ceilingLoop:
		ldr		r1, =CEILINGLABELS
		mov		r4, #0  	// i index
		ceilingExtend:
			ldrh	r2, [r1, #4]	// loads extend label
			strh	r2, [r0], #2
		
			add		r4, #1
		ceilingExtendTest:
			cmp		r4, #3
			blt		ceilingExtend
		
		mov		r4, #0
		ldr		r1, =CEILINGLABELS
		add		r1, #6
		ceilingSpecial:
			ldrh	r2, [r1], #2	// loads ceiling specials in order
			strh	r2, [r0], #2
		
			add		r4, #1
		ceilingSpecialTest:
			cmp		r4, #5
			blt		ceilingSpecial
			
		ldr		r1, =CEILINGLABELS
		mov		r4, #0  	// i index
		ceilingExtend2:
			ldrh	r2, [r1, #4]	// loads extend label
			strh	r2, [r0], #2
		
			add		r4, #1
		ceilingExtendTest2:
			cmp		r4, #3
			blt		ceilingExtend2
			
		add		r5, #1
	ceilingLoopTest:
		cmp		r5, #2
		blt		ceilingLoop
		
	ldr		r1, =CEILINGLABELS
	ldrh	r2, [r1, #2]		// loads right edge label
	strh	r2, [r0]
	
	pop		{r4, r5, r6, lr}
	bx 		lr

@ indexes the wall on screen array
@ r0 = starting row
@ r1 = column offset
@ returns nothing
WallPattern:
	push	{r4, r5, r6, r7, lr}
	
	ldr		r2, =GRIDDIMENSION
	ldr		r4, [r2, #4]	//	column value
	mul		r5, r0, r4		// row offset
	add		r5, r1			// row + column offset
	//mov		r6, #0			// i index
	
	mov		r7, #0
	wallLoop:
		// stores wall extend
		ldr		r1, =screenArray
		ldr		r2, =WALLLABELS
		
		ldrh	r3, [r2], #2		//loads extend
		lsl		r8, r5, #1
		strh	r3, [r1, r8]		//screenArray + offset 
		add		r5, r4				// move down a row
		
		// stores wall specials
		mov		r6, #0
		//ldr		r2, =WALLLABELS
		innerWallLoop:
			ldrh	r3, [r2], #2		// loads special labels in order
			lsl		r8, r5, #1
			strh	r3, [r1, r8]
			add		r5, r4				// move down a row
			
			add		r6, #1
		innerWallLoopTest:
			cmp		r6, #5
			blt		innerWallLoop
		
		// stores final wall extend
		ldr		r1, =screenArray
		ldr		r2, =WALLLABELS
		ldrh	r3, [r2]		//loads extend
		lsl		r8, r5, #1		
		strh	r3, [r1, r8]	//screenArray + offset
		add		r5, r4			// move down a row
		
		add		r7, #1 
	wallLoopTest:
		cmp		r7, #4
		blt		wallLoop
		
	pop		{r4, r5, r6, r7, lr}
	bx		lr
	
@ indexes the screenArray with backgroundlabels
@ r0 - starting row
@ r1 - column offset
@ returns nothing
BackgroundPattern:
	push	{r4, r5, r6, r7, r9, lr}
	
	mov		r4, #0	// i index
	mov		r5, #0	// j index
	ldr		r2, =GRIDDIMENSION
	ldr		r9, [r2, #4]		// column value
	//		initial array index
	mul		r6, r0, r9			// row * column value
	add		r6, r1				// add column offset
	
	mov		r4, #0
	backgroundLoop:
		
		mov		r5, #0	// j index
		mov		r7, r6		// r7 = r6 copy
		innerBackgroundLoop:
			ldr		r0, =BACKGROUNDLABELS
			ldrh	r1, [r0], #2	//loads label 0
			ldr		r2, =screenArray
			lsl		r3, r7, #1		
			strh	r1, [r2, r3]
			
			add		r3, r7, #1			// move array index one cell right
			lsl		r3, #1			
			ldrh	r1, [r0], #2	//loads label 1
			strh	r1, [r2, r3]
			
			add		r7, r9			//move down a row
			ldrh	r1, [r0], #2	//loads label 2
			lsl		r3, r7, #1
			strh	r1, [r2, r3]
			
			add		r3, r7, #1			// move array index one cell right
			lsl		r3, #1
			ldrh	r1, [r0], #2		// loads label 3
			strh	r1, [r2, r3]
			
			add	r7, r9		// move down a row if its available
					
			add		r5, #1 
		innerBackgroundTest:
			cmp		r5, #14
			blt		innerBackgroundLoop
		
		add		r6, #2		// move to the next column
		add		r4, #1
	backgroundLoopTest:
		cmp		r4, #11
		blt		backgroundLoop
	
	pop		{r4, r5, r6, r7, r9, lr}
	bx 		lr

@ index the blocks according to the given label
@ r0 - brick label L
@ r1 - brick label R
@ r2 - starting row
@ r3 - starting column
@ returns nothing
BrickPattern:
	push	{r4, r5, r6, r7, lr}
	
	ldr		r4, =GRIDDIMENSION
	ldr		r4, [r4, #4]	// width
	mul		r4, r2, r4		// row offset
	add		r4, r4, r3		// row offset + column offset
	
	mov		r5, r0			// brick label L
	mov		r6, r1			// brick label R
	
	mov		r7, #0
	brickLoop2:
		ldr		r1, =screenArray
		lsl		r2, r4, #1
		strh	r5, [r1, r2]	//stores brick label L
		add		r4, #1
		
		lsl		r2, r4, #1
		strh	r6, [r1, r2]	// stores brick label R
		add		r4, #1
		
		add 	r7, #1
	brickLoopTest:
		cmp		r7, #11
		blt		brickLoop2
	
	pop		{r4, r5, r6, r7, lr}
	bx 		lr
	
@ indexes the screen arrays using the created patterns
IndexArray:
	push	{lr}
	
	bl		CeilingPattern
	
	// left wall pattern
	mov		r0, #1
	mov		r1, #0
	bl		WallPattern		
	//right wall pattern
	mov		r0, #1
	mov		r1, #23
	bl		WallPattern
	
	// indexes the background
	mov		r0, #1
	mov		r1, #1
	bl		BackgroundPattern
	
	
	// indexes green bricks
	ldr		r0, =BRICKLABELS
	ldrh	r1, [r0, #2]		// label: green brick R
	ldrh	r0, [r0]			// label: green brick L
	mov		r2,	#10				// initial row
	mov		r3, #1				// initial column
	bl		BrickPattern
	
	// indexes pink bricks
	ldr		r0, =BRICKLABELS
	ldrh	r1, [r0, #6]		// label: pink brick R
	ldrh	r0, [r0, #4]		// label: pink brick L
	mov		r2,	#9				// initial row
	mov		r3, #1				// initial column
	bl		BrickPattern
	
	// indexes orange bricks
	ldr		r0, =BRICKLABELS
	ldrh	r1, [r0, #10]		// label: orange brick R
	ldrh	r0, [r0, #8]		// label: orange brick L
	mov		r2,	#8				// initial row
	mov		r3, #1				// initial column
	bl		BrickPattern
	
	// indexes blue bricks
	ldr		r0, =BRICKLABELS
	ldrh	r1, [r0, #14]		// label: blue brick R
	ldrh	r0, [r0, #12]			// label: blue brick L
	mov		r2,	#7				// initial row
	mov		r3, #1				// initial column
	bl		BrickPattern
	
	// indexes red bricks
	ldr		r0, =BRICKLABELS
	ldrh	r1, [r0, #18]		// label: red brick R
	ldrh	r0, [r0, #16]		// label: red brick L
	mov		r2,	#6				// initial row
	mov		r3, #1				// initial column
	bl		BrickPattern
	
	// indexes gray bricks
	ldr		r0, =BRICKLABELS
	ldrh	r1, [r0, #22]		// label: gray brick R
	ldrh	r0, [r0, #20]		// label: gray brick L
	mov		r2,	#10				// initial row
	mov		r3, #1				// initial column
	bl		BrickPattern
	
	pop		{lr}
	bx 		lr

@ Data section
.section .data

//29 x 24
.global screenArray
screenArray:
.rept	696
.hword	0
.endr
