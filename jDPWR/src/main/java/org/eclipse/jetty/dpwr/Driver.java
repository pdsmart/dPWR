/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            Driver.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     Driver - The primary device driver, base class for all Drivers providing standard
//                  default API methods.
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

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.*;
import java.util.concurrent.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.net.JarURLConnection;

// Jackson imports for serialization of this bean into JSON files.
//
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonSubTypes;  
import com.fasterxml.jackson.annotation.JsonTypeInfo;  
import com.fasterxml.jackson.annotation.JsonSubTypes.Type;  
import com.fasterxml.jackson.core.JsonGenerationException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
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


@JsonTypeInfo( use      = JsonTypeInfo.Id.NAME,
               include  = JsonTypeInfo.As.PROPERTY,
               property = "type"
             )
@JsonSubTypes({
               @Type(value = DriverATMega328P.class, name = "atmega328p"),
               @Type(value = DriverTCA6416A.class,   name = "tca6416a")
              }
             )
public interface Driver
{
    // ###################
    // # Driver Interface 
    // ###################
    //
    // Constants.
    //

    // Pseudo constants for port activity.
    public static final String                  S_DISABLED                  = "DISABLED";
    public static final int                     I_DISABLED                  = 0;
    public static final String                  S_ENABLED                   = "ENABLED";
    public static final int                     I_ENABLED                   = 1;
    public static final String                  S_UNLOCKED                  = "UNLOCKED";
    public static final int                     I_UNLOCKED                  = 0;
    public static final String                  S_LOCKED                    = "LOCKED";
    public static final int                     I_LOCKED                    = 1;

    // Enums.
    //
    public enum TOGGLE
    {
        DISABLED(I_DISABLED),                     // Toggle is DISABLED
        ENABLED(I_ENABLED);                       // Toggle is ENABLED.

        // In order to ensure known values instead or arbitary values to caller, use fixed integer constants
        // for each result code.
        private int toggle;
        TOGGLE(int code) { this.toggle = code; }
        public int getToggle() { return this.toggle; }
    }

    public enum LOCKED
    {
        UNLOCKED(I_UNLOCKED),                     // Target is UNLOCKED.
        LOCKED(I_LOCKED);                         // Target is LOCKED.

        // In order to ensure known values instead or arbitary values to caller, use fixed integer constants
        // for each result code.
        private int locked;
        LOCKED(int code) { this.locked = code; }
        public int getLocked() { return this.locked; }
    }

    // Maxims.
    //

    // Various methods to initialise driver.
    //
    default Boolean init(String name, String description, String uart, int baud, int databits, String parity, int stopbits)
    {
        return(false);
    }
    default Boolean init(String name, String description, int baseAddr)
    {
        return(false);
    }

    // Get Unique Id to identify the driver with (needed in a multi user environment).
    //
    public String getUuid();

    // Get the type of driver.
    //
    public String getDriverType();

    // Get maximum number of ports this driver handles.
    //
    public int getMaxPorts();

    // Get the time period in milliseconds, for calling the run() method.
    //
    public int getRunInterval();

    // Get flag to indicate if this driver is enabled.
    //
    public TOGGLE getEnabled();

    // Get flag to indicate if a given port is locked out (ie. not useable).
    //
    public LOCKED   getLocked(int i);
    public LOCKED[] getLocked();

    // Get name of the driver.
    //
    public String getName();

    // Get description of configurable parameters and options.
    //
    public ObjectNode getParamInfo();

    // Get description of the driver.
    //
    public String getDescription();

    // Dummy handler to set the type of driver.
    //
    public void setDriverType(String driverType);

    // Change the UUID of the driver from the default created during construction.
    //
    public void setUuid(String uuid);

    // Set the flag to indicate if a given port is locked out (ie. not useable).
    //
    public void setLocked(int i, LOCKED locked);
    public void setLocked(LOCKED[] locked);

    // Set the flag to indicate if driver is enabled.
    //
    public void setEnabled(TOGGLE enabled);

    // Method to set/reset a port state. TRUE=HIGH=1, FALSE=LOW=0
    //
    public void    bitWrite(int port, Boolean value);

    // Method to read a port state. TRUE=HIGH=1, FALSE=LOW=0
    //
    public Boolean bitRead(int port);

    // Method to clone a driver with a unique uuid.
    //
    public Driver clone(Driver oldObj) throws Exception;

    // Method to configure the driver from a JSON structure.
    //
    public Boolean updateFromJSON(ObjectNode config, ObjectNode results);

    // Method to update hardware if it cannot be updated directly or needs to group a set of updates
    // together prior to processing.
    //
    public void     run();
}
