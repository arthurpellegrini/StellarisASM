	
	;; RK - Evalbot (Cortex M3 de Texas Instrument)
	;; fait clignoter une seule LED connectée au port GPIOF
   	
		AREA    |.text|, CODE, READONLY
 
; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIOF EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN   		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; PIN select
PINS_PORTF				EQU		0x30		; led 1 & 2 sur broches 4 & 5 (0011 0000)

; blinking frequency
DUREE   			EQU     0x002FFFFF	; Random Value

	  	ENTRY
		EXPORT	__main
__main	

		; ;; Enable the Port F peripheral clock by setting bit 5 (0x20 == 0b100000)		(p291 datasheet de lm3s9B96.pdf)
		; ;;														 (GPIO::FEDCBA)
		ldr r6, = SYSCTL_PERIPH_GPIOF  			;; RCGC2
        mov r0, #0x00000020  					;; Enable clock sur GPIO F où sont branchés les leds (0x20 == 0b100000)
		; ;;														 									 (GPIO::FEDCBA)
        str r0, [r6]
		
		; ;; "There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)
		nop	   									;; tres tres important....
		nop	   
		nop	   									;; pas necessaire en simu ou en debbug step by step...
	
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION LED
        ldr r0, = PINS_PORTF
        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DIR   
        str r0, [r6]
		
        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN
        str r0, [r6]
 
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DR2R		
        str r0, [r6]
		
		; allumer les leds
		mov r3, #PINS_PORTF       					;; Allume portF broches 4 et 5
		ldr r6, = GPIO_PORTF_BASE + (PINS_PORTF<<2) 
		
		        
        mov r2, #0x000       					;; pour eteindre LED

		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration LED 
		
		
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION SWITCH
		
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration SWITCH
		

		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CLIGNOTTEMENT

loop    str r2, [r6]    						;; Eteint LED car r2 = 0x00     		
        
		ldr r1, = DUREE
wait1	subs r1, #1
        bne wait1
	
        str r3, [r6]  							;; Allume portF broche 4 & 5 : 00110000 (contenu de r3)
        
		ldr r1, = DUREE
wait2   subs r1, #1
        bne wait2

        b loop       
		
		nop		
        END 