	;; RK - Evalbot (Cortex M3 de Texas Instrument)
; programme - Pilotage 2 Moteurs Evalbot par PWM tout en ASM (Evalbot tourne sur lui même)



		AREA    |.text|, CODE, READONLY

		
; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIOF EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTD_BASE		EQU		0x40007000	; GPIO Port D (APB) base: 0x4000.7000
GPIO_PORTE_BASE		EQU		0x40024000	; GPIO Port E (APB) base: 0x4002.4000
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

; The GPIOPUR register is the pull-up control register
GPIO_O_PUR			EQU		0x00000510 

; PINS port input
PINSD_6_7				EQU		0xC0		; switch 1 & 2 sur broches 6 & 7 (1100 0000)
PINSE_1_2				EQU		0x03		; bumpers 1 & 2 sur les broches (0000 0011)

; PINS port output
PINSF_4_5				EQU		0x30		; led 1 & 2 sur broches 4 & 5 (0011 0000)
	
; blinking frequency
DUREE   			EQU     0x002FFFFF	; Random Value
		
		
		ENTRY
		EXPORT	__main
		
		;; The IMPORT command specifies that a symbol is defined in a shared object at runtime.
		IMPORT	MOTEUR_INIT					; initialise les moteurs (configure les pwms + GPIO)
		
		IMPORT	MOTEUR_DROIT_ON				; activer le moteur droit
		IMPORT  MOTEUR_DROIT_OFF			; déactiver le moteur droit
		IMPORT  MOTEUR_DROIT_AVANT			; moteur droit tourne vers l'avant
		IMPORT  MOTEUR_DROIT_ARRIERE		; moteur droit tourne vers l'arrière
		IMPORT  MOTEUR_DROIT_INVERSE		; inverse le sens de rotation du moteur droit
		
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; déactiver le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant
		IMPORT  MOTEUR_GAUCHE_ARRIERE		; moteur gauche tourne vers l'arrière
		IMPORT  MOTEUR_GAUCHE_INVERSE		; inverse le sens de rotation du moteur gauche


__main	
		; ;; Enable the Port F peripheral clock by setting bit 5 (0x20 == 0b100000)		(p291 datasheet de lm3s9B96.pdf)
		; ;;														 (GPIO::FEDCBA)
		ldr r6, = SYSCTL_PERIPH_GPIOF  			;; RCGC2
        mov r0, #0x00000038  					;; Enable clock sur GPIO F E D (0011 1000)
		; ;;														 									 (GPIO::FEDCBA)
        str r0, [r6]
	
		; ;; "There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)
		nop	   									;; tres tres important....
		nop	   
		nop	   									;; pas necessaire en simu ou en debbug step by step...
	
		;-----------------------CONFIGURATION LED
        ldr r0, = PINSF_4_5
        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DIR   
        str r0, [r6]
		    
        ldr r6, = GPIO_PORTF_BASE+GPIO_O_DEN
        str r0, [r6]
 
		ldr r6, = GPIO_PORTF_BASE+GPIO_O_DR2R		
        str r0, [r6]
		
		; allumer les leds
		mov r2, #PINSF_4_5    

		;; Allume portF broches 4 et 5   					
		ldr r6, = GPIO_PORTF_BASE + (PINSF_4_5<<2) 

		;; pour eteindre LED 
        mov r1, #0x000       					

		;-----------------------FIN CONFIGURATION LED 
		
		;-----------------------CONFIGURATION SWITCH
		ldr r0, = PINSD_6_7
		
		ldr r7, = GPIO_PORTD_BASE+GPIO_O_DEN
		str r0, [r7]
 
		ldr r7, = GPIO_PORTD_BASE+GPIO_O_PUR	
		str r0, [r7]
		
		ldr r7, = GPIO_PORTD_BASE + (PINSD_6_7<<2) 
		;-----------------------FIN CONFIGURATION SWITCH

		;;----------------------CONFIGURATION BUMPER
		ldr r0, = PINSE_1_2
		
		ldr r8, = GPIO_PORTE_BASE+GPIO_O_DEN
		str r0, [r8]
 
		ldr r8, = GPIO_PORTE_BASE+GPIO_O_PUR	
		str r0, [r8]
		ldr r8, = GPIO_PORTE_BASE + (PINSE_1_2<<2) 
		;;----------------------FIN CONFIGURATION BUMPER




		;; BL Branchement vers un lien (sous programme)

		; Configure les PWM + GPIO
		BL	MOTEUR_INIT	   		   
		
		; Activer les deux moteurs droit et gauche
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON

		
loop	  
        ; Boucle de pilotage des 2 Moteurs (Evalbot tourne sur lui même)
		; Evalbot avance droit devant
		BL	MOTEUR_DROIT_AVANT	   
		BL	MOTEUR_GAUCHE_AVANT
		
		; Avancement pendant une période (deux WAIT)
		BL	WAIT	; BL (Branchement vers le lien WAIT); possibilité de retour à la suite avec (BX LR)
		BL	WAIT
		
		; Rotation à droite de l'Evalbot pendant une demi-période (1 seul WAIT)
		;BL	MOTEUR_DROIT_ARRIERE   ; MOTEUR_DROIT_INVERSE
		;BL	WAIT

		ldr r3, [r7]							;; on récupère les entrées des switchs
		ldr r4, [r8]							;; on récupère les entrées des bumpers
		str r1, [r6]    						;; Eteint LED car r2 = 0x00     		
		BL WAIT
        str r2, [r6]  							;; Allume portF broche 4 & 5 : 00110000 (contenu de r3)
		BL WAIT

		b	loop

		;; Boucle d'attante
WAIT	ldr r0, =0xAFFFFF 
wait1	subs r0, #1
        bne wait1
		
		;; retour à la suite du lien de branchement
		BX	LR

		NOP
        END