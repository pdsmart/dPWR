/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            TimeConfig.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     A Time encapsulation class to handle the setup and configuration of NTP.
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

public class TimeConfig implements java.io.Serializable
{
    // ###############################
    // # TIME Configuration
    // ###############################
    private String     localOrNtp;         // Use local set time or an NTP server.
    private String     ntpServerIP;        // IP or hostname of NTP server.
    private String     ntpTimeZoneId;      // Time Zone Id.
    private int        ntpTimeZoneDst;     // Daylight Savings Time applies (1), does not apply (0).
    private int        ntpTimeZoneOffset;  // Time Zone offset from GMT.


    public TimeConfig()
    {
    }

    public String getLocalOrNtp()
    {
        return(this.localOrNtp);
    }

    public String getNtpServerIP()
    {
        return(this.ntpServerIP);
    }

    public String getNtpTimeZoneId()
    {
        return(this.ntpTimeZoneId);
    }

    public int getNtpTimeZoneDst()
    {
        return(this.ntpTimeZoneDst);
    }

    public int getNtpTimeZoneOffset()
    {
        return(this.ntpTimeZoneOffset);
    }

    public void setLocalOrNtp(String localOrNtp)
    {
        this.localOrNtp = localOrNtp;
    }

    public void setNtpServerIP(String ntpServerIP)
    {
        this.ntpServerIP = ntpServerIP;
    }

    public void setNtpTimeZoneId(String ntpTimeZoneId)
    {
        this.ntpTimeZoneId = ntpTimeZoneId;
    }

    public void setNtpTimeZoneDst(int ntpTimeZoneDst)
    {
        this.ntpTimeZoneDst = ntpTimeZoneDst;
    }

    public void setNtpTimeZoneOffset(int ntpTimeZoneOffset)
    {
        this.ntpTimeZoneOffset = ntpTimeZoneOffset;
    }
}
