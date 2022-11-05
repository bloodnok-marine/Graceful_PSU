# GracefulPSU

A 12V power supply for a Raspberry Pi or equivalent that provides
enough reserve power to allow a graceful shutdown.

## Purpose

Raspberry Pi's are marvelous little machines, but their SD cards can
be damaged if they are being written to when the power fails.

This project provides a Pi or equivalent enough time to safely shut
doen when input power is removed in order to reduce the risk of SSD
corruption.

The project contains the circuit designs and software to implement and
use such a power supply. 

## Directory Overview

### kicad Files

The circuit has been developed using Kicad V6.  All of the kicad
project files are in the `kicad` subdirectory.

The `simulation` subdirectory contains a kicad project which simulates
the Supercapacitor Backup Power, and the Power Control Enable parts of
the circuit.  

### Circuit Diagram Image

A rendered image of the kicad circuit diagram can be found in
[`schematic.pdf`](../schematic.pdf) in the root directory.

### Gerber Files

A full set of gerber files for the PCB can be found in
`kicad/pcbfiles`.  These were generated for
[JLCPCB](https://jlcpcb.com) which creates fine pcbs at a reasonable
price.

### Circuit Description

A description of the circuit can be found in
[`docs/psu.md`](./psu.md).

### Software

To follow.

## Licensing

All software is licensed under V3 of the GPL.  A copy of this license
is provided in the root directory of this project.

All electronic circuit schematics and PCB designs are made available
under the generic Creative Commons Attribution License version 2:
[https://creativecommons.org/licenses/by/2.0/].

What this means is that you can use the circuits and software freely
for your own use, but if you distribute it to others you must abide by
the terms of the licenses.

Share and Enjoy.

## About Bloodnok Marine

Bloodnok Marine provides free software, circuit schematics and PCB
designs for various items of marine electronics.  Use them at your own
risk: there is no warranty provided or implied.





