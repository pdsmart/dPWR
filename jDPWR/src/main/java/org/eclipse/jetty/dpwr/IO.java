/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            IO.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     IO object class. This class is responsible for maintaining all IO, instantiating 
//                  drivers, instantiating ports, configuring and controlling them and providing
//                  methods to read and set ports as required.
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
import java.lang.CloneNotSupportedException;
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

public class IO implements Runnable, java.io.Serializable
{
    // ###################################
    // # I/O Specific Configuration
    // ###################################
    //
    // Constants.
    //
    // Maxims.
    public static final int                     MIN_PORT_LIMIT              = 0;
    public static final int                     MAX_PORT_LIMIT              = 128;  // Valid Range is MIN_PORT_LIMIT .. MAX_PORT_LIMIT - 1
    public static final int                     MIN_DEVICE_LIMIT            = 0;
    public static final int                     MAX_DEVICE_LIMIT            = 8;    // Valid Range is MIN_DEVICE_LIMIT .. MAX_DEVICE_LIMIT - 1
    public static final int                     MIN_TIMER_LIMIT             = 0;
    public static final int                     MAX_TIMER_LIMIT             = 7;
    public static final int                     MIN_PING_LIMIT              = 0;
    public static final int                     MAX_PING_LIMIT              = 3;

    // Enum's
    //
    public enum ResultCodes
    {
        SUCCESS(0),                                // Method was successful.
        FAIL_BADPARAMETERS(-1),                    // Bad parameters provided to method.
        FAIL_PORTINUSE(-10),                       // A requested port is in use.
        FAIL_PORTHASLINK(-20);                     // A requested port already has a linkedPortList.

        // In order to ensure known values instead or arbitary values to caller, use fixed integer constants
        // for each result code.
        private int resultCode;
        ResultCodes(int code) { this.resultCode = code; }
        public int getResultCode() { return this.resultCode; }
    }

    // Pseudo constants for I/O control.

    // Defaults.

    // Bean variables to control an I/O interface.
    //
    @JsonIgnore
    private static final Logger LOG = Logger.getLogger(IO.class.getName());    
    private int                        maxPort;           // Maximum number of Ports across all drivers.
    @JsonIgnore
    private static Boolean             ioIsRunning;       // Flag to indicate if the IO is running, ie. threads attached.
    @JsonIgnore
    private static Boolean             ioStop;            // Flag to indicate if IO is to be stopped, used during internal reconfigurations.
    @JsonIgnore
    private static Boolean             ioTerminate;       // Flag to indicate exit is required.
    @JsonIgnore
    private static Boolean             ioUpdated;         // Flag to indicate if an update was made to the IO configuration.
    private static List<Driver>        driverList;        // List of all instantiated driver objects.
    @JsonIgnore
    private static List<Driver>        modelList;         // List of all available drivers with default configuration.
    private static List<Port>          portList;          // List of all instantiated port objects.
    private static List<List<Integer>> linkedPortList;    // List of all instantiated port objects.

    // CONSTRUCTORS.
    //
    public IO()
    {
        // On mutiple calls to the constructor (normally only one instance of this class should exist per App), destroy the existing
        // setup.
        //
        if(this.driverList != null)
        {
            LOG.finer("Driver list isnt NULL:" + this.driverList);

            Iterator<Driver>  driverIterator  = this.driverList.iterator();
            Driver driver;
            for(; driverIterator.hasNext(); )
            {
                LOG.finer("In driver iterator");
                driver = driverIterator.next();

                // Deleting a driver removes all ports and the linked Port setup associated with it.
                //
                LOG.finer("Deleting driver:" + driver);
                delDriver(driver);
                //driverIterator.remove();
                driverIterator = this.driverList.iterator();
                LOG.finer("Driver deleted");
            }
        } else
        {
            // We only allocate memory to the static variables on the first instantiation of this class.
            //
            this.driverList     = Collections.synchronizedList(new ArrayList<Driver>());
            this.modelList      = Collections.synchronizedList(new ArrayList<Driver>());
            this.portList       = Collections.synchronizedList(new ArrayList<Port>());
            this.linkedPortList = Collections.synchronizedList(new ArrayList<List<Integer>>());

            // Add one of each driver to our model list, this list is used internally to know what drivers we have
            // available. This list must be MANUALLY UPDATED if new drivers are added to the project.
            //
            try {
                this.modelList.add(new DriverATMega328P());
                this.modelList.add(new DriverTCA6416A());
            }
            catch(IndexOutOfBoundsException e)
            {
                LOG.severe("Caught IndexOutOfBoundsException adding driver to model list.");
            }
            catch(NullPointerException e)
            {
                LOG.severe("Caught NullPointerException adding driver to model list.");
            }
        }

        // Initialise internal variables.
        //
        this.maxPort        = 0;
        this.ioIsRunning    = false;
        this.ioTerminate    = false;
        this.ioStop         = false;
        this.ioUpdated      = true;
    }

    // Getters and Setters. //

    // Method to get the maximum number of logical ports currently configured.
    //
    public int getMaxPort()
    {
        return(this.maxPort);
    }

    // Method to get a driver given its index.
    //
    public Driver getDriver(int i)
    {
        return(this.driverList.get(i));
    }

    // Method to get a driver given its name.
    //
    public Driver getDriver(String name)
    {
        Iterator<Driver>  driverIterator  = this.driverList.iterator();
        Driver driver = null;
        for(; driverIterator.hasNext(); )
        {
            driver = driverIterator.next();
            if(driver.getName().equals(name))
            {
                break;
            }
        }
        return(driver);
    }

    // Method to get the entire driverList, generally used by serialisation.
    //
    public List<Driver> getDriverList()
    {
        return(this.driverList);
    }

    // Method to get a model driver given its name.
    //
    @JsonIgnore
    public Driver getModelDriver(String name)
    {
        Iterator<Driver>  driverIterator  = this.modelList.iterator();
        Driver driver = null;
        for(; driverIterator.hasNext(); )
        {
            driver = driverIterator.next();
            if(driver.getName().equals(name))
            {
                break;
            }
        }
        return(driver);
    }

    // Method to get the entire modelList used to determine what drivers are available in this application.
    //
    @JsonIgnore
    public List<Driver> getModelList()
    {
        return(this.modelList);
    }
    
    // Method to get a port given its index.
    //
    public Port getPort(int i)
    {
        return(this.portList.get(i));
    }

    // Method to get the entire portList, generally used by serialisation.
    //
    public List<Port> getPortList()
    {
        return(this.portList);
    }

    // Method to get the linked list of ports assigned to the requested port.
    //
    public List getLinkedPort(int i)
    {
        return(this.linkedPortList.get(i));
    }

    // Method to return the entire Array of Arrays of linked port numbers.
    //
    public List<List<Integer>> getLinkedPortList()
    {
        return(this.linkedPortList);
    }

    // Method to set the maximum configured ports in the IO bean.
    //
    public void setMaxPort(int maxPort)
    {
        this.maxPort = maxPort;
        LOG.finer("Setting maxPort=" + maxPort);
    }

    // Method to create a new driver based on a given driver type and initialise it from a JSON array.
    //
    public Driver createDriver(String driverType, ObjectNode config, ObjectNode results)
    {
        Driver newDriver = null;
        try {
            Driver modelDriver = this.getModelDriver(driverType);

            if(modelDriver != null)
            {
                newDriver = modelDriver.clone(modelDriver);

                // Configure the driver.
                //
                if(newDriver.updateFromJSON(config, results) == true)
                {
                    // To complete, add the driver onto our list.
                    //
                    this.addDriver(newDriver);
                } else
                {
                    // Driver couldnt be configured, so drop it and signal to caller it couldnt be created.
                    //
                    LOG.fine("IO: Failed to instantiate a driver of type:" + driverType);
                    newDriver = null;
                }
            } else
            {
                LOG.warning("IO: Unrecognised driverType in createDriver:" + driverType);
            }
        }
        catch(Exception e)
        {
            e.printStackTrace();
            LOG.severe("Caught Exception duplicating driver: " + driverType);
        }

        // Return the new driver object to the caller or null if failed.
        //
        return(newDriver);
    }

    // Method to add a driver object in our Array of drivers.
    //
    public void addDriver(Driver driver)
    {
        // Request the IO to stop so that we dont get spurious operations as delete the requested driver and ports.
        //
        if(this.ioIsRunning)
        {
            this.ioStop = true;
            do {
                try {
                    TimeUnit.MILLISECONDS.sleep(500);
                }
                catch (InterruptedException e) {
                    ; // We dont care if we get interrupted and exit sooner, the sleep is only to conserve CPU resource.
                }
            } while(this.ioIsRunning);
        }

        // Add the new driver.
        try {
            this.driverList.add(driver);
        }
        catch(IndexOutOfBoundsException e)
        {
            LOG.severe("Caught IndexOutOfBoundsException: " + driver);
        }
        catch(NullPointerException e)
        {
            LOG.severe("Caught NullPointerException: " + driver);
        }

        // Initialise the ports to a default state, normally it will take on real values from a deserialization event.
        //
        for(int idx = 0; idx < driver.getMaxPorts(); idx++)
        {
            if(driver.getLocked(idx) == Driver.LOCKED.UNLOCKED)
            {
                // Add a new port.
                //
                this.addPort(new Port(driver, idx, driver.getName(), "Port " + idx, "Driver " + driver.getName() + ", Port " + idx + " (default config)"));

                // Add a linked port entry for this port incase other ports need to be linked to it.
                //
                this.linkedPortList.add(new ArrayList<Integer>());
            }
        }

        // Update maximum available ports.
        //
        this.maxPort = this.portList.size();

        // Restart the IO now all changes are complete.
        //
        this.ioUpdated = false;
        this.ioStop    = false;
    }

    // Method to remove a driver and its associated ports.
    //
    public void delDriver(Driver driverToDelete)
    {
        // Firstly, remove the ports associated with the driver and update the linkedPorts list.
        //
        {
            Iterator<Port>          portIterator    = this.portList.iterator();
            Iterator<List<Integer>> linkIterator    = this.linkedPortList.iterator();
            Port                    port;
            List<Integer>           link;
            int                     idx             = 0;
            int                     lastPortDeleted = 0;

            // Request the IO to stop so that we dont get spurious operations as delete the requested driver and ports.
            //
            if(this.ioIsRunning)
            {
                this.ioStop = true;
                do {
                    try {
                        TimeUnit.MILLISECONDS.sleep(500);
                    }
                    catch (InterruptedException e) {
                        ; // We dont care if we get interrupted and exit sooner, the sleep is only to conserve CPU resource.
                    }
                } while(this.ioIsRunning);
            }

            for(; portIterator.hasNext() && linkIterator.hasNext(); idx++ )
            {
                port = portIterator.next();
                link = linkIterator.next();

                // If the port uses the same driver as the one to be deleted, we can remove the port.
                //
                if(port.getDriver() == driverToDelete)
                {
                    // Log the port + link to be deleted.
                    LOG.finer("Delete Driver: Port/link:" + port + "/" + link);

                    // Remove from any linked list entry.
                    //
                    for(int idx2=0; idx2 < this.linkedPortList.size(); idx2++)
                    {
                        this.delLinkedPort(idx2, idx);
                    }

                    // Remove the port object and the port linked list object as no longer needed.
                    //
                    portIterator.remove();
                    linkIterator.remove();
                    lastPortDeleted = idx;
                }
            }

            // Update last port deleted into range 1...n
            //
            lastPortDeleted++;
            LOG.finer("Last Port Deleted:" + lastPortDeleted);

            // Now iterate through every list in the linkedPortArray and update the elements to compensate
            // for the removal of this driver.
            //
            if(this.linkedPortList != null)
            {
                for(linkIterator = this.linkedPortList.iterator(); linkIterator.hasNext(); )
                {
                    link = linkIterator.next();
                    LOG.finer("LinkIterator:" + linkIterator + ", Link:" + link);
                    for(idx=0; idx < link.size(); idx++)
                    {
                        link.set(idx, (link.get(idx) - lastPortDeleted));
                    }
                }
            }
        }

        // Now remove the driver.
        //
        for(int idx=0; idx < this.driverList.size(); idx++)
        {
            if(this.driverList.get(idx).equals(driverToDelete))
            {
                LOG.finer("Removing Driver = " + idx);
                this.driverList.remove(idx);
            }
        }

        // Update maximum available ports.
        //
        this.maxPort = this.portList.size();

        // Restart the IO now all changes are complete.
        //
        this.ioUpdated = false;
        this.ioStop    = false;
    }

    // Method to install an array of pre-configured drivers overwriting our existing list if it exists.
    //
    public void setDriverList(List<Driver> driverList)
    {
        // Iterate through the list provided and add the drivers onto our static list.
        //
        Iterator<Driver> driverIterator = driverList.iterator();
        for(; driverIterator.hasNext(); )
        {
            try {
                this.driverList.add(driverIterator.next());
            }
            catch(IndexOutOfBoundsException e)
            {
                LOG.severe("Caught IndexOutOfBoundsException adding a driver to list");
            }
            catch(NullPointerException e)
            {
                LOG.severe("Caught NullPointerException adding a driver to list");
            }
        }
        LOG.finer("Setting Driver List:" + driverList);

        // Update flag to indicate an IO change has been made.
        //
        this.ioUpdated = true;
    }

    // Method to add a single Port object into our logical set of Ports to be processed.
    //
    public void addPort(Port port)
    {
        try {
            this.portList.add(port);
        }
        catch(IndexOutOfBoundsException e)
        {
            LOG.severe("Caught IndexOutOfBoundsException adding a port: " + port);
        }
        catch(NullPointerException e)
        {
            LOG.severe("Caught NullPointerException adding a port: " + port);
        }
        LOG.finer("Added port:" + port);

        // Update flag to indicate an IO change has been made.
        //
        this.ioUpdated = true;
    }

    // Method to install an array of pre-configured ports overwriting our existing list if it exists.
    //
    public void setPortList(List<Port> portList)
    {
        // Build up a map of driver name to driver instance.
        //
        HashMap<String, Driver> nameToDriver = new HashMap<String, Driver>();
        Iterator<Driver> driverIterator = driverList.iterator();
        Driver driver;
        for(; driverIterator.hasNext(); )
        {
            driver=driverIterator.next();
            nameToDriver.put(driver.getName(), driver);
        }

        // Iterate through the list provided and add the drivers onto our static list.
        //
        Iterator<Port> portIterator = portList.iterator();
        Port port;
        for(; portIterator.hasNext(); )
        {
            port = portIterator.next();

            // Add in the associated driver mapped via the driver name.
            //
            port.setDriver(nameToDriver.get(port.getDriverName()));

            try {
                this.portList.add(port);
            }
            catch(IndexOutOfBoundsException e)
            {
                LOG.severe("Caught IndexOutOfBoundsException adding a port to list.");
            }
            catch(NullPointerException e)
            {
                LOG.severe("Caught NullPointerException adding a port to list.");
            }
        }
        LOG.finer("Set Port List:" + portList);

        // Update flag to indicate an IO change has been made.
        //
        this.ioUpdated = true;
    }

    // Method to add a port into the linked list of another port, ie. the ports actions are linked.
    //
    public ResultCodes addLinkedPort(int portListNo, int portNo)
    {
        // Ensure that the parameters are valid.
        //
        if(this.linkedPortList.size() >= portListNo && portListNo < this.maxPort)
        {
            // If this port has its own list, then error!
            //
            if(this.linkedPortList.get(portNo).size() > 0)
            {
                return(ResultCodes.FAIL_PORTHASLINK);
            }

            // Now check to ensure this requested port is not used in other links.
            //
            for(Iterator<List<Integer>> linkIterator = this.linkedPortList.iterator(); linkIterator.hasNext(); )
            {
                List<Integer> link = linkIterator.next();
                for(int idx=0; idx < link.size(); idx++)
                {
                    if(link.get(idx).equals(portListNo) || link.get(idx).equals(portNo))
                    {
                        return(ResultCodes.FAIL_PORTINUSE);
                    }
                }
            }
            
            // Ok, safe to add this port onto the requested port list.
            //
            this.linkedPortList.get(portListNo).add(portNo);
        } else
        {
            return(ResultCodes.FAIL_BADPARAMETERS);
        }

        // Update flag to indicate an IO change has been made.
        //
        this.ioUpdated = true;

        // Success!
        return(ResultCodes.SUCCESS);
    }

    // Method to delete a port from a linked list of another port.
    //
    public ResultCodes delLinkedPort(int portListNo, int portNo)
    {
        // Ensure that the parameters are valid.
        //
        if(this.linkedPortList.size() >= portListNo && portListNo < this.maxPort)
        {
            for(int idx=0; idx < this.linkedPortList.get(portListNo).size(); idx++)
            {
                if( this.linkedPortList.get(portListNo).get(idx).equals(portNo) )
                {
                    this.linkedPortList.get(portListNo).remove(idx);
                }
            }
        } else
        {
            return(ResultCodes.FAIL_BADPARAMETERS);
        }

        // Update flag to indicate an IO change has been made.
        //
        this.ioUpdated = true;

        // Success!
        return(ResultCodes.SUCCESS);
    }

    // Method to install a pre-configured Array of port number lists, overwriting exiting Array if it exits.
    //
    public void setLinkedPortList(List<List<Integer>> linkedPortList)
    {
        LOG.finer("Set a Linked Port List:" + portList);
        this.linkedPortList = linkedPortList;

        // Update flag to indicate an IO change has been made.
        //
        this.ioUpdated = true;
    }

    // Action Methods. //

    // Method to run the IO processing and scheduling. An Executor is used to schedule the run of each Port run() method
    // at a frequent interval. A driver thread is also created on each driver to allow a mutex point where the physical
    // hardware gets updated (for hardware which isnt directly attached and instantly manipulated). 
    //
    public void run()
    {
        // Stay in the method until an external event sets the ioTerminate flag.
        //
        while(!this.ioTerminate)
        {
            ScheduledExecutorService executor         = Executors.newScheduledThreadPool(this.maxPort);
            List<Integer>            sequentialPorts  = new ArrayList<Integer>();
            List<Integer>            parentPorts      = new ArrayList<Integer>();

            // Reset ioUpdated flag as we are only interested in its state during this method run.
            //
            this.ioUpdated = false;

            // If an ioStop is active, loop until it is reset.
            //
            while(this.ioStop)
            {
                try {
                    TimeUnit.MILLISECONDS.sleep(500);
                }
                catch (InterruptedException e) {
                    ; // We dont care if we get interrupted and exit sooner, the sleep is only to conserve CPU resource.
                }
            }

            // Setup variables and identify linked ports, these have to be processed sequentially.
            //
            for(int idx=0; idx < this.portList.size(); idx++)
            {
                // If the port linked list exists, process and add the linked ports into the sequential list.
                //
                if(this.linkedPortList.get(idx).size() > 0)
                {
                    sequentialPorts.add(idx);
                    parentPorts.add(idx);
                    for(int idx2=0; idx2 < this.linkedPortList.get(idx).size(); idx2++)
                    {
                        sequentialPorts.add(this.linkedPortList.get(idx).get(idx2));
                    }
                }
            }

            // Submit each port to the executor. Linked ports: only the parent gets a running thread, the parent takes
            // responsibility for invoking the child port method.
            //
            for(int idx=0; idx < this.portList.size(); idx++)
            {
                // Non linked ports or parents of linked ports are set running by a new thread.
                //
                if(sequentialPorts.contains(idx) == false || parentPorts.contains(idx) == true)
                {
                    // Only start a thread on the port if the port is enabled, no need to waste resource.
                    //
                    if(portList.get(idx).isEnabled())
                    {
                        // Indicate progress if needed.
                        //
                        LOG.finer("Launching thread to process port: " + idx);

                        // Make a final copy of the port object in order to call it's methods via the ExecutorService.
                        //
                        final Port port = this.portList.get(idx);
    
                        // Submit the task.
                        //
                        executor.scheduleWithFixedDelay((new Runnable() { @Override public void run()
                                                                          {
                                                                              port.run();
                                                                          }
                                                                        }), 0, port.getRunInterval(), TimeUnit.MILLISECONDS);
                    }
                }
            }

            // Submit each driver to the executor.
            //
            for(int idx=0; idx < this.driverList.size(); idx++)
            {
                // Make a final copy of the driver object in order to call it's methods via the ExecutorService.
                //
                final Driver driver = this.driverList.get(idx);

                // Submit the task.
                //
                executor.scheduleWithFixedDelay((new Runnable() { @Override public void run()
                                                                  {
                                                                      driver.run();
                                                                  }
                                                                }), 0, driver.getRunInterval(), TimeUnit.MILLISECONDS);
            }

            // Set the flag to indicate that the io is running.
            //
            this.ioIsRunning = true;
            LOG.finer("IO is Running.");

            // Sleep until an external event triggers an action.
            //
            while(!this.ioTerminate && !this.ioUpdated && !this.ioStop)
            {
                try {
                    TimeUnit.MILLISECONDS.sleep(500);
                }
                catch (InterruptedException e) {
                    ; // We dont care if we get interrupted and exit sooner, the sleep is only to conserve CPU resource.
                }
            }

            // If requested to stop or if the linkedPortList has changed then we need to close the current executor jobs
            // then recalculate and start the run list as required.
            //
            if(this.ioStop || this.ioUpdated || this.ioTerminate)
            {
                // Firstly stop any threads assigned to the ports.
                //
                for(int idx=0; idx < this.portList.size(); idx++)
                {
                    portList.get(idx).stopThreads();
                }

                // Now stop any threads assigned to IO.
                //
                try {
                    String               message="IO Config Updated, shutting down IO for reinitialisation.";
                    if(this.ioStop)      message="IO Stop requested, shutting down IO processing.";
                    if(this.ioTerminate) message="IO Terminate requested, shutting down IO processing.";
                    LOG.info(message);
                    executor.shutdown();
                    executor.awaitTermination(1, TimeUnit.SECONDS);
                }
                catch (InterruptedException e) {
                    ;
                }
                finally {
                    if(!executor.isTerminated()) {
                        executor.shutdownNow();
                    }
                }

                LOG.finer("IO Shutdown complete.");
            }

            // Set the flag to indicate that the io has been stopped.
            //
            this.ioIsRunning = false;
        }
    }
}
