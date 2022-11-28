; RK - Evalbot (Cortex M3 de Texas Instrument)
;------------------------------------------------
; AUTHORS - Arthur PELLEGRINI & Clément BRISSARD
;------------------------------------------------

		AREA    |.text|, CODE, READONLY
			
; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIOF EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; Configure the corresponding pin to be an output
; All GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN   		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; The GPIOPUR register is the pull-up control register
GPIO_O_PUR			EQU		0x00000510 

; The GPIODATA register is the data register
GPIO_PORTD_BASE		EQU		0x40007000	; GPIO Port D (APB) base: 0x4000.7000
GPIO_PORTE_BASE		EQU		0x40024000	; GPIO Port E (APB) base: 0x4002.4000
GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; PINS Port Input
PINSD_6_7			EQU		0xC0		; Switchs 1 & 2 on Pins 6 & 7	(1100 0000)
PINSE_1_2			EQU		0x03		; Bumpers 1 & 2 on Pins 1 & 2 	(0000 0011)
PINSF_4_5			EQU		0x30		; Leds 1 & 2 on Pins 4 & 5 		(0011 0000)
	
; Blinking Frequency
TIME   				EQU     0x002FFFFF	; Fixed Value
	
	
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
		;; Enable the Port F peripheral clock by setting bit 5 (0x20 == 0b100000) (p291 datasheet de lm3s9B96.pdf)
		;; (GPIO::FEDCBA)
		ldr R5, = SYSCTL_PERIPH_GPIOF  			;; RCGC2
        mov R9, #0x00000038  					;; Enable clock sur GPIO F E D (0011 1000)
		;; (GPIO::FEDCBA)
        str R9, [R5]
		;; "There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)
		nop	   									;; very important...
		nop	   
		nop	   									;; not necessary in simulation or in debbug step by step...

		;;----------------------CONF_LEDS
		ldr R9, = PINSF_4_5
        ldr R5, = GPIO_PORTF_BASE+GPIO_O_DIR   
        str R9, [R5]
        ldr R5, = GPIO_PORTF_BASE+GPIO_O_DEN
        str R9, [R5]
		ldr R5, = GPIO_PORTF_BASE+GPIO_O_DR2R		
        str R9, [R5] 
		mov R2, #PINSF_4_5 ; LEDS values   
		ldr R5, = GPIO_PORTF_BASE + (PINSF_4_5<<2) ; Turn on LEDS that correspond to portF broches 4 & 5 values   
		;;----------------------END_CONF_LEDS

		;;----------------------CONF_SWITCHS
		ldr R9, = PINSD_6_7
		ldr R7, = GPIO_PORTD_BASE+GPIO_O_DEN
		str R9, [R7]
		ldr R7, = GPIO_PORTD_BASE+GPIO_O_PUR	
		str R9, [R7]
		ldr R7, = GPIO_PORTD_BASE + (PINSD_6_7<<2) 
		;;----------------------END_CONF_SWITCHS

		;;----------------------CONF_BUMPERS
		ldr R9, = PINSE_1_2
		ldr R8, = GPIO_PORTE_BASE+GPIO_O_DEN
		str R9, [R8]
		ldr R8, = GPIO_PORTE_BASE+GPIO_O_PUR	
		str R9, [R8]
		ldr R8, = GPIO_PORTE_BASE + (PINSE_1_2<<2) 
		;;----------------------END_CONF_BUMPERS

		;;----------------------CONF_MOTORS
		BL	MOTEUR_INIT ; Setup PWM + GPIO
		BL	MOTEUR_DROIT_ON ; Turn on right motor
		BL	MOTEUR_GAUCHE_ON ; Turn on left motor
		;;----------------------END_CONF_MOTORS 

MAIN_LOOP
		B 	GET_ENTRIES
END_GET_ENTRIES
		
		B	CHECK_SWITCHS
END_CHECK_SWITCHS
		CMP R10, #0x80 ; Si classique mode
		BEQ classic_mode
		CMP R10, #0x40 ; Si labyrinthe mode
		BEQ labyrinthe_mode
classic_mode
		B	CHECK_BUMPERS_CLASSIQUE
END_CHECK_BUMPERS_CLASSIQUE
		B end_choose_mode
labyrinthe_mode
		B	CHECK_BUMPERS_LABYRINTHE
END_CHECK_BUMPERS_LABYRINTHE
		B end_choose_mode

end_choose_mode


		B	BLINKING_LEDS
END_BLINKING_LEDS

		b	MAIN_LOOP
		
;;-------------------------------------------------------------------------------------------------
;;---------------------------------------	  FUNCTIONS		---------------------------------------
;;-------------------------------------------------------------------------------------------------	
; Waiting Loop
WAIT	
		LDR R9, =TIME  
wait1	SUBS R9, #0x01
		BNE wait1
		BX	LR	
;----------------------Get Environnement Entries (Update Switchs & Bumpers Values)
GET_ENTRIES
	ldr R3, [R7]							;; Get Switchs Entries Values
	ldr R4, [R8]							;; Get Bumper Entries Values
	B END_GET_ENTRIES
;----------------------BLINKING LED
BLINKING_LEDS
	MOV R9, #0x00
	str R9, [R5]    	;; Turn off LEDS with 0x00  
	BL	WAIT
	str R2, [R5] 		;; Turn on LEDS that correspond to portF broche 4 & 5 values : 00110000 => R2
	BL WAIT
	B END_BLINKING_LEDS
;----------------------CHECK SWITCHS
CHECK_SWITCHS
	CMP R3, #0x80 ;=> SWITCH 1
	BEQ	switch1
    CMP R3, #0x40 ;=> SWITCH 2
	BEQ	switch2
	B END_CHECK_SWITCHS
switch1				; Mode de fonctionnement Classique
	MOV R10, #0x80
	B END_CHECK_SWITCHS
switch2				; Mode de fonctionnement Labyrinthe
	MOV R10, #0x40
	B END_CHECK_SWITCHS
;----------------------CHECK_BUMPERS_CLASSIQUE
CHECK_BUMPERS_CLASSIQUE
		CMP R4, #0x01
		BEQ	c_bumper_gauche
		
		CMP R4, #0x02
		BEQ	c_bumper_droit
	
		CMP R4, #0x03
		BEQ	c_bumper_not_pressed
		
		BL	WAIT
		
		CMP R4, #0x00
		BEQ	c_all_bumpers
		
		B	END_CHECK_BUMPERS_CLASSIQUE
c_bumper_not_pressed
		MOV R2, #0x00; on reset les leds
		B 	END_CHECK_BUMPERS_CLASSIQUE
c_bumper_droit
		MOV R2, #0x10
		B	END_CHECK_BUMPERS_CLASSIQUE
c_bumper_gauche
		MOV R2, #0x20
		B	END_CHECK_BUMPERS_CLASSIQUE 
c_all_bumpers
		MOV R2, #0x30
		B	END_CHECK_BUMPERS_CLASSIQUE
;----------------------CHECK_BUMPERS_LABYRINTHE
CHECK_BUMPERS_LABYRINTHE
		CMP R4, #0x01
		BEQ	l_bumper_gauche
		
		CMP R4, #0x02
		BEQ	l_bumper_droit
	
		CMP R4, #0x03
		BEQ	l_bumper_not_pressed
		
		BL	WAIT
		
		CMP R4, #0x00
		BEQ	l_all_bumpers
		
		B	END_CHECK_BUMPERS_LABYRINTHE
l_bumper_not_pressed
		MOV R2, #0x00; on reset les leds
		B GO_FRONT
END_GO_FRONT
		B 	END_CHECK_BUMPERS_LABYRINTHE
l_bumper_droit
		MOV R2, #0x10
		B GO_RIGHT
END_GO_RIGHT
		B	END_CHECK_BUMPERS_LABYRINTHE
l_bumper_gauche
		MOV R2, #0x20
		B GO_LEFT
END_GO_LEFT
		B	END_CHECK_BUMPERS_LABYRINTHE
l_all_bumpers
		MOV R2, #0x30
		B GO_BACK
END_GO_BACK
		B	END_CHECK_BUMPERS_LABYRINTHE
;----------------------GO FRONT		
GO_FRONT
		BL	MOTEUR_DROIT_AVANT	   
		BL	MOTEUR_GAUCHE_AVANT
		B END_GO_FRONT
;----------------------GO BACK
GO_BACK
		BL	MOTEUR_DROIT_ARRIERE	   
		BL	MOTEUR_GAUCHE_ARRIERE
		B END_GO_BACK
;----------------------GO LEFT
GO_LEFT
		BL	MOTEUR_DROIT_AVANT	   
		BL	MOTEUR_GAUCHE_ARRIERE
		B END_GO_LEFT
;----------------------GO RIGHT
GO_RIGHT
		BL	MOTEUR_DROIT_ARRIERE	   
		BL	MOTEUR_GAUCHE_AVANT
		B END_GO_RIGHT
;;-------------------------------------------------------------------------------------------------
;;---------------------------------------	END FUNCTIONS	---------------------------------------
;;-------------------------------------------------------------------------------------------------
		;; retour à la suite du lien de branchement
		BX	LR

		NOP
        END
			
			
	