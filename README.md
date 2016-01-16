##Tiny Door and Window Sensor/Alarm with Ultra Low Standby Power (<1µA)

A **Ultra Low Standby Power Project** which pushes the state of a connected switch(reed/magnet or any other) every time it changes to one of 4 different services(you need to chooose and configure one). Supported "services": [**ArrestDB**](https://github.com/alixaxel/ArrestDB)(this is not an online service but a php script which runs on my raspberry pi), [**IFTTT**](https://ifttt.com/), [**Pushingbox**](https://www.pushingbox.com/) and [**Thingspeak**](https://thingspeak.com/).

##Partlist:
* ATtiny25(45/85)
* Voltage regulator with enable/shutdown pin (tested with SPX3819, AS1363, LT1763)
* ESP8266 (ESP-12)
* Changeover/SPDT switch (could be any other)
* Some resistors, capacitors, and leds(r, g, b)

##Schematic
![alt text](https://raw.githubusercontent.com/8n1/ESP8266-Tiny-Door-and-Window-Sensor/master/Schematic/tiny-door-and-window-sensor_v01.png "Door and window sensor - Schematic")


The standby current consumption is about 330nA(*Nanoampere*) @3.8V.
The biggest current sucker in standby is the ATtiny in power-down sleep mode (~300nA).

Beside a few other tricks I've had to come up with to get the current consumption really that low, a in some of my usecases important one is to use a changover/SPDT (3pin) wakeup switch(the one with 3 pins). Using one of these I can get rid of the pullup resistor that is otherwise needed when using a normal (2pin) switch. This means that the current consumption is in both states(door/window is open AND door/window is closed) equaly low. 


##Procedure
The ATtiny wakes up through a pin change interrupt triggered by opening or closing the window/door(pressing or releasing the switch). The ATtiny activates the LDO and therefore the ESP-12. The ESP connects to the wifi, optionaly collects some data(**wifi signal strength**, **temperature**, **battery voltage**), reads the state of the (wakeup) switch and sends it along with the other colleted data to the choosen service. After that the ESP signals the ATtiny to shutdown the LDO and the system goes into standby, waiting for the next interrupt.


##Installation ESP
* Clone/download this repository
* Flash the nodemcu firmware (I'm using esptool.py for this)
* Configure the two lua files ("config.lua" and "..._request.lua")
* Upload all lua files (I'm using ESPlorer for that)
* Execute "compile_files.lua"
* Done. Restart the ESP to test.

##Configuration ESP
Only two files must be edited.
* Open and edit "config.lua"
* Open and edit the selected service request script ("..._request.lua")

##Installation ATtiny
* Get the latest Arduino IDE (tested with 1.6.5)
* Install attiny support using the "Boards Manager" (Menu: Tools->Board:...->Boards Manager->attiny)
* Compile and upload the sketch (no configuration needed)
* (go sure the fusebits are set correct (default value))

##Breadboard setup
By using one my own ESP Breakout Adapters, the breadboard setup is quite simple and looks like this: TODO 
![alt text](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Door and window sensor - breadboard setup")

##A small pcb
I've also designed a small pcb which holds everything in place: TODO 
![alt text](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Door and window sensor - pcb v0.2")

###More details and explainations: (in german) TODO


###Resources
- http://frightanic.com/nodemcu-custom-build/
- https://github.com/nodemcu/nodemcu-firmware/wiki/nodemcu_api_en
- http://www.atmel.com/Images/atmel-2586-avr-8-bit-microcontroller-attiny25-attiny45-attiny85_datasheet.pdf
- http://www.engbedded.com/fusecalc/

Services
- https://github.com/alixaxel/ArrestDB
- https://ifttt.com/
- https://www.pushingbox.com/
- https://thingspeak.com/
