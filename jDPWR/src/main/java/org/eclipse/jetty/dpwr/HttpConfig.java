/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            HTTPConfig.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     HTTP object class, provides methods to setup the Jetty:: HTTP Server.
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
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.Vector;
import java.net.JarURLConnection;
import java.util.jar.Manifest;

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

public class HttpConfig implements java.io.Serializable
{
    //                       PARAMETER                       DESCRIPTION
    //                       ---------                       -----------
    private String           serverHost;                 // IP address of the internal HTTP server.
    private int              serverPort;                 // PORT of the internal HTTP server.
    private String           docPath;                    // Local path containing HTML documents to be served to web browsers.
    private String           password;                   // Password for protected HTTP server pages.
    private int              maxRetries;                 // Not currently used.
    private int              sessionTimeout;             // Inactivity timer in seconds before user is logged out.

    public HttpConfig()
    {
    }

    public String getServerHost()
    {
        return(this.serverHost);
    }
    public int getServerPort()
    {
        return(this.serverPort);
    }
    public String getDocPath()
    {
        return(this.docPath);
    }
    public String getPassword()
    {
        return(this.password);
    }
    public int getMaxRetries()
    {
        return(this.maxRetries);
    }
    public int getSessionTimeout()
    {
        return(this.sessionTimeout);
    }

    public void setServerHost(String serverHost)
    {
        this.serverHost = serverHost;
    }
    public void setServerPort(int serverPort)
    {
        this.serverPort = serverPort;
    }
    public void setDocPath(String docPath)
    {
        this.docPath = docPath;
    }
    public void setPassword(String password)
    {
        this.password = password;
    }
    public void setMaxRetries(int maxRetries)
    {
        this.maxRetries = maxRetries;
    }
    public void setSessionTimeout(int sessionTimeout)
    {
        this.sessionTimeout = sessionTimeout;
    }
}
