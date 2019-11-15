#########################################################################################################
##
## Name:            NC800.pm
## Created:         September 2015
## Author(s):       Philip Smart
## Description:     A perl module which forms part of the dPWR program.
##                  This module provides all the Private and Public API calls which interface the 
##                  NC800 Ethernet based Relay Board to the dPWR program.
##
## Credits:         
## Copyright:       (c) 2015-2019 Philip Smart <philip.smart@net2net.org>
##
## History:         September 2015   - Initial module written.
##
#########################################################################################################
## This source file is free software: you can redistribute it and#or modify
## it under the terms of the GNU General Public License as published
## by the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This source file is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
#########################################################################################################
package NC800;
require 5.8.0;
use strict;
use IO::File;
use File::Temp qw(tempfile);
use Switch;
use POSIX qw(SIGALRM SIGTERM sigaction);
use HTTP::Lite;
use IO::Socket;
use Net::Ping;

use vars qw(@ISA @EXPORT $VERSION);

$VERSION = 1.00;
@ISA     = qw(Exporter);

@EXPORT  = qw(Init,
              Terminate,
			  GetRelayState,
			  RelaySet,
              MainLoop
             );       # Symbols to autoexport (:DEFAULT tag)

#################################################################################
# NC800 Package.
#
# Description: This package contains all the functions which control the NC800
#              TCP power relay board.
#
# Members Functions:
#        ExpandFileName         - PRIVATE
#        LogFileWriter          - PUBLIC
#
# Members Variables:
#                               - PRIVATE
#                               - PUBLIC
# Comments: 
#
#################################################################################

{
    # Module wide constants
    #
    my $MODEM_RELAY                   =  1;
    my $SERVER_RESET_RELAY            =  2;
    my $SERVER_POWER_RELAY            =  3;
    my $RELAY_4                       =  4;
    my $RELAY_5                       =  5;
    my $RELAY_6                       =  6;
    my $RELAY_7                       =  7;
    my $RELAY_8                       =  8;

    # Map to map an external identifier to an internal relay value for active relays.
    #
	my  %reverse_RELAY_MAP            = ( $MODEM_RELAY                            => "MODEM",
										  $SERVER_RESET_RELAY                     => "SERVER_RESET",
										  $SERVER_POWER_RELAY                     => "SERVER_POWER"
										);
	our %RELAY_MAP                    = ( $reverse_RELAY_MAP{$MODEM_RELAY}        => $MODEM_RELAY,
										  $reverse_RELAY_MAP{$SERVER_RESET_RELAY} => $SERVER_RESET_RELAY,
										  $reverse_RELAY_MAP{$SERVER_POWER_RELAY} => $SERVER_POWER_RELAY
										);
	our %RELAY_STATE_MAP              = ( "0"                                     => 0,
										  "1"                                     => 1,
										  "OFF"                                   => 0,
										  "ON"                                    => 1,
										  "off"                                   => 0,
										  "on"                                    => 1
										);

	my %CURRENT_RELAY_STATE           = ( $MODEM_RELAY                            => 0,
			                              $SERVER_RESET_RELAY                     => 0,
                                          $SERVER_POWER_RELAY                     => 0
										);

    # Public variables (our)
    #
    our $NC800_IP                     = "";
    our $NC800_PORT                   =  0;
    our $NC800_PWD                    = "";
    our $NC800_MAX_HTTP_RETRIES       =  0;
    our $NC800_LOGFILE                = "";
    our $NC800_MODEM_PING_ADDR1       = "";
    our $NC800_MODEM_PING_ADDR2       = "";
    our $NC800_MODEM_MAXPING          = "";
    our $NC800_MODEM_PINGTIME         =  0;  # Period between Ping checks.
    our $NC800_MODEM_RESETTIME        =  0;  # Period that Modem is held in reset (power off) state.
    our $NC800_MODEM_CHECK_WAIT_TIME  =  0;  # Period of time to wait after modem reset before making checks.
    our $NC800_SERVER_PING_ADDR1      = "";
    our $NC800_SERVER_PING_ADDR2      = "";
    our $NC800_SERVER_MAXPING         =  0;
    our $NC800_SERVER_PINGTIME        =  0;  # Period between Ping checks.
    our $NC800_SERVER_RESETTIME       =  0;  # Period that Server is held in reset (reset button pressed).
    our $NC800_SERVER_CHECK_WAIT_TIME =  0;  # Period of time to wait after a reset or powercycle before making new checks.
    our $NC800_SERVER_MAXRESET        =  0;  # Number of consecutive reset attempts before a power cycle.
    our $NC800_SERVER_HOLDOFF_TIME    =  0;  # Period of time in seconds needed for Server to register a Power OFF request.
    our $NC800_SERVER_HOLDON_TIME     =  0;  # Period of time in seconds needed for Server to register a Power ON request.
    our $NC800_SERVER_POWEROFF_TIME   =  0;  # Period of time in seconds that the server is held in Power OFF state.

    # Private variables (my)
    #
    my $CURRENT_TIME                  =  0;
    my $MODEM_PING_COUNTER            =  0;
    my $MODEM_1_PING_TIMER            = -1;
    my $MODEM_2_PING_TIMER            = -1;
    my $MODEM_RESET_TIMER             = -1;
    my $MODEM_CHECK_WAIT_TIME         =  0;
    my $SERVER_PING_COUNTER           =  0;
    my $SERVER_1_PING_TIMER           = -1;
    my $SERVER_2_PING_TIMER           = -1;
    my $SERVER_RESET_TIMER            = -1;
    my $SERVER_RESET_COUNTER          =  0;
    my $SERVER_CHECK_WAIT_TIME        =  0;


    # Method to log information from this module, seperate from callers logging.
    #
    sub log
    {
        my ($error, $msg) = @_;
        my $date = scalar localtime;
        my ($dow, $mon, $dt, $tm, $yr) = ($date =~ m/(...) (...) (..) (..:..:..) (....)/);
        $dt += 0;
        $dt = substr("0$dt", length("0$dt") - 2, 2);
        $date = "$dt/$mon/$yr:$tm"; 

        if (open(LG_HDL, ">>$NC800_LOGFILE")) {
            print LG_HDL <<"EOF";
[$date]:$error:$msg
EOF
            close(LG_HDL);
        }
    }

    # Method to run a detached system command.
    #
    sub forkrun {
        my ($cmd)=@_;
        my $pid;

        if( $pid = fork )
        {
            return $pid;
        }
        elsif( defined $pid )
        {
            exec "$cmd";
            exit 0;
        }
        else {
            NC800::log(1, "Failed to run command:$cmd");
            return 0;
        }
    }

    # Method to ping a remote address to see if it is alive.
    #
    sub pingIP
    {
        my ($ipToPing) = @_;
        my $handle;
        my $result;
        
        # Create Ping handle, ping address given and return result.
        #
        $handle = Net::Ping->new();
        $result = $handle->ping($ipToPing);
        $handle->close();

        return $result;
    }

    # Method to expand a filename macros.
    #
    sub expandFileName
    {
        my $filename  = shift;
        my $year      = "";
        my ($sec, $min, $hour, $day, $month, $lyear, $dummy, $dummy, $dummy) = localtime();

        # Convert integers into formatted strings.
        #
        $sec   = sprintf("%02d", $sec);
        $min   = sprintf("%02d", $min);
        $hour  = sprintf("%02d", $hour);
        $day   = sprintf("%02d", $day);
        $month = sprintf("%02d", $month + 1);
        $lyear = sprintf("%04d", $lyear + 1900);
        $year  = substr($lyear, -1, 2);

        # Expand macros in filename.
        #
        $filename =~ s/<DD>/$day/;
        $filename =~ s/<DAY>/$day/;
        $filename =~ s/<MM>/$month/;
        $filename =~ s/<MONTH>/$month/;
        $filename =~ s/<YY>/$year/;
        $filename =~ s/<YYYY>/$lyear/;
        $filename =~ s/<HH>/$hour/;
        $filename =~ s/<HOUR>/$hour/;
        $filename =~ s/<MIN>/$min/;
        $filename =~ s/<SS>/$sec/;
        $filename =~ s/<SEC>/$sec/;

        # Return finished filename.
        # 
        return($filename);
    }
    
    # Method to test if an IP address is valid.
    #
    sub testIP
    {
        my ($remote_ip, $remote_port) = @_;
        my $local_ip = "0.0.0.0";
        my $result = 0;

        my $remote = IO::Socket::INET->new(
                Proto => "tcp",
                LocalAddr => "$local_ip",
                PeerAddr  => "$remote_ip",
                PeerPort  => "$remote_port",
                Reuse     => 1
            ) or $result = 1;

        return $result;
    }

    # Method to GET a URL, but ignoring the response as it is not needed.
    #
    sub httpGet
    {
        my ($url) = shift;
        my $idx;
        my $result;
        my $http;

        # Initialise a Lite connection.
        #
        $http = HTTP::Lite->new;

        # Retry a set number of times 
        for($idx = 1; $idx < $NC800_MAX_HTTP_RETRIES; $idx++)
        {
            $result = $http->request($url);
            if($result == 200)
            {
                undef $http;
                return;
            }
        }
        NC800::log(1, "Failed to open url ($url).");
        undef $http;
    }

    # External method to get the current state of a given relay.
	#
	sub GetRelayState
	{
        my $relay          = shift;
		my $state;

		# Map given value to relay known internally.
        #
        $relay = $RELAY_MAP{$relay};
		$state = $CURRENT_RELAY_STATE{$relay};
        NC800::log(1, "$relay:$state");
		return($state);
	}

    # External method to change the state of a relay, using numbers 0..7 or name.
    #
	sub RelaySet
	{
        my $relay          = shift;
		my $state          = shift;
		my $testOnly       = shift;
        my $result         = 0;

		# Map given value to relay known internally.
        #
        $relay = $RELAY_MAP{$relay};
        $state = $RELAY_STATE_MAP{$state};
		if($relay eq "")
		{
			$result = 1;
		}
		elsif($state eq "")
		{
			$result = 2;
		}
		else
		{
            # Only switch ON/OFF if correct value given, else return fail.
            #
		    if($state == 1)
		    {
				if($testOnly == 0)
				{
				    NC800::relayON($relay);
                    NC800::log(1, "Relay ($relay) has been turned on by external request.");
				}
		    }
		    elsif($state == 0)
		    {
				if($testOnly == 0)
				{
				    NC800::relayOFF($relay);
                    NC800::log(1, "Relay ($relay) has been turned off by external request.");
				}
            }
			else {
				$result = 2;
			}
		}
        return $result; 
	}
	
    # Method to turn on a relay. A number 1..8 is given which is sent to the NC-800 in correct format.
    #
    sub relayON
    {
        my $url;
        my $relay = shift;

        # Sanity check.
		if( $reverse_RELAY_MAP{$relay} eq "" ) { return; }

        # Build and send HTTP request to NC-800.
        $url = sprintf("http://%s/%s/6/?1%d&", $NC800_IP, $NC800_PWD, $relay);
        httpGet $url;

        # Update state.
		$CURRENT_RELAY_STATE{$relay} = 1;
    }

    # Method to turn off a relay. A number 1..8 is given which is sent to the NC-800 in correct format.
    #
    sub relayOFF
    {
        my $url;
        my $relay = shift;

        # Sanity check.
		if( $reverse_RELAY_MAP{$relay} eq "" ) { return; }

        # Build and send HTTP request to NC-800.
        $url = sprintf("http://%s/%s/6/?0%d&", $NC800_IP, $NC800_PWD, $relay);
        httpGet $url;

        # Update state.
		$CURRENT_RELAY_STATE{$relay} = 0;
    }

    # Method to turn off the server by pressing the 'OFF' button via a relay.
    #
    sub serverOFF
    {
        # Switch Power Relay ON, which has the effect of bridging the power switch on the Server.
        #
        NC800::relayON($SERVER_POWER_RELAY);

        # Wait for the programmed time as this is necessary for the Server power supply to register an OFF request.
        #
        sleep($NC800_SERVER_HOLDOFF_TIME);

        # Switch Power Relay OFF, which has the effect of removing the bridge on the power switch.
        #
        NC800::relayOFF($SERVER_POWER_RELAY);
    }

    # Method to turn on the server by pressing the 'ON' button via a relay.
    #
    sub serverON
    {
        # Switch Power Relay ON, which has the effect of bridging the power switch on the Server.
        #
        NC800::relayON($SERVER_POWER_RELAY);

        # Wait for the programmed time as this is necessary for the Server power supply to register an ON request.
        #
        sleep($NC800_SERVER_HOLDON_TIME);

        # Switch Power Relay OFF, which has the effect of removing the bridge on the power switch.
        #
        NC800::relayOFF($SERVER_POWER_RELAY);
    }

    # Method to verify if the ADSL modem is working by pinging external addresses.
    # Return 1 if the modem is ok, 0 if not.
    #
    sub checkModem
    {
        # If we reach the limit, return 0 to indicate modem failed.
        #
        if( $MODEM_PING_COUNTER >= $NC800_MODEM_MAXPING )
        {
            return 0;
        }

        # Try address 1.
        #
        if($MODEM_1_PING_TIMER < $CURRENT_TIME)
        {
            if(NC800::pingIP($NC800_MODEM_PING_ADDR1) == 1)
            {
                $MODEM_PING_COUNTER = 0;
            } else
            {
                  $MODEM_PING_COUNTER = $MODEM_PING_COUNTER + 1;
            }

            # Adjust the timer for next occurence.
            #
            $MODEM_1_PING_TIMER = $CURRENT_TIME + $NC800_MODEM_PINGTIME;
        }

        # Then address 2.
        #
        if($MODEM_2_PING_TIMER < $CURRENT_TIME)
        {
            if(NC800::pingIP($NC800_MODEM_PING_ADDR2) == 1)
            {
                $MODEM_PING_COUNTER = 0;
            } else
            {
                $MODEM_PING_COUNTER = $MODEM_PING_COUNTER + 1;
            }

            # Adjust the timer for next occurence.
            #
            $MODEM_2_PING_TIMER = $CURRENT_TIME + $NC800_MODEM_PINGTIME;
        }

        if( $MODEM_PING_COUNTER >= $NC800_MODEM_MAXPING )
        {
            NC800::log(1, "Modem not responding to pings, tried $MODEM_PING_COUNTER times.");
        }
        return 1;
    }

    # Reset the modem by disconnecting the power, setting a timer and waiting for it to
    # expire before re-applying power. Once the power has been re-applied, return a positive
    # value to indicate the routine has finished.
    #
    sub resetModem
    {
        if( $MODEM_RESET_TIMER != -1 && $MODEM_RESET_TIMER < $CURRENT_TIME )
        {
            # Turn the relay back off which has the effect of turning on the modem.
            #
            NC800::relayOFF($MODEM_RELAY);
            $MODEM_RESET_TIMER = -1;

            # Log event.
            #
            NC800::log(1, "Turned Modem Relay OFF - ie. Applied power.");
            return 1;
        }

        # If the timer is running but not expired, just exit.
        #
        if( $MODEM_RESET_TIMER != -1 )
        {
            return 0;
        }

        # Turn on the relay, ie. switch power off to the modem.
        #
        NC800::relayON($MODEM_RELAY);

        # Log event.
        #
        NC800::log(1, "Turned Modem Relay ON - ie. Disconnected power.");

        # Set the timer running, basically we need the modem to be switched off for this amount of time.
        #
        $MODEM_RESET_TIMER = $CURRENT_TIME + $NC800_MODEM_RESETTIME;
        return 0;
    }

    # Method to verify if the SERVER is working by pinging its ethernet addresses.
    # Return 1 if the SERVER is ok, 0 if not.
    #
    sub checkSERVER
    {
        # If we reach the limit, return 0 to indicate modem failed.
        #
        if( $SERVER_PING_COUNTER >= $NC800_SERVER_MAXPING )
        {
            return 0;
        }

        # Try address 1.
        #
        if($SERVER_1_PING_TIMER < $CURRENT_TIME)
        {
            if(NC800::pingIP($NC800_SERVER_PING_ADDR1) == 1)
            {
                $SERVER_PING_COUNTER = 0;
                $SERVER_RESET_COUNTER = 0;
            } else
            {
                $SERVER_PING_COUNTER = $SERVER_PING_COUNTER + 1;
            }

            # Adjust the timer for next occurence.
            #
            $SERVER_1_PING_TIMER = $CURRENT_TIME + $NC800_SERVER_PINGTIME;
        }

        # Then address 2.
        #
        if($SERVER_2_PING_TIMER < $CURRENT_TIME)
        {
            if(NC800::pingIP($NC800_SERVER_PING_ADDR2) == 1)
            {
                $SERVER_PING_COUNTER = 0;
                $SERVER_RESET_COUNTER = 0;
            } else
            {
                $SERVER_PING_COUNTER = $SERVER_PING_COUNTER + 1;
            }

            # Adjust the timer for next occurence.
            #
            $SERVER_2_PING_TIMER = $CURRENT_TIME + $NC800_SERVER_PINGTIME;
        }

        if( $SERVER_PING_COUNTER >= $NC800_SERVER_MAXPING )
        {
            # Log event.
            #
            NC800::log(1, "Server not responding to pings, tried $SERVER_PING_COUNTER times.");
        }
        return 1;
    }

    # Reset the SERVER by closing the relay connected to the reset switch, then setting a timer and waiting for it to
    # expire before opening the relay to allow the SERVER to start. Once the reset has finished, return a positive
    # value to indicate the routine has finished.
    #
    sub resetSERVER
    {
        if( $SERVER_RESET_TIMER != -1 && $SERVER_RESET_TIMER < $CURRENT_TIME )
        {
            # Turn the relay off which has the effect of allowing the SERVER to start.
            #
            NC800::relayOFF($SERVER_RESET_RELAY);
            $SERVER_RESET_TIMER = -1;

            # Log event.
            #
            NC800::log(1, "Turned Server Reset Relay OFF - ie. Released RESET button.");
            return 1;
        }

        # If the timer is running but not expired, just exit.
        #
        if( $SERVER_RESET_TIMER != -1 )
        {
            return 0;
        }

        # Turn on the relay, ie. switch power off to the modem.
        #
        NC800::relayON($SERVER_RESET_RELAY);

        # Set the timer running, basically we need the modem to be switched off for this amount of time.
        #
        $SERVER_RESET_TIMER = $CURRENT_TIME + $NC800_SERVER_RESETTIME;

        # Log event.
        #
        NC800::log(1, "Turned Server Reset Relay ON - ie. Pressed RESET button.");
        return 0;
    }

    # Function to initialise the module.
    #
    sub Init
    {
		my $relay;

        # Setup initial timer values.
        #
        $CURRENT_TIME=time();
        $MODEM_1_PING_TIMER  = $CURRENT_TIME + $NC800_MODEM_PINGTIME;
        $MODEM_2_PING_TIMER  = $CURRENT_TIME + $NC800_MODEM_PINGTIME;
        $SERVER_1_PING_TIMER = $CURRENT_TIME + $NC800_SERVER_PINGTIME;
        $SERVER_2_PING_TIMER = $CURRENT_TIME + $NC800_SERVER_PINGTIME;

        # Verify that we can connect to the NC800, if we cannot, then log and exit.
        #
        if(testIP($NC800_IP, $NC800_PORT) == 1)
        {
            NC800::log(1, "Cannot connect to IP ($NC800_IP), PORT ($NC800_PORT).");
            return 1;
        }

        # Turn off all relays - default for a reset on the NC-800.
        #
		foreach $relay (keys %CURRENT_RELAY_STATE)
		{
			if($NC800::CURRENT_RELAY_STATE{$relay} == 1)
			{
                NC800::relayON($relay);
			} else
			{
                NC800::relayOFF($relay);
			}
        }

        # Start message.
        #
        NC800::log(0, "NC800 online.");
        return 0;
    }

    # Method to tidy up the NC800 prior to exit.
    #
    sub Terminate
    {
        # Turn off all relays - default for a reset on the NC-800.
        #
        my $idx;
        for($idx=1; $idx < 9; $idx++)
        {
            NC800::relayOFF($idx);
        }

        # End message.
        #
        NC800::log(0, "NC800 offline.");
    }

    # Main loop which executes all required NC800 logic.
    #
    sub MainLoop
    {
        $CURRENT_TIME=time();

        # If the Modem has been reset, we wait a period of time before continuing
        # on with further checks.
        #
        if( $CURRENT_TIME < $MODEM_CHECK_WAIT_TIME )
        { 
            ;
        }
        else
        {
            # Has the modem failed? If so, reset it via oneshot power cycle.
            #
            if( NC800::checkModem() == 0 )
            {
                # Request the modem to be reset, when it has, the method will return 1.
                #
                if( NC800::resetModem() == 1 )
                {
                    $MODEM_PING_COUNTER=0;
                    $MODEM_CHECK_WAIT_TIME = $NC800_MODEM_CHECK_WAIT_TIME + $CURRENT_TIME;
                }
            }
        }

        # If the server has been reset or powercycled, we wait a period of time before continuing
        # on with further checks.
        #
        if( $CURRENT_TIME < $SERVER_CHECK_WAIT_TIME )
        { 
            ;
        }
        else
        {
            # Has the SERVER failed? If so, try a reset and if this doesnt work, cycle the power.
            #
            if( NC800::checkSERVER() == 0 )
            {
                # If the Reset Counter has reached the maximum, we need to power cycle the server.
                # This code has been written intentionally as 'Blocking' as it only happens rarely.
                #
                if( $SERVER_RESET_COUNTER >= $NC800_SERVER_MAXRESET )
                {
                    # First turn server off.
                    #
                    NC800::serverOFF();

                    # Wait a period of time to allow the power supply to fully reset.
                    #
                    sleep($NC800_SERVER_POWEROFF_TIME);

                    # Turn on the server and continue.
                    #
                    NC800::serverON();
                    $SERVER_RESET_COUNTER = 0;
                    $SERVER_PING_COUNTER = 0;
                    $SERVER_CHECK_WAIT_TIME = $NC800_SERVER_CHECK_WAIT_TIME + $CURRENT_TIME;

                    # Log event.
                    #
                    NC800::log(1, "Power Cycled the Server.");
                }
                else
                {
                    # Request the SERVER to be reset, when it has, the method will return 1.
                    #
                    if( NC800::resetSERVER() == 1 )
                    {
                        $SERVER_PING_COUNTER=0;
                        $SERVER_RESET_COUNTER = $SERVER_RESET_COUNTER + 1;
                    }
                }
            }
        }
    }
}
1;
