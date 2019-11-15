/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            DPWRServlet.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     Jetty Servlet, preparing JSP pages and serving them.
//                  This package is based on Jetty:: and is responsible for the dynamic creation of
//                  web pages and serving of them.
//
// Credits:         Eclipse for Jetty::
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

//import java.io.File;
//import java.io.FileNotFoundException;
//import java.io.IOException;
import java.io.*;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.*;
//import java.util.ArrayList;
//import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
//import java.util.Vector;
import java.net.JarURLConnection;
import java.util.jar.Manifest;
import java.lang.IndexOutOfBoundsException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Cookie;

// Jackson imports for serialization of this bean into JSON files.
//
import com.fasterxml.jackson.annotation.JsonIgnore;
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

@WebServlet("/*")
public class DPWRServlet extends HttpServlet implements java.io.Serializable
{
    // ###################################
    // # Config Specific Configuration
    // ###################################
    //
    // Constants.
    //
    // Maxims.

    // Pseudo constants for I/O control.

    // Defaults.

    // Bean variables to control an I/O interface.
    //
    @JsonIgnore
    private static final Logger LOG = Logger.getLogger(DPWRServlet.class.getName());    
    private static String             system;      // Name of system (ie Linux, Windows etc).
    private static String             product;     // Name of product (ie. v2dev).
    private static HttpConfig         http;        // Class to hold all config and methods related to HTTP processing.
    private static EmailConfig        email;       // Class to hold all config and methods related to Email processing.
    private static DDNSConfig         ddns;        // Class to hold all config and methods related to DDNS processing.
    private static TimeConfig         time;        // Class to hold all config and methods related to Time processing.
    private static List<UserConfig>   userList;    // Class to hold all config and methods related to User control.
    private static IO                 io;          // Class to hold all config and methods for I/O operations.

    private static final String CONTENT_TYPE = "text/html; charset=windows-1252";


    public DPWRServlet()
    {
        // Indicate when object is created for debug purposes.
        //
        LOG.finest("Constructing DPWRServlet.");

        // Initialise internal variables.
        //
        http     = new HttpConfig();
        email    = new EmailConfig();
        ddns     = new DDNSConfig();
        time     = new TimeConfig();
        userList = new ArrayList<UserConfig>();
        io       = new IO();
    }

    // Method to get a DataTables compatible JSON string representation of our devices.
    //
    private String srvDeviceList()
    {
        // Initialise Jackson objects.
        ObjectMapper mapper             = new ObjectMapper();
        ObjectNode   ajax               = mapper.createObjectNode();
        ArrayNode    dataArray          = mapper.createArrayNode();
        ArrayNode    modelArray         = mapper.createArrayNode();
        ObjectNode   optionsNode        = mapper.createObjectNode();
        ObjectNode   driverChoiceNode   = mapper.createObjectNode();
        ArrayNode    driverChoiceArray  = mapper.createArrayNode();
        ArrayNode    filesArray         = mapper.createArrayNode();
        String       result             = "";

        try {
            // Loop through all model drivers to build up array of drivers available and their default configuration.
            // First loop is to get unique data, 2nd loop
            Iterator<Driver> modelListIterator = io.getModelList().iterator();
            Driver driver;
            for(; modelListIterator.hasNext();)
            {
                // Get the next driver template to serialise.
                driver = modelListIterator.next();

                // Create nodes, outer and inner.
                ObjectNode modelNode  = mapper.createObjectNode();
                //ObjectNode deviceNode = mapper.createObjectNode();
                ObjectNode deviceElem = mapper.createObjectNode();

                // Add the driver to our driverType choices list.
                ObjectNode driverChoiceElem = mapper.createObjectNode();
                driverChoiceElem.put("label", driver.getDriverType());
                driverChoiceElem.put("value", driver.getDriverType());
                driverChoiceArray.add(driverChoiceElem);

                // Get the driver JSON description and extract the device node, add to our destination.
                ObjectNode device = driver.getParamInfo();
                ObjectNode deviceNode = (ObjectNode)device.get("device");
                deviceNode.put("params", device.get("params"));
                modelNode.put("device", deviceNode);

                // Add in the params definition.
                //optionsNode.put("device.enabled", device.findValue("params").findValue("enabled").findValue("choice"));
                //optionsNode.setAll(device.with("options"));
                //optionsNode.setAll(device.with("choice"));

                // Add in the params definitions into the options node.
                Iterator<Map.Entry<String,JsonNode>> paramIterator = device.findValue("params").fields();
                for(; paramIterator.hasNext();)
                {
                    Map.Entry<String, JsonNode> composite = paramIterator.next();
                    String key          = composite.getKey();
                    JsonNode jNode      = composite.getValue();
                    JsonNode choiceElem = jNode.findValue("choice");
                    if(choiceElem != null)
                    {
                        optionsNode.put("device."+key, choiceElem);
                    }
                }

                // Add the driver to the model array component.
                //
                modelArray.add(deviceNode);
            }

            // Update the driverType choices, can only do this after going through all driver types.
            //
            for(JsonNode jNode : modelArray)
            {
                // Need to add in the full driver type choice array into each device definition as each driver only
                // knows about itself.
                ObjectNode paramsNode = (ObjectNode)jNode.findValue("params").findValue("driverType");
                paramsNode.put("choice", driverChoiceArray);
            }

            // Add in the driver choice array into the options list.
            //
            optionsNode.put("device.driverType", driverChoiceArray);

            // Build up the correct tree.
            Iterator<Driver> driverListIterator = io.getDriverList().iterator();
            for(int idx=0; driverListIterator.hasNext(); idx++)
            {
                // Get the next driver to serialise.
                driver = driverListIterator.next();

                // Create nodes, outer and inner.
                ObjectNode deviceNode = mapper.createObjectNode();
                ObjectNode deviceElem = mapper.createObjectNode();

                // Add inner nodes and singular values to outer node.
                deviceNode.put("DT_RowId", driver.getUuid());

                // Get the driver JSON description and extract the device node.
                ObjectNode device = (ObjectNode)driver.getParamInfo().get("device");

                // The device provides the locked items as an array of UNLOCKED/LOCKED values, for the web client this
                // needs to be converted into an array of string numerics, a numeric present for each locked item.
                ArrayNode mappedLockedArray = mapper.createArrayNode();
                int lockedIdx = 0;
                for(JsonNode jNode : device.findValue("locked"))
                {
                    if(jNode.asText().equals(Driver.LOCKED.LOCKED.name()))
                    {
                        mappedLockedArray.add(String.valueOf(lockedIdx+1));
                    }
                    lockedIdx++;
                }
                if(mappedLockedArray.size() == 0) mappedLockedArray.add("0");
                device.put("locked", mappedLockedArray);

                // Add the device tree to our destination.
                deviceNode.put("device", device);

                // Finally add the node to the data node.
                dataArray.add(deviceNode);

                // Debug.
                //System.out.println(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(driver.getParamInfo()));
            }

            // Finalise the ajax container by inserting required objects.
            //
            ajax.put("data",    dataArray);
            ajax.put("model",   modelArray);
            ajax.put("options", optionsNode);
            ajax.put("files",   filesArray);

            // Convert JSON ajax object into a string.
            result = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(ajax);

            // Debug.
            System.out.println(result);
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

        return(result);
    }

    // Method to get a DataTables compatible JSON string representation of our ports.
    //
    private String srvPortList()
    {
        // Initialise Jackson objects.
        ObjectMapper mapper             = new ObjectMapper();
        ObjectNode   ajax               = mapper.createObjectNode();
        ArrayNode    dataArray          = mapper.createArrayNode();
        ArrayNode    modelArray         = mapper.createArrayNode();
        ObjectNode   optionsNode        = mapper.createObjectNode();
        ObjectNode   driverChoiceNode   = mapper.createObjectNode();
        ArrayNode    driverChoiceArray  = mapper.createArrayNode();
        ArrayNode    filesArray         = mapper.createArrayNode();
        String       result             = "";

        try {
            // No drivers configured, then no action possible.
            if(io.getDriverList().size() == 0) return(null);

            // Need to get a list of the available drivers names and insert into the model.
            //
            HashMap<String, Driver.LOCKED[]> lockedList = new HashMap<String, Driver.LOCKED []>();
            Iterator<Driver> driverListIterator = io.getDriverList().iterator();
            Driver driver;
            for(; driverListIterator.hasNext();)
            {
                // Get the next driver. 
                driver = driverListIterator.next();

String driverName = driver.getName();
Driver.LOCKED [] lockedPortList = driver.getLocked();
lockedList.put(driverName, lockedPortList);

                // Create nodes, outer and inner.
                ObjectNode modelNode  = mapper.createObjectNode();
                ObjectNode deviceElem = mapper.createObjectNode();

                // Add the driver to our driverType choices list.
                ObjectNode driverChoiceElem = mapper.createObjectNode();
                driverChoiceElem.put("label", driver.getName());
                driverChoiceElem.put("value", driver.getName());
                driverChoiceArray.add(driverChoiceElem);
            }

            // Create a template port to be used as the model.
            Port port = new Port(null, 0, "Driver name", "Port Name", "Port Description");

            // Get the port JSON description and extract the port node, add to our destination.
            ObjectNode infoElem  = port.getParamInfo();
            ObjectNode modelNode = (ObjectNode)infoElem.get("port");
            ObjectNode paramsNode = (ObjectNode)infoElem.get("params");

            // Add in the driverName model.
            ObjectNode paramsElem  = mapper.createObjectNode();
            ArrayNode choiceArray = mapper.createArrayNode();
            paramsElem.put("varType",      "Choice");
            paramsElem.put("title",        "Device Name");
            paramsElem.put("info",         "Configured drivers by Name.");
            paramsElem.put("choice",       driverChoiceArray);
            paramsNode.put("driverName",   paramsElem);
            modelNode.put("params",        paramsNode);

            // Add the port to the model array component.
            modelArray.add(modelNode);

            // Build up the correct tree.
            HashMap<String, ArrayList> inUseList = new HashMap<String, ArrayList>();
            Iterator<Port> portListIterator = io.getPortList().iterator();
            for(int idx=0; portListIterator.hasNext(); idx++)
            {
                // Get the next driver to serialise.
                port = portListIterator.next();

                // Create nodes, outer and inner.
                ObjectNode portNode = mapper.createObjectNode();

                // Add inner nodes and singular values to outer node.
                portNode.put("DT_RowId", port.getUuid());

                // Get the driver JSON description and extract the device node.
                ObjectNode portElem = (ObjectNode)port.getParamInfo().get("port");

String driverName = port.getParamInfo().get("port").get("driverName").asText();
Integer driverPort = port.getParamInfo().get("port").get("driverPortNo").asInt();
if(driverName != null && driverPort != null)
{
ArrayList thisDriver = inUseList.get(driverName);
if(thisDriver == null)
{
    thisDriver = new ArrayList();
    inUseList.put(driverName, thisDriver);
}
thisDriver.add(driverPort);
}

                // Add in the logical port number, for human reference, in the app the driver and driverPortNo are used
                // to identify a port.
                portElem.put("logicalPortNo", idx);

                // Add the device tree to our destination.
                portNode.put("port", portElem);

                // Add in the params definitions into the options node.
                Iterator<Map.Entry<String,JsonNode>> paramIterator = infoElem.findValue("params").fields();
                for(; paramIterator.hasNext();)
                {
                    Map.Entry<String, JsonNode> composite = paramIterator.next();
                    String key = composite.getKey();
                    JsonNode jNode = composite.getValue();
                    JsonNode choiceElem = jNode.findValue("choice");
                    if(choiceElem != null)
                    {
                        optionsNode.put("port."+key, choiceElem);
                    }
                }

                // Finally add the node to the data node.
                dataArray.add(portNode);

                // Debug.
                System.out.println(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(port.getParamInfo()));
            }

//for(String driverName : lockedList.keySet())
//{
//    ObjectNode driverElem  = mapper.createObjectNode();
//    ArrayNode portArray = mapper.createArrayNode();
//
//    Array [] 
//    for(int idx=0; idx < lockedList.length; idx++)
//    {
//        if(lockedList.get
//    }
//}

            // Finalise the ajax container by inserting required objects.
            //
            ajax.put("data",    dataArray);
            ajax.put("model",   modelArray);
            ajax.put("options", optionsNode);
            ajax.put("files",   filesArray);

            // Convert JSON ajax object into a string.
            result = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(ajax);

            // Debug.
            System.out.println(result);
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

        return(result);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        String path = request.getRequestURI().substring(request.getContextPath().length());
        path = path.replace("/dpwr/", "");
        path = path.replace("/dpwr", "");

        response.setContentType(CONTENT_TYPE);
        PrintWriter out = response.getWriter();

        String command = request.getParameter("cmd");
        LOG.fine("PATH="+path+", COMMAND="+command);
        if(path != null)
        {
            switch(path)
            {
                case "device":
                    // Make sure cmd has been given, cannot process without.
                    if(command != null)
                    {
                        switch(command)
                        {
                            case "get":
                                // Send the JSON device list to client.
                                out.println(srvDeviceList());
                                out.close();
                                break;

                            case "set":
                                LOG.warning("SET: Not Implemented, command=" + command);
                                break;

                            default:
                                LOG.warning("GET: Unknown command=" + command);
                                break;
                        }
                    }
                    break;

                case "port":
                    // Make sure cmd has been given, cannot process without.
                    if(command != null)
                    {
                        switch(command)
                        {
                            case "get":
                                // Send the JSON port list to client.
                                out.println(srvPortList());
                                out.close();
                                break;

                            case "set":
                                LOG.warning("SET: Not Implemented, command=" + command);
                                break;

                            default:
                                LOG.warning("GET: Unknown command=" + command);
                                break;
                        }
                    }
                    break;

                default:
                    LOG.warning("GET: Unknown path=" + path);
                    break;
            }
        }

        //request.getRequestDispatcher(path).forward(request, response);
        //request.getRequestDispatcher("default").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
    {
        ObjectMapper mapper          = new ObjectMapper();
        ObjectNode config            = mapper.createObjectNode();
        ObjectNode results           = mapper.createObjectNode();
        ObjectNode data              = mapper.createObjectNode();
        String command               = "";
        String rowId                 = "";
        String destination           = "";
        String parameter             = "";
        String driverType            = "";
        String errorMsg              = "";

        String action, allOnApply, autoRefresh, notificationTime, portList, refreshTime;
        String[] splitPorts, splitPort;
        Integer port;
        Port.STATE outputState;
        HttpSession session = request.getSession(false);

        PrintWriter out = response.getWriter();
        response.setContentType("application/json");

        Enumeration<String> parameterNames = request.getParameterNames();
        while (parameterNames.hasMoreElements())
        {
            String paramName     = parameterNames.nextElement();
            String[] paramValues = request.getParameterValues(paramName);
LOG.finer(paramName);
for(int idx2=0; idx2 < paramValues.length; idx2++)
{
    LOG.finer(paramValues[idx2]);
}
            // Break up command as field names are braced.
            //
            String paramNames [] = paramName.replace('[', ' ').replace(']', ' ').replaceAll("  ", " ").trim().split(" ");
LOG.finer("PARAM[0]="+paramNames[0]);
            // Process the sent data into internal variables prior to acting on the request.
            //
            switch(paramNames[0])
            {
                case "action":
                    command = paramValues[0];
                    LOG.finer("POST Action Command = " + paramValues[0]);
                    break;

                case "data":
                    if(paramNames.length > 3)
                    {
                        if(paramNames.length > 4)
                        {
                            LOG.warning("POST received, not catered for:" + paramName);
                            continue;
                        }

                        switch(paramNames[2])
                        {
                            case "device":
                            case "port":
                                rowId = paramNames[1];
                                destination = paramNames[2];
                                parameter = paramNames[3];
LOG.finer("rowId="+rowId+", destination="+destination+", parameter="+parameter);

                                ArrayNode  valueArray = mapper.createArrayNode();
                                switch(parameter)
                                {
                                    case "driverType":
                                        driverType = paramValues[0];
LOG.finer("driverType="+driverType);
                                        break;

                                    case "locked":
                                        //String [] valuesSplit = paramValues[0].split(",");
LOG.finer("Locked:"+paramValues[0]);
                                        for(int idx2=0; idx2 < paramValues.length; idx2++)
                                        {
                                            // Due to an error with Selectize, 0 represents an empty set, so dont add 0
                                            // ad reduce all values by 1 prior to adding into array.
LOG.finer("Locked port:"+ paramValues[idx2]);
                                            Integer val = Integer.parseInt(paramValues[idx2]);
                                            if(val != 0)
                                            {
LOG.finer("Converted:"+val);
                                                valueArray.add(val - 1);
                                            }
                                        }
                                        data.put(parameter, valueArray);
                                        break;


                                    default:
                                        if(paramValues.length > 1)
                                        {
                                            for(int idx=0; idx < paramValues.length; idx++)
                                            {
                                                valueArray.add(paramValues[idx]);
                                            }
                                            data.put(parameter, valueArray);
                                        } else
                                        {
LOG.finer("Parameter:"+parameter+",of value:"+paramValues[0]);
                                            data.put(parameter, paramValues[0]);
                                        }
                                        break;
                                }
                                break;

                            default:
                                LOG.finer("Parameter sub-type unknown: " + paramNames[2]);
                                break;
                        }
                    }

                    data.put("uuid", rowId);
                    config.put("data",    data);
                    break;

                default:
                    LOG.finer("POST UNKNOWN Action: " + paramNames[0] + ", Command=" + paramValues[0]);
                    break;
            }
        }
System.out.println(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(config));
LOG.finer(destination);
        // Dispatch the data to the relevant object.
        //
        switch(destination)
        {
            case "device":
                if(command.equals("create"))
                {
                    // Create new driver instance and add it to the driver list.
                    Driver driver = io.createDriver(driverType, (ObjectNode)config.findValue("data"), results);
                    if(driver == null)
                    {
                        errorMsg = "Failed to create new device, check parameters!";
                    }
                } else
                {
                    // Go through all the drivers and pass in the data record. Normally only one
                    // driver will be updated, but the UUID ensures if AJAX has passed multiple rows, it is
                    // handled correctly.
                    //
                    //Iterator<Driver> driverListIterator = io.getDriverList().iterator();
                    List<Driver> driverList = io.getDriverList();
                    Driver driver;
                    //for(; driverListIterator.hasNext();)
                    for(int idx = 0; idx < driverList.size(); idx++)
                    {
                        // Get the next driver to serialise.
                        //driver = driverListIterator.next();
                        driver = driverList.get(idx);

                        // If the data set matches on the UUID from this driver, process.
                        //
                        if(config.findValue("uuid") != null && config.findValue("uuid").textValue().equals(driver.getUuid()))
                        {
                            switch(command)
                            {
                                case "delete":
                                case "remove":
                                    // If the delete command given and we have a match on UUID, delete the driver.
                                    //
                                    io.delDriver(driver);
                                    idx--;
                                    break;
    
                                case "edit":
                                    driver.updateFromJSON((ObjectNode)config.findValue("data"), results);
                                    break;
    
                                default:
                                    LOG.warning("POST - unrecognisable command given:" + command);
                                    break;
                            }
                        }
                    }
                }
                break;

            case "port":
//TODO - Need to lookup the driver, error if not found.
//    - add a new port - check to see if it is locked and doesnt already exist
//    - add the port to the IO linkedPortList

                if(command.equals("create"))
                {
                    // Create new port instance and add it to the port list.
                    //Port port = io.createDriver(driverType, (ObjectNode)config.findValue("data"), results);
port = null;
                    if(port == null)
                    {
                        errorMsg = "Failed to create new port, check parameters!";
                    }
                } else
                {
                    // Go through all the drivers and pass in the data record. Normally only one
                    // driver will be updated, but the UUID ensures if AJAX has passed multiple rows, it is
                    // handled correctly.
                    //
                    //Iterator<Driver> driverListIterator = io.getDriverList().iterator();
/*
                    List<Driver> driverList = io.getDriverList();
                    Driver driver;
                    //for(; driverListIterator.hasNext();)
                    for(int idx = 0; idx < driverList.size(); idx++)
                    {
                        // Get the next driver to serialise.
                        //driver = driverListIterator.next();
                        driver = driverList.get(idx);

                        // If the data set matches on the UUID from this driver, process.
                        //
                        if(config.findValue("uuid") != null && config.findValue("uuid").textValue().equals(driver.getUuid()))
                        {
                            switch(command)
                            {
                                case "delete":
                                case "remove":
                                    // If the delete command given and we have a match on UUID, delete the driver.
                                    //
                                    io.delDriver(driver);
                                    idx--;
                                    break;
    
                                case "edit":
                                    driver.updateFromJSON((ObjectNode)config.findValue("data"), results);
                                    break;
    
                                default:
                                    LOG.warning("POST - unrecognisable command given:" + command);
                                    break;
                            }
                        }
                    }
*/
                }
                LOG.warning("TODO - Port Logic needed:" + destination);
                break;

            default:
                LOG.warning("POST - unrecognisable destination:" + destination);
                break;
        }

        // Create the results set to be returned to the client.
        //
        ObjectNode reply             = mapper.createObjectNode();
        ObjectNode device            = (ObjectNode)results.findValue("device");
        ArrayNode dataArray          = mapper.createArrayNode();
        ArrayNode fieldErrors        = mapper.createArrayNode();
        data                         = mapper.createObjectNode();

        Iterator<String> iterator = results.fieldNames();
        while(iterator.hasNext())
        {
            String field = iterator.next();
            String value = results.findValue(field).asText();

            if(field.equals("errors"))
            {
                ArrayNode errorsArray = (ArrayNode)results.findValue(field);
                for(JsonNode jNode: errorsArray)
                {
                    iterator = jNode.fieldNames();
                    ObjectNode fieldError;
                    while(iterator.hasNext())
                    {
                        field      = iterator.next();
                        value      = jNode.findValue(field).asText();
                        fieldError = mapper.createObjectNode();
                        fieldError.put("name", "device."+field);
                        fieldError.put("status", value);
                        fieldErrors.add(fieldError);
                    }
                }
            } else
            if(field.equals("uuid"))
            {
                data.put("DT_RowId", value);
            } else
            if(field.equals("device"))
            {
                // The device provides the locked items as an array of UNLOCKED/LOCKED values, for the web client this
                // needs to be converted into an array of string numerics, a numeric present for each locked item.
                ArrayNode mappedLockedArray = mapper.createArrayNode();
                int lockedIdx = 0; 
                for(JsonNode jNode : device.findValue("locked"))
                {
                    if(jNode.asText().equals(Driver.LOCKED.LOCKED.name()))
                    {
                        mappedLockedArray.add(String.valueOf(lockedIdx+1));
                    }
                    lockedIdx++;
                }
                if(mappedLockedArray.size() == 0) mappedLockedArray.add("0");
                device.put("locked", mappedLockedArray);
            }
        }

        data.put("device", device);
        dataArray.add(data);
        reply.put("data", dataArray);
        if(fieldErrors.size() > 0) { reply.put("fieldErrors", fieldErrors); }
        if(errorMsg.length()  > 0) { reply.put("error",       errorMsg); }

        try {
            // Convert JSON ajax object into a string.
            out.println(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(reply));
            //System.out.println(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(config));
            //System.out.println(mapper.writerWithDefaultPrettyPrinter().writeValueAsString(reply));
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
        out.close();

        if(session == null)
        {
            LOG.warning("No session instance exists, cannot persist changes.");
        }

        action = request.getParameter("ACTION");
        if(action != null)
        {
            switch(action)
            {
                case "SETPORT":
                    port        = Integer.parseInt(request.getParameter("PORT"));
                    outputState = Port.STATE.valueOf(request.getParameter("OUTPUT_STATE"));
                    this.io.getPort(port).writePortValue(outputState);
                    LOG.finer("POST: SETPORT=" + port + ":" + outputState);
                    break;
    
                case "SETPORTS":
                    portList   = request.getParameter("PORTLIST");
                    splitPorts = portList.split(";");
                    for(int idx=0; idx < splitPorts.length; idx++)
                    {
                        splitPort = splitPorts[idx].split(":");
                        port = Integer.parseInt(splitPort[0]);
                        outputState = Port.STATE.valueOf(splitPort[1]);
    
                        this.io.getPort(port).writePortValue(outputState);
                    }
    
                    LOG.finer("POST: SETPORTS=" + portList);
                    break;
    
                case "IOCONTROL":
                    allOnApply       = request.getParameter("ALLONAPPLY");
                    autoRefresh      = request.getParameter("AUTOREFRESH");
                    refreshTime      = request.getParameter("REFRESHTIME");
                    notificationTime = request.getParameter("NOTIFICATIONTIME");
                    if(session != null)
                    {
                        if(allOnApply != null)
                        {
                            session.setAttribute("AllOnApply",  allOnApply);
                        }
                        if(autoRefresh != null)
                        {
                            session.setAttribute("AutoRefresh", autoRefresh);
                        }
                        if(refreshTime != null)
                        {
                            session.setAttribute("RefreshTime", refreshTime);
                        }
                        if(notificationTime != null)
                        {
                            session.setAttribute("NotificationTime", notificationTime);
                        }
                    }
                    LOG.finer("POST: ALLONAPPLY=" + allOnApply + ",AUTOREFRESH=" + autoRefresh + ",REFRESHTIME=" + refreshTime + ",NOTIFICATIONTIME=" + notificationTime);
                    break;
    
                default:
                    LOG.finer("POST: Unknown action=" + action);
                    break;
            }

            if(!action.equals("SETPORT"))
            {
                LOG.finer("Redirecting to referer...");
                response.sendRedirect(request.getHeader("Referer"));
            }
        }
    }

    public String getSystem()
    {
        return(this.system);
    }

    public String getProduct()
    {
        return(this.product);
    }

    public HttpConfig getHttp()
    {
        return(this.http);
    }

    public EmailConfig getEmail()
    {
        return(this.email);
    }

    public DDNSConfig getDDNS()
    {
        return(this.ddns);
    }

    public TimeConfig getTime()
    {
        return(this.time);
    }

    public UserConfig getUserList(int i)
    {
        return(this.userList.get(i));
    }

    public List<UserConfig> getUserList()
    {
        return(this.userList);
    }

    public IO getIO()
    {
        return(this.io);
    }

    public void setSystem(String system)
    {
        this.system = system;
    }

    public void setProduct(String product)
    {
        this.product = product;
    }

    public void setHttp(HttpConfig http)
    {
        this.http = http;
    }

    public void setEmail(EmailConfig email)
    {
        this.email = email;
    }

    public void setDDNS(DDNSConfig ddns)
    {
        this.ddns = ddns;
    }

    public void setTime(TimeConfig time)
    {
        this.time = time;
    }

    public void addUser(UserConfig user)
    {
        this.userList.add(user); 
        LOG.finer("Added User:" + user);
    }

    public void setUserList(int i, UserConfig user)
    {
        try {
            this.userList.set(i, user);
        }
        catch(IndexOutOfBoundsException e)
        {
            this.addUser(user);
        }
        catch(NullPointerException e)
        {
            LOG.severe("Caught it: " + user.getLoginUser() + user.getLoginPassword() + user.getLoginLevel());
        }
    }

    public void setUserList(List<UserConfig> userList)
    {
        // Iterate through the provided list and add onto our static list.
        //
        Iterator<UserConfig> userListIterator = userList.iterator();
        UserConfig user;
        for(; userListIterator.hasNext(); )
        {
            user = userListIterator.next();
            this.addUser(user);
        }
    }

    public void setIO(IO io)
    {
        this.io = io;
    }
}

