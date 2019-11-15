/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            DDNSConfig.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     DDNS Configuration module.
//                  This package is responsible for configuring the Dynamic DNS Server. All methods
//                  are specific to manipulating the DDNS object.
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
import java.lang.IndexOutOfBoundsException;

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

public class DDNSConfig implements java.io.Serializable
{
    // ##############################
    // # DDNS Configuration
    // ##############################
    private Boolean       enabled;           // Enable/Disable the DDNS configuration service.
    private String        serverIP;          // IP or hostname of DDNS server.
    private String        clientDomain;      // Domain name of the client, ie the one to setup the IP against.
    private String        clientUserName;    // Username on the Server for this client.
    private String        clientPassword;    // Password for the above client on the Server.
    private Boolean       proxyEnabled;      // Enable/Disable the Proxy through which we connect to the server.
    private String        proxyIP;           // IP Address of the Proxy Server.
    private int           proxyPort;         // Port on which the Proxy Server listens.

    public DDNSConfig()
    {
    }

    public Boolean isEnabled()
    {
        return(this.enabled);
    }

    public String getServerIP()
    {
        return(this.serverIP);
    }

    public String getClientDomain()
    {
        return(this.clientDomain);
    }

    public String getClientUserName()
    {
        return(this.clientUserName);
    }

    public String getClientPassword()
    {
        return(this.clientPassword);
    }

    public Boolean isProxyEnabled()
    {
        return(this.proxyEnabled);
    }

    public String getProxyIP()
    {
        return(this.proxyIP);
    }

    public int getProxyPort()
    {
        return(this.proxyPort);
    }

    public void setEnabled(Boolean enabled)
    {
        this.enabled = enabled;
    }

    public void setServerIP(String serverIP)
    {
        this.serverIP = serverIP;
    }

    public void setClientDomain(String clientDomain)
    {
        this.clientDomain = clientDomain;
    }

    public void setClientPassword(String clientPassword)
    {
        this.clientPassword = clientPassword;
    }

    public void setProxyEnabled(Boolean proxyEnabled)
    {
        this.proxyEnabled = proxyEnabled;
    }

    public void setProxyIP(String proxyIP)
    {
        this.proxyIP = proxyIP;
    }

    public void setProxyPort(int proxyPort)
    {
        this.proxyPort = proxyPort;
    }
}

