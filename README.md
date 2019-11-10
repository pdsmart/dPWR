## Foreword

This document is a work in progress.



## Overview

I needed a web based power controller to remotely control a large number of devices, Mains (230VAC) and low level DC voltages as well as read remote value such as switch settings. I looked at the market and there wasn't really anything suitable within an acceptable price range (B2B equipment was in the multi-thousand GBP price bracket). I didn't want to design and fabricate a dedicated circuit board so I sifted through my parts bin and used what I found and thus was born the dPWR Controller.

I had a hardkernel.org Odroid (a Raspberry Pi type dev board) and U3 Shield along with some relay & thyristor switching boards and a few IO Expander chips and ATMega devices. I decided to base dPWR on a cobbling of these parts with the foresight of adding additional components as needed. In terms of software, the Linux operating system stood as the base platform rather than an embedded on metal application as the Odroid was sufficiently powerful, low power and made development that much easier.

Having limited time I discounted C/C++ as it takes considerably longer to develop in these languages especially as performance wasn't a consideration, this left Java, Python and Perl. Having just finished an application for a client in Perl it just seemed a natural choice (even though it is a scripting language primarily developed for reporting but was incredibly rich in it's eco system). 

dPWR had to provide the following functionality:-

o Communicate directly with hardware to configure, set and read GPIO, I2C, Serial Ports and Ethernet ports in order to make use of the variety of boards I had in my bin. A modular system was needed to add hardware and support software as required.

o Provide a web server to allow remote configuration and control.

o Provide configurable automation such that dPWR could monitor a device and take actions as required.

The above was developed and has been reliably in service for the last 4 years. I recently removed the dPWR hardware to service it when the Corsair power supplies gave up the ghost and took the photos below.

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/IMG_9800.jpg)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/IMG_9801.jpg)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/IMG_9803.jpg)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/IMG_9804.jpg)





## dPWR Web Interface

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen1.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen2.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen3.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen4.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen5.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen6.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen7.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen8.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen9.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen10.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen11.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen12.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen13.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen14.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen15.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen16.png)

![alt text](https://github.com/pdsmart/DPWR/blob/master/docs/Screen17.png)





#### To Do





## Credits

Where I have used or based any component on a 3rd parties design I have included the original authors copyright notice.



## Licenses

This design, hardware and software, is licensed under the GNU Public Licence v3.


