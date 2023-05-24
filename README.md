Stellaris_ASM
==============================================================

Description
--------------------------------------------------------------

This project was developed as part of the architecture module in our Computer Science and Application engineering program at ESIEE-IT. Stellaris_ASM is an assembly (.s) program that enables control of a robot through two selectable movement modes using switches:

* Classic
* Labyrinth Solver

The following tools were used for the development of this program:

* Stellaris Cortex M3 Robot
* ARM Cortex M3 Assembly
* Keil uVision4

Classic Mode
--------------------------------------------------------------

* Pressing both bumpers: Turn on both LEDs and perform a U-turn.
* Pressing the right bumper: Turn on the left LED and turn left.
* Pressing the left bumper: Turn on the right LED and turn right.

Labyrinth Solver Mode
--------------------------------------------------------------

Labyrinth escape method based on the Pledge algorithm:

* If the counter is 0, move straight ahead until reaching the wall in front.
* From this wall, turn in the preferred direction (always the same, let's say left).
* Then, follow the wall by adding 1 to the counter when turning right and subtracting 1 when turning left.
* If the counter is 0, detach from the wall and move straight ahead.

Videos
--------------------------------------------------------------
https://www.youtube.com/embed/83kjO3r_M6c
https://www.youtube.com/embed/YOWi1U9MCvc

Register Usage
--------------------------------------------------------------

* R0 => RK_MOTORS

* R1 => RK_MOTORS

* R2 => LED STATE
  * Possible values:
    * 0x00 => LEDs OFF
    * 0x10 => LEFT LED
    * 0x20 => RIGHT LED
    * 0x30 => BOTH LEDs

* R3 => SWITCH STATES
  * Possible values:
    * 0x00 => SWITCHES PRESSED
    * 0x40 => SWITCH 2
    * 0x80 => SWITCH 1
    * 0xC0 => SWITCHES NOT PRESSED

* R4 => BUMPER STATES
  * Possible values:
    * 0x00 => BUMPERS PRESSED
    * 0x01 => LEFT BUMPER
    * 0x02 => RIGHT BUMPER
    * 0x03 => BUMPERS NOT PRESSED
	
* R5 => @ LED MEMORY

* R6 => @ RK_MOTORS MEMORY

* R7 => @ SWITCH MEMORY
  
* R8 => @ BUMPER MEMORY

* R9 => LOOP COUNT FOR WAIT FUNCTION

* R10 => VALUE CORRESPONDING TO THE SELECTED GAME MODE

* R11 => NUMBER OF LOOPS FOR 90° ROTATION

* R12 => DISTANCE TRAVELED FORWARD BEFORE IMPACT (DISTANCE TO TRAVEL IN REVERSE)
