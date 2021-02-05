# Std-Signal-Generator

This project is a standard signal generator.
Sine, rising sawtooth, falling sawtooth, and square wave are supported.
The generator has 5 channels (1st channel - reference phase; 2nd channel - 45 degrees phase shift; 3rd channel - 90 degrees phase shift; 4th channel - 180 degrees phase shift; 5th channel - programmable phase shift, step size - 360/256 degrees).
The output swing is approximately 3.3 V.
The generator sends data to AD7303 DACs via SPI interface.
This project can be fit into a 256 macrocell CPLD.
The source code was written in VHDL (~700 sloc).
The design is completed.
All known bugs were fixed.
