/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            EmailConfig.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     Email object class, provides all methods to create, maintain and use emails
//                  as required by jDPWR.
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

public class EmailConfig implements java.io.Serializable
{
    // ##############################
    // # EMAIL Specific Configuration
    // ##############################
    private String        smtpOrPop3;        // Use SMTP, POP3 or NO email service.
    private String        useAuthentication; // Connection with SMTP or POP3 service requires authentication.
    private String        smtpServerIP;      // IP or hostname of an smtp server through which to send emails.
    private int           smtpServerPort;    // Port on which the smtp server listens.
    private String        pop3ServerIP;      // IP or hostname of a POP3 server through which to send emails.
    private int           pop3ServerPort;    // Port on which the POP3 server listens.
    private String        userName;          // Username for SMTP gateway or POP3 server.
    private String        password;          // Password for SMTP gateway or POP3 server.
    private String        sender;            // Sender (from:) of the email.
    private List<String>  recipient = new ArrayList<String>();         // Recipient (to:) of the email.
    private String        subject;           // Subject of the email, overrides in-built default.
    private String        mailBody;          // Contents of the email, overrides in-built default.

    public EmailConfig()
    {
    }

    public String getSmtpOrPop3()
    {
        return(this.smtpOrPop3);
    }

    public String getUseAuthentication()
    {
        return(this.useAuthentication);
    }

    public String getSmtpServerIP()
    {
        return(this.smtpServerIP);
    }

    public int getSmtpServerPort()
    {
        return(this.smtpServerPort);
    }

    public String getPop3ServerIP()
    {
        return(this.pop3ServerIP);
    }

    public int getPop3ServerPort()
    {
        return(this.pop3ServerPort);
    }

    public String getUserName()
    {
        return(this.userName);
    }

    public String getPassword()
    {
        return(this.password);
    }

    public String getSender()
    {
        return(this.sender);
    }

    public String getRecipient(int i)
    {
        return(this.recipient.get(i));
    }

    public List<String> getRecipient()
    {
        return(this.recipient);
    }

    public String getSubject()
    {
        return(this.subject);
    }

    public String getMailBody()
    {
        return(this.mailBody);
    }

    public void setSmtpOrPop3(String smtpOrPop3)
    {
        this.smtpOrPop3 = smtpOrPop3;
    }

    public void setUseAuthentication(String userAuthentication)
    {
        this.useAuthentication = useAuthentication;
    }

    public void setSmtpServerIP(String smtpServerIP)
    {
        this.smtpServerIP = smtpServerIP;
    }

    public void setSmtpServerPort(int smtpServerPort)
    {
        this.smtpServerPort = smtpServerPort;
    }

    public void setPop3ServerIP(String pop3ServerIP)
    {
        this.pop3ServerIP = pop3ServerIP;
    }

    public void setPop3ServerPort(int pop3ServerPort)
    {
        this.pop3ServerPort = pop3ServerPort;
    }

    public void setUserName(String userName)
    {
        this.userName = userName;
    }

    public void setPassword(String password)
    {
        this.password = password;
    }

    public void setSender(String sender)
    {
        this.sender = sender;
    }

    public void addRecipient(String recipient)
    {
        this.recipient.add(recipient);
    }

    public void setRecipient(int i, String recipient)
    {
        try {
            this.recipient.set(i, recipient);
        }
        catch(IndexOutOfBoundsException e)
        {
            this.addRecipient(recipient);
        }
        catch(NullPointerException e)
        {
            System.out.println("Caught it: " + recipient);
        }
    }

    public void setRecipient(List<String> recipient)
    {
        this.recipient = recipient;
    }

    public void setSubject(String subject)
    {
        this.subject = subject;
    }

    public void setMailBody(String mailBody)
    {
        this.mailBody = mailBody;
    }
}

