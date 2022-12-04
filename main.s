;------------------------------------------------------------
; RK - Evalbot (Cortex M3 de Texas Instrument)
;------------------------------------------------------------
; AUTHORS - Arthur PELLEGRINI & Clément BRISSARD -- ESIEE-IT
;------------------------------------------------------------

		AREA    |.text|, CODE, READONLY
			
; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIOF EQU		0x400FE108	;; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; Configure the corresponding pin to be an output
; All GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ;; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ;; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN   		EQU 	0x0000051C  ;; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; The GPIOPUR register is the pull-up control register
GPIO_O_PUR			EQU		0x00000510 	;; GPIO Pull-Up Control

; The GPIODATA register is the data register
GPIO_PORTD_BASE		EQU		0x40007000	;; GPIO Port D (APB) base: 0x4000.7000
GPIO_PORTE_BASE		EQU		0x40024000	;; GPIO Port E (APB) base: 0x4002.4000
GPIO_PORTF_BASE		EQU		0x40025000	;; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; PINS Port Input
PINSD_6_7			EQU		0xC0		;; Switchs 1 & 2 on Pins 6 & 7	(1100 0000)
PINSE_1_2			EQU		0x03		;; Bumpers 1 & 2 on Pins 1 & 2 	(0000 0011)
PINSF_4_5			EQU		0x30		;; Leds 1 & 2 on Pins 4 & 5 	(0011 0000)
	
; CONSTANTS
WAIT_ITERATIONS   		EQU     0x00FFFFF	;; Number of iterations to complete a wait
ROTATION_ITERATIONS		EQU		0x0D		;; Number of iterations to complete a rotation
DISTANCE_ITERATIONS		EQU		0x19		;; Number of iterations to complete a distance
	
	ENTRY
	EXPORT	__main
	
	;; The IMPORT command specifies that a symbol is defined in a shared object at runtime.
	IMPORT	MOTEUR_INIT					;; init motors (setup PWMS + GPIO)
	
	IMPORT	MOTEUR_DROIT_ON				;; enable right motor
	IMPORT  MOTEUR_DROIT_OFF			;; disable right motor
	IMPORT  MOTEUR_DROIT_AVANT			;; right motor turns forward
	IMPORT  MOTEUR_DROIT_ARRIERE		;; right motor turns backwards
	IMPORT  MOTEUR_DROIT_INVERSE		;; reverses the right motor's rotation direction
	
	IMPORT	MOTEUR_GAUCHE_ON			;; enable left motor
	IMPORT  MOTEUR_GAUCHE_OFF			;; disable left motor
	IMPORT  MOTEUR_GAUCHE_AVANT			;; left motor turns forward
	IMPORT  MOTEUR_GAUCHE_ARRIERE		;; left motor turns backwards
	IMPORT  MOTEUR_GAUCHE_INVERSE		;; reverses the left motor's rotation direction

__main	
	;; Enable the Port F peripheral clock by setting bit 5 (0x20 == 0b100000) (p291 datasheet de lm3s9B96.pdf)
	;; (GPIO::FEDCBA)
	LDR R5, =SYSCTL_PERIPH_GPIOF  	;; RCGC2
	MOV R9, #0x00000038  			;; Store value to Enable clock on GPIO F, E and D (0011 1000)
	;; (GPIO::FEDCBA)
	STR R9, [R5]					;; Enable clock on GPIO F, E and D
	;; "There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)
	NOP	   							;; very important...
	NOP	   
	NOP	   							;; not necessary in simulation or in debbug step by step...

	;;----------------------CONF_SWITCHS
	LDR R9, =PINSD_6_7							;; Get the value to enable PINS 6 & 7 on PORTD
	LDR R7, =GPIO_PORTD_BASE+GPIO_O_DEN			;;
	STR R9, [R7]								;; Enable PINS 6 & 7 on PORTD with GPIO_O_DEN		
	LDR R7, =GPIO_PORTD_BASE+GPIO_O_PUR			;;
	STR R9, [R7]								;; Enable PINS 6 & 7 on PORTD with GPIO_O_PUR
	LDR R7, =GPIO_PORTD_BASE+(PINSD_6_7<<2) 	;; Enable Switchs that correspond to PORTD PINS 6 & 7 values
	;;----------------------END CONF_SWITCHS

	;;----------------------CONF_BUMPERS
	LDR R9, =PINSE_1_2							;; Get the value to enable PINS 1 & 2 on PORTE
	LDR	R8, =GPIO_PORTE_BASE+GPIO_O_DEN			;;
	STR R9, [R8]								;; Enable PINS 1 & 2 on PORTE with GPIO_O_DEN
	LDR R8, =GPIO_PORTE_BASE+GPIO_O_PUR			;;
	STR R9, [R8]								;; Enable PINS 1 & 2 on PORTE with GPIO_O_PUR
	LDR R8, =GPIO_PORTE_BASE+(PINSE_1_2<<2) 	;; Enable Bumpers that correspond to PORTE PINS 1 & 2 values
	;;----------------------END CONF_BUMPERS

	;;----------------------CONF_LEDS
	LDR	R9, =PINSF_4_5							;; Get the value to enable PINS 4 & 5 on PORTF
	LDR R5, =GPIO_PORTF_BASE+GPIO_O_DIR   		;; 
	STR R9, [R5]								;; Enable PINS 4 & 5 on PORTF with GPIO_O_DIR
	LDR R5, =GPIO_PORTF_BASE+GPIO_O_DEN			;;
	STR R9, [R5]								;; Enable PINS 4 & 5 on PORTF with GPIO_O_DEN
	LDR R5, =GPIO_PORTF_BASE+GPIO_O_DR2R		;;
	STR R9, [R5] 								;; Enable PINS 4 & 5 on PORTF with GPIO_O_DR2R   
	LDR R5, =GPIO_PORTF_BASE+(PINSF_4_5<<2) 	;; Enable LEDS that correspond to PORTF PINS 4 & 5 values 
	;;----------------------END CONF_LEDS

	;;----------------------CONF_MOTORS
	BL	MOTEUR_INIT 			;; Setup PWM + GPIO
	BL	MOTEUR_DROIT_ON 		;; Turn on right motor
	BL	MOTEUR_GAUCHE_ON 		;; Turn on left motor
	BL	MOTEUR_DROIT_AVANT	   	;; Set front direction for right motor
	BL	MOTEUR_GAUCHE_AVANT		;; set front direction for left motor
	;;----------------------END CONF_MOTORS

	MOV R10, #0x40	;; Setup R10 with value for the default mode : 0x80 for Classic mode 
					;;											&& 0x40 for Labyrinth mode

main_loop
	LDR R3, [R7]			;; Get Switchs Entries Values
	LDR R4, [R8]			;; Get Bumper Entries Values
	
;----------------------CHECK SWITCHS STATUS
	CMP R3, #0x00 			;; If all the switchs are pressed
	BEQ	end_check_switchs	;; Jump to end_switchs
	CMP R3, #0xC0 			;; If no switchs are pressed
	BEQ	end_check_switchs	;; Jump to end_switchs
	MOV	R10, R3				;; Store in R10 the value of the pressed switch
end_check_switchs	
;----------------------END CHECK SWITCHs STATUS

;----------------------CHOOSE MODE
	CMP R10, #0x80 			;; If Switchs Status == Classic mode
	BEQ classic_mode		;; Go to Classic mode branch
	CMP R10, #0x40 			;; If Switchs Status == Labyrinth mode
	BEQ labyrinth_mode		;; Go to Labyrinth mode branch

;----------------------Classic mode
classic_mode
	BL	WAIT 					;; Wait for few iterations to tempo the programm
	CMP R4, #0x01				;; R4 == 0x01
	BEQ	c_left_bumper			;; If left bumper pressed then go to c_left_bumper branch
	CMP R4, #0x02				;; R4 == 0x02
	BEQ	c_right_bumper			;; If right bumper pressed then go to c_right_bumper branch
	CMP R4, #0x03				;; R4 == 0x03
	BEQ	c_bumpers_not_pressed	;; If bumpers not pressed then go to c_bumpers_not_pressed branch
	CMP R4, #0x00				;; R4 == 0x00
	BEQ	c_all_bumpers_pressed	;; If all bumpers pressed then go to c_all_bumpers_pressed branch
c_left_bumper					
	MOV R2, #0x20				;; Change LEDS values to turn on only left LED
	BL	MOTEUR_DROIT_AVANT	   	;; Set front direction for right motor
	BL	MOTEUR_GAUCHE_ARRIERE	;; Set back direction for left motor
	B	end_choose_mode 		;; Go to end_choose_mode branch
c_right_bumper
	MOV R2, #0x10				;; Change LEDS values to turn on only right LED
	BL	MOTEUR_DROIT_ARRIERE	;; Set back direction for right motor
	BL	MOTEUR_GAUCHE_AVANT		;; Set front direction for left motor
	B	end_choose_mode			;; Go to end_choose_mode branch
c_bumpers_not_pressed
	MOV R2, #0x00				;; Change LEDS values to turn off LEDS
	BL	MOTEUR_DROIT_AVANT	   	;; Set front direction for right motor 
	BL	MOTEUR_GAUCHE_AVANT		;; Set front direction for left motor	
	B 	end_choose_mode			;; Go to end_choose_mode branch
c_all_bumpers_pressed					
	MOV R2, #0x30				;; Change LEDS values to turn on all LEDS
	BL	MOTEUR_DROIT_ARRIERE	;; Set back direction for right motor 
	BL	MOTEUR_GAUCHE_ARRIERE	;; Set back direction for left motor
	B end_choose_mode			;; Go to end_choose_mode branch

;----------------------Labyrinth mode
labyrinth_mode
	BL	WAIT						;; Wait for few iterations to tempo the programm
	MOV R2, #0x30					;; Change LEDS values to turn on all LEDS
	CMP	R4, #0x03 					;; R4 == 0x03
	BEQ	algo_res					;; If bumpers not pressed then go to algo_res branch
	B end_choose_mode				;; Else go to end_choose_mode branch

algo_res 
;; Right 90° Rotation
	LDR	R11, =ROTATION_ITERATIONS	;; Init R11 with the number of iterations needed to do a 90° rotation

right_rotation
	BL	MOTEUR_DROIT_ARRIERE		;; Set back direction for right motor 
	BL	MOTEUR_GAUCHE_AVANT			;; Set front direction for left motor
	BL	WAIT						;; Wait for few iterations to tempo the programm
	SUBS	R11, #0x01				;; R11 = R11 - 0x01
	BNE	right_rotation				;; If R11 != 0x00 go to right_rotation branch
;; End Right 90° Rotation

go_forward
;; Go Forward
	LDR	R11, =DISTANCE_ITERATIONS	;; Init R11 with the number of iterations needed to do a distance
	MOV	R12, #0x00					;; Init R12 with 0x00
go_forward_loop
	BL	MOTEUR_DROIT_AVANT	   		;; Set front direction for right motor 
	BL	MOTEUR_GAUCHE_AVANT			;; Set front direction for left motor 
	BL	WAIT						;; Wait for few iterations to tempo the programm
	ADD	R12, #0x01					;; Incrementing R12 (Contains the number of iterations performed in real time)
	LDR R4, [R8]					;; Get Bumper Entries Values
	CMP R4, #0x03					;; Bumpers Status == Bumpers not pressed
	BNE	actives_bumpers				;; If not equal go to actives_bumpers branch
	SUBS	R11, #0x01				;; R11 = R11 - 0x01
	BNE	go_forward_loop				;; If R11 != 0x00 go to go_forward_loop
;; End Go Forward

	B end_choose_mode				;; Go to end_choose_mode branch
actives_bumpers	
	
;; Go Backwards
go_backwards
	BL	MOTEUR_DROIT_ARRIERE	   	;; Set back direction for right motor
	BL	MOTEUR_GAUCHE_ARRIERE		;; Set back direction for left motor
	BL	WAIT						;; Wait for few iterations to tempo the programm	
	SUBS	R12, #0x01				;; R12 = R12 - 0x01
	BNE	go_backwards				;; If R12 != 0x00 go to go_backwards branch
;; End Go Backwards	

;; Left 90° Rotation
	LDR	R11, =ROTATION_ITERATIONS	;; Init R11 with the number of iterations needed to do a 90° rotation

left_rotation
	BL	MOTEUR_DROIT_AVANT	   		;; Set front direction for right motor 
	BL	MOTEUR_GAUCHE_ARRIERE		;; Set back direction for left motor
	BL	WAIT						;; Wait for few iterations to tempo the programm
	SUBS	R11, #0x01				;; R11 = R11 - 0x01
	BNE	left_rotation				;; If R11 != 0x00 go to left_rotation
;; End Left 90° Rotation

	B go_forward					;; Go to go_forward branch

end_choose_mode
;----------------------END CHOOSE MODE

;----------------------BLINKING LED
	MOV R9, #0x00		;; 0x00 --> LEDS Off Value
	STR R9, [R5]    	;; Turn off LEDS with 0x00  
	BL	WAIT			;; Wait between LEDS on/off 
	STR R2, [R5] 		;; Turn on LEDS that correspond to portF broche 4 & 5 values : 00110000 => R2
;----------------------END BLINKING LED

	b	main_loop		;; Return to the beginning of the main loop
	BX	LR				;; Back to the continuation of the connection link

;----------------------Function Wait (Iterates to WAIT_ITERATIONS out)
WAIT	LDR R9, =WAIT_ITERATIONS  	;; Initialization of the number of loop turns
wait_loop 	SUBS R9, #0x01			;; R9 - 0x01
		BNE wait_loop				;; As long as R9 != 0 return to wait_loop
		BX	LR						;; Back to the continuation of the connection link
;----------------------END Function Wait
	NOP
    END	
	