Olimexino & ModRGB via Espurino
===============================

Software to control the OLIMEXINO-STM32 &amp; MOD-RGB extension through the Espurino interface with a neat small application.

The micro controller can be found here: https://www.olimex.com/Products/Duino/STM32/OLIMEXINO-STM32/open-source-hardware
The RGB LED UEXT mod can be found here: https://www.olimex.com/Products/Modules/LED/MOD-RGB/open-source-hardware
Espurino and its firmware can be found here: http://www.espruino.com/
Works with 12V RGB-LED strips

Instructions
------------

Connect the micro controller via USB, then flash the Espurino firmware to the device (for further instructions see Espurino website). Connect the LED strip with the UEXT MOD-RGB board and connect this board with the micro controller. Additionally wire power from micro controller pin GND & VIN to (+) and (-) of the UEXT board. Now, connect a power supply (12V !) and run the software.
