# GracefulPSU

A 12V power supply for a Raspberry Pi or equivalent that provides
enough reserve power to allow a graceful shutdown.

## Purpose

Raspberry Pi's are marvelous little machines, but their SD cards can
be damaged if they are being written to when the power fails.

The author wanted to use a Pi alternative (Libre Computer's Le Potato)
on his sailboat and needed reliability.

A power supply that could provide enough reserve power to safely shut
down the SBC was the answer.  This project contains the circuit designs
and software to implement and use such a power supply.

## Directory Overview

### kicad Files

The circuit has been developed using Kicad V6.  All of the kicad
project files are in the `kicad` subdirectory.

The `simulation` subdirectory contains a kicad project which simulates
the Supercapacitor Backup Power, and the Power Control Enable parts of
the circuit.  Note that the simulation uses a bipolar transistor as
the author was unable to get the CSD19505 simulation to work.

This proved good enough to be able to choose component values for the
final circuit.  Note that the final circuit may have evolved slightly
from the version in the simulation.

### Circuit Diagram Image

A rendered image of the kicad circuit diagram can be found in
[`GracefulPSU.pdf`](../kicad/GracefulPSU.pdf) in the kicad directory.

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

## License

Everything is licensed under V3 of the GPL.

What this means is that you can use it freely for your own use, but if
you distribute it to others you must abide by the terms of the
license, which essentially says that you must include the same license
and grant your users the same rights that you are being granted here.

Share and Enjoy.




