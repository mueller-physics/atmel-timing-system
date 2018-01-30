---
layout: default
title: ATMEL avr timing system
---

## Arduino / ATMEL AVR timing System

Goal:
* use an Arduino (or, any AVR) to synchronize equipment with high, repeatable precision ( microseconds )
* avoid need to re-flash the micro-controller every time

Approach:
* send a list of commands
* have some code iterate that list and execute it (interpreter)
* make this code have deterministic runtime (cycle count) for each command

State:
* Core functionality (interpreter for a few commands) seems to work
* More testing is needed, maybe unit tests w. simavr?
* Tested both in simavr (w. gtkwave) and on real hardware
* Interpreter completely in assembler, to get exact cycle counts
* Most commands need 16 cycles (1 microsecond), quick ones 8 cycles (0.5 microseconds)

Documentation:

* early stages, not much yet
* opcodes for the interpreter [here](commands.html)





