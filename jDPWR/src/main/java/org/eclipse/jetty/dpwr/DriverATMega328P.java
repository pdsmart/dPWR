/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            DriverATMega328P.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     Driver::ATMega328P - A Driver package specifically to interact with the ATMega328P
//                  communicating with it and providing standard API methods for the jDPWR program
//                  to read, set and configure the device and ports.
//
// Credits:
// Copyright:       (c) 2017-2019 Philip Smart <philip.smart@net2net.org>
//
// History:         March 2017   - Initial creation based on dPWR.
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
package org.eclipse.jetty.dpwr;

import java.io.*;
//import java.io.FileNotFoundException;
//import java.io.IOException;
//import java.io.InputStream;
//import java.io.OutputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.UUID;
import java.util.*;
import java.util.concurrent.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.net.JarURLConnection;
import java.lang.*;

// Jackson imports for serialization of this bean into JSON files.
//
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonSubTypes;  
import com.fasterxml.jackson.annotation.JsonTypeInfo;  
import com.fasterxml.jackson.annotation.JsonSubTypes.Type;  
import com.fasterxml.jackson.core.JsonGenerationException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

import org.eclipse.jetty.jsp.JettyJspServlet;
import org.apache.tomcat.InstanceManager;
import org.apache.tomcat.SimpleInstanceManager;
import org.eclipse.jetty.annotations.ServletContainerInitializersStarter;
import org.eclipse.jetty.apache.jsp.JettyJasperInitializer;
import org.eclipse.jetty.plus.annotation.ContainerInitializer;
import org.eclipse.jetty.server.ConnectionFactory;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.ServerConnector;
import org.eclipse.jetty.servlet.DefaultServlet;
import org.eclipse.jetty.servlet.ServletHolder;
import org.eclipse.jetty.util.log.JavaUtilLog;
import org.eclipse.jetty.util.log.Log;
import org.eclipse.jetty.webapp.WebAppContext;

public class DriverATMega328P implements Driver, Runnable, java.io.Serializable
{
    // ##################################
    // # ATMEGA328P Driver Configuration
    // ##################################
    //
    // Constants.
    //
    // Maxims.    
    public static final int                     ATMEGA328P_MAX_PORTS        = 20;
    public static final int                     DRIVER_PROCESSING_INTERVAL  = 5000; // Milliseconds between running the run() method.
    
    // Pseudo constants for devices.
    public static final String                  S_ATMEGA328P                = "ATMEGA328P";
    public static final int                     I_ATMEGA328P                = 0;
    public static final String                  S_NAME                      = "ATMEGA328P";
    public static final String                  S_DESCRIPTION               = "UART 20port IO Expander";

    // Maps for the various uart parameters.
    private static final Map<String, Integer>   UART_BAUD_RATES             = createUartBaudRatesMap();
    private static final Map<String, Integer>   UART_DATABITS               = createUartDataBitsMap();
    private static final Map<String, String>    UART_PARITY                 = createUartParityMap();
    private static final Map<String, Integer>   UART_STOPBITS               = createUartStopBitsMap();

    // Defaults.
    public static final String                  DEFAULT_ATMEGA328P_UART     = "/dev/ttyACM99";
    public static final int                     DEFAULT_ATMEGA328P_BAUDRATE = 115200;
    public static final int                     DEFAULT_ATMEGA328P_DATABITS = 8;
    public static final String                  DEFAULT_ATMEGA328P_PARITY   = "N";
    public static final int                     DEFAULT_ATMEGA328P_STOPBITS = 1;

    // Bean variables to control a device.
    //
    @JsonIgnore
    private static final Logger LOG = Logger.getLogger(DriverATMega328P.class.getName());    
    @JsonIgnore
    private transient String    uuid;                // Unique ID to identify this driver instance.
    private int                 runInterval;         // Period of time in Milliseconds between calls to run() method.
    private TOGGLE              enabled;             // Driver is enabled and functional.
    private LOCKED []           locked;              // Array of bits to indicate port locked out (not useable = LOCKED).
    private String              name;                // Name associated with this device.
    private String              description;         // Description of device purpose.
    private String              uart;                // Serial device to which the ATMega328P is connected.
    private int                 uartBaud;            // Baud rate used by the ATMega328P.
    private int                 uartDataBits;        // Number of databits used by the ATMega328P.
    private String              uartParity;          // Number of parity bits used by the ATMega328P.
    private int                 uartStopBits;        // Number of stopbits used by the ATMega328P.

    // Static map initialisers.
    //
    private static Map<String, Integer> createUartBaudRatesMap()
    {
        Map<String, Integer> result = new LinkedHashMap<String, Integer>();
        result.put("115200", 115200);
        result.put( "57600",  57600);
        result.put( "28800",  28800);
        result.put( "14400",  14400);
        result.put(  "9600",   9600);
        result.put(  "4800",   4800);
        result.put(  "2400",   2400);
        result.put(  "1200",   1200);
        return Collections.unmodifiableMap(result);
    }
    private static Map<String, Integer> createUartDataBitsMap()
    {
        Map<String, Integer> result = new LinkedHashMap<String, Integer>();
        result.put("8", 8);
        result.put("7", 7);
        result.put("6", 6);
        result.put("5", 5);
        return Collections.unmodifiableMap(result);
    }
    private static Map<String, String> createUartParityMap()
    {
        Map<String, String> result = new LinkedHashMap<String, String>();
        result.put("none", "N");
        result.put("odd",  "O");
        result.put("even", "E");
        return Collections.unmodifiableMap(result);
    }
    private static Map<String, Integer> createUartStopBitsMap()
    {
        Map<String, Integer> result = new LinkedHashMap<String, Integer>();
        result.put("2",   2);
        result.put("1",   1);
        return Collections.unmodifiableMap(result);
    }

    //Constructor.
    //
    public DriverATMega328P()
    {
        // Setup internal variables and initialise to defaults.
        //
        this.uuid             = UUID.randomUUID().toString();
        this.runInterval      = DRIVER_PROCESSING_INTERVAL;
        this.enabled          = TOGGLE.DISABLED;
        this.locked           = new LOCKED[ATMEGA328P_MAX_PORTS];
        this.name             = S_NAME;
        this.description      = S_DESCRIPTION;
        this.uart             = DEFAULT_ATMEGA328P_UART;
        this.uartBaud         = DEFAULT_ATMEGA328P_BAUDRATE;
        this.uartDataBits     = DEFAULT_ATMEGA328P_DATABITS;
        this.uartParity       = DEFAULT_ATMEGA328P_PARITY;
        this.uartStopBits     = DEFAULT_ATMEGA328P_STOPBITS;

        // Initialise the base state of the arrays. Normally these arrays will take on values from a deserialization event.
        //
        for(int idx = 0; idx < ATMEGA328P_MAX_PORTS; idx++)
        {
            this.locked[idx] = LOCKED.UNLOCKED;
        }
    }
    public DriverATMega328P(LOCKED[] locked)
    {
        // Call the base constructor.
        //
        this();

        // Use the locked array to setup the driver, locking out hardware ports which are not accessible.
        //
        if(locked.length < ATMEGA328P_MAX_PORTS)
        {
            LOG.warning("Illegal Locked Array given, should be " + ATMEGA328P_MAX_PORTS + " elements in size.");
        }
        for(int idx=0; idx < ATMEGA328P_MAX_PORTS; idx++)
        {
            if(locked.length >= ATMEGA328P_MAX_PORTS && locked[idx] != null && locked[idx] == LOCKED.LOCKED)
            {
                this.locked[idx] = LOCKED.LOCKED;
            } else
            {
                this.locked[idx] = LOCKED.UNLOCKED;
            }
        }
    }
    public DriverATMega328P(String name, String description, LOCKED[] locked, String uart, int baud, int databits, String parity, int stopbits)
    {
        this(locked);
        Boolean result = init(name, description, uart, baud, databits, parity, stopbits);
    }
    public DriverATMega328P(String name, String uart, LOCKED[] locked, int baud, int databits, String parity, int stopbits)
    {
        this(locked);
        Boolean result = init(name, S_DESCRIPTION, uart, baud, databits, parity, stopbits);
    }

    // Various methods to initialise driver.
    //
    @Override
    public Boolean init(String name, String description, String uart, int baud, int databits, String parity, int stopbits)
    {
        this.setUart(uart);
        this.setUartBaud(baud);
        this.setUartDataBits(databits);
        this.setUartParity(parity);
        this.setUartStopBits(stopbits);
        this.setName(name);
        this.setDescription(description);
        return(true);
    }

    // Getters and Setters.
    //
    @JsonIgnore
    public String getUuid()
    {
        return(this.uuid);
    }

    public String getDriverType()
    {
        return(S_ATMEGA328P);
    }

    // As each device has several parameters local to it, a method is needed for an external process to evaluate
    // the parameters and know the Get/Setters associated with them,
    //
    @JsonIgnore
    public ObjectNode getParamInfo()
    {
        // Initialise Jackson objects.
        ObjectMapper mapper    = new ObjectMapper();
        ObjectNode result      = mapper.createObjectNode();
        ObjectNode paramsNode  = mapper.createObjectNode();
        ArrayNode choiceArray;
        ObjectNode choiceElem;
        ObjectNode paramsElem;

        // Build up all parameters that can be changed along with editting information.
        //
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "Choice");
        paramsElem.put("title",        "Device Enabled");
        paramsElem.put("info",         "Device is enabled and active.");
        for(TOGGLE val : TOGGLE.values())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", val.name());
            choiceElem.put("value", val.name());
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",        choiceArray);
        paramsNode.put("enabled",       paramsElem);

        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        choiceElem  = mapper.createObjectNode();
        paramsElem.put("varType",      "Choice");
        paramsElem.put("title",        "Device Type");
        paramsElem.put("info",         "Type of underlying hardware.");
        choiceElem.put("label", S_ATMEGA328P);
        choiceElem.put("value", S_ATMEGA328P);
        choiceArray.add(choiceElem);
        paramsElem.put("choice",        choiceArray);
        paramsNode.put("driverType",    paramsElem);

        paramsElem  = mapper.createObjectNode();
        paramsElem.put("varType",      "String");
        paramsElem.put("title",        "Device Name");
        paramsElem.put("info",         "Unique free text name for device.");
        paramsNode.put("name",         paramsElem);

        paramsElem  = mapper.createObjectNode();
        paramsElem.put("varType",      "String");
        paramsElem.put("title",        "Device Description");
        paramsElem.put("info",         "Free text description of device.");
        paramsNode.put("description",  paramsElem);

        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "ChoiceArray");
        paramsElem.put("elements",     String.valueOf(ATMEGA328P_MAX_PORTS));
        paramsElem.put("title",        "Ports Locked Out");
        paramsElem.put("info",         "Ports which are locked and cannot be used.");
        for(LOCKED val : LOCKED.values())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", val.name());
            choiceElem.put("value", val.name());
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",       choiceArray);
        paramsNode.put("locked",       paramsElem);

        paramsElem  = mapper.createObjectNode();
        paramsElem.put("varType",      "String");
        paramsElem.put("title",        "UART Device");
        paramsElem.put("info",         "Device name or address, ie. /dev/ttyUSB0");
        paramsNode.put("uart",         paramsElem);

        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "Choice");
        paramsElem.put("title",        "UART Baud Rate");
        paramsElem.put("info",         "Baud rate of uart device.");
        for(String key : UART_BAUD_RATES.keySet())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", key);
            choiceElem.put("value", key);
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",       choiceArray);
        paramsNode.put("uartBaud",     paramsElem);

        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "Choice");
        paramsElem.put("title",        "UART DataBits");
        paramsElem.put("info",         "Data bits in packet.");
        for(String key : UART_DATABITS.keySet())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", key);
            choiceElem.put("value", key);
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",       choiceArray);
        paramsNode.put("uartDataBits", paramsElem);

        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "Choice");
        paramsElem.put("title",        "UART Parity");
        paramsElem.put("info",         "Parity of packet.");
        for(String key : UART_PARITY.keySet())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", key);
            choiceElem.put("value", key);
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",       choiceArray);
        paramsNode.put("uartParity",   paramsElem);

        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "Choice");
        paramsElem.put("title",        "UART StopBits");
        paramsElem.put("info",         "Stop bits at end of packet.");
        for(String key : UART_STOPBITS.keySet())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", key);
            choiceElem.put("value", key);
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",       choiceArray);
        paramsNode.put("uartStopBits", paramsElem);

        // Convert Enums and Maps to choice fields such that caller knows what values fit in each field.
        //
        ObjectNode optionsNode = mapper.createObjectNode();

        // Build up result set to be returned to caller.
        //
        result.put("device",  mapper.valueToTree(this));
        result.put("params",  paramsNode);
        result.put("options", optionsNode);
        return(result);
    }

    public TOGGLE getEnabled()
    {
        return(this.enabled);
    }

    public LOCKED getLocked(int i)
    {
        return(this.locked[i]);
    }

    public LOCKED[] getLocked()
    {
        return(this.locked);
    }

    public String getName()
    {
        return(this.name);
    }

    public String getDescription()
    {
        return(this.description);
    }

    public String getUart()
    {
        return(this.uart);
    }

    public int getUartBaud()
    {
        return(this.uartBaud);
    }

    public int getUartDataBits()
    {
        return(this.uartDataBits);
    }

    public String getUartParity()
    {
        return(this.uartParity);
    }

    public int getUartStopBits()
    {
        return(this.uartStopBits);
    }

    public int getMaxPorts()
    {
        return(ATMEGA328P_MAX_PORTS);
    }

    public int getRunInterval()
    {
        return(this.runInterval);
    }

    public void setDriverType(String driverType)
    {
        ;
    }

    public void setUuid(String uuid)
    {
        this.uuid = uuid;
    }

    public void setEnabled(TOGGLE enabled)
    {
        this.enabled = enabled;
    }

    public void setLocked(int i, LOCKED locked)
    {
        this.locked[i] = locked;
    }

    public void setLocked(LOCKED locked[])
    {
        this.locked = locked;
    }

    public void setName(String name)
    {
        this.name = name;
    }

    public void setDescription(String description)
    {
        this.description = description;
    }

    public void setUart(String uart)
    {
        this.uart = uart;
    }

    public void setUartBaud(int uartBaud)
    {
        this.uartBaud = uartBaud;
    }

    public void setUartDataBits(int uartDataBits)
    {
        this.uartDataBits = uartDataBits;
    }

    public void setUartParity(String uartParity)
    {
        this.uartParity = uartParity;
    }

    public void setUartStopBits(int uartStopBits)
    {
        this.uartStopBits = uartStopBits;
    }

    // Dummy method as MaxPorts is static.
    //
    public void setMaxPorts(int maxPorts)
    {
    }

    public void setRunInterval(int runInterval)
    {
        this.runInterval = runInterval;
    }

    // Action Methods. //

    // Method to set/reset a port state. TRUE=HIGH=1, FALSE=LOW=0
    //
    public void    bitWrite(int port, Boolean value)
    {
    }

    // Method to read a port state. TRUE=HIGH=1, FALSE=LOW=0
    //
    public Boolean bitRead(int port)
    {
        return(true);
    }

    // Method to duplicate a driver.
    //
    public Driver clone(Driver oldObj) throws Exception
    {
       ObjectOutputStream oos = null;
       ObjectInputStream ois = null;

       try {
          ByteArrayOutputStream bos = new ByteArrayOutputStream();                // A
          oos = new ObjectOutputStream(bos);                                      // B
          // serialize and pass the object
          oos.writeObject(oldObj);                                                // C
          oos.flush();                                                            // D
          ByteArrayInputStream bin = new ByteArrayInputStream(bos.toByteArray()); // E
          ois = new ObjectInputStream(bin);                                       // F

          // Deserialise and configure the driver UUID to make it unique.
          //
          Driver newDriver = (Driver)ois.readObject();
          newDriver.setUuid(UUID.randomUUID().toString());

          // return the new object
          return(newDriver);                                                      // G
       }
       catch(Exception e)
       {
          System.out.println("Exception in Driver clone = " + e);
          throw(e);
       }
       finally
       {
          oos.close();
          ois.close();
       }
    }

    // Method to configure the driver from a JSON structure.
    //
    public Boolean updateFromJSON(ObjectNode config, ObjectNode results)
    {
        ObjectMapper mapper = new ObjectMapper();
        ArrayNode errors    = mapper.createArrayNode();
        Boolean result      = true;
        String txtVal;
        ObjectNode error;

        try {
            System.out.println(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(config));

            // Parse each expected value, check for errors and store into local variable.
            //
            String driverType = S_ATMEGA328P;
            try {
                driverType = config.findValue("driverType").textValue();
            }
            catch (NullPointerException e) {
                // Not an error as this variable has not been provided.
            }
            // name
            String name = this.name;
            try {
                name = config.findValue("name").textValue();

                if(name.equals(""))
                {
                    error = mapper.createObjectNode();
                    error.put("name", "Name cannot be blank!");
                    errors.add(error);
                    result = false;
                }
            }
            catch (NullPointerException e) {
                // Not an error as this variable has not been provided.
            }
            // description
            String description = this.description;
            try {
                description = config.findValue("description").textValue();

                if(description.equals(""))
                {
                    error = mapper.createObjectNode();
                    error.put("description", "Description cannot be blank!");
                    errors.add(error);
                    result = false;
                }
            }
            catch (NullPointerException e) {
                // Not an error as this variable has not been provided.
            }
            // enabled
            TOGGLE enabled = this.enabled;
            try {
                enabled = TOGGLE.valueOf(config.findValue("enabled").textValue());
            }
            catch (IllegalArgumentException e) {
                error = mapper.createObjectNode();
                error.put("enabled", "Illegal value:" + config.findValue("enabled").textValue());
                errors.add(error);
                result = false;
            }
            catch (NullPointerException e) {
                // Not an error as this variable has not been provided.
            }
            // locked
            error = mapper.createObjectNode();
            LOCKED [] locked   = new LOCKED[ATMEGA328P_MAX_PORTS];
            for(int idx = 0; idx < ATMEGA328P_MAX_PORTS; idx++)
            {
                locked[idx] = LOCKED.UNLOCKED;
            }
            try {
                for(JsonNode jNode : config.findValue("locked"))
                {
                    int arrIdx = jNode.asInt(-1);
                    if(arrIdx < 0 || arrIdx > ATMEGA328P_MAX_PORTS)
                    {
                        error.put("locked", "Illegal port: " + jNode.asText());
                        errors.add(error);
                        result = false;
                    } else
                    {
                        locked[arrIdx] = LOCKED.LOCKED;
                    }
                }
            }
            catch (NullPointerException e) {
                // No given locked ports is legal.
                locked = this.locked;
            }
            // uart
            String uart = this.uart;
            try {
                uart = config.findValue("uart").textValue();

                if(uart.equals(""))
                {
                    error = mapper.createObjectNode();
                    error.put("uart", "Uart cannot be blank!");
                    errors.add(error);
                    result = false;
                }
            }
            catch (NullPointerException e) {
                // Not an error as this variable has not been provided.
            }
            // uartBaud
            Integer uartBaud = this.uartBaud;
            try {
                txtVal = config.findValue("uartBaud").textValue();
                uartBaud = UART_BAUD_RATES.get(txtVal);
                if(uartBaud == null)
                {
                    error = mapper.createObjectNode();
                    error.put("uartBaud", "Illegal value:" + txtVal);
                    errors.add(error);
                    result = false;
                }
            }
            catch (NullPointerException e) {
                // Not an error as this variable has not been provided.
            }
            // uartDatabits
            Integer uartDataBits = this.uartDataBits;
            try {
                txtVal = config.findValue("uartDataBits").textValue();
                uartDataBits = UART_DATABITS.get(txtVal);
                if(uartDataBits == null)
                {
                    error = mapper.createObjectNode();
                    error.put("uartDataBits", "Illegal value:" + txtVal);
                    errors.add(error);
                    result = false;
                }
            }
            catch (NullPointerException e) {
                // Not an error as this variable has not been provided.
            }
            // uartParity
            String uartParity = this.uartParity;
            try {
                txtVal = config.findValue("uartParity").textValue();
                uartParity = UART_PARITY.get(txtVal);
                if(uartParity == null)
                {
                    error = mapper.createObjectNode();
                    error.put("uartParity", "Illegal value:" + txtVal);
                    errors.add(error);
                    result = false;
                }
            }
            catch (NullPointerException e) {
                // Not an error as this variable has not been provided.
            }
            // uartStopBits
            Integer uartStopBits = this.uartStopBits;
            try {
                txtVal = config.findValue("uartStopBits").textValue();
                uartStopBits = UART_STOPBITS.get(txtVal);
                if(uartStopBits == null)
                {
                    error = mapper.createObjectNode();
                    error.put("uartStopBits", "Illegal value:" + txtVal);
                    errors.add(error);
                    result = false;
                }
            }
            catch (NullPointerException e) {
                // Not an error as this variable has not been provided.
            }
            results.put("errors", errors);

            // Only update the internal parameters if no errors occured.
            //
            if(result)
            {
                this.name         = name;
                this.description  = description;
                this.enabled      = enabled;
                this.locked       = locked;
                this.uart         = uart;
                this.uartBaud     = uartBaud;
                this.uartDataBits = uartDataBits;
                this.uartParity   = uartParity;
                this.uartStopBits = uartStopBits;

                // Output the stored values into the results set for verification.
                //
                results.put("uuid",    this.uuid);
                results.put("device",  mapper.valueToTree(this));
            }

            //System.out.println(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(config));
            System.out.println(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(results));
        }
        catch (JsonGenerationException e) {
            e.printStackTrace();
        }
        catch (JsonMappingException e) {
            e.printStackTrace();
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        return result;
    }

    // Method, to be called by a thread periodically, to synchronise the hardware with the desired cached state.
    // This method is only needed for hardware which cant be directly updated or is too costly in terms of I/O to update
    // 1 bit at a time.
    //
    @Override
    public void run() {
        LOG.finest("In Driver:" + this.name);

        // Only process if the driver is enabled.
        //
        if(this.enabled == TOGGLE.ENABLED)
        {
            ;
        }
    }
}
