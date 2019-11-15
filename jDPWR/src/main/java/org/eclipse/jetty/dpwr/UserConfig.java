/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            UserConfig.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     A User encapsulation class to handle data pertaining to a user of the system.
//                  Provides methods to set the data and access it as required.
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

public class UserConfig implements java.io.Serializable
{
    // ##############################
    // # USER Specific Configuration
    // ##############################
    private String     loginUser;         // Id of a User who can access the web interace.
    private String     loginPassword;     // Password of above User Id, leave blank for no password.
    private int        loginLevel;        // Authorisation level, 1=All, 1=Operator, 2=Admin, 3=Root.

    public UserConfig()
    {
    }

    public String getLoginUser()
    {
        return(this.loginUser);
    }

    public String getLoginPassword()
    {
        return(this.loginPassword);
    }

    public int getLoginLevel()
    {
        return(this.loginLevel);
    }

    public void setLoginUser(String loginUser)
    {
        this.loginUser = loginUser;
    }

    public void setLoginPassword(String loginPassword)
    {
        this.loginPassword = loginPassword;
    }

    public void setLoginLevel(int loginLevel)
    {
        this.loginLevel = loginLevel;
    }
}
