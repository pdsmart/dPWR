/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            LoggingUtil.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     Generic Logging class using Jetty:: logging.
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

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.logging.LogManager;

public final class LoggingUtil
{
    public static void config()
    {
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
    }
}
