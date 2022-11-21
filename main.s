	
	;; RK 11/2012 - Evalbot (Cortex M3 de Texas Instrument)
	;; fait clignoter une seule LED connect?e au port GPIOF
   	
		AREA    |.text|, CODE, READONLY
 
; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIO EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)
GPIO_PORTE_BASE		EQU		0x40024000	; GPIO Port E (APB) base: 0x4002.4000 (p416 datasheet de lm3s9B92.pdf)

; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)
GPIO_PUR	   		EQU 	0x00000510  

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN   		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Port select
PORT4				EQU		0x10		; led1 sur port 4 0b00010000
BumperG				EQU		0x02		; led1 sur port 1 0b00000010
BumperD				EQU		0x01		; led1 sur port 0 0b00000001

; blinking frequency
DUREE   			EQU     0x002FFFFF	

	  	ENTRY
		EXPORT	__main
__main	

		; ;; Enable the Port F peripheral clock by setting bit 5 (0x38 == 0b010000)		(p291 datasheet de lm3s9B96.pdf)
		; ;;														 (GPIO::FEDCBA)
		ldr r6, = SYSCTL_PERIPH_GPIO  			;; RCGC2
        mov r0, #0x00000010  					;; Enable clock sur GPIO F o? sont branch?s les leds (0x20 == 0b100000)
		; ;;														 									 (GPIO::FEDCBA)
        str r0, [r6]
		
		; ;; "There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)
		nop	   									;; tres tres important....
		nop	   
		nop	   									;; pas necessaire en simu ou en debbug step by step...
	
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION LED

        ldr r6, = GPIO_PORTE_BASE+GPIO_O_DIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)
        ldr r0, = 0x00 	
        str r0, [r6]
		
        ldr r6, = GPIO_PORTE_BASE+GPIO_O_DEN	;; Enable Digital Function 		
        ldr r0, = BumperG+BumperD	
        str r0, [r6]
 
		ldr r6, = GPIO_PORTE_BASE+GPIO_PUR	;; Choix de l'intensit? de sortie (2mA)
        ldr r0, = BumperG+BumperD 			
        str r0, [r6]

        mov r2, #0x000       					;; pour eteindre LED
     
		; allumer la led broche 4 (PORT4)
		mov r3, #PORT4       					;; Allume portF broche 4 : 00010000
		ldr r6, = GPIO_PORTF_BASE + (PORT4<<2)  ;; @data Register = @base + (mask<<2) ==> LED1

		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration LED 

		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CLIGNOTTEMENT

loop
        str r2, [r6]    						;; Eteint LED car r2 = 0x00      
        ldr r1, = DUREE 						;; pour la duree de la boucle d'attente1 (wait1)

wait1	subs r1, #1
        bne wait1

        str r3, [r6]  							;; Allume portF broche 4 : 00010000 (contenu de r3)
        ldr r1, = DUREE							;; pour la duree de la boucle d'attente2 (wait2)

wait2   subs r1, #1
        bne wait2

        b loop       
		
		nop		
        END 