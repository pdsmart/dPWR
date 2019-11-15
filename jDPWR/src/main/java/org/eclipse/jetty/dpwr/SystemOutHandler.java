/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            SystemOutHandler.java
// Created:         March 2017
// Author(s):       Philip Smart
// Description:     A helper class for the logger to handle formatted output of log data.
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

import java.util.logging.Handler;
import java.util.logging.LogRecord;
import java.text.SimpleDateFormat;
import java.util.Date;

public class SystemOutHandler extends Handler
{
    @Override
    public void publish(LogRecord record)
    {
        Date now = new Date();
        SimpleDateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss");

        String logname = record.getLoggerName();
        int idx = logname.lastIndexOf('.');
        if (idx > 0)
        {
            logname = logname.substring(idx + 1);
        }

        StringBuilder buf = new StringBuilder();
        buf.append(dateFormatter.format(now)).append(" ");
        buf.append("[").append(record.getLevel().getName());
        buf.append(":").append(logname).append("] ");
        buf.append(record.getMessage());

        System.out.println(buf.toString());
        if (record.getThrown() != null)
        {
            record.getThrown().printStackTrace(System.out);
        }
    }

    @Override
    public void flush()
    {
    }

    @Override
    public void close() throws SecurityException
    {
    }
}
