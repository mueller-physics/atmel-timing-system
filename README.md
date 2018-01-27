
## Arduino / ATMEL Timing System

Goal:
* use an Arduino to synchronize equipment with high, repeatable precision ( microseconds )
* avoid need to re-flash the Arduino every time

Approach:
* send a list of simple commands (2-bytes each)
* have some code look iterate that list and execute it
* make this code have deterministic runtime




