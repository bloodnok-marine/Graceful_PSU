# RPi Graceful Power Supply Controller

This is a graceful-shutdown power supply for a Raspberry Pi or
similar Single Board Computer (SBC).

It has 3 major functions:

1) Provide very short term backup power when input power is lost.
   A supercapacitor provides enough power to allow time for a clean
   shutdown. 
2) Provide software and push-button control of power.
   This allows the computer to be turned on by a short button press
   and the power removed by a long press.  It also allows the computer
   to turn off the power itself, and allows it to monitor the button
   state.
3) Provide a regulated 5V supply from an unregulated ~12V supply.

## Circuit Description

Note that components marked with an asterisk (*) are optional.  The
optionality of these components is decribed in the appropriate section
below.

### Power Input

The circuit is designed to allow 2 independent 12V power inputs.  This
allows the SBC, for usage on a sailboat, to be powered by independent
circuit breakers: 1 for accessories allowing it to be used as an
entertainment system; and 1 for instruments allowing it to be used for
navigation.  Separate sensing of these power inputs is provided for
the Pi so that different functionality may be provided in each case.

Schottky Diodes (D6, D7) carry the power from each input source,
preventing one source from feeding power into the other, and
preventing our backup power feeding back to the source.

D1 and D4 provide input voltage sense signals to the Pi. 

If only a single power source is required J2 may be ignored; D1 and
D7 may be ommitted; and D4 replaced with a wire link.

### Power Sensing

Sense input is provided to GPIO pins (header pins 29 and 31) to allow
the SBC to determine whether, and which, inputs are providing power.

This allows us to sense loss of input power and to identify which power
sources are active.

If only a single power source is needed D2, R2, R8 and C2 can be
ommitted, and D5 replaced with a wire link.

### SuperCapacitor Backup Power

This part of the circuit:

- limits the charge current for the supercapacitor, C4, to avoid a
  large current spike when power is connected;
- ensures that the supercapacitor fully charges;
- allows current to flow from the supercapacitor unimpeded when
  input power is removed;
- disables the Power Control Latch until the supercapacitor has
  reached a suitable level of charge. 

When power is applied, C1 slowly charges through R3, lowering the
input voltage to the inverting input of U1B, thereby raising the
output voltage of U1B causing C4 to charge.

R4, R5 and R8 provide the non-inverting input of U1B.  This voltage
starts at around 75% of the supply voltage and falls to around 50% as
the supercapacitor charges.  This effectively provides negative
feedback, limiting the rate of charging of C4: as C4 charges the
voltage at the non-inverting input falls reducing the the output
voltage of U1B and increasing the source-drain resistance of Q1.

The net result of all this is that C4 charges at about 5 times the
rate of C1, with C1's charge rate entirely governing that of C4.

D10 causes Q1's gate voltage to be kept 6.8V below the output voltage
of U1B.  This is to force U1B's output to be very high when C4's
charge state is behind that of C1.  This highly non-linear behaviour
allows U1B to force C1 to charge rapidly when it is significantly
behind C4's charge.  This will happen when power is disconnected,
allowing C1 to rapidly discharge through R1 and D3, but C4 has not yet
discharged.  This means that if C4 is still largely charged when power
is applied, C1 will rapidly charge to the point where C4 begins to
charge.  This, fast, charging of C1 is done through D8, D9 and R11 but
only when U1B's output is low.  D8 ensures that the charging of C1
stops as soon Q1 starts to be turned on, and D9 prevents C1 from
discharging.

U1A is a simple voltage comparator configured as a Schmitt Trigger.
When C4 reaches around 90% (around 10.8V) of being fully charged, the
output will switch from high to low, turning on the LED (J5, J6) and
enabling the Power Control Latch switch (J7, J8).  If optional C8 is
installed, the Power Control Latch, Q2, will automatically switch on
at this time.

When input power is disconnected, U1As non inverting input will be
pulled low, disabling the switch and turning off the LED.

When input power is disconnected, U1B's non-inverting input will be
pulled low by R3, causing U1B's output to go high turning Q1 on hard.
This will allow power to be drawn from Q4 with almost zero loss.

#### Charging Time and Current

[This](https://www.amazon.ca/LMUWF-Capacitor-Module-Capacitors-Protection/dp/B09FXK86RZ/ref=sr_1_2?crid=354P0FGQLHK3U&keywords=2f+super+capacitor&qid=1648493702&sprefix=2f+supercapacitor%2Caps%2C146&sr=8-2)
is the supercapacitor module I used, which is actually 1.6F.

The charge current for the supercapacitor is given by the formula:

    I = C * V / t

where C is the capacitance, V is the voltage to which it is to be
charged, and t is the time taken to charge.

With the circuit as given, the full charge time (for 12V) is around 7.5 seconds,
which gives us 1.6 * 12 / 7.5 = 2.6 Amp.

The Schottky diodes are rated at 4A, so using any larger
supercapacitor will require circuit modification to increase the
rating of the diodes or limit the charge current.  This can be done by
increasing the value of C1 and/or R3.  

### Power Control Latch

This section of the circuit is from:

http://www.mosaic-industries.com/embedded-systems/microcontroller-projects/raspberry-pi/on-off-power-controller

The MOSFET pair of Q2 form a latching circuit that provides power to a
5V buck regulator.

When power is initially applied to J1 or J2 the gate of Q2B is driven
high by R21 causing it to not conduct (R20 and C7 assist in this).  Q2A's
gate will be drawn low at this point (via internal resistance in the
pi) keeping Q2b from conducting.

To turn on Q2B, the Voltage at its gate must be dropped towards zero.
This can be done by momentarily closing the contacts of a switch
across J7 and J8.  The optional capacitor C8 will automatically switch
power on once the output of U1A drops to zero volts.  If you do not
want automatic switch-on, leave C8 out of the circuit.

Once Q2B turns on, Q2A's gate is drawn high, turning it on, and
keeping Q2B's gate low which keeps Q2B conducting.

To turn off the power, the gate voltage at Q2A must be brought low.
This can be done by the pi bringing GPIO4 (header pin 7) low, or by a
long press on the switch (J7, J8) which will slowly discharge
capacitor C7 until Q2A's gate voltage is sufficiently brought down to
turn it off.

The Pi's GPIO4 pin can also be used as an input to monitor the
switch state.  If a short press is detected it should start the power
down process, finishing by rconfiguring GPIO4 as an output and setting
it low.

Shutdown should also be initiated when input power is disconnected
(from J1 and J2).  This is determined by monitoring GPIO5 and GPIO6
(header pins 29 and 31).

### 5V Regulator

5V for the Rpi is provided by a buck convertor.  This part of the
circuit was generated by Texas Instruments' WEBENCH tool.

Q3 provides an unbacked-up 5V supply.  When input power is
disconnected Q3 will no longer conduct.  This is intended for
peripherals such as monitors that need not be powered during the
shutdown of the computer. 
