@ The program
// Program that reads input from a SNES controller and prints the buttons
// pressed to terminal
// Authors:
// Nathan Cruz
// Philip Dometita
// John Benedict Mendoza
// March 7, 2018

.section    .text

// calls the functions and runs the program
.global snesDriver
.global InitializeSNES
InitializeSNES:
	push	{lr}
	// setup macros
	gBase	.req	r7	
	buttons	.req	r8
	
	// get GPIO base address and store in memory for future use
	bl		getGpioPtr		
	ldr		r1, =gpioBaseAddress
	str		r0, [r1]
	
	// save GPIO address to a local variable
	ldr		r0, =gpioBaseAddress
	ldr		gBase, [r0]
	
	// set GPIO 10 to input through init_GPIO (DAT)
	mov		r0, #10														
	mov		r1, #0b000
	bl		init_GPIO
	
	// set GPIO 9 to output through init_GPIO (LAT)
	mov		r0, #9														 
	mov		r1, #0b001
	bl		init_GPIO
	
	// set GPIO 11 to output through init_GPIO (CLK)
	mov		r0, #11														
	mov		r1, #0b001
	bl		init_GPIO
	pop		{lr}
	mov		pc, lr																	

snesDriver:
	push		{r4, r5, lr}
	
	bl		Read_SNES
	mov		buttons, r0
	ldr		r4, =noInput
	ldr		r5, [r4]
	
	// program end
endLoop:
	mov		r0, buttons
	
	pop		{r4, r5, lr}
	mov		pc, lr
	
	// initializes a GPIO line
	// sets the function code of the specified GPIO line
	// parameters: r0 = GPIO line, r1 = function code
init_GPIO:																
	
	// pushes register variables to the stack
	push	{r4, lr}
	
	// r4 = function code
	mov		r4, r1 						
	// get the GPFSEL Offset								
	bl		getGPFSELOffset												
							
getOffset:

	// r0 now contains the offset corresponding to the pin number
	// load the register containing the pin															
	mov		r3, r0														
	ldr		r0, [gBase, r3]												

	// assign the bits to either input or output		
assignBits:
	// r2 = r1 * 3 = first index of the pin															
	add		r2, r1, r1, lsl #1											
	
	// sets the bits corresponding to the pin to 000
	mov		r1, #0b111
	bic		r0, r1, lsl r2
	
	// sets the bits corresponding to the pin to the specified function code
	orr		r0, r4, lsl r2
	
	// save the changes
	str		r0, [gBase, r3] 
	
	// pop the values on the stack and return 
	pop		{r4, lr}
	mov		pc,	lr


	// returns the corresponding GPFSEL offset for the specified
getGPFSELOffset:
	push	{r4, lr}
	
	// check if line number is in GPFSEL0
	cmp		r0, #9														
	movle	r1, r0
	movle	r0, #0
	ble		skipSubLoop
	
	// else divide pin number by 10, rounded down
	mov		r4, r0
	mov		r0, #0
	
	// divides pin number by 10, rounded down
subLoop:
	sub		r4, #10
	cmp		r4,	#0
	addge	r0, #1
	movge	r1, r4
	bge		subLoop
	
skipSubLoop:
	
	// multiple the index of GPFSEL by 4 to get offset 
	lsl		r0, #2	
	
	// pop values off the stack and return GPFSEL offset
	pop		{r4, lr}
	mov		pc,	lr

	// write a bit to the SNES latch line
	// paramters: r0 = bit to write
Write_Latch:															
	push	{r4, lr}
	//r4 = bit to write													
	mov		r4, r0														
	mov		r3, #1														
	
	// loads GPIO base address
	ldr		r0, =gpioBaseAddress
	ldr		gBase, [r0]
	
	lsl		r3, #9
	
	teq		r4, #0
	//GPCLR0
	streq	r3, [gBase, #40]
	//GPSET0											
	strne	r3, [gBase, #28]											
	
	// pop values off the stack and returns
	pop		{r4, lr}
	mov		pc, lr
	
	// writes a bit to the SNES data line
	// parameters: r0 = bit to write
Write_Clock:
	push	{lr}
	
	// loads GPIO base address
	ldr		r1, =gpioBaseAddress
	ldr		gBase, [r1]
	
	// if bit = 0 then GPCLR on the corresponding bit index
	// if bit = 1 then GPSET on the corresponding bit index
	mov		r3, #1
	lsl		r3, #11
	teq		r0, #0
	strne	r3, [gBase, #28]
	streq	r3, [gBase, #40]
	
	// pops values off the stack and returns
	pop		{lr}
	mov		pc, lr
	
	
	// reads a bit from the SNES data line
	// returns: the bit on the data line
Read_Data:
	push	{lr}
	
	// loads GPIO base address
	mov		r0, #10
	ldr		r2, =gpioBaseAddress
	// loads GPLEV0 to read 
	ldr		gBase, [r2]
	ldr		r1, [gBase, #52]
	
	// checks if the specified bit is 0 or 1
	mov		r3, #1
	lsl		r3, r0
	and		r1, r3
	
	teq		r1, #0
	moveq	r0, #0
	movne	r0, #1
	
	// pops values off the stack and returns the value of the pin
	pop		{lr}
	mov 	pc, lr
	
	// reads input from the SNES controller
	// saves buttons register to buttonInfo on data section
Read_SNES:
	push	{r4, buttons, lr}
	
	// initialize buttons register to 0
	mov		buttons, #0													
	
	// write 1 to clock
	mov		r0, #1														
	bl		Write_Clock
	
	// set latch to high for 12 microseconds
	mov		r0, #1
	bl		Write_Latch
	mov		r0, #12
	bl		delayMicroseconds
	
	// set latch to 0
	mov		r0, #0
	bl		Write_Latch
	
	// r4 = index
	mov		r4, #0														
	b		pulseLoopTest
	
	// loop to read from SNES
	// take input from data line every 6 microseconds
pulseLoop:																
	mov		r0, #6
	bl 		delayMicroseconds
	
	// set clock to 0 for 6 ms and read data 
	mov		r0, #0
	bl		Write_Clock
	
	mov		r0, #6
	bl		delayMicroseconds
	
	// fetches the bit from the data line
	bl		Read_Data
	lsl		r0, r4
	add		buttons, r0
	
	// set clock to 1 for 6 ms
	mov		r0, #1
	bl		Write_Clock
	
	// increment index
	add		r4, #1
	
	// loop while i < 16
pulseLoopTest:
	cmp		r4, #16
	blt		pulseLoop
	
	// pops values off the stack and returns the value of the button register
	ldr		r0, =buttonInfo
	str		buttons, [r0]
	pop		{r4, buttons, lr}
	mov		pc, lr
	
	// detects which buttons were pressed 
	// 1 = button is pressed
	// 0 = button not pressed
	.global CheckB
CheckB:
	push	{r4, r5, buttons, lr}
	
	// loads buttonInfo and stores it in buttons
	ldr		r0, =buttonInfo
	str		buttons, [r0]	
	
	mov		r4, #1
	
	and		r5, buttons, r4
	cmp		r5, #0
	moveq	r0, #1
	movne	r0, #0
	
	pop	{r4, r5, buttons, lr}
	mov 	pc, lr
	
	.global CheckStart
CheckStart:
	push	{r4, r5, buttons, lr}
	
	// loads buttonInfo and stores it in buttons
	ldr		r0, =buttonInfo
	str		buttons, [r0]	
	
	mov		r3, #1
	add		r4, r3, lsl #3
	
	and		r5, buttons, r4
	cmp		r5, #0
	moveq	r0, #1
	movne	r0, #0
	
	pop		{r4, r5, buttons, lr}
	mov 	pc, lr
	
	.global	CheckUp
CheckUp:
	push	{r4, r5, buttons, lr}
	
	// loads buttonInfo and stores it in buttons
	ldr		r0, =buttonInfo
	str		buttons, [r0]	
	
	mov		r3, #1
	mov		r4, #0
	add		r4, r3, lsl #4
	
	and		r5, buttons, r4
	cmp		r5, #0
	moveq	r0, #1
	movne	r0, #0
	
	pop		{r4, r5, buttons, lr}
	mov 	pc, lr

	.global	CheckDown
CheckDown:
	push	{r4, r5, buttons, lr}
	
	// loads buttonInfo and stores it in buttons
	ldr		r0, =buttonInfo
	str		buttons, [r0]	
	
	mov		r3, #1
	mov		r4, #0
	add		r4, r3, lsl #5
	
	and		r5, buttons, r4
	cmp		r5, #0
	moveq	r0, #1
	movne	r0, #0
	
	pop		{r4, r5, buttons, lr}
	mov 	pc, lr
	
	
	.global	CheckLeft
CheckLeft:
	push	{r4, r5, buttons, lr}
	
	// loads buttonInfo and stores it in buttons
	ldr		r0, =buttonInfo
	str		buttons, [r0]	
	
	mov		r3, #1
	mov		r4, #0
	add		r4, r3, lsl #6
	
	and		r5, buttons, r4
	cmp		r5, #0
	moveq	r0, #1
	movne	r0, #0
	
	pop		{r4, r5, buttons, lr}
	mov 	pc, lr

	.global	CheckRight
CheckRight:
	push	{r4, r5, buttons, lr}
	
	// loads buttonInfo and stores it in buttons
	ldr		r0, =buttonInfo
	str		buttons, [r0]	
	
	mov		r3, #1
	mov		r4, #0
	add		r4, r3, lsl #7
	
	and		r5, buttons, r4
	cmp		r5, #0
	moveq	r0, #1
	movne	r0, #0
	
	pop		{r4, r5, buttons, lr}
	mov 	pc, lr
	
	.global	CheckA
CheckA:
	push	{r4, r5, buttons, lr}
	
	// loads buttonInfo and stores it in buttons
	ldr		r0, =buttonInfo
	str		buttons, [r0]	
	
	mov		r3, #1
	mov		r4, #0
	add		r4, r3, lsl #8
	
	and		r5, buttons, r4
	cmp		r5, #0
	moveq	r0, #1
	movne	r0, #0
	
	pop		{r4, r5, buttons, lr}
	mov 	pc, lr	

	
@ Data section
.section .data

	// value when no buttons are pressed
noInput:
.int		65535

	// contains info about which buttons are pressed
	// default value = no buttons pressed
buttonInfo:
.int		65535

	// strings for printing
creatorNames:
.asciz		"Created by: Nathan Cruz (30030215), Philip Dometita (30032976) and John Benedict Mendoza (30028470)\r\n\n"

inputPrompt:
.asciz		"Please press a button...\r\n\n"

buttonMessage:
.asciz		"You have pressed:\n"

buttonB:
.asciz		"B\n"

buttonY:
.asciz		"Y\n"

buttonSL:
.asciz		"Select\n"

buttonST:
.asciz		"Start\n"

buttonUP:
.asciz		"Joy-pad UP\n"

buttonDOWN:
.asciz		"Joy-pad DOWN\n"

buttonLEFT:
.asciz		"Joy-pad LEFT\n"

buttonRIGHT:
.asciz		"Joy-pad RIGHT\n"

buttonA:
.asciz		"A\n"

buttonX:
.asciz		"X\n"

buttonL:
.asciz		"L\n"

buttonR:
.asciz		"R\n"

newLine:
.asciz		"\n"

terminateMessage:
.asciz		"Program is terminating...\r\n\n"


.align 2
	// address containing the GPIO base address
.global gpioBaseAddress
gpioBaseAddress:
	.int	0
