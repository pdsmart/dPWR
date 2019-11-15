/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            jDPWR.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     Main class, instantiates all classes required to perform the jDPWR functionality,
//                  configures them, sets up and controls the IO, and interacts with the user through
//                  the web-interface.
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
//File;
//import java.io.FileNotFoundException;
//import java.io.IOException;
//import java.io.BufferedOutputStream;
//import java.io.FileOutputStream;
//import java.io.FileWriter;
//import java.io.InputStream;
import java.net.*;
//import java.net.URI;
//import java.net.URISyntaxException;
//import java.net.URL;
//import java.net.URLClassLoader;
import java.math.BigDecimal;
import java.util.*;
//import java.util.ArrayList;
//import java.util.List;
//import java.util.Vector;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.LogManager;
import java.net.JarURLConnection;
import java.util.jar.Manifest;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Cookie;
import com.fasterxml.jackson.core.JsonGenerationException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;

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

//import com.acme.DateServlet;
import org.eclipse.jetty.dpwr.DPWRServlet;

public class jDPWR
{
    // #############################
    // # 
    // #############################
    //
    // Constants.
    // 
    private static final String             CONFIG_FILE            = "../jDPWR.cfg";
    private static final String             DEFAULT_CONFIG_FILE    = "../jDPWR.cfg.default";

    // Maxims.
    //

    // Variables.
    //
    private static final Logger LOG = Logger.getLogger(jDPWR.class.getName());
    private Server             server;
    private URI                serverURI;
    private IO                 io;
    private static DPWRServlet dpwr;

    // Entry point into program, perform all initialisation here and command line 
    // argument parsing.
    //
    public static void main(String[] args) throws Exception
    {
        // Read the configuration directly into the DPWRServlet Bean.
        //
        ObjectMapper mapper = new ObjectMapper();
        Boolean readDefault = false;
        try {
            dpwr = mapper.readValue(new File(CONFIG_FILE), DPWRServlet.class);
            LOG.info("Loaded configuration: " + CONFIG_FILE);
        }
        catch (JsonGenerationException e) {
            e.printStackTrace();
            System.out.println("Configuration File: " + CONFIG_FILE + " Generation error - ie. config file is corrupt, exitting.");
            System.exit(-1);
        }
        catch (JsonMappingException e) {
            e.printStackTrace();
            System.out.println("Configuration File: " + CONFIG_FILE + " Mapping error - ie. config file is not valid!");
            readDefault = true;
        }
        catch (IOException e) {
            e.printStackTrace();
            System.out.println("Configuration File: " + CONFIG_FILE + " does not exist!");
            readDefault = true;
        }

        // If we cant read in the working config file, then revert to the factory default, if this cant be read, exit.
        //
        if(readDefault)
        {
            System.out.println("Reading default configuration: "  + DEFAULT_CONFIG_FILE);
            try {
                dpwr = mapper.readValue(new File(DEFAULT_CONFIG_FILE), DPWRServlet.class);
                LOG.info("Loaded default configuration: " + DEFAULT_CONFIG_FILE);
            }
            catch (Exception e) {
                e.printStackTrace();
                System.out.println("Default Configuration File: " + DEFAULT_CONFIG_FILE + " not valid, exitting.");
                System.exit(-2);
            }
        }

        // Configure the logfile mechanism.
        //
        ClassLoader cl = Thread.currentThread().getContextClassLoader();
        URL url = cl.getResource("logging.properties");
        if (url != null)
        {
            try(InputStream in = url.openStream())
            {
                LogManager.getLogManager().readConfiguration(in);
            }
            catch (IOException e)
            {
                e.printStackTrace(System.err);
            }
        }
        Log.setLog(new JavaUtilLog());

        // Instantiate the jDPWR application and start it.
        //
        jDPWR app = new jDPWR(dpwr);
        app.start();

        // Block until complete then exit.
        //
        app.waitForInterrupt();
    }

    // CONSTRUCTOR.
    //
    public jDPWR(DPWRServlet dpwr)
    {
        this.dpwr = dpwr;
        this.io   = dpwr.getIO();
    }

    public URI getServerURI()
    {
        return(this.serverURI);
    }

    public void testScenario() throws Exception
    {
        // Write out current config file for comparison.
        //
        ObjectMapper mapper = new ObjectMapper();
        try {
            mapper.writerWithDefaultPrettyPrinter().writeValue(new File("JSON.cur"), this.dpwr);
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
    
        Thread.sleep(10000);
    
        LOG.finer("Deleting a driver and writing JSONDEL.txt");
        Driver testDriver = this.io.getDriver(0);
        this.io.delDriver(testDriver);
        try {
            mapper.writerWithDefaultPrettyPrinter().writeValue(new File("JSON.del"), this.dpwr);
            LOG.finer("THIS IS THE CONFIG AFTER DELETING:" + this.dpwr);
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
    
        Thread.sleep(5000);
    
        LOG.finer("Reading original config: " + CONFIG_FILE);
        DPWRServlet newDpwr = new DPWRServlet();
        try {
            newDpwr = mapper.readValue(new File(CONFIG_FILE), DPWRServlet.class);
            LOG.finer("THIS IS THE CONFIG AFTER READING:" + this.dpwr);
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
    
        LOG.finer("Writing the original configuration to JSON.cmp");
        try {
            mapper.writerWithDefaultPrettyPrinter().writeValue(new File("JSON.cmp"), this.dpwr);
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
    }

    public void start() throws Exception
    {
        this.server = new Server();
        ServerConnector connector = connector();
        this.server.addConnector(connector);
//        this.server.addBean(dpwr);

        URI baseUri = getWebRootResourceUri();

        // Set JSP to use Standard JavaC always
        System.setProperty("org.apache.jasper.compiler.disablejsr199", "false");

        WebAppContext webAppContext = getWebAppContext(baseUri, getScratchDir());

        this.server.setHandler(webAppContext);

        // In order to ensure the jtsl taglibs work correctly, add in the search path.
        //
        ClassLoader currentClassLoader = Thread.currentThread().getContextClassLoader();
        URL urlTaglibs = new File("org.apache.taglibs").toURI().toURL();
        URLClassLoader newClassLoader = new URLClassLoader(new URL[]{urlTaglibs},currentClassLoader);
        Thread.currentThread().setContextClassLoader(newClassLoader);

        // Start Server
        this.server.start();

        // Show server state
        if (LOG.isLoggable(Level.FINE))
        {
            LOG.fine(this.server.dump());
        }
        this.serverURI = getServerUri(connector);

        // Create a thread for the IO app component and attach it to the main IO object.
        //
        Thread ioT;
        ioT = new Thread(this.io, "IOMain");
        LOG.finer("IO Main thread is starting");
        ioT.start();

        // Perform testing as needed.
        //
        //testScenario();

        // Wait for IO processing to finish before tidying up to exit.
        //
        ioT.join();
        LOG.info("IO Thread has joined");
    }

    private ServerConnector connector()
    {
        ServerConnector connector = new ServerConnector(this.server);
        connector.setHost(this.dpwr.getHttp().getServerHost());
        connector.setPort(this.dpwr.getHttp().getServerPort());
        return connector;
    }

    private URI getWebRootResourceUri() throws FileNotFoundException, URISyntaxException
    {
        URL indexUri = this.getClass().getResource(this.dpwr.getHttp().getDocPath());
        if (indexUri == null)
        {
            throw new FileNotFoundException("Unable to find resource " + this.dpwr.getHttp().getDocPath());
        }
        // Points to wherever /webroot/ (the resource) is
        return indexUri.toURI();
    }

    /**
     * Establish Scratch directory for the servlet context (used by JSP compilation)
     */
    private File getScratchDir() throws IOException
    {
        File tempDir = new File(System.getProperty("java.io.tmpdir"));
        File scratchDir = new File(tempDir.toString(), "embedded-jetty-jsp");

        if (!scratchDir.exists())
        {
            if (!scratchDir.mkdirs())
            {
                throw new IOException("Unable to create scratch directory: " + scratchDir);
            }
        }
        return scratchDir;
    }

    /**
     * Setup the basic application "context" for this application at "/"
     * This is also known as the handler tree (in jetty speak)
     */
    private WebAppContext getWebAppContext(URI baseUri, File scratchDir)
    {
        WebAppContext context = new WebAppContext();
        context.setContextPath("/");

        context.setAttribute("javax.servlet.context.tempdir", scratchDir);
        context.setAttribute("org.eclipse.jetty.server.webapp.ContainerIncludeJarPattern",
          ".*/[^/]*servlet-api-[^/]*\\.jar$|.*/javax.servlet.jsp.jstl-.*\\.jar$|.*/.*taglibs.*\\.jar$");

        org.eclipse.jetty.webapp.Configuration.ClassList classlist = org.eclipse.jetty.webapp.Configuration.ClassList.setServerDefault(server);
        classlist.addAfter("org.eclipse.jetty.webapp.FragmentConfiguration", "org.eclipse.jetty.plus.webapp.EnvConfiguration", "org.eclipse.jetty.plus.webapp.PlusConfiguration");
        classlist.addBefore("org.eclipse.jetty.webapp.JettyWebXmlConfiguration", "org.eclipse.jetty.annotations.AnnotationConfiguration");

        context.setResourceBase(baseUri.toASCIIString());
        context.setAttribute("org.eclipse.jetty.containerInitializers", jspInitializers());
        context.setAttribute(InstanceManager.class.getName(), new SimpleInstanceManager());

        // Attach configuration beans/attributes to the context so that they can be used within JSP pages.
        //
        context.setAttribute("system",  this.dpwr.getSystem());
        context.setAttribute("product", this.dpwr.getProduct());
        context.setAttribute("http",    this.dpwr.getHttp());
        context.setAttribute("email",   this.dpwr.getEmail());
        context.setAttribute("ddns",    this.dpwr.getDDNS());
        context.setAttribute("time",    this.dpwr.getTime());
        context.setAttribute("userList",this.dpwr.getUserList());
        context.setAttribute("io",      this.dpwr.getIO());

        context.addBean(new ServletContainerInitializersStarter(context), true);
        context.setClassLoader(getUrlClassLoader());

        // Add in the JSP processor on all files ending in .jsp
        //
        context.addServlet(jspServletHolder(), "*.jsp");

        // Add in the already instanciated DPWR Servlet.
        //
        ServletHolder sh = new ServletHolder(this.dpwr);
        context.addServlet(sh, "/dpwr/*");

        // Finally, add the static default server on root /.
        //
        context.addServlet(exampleJspFileMappedServletHolder(), "/test/foo/");
        context.addServlet(defaultServletHolder(baseUri), "/");

        //
        //
        // configure the default servlet to serve static files from "htdocs" in the classpath   
        //context.addServlet(new ServletHolder(new ClasspathFilesServlet("/htdocs")),"/");
        
        // use /uuid to get a fresh id
        //context.addServlet(new ServletHolder(new UUIDServlet()), "/uuid");
        
        // the actual key/value store
        //context.addServlet(new ServletHolder(new KeyValueServlet()), "/store/*");
        
        // bind a publishServlet to /quotes
        //final PublishServlet publishServlet = new PublishServlet();
        //context.addServlet(new ServletHolder(publishServlet), "/quotes");
        
        // setup the quote service
        //InputStream stream = jDPWR.class.getClassLoader().getResourceAsStream("hitchhiker_guide_to_the_galaxy_quotes.txt");        
        //final QuoteService guideQuoteService = QuoteService.fromInputStream(stream);
        
        // send out a new quote every 3 to 10 seconds
        //new RandomTimer(3, 10) {            
        //    @Override
        //    public void tick() {
        //        publishServlet.publish(guideQuoteService.getRandomQuote());                
        //    }
        //};         

        return context;
    }

    /**
     * Ensure the jsp engine is initialized correctly
     */
    private List<ContainerInitializer> jspInitializers()
    {
        JettyJasperInitializer sci = new JettyJasperInitializer();
        ContainerInitializer initializer = new ContainerInitializer(sci, null);
        List<ContainerInitializer> initializers = new ArrayList<ContainerInitializer>();
        initializers.add(initializer);
        return initializers;
    }

    /**
     * Set Classloader of Context to be sane (needed for JSTL)
     * JSP requires a non-System classloader, this simply wraps the
     * embedded System classloader in a way that makes it suitable
     * for JSP to use
     */
    private ClassLoader getUrlClassLoader()
    {
        ClassLoader jspClassLoader = new URLClassLoader(new URL[0], this.getClass().getClassLoader());
        return jspClassLoader;
    }


    /**
     * Create JSP Servlet (must be named "jsp")
     */
    private ServletHolder jspServletHolder()
    {
        ServletHolder holderJsp = new ServletHolder("jsp", JettyJspServlet.class);
        holderJsp.setInitOrder(0);
        holderJsp.setInitParameter("logVerbosityLevel", "DEBUG");
        holderJsp.setInitParameter("fork", "false");
        holderJsp.setInitParameter("xpoweredBy", "false");
        holderJsp.setInitParameter("compilerTargetVM", "1.7");
        holderJsp.setInitParameter("compilerSourceVM", "1.7");
        holderJsp.setInitParameter("keepgenerated", "true");
        return holderJsp;
    }

    /**
     * Create Example of mapping jsp to path spec
     */
    private ServletHolder exampleJspFileMappedServletHolder()
    {
        ServletHolder holderAltMapping = new ServletHolder();
        holderAltMapping.setName("foo.jsp");
        holderAltMapping.setForcedPath("/test/foo/foo.jsp");
        return holderAltMapping;
    }

    /**
     * Create Default Servlet (must be named "default")
     */
    private ServletHolder defaultServletHolder(URI baseUri)
    {
        ServletHolder holderDefault = new ServletHolder("default", DefaultServlet.class);
        LOG.info("Base URI: " + baseUri);
        holderDefault.setInitParameter("resourceBase", baseUri.toASCIIString());
        holderDefault.setInitParameter("dirAllowed", "true");
        return holderDefault;
    }

    /**
     * Establish the Server URI
     */
    private URI getServerUri(ServerConnector connector) throws URISyntaxException
    {
        String scheme = "http";
        for (ConnectionFactory connectFactory : connector.getConnectionFactories())
        {
            if (connectFactory.getProtocol().equals("SSL-http"))
            {
                scheme = "https";
            }
        }
        String host = connector.getHost();
        if (host == null)
        {
            host = "localhost";
        }
        int port = connector.getLocalPort();
        this.serverURI = new URI(String.format("%s://%s:%d/", scheme, host, port));
        LOG.info("Server URI: " + this.serverURI);

        return(this.serverURI);
    }

    public void stop() throws Exception
    {
        this.server.stop();
    }

    /**
     * Cause server to keep running until it receives a Interrupt.
     * <p>
     * Interrupt Signal, or SIGINT (Unix Signal), is typically seen as a result of a kill -TERM {pid} or Ctrl+C
     * @throws InterruptedException if interrupted
     */
    public void waitForInterrupt() throws InterruptedException
    {
        this.server.join();
    }
}
