Stellaris_ASM
==============================================================

Description
--------------------------------------------------------------

Ce projet a été réalisé dans le cadre du module architecture de notre formation d'ingénieur en Informatique et Application à l'ESIEE-IT. Stellaris_ASM est un programme en assembleur permettant le controle d'un robot à travers deux modes de déplacement sélectionnable à partir de ses switchs :

* mode classique
* mode sortie de labyrinthe

Voici les outils utilisés pour le développement de cette application :

* Robot Stellaris Cortex M3
* Assembleur ARM Cortex M3
* Keil uVision4

Mode de déplacement classique
--------------------------------------------------------------

* 2 bumpers pressé => allumer les deux LED et faire demi-tour
* Bumper droit pressé => allumer la LED gauche et tourner à gauche
* Bumper gauche pressé => allumer la LED droite et tourner à droite

Mode de déplacement sortie de labyrinthe
--------------------------------------------------------------

méthode d'échapatoire d'un labyrinthe issue de l'algorythme de Pledge :

* Si le compteur indique 0, on va tout droit jusqu'au mur en face.
* A partir de ce mur, on tourne du côté que l'on préfère (mais toujours le même, disons gauche).
* Ensuite on suit le mur en ajoutant 1 au compteur dès que l'on tourne à droite et en soustrayant 1 dès que l'on tourne à gauche.
* Si le compteur indique 0, on lâche le mur, et on va tout droit.

Registres utilisés
--------------------------------------------------------------

* R0 => MOTEUR

* R1 => MOTEUR

* R2 => LED ETEINTE

* R3 => ETAT LED
  * valeur possible :
    * 0X30 => LED left & LED right
    * 0X20 => LED left
    * 0X10 => LED right
    * 0X00 => LED OFF

* R4 => SWITCHS
  * valeur possible :
    * 0XC0 => SWITCH not pressed
    * 0X80 => SWITCH 1
    * 0X40 => SWITCH 2

* R5 => BUMPERS
  * valeur possible :
    * 0X00 => BUMPERS not pressed
    * 0X03 => BUMPERS pressed
    * 0X01 => BUMPER left
    * 0X02 => BUMPER right

* R6 => @ MOTEUR

* R7 => @ LEDS

* R8 => @ SWITCHS

* R9 => @ BUMPERS

* R10 => WAIT

* R11 =>  N/A

* R12 =>  N/A
