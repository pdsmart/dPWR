/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            RequestWrapper.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     A class to encapuslate an HTTP request URI and modify it according to requirements.
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
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

// Jackson imports for serialization of this bean into JSON files.
//
import com.fasterxml.jackson.annotation.JsonIgnore;

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

class RequestWrapper extends HttpServletRequestWrapper
{
    private String originalDestination, newDestinationAgent;
    
    /*
     * Constructor
     */
    public RequestWrapper(HttpServletRequest request)
    {
        super(request);
    }
    
    /*
     */
    @Override
    public String getRequestURI()
    {
        String originalURI = super.getRequestURI();
        
        StringBuffer newURI = new StringBuffer();
        
        newURI.append(originalURI.substring(0, originalURI.indexOf(originalDestination)));
        newURI.append(newDestinationAgent);
        newURI.append(originalURI.substring(originalURI.indexOf(originalDestination) + originalDestination.length(), 
                                            originalURI.length()));
        
        return newURI.toString();
    }
    
    /**
     * Change the original destination to a new destination.
     * 
     * @param originalDestination
     * @param newDestination
     */
    protected void changeDestination(String originalDestination, String newDestination)
    {
        this.originalDestination = originalDestination;
        this.newDestinationAgent = newDestination;
    }
}
