Stellaris_ASM
==============================================================

Description
--------------------------------------------------------------

Ce projet a été réalisé dans le cadre du module architecture de notre formation d'ingénieur en Informatique et Application à l'ESIEE-IT. Stellaris_ASM est un programme en assembleur (.s) qui permet le fonctionnement permettant le contrôle d'un robot à travers deux modes de déplacement sélectionnable à partir de ses switchs :

* Classique
* Résolution Labyrinthe

Voici les outils utilisés pour le développement de ce programme :

* Robot Stellaris Cortex M3
* Assembleur ARM Cortex M3
* Keil uVision4

Mode Classique
--------------------------------------------------------------

* 2 bumpers pressé => allumer les deux LED et faire demi-tour
* Bumper droit pressé => allumer la LED gauche et tourner à gauche
* Bumper gauche pressé => allumer la LED droite et tourner à droite

Mode Résolution de labyrinthe
--------------------------------------------------------------

Méthode d'échapatoire d'un labyrinthe issue de l'algorithme de Pledge :

* Si le compteur indique 0, on va tout droit jusqu'au mur en face.
* A partir de ce mur, on tourne du côté que l'on préfère (mais toujours le même, disons gauche).
* Ensuite on suit le mur en ajoutant 1 au compteur dès que l'on tourne à droite et en soustrayant 1 dès que l'on tourne à gauche.
* Si le compteur indique 0, on lâche le mur, et on va tout droit.

Utilisation des Registres
--------------------------------------------------------------

* R0 => RK_MOTORS

* R1 => RK_MOTORS

* R2 => ETAT LED
  * Valeur Possibles :
    * 0x00 => LEDS ÉTEINTES
    * 0x10 => LED DROITE
    * 0x20 => LED GAUCHES
    * 0x30 => LEDS

* R3 => ETATS SWITCHS
  * Valeurs Possibles :
    * 0x00 => SWITCHS PRESSÉS
    * 0x40 => SWITCH 2
    * 0x80 => SWITCH 1
    * 0xC0 => SWITCHS NON PRESSÉS

* R4 => ETATS BUMPERS
  * Valeurs Possibles :
    * 0x00 => BUMPERS PRESSÉS
    * 0x01 => BUMPER GAUCHE
    * 0x02 => BUMPER DROIT
    * 0x03 => BUMPERS NON PRESSÉS

* R5 => @ MEMOIRE LEDS

* R6 => @ MEMOIRE RK_MOTORS

* R7 => @ MEMOIRE SWITCHS
  
* R8 => @ MEMOIRE BUMPERS

* R9 => NOMBRE TOURS BOUCLE POUR FONCTION WAIT

* R10 => VALEUR CORRESPONDANTE AU MODE DE JEU SÉLECTIONNÉ

* R11 => NOMBRE TOURS POUR ROTATION 90° & DISTANCE AVANT & ARRIERE

* R12 => DISTANCE AVANT PARCOURUE AVANT IMPACT (DISTANCE À PARCOURIR DANS LE SENS INVERSE)
