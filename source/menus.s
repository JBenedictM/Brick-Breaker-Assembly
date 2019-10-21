@Code Section
.section .text


.global StartMenu
StartMenu:
	push	{r4, r5, r6, lr}
	mov		r4, #18 		//r4 = current row pos for selector
	mov		r6, #18			//r6 = old row pos
	mov		r0, r4
	bl		IndexSelector
	
loopTop:
	bl		snesDriver
	mov		r5, r0
	
	mov		r0, #18
	mov		r1, #8
	mov		r3, #0
	bl		IndexStartMenu
	
	mov		r0, #20
	mov		r1, #8
	mov		r3, #2
	bl		IndexStartMenu

	mov		r0, r5
	bl		CheckDown
	cmp		r0, #0
	cmpeq	r4, #18
	moveq	r6, r4
	addeq	r4, r4, #2
	beq		moveSel
	
	mov		r0, r5
	bl		CheckUp
	cmp		r0, #0
	cmpeq	r4, #20
	moveq	r6, r4
	subeq	r4, r4, #2
	beq		moveSel
	
	b		checkSelector
moveSel:
	mov		r0, r6
	mov		r1, #6
	bl		IndexSelector
	
	mov		r0, r4
	mov		r1, #4
	bl		IndexSelector
	
checkSelector:
	mov		r0, r5
	bl		CheckA
	mov		r1, r0
	cmp		r1, #0
	cmpeq	r4,	#18
	beq		startgame
	
	cmp		r1, #0
	cmpeq	r4, #20
	beq		clearScreen
	
	
	ldr		r0, =startMenArray
	bl		DrawGrid
	
	b		loopTop

clearScreen:
	ldr		r0, =EmptyScreen
	bl		DrawGrid
haltLoop$:
	b		haltLoop$
	
startgame:
	pop		{r4, r5, r6, lr}
	mov 	pc, lr

IndexStartMenu:
	push	{r4, r5, r6, r7, r8, r9, lr}
	
		ldr		r9, =GRIDDIMENSION
		ldr		r9, [r9, #4]		// width
		mov		r10, r3	
		mov		r4, r0		// row index
		mov		r5, r1		// column index
		add		r6, r5, #5	
			
	indexSt:
		ldr		r8, =MENUTYPES
		ldrh	r2, [r8, r10]
		mul		r3, r4, r9 		// row * width
		add		r3, r5			// row * width + offset
		lsl 	r3, #1			// each element is halfword
		ldr		r7, =startMenArray
		strh	r2, [r7, r3]
		
		add		r5, #1
		cmp		r5, r6
		blt		indexSt 
		
	pop		{r4, r5, r6, r7, r8, r9, lr}
	mov		pc,	lr

IndexSelector:
	
	push	{r4, r5, r6, r7, r8, r9, lr}
		ldr		r9, =GRIDDIMENSION
		ldr		r9, [r9, #4]		// width
		mov		r4, r0		// row index
		mov		r5, #6		// column index
			
	indexSl:
		cmp		r1, #6
		bne		skipClear
		ldr		r8, =CELLTYPES
		ldrh	r2, [r8, #4]	
		b		skipMenuType
skipClear:		
		ldr		r8, =MENUTYPES
		ldrh	r2, [r8, #4]
skipMenuType:
		mul		r3, r4, r9 		// row * width
		add		r3, r5			// row * width + offset
		lsl 	r3, #1			// each element is halfword
		ldr		r7, =startMenArray
		strh	r2, [r7, r3]
		
		
	pop		{r4, r5, r6, r7, r8, r9, lr}
	mov		pc,	lr
