/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            StaticFilter.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     A filter class to handle cookies and the insertion of stored cookie data into the URI.
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
import java.lang.String;
import java.util.regex.Pattern;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;
import javax.servlet.http.Cookie;

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

public class StaticFilter implements Filter, java.io.Serializable
{
    // ###############################
    // # StaticFilter Configuration
    // ###############################
    // Bean variables to control a device.
    //
    @JsonIgnore
    private static final Logger LOG = Logger.getLogger(StaticFilter.class.getName());    

    @Override
    public void init(FilterConfig fc) throws ServletException {
    }

    @Override
    public void destroy() {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException
    {
        //RequestWrapper modifiedRequest = null;

        HttpServletRequest req = (HttpServletRequest) request;
        //String path = req.getRequestURI().substring(req.getContextPath().length());
        String path = req.getRequestURI().toString();

        // Setup any session variables to defaults if this is a new session.
        //
        HttpSession session = req.getSession(true);
        if(session.isNew())
        {
            // Setup as default, let cookie value override.
            //
            session.setAttribute("AllOnApply",            false);
            session.setAttribute("SetOutputRefreshTime",  10);
            session.setAttribute("ReadInputRefreshTime",  10);
            session.setAttribute("NotificationTime",      10);
            session.setAttribute("Notification",          "");
            session.setAttribute("NotificationColour",    "red");
            session.setAttribute("CurrentTheme",          "cerulean");
            session.setAttribute("is-ajax",               true);
            session.setAttribute("MainPage",              "dash.jsp");
            session.setAttribute("SetOutputRowsPerPage",  10);
            session.setAttribute("ReadInputRowsPerPage",  10);

            LOG.finest("Initialised Session.");
        }

        // Process cookies, if none found for a parameter, assume default.
        //
        Cookie cookie = null;
        Cookie[] cookies = null;

        // Get an array of Cookies associated with this domain.
        //
        cookies = req.getCookies();
        if( cookies != null && (path.equals("/") || path.matches("^.*jsp$")) )
        {
            for (int idx = 0; idx < cookies.length; idx++)
            {
                cookie = cookies[idx];
                if     (cookie.getName().equals("AllOnApply"))             { session.setAttribute("AllOnApply",           cookie.getValue()); }
                else if(cookie.getName().equals("SetOutputRefreshTime"))   { session.setAttribute("SetOutputRefreshTime", cookie.getValue()); }
                else if(cookie.getName().equals("ReadInputRefreshTime"))   { session.setAttribute("ReadInputRefreshTime", cookie.getValue()); }
                else if(cookie.getName().equals("NotificationTime"))       { session.setAttribute("NotificationTime",     cookie.getValue()); }
                else if(cookie.getName().equals("Notification"))           { session.setAttribute("Notification",         cookie.getValue()); }
                else if(cookie.getName().equals("NotificationColour"))     { session.setAttribute("NotificationColour",   cookie.getValue()); }
                else if(cookie.getName().equals("CurrentTheme"))           { session.setAttribute("CurrentTheme",         cookie.getValue()); }
                else if(cookie.getName().equals("is-ajax"))                { session.setAttribute("is-ajax",              cookie.getValue()); }
                else if(cookie.getName().equals("MainPage"))               { session.setAttribute("MainPage",             cookie.getValue()); }
                else if(cookie.getName().equals("SetOutputRowsPerPage"))   { session.setAttribute("SetOutputRowsPerPage", cookie.getValue()); }
                else if(cookie.getName().equals("ReadInputRowsPerPage"))   { session.setAttribute("ReadInputRowsPerPage", cookie.getValue()); }
                else
                {
                    LOG.info("Cookie:" + cookie.getName() + ", Value:" + cookie.getValue() + " - is not handled!");
                }
            }
        }

        LOG.finest("URI:" + req.getRequestURI().toString());
        chain.doFilter(request, response);
    }
}
