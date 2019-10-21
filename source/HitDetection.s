@ Code section
.section .text

@ SetPaddleSpeed - Sets the paddle speed
@
@ Arguments:
@ r0 - New paddle speed
@
@ Returns:
@ None
@
.global SetPaddleSpeed
SetPaddleSpeed:
	push 	{lr}
	
	@Update the paddle velocity
	ldr		r1, =paddleVel
	str		r0, [r1]
	
	pop		{lr}
	mov		pc, lr

@ MovePaddleLeft - Move the paddle to the left
@
@ Arguments:
@ None
@
@ Returns:
@ None
@
.global	MovePaddleLeft
MovePaddleLeft:
	push	{r4, r5, r6, r7, r8, r9, r10, lr}
	
	@ Load the wall boundaries and position of the paddle
	ldr		r8, =wallBoundaries
	ldr		r5, =paddlePos
	ldr		r6, [r5]		@ top left x
	
	@ Get the paddle velocity and apply it to the paddle position
	ldr		r7, =paddleVel
	ldr		r1, [r7]	
	sub		r6, r1
	@ Check if the position will overlap with the left wall
	mov		r0, r6
	bl		LeftWallCheck
	cmp		r0, #1
	@ Magnet to the left wall if the position will overlap
	ldrne	r6, [r8]	
	
	@Store the new position
	str		r6, [r5]
	
	pop		{r4, r5, r6, r7, r8, r9, r10, lr}
	bx 		lr

@ MovePaddleRight - Move the paddle to the right
@
@ Arguments:
@ None
@
@ Returns:
@ None
@
.global	MovePaddleRight
MovePaddleRight:
	push	{r4, r5, r6, r7, r8, r9, r10, lr}
	
	@ Load the wall boundaries and position of the paddle
	ldr		r8, =wallBoundaries
	ldr		r5, =paddlePos
	ldr		r9, =PADDLEDIMENSION
	ldr		r6, [r5]		@ top left x
	
	@ Get the paddle velocity and apply it to the paddle position
	ldr		r7, =paddleVel
	ldr		r1, [r7]	//paddle velocity
	add		r6, r1
	
	@ Check if the position will overlap with the right wall
	ldr		r4, [r9]
	add		r2, r4, r6
	mov		r0, r2
	bl		RightWallCheck
	cmp		r0, #1
	@ Magnet to the right wall if the position will overlap
	ldrne	r6, [r8, #4]	// load right boundary
	subne	r6, r4
	
	@Store the new position
	str		r6, [r5]
	
	pop		{r4, r5, r6, r7, r8, r9, r10, lr}
	bx 		lr

@ MoveBall - Moves the ball
@
@ Arguments:
@ None
@
@ Returns:
@ None
@
.global MoveBall
MoveBall:
	push	{r4, r5, r6, r7, r8, r9, r10, lr}

	ldr		r8, =wallBoundaries
	ldr		r5, =ballPos
	ldr		r7, =ballVel
	ldr		r9, =BALLDIMENSION
	
	@ X Movement
	ldr		r6, [r5]
	
	@ Get the next X position
	ldr		r1, [r7]	
	add		r6, r1
	@ Check which wall to check based on X velocity
	cmp		r1, #0
	bls		leftBallX
	bgt		RightBallX
	
leftBallX:
	@ Check if the position will overlap with the left wall
	mov		r0, r6
	bl		LeftWallCheck
	cmp		r0, #1
	beq		BallXDone
	
	@ Magnet to the left wall if the position will overlap and flip X velocity
	ldr		r6, [r8]	
	b		FlipXVel

RightBallX:	
	@ Check if the position will overlap with the right wall
	ldr		r4, [r9]
	add		r2, r4, r6
	mov		r0, r2
	bl		RightWallCheck
	cmp		r0, #1
	beq		BallXDone
	
	@ Magnet to the right wall if the position will overlap and flip X velocity
	ldr		r6, [r8, #4]
	sub		r6, r4
	b		FlipXVel
	
FlipXVel:
	@ Flip X velocity
	ldr		r1, [r7]		
	rsb		r1, #0
	str		r1, [r7]
	
BallXDone:
	@ Store the new X position
	str		r6, [r5]
	

	@ Y Movement
	ldr		r6, [r5, #4]

	@ Get the next Y position	
	ldr		r1, [r7, #4]
	add		r6, r1
	@ Check if the position will overlap with the ceiling
	mov		r0, r6
	bl		CeilCheck
	cmp		r0, #1
	beq		BallYDone
	@ Magnet to the ceiling if the position will overlap and flip Y velocity
	mov		r6, r2			
	
FlipYVel:
	@ Flip Y velocity
	ldr		r1, [r7, #4]		
	rsb		r1, #0
	str		r1, [r7, #4]
	
BallYDone:
	@ Store the new Y position	
	str		r6, [r5, #4]	
	
	@ Check paddle detection	
	bl		BallScan
	
	pop		{r4, r5, r6, r7, r8, r9, r10, lr}
	mov		pc,	lr
	
@ LeftWallCheck - Checks if a point overlaps with the left wall
@
@ Arguments:
@ r0 - X coordinate of the point
@
@ Returns:
@ r0 - 1 = Point not will overlap, 0 = Point will overlap
@
.global LeftWallCheck
LeftWallCheck:
	push	{r4, r5, r6, r7, r8, r9, r10, lr}
	
	ldr		r1, =wallBoundaries
	
	ldr		r2, [r1]
	cmp		r0, r2
	@Assign the return value
	movls	r0, #0	
	movge	r0, #1	
	
	pop		{r4, r5, r6, r7, r8, r9, r10, lr}
	mov		pc,	lr
	
@ RightWallCheck - Checks if a point overlaps with the right wall
@
@ Arguments:
@ r0 - X coordinate of the point
@
@ Returns:
@ r0 - 1 = Point not will overlap, 0 = Point will overlap
@
.global RightWallCheck
RightWallCheck:
	push	{r4, r5, r6, r7, r8, r9, r10, lr}
	
	ldr		r1, =wallBoundaries
	
	ldr		r2, [r1, #4]
	cmp		r0, r2
	@Assign the return value
	movgt	r0, #0	
	movlt	r0, #1
	
	pop		{r4, r5, r6, r7, r8, r9, r10, lr}
	mov		pc,	lr

@ CeilCheck - Checks if a point overlaps with the ceiling
@
@ Arguments:
@ r0 - Y coordinate of the point
@
@ Returns:
@ r0 - 1 = Point not will overlap, 0 = Point will overlap
@
CeilCheck:
	push	{r4, r5, r6, r7, r8, r9, r10, lr}
	
	ldr		r1, =INITIALPOINT
	
	ldr		r2, [r1, #4]
	add		r2, #32
	cmp		r0, r2
	@Assign the return value
	movle	r0, #0
	movgt	r0, #1
	
	pop		{r4, r5, r6, r7, r8, r9, r10, lr}
	mov		pc,	lr

@ BallScan - Checks the positions of the 4 corners of the ball
@
@ Arguments:
@ None
@
@ Returns:
@ None
@
BallScan:
	push	{r4, r5, r6, r7, r8, r9, r10, lr}

	ldr		r4, =ballPos
	ldr		r5, =ballVel
	ldr		r6, =BALLDIMENSION
	ldr		r6, [r6]

	@ Check top left corner	
	ldr		r0, [r4]
	ldr		r1, [r4, #4]
	bl		PaddleScan
	cmp		r0, #0
	beq		HitDetect

	@ Check top right corner	
	ldr		r0, [r4]
	ldr		r1, [r4, #4]
	add		r0, r6
	bl		PaddleScan
	cmp		r0, #0
	beq		HitDetect

	@ Check bottom left corner	
	ldr		r0, [r4]
	ldr		r1, [r4, #4]
	add		r1, r6
	bl		PaddleScan
	cmp		r0, #0
	beq		HitDetect
	
	@ Check bottom right corner	
	ldr		r0, [r4]
	ldr		r1, [r4, #4]
	add		r0, r6
	add		r1, r6
	bl		PaddleScan
	cmp		r0, #0
	beq		HitDetect
	
	bne		DoneScan
	
	@ Ball overlaps with paddle	
HitDetect:
	cmp		r1, #0
	beq		BodyHit
	
	@ The ball hit the corner of the paddle
CornerHit:
	@ Adjust X velocity
	ldr		r2, [r5]	
	cmp		r1, #1
	@ Check which direction to go based on which corner was hit
	moveq	r2, #-8
	movne	r2, #8
	str		r2, [r5]
	
	@ Adjust Y velocity
	ldr		r2, [r5, #4]
	mov		r2, #-8
	str		r2, [r5, #4]
		
	b		DoneScan

	@ The ball didn't hit the corner of the paddle
BodyHit:
	@ Slow down X velocity
	ldr		r2, [r5]
	cmp		r2, #0
	@ Preserve the direction of the X velocity
	movls	r2, #-6
	movgt	r2,	#6
	str		r2, [r5]
	
	@ Speed up Y velocity
	ldr		r2, [r5, #4]		// Adjust Y velocity
	mov		r2, #-10
	str		r2, [r5, #4]

	b		DoneScan

BrickHit:
	b		BrickHit

DoneScan:
	pop		{r4, r5, r6, r7, r8, r9, r10, lr}
	mov		pc,	lr
	
@ PaddleScan - Checks if a point overlaps with the paddle
@
@ Arguments:
@ r0 - X coordinate of the point
@ r1 - Y coordinate of the point
@
@ Returns:
@ r0 - 1 = Point not will overlap, 0 = Point will overlap
@ r1 - 0 = Body was hit, 1 = Left corner was hit, 2 = Right corner was hit
@
PaddleScan:
	push	{r4, r5, r6, r7, r8, r9, r10, lr}

	ldr		r4, =paddlePos
	ldr		r5, =PADDLEDIMENSION
	
	@ Is the X coordinate of the point overlaps with the paddle
PaddleScanX:
	ldr		r2, [r4]	
	ldr		r3, [r5]
	cmp		r0, r2
	blt		BallMissPaddle
	add		r3, r2
	cmp		r0, r3
	bgt		BallMissPaddle
	
	@ Is the Y coordinate of the point overlaps with the paddle
PaddleScanY:
	ldr		r2, [r4, #4]	
	ldr		r3, [r5, #4]
	cmp		r1, r2
	blt		BallMissPaddle
	add		r3, r2
	cmp		r1, r3
	bgt		BallMissPaddle
	
	@ Where in the paddle did the point hit
BallCheckSection:
	@ Left corner check
	ldr		r2, [r4]
	add		r2, #16
	cmp		r0, r2
	movls	r1, #1
	bls		BallHitPaddle
	
	@ Right corner check
	ldr		r2, [r4]
	ldr		r3, [r5]
	add		r2, r3
	sub		r2, #16
	cmp		r0, r2
	movgt	r1, #2
	bgt		BallHitPaddle
	
	@ Point hits the body
	mov		r1, #0	
	
	@ Turn on the hit detection flag
BallHitPaddle:	
	mov		r0, #0
	b		DonePaddleScan

	@ Turn off the hit detection flag
BallMissPaddle:
	mov		r0, #1
	
DonePaddleScan:	
	pop		{r4, r5, r6, r7, r8, r9, r10, lr}
	mov		pc,	lr

@ BrickScan - Checks if a point overlaps with a brick
@
@ Arguments:
@ r0 - X coordinate of the point
@ r1 - Y coordinate of the point
@
@ Returns:
@ r0 - 1 = Point not will overlap, 0 = Point will overlap
@
BrickScan:
	push	{r4, r5, r6, r7, r8, r9, r10, lr}

	ldr		r4, =screenArray
	ldr		r5, =BACKGROUNDLABELS
	ldrb	r5, [r5]
	ldr		r6, =GRIDDIMENSION
	ldr		r6, [r6, #4]
	
ScanForRow:
	mov		r7, r0
	mov		r8, #0
	sub		r7, #32
	cmp		r7, #0
	addge	r8, #1
	bgt		ScanForRow
	
	mov		r9, r7
			
ScanForColumn:
	mov		r7, r1
	mov		r8, #0
	sub		r7, #32
	cmp		r7, #0
	addge	r8, #1
	bgt		ScanForColumn	
	
	mov		r10, r7
	
	mul		r7, r9, r6			// row * column value
	add		r7, r10				// add column offset
	lsl		r7, #1
	ldrb	r1, [r4, r7]
	
	cmp		r5, r1
	beq		BallMissBrick
	
	@ Turn on the hit detection flag
BallHitBrick:	
	mov		r0, #0
	b		DoneBrickScan

	@ Turn off the hit detection flag
BallMissBrick:
	mov		r0, #1
	
DoneBrickScan:	
	pop		{r4, r5, r6, r7, r8, r9, r10, lr}
	mov		pc,	lr	
	
@ Data section
.section .data

@ paddlePos - Top Left point of the paddle
.global paddlePos
paddlePos:	
.int	0, 0		//x = (9*32) + INITIALPOINT.x, y = (25*32) + INITIALPOINT.y

@ paddlePos - Velocity of the paddle
.global paddleVel
paddleVel:
.int	4

@ ballPos - Top Left point of the ball
.global ballPos
ballPos:	
.int	288, 700

@ ballVel - Velocity of the ball
.global ballVel
ballVel:	
.int	8, -8	

@ wallBoundaries - Boundaries for the walls
.global wallBoundaries
wallBoundaries:	
.int	0, 0		// left = (INITIALPOINT.x + 32), right = (((# of columns -1)*32)+INITIALPOINT.x)-(21)
