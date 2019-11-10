/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            v1.ino
// Created:         September 2015
// Author(s):       Philip Smart
// Description:     An Arduino sketch to configure an ATMega328p as an I/O expander.
//                  The ATMega listens on the serial port and executes commands to set output pins to
//                  requested values or read input pins and return values via the serial port.
//
// Credits:         
// Copyright:       (c) 2015-2019 Philip Smart <philip.smart@net2net.org>
//
// History:         September 2015    - Initial program creation.
//
// Notes:           
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// This source file is free software: you can redistribute it and#or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This source file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
/////////////////////////////////////////////////////////////////////////////////////////////////////////
String serialInBuffer  = "";         // Buffer to hold incoming data for processing.
String serialOutBuffer = "";         // Buffer to hold outgoing data.
char inputPorts[20]     = "";        // Buffer to hold regularly sampled digital input ports.
char portConfig[20]     = "";        // Port configuration map.
char tmpbuf[20]         = "";
boolean stringComplete = false;      // Flag to indicate when an incoming message is complete.

// Configuration of PINS - Output mode.
//
int PIN_D0   = 0;
int PIN_D1   = 1;
int PIN_D2   = 2;
int PIN_D3   = 3;
int PIN_D4   = 4;
int PIN_D5   = 5;
int PIN_D6   = 6;
int PIN_D7   = 7;
int PIN_D8   = 8;  int OUT0 = PIN_D8;
int PIN_D9   = 9;  int OUT1 = PIN_D9;
int PIN_D10  = 10; int OUT2 = PIN_D10;
int PIN_D11  = 11; int OUT3 = PIN_D11;
int PIN_D12  = 12; int OUT4 = PIN_D12;
int PIN_D13  = 13; int OUT5 = PIN_D13;
int PIN_A0   = 14; int IN0  = PIN_A0;
int PIN_A1   = 15; int IN1  = PIN_A1;
int PIN_A2   = 16; int IN2  = PIN_A2;
int PIN_A3   = 17; int IN3  = PIN_A3;
int PIN_A4   = 18; int IN4  = PIN_A4;
int PIN_A5   = 19; int IN5  = PIN_A5;

// Config string locations.
//
int CFG_D0  = 0;
int CFG_D1  = 1;
int CFG_D2  = 2;
int CFG_D3  = 3;
int CFG_D4  = 4;
int CFG_D5  = 5;
int CFG_D6  = 6;
int CFG_D7  = 7;
int CFG_D8  = 8;
int CFG_D9  = 9;
int CFG_D10 = 10;
int CFG_D11 = 11;
int CFG_D12 = 12;
int CFG_D13 = 13;
int CFG_A0  = 14;
int CFG_A1  = 15;
int CFG_A2  = 16;
int CFG_A3  = 17;
int CFG_A4  = 18;
int CFG_A5  = 19;

// Function to set up all GPIO ports according to the memory buffer configuration image portConfigs.
// A 0 means output, a 1 means input.
//
void setPortConfig()
{
    // Set ports according to config string, 0 = output, 1 = input. PIN_D0 and PIN_D1 are RX/TX so dont set
    //
    //if(portConfig[0]  == '0') { pinMode(PIN_D0,  OUTPUT);} else { pinMode(PIN_D0,  INPUT); }
    //if(portConfig[1]  == '0') { pinMode(PIN_D1,  OUTPUT);} else { pinMode(PIN_D1,  INPUT); }
    if(portConfig[2]  == '0') { pinMode(PIN_D2,  OUTPUT);} else { pinMode(PIN_D2,  INPUT); }
    if(portConfig[3]  == '0') { pinMode(PIN_D3,  OUTPUT);} else { pinMode(PIN_D3,  INPUT); }
    if(portConfig[4]  == '0') { pinMode(PIN_D4,  OUTPUT);} else { pinMode(PIN_D4,  INPUT); }
    if(portConfig[5]  == '0') { pinMode(PIN_D5,  OUTPUT);} else { pinMode(PIN_D5,  INPUT); }
    if(portConfig[6]  == '0') { pinMode(PIN_D6,  OUTPUT);} else { pinMode(PIN_D6,  INPUT); }
    if(portConfig[7]  == '0') { pinMode(PIN_D7,  OUTPUT);} else { pinMode(PIN_D7,  INPUT); }
    if(portConfig[8]  == '0') { pinMode(PIN_D8,  OUTPUT);} else { pinMode(PIN_D8,  INPUT); }
    if(portConfig[9]  == '0') { pinMode(PIN_D9,  OUTPUT);} else { pinMode(PIN_D9,  INPUT); }
    if(portConfig[10] == '0') { pinMode(PIN_D10, OUTPUT);} else { pinMode(PIN_D10, INPUT); }
    if(portConfig[11] == '0') { pinMode(PIN_D11, OUTPUT);} else { pinMode(PIN_D11, INPUT); }
    if(portConfig[12] == '0') { pinMode(PIN_D12, OUTPUT);} else { pinMode(PIN_D12, INPUT); }
    if(portConfig[13] == '0') { pinMode(PIN_D13, OUTPUT);} else { pinMode(PIN_D13, INPUT); }
    if(portConfig[14] == '0') { pinMode(PIN_A0,  OUTPUT);} else { pinMode(PIN_A0,  INPUT); }
    if(portConfig[15] == '0') { pinMode(PIN_A1,  OUTPUT);} else { pinMode(PIN_A1,  INPUT); }
    if(portConfig[16] == '0') { pinMode(PIN_A2,  OUTPUT);} else { pinMode(PIN_A2,  INPUT); }
    if(portConfig[17] == '0') { pinMode(PIN_A3,  OUTPUT);} else { pinMode(PIN_A3,  INPUT); }
    if(portConfig[18] == '0') { pinMode(PIN_A4,  OUTPUT);} else { pinMode(PIN_A4,  INPUT); }
    if(portConfig[19] == '0') { pinMode(PIN_A5,  OUTPUT);} else { pinMode(PIN_A5,  INPUT); }
}

// Function to initialise the ATMega328p.
// Setup necessary memory buffers, serial port and initial GPIO port state.
//
void setup()
{
    // initialize serial:
    Serial.begin(115200);

    // Buffer for the input stream.
    serialInBuffer.reserve(200);

    // Buffer for the output stream.
    serialOutBuffer.reserve(200);

    // Port config string.
    //portConfig.reserve(20);

    // Setup default port config string.
    //
    for(int idx=0; idx < 20; idx++)
    {
        // Default to input.
        //
        portConfig[idx] = '1'; 

        // Reset input port storage buffer to default for this port.
        //
        inputPorts[idx] = '0';
    }
    portConfig[CFG_D8]  = '0';
    portConfig[CFG_D9]  = '0';
    portConfig[CFG_D10] = '0';
    portConfig[CFG_D11] = '0';
    portConfig[CFG_D12] = '0';
    portConfig[CFG_D13] = '0';

    setPortConfig();

    // Setup default state, all outputs off (inverse logic).
    //
    digitalWrite(OUT5, HIGH);
    digitalWrite(OUT4, HIGH);
    digitalWrite(OUT3, HIGH);
    digitalWrite(OUT2, HIGH);
    digitalWrite(OUT1, HIGH);
    digitalWrite(OUT0, HIGH);
}

// Function, called periodically, to read all the valid input ports and store value in memory.
// Done this way primarily for transmission speed of individual reads given the arduino loop mechanism.
//
void readInputs()
{
    // Just read the ports into the string to be sent to requestor.
    //
    if(portConfig[CFG_D0]  == '1') { inputPorts[CFG_D0]  = char(digitalRead(PIN_D0)+48);  }
    if(portConfig[CFG_D1]  == '1') { inputPorts[CFG_D1]  = char(digitalRead(PIN_D1)+48);  }
    if(portConfig[CFG_D2]  == '1') { inputPorts[CFG_D2]  = char(digitalRead(PIN_D2)+48);  }
    if(portConfig[CFG_D3]  == '1') { inputPorts[CFG_D3]  = char(digitalRead(PIN_D3)+48);  }
    if(portConfig[CFG_D4]  == '1') { inputPorts[CFG_D4]  = char(digitalRead(PIN_D4)+48);  }
    if(portConfig[CFG_D5]  == '1') { inputPorts[CFG_D5]  = char(digitalRead(PIN_D5)+48);  }
    if(portConfig[CFG_D6]  == '1') { inputPorts[CFG_D6]  = char(digitalRead(PIN_D6)+48);  }
    if(portConfig[CFG_D7]  == '1') { inputPorts[CFG_D7]  = char(digitalRead(PIN_D7)+48);  }
    if(portConfig[CFG_D8]  == '1') { inputPorts[CFG_D8]  = char(digitalRead(PIN_D8)+48);  }
    if(portConfig[CFG_D9]  == '1') { inputPorts[CFG_D9]  = char(digitalRead(PIN_D9)+48);  }
    if(portConfig[CFG_D10] == '1') { inputPorts[CFG_D10] = char(digitalRead(PIN_D10)+48); }
    if(portConfig[CFG_D11] == '1') { inputPorts[CFG_D11] = char(digitalRead(PIN_D11)+48); }
    if(portConfig[CFG_D12] == '1') { inputPorts[CFG_D12] = char(digitalRead(PIN_D12)+48); }
    if(portConfig[CFG_D13] == '1') { inputPorts[CFG_D13] = char(digitalRead(PIN_D13)+48); }
    if(portConfig[CFG_A0]  == '1') { inputPorts[CFG_A0]  = char(digitalRead(PIN_A0)+48);  }
    if(portConfig[CFG_A1]  == '1') { inputPorts[CFG_A1]  = char(digitalRead(PIN_A1)+48);  }
    if(portConfig[CFG_A2]  == '1') { inputPorts[CFG_A2]  = char(digitalRead(PIN_A2)+48);  }
    if(portConfig[CFG_A3]  == '1') { inputPorts[CFG_A3]  = char(digitalRead(PIN_A3)+48);  }
    if(portConfig[CFG_A4]  == '1') { inputPorts[CFG_A4]  = char(digitalRead(PIN_A4)+48);  }
    if(portConfig[CFG_A5]  == '1') { inputPorts[CFG_A5]  = char(digitalRead(PIN_A5)+48);  }
}

// Main loop - just receive requests and process them.
//
void loop()
{
    // Update the in-memory representation of the input pins.
    //
    readInputs();

    // Decipher command string and act upon it.
    //
    if (stringComplete)
    {
        // Configuration of ports, 0 = output, 1 = input.
       //
        if(serialInBuffer[0] == 'C')
        {
            // Copy input string to config string then setup ports.
            //
            for(int idx=0; idx <= 19; idx++)
            {
                portConfig[idx] = serialInBuffer[idx+1];

                // Reset input port storage buffer to default for this port.
                //
                inputPorts[idx] = '0';
            }
            setPortConfig();
            Serial.println("OK\n");

            // Debug - write back the received config.
            //Serial.println(portConfig);
        } else

        // Read all input ports and return values as a string.
        //
        if(serialInBuffer[0] == 'R')
        {
            // Get most recent values.
            //
            readInputs();

            // Build into a string and transmit back.
            //
            serialOutBuffer = "V";
            for(int idx=0; idx <= 19; idx++)
            {
                serialOutBuffer += inputPorts[idx];
            }
            serialOutBuffer += "\n";
            Serial.println(serialOutBuffer);
        } else

        // Transmit last sampled value for a given port, done this way for speed.
        //
        if(serialInBuffer[0] == 'r')
        {
            // Get required input port number, then send value back.
            //
            int gpioport=((serialInBuffer[1]-48) * 10) + (serialInBuffer[2] - 48);
            serialOutBuffer = "v";
            serialOutBuffer += inputPorts[gpioport];
            serialOutBuffer += "\n";
            Serial.println(serialOutBuffer);
        } else

        // Set all output ports.
        //
        if(serialInBuffer[0] == 'W')
        {
            for(char idx=0; idx <= 19; idx++)
            {
                if(serialInBuffer[idx+1] == '0') { digitalWrite(idx, LOW); } else { digitalWrite(idx, HIGH); }
            }
            Serial.println("OK\n");

            // Debug - write back the received command.
            //Serial.println(serialInBuffer);
        } else

        // Set an individual output port.
        //
        if(serialInBuffer[0] == 'w')
        {
            int gpioport=((serialInBuffer[1]-48) * 10) + (serialInBuffer[2] - 48);
            if(serialInBuffer[3] == '0') { digitalWrite(gpioport, LOW); } else { digitalWrite(gpioport, HIGH); }

            // No reply to minimise traffic and increase throughput.

            // Debug - write back the received command.
            //Serial.println(serialInBuffer);
            //Serial.println(gpioport);
            //Serial.println("\n");
        } else
        {
            if(serialInBuffer != "")
            {
                Serial.println("ERROR:");
                Serial.println(serialInBuffer);
                Serial.println("\n");
            }
        }

        // clear the string:
        serialInBuffer = "";
        stringComplete = false;
    }
}

/*
  SerialEvent occurs whenever new data comes in the
  hardware serial RX. This routine is run between each
  time loop() runs, so using delay inside loop can delay
  response. Multiple bytes of data may be available.
*/
void serialEvent()
{
    while (Serial.available())
    {
        // get the new byte:
        char inChar = (char)Serial.read(); // Serial.write(inChar);

        // if the incoming character is a newline, set a flag
        // so the main loop can do something about it:
        if (inChar == '\n')
        {
            stringComplete = true;
        } else
        {
            // add it to the serialInBuffer:
            serialInBuffer += inChar;
        }
    }
}
