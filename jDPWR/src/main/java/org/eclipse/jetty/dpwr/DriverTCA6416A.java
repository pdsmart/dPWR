/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            DriverTCA6416A.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     Driver::TCA6416A - A Driver package specifically to interact with the TCA6416A IC
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
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.*;
import java.util.concurrent.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.net.JarURLConnection;
import java.lang.reflect.Array;

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

public class DriverTCA6416A implements Driver, Runnable, java.io.Serializable
{
    // ################################
    // # TCA6416A Driver Configuration
    // ################################
    //
    // Constants.
    //
    // Maxims.
    public static final int                     TCA6416A_BASE_ADDR          = 289;
    public static final int                     TCA6416A_MAX_PORTS          = 16;
    public static final int                     DRIVER_PROCESSING_INTERVAL  = 5000; // Milliseconds between running the run() method.
    public static final int                     MIN_BASE_ADDR               = 0;
    public static final int                     MAX_BASE_ADDR               = 65536;    

    // Pseudo constants for devices.
    public static final String                  S_TCA6416A                  = "TCA6416A";
    public static final int                     I_TCA6416A                  = 1;
    public static final String                  S_NAME                      = "TCA6416A";
    public static final String                  S_DESCRIPTION               = "I2C 16port IO Expander";

    // Bean variables to control a device.
    //
    @JsonIgnore
    private static final Logger LOG = Logger.getLogger(DriverTCA6416A.class.getName());    
    @JsonIgnore
    private transient String    uuid;              // Unique ID to identify this driver instance.
    private int                 runInterval;       // Period of time in Milliseconds between calls to run() method.    
    private TOGGLE              enabled;           // Driver is enabled and functional.
    private LOCKED []           locked;            // Array of bits to indicate port locked out (not useable = LOCKED).    
    private String              name;              // Name associated with this device.
    private String              description;       // Description of device purpose.
    private int                 baseAddr;          // Base address for direct addressable devices, ie. TCA6416A

    // Constructor.
    //
    public DriverTCA6416A()
    {
        // Setup internal variables and initialise to defaults.
        //
        this.uuid        = UUID.randomUUID().toString();
        this.runInterval = DRIVER_PROCESSING_INTERVAL;
        this.enabled     = TOGGLE.DISABLED;
        this.locked      = new LOCKED[TCA6416A_MAX_PORTS];
        this.name        = S_NAME;
        this.description = S_DESCRIPTION;
        this.baseAddr    = TCA6416A_BASE_ADDR;

        // Initialise the base state of the arrays. Normally these arrays will take on values from a deserialization event.
        //
        for(int idx = 0; idx < TCA6416A_MAX_PORTS; idx++)
        {
            this.locked[idx] = LOCKED.UNLOCKED;
        }
    }
    public DriverTCA6416A(LOCKED[] locked)
    {
        // Call the base constructor.
        //
        this();

        // Use the locked array to setup the driver, locking out hardware ports which are not accessible.
        //
        if(locked.length < TCA6416A_MAX_PORTS)
        {
            LOG.warning("Illegal Locked Array given, should be " + TCA6416A_MAX_PORTS + " elements in size.");
        }
        for(int idx=0; idx < TCA6416A_MAX_PORTS; idx++)
        {
            if(locked.length >= TCA6416A_MAX_PORTS && locked[idx] != null && locked[idx] == LOCKED.LOCKED)
            {
                this.locked[idx] = LOCKED.LOCKED;
            } else
            {
                this.locked[idx] = LOCKED.UNLOCKED;
            }
        }
    }    
    public DriverTCA6416A(String name, String description, LOCKED[] locked, int baseAddr)
    {
        this(locked);
        Boolean result = init(name, description, baseAddr);
    }
    public DriverTCA6416A(String name, LOCKED[] locked, int baseAddr)
    {
        this(locked);
        Boolean result = init(name, S_DESCRIPTION, baseAddr);
    }

    // Various methods to initialise driver.
    //
    @Override
    public Boolean init(String name, String description, int baseAddr)
    {
        this.setBaseAddr(baseAddr);
        this.setName(name);
        this.setDescription(description);
        return(true);
    }

    // Getters and Setters.
    //
    public String getUuid()
    {
        return(this.uuid);
    }

    public String getDriverType()
    {
        return(S_TCA6416A);
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

        // Build up all parameters that can be changed along with editting information.
        //
        ObjectNode paramsElem  = mapper.createObjectNode();
        paramsElem.put("varType",      "Choice");
        paramsElem.put("title",        "Device Enabled");
        paramsElem.put("info",         "Device is enabled and active.");
        choiceArray = mapper.createArrayNode();
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
        choiceElem.put("label", S_TCA6416A);
        choiceElem.put("value", S_TCA6416A);
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
        paramsElem.put("varType",      "ChoiceArray");
        paramsElem.put("elements",     String.valueOf(TCA6416A_MAX_PORTS));
        paramsElem.put("title",        "Ports Locked Out");
        paramsElem.put("info",         "Ports which are locked and cannot be used.");
        paramsNode.put("locked",       paramsElem);

        paramsElem  = mapper.createObjectNode();
        paramsElem.put("varType",      "Integer");
        paramsElem.put("title",        "Base Address");
        paramsElem.put("info",         "Memory or I2C address of the TCA6416A controller." );
        paramsNode.put("baseAddr",     paramsElem);

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

    public int getBaseAddr()
    {
        return(this.baseAddr);
    }

    public int getMaxPorts()
    {
        return(TCA6416A_MAX_PORTS);
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

    public void setBaseAddr(int baseAddr)
    {
        this.baseAddr = baseAddr;
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

    // Action methods. //

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

    //public <T extends Enum<T>> T[] toEnums(String[] arr, Class<T> type)
    //{
    //    T[] result = (T[]) Array.newInstance(type, arr.length);
    //    for (int i = 0; i < arr.length; i++)
    //    {
    //        result[i] = Enum.valueOf(type, arr[i]);
    //    }
    //    return result;
    //}

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
            String driverType = S_TCA6416A;
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
            LOCKED [] locked   = new LOCKED[TCA6416A_MAX_PORTS];
            for(int idx = 0; idx < TCA6416A_MAX_PORTS; idx++)
            {
                locked[idx] = LOCKED.UNLOCKED;
            }
            try {
                for(JsonNode jNode : config.findValue("locked"))
                {
                    int arrIdx = jNode.asInt(-1);
                    if(arrIdx < 0 || arrIdx > TCA6416A_MAX_PORTS)
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
            // baseaddr
            int baseAddr = this.baseAddr;
            try {
                txtVal = config.findValue("baseAddr").textValue();
                baseAddr = Integer.parseInt(txtVal);

                if(txtVal.equals("") || baseAddr < 0 || baseAddr > 65535)
                {
                    error = mapper.createObjectNode();
                    error.put("baseAddr", "Illegal value given (range 0:65535)");
                    errors.add(error);
                    result = false;
                }
            }
            catch(NumberFormatException e)
            {
                baseAddr = -1;
            }
            catch (NullPointerException e) {
                // Not an error as this variable has not been provided.
            }
            results.put("errors", errors);

            // Only update the internal parameters if no errors occured.
            //
            if(result)
            {
                this.name        = name;
                this.description = description;
                this.baseAddr    = baseAddr;
                this.enabled     = enabled;
                this.locked      = locked;

                // Output the stored values into the results set for verification.
                //
                results.put("uuid",    this.uuid);
                results.put("device",  mapper.valueToTree(this));
            }

            System.out.println(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(config));
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
