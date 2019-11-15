/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            Port.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     Port - Class to encapsulate a single port element and all its functionality. Provides
//                  methods to manipulate its configuration and its control state.
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
import java.net.URI;
import java.net.URL;
import java.net.URLClassLoader;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.util.*;
import java.util.concurrent.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.text.*;
import java.net.JarURLConnection;
import java.time.LocalTime;
import java.lang.reflect.Array;

// Exceptions.
import java.io.IOException;
import java.io.FileNotFoundException;
import java.net.URISyntaxException;
import java.net.UnknownHostException;
import java.time.format.DateTimeParseException;

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

public class Port implements Runnable, java.io.Serializable
{
    // #############################
    // # Port Specific Configuration
    // #############################
    //
    // Constants.
    // 
    // Maxims.
    public static final int                     MAX_TIMERS                  = 4;
    public static final int                     MAX_PINGERS                 = 4;
    public static final int                     PORT_PROCESSING_INTERVAL    = 2000; // Milliseconds between running the run() method.

    // Ping Actions.
    public static final int                     I_PING_ACTION_NONE          = 0;
    public static final int                     I_PING_ACTION_OFF           = 1;
    public static final int                     I_PING_ACTION_ON            = 2;
    public static final int                     I_PING_ACTION_CYCLEOFF      = 3;
    public static final int                     I_PING_ACTION_CYCLEON       = 4;
    public static final String                  S_PING_ACTION_NONE          = "NONE";
    public static final String                  S_PING_ACTION_OFF           = "OFF";
    public static final String                  S_PING_ACTION_ON            = "ON";
    public static final String                  S_PING_ACTION_CYCLEOFF      = "CYCLEOFF";
    public static final String                  S_PING_ACTION_CYCLEON       = "CYCLEON";    

    // Pseudo constants for port activity.
    public static final String                  S_DISABLED                  = "DISABLED";
    public static final int                     I_DISABLED                  = 0;
    public static final String                  S_ENABLED                   = "ENABLED";
    public static final int                     I_ENABLED                   = 1;
    public static final String                  S_OFF                       = "OFF";
    public static final int                     I_OFF                       = 0;
    public static final String                  S_ON                        = "ON";
    public static final int                     I_ON                        = 1;
    public static final String                  S_CURRENT                   = "CURRENT";
    public static final int                     I_CURRENT                   = 2;
    public static final String                  S_LOW                       = "LOW";
    public static final int                     I_LOW                       = 0;
    public static final String                  S_HIGH                      = "HIGH";
    public static final int                     I_HIGH                      = 1;
    public static final String                  S_OUTPUT                    = "OUTPUT";
    public static final int                     I_OUTPUT                    = 0;
    public static final String                  S_INPUT                     = "INPUT";
    public static final int                     I_INPUT                     = 1;
    public static final String                  S_UNLOCKED                  = "UNLOCKED";
    public static final int                     I_UNLOCKED                  = 0;
    public static final String                  S_LOCKED                    = "LOCKED";
    public static final int                     I_LOCKED                    = 1;
    public static final String                  S_OR                        = "OR";
    public static final int                     I_OR                        = 0;
    public static final String                  S_AND                       = "AND";
    public static final int                     I_AND                       = 1;    

    // Pseudo constants for types of ping.
    public static final int                     I_PING_ICMP                 = 0;
    public static final String                  S_PING_ICMP                 = "ICMP";
    public static final int                     I_PING_TCP                  = 1;
    public static final String                  S_PING_TCP                  = "TCP";
    public static final int                     I_PING_UDP                  = 2;
    public static final String                  S_PING_UDP                  = "UDP";    

    // Enums.
    //
    public enum MODE
    {
        INPUT(I_INPUT),                            // Mode is INPUT
        OUTPUT(I_OUTPUT);                          // Mode is OUTPUT.

        // In order to ensure known values instead or arbitary values to caller, use fixed integer constants
        // for each result code.
        private int mode;
        MODE(int code) { this.mode = code; }
        public int getMode() { return this.mode; }
    }

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

    public enum LEVEL
    {
        LOW(I_LOW),                               // Level is LOW.
        CURRENT(I_CURRENT),                       // Level remains as is.
        HIGH(I_HIGH);                             // Level is HIGH.

        // In order to ensure known values instead or arbitary values to caller, use fixed integer constants
        // for each result code.
        private int level;
        LEVEL(int code) { this.level = code; }
        public int getLevel() { return this.level; }
    }

    public enum STATE
    {
        OFF(I_OFF),                               // State is OFF.
        ON(I_ON);                                 // State is ON.

        // In order to ensure known values instead or arbitary values to caller, use fixed integer constants
        // for each result code.
        private int state;
        STATE(int code) { this.state = code; }
        public int getState() { return this.state; }
    }

    public enum ACTION
    {
        NONE(I_PING_ACTION_NONE),                 // Take no action.
        OFF(I_PING_ACTION_OFF),                   // Turn port off.
        ON(I_PING_ACTION_ON),                     // Turn port on.
        CYCLE_OFF(I_PING_ACTION_CYCLEOFF),        // Cycle port Off then ON.
        CYCLE_ON(I_PING_ACTION_CYCLEON);          // Cycle port On then OFF.

        // In order to ensure known values instead or arbitary values to caller, use fixed integer constants
        // for each result code.
        private int action;
        ACTION(int code) { this.action = code; }
        public int getAction() { return this.action; }
    }

    public enum PINGTYPE
    {
        ICMP(I_PING_ICMP),                        // Ping via ICMP.
        TCP(I_PING_TCP),                          // Ping via TCP connect.
        UDP(I_PING_UDP);                          // Ping via UDP connect.

        // In order to ensure known values instead or arbitary values to caller, use fixed integer constants
        // for each result code.
        private int type;
        PINGTYPE(int code) { this.type = code; }
        public int getType() { return this.type; }
    }

    public enum LOGIC
    {
        OR(I_OR),                                 // Logic OR Operator.
        AND(I_AND);                               // Logic AND Operator.

        // In order to ensure known values instead or arbitary values to caller, use fixed integer constants
        // for each result code.
        private int logic;
        LOGIC(int code) { this.logic = code; }
        public int getLogic() { return this.logic; }
    }

    // Lookup tables.
    public static final Map<Integer,String>     I_ON_OFF                    = createOnOffIntegerMap();
    public static final Map<String, Integer>    S_ON_OFF                    = createOnOffStringMap();
    public static final Map<Integer,String>     I_HIGH_LOW                  = createHighLowIntegerMap();
    public static final Map<String, Integer>    S_HIGH_LOW                  = createHighLowStringMap();
    public static final Map<Integer,String>     I_INPUT_OUTPUT              = createInputOutputIntegerMap();
    public static final Map<String, Integer>    S_INPUT_OUTPUT              = createInputOutputStringMap();
    public static final Map<Integer,String>     I_ENABLED_DISABLED          = createEnabledDisabledIntegerMap();
    public static final Map<String, Integer>    S_ENABLED_DISABLED          = createEnabledDisabledStringMap();
    public static final Map<Integer,String>     I_LOCKED_UNLOCKED           = createLockedUnlockedIntegerMap();
    public static final Map<String, Integer>    S_LOCKED_UNLOCKED           = createLockedUnlockedStringMap();
    public static final Map<Integer,String>     DOW_ABBR                    = createDOWAbbrMap();
    public static final Map<String, Integer>    LOGIC_OPER                  = createLogicOperMap();
    public static final Map<Integer,String>     I_PING_ACTION               = createPingActionIntegerMap();
    public static final Map<String, Integer>    S_PING_ACTION               = createPingActionStringMap();
    public static final Map<Integer,String>     I_CONV_POST_VALUES          = createConvPostValuesIntegerMap();
    public static final Map<String, Integer>    S_CONV_POST_VALUES          = createConvPostValuesStringMap();
    public static final Map<String, String>     PING_TYPES                  = createPingTypesMap();

    // Defaults.
    public static final PINGTYPE                DEFAULT_PING_TYPE           = PINGTYPE.ICMP;
    public static final int                     DEFAULT_PING_PORT           = 80;
    public static final String                  DEFAULT_PING_ADDR           = "127.0.0.1";
    public static final int                     DEFAULT_PING_WAIT_TIME      = 60;
    public static final int                     DEFAULT_INTER_PING_TIME     = 60;
    public static final int                     DEFAULT_PING_FAIL_MAX       = 5;
    public static final int                     DEFAULT_PING_SUCCESS_MAX    = 5;
    public static final LOGIC                   DEFAULT_PING_LOGIC_FAIL     = LOGIC.OR;
    public static final LOGIC                   DEFAULT_PING_LOGIC_SUCCESS  = LOGIC.AND;
    public static final ACTION                  DEFAULT_PING_ACTION_FAIL    = ACTION.CYCLE_OFF;
    public static final ACTION                  DEFAULT_PING_ACTION_SUCCESS = ACTION.CYCLE_ON;
    public static final int                     DEFAULT_PING_CYCLE_FAIL     = 10;
    public static final int                     DEFAULT_PING_CYCLE_SUCCESS  = 10;

    // Bean variables to control a port.
    //
    @JsonIgnore
    private static final Logger LOG = Logger.getLogger(Port.class.getName());    
    @JsonIgnore
    private transient Driver     driver;                 // Driver which processes this port.
    @JsonIgnore
    private transient String     uuid;                   // Unique ID to identify this port instance.
    private transient int        runInterval;            // Period of time in milliseconds between calls to run() method.
    @JsonIgnore
    private transient ScheduledExecutorService executor; // Thread executor handle to process long running tasks.
    @JsonIgnore
    private transient ScheduledFuture[] future;          // Thread future value result set.
    @JsonIgnore
    private transient Boolean    portUpdated;            // Flag to signal when a config change has taken place.
    @JsonIgnore
    private transient Boolean    pingersActive;          // Flag to indicate if the pingers threads are active.
    @JsonIgnore
    private transient STATE      state;                  // Current value of port.
    private TOGGLE               enabled;                // Enable I/O port: DISABLED or ENABLED
    private int                  driverPortNo;           // Physical port number on the device.
    private String               driverName;             // Unique name of the associated driver.
    private String               name;                   // Name associated with the I/O Port
    private String               description;            // Description of I/O Port purpose.
    private MODE                 mode;                   // Configure I/O port: OUTPUT or INPUT
    private LEVEL                powerUpLevel;           // Set output port level to this state at Power Up: LOW or HIGH.
    private LEVEL                powerDownLevel;         // Set output port level to this state at Power Down: LOW or HIGH.
    private LEVEL                onLevel;                // Level which is active for this port: LOW or HIGH.
    private TOGGLE[]             timeEnabled;            // TIME #0: DISABLED or ENABLED
    private LocalTime[]          timeOn;                 // 'HH:MM:SS array' - set port active at this time.
    private LocalTime[]          timeOff;                // 'HH:MM:SS array' - set port inactive at this time.
    private TOGGLE[]             pingEnabled;            // PING #0 mechanism: DISABLED or ENABLED. (Ping an address and take an action.)
    private InetAddress[]        pingAddr;               // IP or FQDN to ping in order to see if destination is alive.
    private PINGTYPE[]           pingType;               // Type of PING to use, ie. ICMP, TCP or UDP.
    private int[]                pingPort;               // Port to use with TCP/UDP methods of ping.
    private int[]                pingAddrWaitTime;       // Period, in seconds, to wait for a ping response from destination.
    private int[]                pingToPingTime;         // Period, in seconds, between successive ping operations.
    private int[]                pingFailCount;          // Number of ping failures before a PING ACTION ON FAIL occurs.
    private int[]                pingSuccessCount;       // Number of ping success responses before a PING ACTION ON SUCCESS occurs.
    @JsonIgnore
    private int[]                failCount;              // Number of current ping failures per pinger.
    @JsonIgnore
    private int[]                successCount;           // Number of current ping successes per pinger.
    private LOGIC                pingLogicForFail;       // Logic operator between Ping #0..#n before a PING ACTION occurs for FAIL Count: OR or AND.
    private LOGIC                pingLogicForSuccess;    // Logic operator between Ping #0..#n before a PING ACTION occurs for SUCCESS Count: OR or AND.
    private ACTION               pingActionOnFail;       // NONE|OFF|ON|CYCLEON|CYCLEOFF
                                                         //  ^- Take no action.
                                                         //       ^- Set port output inactive.
                                                         //           ^- Set port output active.
                                                         //              ^- Set port output active, wait ACTION PAUSE TIME, set port inactive.
                                                         //                      ^- Set port output inactive, wait ACTION PAUSE TIME, set port active.
    private ACTION               pingActionOnSuccess;    // as ON FAIL above.
    private int                  pingActionSuccessTime;  // Period, in seconds, used in cycleon/cycleoff above for success action.
    private int                  pingActionFailTime;     // Period, in seconds, used in cycleon/cycleoff above for fail action.
    private int                  resetTime;              // Not used.

    // Static map initialisers.
    //
    private static Map<Integer, String> createOnOffIntegerMap()
    {
        Map<Integer, String> result = new HashMap<Integer, String>();
        result.put(I_OFF,     S_OFF);
        result.put(I_ON,      S_ON);
        result.put(I_CURRENT, S_CURRENT);
        return Collections.unmodifiableMap(result);
    }
    private static Map<String, Integer> createOnOffStringMap()
    {
        Map<String, Integer> result = new HashMap<String, Integer>();
        result.put(S_OFF,     I_OFF);
        result.put(S_ON,      I_ON);
        result.put(S_CURRENT, I_CURRENT);
        return Collections.unmodifiableMap(result);
    }
    private static Map<Integer, String> createHighLowIntegerMap()
    {
        Map<Integer, String> result = new HashMap<Integer, String>();
        result.put(I_LOW,     S_LOW);
        result.put(I_HIGH,    S_HIGH);
        return Collections.unmodifiableMap(result);
    }
    private static Map<String, Integer> createHighLowStringMap()
    {
        Map<String, Integer> result = new HashMap<String, Integer>();
        result.put(S_LOW,     I_LOW);
        result.put(S_HIGH,    I_HIGH);
        return Collections.unmodifiableMap(result);
    }
    private static Map<Integer, String> createInputOutputIntegerMap()
    {
        Map<Integer, String> result = new HashMap<Integer, String>();
        result.put(I_INPUT,   S_INPUT);
        result.put(I_OUTPUT,  S_OUTPUT);
        return Collections.unmodifiableMap(result);
    }
    private static Map<String, Integer> createInputOutputStringMap()
    {
        Map<String, Integer> result = new HashMap<String, Integer>();
        result.put(S_INPUT,   I_INPUT);
        result.put(S_OUTPUT,  I_OUTPUT);
        return Collections.unmodifiableMap(result);
    }
    private static Map<Integer, String> createEnabledDisabledIntegerMap()
    {
        Map<Integer, String> result = new HashMap<Integer, String>();
        result.put(I_ENABLED, S_ENABLED);
        result.put(I_DISABLED,S_DISABLED);
        return Collections.unmodifiableMap(result);
    }
    private static Map<String, Integer> createEnabledDisabledStringMap()
    {
        Map<String, Integer> result = new HashMap<String, Integer>();
        result.put(S_ENABLED, I_ENABLED);
        result.put(S_DISABLED,I_DISABLED);
        return Collections.unmodifiableMap(result);
    }
    private static Map<Integer, String> createLockedUnlockedIntegerMap()
    {
        Map<Integer, String> result = new HashMap<Integer, String>();
        result.put(I_UNLOCKED,S_UNLOCKED);
        result.put(I_LOCKED,  S_LOCKED);
        return Collections.unmodifiableMap(result);
    }
    private static Map<String, Integer> createLockedUnlockedStringMap()
    {
        Map<String, Integer> result = new HashMap<String, Integer>();
        result.put(S_UNLOCKED,I_UNLOCKED);
        result.put(S_LOCKED,  I_LOCKED);
        return Collections.unmodifiableMap(result);
    }
    private static Map<Integer, String> createDOWAbbrMap()
    {
        Map<Integer, String> result = new HashMap<Integer, String>();
        result.put(0,     "Mon");
        result.put(1,     "Tue");
        result.put(2,     "Wed");
        result.put(3,     "Thu");
        result.put(4,     "Fri");
        result.put(5,     "Sat");
        result.put(6,     "Sun");
        return Collections.unmodifiableMap(result);
    }
    private static Map<String, Integer> createLogicOperMap()
    {
        Map<String, Integer> result = new HashMap<String, Integer>();
        result.put(S_OR,     I_OR);
        result.put(S_AND,    I_AND);
        return Collections.unmodifiableMap(result);
    }
    private static Map<Integer, String> createPingActionIntegerMap()
    {
        Map<Integer, String> result = new HashMap<Integer, String>();
        result.put(I_PING_ACTION_NONE,     S_PING_ACTION_NONE);
        result.put(I_PING_ACTION_OFF,      S_PING_ACTION_OFF);
        result.put(I_PING_ACTION_ON,       S_PING_ACTION_ON);
        result.put(I_PING_ACTION_CYCLEOFF, S_PING_ACTION_CYCLEOFF);
        result.put(I_PING_ACTION_CYCLEON,  S_PING_ACTION_CYCLEON);
        return Collections.unmodifiableMap(result);
    }
    private static Map<String, Integer> createPingActionStringMap()
    {
        Map<String, Integer> result = new HashMap<String, Integer>();
        result.put(S_PING_ACTION_NONE,     I_PING_ACTION_NONE);
        result.put(S_PING_ACTION_OFF,      I_PING_ACTION_OFF);
        result.put(S_PING_ACTION_ON,       I_PING_ACTION_ON);
        result.put(S_PING_ACTION_CYCLEOFF, I_PING_ACTION_CYCLEOFF);
        result.put(S_PING_ACTION_CYCLEON,  I_PING_ACTION_CYCLEON);
        return Collections.unmodifiableMap(result);
    }
    private static Map<Integer, String> createConvPostValuesIntegerMap()
    {
        Map<Integer, String> result = new HashMap<Integer, String>();
        result.put(I_OFF,     S_OFF);
        result.put(I_ON,      S_ON);
        result.put(I_CURRENT, S_CURRENT);
        result.put(I_LOW,     S_LOW);
        result.put(I_HIGH,    S_HIGH);
        result.put(I_OUTPUT,  S_OUTPUT);
        result.put(I_INPUT,   S_INPUT);
        result.put(I_DISABLED,S_DISABLED);
        result.put(I_ENABLED, S_ENABLED);
        result.put(I_UNLOCKED,S_UNLOCKED);
        result.put(I_LOCKED,  S_LOCKED);
        result.put(I_AND,     S_AND);
        result.put(I_OR,      S_OR);
        return Collections.unmodifiableMap(result);
    }
    private static Map<String, Integer> createConvPostValuesStringMap()
    {
        Map<String, Integer> result = new HashMap<String, Integer>();
        result.put(S_OFF,     I_OFF);
        result.put(S_ON,      I_ON);
        result.put(S_CURRENT, I_CURRENT);
        result.put(S_LOW,     I_LOW);
        result.put(S_HIGH,    I_HIGH);
        result.put(S_OUTPUT,  I_OUTPUT);
        result.put(S_INPUT,   I_INPUT);
        result.put(S_DISABLED,I_DISABLED);
        result.put(S_ENABLED, I_ENABLED);
        result.put(S_UNLOCKED,I_UNLOCKED);
        result.put(S_LOCKED,  I_LOCKED);
        result.put(S_AND,     I_AND);
        result.put(S_OR,      I_OR);
        return Collections.unmodifiableMap(result);
    }
    private static Map<String, String> createPingTypesMap()
    {
        Map<String, String> result = new HashMap<String, String>();
        result.put(S_PING_ICMP,   "icmp");
        result.put(S_PING_TCP,    "tcp");
        result.put(S_PING_UDP,    "udp");
        return Collections.unmodifiableMap(result);
    }


    // CONSTRUCTORS.
    //
    public Port()
    {
        LOG.finer("Constructing Port (default).");

        // Initialise internal variables.
        //
        this.uuid             = UUID.randomUUID().toString();
        this.executor         = Executors.newScheduledThreadPool(1);
        this.future           = new ScheduledFuture[MAX_TIMERS];
        this.portUpdated      = false;
        this.pingersActive    = false;
        this.runInterval      = PORT_PROCESSING_INTERVAL;
        this.state            = STATE.OFF;
        this.timeOn           = new LocalTime[MAX_TIMERS];
        this.timeOff          = new LocalTime[MAX_TIMERS];
        this.timeEnabled      = new TOGGLE[MAX_TIMERS];
        for(int i = 0; i < MAX_TIMERS; i++)
        {
            this.timeOn[i]           = LocalTime.of(0,0,0);
            this.timeOff[i]          = LocalTime.of(0,0,0);
            this.timeEnabled[i]      = TOGGLE.DISABLED;
        }
        this.pingEnabled      = new TOGGLE[MAX_PINGERS];
        this.pingAddr         = new InetAddress[MAX_PINGERS];
        this.pingType         = new PINGTYPE[MAX_PINGERS];
        this.pingPort         = new int[MAX_PINGERS];
        this.pingAddrWaitTime = new int[MAX_PINGERS];
        this.pingToPingTime   = new int[MAX_PINGERS];
        this.pingFailCount    = new int[MAX_PINGERS];
        this.pingSuccessCount = new int[MAX_PINGERS];
        this.failCount        = new int[MAX_PINGERS];
        this.successCount     = new int[MAX_PINGERS];
    }
    //
    public Port(Driver driver, int driverPortNo, String driverName, String name, String description)
    {
        this();
        LOG.finer("Constructing port using: driver=" + driver + ", driverPortNo=" + driverPortNo + ", driverName=" + driverName +
                  ", name=" + name + ", description=" + description);

        this.driver         = driver;
        this.enabled        = TOGGLE.DISABLED;
        this.driverPortNo   = driverPortNo;
        this.driverName     = driverName;
        this.name           = name;
        this.description    = description;
        this.mode           = MODE.INPUT;
        this.powerUpLevel   = LEVEL.LOW;
        this.powerDownLevel = LEVEL.CURRENT;
        this.onLevel        = LEVEL.HIGH;
        for(int i = 0; i < MAX_PINGERS; i++)
        {
            this.pingEnabled[i]      = TOGGLE.DISABLED;
            try {
                this.pingAddr[i]     = InetAddress.getByName(DEFAULT_PING_ADDR);
            } catch (UnknownHostException e) { ; }
            this.pingType[i]         = DEFAULT_PING_TYPE;
            this.pingPort[i]         = DEFAULT_PING_PORT;
            this.pingAddrWaitTime[i] = DEFAULT_PING_WAIT_TIME;
            this.pingToPingTime[i]   = DEFAULT_INTER_PING_TIME;
            this.pingFailCount[i]    = DEFAULT_PING_FAIL_MAX;
            this.pingSuccessCount[i] = DEFAULT_PING_SUCCESS_MAX;
            this.failCount[i]        = 0;
            this.successCount[i]     = 0;
        }
        this.pingLogicForFail        = DEFAULT_PING_LOGIC_FAIL;
        this.pingLogicForSuccess     = DEFAULT_PING_LOGIC_SUCCESS;
        this.pingActionOnFail        = DEFAULT_PING_ACTION_FAIL;
        this.pingActionOnSuccess     = DEFAULT_PING_ACTION_SUCCESS;
        this.pingActionSuccessTime   = DEFAULT_PING_CYCLE_SUCCESS;
        this.pingActionFailTime      = DEFAULT_PING_CYCLE_FAIL;
        this.resetTime               = 0;
    }


    // Getters and Setters
    //
    public String getUuid()
    {
        return(this.uuid);
    }

    public Driver getDriver()
    {
        return(this.driver);
    }

    public STATE getState()
    {
        return(this.state);
    }

    public TOGGLE getEnabled()
    {
        return(this.enabled);
    }

    public int getDriverPortNo()
    {
        return(this.driverPortNo);
    }

    public String getDriverName()
    {
        return(this.driverName);
    }

    public String getName()
    {
        return(this.name);
    }

    public String getDescription()
    {
        return(this.description);
    }

    public MODE getMode()
    {
        return(this.mode);
    }

    public LEVEL getPowerUpLevel()
    {
        return(this.powerUpLevel);
    }

    public LEVEL getPowerDownLevel()
    {
        return(this.powerDownLevel);
    }

    public LEVEL getOnLevel()
    {
        return(this.onLevel);
    }

    public String getTimeOn(int i)
    {
        // To the outside world, only return a string equivalent of time.
        //
        return(this.timeOn[i].toString());
    }

    public String[] getTimeOn()
    {
        String[] results = new String[this.timeOn.length];
        for(int idx=0; idx < this.timeOn.length; idx++)
        {
            results[idx] = this.getTimeOn(idx);
        }
        return(results);
    }

    public String getTimeOff(int i)
    {
        // To the outside world, only return a string equivalent of time.
        //
        return(this.timeOff[i].toString());
    }

    public String[] getTimeOff()
    {
        String[] results = new String[this.timeOff.length];
        for(int idx=0; idx < this.timeOff.length; idx++)
        {
            results[idx] = this.getTimeOff(idx);
        }
        return(results);
    }

    public TOGGLE getTimeEnabled(int i)
    {
        return(this.timeEnabled[i]);
    }

    public TOGGLE[] getTimeEnabled()
    {
        return(this.timeEnabled);
    }

    public TOGGLE getPingEnabled(int i)
    {
        return(this.pingEnabled[i]);
    }

    public TOGGLE[] getPingEnabled()
    {
        return(this.pingEnabled);
    }

    public InetAddress getPingAddr(int i)
    {
        return(this.pingAddr[i]);
    }

    public InetAddress[] getPingAddr()
    {
        return(this.pingAddr);
    }

    public PINGTYPE getPingType(int i)
    {
        return(this.pingType[i]);
    }

    public PINGTYPE[] getPingType()
    {
        return(this.pingType);
    }

    public int getPingPort(int i)
    {
        return(this.pingPort[i]);
    }

    public int[] getPingPort()
    {
        return(this.pingPort);
    }

    public int getPingAddrWaitTime(int i)
    {
        return(this.pingAddrWaitTime[i]);
    }

    public int[] getPingAddrWaitTime()
    {
        return(this.pingAddrWaitTime);
    }

    public int getPingToPingTime(int i)
    {
        return(this.pingToPingTime[i]);
    }

    public int[] getPingToPingTime()
    {
        return(this.pingToPingTime);
    }

    public int getPingFailCount(int i)
    {
        return(this.pingFailCount[i]);
    }

    public int[] getPingFailCount()
    {
        return(this.pingFailCount);
    }

    public int getPingSuccessCount(int i)
    {
        return(this.pingSuccessCount[i]);
    }

    public int[] getPingSuccessCount()
    {
        return(this.pingSuccessCount);
    }

    public LOGIC getPingLogicForFail()
    {
        return(this.pingLogicForFail);
    }

    public LOGIC getPingLogicForSuccess()
    {
        return(this.pingLogicForSuccess);
    }

    public ACTION getPingActionOnFail()
    {
        return(this.pingActionOnFail);
    }

    public ACTION getPingActionOnSuccess()
    {
        return(this.pingActionOnSuccess);
    }

    public int getPingActionSuccessTime()
    {
        return(this.pingActionSuccessTime);
    }

    public int getPingActionFailTime()
    {
        return(this.pingActionFailTime);
    }

    public int getResetTime()
    {
        return(this.resetTime);
    }

    public int getRunInterval()
    {
        return(this.runInterval);
    }

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
        // enabled
        ObjectNode paramsElem  = mapper.createObjectNode();
        paramsElem.put("varType",      "Choice");
        paramsElem.put("title",        "Port Enabled");
        paramsElem.put("info",         "Port is enabled and active.");
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
        // name
        paramsElem  = mapper.createObjectNode();
        paramsElem.put("varType",      "String");
        paramsElem.put("title",        "Port Name");
        paramsElem.put("info",         "Unique free text name for port.");
        paramsNode.put("name",         paramsElem);
        // description
        paramsElem  = mapper.createObjectNode();
        paramsElem.put("varType",      "String");
        paramsElem.put("title",        "Port Description");
        paramsElem.put("info",         "Free text description of port.");
        paramsNode.put("description",  paramsElem);
        // mode
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "Choice");
        paramsElem.put("title",        "Mode");
        paramsElem.put("info",         "Function of port.");
        for(MODE val : MODE.values())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", val.name());
            choiceElem.put("value", val.name());
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",       choiceArray);
        paramsNode.put("mode",         paramsElem);
        // powerUpLevel
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "Choice");
        paramsElem.put("title",        "Power Up Level");
        paramsElem.put("info",         "Level port is set to on app start.");
        for(LEVEL val : LEVEL.values())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", val.name());
            choiceElem.put("value", val.name());
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",       choiceArray);
        paramsNode.put("powerUpLevel", paramsElem);
        // powerDownLevel
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "Choice");
        paramsElem.put("title",        "Power Down Level");
        paramsElem.put("info",         "Level port is set to on app close.");
        for(LEVEL val : LEVEL.values())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", val.name());
            choiceElem.put("value", val.name());
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",         choiceArray);
        paramsNode.put("powerDownLevel", paramsElem);
        // onLevel
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "Choice");
        paramsElem.put("title",        "On Level");
        paramsElem.put("info",         "Level which is active for this port.");
        for(LEVEL val : LEVEL.values())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", val.name());
            choiceElem.put("value", val.name());
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",         choiceArray);
        paramsNode.put("onLevel", paramsElem);
        // timeEnabled
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "ChoiceArray");
        paramsElem.put("elements",     String.valueOf(MAX_TIMERS));
        paramsElem.put("title",        "Timer Enabled");
        paramsElem.put("info",         "Enabled timers.");
        for(TOGGLE val : TOGGLE.values())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", val.name());
            choiceElem.put("value", val.name());
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",      choiceArray);
        paramsNode.put("timeEnabled", paramsElem);
        // timeOn
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "TimeArray");
        paramsElem.put("elements",     String.valueOf(MAX_TIMERS));
        paramsElem.put("title",        "timeOn");
        paramsElem.put("info",         "Enter time when port turns on.");
        paramsNode.put("timeOn",       paramsElem);
        // timeOff
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "TimeArray");
        paramsElem.put("elements",     String.valueOf(MAX_TIMERS));
        paramsElem.put("title",        "Off Time");
        paramsElem.put("info",         "Enter time when port turns off.");
        paramsNode.put("timeOff",       paramsElem);
        // pingEnabled
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "ChoiceArray");
        paramsElem.put("elements",     String.valueOf(MAX_PINGERS));
        paramsElem.put("title",        "Ping Enabled");
        paramsElem.put("info",         "Enabled pingers.");
        for(TOGGLE val : TOGGLE.values())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", val.name());
            choiceElem.put("value", val.name());
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",      choiceArray);
        paramsNode.put("pingEnabled", paramsElem);
        // pingAddr
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "IPArray");
        paramsElem.put("elements",     String.valueOf(MAX_PINGERS));
        paramsElem.put("title",        "Ping Address");
        paramsElem.put("info",         "Enter dns or ip address to ping.");
        paramsNode.put("pingAddr",     paramsElem);
        // pingType
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "ChoiceArray");
        paramsElem.put("elements",     String.valueOf(MAX_PINGERS));
        paramsElem.put("title",        "Type of Ping");
        paramsElem.put("info",         "Type of ping to use.");
        for(PINGTYPE val : PINGTYPE.values())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", val.name());
            choiceElem.put("value", val.name());
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",      choiceArray);
        paramsNode.put("pingType",    paramsElem);
        // pingPort
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "NumericArray");
        paramsElem.put("elements",     String.valueOf(MAX_PINGERS));
        paramsElem.put("title",        "Ping Port");
        paramsElem.put("info",         "Port to ping.");
        paramsNode.put("pingPort",     paramsElem);
        // pingAddrWaitTime
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "NumericArray");
        paramsElem.put("elements",     String.valueOf(MAX_PINGERS));
        paramsElem.put("title",        "Ping Wait Time");
        paramsElem.put("info",         "Period, in seconds, to wait for a ping response.");
        paramsNode.put("pingAddrWaitTime", paramsElem);
        // pingToPingTime
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "NumericArray");
        paramsElem.put("elements",     String.valueOf(MAX_PINGERS));
        paramsElem.put("title",        "Ping to Ping Time");
        paramsElem.put("info",         "Period, in seconds, between successive ping operations.");
        paramsNode.put("pingToPingTime", paramsElem);
        // pingFailCount
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "NumericArray");
        paramsElem.put("elements",     String.valueOf(MAX_PINGERS));
        paramsElem.put("title",        "Ping Fail Count");
        paramsElem.put("info",         "Number of ping failures before an ACTION ON FAIL event occurs.");
        paramsNode.put("pingFailCount", paramsElem);
        // pingSuccessCount
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "NumericArray");
        paramsElem.put("elements",     String.valueOf(MAX_PINGERS));
        paramsElem.put("title",        "Ping Success Count");
        paramsElem.put("info",         "Number of successful pings before an ACTION ON SUCCESS event occurs.");
        paramsNode.put("pingSuccessCount", paramsElem);
        // pingLogicForFail
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "ChoiceArray");
        paramsElem.put("elements",     String.valueOf(MAX_PINGERS));
        paramsElem.put("title",        "Ping Fail Logic Operator");
        paramsElem.put("info",         "Logic operator to use between all Ping fail counters.");
        for(LOGIC val : LOGIC.values())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", val.name());
            choiceElem.put("value", val.name());
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",      choiceArray);
        paramsNode.put("pingLogicForFail",    paramsElem);
        // pingLogicForSuccess
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "ChoiceArray");
        paramsElem.put("elements",     String.valueOf(MAX_PINGERS));
        paramsElem.put("title",        "Ping Success Logic Operator");
        paramsElem.put("info",         "Logic operator to use between all Ping success counters.");
        for(LOGIC val : LOGIC.values())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", val.name());
            choiceElem.put("value", val.name());
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",      choiceArray);
        paramsNode.put("pingSuccessForFail",    paramsElem);
        // pingActionOnFail
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "ChoiceArray");
        paramsElem.put("elements",     String.valueOf(MAX_PINGERS));
        paramsElem.put("title",        "Ping Action on Fail");
        paramsElem.put("info",         "Action to perform when a fail event is triggered.");
        for(ACTION val : ACTION.values())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", val.name());
            choiceElem.put("value", val.name());
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",      choiceArray);
        paramsNode.put("pingActionOnFail", paramsElem);
        // pingActionOnSuccess
        paramsElem  = mapper.createObjectNode();
        choiceArray = mapper.createArrayNode();
        paramsElem.put("varType",      "ChoiceArray");
        paramsElem.put("elements",     String.valueOf(MAX_PINGERS));
        paramsElem.put("title",        "Ping Action on Success");
        paramsElem.put("info",         "Action to perform when a success event is triggered.");
        for(ACTION val : ACTION.values())
        {
            choiceElem  = mapper.createObjectNode();
            choiceElem.put("label", val.name());
            choiceElem.put("value", val.name());
            choiceArray.add(choiceElem);
        }
        paramsElem.put("choice",      choiceArray);
        paramsNode.put("pingActionOnSuccess", paramsElem);
        // pingActionSuccessTime
        paramsElem  = mapper.createObjectNode();
        paramsElem.put("varType",      "Integer");
        paramsElem.put("title",        "Action Success Time");
        paramsElem.put("info",         "Period in seconds used in success action event." );
        paramsNode.put("pingActionSuccessTime", paramsElem);
        // pingActionFailTime
        paramsElem  = mapper.createObjectNode();
        paramsElem.put("varType",      "Integer");
        paramsElem.put("title",        "Action Fail Time");
        paramsElem.put("info",         "Period in seconds used in fail action event." );
        paramsNode.put("pingActionFailTime", paramsElem);
        // resetTime
        paramsElem  = mapper.createObjectNode();
        paramsElem.put("varType",      "Integer");
        paramsElem.put("title",        "Reset Time");
        paramsElem.put("info",         "Period in seconds used to reset pingers." );
        paramsNode.put("resetTime", paramsElem);

        // Convert Enums and Maps to choice fields such that caller knows what values fit in each field.
        //
        //ObjectNode optionsNode = mapper.createObjectNode();

        // Build up result set to be returned to caller.
        //
        result.put("port",  mapper.valueToTree(this));
        result.put("params",  paramsNode);
        //result.put("options", optionsNode);
        return(result);
    }

    public Boolean isEnabled()
    {
        return(this.enabled == TOGGLE.ENABLED);
    }

    public void setDriver(Driver driver)
    {
        this.driver = driver;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setEnabled(TOGGLE enabled)
    {
        this.enabled = enabled;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setDriverPortNo(int portNo)
    {
        this.driverPortNo = portNo;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setDriverName(String name)
    {
        this.driverName = name;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setName(String name)
    {
        this.name = name;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setDescription(String description)
    {
        this.description = description;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setMode(MODE mode)
    {
        this.mode = mode;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPowerUpLevel(LEVEL powerUpLevel)
    {
        this.powerUpLevel = powerUpLevel;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPowerDownLevel(LEVEL powerDownLevel)
    {
        this.powerDownLevel = powerDownLevel;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setOnLevel(LEVEL onLevel)
    {
        this.onLevel = onLevel;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setTimeOn(int i, String timeOn)
    {
        try {
            this.timeOn[i] = LocalTime.parse(timeOn);
        }
        catch (DateTimeParseException e)
        {
            LOG.warning("Illegal Time value given:" + timeOn);
        }

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }
    
    public void setTimeOn(String[] timeOn)
    {
        for(int idx=0; idx < timeOn.length; idx++)
        {
            this.setTimeOn(idx, timeOn[idx]);
        }
    }

    public void setTimeOff(int i, String timeOff)
    {
        try {
            this.timeOff[i] = LocalTime.parse(timeOff);
        }
        catch (DateTimeParseException e)
        {
            LOG.warning("Illegal Time value given:" + timeOff);
        }

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setTimeOff(String[] timeOff)
    {
        for(int idx=0; idx < timeOff.length; idx++)
        {
            this.setTimeOff(idx, timeOff[idx]);
        }
    }

    public void setTimeEnabled(int i, TOGGLE timeEnabled)
    {
        this.timeEnabled[i] = timeEnabled;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setTimeEnabled(TOGGLE[] timeEnabled)
    {
        for(int idx=0; idx < timeEnabled.length; idx++)
        {
            this.setTimeEnabled(idx, timeEnabled[idx]);
        }

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingEnabled(int i, TOGGLE pingEnabled)
    {
        this.pingEnabled[i] = pingEnabled;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingEnabled(TOGGLE[] pingEnabled)
    {
        for(int idx=0; idx < pingEnabled.length; idx++)
        {
            this.setPingEnabled(idx, pingEnabled[idx]);
        }

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingAddr(int i, InetAddress pingAddr)
    {
        this.pingAddr[i] = pingAddr;
        //
        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingAddr(InetAddress[] pingAddr)
    {
        for(int idx=0; idx < pingAddr.length; idx++)
        {
            this.setPingAddr(idx, pingAddr[idx]);
        }

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingType(int i, PINGTYPE pingType)
    {
        this.pingType[i] = pingType;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingType(PINGTYPE[] pingType)
    {
        for(int idx=0; idx < pingType.length; idx++)
        {
            this.setPingType(idx, pingType[idx]);
        }

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingPort(int i, int pingPort)
    {
        this.pingPort[i] = pingPort;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingPort(int[] pingPort)
    {
        for(int idx=0; idx < pingPort.length; idx++)
        {
            this.setPingPort(idx, pingPort[idx]);
        }

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingAddrWaitTime(int i, int pingAddrWaitTime)
    {
        this.pingAddrWaitTime[i] = pingAddrWaitTime;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingAddrWaitTime(int[] pingAddrWaitTime)
    {
        for(int idx=0; idx < pingAddrWaitTime.length; idx++)
        {
            this.setPingAddrWaitTime(idx, pingAddrWaitTime[idx]);
        }

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingToPingTime(int i, int pingToPingTime)
    {
        this.pingToPingTime[i] = pingToPingTime;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingToPingTime(int[] pingToPingTime)
    {
        for(int idx=0; idx < pingToPingTime.length; idx++)
        {
            this.setPingToPingTime(idx, pingToPingTime[idx]);
        }

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingFailCount(int i, int pingFailCount)
    {
        this.pingFailCount[i] = pingFailCount;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingFailCount(int[] pingFailCount)
    {
        for(int idx=0; idx < pingFailCount.length; idx++)
        {
            this.setPingFailCount(idx, pingFailCount[idx]);
        }

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingSuccessCount(int i, int pingSuccessCount)
    {
        this.pingSuccessCount[i] = pingSuccessCount;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingSuccessCount(int[] pingSuccessCount)
    {
        for(int idx=0; idx < pingSuccessCount.length; idx++)
        {
            this.setPingSuccessCount(idx, pingSuccessCount[idx]);
        }

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingLogicForFail(LOGIC pingLogicForFail)
    {
        this.pingLogicForFail = pingLogicForFail;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingLogicForSuccess(LOGIC pingLogicForSuccess)
    {
        this.pingLogicForSuccess = pingLogicForSuccess;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingActionOnFail(ACTION pingActionOnFail)
    {
        this.pingActionOnFail = pingActionOnFail;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingActionOnSuccess(ACTION pingActionOnSuccess)
    {
        this.pingActionOnSuccess = pingActionOnSuccess;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingActionSuccessTime(int pingActionSuccessTime)
    {
        this.pingActionSuccessTime = pingActionSuccessTime;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setPingActionFailTime(int pingActionFailTime)
    {
        this.pingActionFailTime = pingActionFailTime;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setResetTime(int resetTime)
    {
        this.resetTime = resetTime;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    public void setRunInterval(int runInterval)
    {
        this.runInterval = runInterval;

        // Update flag to indicate a config change has been made.
        //
        this.portUpdated = true;
    }

    /////////////////////
    // Action Methods. //
    /////////////////////
    
    // Method to detect if a given IP address and port are reachable.
    //
    private Boolean isReachable(PINGTYPE pingType, InetAddress addr, int openPort, int waitTimeMilliS)
    {
        Boolean result = true;

        if(pingType == PINGTYPE.TCP || pingType == PINGTYPE.UDP)
        {
            // Open a connection with the given address/port combination, if it opens then success.
            //
            try {
                try (Socket soc = new Socket()) {
                    soc.connect(new InetSocketAddress(addr, openPort), waitTimeMilliS);
                }
            } catch (IOException ex) {
                result = false;
            }
        } else
        {
            try {
                Process p1    = java.lang.Runtime.getRuntime().exec("ping -c 1 " + addr.getHostAddress());
                int returnVal = p1.waitFor();
                result = (returnVal==0);
            }
            // Certain platforms dont have a system ping or this application doesnt have the permissions, so send false.
            //
            catch(IOException | InterruptedException e)
            {
                LOG.warning("Failed to call the ping command, wrong os or permissions!");
                result = false;
            }
        }
        return(result);
    }
    
    // Method to determine if port pinger is enabled.
    //
    private Boolean isPingEnabled(int i)
    {
        return(this.pingEnabled[i] == TOGGLE.ENABLED);
    }

    // Method to indicate if this port is configured as an output port.
    //
    private Boolean isOutputPort()
    {
        return(this.mode == MODE.OUTPUT);
    }

    // Method to indicate if this port is configured as an input port.
    //
    private Boolean isInputPort()
    {
        return(this.mode == MODE.INPUT);
    }

    // Method to read the current state of the I/O port.
    //
    private STATE readPort()
    {
        Boolean result = driver.bitRead(this.driverPortNo);

        return(result == true ? STATE.ON : STATE.OFF);
    }

    // Method to write a state to the I/O port. Map the value true = ON, false = OFF to the
    // actual state of the port.
    //
    private void writePort(STATE state)
    {
        // Can only change if the port is configured as an output.
        //
        if(!this.isOutputPort())
        {
            return;
        }

        if((this.onLevel == LEVEL.LOW && state == STATE.OFF) ||
           (this.onLevel == LEVEL.HIGH && state == STATE.ON))
        {
            LOG.info("Turning port on");
            driver.bitWrite(this.driverPortNo, true);
            this.state = STATE.ON;
        } else
        {
            LOG.info("Turning port off");
            driver.bitWrite(this.driverPortNo, false);
            this.state = STATE.OFF;
        }
    }

    // Method to start pingers running at a fixed rate according to config values.
    //
    private void startPingers()
    {
        LOG.finer("StartPinger Port:" + this.driverPortNo + " Name:" + this.driverName);

        // If port is not configured as an output, exit as only applicable to output mode.
        //
        if(!this.isOutputPort())
        {
            return;
        }

        // Go through all enabled pingers and launch if not running.
        //
        for(int idx=0; idx < this.pingEnabled.length; idx++)
        {
            // If ping enabled on this port and no thread assigned, start a thread to see if a connection can be made.
            //
            if(this.isPingEnabled(idx) && this.future[idx] == null)
            {
                LOG.finer("Starting thread for pinger(" + idx + ").");

                // Make a final copy of the Port object in order to call it's methods via the ExecutorService.
                //
                final Port        thisMethod  = this;
                final int         innerIdx    = idx;
                final PINGTYPE    type        = this.pingType[idx];
                final InetAddress addr        = this.pingAddr[idx];
                final int         port        = this.pingPort[idx];
                final int         waitTime    = this.pingAddrWaitTime[idx];
                final int         interTime   = this.pingToPingTime[idx];
                //
                // Start a pinger which gets relaunched every configurable seconds. The results clock up counters for
                // later actions.
                //
                this.future[idx] = this.executor.scheduleAtFixedRate(
                                        new Runnable() { @Override public void run()
                                                                   {
                                                                       if(thisMethod.isReachable(type, addr, port, waitTime))
                                                                       {
                                                                           thisMethod.incrementSuccessCount(innerIdx);
                                                                       } else
                                                                       {
                                                                           thisMethod.incrementFailCount(innerIdx);
                                                                       }
                                                                   }
                                                       },
                                                       interTime, interTime, TimeUnit.SECONDS);

            }
        }
    }

    // Helper methods to increment a class variable called from a scheduled thread.
    //
    private void incrementSuccessCount(int i)
    {
        this.successCount[i]++;
        LOG.finer("Success incremented(" + this.driverPortNo + "," + i + ") = " + this.successCount[i]);
    }
    private void incrementFailCount(int i)
    {
        this.failCount[i]++;
        LOG.finer("Fail incremented(" + this.driverPortNo + "," + i + ") = " + this.failCount[i]);
    }

    // Method to stop running pingers, generally required due to a config change.
    //
    private void stopPingers()
    {
        try {
            this.executor.shutdown();
            this.executor.awaitTermination(1, TimeUnit.SECONDS);
        }
        catch (InterruptedException e) {
            ;
        }
        finally {
            if(!this.executor.isTerminated()) {
                this.executor.shutdownNow();
            }
        }

        // Clean up all futures and counters.
        //
        for(int idx=0; idx < this.pingEnabled.length; idx++)
        {
            this.future[idx]       = null;
            this.failCount[idx]    = 0;
            this.successCount[idx] = 0;
        }
    }

    // Method to execute an action due to an event (ie. ping expiration).
    // a
    private void executeAction(ACTION requiredAction, int pauseTime)
    {
        // Verify that the port is an output before processing.
        //
        if(!this.isOutputPort())
        {
            return;
        }

        // Make a final copy of the Port object in order to call it's methods via the ExecutorService as needed.
        //
        final Port        thisMethod  = this;

        LOG.info("Action:" + requiredAction + ":" + pauseTime);
        switch(requiredAction)
        {
            // Nothing to do!
            //
            case NONE: LOG.finer("No defined execute Action");
                       break;

            // Turn port off.
            //
            case OFF:  this.writePort(STATE.OFF);
                       break;

            // Turn port on.
            //
            case ON:   this.writePort(STATE.ON);
                       break;

            // Turn port off, wait a period of time, then turn on!
            //
            case CYCLE_OFF:
                       this.writePort(STATE.OFF);

                       // Schedule a task to turn the port back on in the configured time.
                       //
                       this.executor.schedule(new Runnable() { @Override public void run()
                                                                         {
                                                                             thisMethod.writePort(STATE.ON);
                                                                         }
                                                             }, pauseTime, TimeUnit.SECONDS);
                       break;

            // Turn port on, wait a period of time, then turn it off!
            //
            case CYCLE_ON:
                       this.writePort(STATE.ON);
                
                       // Schedule a task to turn the port back on in the configured time.
                       //
                       this.executor.schedule(new Runnable() { @Override public void run()
                                                                         {
                                                                             thisMethod.writePort(STATE.OFF);
                                                                         }
                                                             }, pauseTime, TimeUnit.SECONDS);
                       break;

            default:   LOG.warning("Error in Switch, undefined action:" + requiredAction);
                       break;
        }
    }


    // Method to process any actions on triggered pingers.
    //
    private void processPingers()
    {
        int successCount = 0;
        int failCount    = 0;

        // Exit if the port is not enabled or not configured as an output.
        //
        if(!this.isEnabled() || !this.isOutputPort())
        {
            return;
        }

        // If this is the first time we are called, initialise pingers etc.
        //
        if(!this.pingersActive)
        {
            startPingers();
            this.pingersActive = true;
            this.portUpdated   = false;
        }

        // If the configuration has changed, stop the pingers and restart.
        //
        if(this.portUpdated)
        {
            stopPingers();
            startPingers();
            this.portUpdated   = false;
        }

        // Process according to counters.
        //
        for(int idx=0; idx < this.pingEnabled.length; idx++)
        {
            if(this.failCount[idx] >= this.pingFailCount[idx])
            {
                failCount++;
            }
            if(this.successCount[idx] >= this.pingSuccessCount[idx])
            {
                successCount++;
            LOG.finer("Port:" + this.driverPortNo + " Fail:" + failCount + ":" + this.failCount[idx] + " Success:" + successCount);
            }
        }

        // If a ping check results in fail count being met for the given operator type, execute the action required when ping fails.
        //
        if((failCount > 0 && this.pingLogicForFail == LOGIC.OR) ||
           (((failCount > 0 && Integer.compare(this.pingEnabled.length, 1) == 0) || Integer.compare(failCount, this.pingEnabled.length) == 0) &&
            this.pingLogicForFail == LOGIC.AND))
        {
            // Execute required action and reset counters for next run.
            //
            executeAction(this.pingActionOnFail, this.pingActionFailTime);
            for(int idx=0; idx < this.pingEnabled.length; this.failCount[idx] = 0, this.successCount[idx] = 0, idx++);
        }

        // If a ping check results in success count being met for the given operator type, execute the action required when ping succeeds.
        //
        if((successCount > 0 && this.pingLogicForSuccess == LOGIC.OR) ||
           (((successCount > 0 && Integer.compare(this.pingEnabled.length, 1) == 0) || Integer.compare(successCount, this.pingEnabled.length) == 0) &&
             this.pingLogicForSuccess == LOGIC.AND))
        {
            // Execute required action and reset counters for next run.
            //
            executeAction(this.pingActionOnSuccess, this.pingActionSuccessTime);
            for(int idx=0; idx < this.pingEnabled.length; this.failCount[idx] = 0, this.successCount[idx] = 0, idx++);
        }
    }

    // Method to set the port state according to a timed event.
    //
    private void processTimedEvents()
    {
        // Exit if the port is not enabled or not configured as an output.
        //
        if(!this.isEnabled() || !this.isOutputPort())
        {
            return;
        }
        //
        // Need current time to compare against.
        //
        LocalTime currentTime = LocalTime.now();

        // Get current port state.
        //
        STATE portTarget = this.readPort();

        // Go through all the timers and on enabled timed ports, set the port state according to the tiggering event. 
        //
        for(int idx=0; idx < this.timeEnabled.length; idx++)
        {
            // If the timer is enabled, check the times to update the port state.
            //
            if(this.timeEnabled[idx] == TOGGLE.ENABLED)
            {
                // Current >= Off & On > Off & Current < On -> Port OFF
                //
                if((currentTime.equals(this.timeOff[idx]) || currentTime.isAfter(this.timeOff[idx])) &&
                   this.timeOn[idx].isAfter(this.timeOff[idx])                                       &&
                   currentTime.isBefore(this.timeOn[idx])) 
                {
                    LOG.finer("TIMEDEVENT1=" + this.timeOff[idx] + "\n" + this.timeOn[idx]);
                    portTarget = STATE.OFF;
                }

                // Current >= On & On > Off  -> Port ON
                //
                if((currentTime.equals(this.timeOn[idx]) || currentTime.isAfter(this.timeOn[idx]))   &&
                   this.timeOn[idx].isAfter(this.timeOff[idx]))
                {
                    LOG.finer("TIMEDEVENT2=" + this.timeOff[idx] + "\n" + this.timeOn[idx]);
                    portTarget = STATE.ON;
                }

                // Current < Off & On > Off  -> Port ON
                //
                if(currentTime.isBefore(this.timeOff[idx])                                           &&
                   this.timeOn[idx].isAfter(this.timeOff[idx]))
                {
                    LOG.finer("TIMEDEVENT3=" + this.timeOff[idx] + "\n" + this.timeOn[idx]);
                    portTarget = STATE.ON;
                }

                // Current >= On & Off > On & Current < Off -> Port ON
                //
                if((currentTime.equals(this.timeOn[idx]) || currentTime.isAfter(this.timeOn[idx]))   &&
                   this.timeOff[idx].isAfter(this.timeOn[idx])                                       &&
                   currentTime.isBefore(this.timeOff[idx])) 
                {
                    LOG.finer("TIMEDEVENT4=" + this.timeOff[idx].isAfter(this.timeOn[idx]) + "\n" + currentTime.isBefore(this.timeOff[idx])
                                             + "\n" + this.timeOff[idx].isBefore(currentTime) + ":" + currentTime);
                    portTarget = STATE.ON;
                }

                // Current >= Off & Off > On  -> Port OFF
                //
                if((currentTime.equals(this.timeOff[idx]) || currentTime.isAfter(this.timeOff[idx])) &&
                   this.timeOff[idx].isAfter(this.timeOn[idx]))
                {
                    LOG.finer("TIMEDEVENT5=" + this.timeOff[idx] + "\n" + this.timeOn[idx]);
                    portTarget = STATE.OFF;
                }

                // Current < On & Off > On   -> Port OFF
                //
                if(currentTime.isBefore(this.timeOn[idx])                                            &&
                   this.timeOff[idx].isAfter(this.timeOn[idx]))
                {
                    LOG.finer("TIMEDEVENT6=" + this.timeOff[idx] + "\n" + this.timeOn[idx]);
                    portTarget = STATE.OFF;
                }
            }
        }

        // If a change is required, set the new value.
        //
        if(portTarget.compareTo(this.readPort()) != 0)
        {
            this.writePort(portTarget);
        }
    }

    // Method to read the current port value.
    //
    public STATE readPortValue()
    {
        STATE result = STATE.OFF;

        // Only proces if port is enabled.
        //
        if(this.isEnabled())
        {
            result = this.readPort();
        }
        return(result);
    }

    // Method to set the port, if configured as an output, to the ON state.
    //
    public void portON()
    {
        // Only proces if port is enabled.
        //
        if(this.isEnabled())
        {
            this.writePort(STATE.ON);
        }
    }

    // Method to set the port, if configured as an output, to the OFF state.
    //
    public void portOFF()
    {
        // Only proces if port is enabled.
        //
        if(this.isEnabled())
        {
            this.writePort(STATE.OFF);
        }
    }
 
    // Method to set the port state if configured as an output.
    //
    public void writePortValue(STATE state)
    {
        // Only proces if port is enabled.
        //
        if(this.isEnabled())
        {
System.out.println("Writing:" + state);
            this.writePort(state);
        }
    }

    // Method to close down all threads used by this port.
    //
    public void stopThreads()
    {
        // Stop threads assigned to pingers.
        //
        this.stopPingers();
    }

    // Method, to be run in a thread, to process all events and update the port status
    // accordingly. Method is non-blocking and create's new threads according to task type.
    //
    @Override
    public void run()
    {
        this.state = this.readPort();

        // Process Ping actions.
        //
        this.processPingers();

        // Process Timed events.
        //
        this.processTimedEvents();
    }
}
