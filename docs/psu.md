# Graceful Power Supply Controller

This is a graceful-shutdown power supply for a Raspberry Pi or
similar Single Board Computer (SBC) that provides enough backup power
to gracefully shut down the computer in the event of loss of power.

It has 3 major functions:

1) Provide short term backup power when input power is lost.

   A supercapacitor provides enough power to allow time for a clean
   shutdown. 

2) Provide software and push-button control of power.

   This allows the computer to be turned on by a short button press
   and the power removed by a long press.  It also allows the computer
   to turn off the power itself, and allows it to monitor the button
   state.

3) Provide a regulated 5V supply from an unregulated ~12V supply.

## Circuit Operation Overview

Note that components marked with an asterisk (*) are optional.  The
optionality of these components is decribed in the appropriate part of
the Detailed Circuit Description below.

The circuit consists of a number of distinct stages.

### Power Input

Power input can come from either 1 or 2 sources.  This allows the SBC
to be used for distinct purposes depending on which power sources are
activated.  Specifically, this is designed for use on a boat, where
the SBC can be used for navigation and for entertainment, and may be
powered from 2 distinct breaker switches (eg, instruments and
accessories).

### Supercapacitor Charger

Capacitor C5 provides enough capacity when charged to run the SBC for
30 seconds or more, giving it ample time to safely shut down.

The charger circuit around U1B and Q1 ensures that the capacitor is
charged relatively slowly, to reduce input current, and that charging
commences quickly so that if the capacitor is already part-charged,
charging time is reduced.

### Power Control Enable

U1A senses when C5 is sufficiently charged and switches low, allowing
the Power Control Latch to be triggered.

### Power Control Latch

This switches power to the 5V regulator stage.  Once turned on, it
stays on until actively disabled.

### 5V Regulator

This consists of either U2, C10, C11, C12, C13, D14, L1, R30
and R31, or a separate psu board B1.  The PCB is designed to accomodate this 
[board from
AliExpress](https://www.aliexpress.com/item/1005006117113975.html?spm=a2g0o.productlist.main.51.7cfe65c4Qg5Jcy&algo_pvid=c19da571-4f8f-49f4-b4a3-435c7f6b84c2&algo_exp_id=c19da571-4f8f-49f4-b4a3-435c7f6b84c2-25&pdp_npi=4%40dis%21USD%218.50%212.79%21%21%2160.90%2119.98%21%402103250717087974209674599e6e2d%2112000035826812826%21sea%21CA%21927347991%21&curPageLogUid=pgyUCSDpvaOo&utparam-url=scene%3Asearch%7Cquery_from%3A).
Other boards may be used but may not solder directly to the PCB.

The alternative regulator built using discrete components should work
fine, but may be more expensive to build.

U2 is a 5V buck-convertor regulator.  This should provide a clean 5V
supply to the SBC at up to about 5A.

### Power Sensing

In order to detect when power has been removed from the circuit, power
input is divided down to a suitable level for detection by GPIO pins
on the SBC.  Additional GPIOs are used to detect use of the power
switch, and to send a disable signal to the power control latch, to
turn off the 5V regulator.

## Detailed Circuit Description

### Power Input

The circuit is designed to allow 2 independent 12V power inputs.  This
allows the SBC, for usage on a boat, to be powered by independent
circuit breakers: 1 for accessories allowing it to be used as an
entertainment system; and 1 for instruments allowing it to be used for
navigation.

Schottky diodes D6 and D8 carry the power to the supercapacitor from
each input source (J1 and J2), preventing one source from feeding
power into the other and preventing our backup power feeding back to
the source.  Schottky diodes are used to minimise the power loss
due to voltage drop.

D3, D4 and D6 provide power to the Supercapacitor Charger control
circuit.  D6 isolates C2 from R16 so that when input power is lost,
the voltage at R16 drops immediately.

The rate of charge of C2 limits the charging of C5.  Normally, C2 is
charged only through R4, but if C2 has been discharged and there is
charge on C5, U1B's output will be low and C2 will be fast-charged
from the low output of U1b via R2, D9 and D10.  This allows C2 to
quickly charge to the point that C5 will resume charging.

If only a single input source is required J2 may be ignored and D3 and
D8 may be omitted.

### Power Sensing

Sense input is provided to GPIO pins (header pins 29 and 31 by
default) to allow the SBC to determine whether, and which, inputs are
providing power. 

If only a single power source is needed D1, R1, R5, C1 and JP2 can be
ommitted, and D2 may be replaced with a wire link.

The SBC must monitor the pins connected to JP1 and JP2 in order to
identify when input power has been lost and automatically shut down.

### Supercapacitor Charger

This part of the circuit:

- limits the charge current for the supercapacitor, C5, to avoid a
  large current spike when power is connected;
- ensures that the supercapacitor fully charges;
- allows current to flow from the supercapacitor unimpeded when
  input power is removed;
- ensures that C2, which regulates charging, quickly charges to the
  point where the supercapacitor will start charging.

In order to minimise any current spikes when power is applied, the
charging of the supercapacitor is controlled by the rate of charge of
C2.  As C2 charges, Q1 is turned on to charge the supercapacitor, C5.
As this charges, the voltage at the non-inverting input of U1B drops,
lowering its output voltage and so reducing the current through
Q1.  The voltage, and level of charge, of C5 therefore follows the
voltage across C2.  So, to control the charge current into C5, we
control the charge time of C2.

There are 2 distinct modes of charging for C2.   It is fast-charged
when the output of U1B is low via R9, D9 and D10.  This rapidly brings
C2 to a state of charge where C5 can begin being charged.  After this
point, once U1B's output rises above about 5V, all of the charge
current is delivered through R4, whose value determines the remaining
rate of charge.

When power is removed from the circuit, C2 is rapidly discharged via R2
and D5.  If power is then reapplied, C2 will again be fast-charged
by U1B until it is close to the threshold to begin charging C5.

C5 will not charge until U1B's output is above around 4V, the sum of
the "on-voltage" for Q1 (approx 2.2V) and the 1.8V dropped across D11.
The 2 zeners, D9 and D11, provide hysteris, ensuring that U1B can only be
charging either C2 or C5 at any given time.

R12 provides feedback from the charge level of C5 to ensure that its
charge rate follows that of C2.  The combination of negative feedback
(R6, R11), positive feedback (R12) and biasing (R7, R8) was arrived at
mostly through simulation and then verification with a prototype.
Although these values are not super-critical, varying any of them
tends to have multiple effects; so modify them with care.

The final feature of this part of the circuit is that when input power
is removed, U1B's output goes high, to the rail voltage, ensuring that
Q1 is turned fully on so that C5 may properly power the voltage
regulator.  Without this, all of C5's discharge current would flow
through Q1's body diode which is not rated for high currents.

#### Charging Time and Current

The supercapacitor module I used could be found at
Amazon (search for 1.6F supercapacitor).  Alternative products and
sources no doubt exist. 

The charge current for the supercapacitor is given by the formula:

    I = C * V / t

where C is the capacitance, V is the voltage to which it is to be
charged, and t is the time taken to charge.

With the circuit as given, the full charge time (for 12V) is around 8
seconds, which gives us 1.6 * 12 / 8 = 2.4 Amp.

The Schottky diodes are rated at 4A, so using any larger
supercapacitor may require circuit modification to limit the charge
current.  This can be done by increasing the value of C2 and/or R4,
though changing R4 may require also changing R6 and R11. 

### Power Control Enable

We want the supercapacitor to be near-fully charged before we allow
the SBC to be powered on.

U1A forms a Schmitt trigger.  With the supercapacitor discharged, the
output will be high.  When C5 is sufficiently charged, the output will
very quickly switch to low.  With C6 in place, this will switch on the
power control latch.  C6 may be omitted if automatic switch-on is not
required.

Note that the push-switch across J7 and J8 is not enabled until U1A's
output is low. 

When the Power Control Latch is off, and input power is removed, U1A's
output will be sent high as its inverting input voltage drops to 0V.
This disables the power switch.

When the latch is on, R25 and D13 bring U1A's non-inverting
input to a high voltage, ensuring its output remain low, keeping the
power switch enabled, allowing it to be used to switch off power.

### Power Control Latch

This section of the circuit is from [Mosaic Industries](http://www.mosaic-industries.com/embedded-systems/microcontroller-projects/raspberry-pi/on-off-power-controller).

The MOSFET pair of Q2 form a latching circuit that provides power to a
5V regulator.

When power is first applied to J1 or J2 the gate of Q2B is driven
high, via R21, causing it to not conduct.  Q2A's gate will be drawn
low at this point (via R26 and R28) keeping Q2A switched-off.

To turn on Q2B, the voltage at its gate must be lowered.  This can be
done by momentarily closing the contacts of a switch across J7 and J8
(when U1A's output is low) which will, momentarily  via C7, bring
Q2B's gate low, turning on the latch.  R24 is of too high a value to
affect this, but is required in order to subsequently discharge C7.

Once Q2B turns on, Q2A's gate is drawn high, via R26 and R27, turning
it on, and forcing Q2B's gate low which keeps it conducting.

To turn off the power, the gate voltage at Q2A must be brought low.

This can be done in 3 ways:

1) by setting the GPIO line connected to JP4 low;
2) by holding down the switch across J7 and J8 for several seconds;
3) by setting the GPIO line connected to JP3 low and waiting for
   several seconds.

In each case, this charges C8, via R26, eventually bringing Q2A's gate
voltage low enough to switch it off.

Note that the same GPIO line from JP3 may also be used to monitor the
push button to allow software controlled power-down of the SBC.

If you have enough GPIOs to spare, you should use the line connected
to JP4 to switch off the power supply as it will switch off more
quickly.  If not, you can remove JP4 and R29, and use the GPIO
connected to JP3.  Note that in this case you may have to switch that
GPIO from being an input, used to detect the pressing of the power
button (across J7, J8), to an output.

### 5V Regulator

5V for the SBC is provided by a buck convertor.  This part of the
circuit was generated by Texas Instruments' WEBENCH tool.

Q3 provides an unbacked-up 5V supply.  When input power is
disconnected Q3 will no longer conduct.  This is intended for
peripherals such as monitors that need not be powered during the
shutdown of the computer.  If this is not required, Q3 can be omitted.

## Choice of Components

Many of the components were chosen based on availability from the
designer's parts drawer.

### MOSFETS

Q1 and Q2 are CSD19505KCS MOSFETs.  These are high-current devices
with very low on resistance.  The designer has a drawer of these.  Any
N-channel MOSFET with very low on resistance, rated for 20V or more
and 10A or more should be quite adequate.

### Schottky Diodes

SS54s were cheap and available.  Almost any alternative rated at 4A or
more should be fine.

### Op-amp

This needs to be a an op-amp with rail-to-rail, push-pull outputs.  In
order to be able to detect the push switch using a gpio pin the output
has to be driven very close to 0V.  If you use a "ready" LED across J6 and
J9, this op-amp must also be able to sink a few milliamps while
keeping the output close to 0V.  Not all rail-to-rail op-amps can do
this.  The TLV9152 was cheaply available.

### Dual MOSFET

The IRF7319 was chosen simply because it was suggested by Mosaic
Industries, the designers of the Power Control Latch.  Other
alternatives would probably be fine or better.

### Supercapacitor

1.6F has proven to be pretty adequate.  A higher value could be
substituted but beware the charging current that would be needed.  You
might get away with as little as 1F.  Or you might not.

### Buck Convertor

All sorts of alternatives probably exist.  The LM22678TJ-ADJ has been
tried and tested and seems to be reliable.

### Inductor

Any 8A low impedence 3.9μH inductor should work.  Getting one to fit
the PCB may be harder.  This is the digi-key part number for the
inductor used by the author: 495-2017-1-ND.

## Circuit Simulation

The simulation subdirectory contains a kicad simulation project.  You
should be able to open it in kicad and run the simulation without any
other preparation.

## Power Management Software

This is a work in progress.  A link will be provided in due course.

## GPIO Pins

The default GPIO pins (ie those with the jumpers closed) are as
follows for Raspberry Pi and LibreComputer's Le Potato.  The default
pins have been picked as reasonable choices for both types of board.
If you need to use one of the chosen default pins, you can simply
choose to wire different pins to the jumpers (see *The Jumpers*
below).

|Purpose			|Pin    |Rpi		|Potato |
|-------------------------------|-------|---------------|-------|
|Power Sense1 (JP1)		|29  	|gpio 5		|gpio 96|
|Power Sense2 (JP2)		|31	|gpio 6		|gpio 97|
|Power Button/Power Off (JP3)	|36	|gpio 16	|gpio 81|
|Power Off (JP4)	       	|37	|gpio 26	|gpio 84|

## The Jumpers

The jumpers JP1-JP4, in combination with J5 allow any gpio pin to be
used.

Note that the jumpers on the project's PCB have only 1 pin, which must
be connected to the required GPIO by a wire link (to J4).

## Optional Components

### Single Power Source

If you only need power sensing for 1 input source, you can remove the
components: J2, D1, D3, D4, D7, R1, C1, R5, and JP2.  You can also
replace D2 with a wire connection.  This will free up the gpio pin on
JP2.

## Auto Start

If you do not want the power-supply to automatically switch on the SBC
when power is applied you can omit C6.  The SBC will then only
switch-on when the power-button switch across J7 and J8 is closed.

## Power-Off

R29 and JP4 allow gpio pin 37 to quickly switch off the power supply.
You can save these components, and regain the gpio pin, if you are
prepared to let gpio pin 36 shut off the power supply.  This shutdown
mechanism is slower than using the dedicated power-off line as it
charges C8 at the same speed that the power button does (ie slowly).

## Switched Power Output

J10 provides 5V power that is switched off as soon as input power to
the board is lost.  If this is not needed, Q3 can be ommitted.

## Changes History

Revision 3.0, 2024-03-27 is the current version.

Revision 2.0 was the first released, mostly working, version.

### Errata from Revision 2.0

Unfortunately, U1A would often switch momentarily low when power was
lost, causing the power-supply to switch on if it was off at the time.
This part of the circuit was completely redesigned for revision 3.

Aditionally, the Zener diode feeding Q1 was placed the wrong way round
on the PCB design (arising from mislabelling of the pins in the
simulation).  Also, as this was a 6.8V Zener, it meant that as the
voltage across C5 fell, Q1 was turned off too early, potentially
leading to damage of Q1's body diode.

The feedback resistor on U1B was specified as 45M.  Since this is a value
that is somewhat difficult to obtain, this has been replaced by 22M.

### Other Changes from Revision 2.0

The board's dimensions have been changed.  The original dimensions
fouled the Ethernet and USB connectors on many SBC boards, so the
layout has been significantly changed to avoid this.

The supercapacitor board is now attached to the underside of the
board, providing more room on top.

The power MOSFETs and tall capacitors, are now mounted horizontally,
to reduce the board's headroom requirements.

Allowance for an optional buck-convertor board (B1) has been added.
This can replace the 5V regulator made from discrete components.

