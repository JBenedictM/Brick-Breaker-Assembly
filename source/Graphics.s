@ Code section
.section .text

// indexes the board with the proper components

.global GraphicsInit
GraphicsInit:
	push	{lr}
	
	@ ask for frame buffer information
	ldr 		r0, =frameBufferInfo 	@ frame buffer information structure
	bl			initFbInfo
	
	bl InitVars
	/*
	@ initialize screenArray
	bl	IndexCeil

	mov	r0, #4
	mov r1, #14
	bl	IndexBrickRow
	mov	r0, #5
	mov r1, #14
	bl	IndexBrickRow
	
	mov	r0, #6
	mov r1, #10
	bl	IndexBrickRow
	mov	r0, #7
	mov r1, #10
	bl	IndexBrickRow
		
	mov	r0, #8
	mov r1, #6
	bl	IndexBrickRow
	mov	r0, #9
	mov r1, #6
	bl	IndexBrickRow
	
	mov	r0, #0
	bl	IndexWall
	mov	r0, #21
	bl	IndexWall
	*/
	//bl	DrawPaddle
	//bl	IndexBall
	
	pop		{lr}
	mov		pc, lr
	
		
//Initialize Variables
InitVars:
	push	{r4, r5, r6, r7, r8, lr}
		
	ldr		r0, =INITIALPOINT
	ldr		r1, =GRIDDIMENSION
	ldr		r2, =wallBoundaries
	ldr		r3, =PADDLEDIMENSION
	
	ldr		r4, [r0]
	add		r4, #31
	str		r4, [r2]
	
	ldr		r4, [r1, #4]
	ldr		r5, [r0]
	ldr		r6, [r3]
	
	sub		r4, #1
	lsl		r4, #5
	add		r4, r5
	sub		r4, #21
	//sub		r4, r6
	str		r4, [r2, #4]
	
	ldr		r1, =paddlePos
	
	ldr		r4, [r0]
	mov		r5, #9
	lsl		r5, #5
	add		r5, r4
	str		r5, [r1]
	
	ldr		r4, [r0, #4]
	mov		r5, #25
	lsl		r5, #5
	add		r5, r4
	str		r5, [r1, #4]	
	
	pop		{r4, r5, r6, r7, r8, lr}
	mov		pc, lr
	
@ IndexCeil "Derived from IndexWalls"
IndexCeil:
	push	{r4, r5, r6, r7, r8, r9, lr}
		
	ldr		r9, =GRIDDIMENSION
	ldr		r9, [r9, #4]		// width
	mov		r5, #0		// column index
	indexUpperWalls:
		ldr		r0, =screenArray
		ldr 	r1, =CELLTYPES
		ldrh 	r2, [r1, #2]
		lsl		r3, r5, #1
		strh	r2, [r0, r3]
		
		add		r5, #1
		cmp		r5, r9
		blt		indexUpperWalls 
		
	pop		{r4, r5, r6, r7, r8, r9, lr}
	mov		pc,	lr

@ IndexBrickRow "Derived from IndexWalls"
IndexBrickRow:
	push	{r4, r5, r6, r7, r8, r9, lr}
	
		ldr		r9, =GRIDDIMENSION
		ldr		r9, [r9, #4]		// width	
		mov		r4, r0		// row index
		mov		r5, #1		// column index
		add		r6, r1, #2		
	indexBrick:
		ldr		r8, =CELLTYPES
		tst		r5,	#1
		ldrneh	r2, [r8, r1]
		ldreqh	r2, [r8, r6]
		mul		r3, r4, r9 		// row * width
		add		r3, r5			// row * width + offset
		lsl 	r3, #1			// each element is halfword
		ldr		r7, =screenArray
		strh	r2, [r7, r3]
		
		add		r5, #1
		cmp		r5, #21
		blt		indexBrick 
		
	pop		{r4, r5, r6, r7, r8, r9, lr}
	mov		pc,	lr
	
@ IndexWall "Derived from IndexWalls"
IndexWall:
	push	{r4, r5, r6, r7, r8, r9, lr}
	
	ldr		r8, =GRIDDIMENSION
	ldr		r9, [r8, #4]		// width	
	mov		r4, #1		// row index
	mov		r5, r0		// get column dimension
	indexRightSideWalls:
		ldr		r1, =CELLTYPES
		ldrh	r2, [r1]
		mul		r3, r4, r9 		// row * width
		add		r3, r5			// row * width + offset
		lsl 	r3, #1			// each element is halfword
		ldr		r7, =screenArray
		strh	r2, [r7, r3]
		
		add		r4, #1
		ldr		r8, =GRIDDIMENSION
		ldr		r8, [r8]
		cmp		r4, r8
		blt		indexRightSideWalls
		
	pop		{r4, r5, r6, r7, r8, r9, lr}
	mov		pc,	lr

@ Draw Cell Grid
@ depends on the constant rows and columns
@ r0 - address of screen array
.global DrawGrid
DrawGrid:
	push	{r4, r5, r6, r7, r8, r9, r10, lr}
	mov		r4, #0		@ row index
	mov		r5, #0		@ column index
	mov		r10, r0
	
	ldr		r0, =GRIDDIMENSION
	ldr		r6, [r0]			@ rows
	ldr		r7, [r0, #4]		@ columns
	
	drawRow:
		mov		r5, #0
		drawColumn:
			// get cell texture
			ldr		r2, =GRIDDIMENSION
			ldr		r8, [r2, #4]	// width
			
			mul		r9, r4, r8		// rows * width
			add		r9, r5			// (rows * width) + offset
			lsl		r9, #1			// each index is a half word
			ldrh	r9, [r10, r9]	// label
			
			mov		r0, r9		
			bl		LabelToTexture
			mov		r2, r0
			
			ldr		r0, =INITIALPOINT
			ldr		r8, [r0]		// initial x
			ldr		r9, [r0, #4]	// initial y
			
			// initial x of cell
			rsb		r1, r5, r5, lsl #5	// column * 31
			add		r0, r1, r8			// column * 31 + initial x
			// initial y of cell
			lsl		r1, r4, #5		// row * 32
			add		r1, r9			// row * 32 + initial y
			
			
			/*
			ldr		r3, =CELLTYPES
			ldrh	r3, [r3] //WW
			cmp		r9, r3
			ldreq	r2, =0x808080
			
			beq		colourAssigned
			
			ldr		r3, =CELLTYPES
			ldrh	r3, [r3, #2] //CC
			cmp		r9, r3
			ldreq	r2, =0x808080
			
			beq		colourAssigned

			ldr		r3, =CELLTYPES
			ldrh	r3, [r3, #6] //1L
			cmp		r9, r3
			ldreq	r2, =0x00FF00
	
			beq		colourAssigned
	
			ldr		r3, =CELLTYPES
			ldrh	r3, [r3, #8] //1R
			cmp		r9, r3
			ldreq	r2, =0x005500
					
			beq		colourAssigned

			ldr		r3, =CELLTYPES
			ldrh	r3, [r3, #10] //2L
			cmp		r9, r3
			ldreq	r2, =0xFFFF00
	
			beq		colourAssigned
	
			ldr		r3, =CELLTYPES
			ldrh	r3, [r3, #12] //2R
			cmp		r9, r3
			ldreq	r2, =0x555500
					
			beq		colourAssigned
							
			ldr		r3, =CELLTYPES
			ldrh	r3, [r3, #14] //3L
			cmp		r9, r3
			ldreq	r2, =0xFF0000
	
			beq		colourAssigned
	
			ldr		r3, =CELLTYPES
			ldrh	r3, [r3, #16] //3R
			cmp		r9, r3
			ldreq	r2, =0x550000
					
			beq		colourAssigned
			
			ldr		r3, =PADDLETYPES
			ldrh	r3, [r3] //"LL"
			cmp		r9, r3
			ldreq	r2, =0xFFFFFF
					
			beq		colourAssigned
			
			ldr		r3, =PADDLETYPES
			ldrh	r3, [r3, #2] //"MM"
			cmp		r9, r3
			ldreq	r2, =0x0000FF
					
			beq		colourAssigned
			
			ldr		r3, =PADDLETYPES
			ldrh	r3, [r3, #4] //"RR"
			cmp		r9, r3
			ldreq	r2, =0xFFFFFF
					
			beq		colourAssigned
	
			ldr		r3, =MENUTYPES
			ldrh	r3, [r3] //"SR"
			cmp		r9, r3
			ldreq	r2, =0x00FF00
					
			beq		colourAssigned
		
			ldr		r3, =MENUTYPES
			ldrh	r3, [r3, #2] //"QQ"
			cmp		r9, r3
			ldreq	r2, =0xFF0000
					
			beq		colourAssigned

			ldr		r3, =MENUTYPES
			ldrh	r3, [r3, #4] //"SL"
			cmp		r9, r3
			ldreq	r2, =0x0000FF
					
			beq		colourAssigned			

			mov	r2, #0x000000	
			*/

colourAssigned:
		
			bl		DrawCell2
			
			add		r5, #1
			cmp		r5,	r7		// column index < column
			blt		drawColumn
		
		add		r4, #1
		cmp		r4, r6		// row index < row
		blt		drawRow
	
	pop		{r4, r5, r6, r7, r8, r9, r10, lr}
	mov		pc,	lr
	
@ Draw a cell 
@ r0 - initial x
@ r1 - initial y
@ r2 - texture address
@ returns nothing
.global DrawCell
DrawCell:
	push	{r4, r5, r6, r7, r8, r9, lr}
	
	mov		r4, r0		@ x
	mov		r5, r1		@ y
	mov		r6, #0		@ i index
	mov		r7, #0		@ j index
	//mov		r8, r2		// texture address
	
	drawY:
		mov		r7, #0
		drawX:
			add		r0, r4, r7		// x + j index
			add		r1, r5, r6		// y + i index
			//ldr		r2, [r8], #4	//pixel color
			
			bl		DrawPixel
			
			add		r7, #1
			ldr		r3, =CELLDIMENSION	// get cell dimension for x
			ldr		r3, [r3]
			cmp		r7, r3		// j index < x dimension
			blt		drawX
			
		add		r6, #1
		ldr		r3, =CELLDIMENSION
		ldr		r3, [r3, #4]	//get cell dimension for y
		cmp		r6, r3		// i index < y dimension
		blt		drawY
	
	pop		{r4, r5, r6, r7, r8, r9, lr}
	mov		pc,	lr
	
@ Draw a cell 
@ r0 - initial x
@ r1 - initial y
@ r2 - texture address
@ returns nothing
.global DrawCell
DrawCell2:
	push	{r4, r5, r6, r7, r8, r9, lr}
	
	mov		r4, r0		@ x
	mov		r5, r1		@ y
	mov		r6, #0		@ i index
	mov		r7, #0		@ j index
	mov		r8, r2		// texture address
	
	drawY2:
		mov		r7, #0
		drawX2:
			add		r0, r4, r7		// x + j index
			add		r1, r5, r6		// y + i index
			ldr		r2, [r8], #4	//pixel color
			
			bl		DrawPixel
			
			add		r7, #1
			ldr		r3, =CELLDIMENSION	// get cell dimension for x
			ldr		r3, [r3]
			cmp		r7, r3		// j index < x dimension
			blt		drawX2
			
		add		r6, #1
		ldr		r3, =CELLDIMENSION
		ldr		r3, [r3, #4]	//get cell dimension for y
		cmp		r6, r3		// i index < y dimension
		blt		drawY2
	
	pop		{r4, r5, r6, r7, r8, r9, lr}
	mov		pc,	lr

//PADDLE DRAWING
.global DrawPaddle
DrawPaddle:
	push	{r4, r5, r6, r7, r8, lr}
	ldr		r4, =GRIDDIMENSION
	ldr		r5, [r4, #4]		// width	
	mov		r6, #25		// row index
	mov		r7, #9		// left side column index
	
	ldr		r8, =paddlePos
	ldr		r4, [r8]		@ x
	ldr		r5, [r8, #4]	@ y
	mov		r6, #0		@ i index
	mov		r7, #0		@ j index
	
	drawPaddleY:
		mov		r7, #0
		drawPaddleX:
			add		r0, r4, r7		// x + j index
			add		r1, r5, r6		// y + i index
			
			ldr		r2, =0xFFFFFF
			bl		DrawPixel
			
			add		r7, #1
			ldr		r3, =PADDLEDIMENSION	// get cell dimension for x
			ldr		r3, [r3]
			cmp		r7, r3		// j index < x dimension
			blt		drawPaddleX
			
		add		r6, #1
		ldr		r3, =PADDLEDIMENSION
		ldr		r3, [r3, #4]	//get cell dimension for y
		cmp		r6, r3		// i index < y dimension
		blt		drawPaddleY
		
	pop		{r4, r5, r6, r7, r8, lr}
	mov		pc, lr

//BALL DRAWING
.global IndexBall
IndexBall:
	push	{r4, r5, r6, r7, r8, lr}
	ldr		r4, =GRIDDIMENSION
	ldr		r5, [r4, #4]		// width	
	mov		r6, #25		// row index
	mov		r7, #9		// get column dimension
	
	ldr		r8, =ballPos
	ldr		r4, [r8]		@ x
	ldr		r5, [r8, #4]	@ y
	mov		r6, #0		@ i index
	mov		r7, #0		@ j index
	
	drawBallY:
		mov		r7, #0
		drawBallX:
			add		r0, r4, r7		// x + j index
			add		r1, r5, r6		// y + i index
			
			ldr		r2, =0x00FFFF
			bl		DrawPixel
			
			add		r7, #1
			ldr		r3, =BALLDIMENSION	// get cell dimension for x
			ldr		r3, [r3]
			cmp		r7, r3		// j index < x dimension
			blt		drawBallX
			
		add		r6, #1
		ldr		r3, =BALLDIMENSION
		ldr		r3, [r3]	//get cell dimension for y
		cmp		r6, r3		// i index < y dimension
		blt		drawBallY
		
	pop		{r4, r5, r6, r7, r8, lr}
	mov		pc, lr

@ Draw Pixel
@  r0 - x
@  r1 - y
@  r2 - colour
DrawPixel:
	push		{r4, r5}

	offset		.req	r4

	ldr		r5, =frameBufferInfo	

	@ offset = (y * width) + x
	
	ldr		r3, [r5, #4]		@ r3 = width
	mul		r1, r3
	add		offset,	r0, r1
	
	@ offset *= 4 (32 bits per pixel/8 = 4 bytes per pixel)
	lsl		offset, #2

	@ store the colour (word) at frame buffer pointer + offset
	ldr		r0, [r5]		@ r0 = frame buffer pointer
	str		r2, [r0, offset]

	pop		{r4, r5}
	bx		lr

	
	
	

@ returns the corresponding texture address of a label	
@ r0 - label
@ returns in r0: texture address
LabelToTexture:
	push	{r4, lr}
	/*
	//	removes the second ascii character
	mov		r4, #0b11111111
	lsl		r4, #8
	bic		r4, r0
	
	// compares the first ascii character
	ldr		r1, =BACKGROUNDLABELS
	ldrb	r1, [r1]		// loads 'B'
	cmp		r1, r4
	beq		backgroundFind
	
	ldr		r1, =WALLLABELS
	ldrb	r1, [r1]		// loads 'W'
	cmp		r1, r4
	beq		wallFind
	
	ldr		r1, =CEILINGLABELS	
	ldrb	r1, [r1]		// loads 'C'
	cmp		r1, r4
	beq		ceilingFind
	
	ldr		r1, =PADDLELABELS
	ldrb	r1, [r1]
	cmp		r1, r4
	beq		paddleFind
	// else
	b		brickFind
	*/
	
	backgroundFind:
	ldr		r1, =BACKGROUNDLABELS
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =backGround0
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =backGround1
	beq		endLabelToTexture

	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =backGround2
	beq		endLabelToTexture

	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =backGround3
	beq		endLabelToTexture
	
	wallFind:
	ldr		r1, =WALLLABELS
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =wallExtend
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =wallSpecial0
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =wallSpecial1
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =wallSpecial2
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =wallSpecial3
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =wallSpecial4
	beq		endLabelToTexture
	
	ceilingFind:
	ldr		r1, =CEILINGLABELS
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =ceilingLeftEdge
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =ceilingRightEdge
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =ceilingExtend
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =ceilingSpecial0
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =ceilingSpecial1
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =ceilingSpecial2
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =ceilingSpecial3
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =ceilingSpecial4
	beq		endLabelToTexture
	
	brickFind:
	ldr		r1, =BRICKLABELS
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =greenBrickL
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =greenBrickR
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =pinkBrickL
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =pinkBrickR
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =orangeBrickL
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =orangeBrickR
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =blueBrickL
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =blueBrickR
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =redBrickL
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =redBrickR
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =grayBrickL
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =grayBrickR
	beq		endLabelToTexture
	
	paddleFind:
	ldr		r1, =PADDLELABELS
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =paddleL
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =paddleM
	beq		endLabelToTexture
	
	ldrh	r2, [r1], #2
	cmp		r2, r0
	ldreq	r0, =paddleR
	beq		endLabelToTexture
	
	//	no texture found for label
	//	loads a generic black texture
	ldr		r0, =blackCell
	
	endLabelToTexture:
	pop		{r4, lr}
	bx		lr

@ Data section
.section .data

.global INITIALPOINT
INITIALPOINT:
	.int	10, 10		// initial x and y
CELLDIMENSION:
	.int	32, 32		// 32x32 pixels
.global GRIDDIMENSION
GRIDDIMENSION:	
	.int	29, 24		// 28 rows x 22 columns
.global PADDLEDIMENSION
PADDLEDIMENSION:	// subject to change
	.int	128, 24		// 128x24 pixels
.global BALLDIMENSION
BALLDIMENSION:	
	.int	16

.global CELLTYPES
CELLTYPES:
.ascii	"WW","CC","00","1L","1R","2L","2R","3L","3R"
.global BACKGROUNDLABELS
BACKGROUNDLABELS:
.ascii	"B0", "B1", "B2", "B3"

.global WALLLABELS
WALLLABELS:
.ascii	"WE", "W0", "W1", "W2", "W3", "W4"		// wall labels

.global CEILINGLABELS
CEILINGLABELS:
.ascii	"CL", "CR", "CE", "C0", "C1", "C2", "C3", "C4"		// ceiling labels

.global PADDLELABELS
PADDLELABELS:
.ascii 	"PL", "PM", "PR"		// paddle labels

.global BRICKLABELS
BRICKLABELS:
.ascii	"1L", "1R", "2L", "2R", "3L", "3R", "4L", "4R", "5L", "5R", "6L", "6R"


.global MENUTYPES
.align 
MENUTYPES:
.ascii	"ST", "QQ", "SL" 

PADDLETYPES:
.ascii	"LL", "MM", "RR"

//28 * 22
screenArrayDup:
.rept	616
.hword	0
.endr

.global startMenArray
startMenArray:
.rept	696
.hword	0
.endr

.global EmptyScreen
EmptyScreen:
.rept	616
.hword	0
.endr	
	
.align
.global frameBufferInfo 			//"a" was missing
frameBufferInfo:
	.int	0		@ frame buffer pointer
	.int	0		@ screen width
	.int	0		@ screen height
