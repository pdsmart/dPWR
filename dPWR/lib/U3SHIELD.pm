#########################################################################################################
##
## Name:            U3SHIELD.pm
## Created:         September 2015
## Author(s):       Philip Smart
## Description:     A perl module which forms part of the dPWR program.
##                  This module provides all the Private and Public API calls which interface the 
##                  HardKernel.org U3 Shield board to the dPWR program.
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
package U3SHIELD;
require 5.8.0;
use strict;
use forks;
use Net::Ping;
use Time::HiRes qw(usleep nanosleep);
use Device::SerialPort;
use Switch;

use vars qw(@ISA @EXPORT $VERSION);

$VERSION = 1.00;
@ISA     = qw(Exporter);

@EXPORT  = qw(Init
              Terminate
              GetPortMode
              GetPortValue
              PortConfig
              PortSet
              ReadPort
              SigThread
              SetLogFile
              SeteviceConfig
              GetDeviceConfig
              SetPortConfig
              GetPortConfig
              MainLoop
              HTML_CreatePage
             );       # Symbols to autoexport (:DEFAULT tag)


#################################################################################
# U3SHIELD Package.
#
# Description: This package contains all the functions which control the U3SHIELD
#              GPIO ports attached to relay's or Thyristor switches.
#
# Members Functions:
#        Init                   - PUBLIC
#
# Members Variables:
#                               - PRIVATE
#                               - PUBLIC
# Comments: 
#
#################################################################################
{
    #################################################################################
    # Constant and Variable declarations.
    #################################################################################

    # Module wide constants
    #
    use constant MODULE                => "U3SHIELD";

    # Maximum and Minimum port numbers controlled by U3Shield.
    #
    use constant MIN_PORT_LIMIT        => 0;
    use constant MAX_PORT_LIMIT        => 128;     # Valid Range is MIN_PORT_LIMIT .. MAX_PORT_LIMIT - 1
    use constant MIN_DEVICE_LIMIT      => 0;
    use constant MAX_DEVICE_LIMIT      => 8;       # Valid Range is MIN_DEVICE_LIMIT .. MAX_DEVICE_LIMIT - 1
	use constant MIN_BASE_ADDR         => 0;
	use constant MAX_BASE_ADDR         => 65536;
    use constant MIN_TIMER_LIMIT       => 0;
    use constant MAX_TIMER_LIMIT       => 7;
    use constant MIN_PING_LIMIT        => 0;
    use constant MAX_PING_LIMIT        => 3;

    # Ping Actions.
    #
    use constant PING_ACTION_NONE      => 0;
    use constant PING_ACTION_OFF       => 1;
    use constant PING_ACTION_ON        => 2;
    use constant PING_ACTION_CYCLEOFF  => 3;
    use constant PING_ACTION_CYCLEON   => 4;

    # Pseudo constants for devices.
    #
    my $sATMEGA328P                    = "ATMEGA328P";
    my $iATMEGA328P                    = 0;
    my $sTCA6416A                      = "TCA6416A";
    my $iTCA6416A                      = 1;
    our %DEVICE_TYPES                  = ( $sATMEGA328P         => $iATMEGA328P,
                                           $sTCA6416A           => $iTCA6416A
                                         );
    our %DEVICE_BAUD_RATES             = ( "115200"             => 115200,
                                           "57600"              => 57600,
                                           "28800"              => 28800,
                                           "14400"              => 14400,
                                           "9600"               => 9600,
                                           "4800"               => 4800,
                                           "2400"               => 2400,
                                           "1200"               => 1200
                                         );
    our %DEVICE_DATABITS               = ("8"                   => 8,
                                          "7"                   => 7,
                                          "6"                   => 6,
                                          "5"                   => 5
                                         );   
    our %DEVICE_PARITY                 = ("none"                => "N",
                                          "odd"                 => "O",
                                          "even"                => "E"
                                         );   
    our %DEVICE_STOPBITS               = ("2"                   => 2,
                                          "1.5"                 => 1.5,
                                          "1"                   => 1
                                         );   

    # Pseudo constants for port activity.
    #
    my $sDISABLED                      = "DISABLED";
    my $iDISABLED                      = 0;
    my $sENABLED                       = "ENABLED";
    my $iENABLED                       = 1;
    my $sOFF                           = "OFF";
    my $iOFF                           = 0;
    my $sON                            = "ON";
    my $iON                            = 1;
    my $sCURRENT                       = "CURRENT";
    my $iCURRENT                       = 2;
    my $sLOW                           = "LOW";
    my $iLOW                           = 0;
    my $sHIGH                          = "HIGH";
    my $iHIGH                          = 1;
    my $sOUTPUT                        = "OUTPUT";
    my $iOUTPUT                        = 0;
    my $sINPUT                         = "INPUT";
    my $iINPUT                         = 1;
    my $sUNLOCKED                      = "UNLOCKED";
    my $iUNLOCKED                      = 0;
    my $sLOCKED                        = "LOCKED";
    my $iLOCKED                        = 1;
    my $sOR                            = "OR";
    my $iOR                            = 0;
    my $sAND                           = "AND";
    my $iAND                           = 1;

    # Pseudo constants for types of ping.
    #
	my $sPING_ICMP                     = "ICMP";
	my $sPING_TCP                      = "TCP";
	my $sPING_UDP                      = "UDP";

    # Device control record, 1 array entry per device.
    #
    my @DEVICE_CTRL                    = ();

    # Port control record, 1 array entry per port, to setup and control it's operation.
    #
    my @PORT_CTRL                      = ();

    # Other variables.
    #
    my $MIN_PORT                       = -1;
    my $MAX_PORT                       = -1;
    my $LOGFILE                        = "/usr/local/DPWR/log/dpwr.log";

    # Map to map an external value to an internal output state.
    #
    our %OUTPUT_STATE_MAP              = ( "0"                  => $iOFF,
                                           "1"                  => $iON,
                                           $sOFF                => $iOFF,
                                           $sON                 => $iON,
                                           "off"                => $iOFF,
                                           "on"                 => $iON 
                                         );

    # Map to map an external mode value to an internal value.
    #
    our %PORT_MODE_MAP                 = ( "0"                  => $iOUTPUT,
                                           "1"                  => $iINPUT,
                                           $sOUTPUT             => $iOUTPUT,
                                           $sINPUT              => $iINPUT
                                         );

    # Value maps for converting numbers to display values.
    #
    our %ON_OFF                        = ( $iOFF                => $sOFF,
                                           $sOFF                => $iOFF,
                                           $iON                 => $sON,
                                           $sON                 => $iON,
                                           $iCURRENT            => $sCURRENT,
                                           $sCURRENT            => $iCURRENT
                                         );
    our %HIGH_LOW                      = ( $iLOW                => $sLOW,
                                           $sLOW                => $iLOW,
                                           $iHIGH               => $sHIGH,
                                           $sHIGH               => $iHIGH
                                         );
    our %INPUT_OUTPUT                  = ( $iOUTPUT             => $sOUTPUT,
                                           $sOUTPUT             => $iOUTPUT,
                                           $iINPUT              => $sINPUT,
                                           $sINPUT              => $iINPUT
                                         );
    our %ENABLED_DISABLED              = ( $iDISABLED           => $sDISABLED,
                                           $sDISABLED           => $iDISABLED,
                                           $iENABLED            => $sENABLED,
                                           $sENABLED            => $iENABLED
                                         );
    our %LOCKED_UNLOCKED               = ( $iUNLOCKED           => $sUNLOCKED,
                                           $sUNLOCKED           => $iUNLOCKED,
                                           $iLOCKED             => $sLOCKED,
                                           $sLOCKED             => $iLOCKED
                                         );
    our %DOW_ABBR                      = ( 0                    => "Mon",
                                           1                    => "Tue",
                                           2                    => "Wed",
                                           3                    => "Thu",
                                           4                    => "Fri",
                                           5                    => "Sat",
                                           6                    => "Sun"
                                         );
    our %LOGIC_OPER                    = ( $sOR                 => $iOR,
                                           $sAND                => $iAND
                                         );
    our %PING_ACTION                   = ( "NONE"               => &PING_ACTION_NONE,
                                           "OFF"                => &PING_ACTION_OFF,
                                           "ON"                 => &PING_ACTION_ON,
                                           "CYCLEOFF"           => &PING_ACTION_CYCLEOFF,
                                           "CYCLEON"            => &PING_ACTION_CYCLEON
                                         );
    our %CONV_POST_VALUES              = ( $sOFF                => $iOFF,
                                           $sON                 => $iON,
                                           $sCURRENT            => $iCURRENT,
                                           $sLOW                => $iLOW,
                                           $sHIGH               => $iHIGH,
                                           $sOUTPUT             => $iOUTPUT,
                                           $sINPUT              => $iINPUT,
                                           $sDISABLED           => $iDISABLED,
                                           $sENABLED            => $iENABLED,
                                           $sUNLOCKED           => $iUNLOCKED,
                                           $sLOCKED             => $iLOCKED,
                                           $sAND                => $iAND,
                                           $sOR                 => $iOR
                                         );


    # Map to map an external name to an internal ping action command.
    #
    our %PING_ACTION_MAP               = ( "none"              => &PING_ACTION_NONE,
                                           "NONE"              => &PING_ACTION_NONE,
                                           "None"              => &PING_ACTION_NONE,
                                           "off"               => &PING_ACTION_OFF,
                                           "OFF"               => &PING_ACTION_OFF,
                                           "Off"               => &PING_ACTION_OFF,
                                           "on"                => &PING_ACTION_ON,
                                           "ON"                => &PING_ACTION_ON,
                                           "On"                => &PING_ACTION_ON,
                                           "cycleoff"          => &PING_ACTION_CYCLEOFF,
                                           "CYCLEOFF"          => &PING_ACTION_CYCLEOFF,
                                           "CycleOff"          => &PING_ACTION_CYCLEOFF,
                                           "cycleon"           => &PING_ACTION_CYCLEON,
                                           "CYCLEON"           => &PING_ACTION_CYCLEON,
                                           "CycleOn"           => &PING_ACTION_CYCLEON
                                         );

    # Map to map an external name to an internal ping type.
    #
	our %PING_TYPES                    = ( $sPING_ICMP         => "icmp",
                                           $sPING_TCP          => "tcp",
										   $sPING_UDP          => "udp"
                                         );

    # HTML Handler variables.
    #
    my $HTMLBUF = "";

    #################################################################################
    # End of Constant and Variable declarations.
    #################################################################################

    #################################################################################
    # Function and Method declarations.
    #################################################################################

    # Function to validate a string time value.
    #
    sub chkTime
    {
        my ($string_time) = @_;
        my @parts     = split(/ /, $string_time);
        my @timeparts = split(/:/, $parts[0]);
        my @dateparts = split(/,/, $parts[1]);
        my $checkedResult = "";
    
        if(@timeparts == 3)
        {
            if(int($timeparts[0]) < 0 || int($timeparts[0]) > 23) { $timeparts[0] = 0; }
            if(int($timeparts[1]) < 0 || int($timeparts[1]) > 59) { $timeparts[1] = 0; }
            if(int($timeparts[2]) < 0 || int($timeparts[2]) > 59) { $timeparts[2] = 0; }
            $checkedResult =  sprintf("%02d:%02d:%02d", int($timeparts[0]), int($timeparts[1]), int($timeparts[2]));
        } else
        {
            Utilities::log(1, MODULE, "chkTime", "Illegal Time string($string_time)");
            $checkedResult = "00:00:00";
        }
    
        $checkedResult = $checkedResult . " ";
        for(my $idx=0; $idx <= $#dateparts; $idx++)
        {
            if($dateparts[$idx] >= 0 && $dateparts[$idx] < 7)
            {
                $checkedResult = $checkedResult . "$dateparts[$idx],";
            } else
            {
                Utilities::log(1, MODULE, "chkTime", "Illegal Day of Week component ($dateparts[$idx]) in time string($string_time)");
            }
        }
        chop($checkedResult);
    
        # Return the verified string.
        #
        return($checkedResult);
    }

    # Function to validate an IP address.
    #
    sub chkIp
    {
        my ($string_ip) = @_;
        return $string_ip;
    }

    # Method to read a current GPIO value.
    #
    sub gpioRead
    {
        my($controladdr) = @_;
        my $value;

        if( !open(GPIO_HDL, "<", $controladdr) )
        {
            Utilities::log(6, MODULE, "gpioRead", "Failed to open GPIO:$controladdr");
            return 0;
        }
        read GPIO_HDL, $value, 1;
        close(GPIO_HDL);
        return $value;
    }

    # Method to write to the GPIO.
    #
    sub gpioWrite
    {
        my($value, $controladdr) = @_;

        if( ! open(GPIO_HDL, ">", $controladdr) )
        {
            Utilities::log(6, MODULE, "gpioWrite", "Failed to open GPIO:$controladdr");
            return 0;
        }
        print GPIO_HDL "$value";
        close(GPIO_HDL);
    }

    # Method to receive a response from the ATMega328p processor.
    # Parameters: uart_handle  - open connection to a serial UART device.
    #             retrycnt     - number of times to retry receiving a byte.
    #             rcvbytedelay - period in 1/1000 of a ms to delay waiting for a byte.
    # NB. Total time waiting = (retrycnt * (delay*1000)) in ms.
    #
    sub atmega328pReceive
    {
        my ($uart_handle, $retrycnt, $rcvbytedelay) = @_;
        my $rcvBuf = "";
        my $inChar = '';

        # Read the ATMega328p values.
        #
        do {
            $inChar = $uart_handle->lookfor();
            if($inChar eq "")
            {
                usleep($rcvbytedelay); # We should receive 1 character every 0.1ms but we wait to give
                                       # time for the ATMega to process and reply.
                $retrycnt--;
            } else
            { 
                last if $inChar eq "\n";
                $rcvBuf = $rcvBuf . $inChar;
            }
        } while($retrycnt > 0);
        Utilities::log(6, MODULE, "atmega328pReceive", "Received:$rcvBuf");

        # Return data received.
        #
        return $rcvBuf;
    }

    # Method to write complete Output Set to the ATMEGA 328p.
    # Parameters: device Id  - Id of an ATMEGA328P device.
    #
    sub atmega328pWriteAll
    {
        my ($dvc) = @_;
        my $hardware_state;

        # Create a Write command containing all ports expected values.
        #
        my $Atmega328p_Write  = "W";
        for(my $idx=$DEVICE_CTRL[$dvc]->{PORT_MIN}; $idx <= $DEVICE_CTRL[$dvc]->{PORT_MAX}; $idx++)
        {
            # Verify that the actual port is an output before trying to set it!
            #
            if(isOutputPort($idx))
            {
                # Set value according to that contained in the internal map.
                #
                my $value = $PORT_CTRL[$idx]->{OUTPUT_STATE};
                if($value == $iOFF)
                {
                    # Lookup the value needed to turn port off.
                    #
                    eval "\$hardware_state = \$HIGH_LOW{\$PORT_CTRL[$idx]->{OFF_STATE_VALUE}}";
                } else
                {
                    # Lookup the value needed to turn port on.
                    #
                    eval "\$hardware_state = \$HIGH_LOW{\$PORT_CTRL[$idx]->{ON_STATE_VALUE}}";
                }

                # Build up the initial output value string.
                #
                $Atmega328p_Write = $Atmega328p_Write . "$hardware_state";
            } else
            {
                # The port is an input so just set to 0 as it will have no effect.
                #
                $Atmega328p_Write  = $Atmega328p_Write  . "0";
            }
        }

        # Set the output values.
        #
        $DEVICE_CTRL[$dvc]->{UART_HANDLE}->write("$Atmega328p_Write\n");
        usleep(5000); # Give the ATMega328p a chance, wait for 5ms.
        Utilities::log(6, MODULE, "atmega328pWriteAll", "Sent:$Atmega328p_Write");
    }

    # Method to write to a single port.
    #
    sub atmega328pWrite
    {
        my($port, $value) = @_;
        #my $hardware_state;

        # Lookup associated device for this port.
        #
        my $dvc = $PORT_CTRL[$port]->{DEVICE_ID};

        # Bring global port value into device range.
        #
        $port -= $DEVICE_CTRL[$dvc]->{PORT_MIN};

        # Lookup the required actual value neede by the I/O port against what we
        # want to set it to (0=off, 1=on).
        #
        #if($value == 0)
        #{
        #    # Lookup the value needed to turn port off.
        #    #
        #    $dynstr  = "\$hardware_state = \$HIGH_LOW{\$PORT_CTRL[$port]->{OFF_STATE_VALUE}}";
        #} else
        #{
        #    # Lookup the value needed to turn port on.
        #    #
        #    $dynstr  = "\$hardware_state = \$HIGH_LOW{\$PORT_CTRL[$port]->{ON_STATE_VALUE}}";
        #}
        #eval $dynstr;

        # Build up the command string.
        #
        my $Atmega328p_Write = sprintf("w%02d%01d\n", $port, $value);

        # Transmit the command string.
        #
        $DEVICE_CTRL[$dvc]->{UART_HANDLE}->write("$Atmega328p_Write\n");
        usleep(5000); # Give the ATMega328p a chance, wait for 5ms.
        Utilities::log(6, MODULE, "atmega328pWrite", "Sent:$Atmega328p_Write");
    }

    # Method to ping a remote address to see if it is alive.
    #
    sub pingIP
    {
        my ($ipToPing, $pingType, $timeout) = @_;
        my $handle;
        my $result;
        
        # Log debug messages.
        #
        Utilities::log(6, MODULE, "pingIP", "Pinging:$ipToPing with timeout:$timeout");

        # Create Ping handle, ping address given and return result.
        #
        $handle = Net::Ping->new($PING_TYPES{$pingType}, $timeout);
        $result = $handle->ping($ipToPing);
        $handle->close();

        # Log debug messages.
        #
        Utilities::log(6, MODULE, "pingIP", "Ping to IP:$ipToPing, Type:$pingType, result:$result");

        return $result;
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

        Utilities::log(6, MODULE, "testIP", "test $remote_ip, $remote_port = $result");
        return $result;
    }

    # Method to see if any output has been activated/inactivated by time parameters.
    #
    sub processTimedPorts
    {
        my $active;

        # Go through all the ports, if an output is enabled for timer control, 
        # check the times to see if the port should be updated.
        #
        for(my $idx=$MIN_PORT; $idx < $MAX_PORT; $idx++)
        {
            # Skip disabled ports.
            #
			next if(! defined $PORT_CTRL[$idx]);
            next if($PORT_CTRL[$idx]->{ENABLED} ne $sENABLED);

            # Verify that the actual port is an output before processing and that there isnt a PING
            # operation in effect.
            #
            if(isOutputPort($idx) && $PORT_CTRL[$idx]->{SCHEDULE}->{trigTime} == 0)
            {
                for(my $pdx=MIN_TIMER_LIMIT; $pdx <= MAX_TIMER_LIMIT; $pdx++)
                {
                    if($PORT_CTRL[$idx]->{ON_TIME_ENABLE}[$pdx] eq $sENABLED && $PORT_CTRL[$idx]->{OFF_TIME_ENABLE}[$pdx] eq $sDISABLED)
                    {
                        if(Utilities::isInActiveTimeRange("$PORT_CTRL[$idx]->{ON_TIME}[$pdx]", "") && $PORT_CTRL[$idx]->{TIME_TOGGLE}[$pdx] != 1)
                        {
                            $PORT_CTRL[$idx]->{TIME_TOGGLE}[$pdx] = 1;
                            PortSet($idx, $iON, 0);
                            Utilities::log(1, MODULE, "processTimedPorts", "Timer($pdx - on timer): Set Port($idx) to $ON_OFF{$iON}");
                        }
                    }
                    elsif($PORT_CTRL[$idx]->{ON_TIME_ENABLE}[$pdx] eq $sDISABLED && $PORT_CTRL[$idx]->{OFF_TIME_ENABLE}[$pdx] eq $sENABLED)
                    {
                        if(Utilities::isInActiveTimeRange("", "$PORT_CTRL[$idx]->{OFF_TIME}[$pdx]") && $PORT_CTRL[$idx]->{TIME_TOGGLE}[$pdx] != 0)
                        {
                            $PORT_CTRL[$idx]->{TIME_TOGGLE}[$pdx] = 0;
                            PortSet($idx, $iOFF, 0);
                            Utilities::log(1, MODULE, "processTimedPorts", "Timer($pdx - off timer): Set Port($idx) to $ON_OFF{$iOFF}");
                        }
                    }
                    elsif($PORT_CTRL[$idx]->{ON_TIME_ENABLE}[$pdx] eq $sENABLED && $PORT_CTRL[$idx]->{OFF_TIME_ENABLE}[$pdx] eq $sENABLED)
                    {
                        # Get state, 1 = in 'ON' time, 0 = 'OFF' time.
                        #
                        my $active = Utilities::isInActiveTimeRange("$PORT_CTRL[$idx]->{ON_TIME}[$pdx]", "$PORT_CTRL[$idx]->{OFF_TIME}[$pdx]");
                        if($active == 1 && $PORT_CTRL[$idx]->{TIME_TOGGLE}[$pdx] != 1)
                        {
                            $PORT_CTRL[$idx]->{TIME_TOGGLE}[$pdx] = 1;
                            PortSet($idx, $iON, 0);
                            Utilities::log(1, MODULE, "processTimedPorts", "Timer($pdx - in time range): Set Port($idx) to $ON_OFF{$iON}");
                        }
                        elsif($active == 0 && $PORT_CTRL[$idx]->{TIME_TOGGLE}[$pdx] == 1)
                        {
                            $PORT_CTRL[$idx]->{TIME_TOGGLE}[$pdx] = 0;
                            PortSet($idx, $iOFF, 0);
                            Utilities::log(1, MODULE, "processTimedPorts", "Timer($pdx - in time range): Set Port($idx) to $ON_OFF{$iOFF}");
                        }
                    }
                }
            }
        }
    }

    # Function to execute commands should a ping check fail or succeed.
    #
    sub executePingAction
    {
        my ($port, $required_actionCmd, $action_PauseTime) = @_;
        my $actionCmd = $PING_ACTION_MAP{$required_actionCmd};
        my $result = 0;

        # Check the value given, error if it is outside command range.
        #
        if($actionCmd <= 0 && $actionCmd > 4)
        {
            Utilities::log(1, MODULE, "executePingAction", "Illegal action command($required_actionCmd) given to executePingAction");
            $result = 2;
        } else
        {
            # Verify that the actual port is an output before processing.
            #
            if(isOutputPort($port))
            {
                switch($actionCmd)
                {
                    # Nothing to do!
                    case PING_ACTION_NONE {
                        Utilities::log(1, MODULE, "executePingAction", "No action");
                    };
    
                    # Turn port off.
                    case PING_ACTION_OFF {
                        PortSet($port, $iOFF, 0);
                    };
    
                    # Turn port on.
                    case PING_ACTION_ON {
                        PortSet($port, $iON, 0);
                    };
    
                    # Turn port off, wait a period of time, then turn on!
                    case PING_ACTION_CYCLEOFF {
                        PortSet($port, $iOFF, 0);
                        portSchedule($port, $action_PauseTime, $iON);
                    };

                    # Turn port on, wait a period of time, then turn off!
                    case PING_ACTION_CYCLEON {
                        PortSet($port, $iON, 0);
                        portSchedule($port, $action_PauseTime, $iOFF);
                    };
                }
            }
        }
    }

    # Method to test if an external IP is functioning, then execute an action based
    # on result.
    #
    sub processCheckIP
    {
        # Current time to determine if an intra-ping time has elapsed before rechecking.
        #
        my $current_time = time();
 
        # Loop through all the ports checking those that have IP testing enabled.
        #
        for(my $idx=$MIN_PORT; $idx < $MAX_PORT; $idx++)
        {
            # Skip inactive ports.
            #
			next if(! defined $PORT_CTRL[$idx]);
            next if($PORT_CTRL[$idx]->{ENABLED} ne $sENABLED);

            # Verify that the actual port is an output, it is enabled for PING's and it isnt undergoing a previous
            # command.
            #
            if(isOutputPort($idx) && 
               # Check if a scheduled operation is in progress, we dont want to ping check if operation in progress!
               $PORT_CTRL[$idx]->{SCHEDULE}->{trigTime} == 0)
            {
                # Counter to determine how many ping channels are enabled.
                #
                my $enabled_ctr = 0;
                for(my $pdx=MIN_PING_LIMIT; $pdx <= MAX_PING_LIMIT; $pdx++)
                {
                    # If the intra ping time has expired, re-ping and update the counters.
                    #
                    if($PORT_CTRL[$idx]->{PING_ENABLE}[$pdx] eq $sENABLED && $PORT_CTRL[$idx]->{PING_COUNT}->{nextTime}[$pdx] <= $current_time)
                    {
                        # If thread id is -1 then a previous child has completed, extract result and restart thread.
                        #
                        if($PORT_CTRL[$idx]->{PING_COUNT}->{thrId}[$pdx] == -1)
                        {
                            # Get result and reset pointer.
                            #
#Utilities::log(0, MODULE, "processCheckIP", "$idx;$pdx;$PORT_CTRL[$idx]->{PING_COUNT}->{thrResult}[$pdx]");
                            if($PORT_CTRL[$idx]->{PING_COUNT}{thrResult}[$pdx] == 1)
                            {
                                $PORT_CTRL[$idx]->{PING_COUNT}->{successCount}[$pdx] += 1;
                                $PORT_CTRL[$idx]->{PING_COUNT}->{failCount}[$pdx] = 0;
                            } else
                            {
                                $PORT_CTRL[$idx]->{PING_COUNT}->{successCount}[$pdx] = 0;
                                $PORT_CTRL[$idx]->{PING_COUNT}->{failCount}[$pdx] += 1;
                            }
                            $PORT_CTRL[$idx]->{PING_COUNT}->{nextTime}[$pdx] = time() + $PORT_CTRL[$idx]->{PING_TO_PING_TIME}[$pdx];

                            # Start new thread to do the ping operation which can take a long time.
                            #
                            my $thread=threads->new( { 'exit' => 'thread_only' }, 
                                         sub { 
                                                 return pingIP("$PORT_CTRL[$idx]->{PING_ADDR}[$pdx]",
															   $PORT_CTRL[$idx]->{PING_TYPE}[$pdx],
                                                               $PORT_CTRL[$idx]->{PING_ADDR_WAIT_TIME}[$pdx])
                                             } );
                            $PORT_CTRL[$idx]->{PING_COUNT}->{thrId}[$pdx]=$thread->tid;
                            Utilities::log(6, MODULE, "processCheckIP", "Created thread with id:$PORT_CTRL[$idx]->{PING_COUNT}->{thrId}[$pdx]");
                        }
                    }
                    if($PORT_CTRL[$idx]->{PING_ENABLE}[$pdx] eq $sENABLED)
                    {
                        $enabled_ctr++;
                    }
                }

                # See if any one has reached max count, if so execute
                # required command.
                #
                my ($countMatchSuccess, $countMatchFail, $resetCount) = (0, 0, 0);
                for(my $pdx=MIN_PING_LIMIT; $pdx <= MAX_PING_LIMIT; $pdx++)
                {
                    next if($PORT_CTRL[$idx]->{PING_ENABLE}[$pdx] eq $sDISABLED);

                    # If the counter has exceeded the configured count, then flag the condition.
                    #
                    if($PORT_CTRL[$idx]->{PING_COUNT}->{successCount}[$pdx] >= $PORT_CTRL[$idx]->{PING_SUCCESS_COUNT}[$pdx])
                    {
                        $countMatchSuccess++;
                    }

                    if($PORT_CTRL[$idx]->{PING_COUNT}->{failCount}[$pdx] >= $PORT_CTRL[$idx]->{PING_FAIL_COUNT}[$pdx])
                    {
                        $countMatchFail++;
                    }
                }

                if($PORT_CTRL[$idx]->{PING_LOGIC_FOR_SUCCESS} eq $sOR && $countMatchSuccess > 0)
                {
                    Utilities::log(1, MODULE, "processCheckIP", "Ping Check match" . ($enabled_ctr > 1 ? ", OR operator," : " for successCount Port ($idx)."));
                    executePingAction($idx, $PORT_CTRL[$idx]->{PING_ACTION_ON_SUCCESS}, $PORT_CTRL[$idx]->{PING_ACTION_SUCCESS_TIME});
                    $resetCount = 1;
                }
                elsif($PORT_CTRL[$idx]->{PING_LOGIC_FOR_FAIL} eq $sOR && $countMatchFail > 0)
                {
                    Utilities::log(1, MODULE, "processCheckIP", "Ping Check match" . ($enabled_ctr > 1 ? ", OR operator," : " for failCount Port ($idx)."));
                    executePingAction($idx, $PORT_CTRL[$idx]->{PING_ACTION_ON_FAIL}, $PORT_CTRL[$idx]->{PING_ACTION_FAIL_TIME});
                    $resetCount = 1;
                }

                # If configured for AND of both checks, see if anyone has reached max count, if so execute
                # required command.
                #
                elsif($PORT_CTRL[$idx]->{PING_LOGIC_FOR_SUCCESS} eq $sAND && $countMatchFail > 0 && $countMatchSuccess == $enabled_ctr)
                {
                    Utilities::log(1, MODULE, "processCheckIP", "Ping Check match" . ($enabled_ctr > 1 ? ", AND operator," : " for successCount Port($idx)."));
                    executePingAction($idx, $PORT_CTRL[$idx]->{PING_ACTION_ON_SUCCESS}, $PORT_CTRL[$idx]->{PING_ACTION_SUCCESS_TIME});
                    $resetCount = 1;
                }
                elsif($PORT_CTRL[$idx]->{PING_LOGIC_FOR_FAIL} eq $sAND    && $countMatchFail > 0 && $countMatchFail == $enabled_ctr)
                {
                    Utilities::log(1, MODULE, "processCheckIP", "Ping Check match" . ($enabled_ctr > 1 ? ", AND operator,": " for failCount Port($idx)."));
                    executePingAction($idx, $PORT_CTRL[$idx]->{PING_ACTION_ON_FAIL}, $PORT_CTRL[$idx]->{PING_ACTION_FAIL_TIME});
                    $resetCount = 1;
                }

                # Reset counters if a trigger occurs.
                #
                if($resetCount == 1)
                {
                    for(my $pdx=MIN_PING_LIMIT; $pdx <= MAX_PING_LIMIT; $pdx++)
                    {
                        $PORT_CTRL[$idx]->{PING_COUNT}->{successCount}[$pdx] = 0;
                        $PORT_CTRL[$idx]->{PING_COUNT}->{failCount}[$pdx] = 0;
                    }
                }
            }
        }
    }

    # Method to check if a given port is enabled.
    #
    sub isEnabledPort
    {
        # Get parameter and verify.
        my $port = shift;
        if($port < $MIN_PORT || $port > $MAX_PORT || !defined $PORT_CTRL[$port])
        {
            Utilities::log(1, MODULE, "isEnabledPort", "Illegal port value ($port)");
            return(-1);
        }

        return(getDeviceNo($port) == -1 ? $sDISABLED : $PORT_CTRL[$port]->{ENABLED} eq $sENABLED);
    }

    # Method to check if a given port is an output port.
    #
    sub isOutputPort
    {
        # Get parameter and verify.
        my $port = shift;
        if($port < $MIN_PORT || $port > $MAX_PORT || !defined $PORT_CTRL[$port])
        {
            Utilities::log(1, MODULE, "isOutputPort", "Illegal port value ($port)");
            return(-1);
        }
        return($PORT_CTRL[$port]->{MODE} eq $sOUTPUT);
    }

    # Method to check if a given port is an input port.
    #
    sub isInputPort
    {
        # Get parameter and verify.
        my $port = shift;
        if($port < $MIN_PORT || $port > $MAX_PORT || !defined $PORT_CTRL[$port])
        {
            Utilities::log(1, MODULE, "isInputPort", "Illegal port value ($port)");
            return(-1);
        }

        return($PORT_CTRL[$port]->{MODE} eq $sINPUT);
    }

    # Method to get the device associated with a given Port.
    # Return -1 = Port is not in a device, >= 0 = Device number.
    #
	sub getDeviceNo
	{
        # Get parameter and locate device.
        my $port = shift;

        # For each possible device, if it exists, check the min/max port range.
        #
        for(my $dvc=MIN_DEVICE_LIMIT; $dvc < MAX_DEVICE_LIMIT; $dvc++)
        {
            if(defined $DEVICE_CTRL[$dvc]->{ENABLED})
			{
				if($port >= $DEVICE_CTRL[$dvc]->{PORT_MIN} && $port <= $DEVICE_CTRL[$dvc]->{PORT_MAX})
			    {
			        return($dvc);
				}
			}
		}
		return(-1);
	}

    # External method to get the current configuration of a port.
    #
    sub GetPortMode
    {
        # Get parameter and verify.
        my $port = shift;
        if($port < $MIN_PORT || $port > $MAX_PORT || !defined $PORT_CTRL[$port])
        {
            Utilities::log(1, MODULE, "GetPortMode", "Illegal port value ($port)");
            return(-1);
        }

        return($PORT_CTRL[$port]->{MODE});
    }

    # External method to get the current state of a given port.
    #
    sub GetPortValue
    {
        # Get parameter and verify.
        my $port = shift;
        if($port < $MIN_PORT || $port > $MAX_PORT || !defined $PORT_CTRL[$port])
        {
            Utilities::log(1, MODULE, "GetPortValue", "Illegal port value ($port)");
            return(-1);
        }
        my $value;

        # Return value according to mode the port is configured.
        #
        if($PORT_CTRL[$port]->{MODE} eq $sOUTPUT)
        {
            $value = $PORT_CTRL[$port]->{OUTPUT_STATE};
        }
        else
        {
            $value = $PORT_CTRL[$port]->{INPUT_STATE};
        }
        return($value);
    }

    # Method to read in all port values into internal representation.
    #
    sub readAllPorts
    {
        # Go through all devices, those which are active, read the input ports.
        #
        for(my $dvc=MIN_DEVICE_LIMIT; $dvc < MAX_DEVICE_LIMIT; $dvc++)
        {
            # Loop if device not configured.
            #
            next if(not defined $DEVICE_CTRL[$dvc]->{ENABLED});
            next if($DEVICE_CTRL[$dvc]->{ENABLED} ne $sENABLED);

            # If device is an ATMega 328p, send command to get values.
            #
            if($DEVICE_CTRL[$dvc]->{TYPE} eq $sATMEGA328P)
            {
                # Send command to ATMega328p to read all ports.
                #
                $DEVICE_CTRL[$dvc]->{UART_HANDLE}->write("R\n");

                # Read the ATMega328p values.
                #
                my $rcvBuf = atmega328pReceive($DEVICE_CTRL[$dvc]->{UART_HANDLE}, 50, 250);
				my $len    = length($rcvBuf);
                Utilities::log(6, MODULE, "readAllPorts", "Received:$rcvBuf");
                if($len > 0 && $len >= ($DEVICE_CTRL[$dvc]->{PORT_MAX} - $DEVICE_CTRL[$dvc]->{PORT_MIN}))
                {
                    for(my $idx=$DEVICE_CTRL[$dvc]->{PORT_MIN}; $idx <= $DEVICE_CTRL[$dvc]->{PORT_MAX}; $idx++)
                    {
                        # Set value in map from received string.
                        #
                        $PORT_CTRL[$idx]->{INPUT_STATE} = substr($rcvBuf, ($idx + 1) - $DEVICE_CTRL[$dvc]->{PORT_MIN}, 1);
                    }
                } else
                {
                    Utilities::log(6, MODULE, "readAllPorts", "Failed to receive complete input value string from ATMega328P:$rcvBuf");
                }
            }

            # If device is a TCA6416A IO Expander, read values directly.
            #
            if($DEVICE_CTRL[$dvc]->{TYPE} eq $sTCA6416A)
            {
                # Read GPIO values into map.
                #
                for(my $idx=$DEVICE_CTRL[$dvc]->{PORT_MIN}; $idx <= $DEVICE_CTRL[$dvc]->{PORT_MAX}; $idx++)
                {
                    # Read from the GPIO register to switch on port. 
                    # 
                    my $gpioport = $DEVICE_CTRL[$dvc]->{BASE_ADDR} + $idx;
                    $PORT_CTRL[$idx]->{INPUT_STATE} = U3SHIELD::gpioRead("/sys/class/gpio/gpio$gpioport/value");
                }
            }
        }
    }

    # Method to read the value of a single port.
    #
    sub ReadPort
    {
        # Get parameters.
        my $port = shift;

        # Extract value and return.
        #
        return($PORT_CTRL[$port]->{INPUT_STATE});
    }

    # External method to change the configuration of a port.
    #
    sub PortConfig
    {
        # Get parameters.
        my $port           = shift; # Port 0-35
        my $required_mode  = shift; # Output (0) or Input (1).
        my $testOnly       = shift; # TestOnly (0=false, 1=true)
        my $result         = 0;
        my $gpioport;

        # Get device for requested port.
        #
        my $dvc = $PORT_CTRL[$port]->{DEVICE_ID};

        # If port is disabled, exit.
        #
        if(not defined $DEVICE_CTRL[$dvc]->{ENABLED} || $DEVICE_CTRL[$dvc]->{ENABLED} eq $sDISABLED)
        {
            Utilities::log(1, MODULE, "PortConfig", "Device:$dvc is disabled, port:$port belongs to device so cannot configure.");
            return(-1);
        }

        # Get current mode for requested port.
        #
        my $mode = $PORT_MODE_MAP{uc($required_mode)};

        # Check the value given, error if it is not 0 (Output) or 1 (Input).
        #
        if($mode != $iOUTPUT && $mode != $iINPUT)
        {
            Utilities::log(1, MODULE, "PortConfig", "Illegal value given to PortConfig for mode:$mode");
            return(-2);
        }
        elsif($port < $MIN_PORT || $port >= $MAX_PORT || !defined $PORT_CTRL[$port])
        {
            Utilities::log(1, MODULE, "PortConfig", "Illegal value given to PortConfig for port:$port");
            return(-3);
        }
        elsif($PORT_CTRL[$port]->{IS_LOCKED} eq $sLOCKED)
        {
            Utilities::log(1, MODULE, "PortConfig", "Port($port) is factory locked, no changes possible.");
            return(-4);
        }
        elsif($PORT_CTRL[$port]->{ENABLED} eq $sDISABLED)
        {
            Utilities::log(1, MODULE, "PortConfig", "Port($port) is disabled in configuration,  cannot configure it.");
            return(-5);
        }

        # Configure the port as an output (0) or and input (1).
        #
        $PORT_CTRL[$port]->{MODE} = $INPUT_OUTPUT{$mode};

        # If device is a TCA6416A IO Expander, set it up.
        #
        if($DEVICE_CTRL[$dvc]->{TYPE} eq $sTCA6416A)
        {
            # Address of port we are working on.
            #
            $gpioport = $DEVICE_CTRL[$dvc]->{BASE_ADDR} + ($port - $DEVICE_CTRL[$dvc]->{PORT_MIN});

            # Configure hardware according to new mode.
            #
            if($mode == 0)
            {
                # Write to the GPIO register to switch on outputs. 
                # 
                U3SHIELD::gpioWrite("out","/sys/class/gpio/gpio$gpioport/direction");
            } else
            {
                # Write to the GPIO register to switch on input. 
                # 
                U3SHIELD::gpioWrite("in","/sys/class/gpio/gpio$gpioport/direction");
            }
        }

        # If device is an ATMega 328p, open serial device which connects to it.
        #
        elsif($DEVICE_CTRL[$dvc]->{TYPE} eq $sATMEGA328P)
        {
            # Initialise the ATMega328p ports.
            #
            my $Atmega328p_Config = "C";
            for(my $idx=$DEVICE_CTRL[$dvc]->{PORT_MIN}; $idx <= $DEVICE_CTRL[$dvc]->{PORT_MAX}; $idx++)
            {
                # Verify that the actual port is an output before trying to set it!
                #
                if(isOutputPort($idx))
                {
                    # Configured to be an output (=0)
                    #
                    $Atmega328p_Config = $Atmega328p_Config . "0";
                } else
                {
                    # Configured to be an input (=1)
                    #
                    $Atmega328p_Config = $Atmega328p_Config . "1";
                }
            }

            # Set the configuration.
            #
            $DEVICE_CTRL[$dvc]->{UART_HANDLE}->write("$Atmega328p_Config\n");
            my $rcvBuf = atmega328pReceive($DEVICE_CTRL[$dvc]->{UART_HANDLE}, 100, 250);
            if(substr($rcvBuf, 0, 2) ne "OK")
            {
                Utilities::log(0, MODULE, "PortConfig", "Did not receive ok:$rcvBuf\n");
            }
        }

        # Log change.
        #
        my $modestr = $INPUT_OUTPUT{$mode};
        Utilities::log(0, MODULE, "PortConfig", "Port ($port) has had its mode changed to an $modestr");
    }

    # External method to change the state of a port, using numbers 0..36.
    #
    sub PortSet
    {
        # Get parameters.
        my $port           = shift; # Port 0->defined by devices
        my $required_state = shift; # Set To Value (off, on, 0 or 1)
        my $testOnly       = shift; # TestOnly (0=false, 1=true)
        my $result         = 0;

        # Get current state for requested port.
        #
        my $current_state = $PORT_CTRL[$port]->{OUTPUT_STATE};
        my $state         = $OUTPUT_STATE_MAP{$required_state};

        # Check the value given, error if it is not 0 (OFF) or 1 (ON).
        #
        if($state != 0 && $state != 1)
        {
            Utilities::log(1, MODULE, "PortSet", "Illegal state value given to PortSet for state:$state");
            $result = 2;
        }

        elsif($port < $MIN_PORT || $port > $MAX_PORT || !defined $PORT_CTRL[$port])
        {
            Utilities::log(1, MODULE, "PortSet", "Illegal port value given to PortSet for port:$port");
            $result = 3;
        }

        # Only change Output state if requested state different to current state.
        #
        elsif($state != $current_state)
        {
            if($state == 1)
            {
                if($testOnly == 1)
                {
                    Utilities::log(1, MODULE, "PortSet", "TEST:Output ($port) has been turned on by external request.");
                } else
                {
                    U3SHIELD::portON($port);
                    Utilities::log(1, MODULE, "PortSet", "Output ($port) has been turned on by external request.");
                }
            } else
            {
                if($testOnly == 1)
                {
                    Utilities::log(1, MODULE, "PortSet", "TEST:Output ($port) has been turned off by external request.");
                } else
                {
                    U3SHIELD::portOFF($port);
                    Utilities::log(1, MODULE, "PortSet", "Output ($port) has been turned off by external request.");
                }
            }
        }
        return $result; 
    }

    # Method to turn on an output.
    #
    sub portON
    {
        my $port = shift;
        my $hardware_state;

        # Get device id.
        #
        my $dvc = $PORT_CTRL[$port]->{DEVICE_ID};

        # If port is disabled, exit.
        #
        if(not defined $DEVICE_CTRL[$dvc]->{ENABLED} || $DEVICE_CTRL[$dvc]->{ENABLED} eq $sDISABLED)
        {
            Utilities::log(1, MODULE, "portOn", "Device:$dvc is disabled, port:$port belongs to device so cannot set.");
            return(-1);
        }

        # Get current state for requested port.
        #
        my $current_state = $PORT_CTRL[$port]->{OUTPUT_STATE};

        # Check the values given.
        #
        if($port < $MIN_PORT || $port > $MAX_PORT || !defined $PORT_CTRL[$port])
        {
            Utilities::log(1, MODULE, "portON", "Illegal value given to portON for port:$port");
        } 
        # Verify that the actual port is an output before trying to set it!
        #
        elsif(!isOutputPort($port))
        {
            Utilities::log(1, MODULE, "portON", "Port ($port) is not configured as an output.");
        }
        # If the port is already on, no need to perform actions.
        #
        elsif($current_state == 0)
        {
            # Update state.
            #
            $PORT_CTRL[$port]->{OUTPUT_STATE} = 1;
    
            # Lookup the value needed to turn port on.
            #
            eval "\$hardware_state = \$HIGH_LOW{\$PORT_CTRL[$port]->{ON_STATE_VALUE}}";
    
            # Device is a TCA6416A IO Expander?
            #
            if($DEVICE_CTRL[$dvc]->{TYPE} eq $sTCA6416A)
            {
                # Write to the GPIO register to switch on port. 
                # 
                my $gpioport = $DEVICE_CTRL[$dvc]->{BASE_ADDR} + ($port - $DEVICE_CTRL[$dvc]->{PORT_MIN});
                U3SHIELD::gpioWrite("$hardware_state", "/sys/class/gpio/gpio$gpioport/value");
            }
            # Device is an ATMega 328p?
            #
            elsif($DEVICE_CTRL[$dvc]->{TYPE} eq $sATMEGA328P)
            {
                U3SHIELD::atmega328pWrite($port, $hardware_state);
            } else
            {
                Utilities::log(1, MODULE, "portON", "Port ($port) is not valid.");
            }
        }
    }

    # Method to turn off a port.
    #
    sub portOFF
    {
        my $port = shift;
        my $hardware_state;

        # Get device id.
        #
        my $dvc = $PORT_CTRL[$port]->{DEVICE_ID};

        # If port is disabled, exit.
        #
        if(not defined $DEVICE_CTRL[$dvc]->{ENABLED} || $DEVICE_CTRL[$dvc]->{ENABLED} eq $sDISABLED)
        {
            Utilities::log(1, MODULE, "portOFF", "Device:$dvc is disabled, port:$port belongs to device so cannot set.");
            return(-1);
        }

        # Get current state for requested port.
        #
        my $current_state = $PORT_CTRL[$port]->{OUTPUT_STATE};

        # Check the values given.
        #
        if($port < $MIN_PORT || $port > $MAX_PORT || !defined $PORT_CTRL[$port])
        {
            Utilities::log(1, MODULE, "portOFF", "Illegal value given to portOFF for port:$port");
        } 
        # Verify that the actual port is an output before trying to set it!
        #
        elsif(!isOutputPort($port))
        {
            Utilities::log(1, MODULE, "portOFF", "Port ($port) is not configured as an output.");
        }
        # If the port is already off, no need to perform actions.
        #
        elsif($current_state == 1)
        {
            # Update state.
            #
            $PORT_CTRL[$port]->{OUTPUT_STATE} = 0;

            # Lookup the value needed to turn port off.
            #
            eval "\$hardware_state = \$HIGH_LOW{\$PORT_CTRL[$port]->{OFF_STATE_VALUE}}";

            # Device is a TCA6416A IO Expander?
            #
            if($DEVICE_CTRL[$dvc]->{TYPE} eq $sTCA6416A)
            {
                # Write to the GPIO register to switch on port. 
                # 
                my $gpioport = $DEVICE_CTRL[$dvc]->{BASE_ADDR} + ($port - $DEVICE_CTRL[$dvc]->{PORT_MIN});
                U3SHIELD::gpioWrite("$hardware_state", "/sys/class/gpio/gpio$gpioport/value");
            }
            # Device is an ATMega 328p?
            #
            elsif($DEVICE_CTRL[$dvc]->{TYPE} eq $sATMEGA328P)
            {
                U3SHIELD::atmega328pWrite($port, $hardware_state);
            } else
            {
                Utilities::log(1, MODULE, "portOFF", "Programming or Run error, port ($port) is not valid.");
            }
        }
    }

    # Handler for children threads, a child which completes has the result stored for later checking.
    #
    sub SigThread
    {
        my ($childId, $result) = @_;

        # Loop through all the port numbers, if we find a child match, update the results arrayed hash.
        #
        for(my $idx=$MIN_PORT; $idx < $MAX_PORT; $idx++)
        {
            # Skip undefined ports.
            #
			next if(!defined $PORT_CTRL[$idx]);

            for(my $pdx=MIN_PING_LIMIT; $pdx <= MAX_PING_LIMIT; $pdx++)
            {
                # If pinging is enabled, check thread id against that stored, update if match found.
                #
                if($PORT_CTRL[$idx]->{PING_ENABLE}[$pdx] eq $sENABLED && $PORT_CTRL[$idx]->{PING_COUNT}->{thrId}[$pdx] == $childId)
                {
                    $PORT_CTRL[$idx]->{PING_COUNT}->{thrResult}[$pdx] = $result;
                    $PORT_CTRL[$idx]->{PING_COUNT}->{thrId}[$pdx] = -1;
                }
            }
        }
    }

    # External method to set the file used for logging.
    #
    sub SetLogFile
    {
        my ($logfile) = @_;
        $LOGFILE = $logfile;
    }

    # External method to set internal Device parameters.
    #
    sub SetDeviceConfig
    {
        # Passed parameters.
        #
        my ($devno, $param, $value) = @_;
		my ($errMsg, $errNo) = ("", 0);

        # If device not configured, setup defaults.
        #
        if(not defined $DEVICE_CTRL[$devno]->{TYPE})
        {
            #$DEVICE_CTRL[$devno]->{ENABLED}         = $sDISABLED;                       # Device is active and configured.
            $DEVICE_CTRL[$devno]->{TYPE}            = $sTCA6416A;                       # Type of Device, ie. ATMEGA328P
            $DEVICE_CTRL[$devno]->{NAME}            = "DEVICE $devno (NOT CONFIGURED)"; # Name associated with this device.
            $DEVICE_CTRL[$devno]->{DESCRIPTION}     = "DEVICE $devno (NOT CONFIGURED)"; # Description of device purpose.
            $DEVICE_CTRL[$devno]->{PORT_MIN}        = MAX_PORT_LIMIT;                   # Minimum port number provided.
            $DEVICE_CTRL[$devno]->{PORT_MAX}        = MAX_PORT_LIMIT;                   # Maximum port number provided.
            $DEVICE_CTRL[$devno]->{BASE_ADDR}       = 0x0;                              # Base address of directly addressable I/O
            $DEVICE_CTRL[$devno]->{UART}            = "";                               # UART device name.
            $DEVICE_CTRL[$devno]->{UART_BAUD}       = 115200;                           # UART Baud Rate.
            $DEVICE_CTRL[$devno]->{UART_DATABITS}   = 8;                                # UART Databits.
            $DEVICE_CTRL[$devno]->{UART_PARITY}     = "none";                           # UART Parity.
            $DEVICE_CTRL[$devno]->{UART_STOPBITS}   = 1;                                # UART Stop bits.
            $DEVICE_CTRL[$devno]->{UART_HANDLE}     = 0;                                # Handle to opened UART device.
        }

        # Check validity of device Id.
        #
        if($devno < MIN_DEVICE_LIMIT)
        {
            $errMsg = "Device Id ($devno) out of acceptable range.";
			$errNo  = -2;
			goto SETDEVICEEXIT;
        }
        if($devno >= MAX_DEVICE_LIMIT)
        {
			$errMsg = "Device Id ($devno) out of acceptable range.";
			$errNo  = -3;
			goto SETDEVICEEXIT;
        }

        # Parameter name is same as is given in the config file, the internal name may differ.
        #
        if($param eq 'DEVICE_TYPE')
        {
            if($value ne "") { $DEVICE_CTRL[$devno]->{TYPE} = $value; }
        }
        elsif($param eq 'DEVICE_NAME')
        {
            if($value ne "") { $DEVICE_CTRL[$devno]->{NAME} = $value; }
        }
        elsif($param eq 'DEVICE_DESCRIPTION')
        {
            if($value ne "") { $DEVICE_CTRL[$devno]->{DESCRIPTION} = $value; } else { $errMsg = "No value given for parameter $param"; $errNo = -1; }
        }
        elsif($param eq 'DEVICE_PORT_MIN')
        {
            # Check validity of values.
            #
			my $usedBy = getDeviceNo($value);
            if($value < MIN_PORT_LIMIT || ($usedBy != $devno && $usedBy != -1))
            {
				$errMsg = "Device ($devno, $value) MIN_PORT_LIMIT in use or out of acceptable range.";
				$errNo  = -5;
			    goto SETDEVICEEXIT;
            }
            $DEVICE_CTRL[$devno]->{PORT_MIN} = $value;

            # Note the minimum port numbers.
            #
            if($MIN_PORT == -1 || $MIN_PORT > $value) { $MIN_PORT = $value; }
        }
        elsif($param eq 'DEVICE_PORT_MAX')
        {
            # Check validity of values.
            #
			my $usedBy = getDeviceNo($value);
            if($value >= MAX_PORT_LIMIT || ($usedBy != $devno && $usedBy != -1))
            {
                $errMsg = "Device ($devno, $value) MAX_PORT_LIMIT in use or out of acceptable range.";
                $errNo  = -6;
			    goto SETDEVICEEXIT;
            }
            $DEVICE_CTRL[$devno]->{PORT_MAX} = $value;

            # Note the maximum port numbers.
            #
            if($MAX_PORT == -1 || $MAX_PORT < $value) { $MAX_PORT = $value; }
        }
        elsif($param eq 'DEVICE_BASE_ADDR')
        {
            if($value ne "") { $DEVICE_CTRL[$devno]->{BASE_ADDR} = $value; }
        }
        elsif($param eq 'DEVICE_UART')
        {
            if($value ne "") { $DEVICE_CTRL[$devno]->{UART} = $value; }
        }
        elsif($param eq 'DEVICE_UART_BAUD')
        {
            if($value ne "") { $DEVICE_CTRL[$devno]->{UART_BAUD} = $value; }
        }
        elsif($param eq 'DEVICE_UART_DATABITS')
        {
            if($value ne "") { $DEVICE_CTRL[$devno]->{UART_DATABITS} = $value; }
        }
        elsif($param eq 'DEVICE_UART_PARITY')
        {
            if($value ne "") { $DEVICE_CTRL[$devno]->{UART_PARITY} = $value; }
        }
        elsif($param eq 'DEVICE_UART_STOPBITS')
        {
            if($value ne "") { $DEVICE_CTRL[$devno]->{UART_STOPBITS} = $value; }
        }

        # If all values have been configured for this device, configure PORTS if necessary,
        # and if all parameters are correct, allow it to be enabled. Disable if any parameter is incorrect.
        # NB. Setting Port values will be overwritten if you setup the Device parameters afterwards.
        #
        elsif($param eq 'DEVICE_ENABLED')
		{		
			if( $errNo                                                 == 0 &&
                defined $DEVICE_CTRL[$devno]->{TYPE}                        &&
                defined $DEVICE_CTRL[$devno]->{PORT_MIN}                    &&
                defined $DEVICE_CTRL[$devno]->{PORT_MAX}                    &&
                $DEVICE_CTRL[$devno]->{PORT_MIN}  < MAX_PORT_LIMIT          &&
                $DEVICE_CTRL[$devno]->{PORT_MIN} >= MIN_PORT_LIMIT          &&
                $DEVICE_CTRL[$devno]->{PORT_MAX}  < MAX_PORT_LIMIT          &&
                $DEVICE_CTRL[$devno]->{PORT_MAX} >= MIN_PORT_LIMIT          &&
                $value ne "" 
              )
            {
                # Initially set the ENABLED state to that requested.
                #
			    $DEVICE_CTRL[$devno]->{ENABLED} = $value;

                # If not already setup, setup the PORT control structure for the device.
                #
                if(not defined $PORT_CTRL[$DEVICE_CTRL[$devno]->{PORT_MIN}])
			    {
                    for(my $idx=$DEVICE_CTRL[$devno]->{PORT_MIN}; $idx <= $DEVICE_CTRL[$devno]->{PORT_MAX}; $idx++)
                    {
                        $PORT_CTRL[$idx]->{IS_LOCKED}                   = $sUNLOCKED;
                        $PORT_CTRL[$idx]->{ENABLED}                     = $sDISABLED;
                        $PORT_CTRL[$idx]->{DEVICE_ID}                   = $devno;
                        $PORT_CTRL[$idx]->{MODE}                        = $sINPUT;
                        $PORT_CTRL[$idx]->{INPUT_STATE}                 = $iLOW;
                        $PORT_CTRL[$idx]->{OUTPUT_STATE}                = $iLOW;
                        $PORT_CTRL[$idx]->{NAME}                        = "PORT $idx";
                        $PORT_CTRL[$idx]->{DESCRIPTION}                 = "PORT $idx (not configured)";
                        $PORT_CTRL[$idx]->{POWERUPSTATE}                = $sOFF;                     # State of output at power on, 0=OFF,1=ON
                        $PORT_CTRL[$idx]->{POWERDOWNSTATE}              = $sCURRENT;                 # State of output at shutdown, 0=OFF,1=ON,2=CURRENT
                        for(my $pdx=MIN_TIMER_LIMIT; $pdx <= MAX_TIMER_LIMIT; $pdx++)
                        {
                            $PORT_CTRL[$idx]->{ON_TIME}[$pdx]           = "00:00:00 0,1,2,3,4,5,6";
                            $PORT_CTRL[$idx]->{ON_TIME_ENABLE}[$pdx]    = $sDISABLED;
                            $PORT_CTRL[$idx]->{TIME_TOGGLE}[$pdx]       = -1;
                            $PORT_CTRL[$idx]->{OFF_TIME}[$pdx]          = "00:00:00 0,1,2,3,4,5,6";
                            $PORT_CTRL[$idx]->{OFF_TIME_ENABLE}[$pdx]   = $sDISABLED;
                        }
						$PORT_CTRL[$idx]->{ON_STATE_VALUE}              = $sHIGH;
						$PORT_CTRL[$idx]->{OFF_STATE_VALUE}             = $sLOW;
				
						for(my $pdx=MIN_PING_LIMIT; $pdx <= MAX_PING_LIMIT; $pdx++)
						{
						    $PORT_CTRL[$idx]->{PING_ENABLE}[$pdx]                = $sDISABLED;
                            $PORT_CTRL[$idx]->{PING_ADDR}[$pdx]                  = "127.0.0.1";
                            $PORT_CTRL[$idx]->{PING_TYPE}[$pdx]                  = $sPING_ICMP;
                            $PORT_CTRL[$idx]->{PING_ADDR_WAIT_TIME}[$pdx]        = 10;
                            $PORT_CTRL[$idx]->{PING_TO_PING_TIME}[$pdx]          = 10;
                            $PORT_CTRL[$idx]->{PING_FAIL_COUNT}[$pdx]            = 10;
                            $PORT_CTRL[$idx]->{PING_SUCCESS_COUNT}[$pdx]         = 10;
                            $PORT_CTRL[$idx]->{PING_COUNT}->{failCount}[$pdx]    = 0;
                            $PORT_CTRL[$idx]->{PING_COUNT}->{successCount}[$pdx] = 0;
                            $PORT_CTRL[$idx]->{PING_COUNT}->{nextTime}[$pdx]     = 0;
                            $PORT_CTRL[$idx]->{PING_COUNT}->{thrId}[$pdx]        = -1;
                            $PORT_CTRL[$idx]->{PING_COUNT}->{thrResult}[$pdx]    = 0;
                        }
        
                        $PORT_CTRL[$idx]->{PING_LOGIC_FOR_FAIL}         = "OR";
                        $PORT_CTRL[$idx]->{PING_LOGIC_FOR_SUCCESS}      = "OR";
                        $PORT_CTRL[$idx]->{PING_ACTION_ON_FAIL}         = "NONE";
                        $PORT_CTRL[$idx]->{PING_ACTION_ON_SUCCESS}      = "NONE";
                        $PORT_CTRL[$idx]->{PING_ACTION_FAIL_TIME}       = 10;
                        $PORT_CTRL[$idx]->{PING_ACTION_SUCCESS_TIME}    = 10;
                        $PORT_CTRL[$idx]->{RESET_TIME}                  = 5;
        
					    $PORT_CTRL[$idx]->{SCHEDULE}->{trigTime}        = 0;
					    $PORT_CTRL[$idx]->{SCHEDULE}->{portValue}       = 0;
                    }
			    }

                # Verify that the device is correctly configured, any issues, disable it.
                #
                if(   $DEVICE_CTRL[$devno]->{TYPE} eq $sATMEGA328P)
			    {
				    if($DEVICE_CTRL[$devno]->{UART} eq "")
				    {
				        $errMsg = $errMsg . "UART Device is not valid; ";
				    }
				    if(not defined $DEVICE_BAUD_RATES{$DEVICE_CTRL[$devno]->{UART_BAUD}})
				    {
				        $errMsg = $errMsg . "Illegal BAUD RATE; ";
				    }
				    if(not defined $DEVICE_DATABITS{$DEVICE_CTRL[$devno]->{UART_DATABITS}})
				    {
				        $errMsg = $errMsg . "Illegal number of DATABITSl ";
				    }
				    if(not defined $DEVICE_PARITY{$DEVICE_CTRL[$devno]->{UART_PARITY}})
				    {
				        $errMsg = $errMsg . "Illegal PARITY setting; ";
				    }
				    if(not defined $DEVICE_STOPBITS{$DEVICE_CTRL[$devno]->{UART_STOPBITS}})
				    {
				        $errMsg = $errMsg . "Illegal STOPBITS setting; ";
				    }
				    if($errMsg ne "")
				    {
					    $DEVICE_CTRL[$devno]->{ENABLED} = $sDISABLED;
					    $errNo = 11;
			            goto SETDEVICEEXIT;
			        }
			    }
			    elsif($DEVICE_CTRL[$devno]->{TYPE} eq $sTCA6416A)
			    {
				    if($errMsg ne "")
				    {
					    $DEVICE_CTRL[$devno]->{ENABLED} = $sDISABLED;
					    $errNo = 12;
			            goto SETDEVICEEXIT;
			        }
			    }
			    else
			    {
				    $errMsg = $errMsg . "Unrecognised device type ($DEVICE_CTRL[$devno]->{TYPE}), cannot enable device; ";
				    $errNo  = 10;
			        goto SETDEVICEEXIT;
			    }
			} else
			{
				$errMsg = "Key device information not setup, cannot ENABLE device ($devno).";
				$errNo  = -4;
			    goto SETDEVICEEXIT;
			}
		}

        else
        {
			$errMsg = "Unknown parameter ($param) for Device Id ($devno)";
			$errNo  = -7;
			goto SETDEVICEEXIT;
        }

SETDEVICEEXIT:
		if(   $errNo < 0)
		{
            Utilities::log(0, MODULE, "SetDeviceConfig", $errMsg);
			return($errNo, undef, $errMsg);
		}
		elsif($errNo > 0)
		{
            (undef, $value, undef) = GetDeviceConfig($devno, $param);
			return($errNo, $value, $errMsg);
		} else
		{
            # Call GetDevice in case any changes were made to passed parameter and return to caller.
            #
            return(GetDeviceConfig($devno, $param));
		}
    }

    # External method to get internal Device parameters.
    #
    sub GetDeviceConfig
    {
        # Passed parameters.
        #
        my ($devno, $param)  = @_;
		my ($errMsg, $errNo) = ("", 0);
        my $value;

        # Check validity of device Id.
        #
        if($devno < MIN_DEVICE_LIMIT)
        {
			$errMsg = "Device Id ($devno) out of acceptable range.";
            $errNo = -2;
			goto GETDEVICEEXIT;
        }
        if($devno >= MAX_DEVICE_LIMIT)
        {
			$errMsg = "Device Id ($devno) out of acceptable range.";
            $errNo = -3;
			goto GETDEVICEEXIT;
        }

        # Parameter name is same as is given in the config file, the internal name may differ.
        #
        if($param eq 'DEVICE_TYPE' && defined $DEVICE_CTRL[$devno]->{TYPE})
        {
            $value = $DEVICE_CTRL[$devno]->{TYPE};
        }
        elsif($param eq 'DEVICE_NAME' && defined $DEVICE_CTRL[$devno]->{NAME})
        {
            $value = $DEVICE_CTRL[$devno]->{NAME};
        }
        elsif($param eq 'DEVICE_DESCRIPTION' && defined $DEVICE_CTRL[$devno]->{DESCRIPTION})
        {
            $value = $DEVICE_CTRL[$devno]->{DESCRIPTION};
        }
        elsif($param eq 'DEVICE_ENABLED' && defined $DEVICE_CTRL[$devno]->{ENABLED})
        {
            $value = $DEVICE_CTRL[$devno]->{ENABLED};
        }
        elsif($param eq 'DEVICE_PORT_MIN' && defined $DEVICE_CTRL[$devno]->{PORT_MIN})
        {
            $value = $DEVICE_CTRL[$devno]->{PORT_MIN};
        }
        elsif($param eq 'DEVICE_PORT_MAX' && defined $DEVICE_CTRL[$devno]->{PORT_MAX})
        {
            $value = $DEVICE_CTRL[$devno]->{PORT_MAX};
        }
        elsif($param eq 'DEVICE_BASE_ADDR' && defined $DEVICE_CTRL[$devno]->{BASE_ADDR})
        {
            $value = $DEVICE_CTRL[$devno]->{BASE_ADDR};
        }
        elsif($param eq 'DEVICE_UART' && defined $DEVICE_CTRL[$devno]->{UART})
        {
            $value = $DEVICE_CTRL[$devno]->{UART};
        }
        elsif($param eq 'DEVICE_UART_BAUD' && defined $DEVICE_CTRL[$devno]->{UART_BAUD})
        {
            $value = $DEVICE_CTRL[$devno]->{UART_BAUD};
        }
        elsif($param eq 'DEVICE_UART_DATABITS' && defined $DEVICE_CTRL[$devno]->{UART_DATABITS})
        {
            $value = $DEVICE_CTRL[$devno]->{UART_DATABITS};
        }
        elsif($param eq 'DEVICE_UART_PARITY' && defined $DEVICE_CTRL[$devno]->{UART_PARITY})
        {
            $value = $DEVICE_CTRL[$devno]->{UART_PARITY};
        }
        elsif($param eq 'DEVICE_UART_STOPBITS' && defined $DEVICE_CTRL[$devno]->{UART_STOPBITS})
        {
            $value = $DEVICE_CTRL[$devno]->{UART_STOPBITS};
        }
        elsif($param eq 'ENABLED' && defined $DEVICE_CTRL[$devno]->{ENABLED})
        {
            $value = $DEVICE_CTRL[$devno]->{ENABLED};
        }
        else
        {
            # If device not configured, warn and exit, otherwise return error.
            #
		    if(!defined $DEVICE_CTRL[$devno]->{ENABLED})
		    {
				$errMsg = "Device Id ($devno) is not configured.";
				$errNo  = -1;
				goto GETDEVICEEXIT;
		    } else
            {
				$errMsg = "Unknown parameter ($param) for Device Id ($devno)";
				$errNo  = -4;
				goto GETDEVICEEXIT;
			}
        }

GETDEVICEEXIT:
		if($errNo != 0)
		{
            Utilities::log(0, MODULE, "GetDeviceConfig", $errMsg);
			return($errNo, undef, $errMsg);
		} else
		{
            return($errNo, $value, $errMsg);
		}
    }

    # External method to set internal port parameters.
    #
    sub SetPortConfig
    {
        # Passed parameters.
        #
        my ($portno, $param, $value) = @_;

        # Check to see that the port has been configured by Set Device.
        #
        if(not defined $PORT_CTRL[$portno]->{NAME}        ||
           not defined $PORT_CTRL[$portno]->{DESCRIPTION} ||
           not defined $PORT_CTRL[$portno]->{IS_LOCKED}   ||
           not defined $PORT_CTRL[$portno]->{ENABLED}     ||
           not defined $PORT_CTRL[$portno]->{PORT_MIN}    ||
           not defined $PORT_CTRL[$portno]->{PORT_MAX})
        {
            Utilities::log(0, MODULE, "SetPortConfig", "Port Id ($portno) is not configured, internal error!");
            return(-5, undef);
        }

        # Check validity of port Id.
        #
        if($portno < MIN_PORT_LIMIT)
        {
            Utilities::log(0, MODULE, "SetPortConfig", "Port Id ($portno) out of acceptable range.");
            return(-1, undef);
        }
        if($portno >= MAX_PORT_LIMIT)
        {
            Utilities::log(0, MODULE, "SetPortConfig", "Port Id ($portno) out of acceptable range.");
            return(-2, undef);
        }

        # Parameter name is same as is given in the config file, the internal name may differ.
        #
        if($param eq 'PORT_NAME')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{NAME} = $value; }
        }
        elsif($param eq 'PORT_DESCRIPTION')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{DESCRIPTION} = $value; }
        }
        elsif($param eq 'PORT_LOCKED')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{IS_LOCKED} = $value; }
        }
        elsif($param eq 'PORT_ENABLED')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{ENABLED} = $value; }
        }
        elsif($param eq 'PORT_MODE')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{MODE} = $value; }
        }
        elsif($param eq 'PORT_POWERUPSTATE')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{POWERUPSTATE} = $value; }
        }
        elsif($param eq 'PORT_POWERDOWNSTATE')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{POWERDOWNSTATE} = $value; }
        }
        elsif(substr($param, 0, 19) eq 'PORT_ON_TIME_ENABLE')
        {
            if($value ne "")
            {
                my $pdx = substr($param, 20);
                $PORT_CTRL[$portno]->{ON_TIME_ENABLE}[$pdx] = $value;
            }
        }
        elsif(substr($param, 0, 20) eq 'PORT_OFF_TIME_ENABLE')
        {
            if($value ne "")
            {
                my $pdx = substr($param, 21);
                $PORT_CTRL[$portno]->{OFF_TIME_ENABLE}[$pdx] = $value;
            }
        }
        elsif(substr($param, 0, 12) eq 'PORT_ON_TIME')
        {
            if($value ne "")
            {
                my $pdx = substr($param, 13);
                $PORT_CTRL[$portno]->{ON_TIME}[$pdx] = chkTime($value);
            }
        }
        elsif(substr($param, 0, 13) eq 'PORT_OFF_TIME')
        {
            if($value ne "")
            {
                my $pdx = substr($param, 14);
                $PORT_CTRL[$portno]->{OFF_TIME}[$pdx] = chkTime($value);
            }
        }
        elsif($param eq 'PORT_ON_STATE_VALUE')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{ON_STATE_VALUE} = $value; }
        }
        elsif($param eq 'PORT_OFF_STATE_VALUE')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{OFF_STATE_VALUE} = $value; }
        }
        elsif(substr($param, 0, 16) eq 'PORT_PING_ENABLE')
        {
            if($value ne "")
            {
                my $pdx = substr($param, 17);
                $PORT_CTRL[$portno]->{PING_ENABLE}[$pdx] = $value;
            }
        }
        elsif(substr($param, 0, 14) eq 'PORT_PING_TYPE')
        {
            if($value ne "")
            {
                my $pdx = substr($param, 15);
                $PORT_CTRL[$portno]->{PING_TYPE}[$pdx] = $value;
            }
        }
        elsif(substr($param, 0, 24) eq 'PORT_PING_ADDR_WAIT_TIME')
        {
            if($value ne "")
            {
                my $pdx = substr($param, 25);
                $PORT_CTRL[$portno]->{PING_ADDR_WAIT_TIME}[$pdx] = $value;
            }
        }
        elsif(substr($param, 0, 14) eq 'PORT_PING_ADDR')
        {
            if($value ne "")
            {
                my $pdx = substr($param, 15);
                $PORT_CTRL[$portno]->{PING_ADDR}[$pdx] = chkIp($value);
            }
        }
        elsif(substr($param, 0, 22) eq 'PORT_PING_TO_PING_TIME')
        {
            if($value ne "")
            {
                my $pdx = substr($param, 23);
                $PORT_CTRL[$portno]->{PING_TO_PING_TIME}[$pdx] = $value;
            }
        }
        elsif(substr($param, 0, 20) eq 'PORT_PING_FAIL_COUNT')
        {
            if($value ne "")
            {
                my $pdx = substr($param, 21);
                $PORT_CTRL[$portno]->{PING_FAIL_COUNT}[$pdx] = $value;
            }
        }
        elsif(substr($param, 0, 23) eq 'PORT_PING_SUCCESS_COUNT')
        {
            if($value ne "")
            {
                my $pdx = substr($param, 24);
                $PORT_CTRL[$portno]->{PING_SUCCESS_COUNT}[$pdx] = $value;
            }
        }
        elsif($param eq 'PORT_PING_LOGIC_FOR_FAIL')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{PING_LOGIC_FOR_FAIL} = $value; }
        }
        elsif($param eq 'PORT_PING_LOGIC_FOR_SUCCESS')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{PING_LOGIC_FOR_SUCCESS} = $value; }
        }
        elsif($param eq 'PORT_PING_ACTION_ON_FAIL')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{PING_ACTION_ON_FAIL} = $value; }
        }
        elsif($param eq 'PORT_PING_ACTION_ON_SUCCESS')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{PING_ACTION_ON_SUCCESS} = $value; }
        }
        elsif($param eq 'PORT_PING_ACTION_SUCCESS_TIME')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{PING_ACTION_SUCCESS_TIME} = $value; }
        }
        elsif($param eq 'PORT_PING_ACTION_FAIL_TIME')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{PING_ACTION_FAIL_TIME} = $value; }
        }
        elsif($param eq 'PORT_RESET_TIME')
        {
            if($value ne "") { $PORT_CTRL[$portno]->{PING_RESET_TIME} = $value; }
        }
        else
        {
            Utilities::log(0, MODULE, "SetPortConfig", "Unknown parameter ($param) for Port Id ($portno)");
            return(-3, undef);
        }

        Utilities::log(6, MODULE, "SetPortConfig", "$portno,$param,$value");
        return(GetPortConfig($portno, $param));
    }

    # External method to get internal port parameters.
    #
    sub GetPortConfig
    {
        # Passed parameters.
        #
        my ($portno, $param) = @_;
        my $value;

        # Check validity of port Id.
        #
        if($portno < MIN_PORT_LIMIT)
        {
            Utilities::log(0, MODULE, "GetPortConfig", "Port Id ($portno) out of acceptable range.");
            return(-1, undef);
        }
        if($portno >= MAX_PORT_LIMIT)
        {
            Utilities::log(0, MODULE, "GetPortConfig", "Port Id ($portno) out of acceptable range.");
            return(-2, undef);
        }
		if(!defined $PORT_CTRL[$portno])
		{
            Utilities::log(0, MODULE, "GetPortConfig", "Port Id ($portno) is not configured.");
            return(-3, undef);
		}

        # Parameter name is same as is given in the config file, the internal name may differ.
        #
        if($param eq 'PORT_NAME')
        {
            $value = $PORT_CTRL[$portno]->{NAME};
        }
        elsif($param eq 'PORT_DESCRIPTION')
        {
            $value = $PORT_CTRL[$portno]->{DESCRIPTION};
        }
        elsif($param eq 'PORT_LOCKED')
        {
            $value = $PORT_CTRL[$portno]->{IS_LOCKED};
        }
        elsif($param eq 'PORT_ENABLED')
        {
            $value = $PORT_CTRL[$portno]->{ENABLED};
        }
        elsif($param eq 'PORT_MODE')
        {
            $value = $PORT_CTRL[$portno]->{MODE};
        }
        elsif($param eq 'PORT_POWERUPSTATE')
        {
            $value = $PORT_CTRL[$portno]->{POWERUPSTATE};
        }
        elsif($param eq 'PORT_POWERDOWNSTATE')
        {
            $value = $PORT_CTRL[$portno]->{POWERDOWNSTATE};
        }
        elsif(substr($param, 0, 19) eq 'PORT_ON_TIME_ENABLE')
        {
            my $pdx = substr($param, 20);
            $value = $PORT_CTRL[$portno]->{ON_TIME_ENABLE}[$pdx];
        }
        elsif(substr($param, 0, 20) eq 'PORT_OFF_TIME_ENABLE')
        {
            my $pdx = substr($param, 21);
            $value = $PORT_CTRL[$portno]->{OFF_TIME_ENABLE}[$pdx];
        }
        elsif(substr($param, 0, 12) eq 'PORT_ON_TIME')
        {
            my $pdx = substr($param, 13);
            $value = $PORT_CTRL[$portno]->{ON_TIME}[$pdx];
        }
        elsif(substr($param, 0, 13) eq 'PORT_OFF_TIME')
        {
            my $pdx = substr($param, 14);
            $value = $PORT_CTRL[$portno]->{OFF_TIME}[$pdx];
        }
        elsif($param eq 'PORT_ON_STATE_VALUE')
        {
            $value = $PORT_CTRL[$portno]->{ON_STATE_VALUE};
        }
        elsif($param eq 'PORT_OFF_STATE_VALUE')
        {
            $value = $PORT_CTRL[$portno]->{OFF_STATE_VALUE};
        }
        elsif(substr($param, 0, 16) eq 'PORT_PING_ENABLE')
        {
            my $pdx = substr($param, 17);
            $value = $PORT_CTRL[$portno]->{PING_ENABLE}[$pdx];
        }
        elsif(substr($param, 0, 14) eq 'PORT_PING_TYPE')
        {
            my $pdx = substr($param, 15);
            $value = $PORT_CTRL[$portno]->{PING_TYPE}[$pdx];
        }
        elsif(substr($param, 0, 24) eq 'PORT_PING_ADDR_WAIT_TIME')
        {
            my $pdx = substr($param, 25);
            $value = $PORT_CTRL[$portno]->{PING_ADDR_WAIT_TIME}[$pdx];
        }
        elsif(substr($param, 0, 14) eq 'PORT_PING_ADDR')
        {
            my $pdx = substr($param, 15);
            $value = $PORT_CTRL[$portno]->{PING_ADDR}[$pdx];
        }
        elsif(substr($param, 0, 22) eq 'PORT_PING_TO_PING_TIME')
        {
            my $pdx = substr($param, 23);
            $value = $PORT_CTRL[$portno]->{PING_TO_PING_TIME}[$pdx];
        }
        elsif(substr($param, 0, 20) eq 'PORT_PING_FAIL_COUNT')
        {
            my $pdx = substr($param, 21);
            $value = $PORT_CTRL[$portno]->{PING_FAIL_COUNT}[$pdx];
        }
        elsif(substr($param, 0, 23) eq 'PORT_PING_SUCCESS_COUNT')
        {
            my $pdx = substr($param, 24);
            $value = $PORT_CTRL[$portno]->{PING_SUCCESS_COUNT}[$pdx];
        }
        elsif($param eq 'PORT_PING_LOGIC_FOR_FAIL')
        {
            $value = $PORT_CTRL[$portno]->{PING_LOGIC_FOR_FAIL};
        }
        elsif($param eq 'PORT_PING_LOGIC_FOR_SUCCESS')
        {
            $value = $PORT_CTRL[$portno]->{PING_LOGIC_FOR_SUCCESS};
        }
        elsif($param eq 'PORT_PING_ACTION_ON_FAIL')
        {
            $value = $PORT_CTRL[$portno]->{PING_ACTION_ON_FAIL};
        }
        elsif($param eq 'PORT_PING_ACTION_ON_SUCCESS')
        {
            $value = $PORT_CTRL[$portno]->{PING_ACTION_ON_SUCCESS};
        }
        elsif($param eq 'PORT_PING_ACTION_SUCCESS_TIME')
        {
            $value = $PORT_CTRL[$portno]->{PING_ACTION_SUCCESS_TIME};
        }
        elsif($param eq 'PORT_PING_ACTION_FAIL_TIME')
        {
            $value = $PORT_CTRL[$portno]->{PING_ACTION_FAIL_TIME};
        }
        elsif($param eq 'PORT_RESET_TIME')
        {
            $value = $PORT_CTRL[$portno]->{RESET_TIME};
        }
        else
        {
            Utilities::log(0, MODULE, "GetPortConfig", "Unknown parameter ($param) for Port Id ($portno)");
            return(-4, undef);
        }
        Utilities::log(6, MODULE, "GetPortConfig", "$portno,$param RETURN:$value");
        return(0, $value);
    }

    # Function to initialise the serial interface to an ATMega328p, then initialise the ATMega328p.
    #
	sub Init_ATMega328p
	{
        # Passed parameters.
        #
        my ($dvc)  = @_;
        my $hardware_startup_value = "0";
        my $hardware_state         = "0";
        my $result                 = 0;

        # If a previous instance existed, destroy it prior to creating new instance.
        #
        if(defined $DEVICE_CTRL[$dvc]->{UART_HANDLE} && $DEVICE_CTRL[$dvc]->{UART_HANDLE} != 0)
        {
            undef $DEVICE_CTRL[$dvc]->{UART_HANDLE};
		}

        # Ensure the device is accessible at operating system level, call the root priviledge config script to
        # set ownership.
        #
        Utilities::log(0, MODULE, "Init_ATMega328p", "Launching(ix ix_cfgATMega328p \"$DEVICE_CTRL[$dvc]->{UART}\"\)");
        system("$ENV{'BINDIR'}/ix ix_cfgATMega328p \"$DEVICE_CTRL[$dvc]->{UART}\" 2>/dev/null >/dev/null");

        $DEVICE_CTRL[$dvc]->{UART_HANDLE} = Device::SerialPort->new("$DEVICE_CTRL[$dvc]->{UART}");
		if(defined $DEVICE_CTRL[$dvc]->{UART_HANDLE})
		{
            # Setup the serial parameters.
            #
            $DEVICE_CTRL[$dvc]->{UART_HANDLE}->baudrate($DEVICE_CTRL[$dvc]->{UART_BAUD});
            $DEVICE_CTRL[$dvc]->{UART_HANDLE}->databits($DEVICE_CTRL[$dvc]->{UART_DATABITS});
            $DEVICE_CTRL[$dvc]->{UART_HANDLE}->parity("$DEVICE_CTRL[$dvc]->{UART_PARITY}");
            $DEVICE_CTRL[$dvc]->{UART_HANDLE}->stopbits($DEVICE_CTRL[$dvc]->{UART_STOPBITS});

            # Need to get rid of gremlins, ie. random bytes sent.
            #
            my $tEnd = time()+2;                # 2 seconds in future
            while (time()< $tEnd)
            {                                   # end latest after 2 seconds
                my $c = $DEVICE_CTRL[$dvc]->{UART_HANDLE}->lookfor(); # char or nothing
                next if $c eq "";               # restart if noting
                last;
            }
            while (1)
            {                                   # and all the rest of the gremlins as they come in one piece
                my $c = $DEVICE_CTRL[$dvc]->{UART_HANDLE}->lookfor(); # get the next one
                last if $c eq "";               # or we're done
            }

            # Initialise the ATMega328p ports.
            #
            my $Atmega328p_Config = "C";
            my $Atmega328p_Write  = "W";
            for(my $idx=$DEVICE_CTRL[$dvc]->{PORT_MIN}; $idx <= $DEVICE_CTRL[$dvc]->{PORT_MAX}; $idx++)
            {
                # Verify that the actual port is an output before trying to set it!
                #
                if(isOutputPort($idx))
                {
                    # Configured to be an output (=0)
                    #
                    $Atmega328p_Config = $Atmega328p_Config . "0";
        
                    # Lookup the value to set the port at power up.
                    #
                    eval "\$hardware_startup_value = \$ON_OFF{\$PORT_CTRL[$idx]->{POWERUPSTATE}}";
        
                    # Update state.
                    #
                    $PORT_CTRL[$idx]->{OUTPUT_STATE} = $hardware_startup_value;
        
                    # Initial state = off?
                    #
                    if($hardware_startup_value == 0)
                    {
                        # Lookup the value needed to turn port off.
                        #
                        eval "\$hardware_state = \$HIGH_LOW{\$PORT_CTRL[$idx]->{OFF_STATE_VALUE}}";
                    } else
                    {
                        # Lookup the value needed to turn port on.
                        #
                        eval "\$hardware_state = \$HIGH_LOW{\$PORT_CTRL[$idx]->{ON_STATE_VALUE}}";
                    }
        
                    # Build up the initial output value string.
                    #
                    $Atmega328p_Write = $Atmega328p_Write . "$hardware_state";
                } else
                {
                    # Configured to be an input (=1)
                    #
                    $Atmega328p_Config = $Atmega328p_Config . "1";
                    $Atmega328p_Write  = $Atmega328p_Write  . "0";
                }
            }

            # Set the configuration.
            #
            $DEVICE_CTRL[$dvc]->{UART_HANDLE}->write("$Atmega328p_Config\n");
            my $rcvBuf = atmega328pReceive($DEVICE_CTRL[$dvc]->{UART_HANDLE}, 100, 250);
            Utilities::log(6, MODULE, "Init_ATMega328p", "Sending config string:$Atmega328p_Config\n");
            if(substr($rcvBuf, 0, 2) ne "OK")
            {
                Utilities::log(0, MODULE, "Init", "Device $dvc, did not receive ACK:$rcvBuf\n");
            }
                
            # Set the output values.
            #
            $DEVICE_CTRL[$dvc]->{UART_HANDLE}->write("$Atmega328p_Write\n");
            $rcvBuf = atmega328pReceive($DEVICE_CTRL[$dvc]->{UART_HANDLE}, 100, 250);
            Utilities::log(6, MODULE, "Init_ATMega328p", "Sending write string:$Atmega328p_Write\n");
            if(substr($rcvBuf, 0, 2) ne "OK")
            {
                Utilities::log(0, MODULE, "Init_ATMega328p", "Device $dvc, did not receive ACK:$rcvBuf\n");
            }
		} else
		{
            $result = -1;
		}
		return($result);
	}

    # Function to initialise the GPIO interface for a TCA641A IO Expander.
    #
	sub Init_TCA6416A
	{
        # Passed parameters.
        #
        my ($dvc)  = @_;
        my $gpioport;
        my $hardware_startup_value = "0";
        my $hardware_state         = "0";
        my $result                 = 0;

        # Ensure the device is accessible at operating system level, call the root priviledge config script to
        # set ownership.
        #
        Utilities::log(0, MODULE, "Init_TCA6416A", "Launching(ix ix_cfgTCA6416A \"$DEVICE_CTRL[$dvc]->{BASE_ADDR}\"\)");
        system("$ENV{'BINDIR'}/ix ix_cfgTCA6416A \"$DEVICE_CTRL[$dvc]->{BASE_ADDR}\" 2>/dev/null >/dev/null");

        # Initialise the GPIO ports.
        #
        for(my $idx=$DEVICE_CTRL[$dvc]->{PORT_MIN}; $idx <= $DEVICE_CTRL[$dvc]->{PORT_MAX}; $idx++)
        {
            # Address of port we are working on.
            #
            $gpioport = $DEVICE_CTRL[$dvc]->{BASE_ADDR} + ($idx - $DEVICE_CTRL[$dvc]->{PORT_MIN});
       
            # Verify that the actual port is an output before trying to set it!
            #
            if(isOutputPort($idx))
            {
                # Lookup the value to set the port at power up.
                #
                eval "\$hardware_startup_value = \$ON_OFF{\$PORT_CTRL[$idx]->{POWERUPSTATE}}";
      
                # Update state.
                #
                $PORT_CTRL[$idx]->{OUTPUT_STATE} = $hardware_startup_value;
        
                # Initial state = off?
                #
                if($hardware_startup_value == 0)
                {
                    # Lookup the value needed to turn port off.
                    #
                    eval "\$hardware_state = \$HIGH_LOW{\$PORT_CTRL[$idx]->{OFF_STATE_VALUE}}";
                } else
                {
                    # Lookup the value needed to turn port on.
                    #
                    eval "\$hardware_state = \$HIGH_LOW{\$PORT_CTRL[$idx]->{ON_STATE_VALUE}}";
                }
     
                # Write to the GPIO register to switch on outputs. 
                # 
                U3SHIELD::gpioWrite("out","/sys/class/gpio/gpio$gpioport/direction");
                U3SHIELD::gpioWrite("$hardware_state", "/sys/class/gpio/gpio$gpioport/value");
            } else
            {
                # Write to the GPIO register to switch on input. 
                # 
                U3SHIELD::gpioWrite("in","/sys/class/gpio/gpio$gpioport/direction");
            }
        }
		return($result);
	}

    # Method to initialise the devices once they have been defined.
    #
	sub InitDevices
	{
        # Variables.
        #
		my ($errMsg) = ("");

		# Loop through all devices, process if active.
        #
        for(my $dvc=MIN_DEVICE_LIMIT; $dvc < MAX_DEVICE_LIMIT; $dvc++)
        {
            next if(not defined $DEVICE_CTRL[$dvc]->{ENABLED});
            next if($DEVICE_CTRL[$dvc]->{ENABLED} ne $sENABLED);

            if(   $DEVICE_CTRL[$dvc]->{TYPE} eq $sATMEGA328P)
			{
			    if(Init_ATMega328p($dvc) != 0)
			    {
			    	$errMsg = $errMsg . "Cannot initialise UART, disabling device; ";
			    }
			}
			elsif($DEVICE_CTRL[$dvc]->{TYPE} eq $sTCA6416A)
			{
			    if(Init_TCA6416A($dvc) != 0)
			    {
			   	    $errMsg = $errMsg . "Cannot initialise IO Expander, disabling device; ";
			    }
			}
			else
			{
			    $errMsg = $errMsg . "Unrecognised device type ($DEVICE_CTRL[$dvc]->{TYPE}), cannot enable device; ";
			}
		}

		# Return any error messages.
        #
		return($errMsg);
	}

    # Method to tidy up the U3SHIELD prior to exit.
    #
    sub Terminate
    {
        my $gpioport;
        my $hardware_shutdown_value = "0";
        my $hardware_state          = "0";

        # Terminate, setting hardware to final state.
        #
        for(my $dvc=MIN_DEVICE_LIMIT; $dvc < MAX_DEVICE_LIMIT; $dvc++)
        {
            next if(not defined $DEVICE_CTRL[$dvc]->{ENABLED});
            next if($DEVICE_CTRL[$dvc]->{ENABLED} ne $sENABLED);

            # ATMega 328p?
            #
            if($DEVICE_CTRL[$dvc]->{TYPE} eq $sATMEGA328P)
            {
                # Build final string.
                #
                my $Atmega328p_Write  = "W";
                for(my $idx=$DEVICE_CTRL[$dvc]->{PORT_MIN}; $idx <= $DEVICE_CTRL[$dvc]->{PORT_MAX}; $idx++)
                {
                    # Verify that the actual port is an output before trying to set it!
                    #
                    if(isOutputPort($idx))
                    {
                        # Lookup the value to set the port at power down.
                        #
                        eval "\$hardware_shutdown_value = \$ON_OFF{\$PORT_CTRL[$idx]->{POWERDOWNSTATE}}";
        
                        # Power off, on or leave as current?
                        #
                        if($hardware_shutdown_value != 2)
                        {
                            # Update state.
                            #
                            $PORT_CTRL[$idx]->{OUTPUT_STATE} = $hardware_shutdown_value;
                        }
        
                        # Final state = off?
                        #
                        if($PORT_CTRL[$idx]->{OUTPUT_STATE} == $iOFF)
                        {
                            # Lookup the value needed to turn port off.
                            #
                            eval "\$hardware_state = \$HIGH_LOW{\$PORT_CTRL[$idx]->{OFF_STATE_VALUE}}";
                        } else
                        {
                            # Lookup the value needed to turn port on.
                            #
                            eval "\$hardware_state = \$HIGH_LOW{\$PORT_CTRL[$idx]->{ON_STATE_VALUE}}";
                        }

                        # Build up the Final output value string.
                        #
                        $Atmega328p_Write = $Atmega328p_Write . "$hardware_state";
                    } else
                    {
                        # Configured to be an input (=1)
                        #
                        $Atmega328p_Write  = $Atmega328p_Write  . "0";
                    }
                }
        
                # Set the output values.
                #
                $DEVICE_CTRL[$dvc]->{UART_HANDLE}->write("$Atmega328p_Write\n");
                my $rcvBuf = atmega328pReceive($DEVICE_CTRL[$dvc]->{UART_HANDLE}, 100, 250);
                if(substr($rcvBuf, 0, 2) ne "OK")
                {
                    Utilities::log(0, MODULE, "Init", "Did not receive ok:$rcvBuf\n");
                }
            }

            # If device is a TCA6416A IO Expander, set it up.
            #
            if($DEVICE_CTRL[$dvc]->{TYPE} eq $sTCA6416A)
            {
                # Initialise the GPIO ports.
                #
                for(my $idx=$DEVICE_CTRL[$dvc]->{PORT_MIN}; $idx <= $DEVICE_CTRL[$dvc]->{PORT_MAX}; $idx++)
                {
                    # Address of port we are working on.
                    #
                    $gpioport = $DEVICE_CTRL[$dvc]->{BASE_ADDR} + ($idx - $DEVICE_CTRL[$dvc]->{PORT_MIN});
        
                    # Verify that the actual port is an output before trying to set it!
                    #
                    if(isOutputPort($idx))
                    {
                        # Lookup the value to set the port at power down.
                        #
                        eval "\$hardware_shutdown_value = \$ON_OFF{\$PORT_CTRL[$idx]->{POWERDOWNSTATE}}";
        
                        # Power off, on or leave as current?
                        #
                        if($hardware_shutdown_value != 2)
                        {
                            # Update state.
                            #
                            $PORT_CTRL[$idx]->{OUTPUT_STATE} = $hardware_shutdown_value;
        
                            # Final state = off?
                            #
                            if($hardware_shutdown_value == 0)
                            {
                                # Lookup the value needed to turn port off.
                                #
                                eval "\$hardware_state = \$HIGH_LOW{\$PORT_CTRL[$idx]->{OFF_STATE_VALUE}}";
                            } else
                            {
                                # Lookup the value needed to turn port on.
                                #
                                eval "\$hardware_state = \$HIGH_LOW{\$PORT_CTRL[$idx]->{ON_STATE_VALUE}}";
                            }

                            # Write to the GPIO register to switch on outputs. 
                            # 
                            U3SHIELD::gpioWrite("out","/sys/class/gpio/gpio$gpioport/direction");
                            U3SHIELD::gpioWrite("$hardware_state", "/sys/class/gpio/gpio$gpioport/value");
                        }
                    } else
                    {
                        # Write to the GPIO register to switch on input. 
                        # 
                        U3SHIELD::gpioWrite("in","/sys/class/gpio/gpio$gpioport/direction");
                    }
                }
            }
        }

        # End message.
        #
        Utilities::log(0, MODULE, "Terminate", "U3SHIELD offline.");
    }

    # Function to schedule a port to change to a defined value in the future.
    #
    sub portSchedule
    {
        my ($port, $waittime, $action) = @_;
        my $set_to_value = $OUTPUT_STATE_MAP{$action};
        my $current_time = time();

        # Check parameters and if ok, load the event into scheduler.
        #
        if($port >= $MIN_PORT && $port < $MAX_PORT && defined $PORT_CTRL[$port] && ($set_to_value == 0 || $set_to_value == 1))
        {
            $PORT_CTRL[$port]->{SCHEDULE}->{portValue}  = $set_to_value;
            $PORT_CTRL[$port]->{SCHEDULE}->{trigTime}   = $current_time + $waittime;
        } else
        {
            if($set_to_value != 0 && $set_to_value != 1)
            {
                Utilities::log(1, MODULE, "portSchedule", "Illegal action ($action) given in portSchedule");
            }
            
            if($port < $MIN_PORT || $port > $MAX_PORT || ! defined $PORT_CTRL[$port])
            {
                Utilities::log(1, MODULE, "portSchedule", "Illegal port ($port) given in portSchedule");
            }
        }
    }

    # Main scheduling loop for events occuring in the future.
    #
    sub scheduleLoop
    {
        my $current_time=time();

        # Loop through all the schedules, if any are active and expired, set the port.
        #
        for(my $idx=$MIN_PORT; $idx < $MAX_PORT; $idx++)
        {
            if(defined $PORT_CTRL[$idx] &&
               $PORT_CTRL[$idx]->{SCHEDULE}->{trigTime} != 0 &&
               $PORT_CTRL[$idx]->{SCHEDULE}->{trigTime} <= $current_time)
            {
                # Disable timer.
                #
                $PORT_CTRL[$idx]->{SCHEDULE}->{trigTime} = 0;

                # Set Port.
                #
                PortSet($idx, $PORT_CTRL[$idx]->{SCHEDULE}->{portValue}, 0);
                Utilities::log(4, MODULE, "scheduleLoop", "Setting Port ($idx) to $PORT_CTRL[$idx]->{SCHEDULE}->{portValue}");
            }
        }
    }

    # Main loop which executes all required U3SHIELD logic.
    #
    sub MainLoop
    {
        # Set port's according to timer parameters.
        #
        processTimedPorts();

        # Process any IP checking, 1 at a time due to length of time a check takes.
        #
        processCheckIP();

        # Set port's according to scheduled events.
        #
        scheduleLoop();

        # Periodically read inputs into the internal map.
        #
        readAllPorts();
    }


#################################################################################
# HTTP Functions - Methods for outputting/setting internal data via HTML.
#################################################################################

# Entry method to module for generation of module specifc HTML for display
# and configuration.
#
sub HTML_CreatePage
{
    # Parameters.
    #
    my ($http, $page, $allPorts) = @_;

    # Check Session parameters exist, create if necessary.
    #
    $http->{SESSION}->param('ActiveDevice',0) unless(defined $http->{SESSION}->param('ActiveDevice'));
    $http->{SESSION}->param('ActivePort',  0) unless(defined $http->{SESSION}->param('ActivePort'));
    $http->{SESSION}->param('SetOnApply',  0) unless(defined $http->{SESSION}->param('SetOnApply'));
    $http->{SESSION}->param('AutoRefresh', 0) unless(defined $http->{SESSION}->param('AutoRefresh'));

    # Process any POST data.
    #
    $http->{ERRMSG} = htmlProcessPOST_Data($http);

    # Call the relevant handling method according to requested page.
    #
    if($page eq "Get_PortData_Table")
    {
        htmlGetPortDataTable($http, $allPorts);
    }
    elsif($page eq "Get_Variables_Table")
    {
        htmlGetVariablesTable($http);
    }
    elsif($page eq "Get_Device_Log")
    {
        htmlGetDeviceLog($http);
    }
    elsif($page eq "Set_Outputs")
    {
        htmlSetOutputs($http);
    }
    elsif($page eq "Read_Inputs")
    {
        htmlReadInputs($http);
    }
    elsif($page eq "Config_Devices")
    {
        htmlConfigDevices($http);
    }
    elsif($page eq "Config_Ports")
    {
        htmlConfigPorts($http);
    }
    elsif($page eq "Config_Timers")
    {
        htmlConfigTimers($http);
    }
    elsif($page eq "Config_Ping")
    {
        htmlConfigPing($http);
    }

    # Return completed HTML to caller.
    #
    return($HTMLBUF);
}

# Method to take a buffer containing POST data and load it into internal structures, then execute
# any logic according to the POST request.
#
sub htmlProcessPOST_Data
{
    # Parameters.
    #
    my ($http) = @_;
    my ($errMsg, $device, $port) = ("", undef, undef);

    # Split the post data into pairs and process into internal structures.
    #
    my @varPairs = split(/&/, $http->{POSTDATA});
    my %params   = ();

    # Pre process POST data - remove encoding.
    #
    foreach my $name_value ( @varPairs )
    {
        my( $name, $value ) = split /=/, $name_value;

        $name =~ tr/+/ /;
        $name =~ s/%([\da-f][\da-f])/chr( hex($1) )/egi;
        
        $value = "" unless defined $value;
        $value =~ tr/+/ /;
        $value =~ s/%([\da-f][\da-f])/chr( hex($1) )/egi;
        
        $params{$name} = $value;
    }

    # Setup the device to which the post data is relevant.
    #
    if(defined $params{DEVICE})
    {
        $http->{SESSION}->param('ActiveDevice', $params{DEVICE});
        $device = 0 + $params{DEVICE};
		delete $params{DEVICE};
    }

    # Setup the port to which the post data is relevant.
    #
    if(defined $params{PORT})
    {
        $http->{SESSION}->param('ActivePort', $params{PORT});
        $port = 0 + $params{PORT};
		delete $params{PORT};
    }

    # Persistent parameters.
    #
    if(defined $params{SETONAPPLY})
    {
        $http->{SESSION}->param("SetOnApply", $params{SETONAPPLY});
		delete $params{SETONAPPLY};
    }
    if(defined $params{AUTOREFRESH})
    {
        $http->{SESSION}->param("AutoRefresh", $params{AUTOREFRESH});
		delete $params{AUTOREFRESH};
    }

    # For cancel operation, we just make a refresh of the active port data.
    #
    if(defined $params{ACTION} && $params{ACTION} eq "CANCEL")
    {
        # Clear persistence, reset to default.
        #
        $http->{SESSION}->param("SetOnApply", 0);
		delete $params{ACTION};
    }
    
    # For Apply or Save, we update internal variables. Save also commits to config file the new values.
    #
    elsif(defined $params{ACTION} && ($params{ACTION} eq "APPLY" || $params{ACTION} eq "SAVE" || $params{ACTION} eq "SETPORT"))
    {
        # Lock the child command buffer, mechanism to update the parents values.
        #
        lock($http->{CHLDCMDCNT});
        my $chldcnt = $http->{CHLDCMDCNT};

        # Update each variable in this thread's memory, then write the required command into an exec file for the
        # parent to issue such that the parent is updated.
        #
        foreach my $key (keys %params)
        {
            my $value  = $params{$key};
            my $pdx    = substr($key, rindex($key, '_')+1);
            my $keyNI  = substr($key, 0, rindex($key, '_'));  

			# Skip identifiers.
            #
			next if($params{$key} eq "APPLY" || $params{$key} eq "SAVE");

            # Verify that the PORT was given in the post.
            #
            if(defined $port)
            {
                if($key eq "OUTPUT_STATE")
                {
                    $PORT_CTRL[$port]->{$key} = $ON_OFF{$value};
                    $http->{CHLDCMDBUF}[$chldcnt] = "U3SHIELD::PortSet(" . $port . ", \"$value\", 0);";
                    $chldcnt++;
                }
                elsif(defined $PORT_CTRL[$port]->{$key})
                {
                    $PORT_CTRL[$port]->{$key} = $value;
                    $http->{CHLDCMDBUF}[$chldcnt] = "U3SHIELD::SetPortConfig($port, \"PORT_$key\", \"$value\");";
                    $chldcnt++;
                }
                elsif(Utilities::isInt($pdx) && defined $PORT_CTRL[$port]->{$keyNI}[$pdx])
                {
                    $PORT_CTRL[$port]->{$keyNI}[$pdx] = $value;
                    $http->{CHLDCMDBUF}[$chldcnt] = "U3SHIELD::SetPortConfig($port, \"PORT_$key\", \"$value\");";
                    $chldcnt++;
                }
            }
            elsif(defined $device)
            {
				# Skip Enabling device until very end.
                #
				next if($key eq "ENABLED");

				# Set the information up in this instance.
                #
                my ($rc, $value, $err) = SetDeviceConfig($device, "DEVICE_$key", "$value");
				$errMsg = sprintf("%s$err", $errMsg);

                # If device exists, then set it up in parent instance.
                #
                if(defined $DEVICE_CTRL[$device]->{$key})
                {
                    $http->{CHLDCMDBUF}[$chldcnt] = "U3SHIELD::SetDeviceConfig($device, \"DEVICE_$key\", \"$value\");";
                    $chldcnt++;
                }
				if($rc != 0)
				{
                    Utilities::log(1, MODULE, "htmlProcessPOST_Data", "Invalid POST for DEVICE:$device,VALUE:$value,KEY:$key,ErrorMsg:$errMsg");
                }
            }
            elsif($key eq "SETPORTS")
            {
                # setports=<port>:<value>;<port>:<value>;..... <port>:<value>
                #
                foreach my $portpair (split(/;/, $value))
                {
                    my ($setport, $rawvalue) = split(/:/, $portpair);
                    $value = -1;
                    $value = 0 if(lc($rawvalue) eq "off" || $rawvalue eq "0");
                    $value = 1 if(lc($rawvalue) eq "on"  || $rawvalue eq "1");

                    # Check parameters and if ok, process command.
                    #
                    if($setport < $MIN_PORT || $setport > $MAX_PORT || ! defined $PORT_CTRL[$setport])
                    {
                        $errMsg = sprintf("%sError: Port($setport) does not exist!\n", $errMsg);
                    }
                    elsif($value == -1)
                    {
                        $errMsg = sprintf("%sError: Value given ($rawvalue) is not valid for command.!\n", $errMsg);
                    } else
                    {
                        $PORT_CTRL[$setport]->{OUTPUT_STATE} = $value;
                        $http->{CHLDCMDBUF}[$chldcnt] = "U3SHIELD::PortSet($setport, \"$value\", 0);";
                        $chldcnt++;
                    }
                }
            } else
            {
                $errMsg = "POST command not recognised, no DEVICE or PORT number given";
            }
            #Utilities::log(1, MODULE, "htmlProcessPOST_Data", "Key=$key:Value=$value:KeyNI=$keyNI:pdx=$pdx:port=$port:ErrMsg=$errMsg");
        }

        # Only enable new device at end of config, because if all values not loaded, it wont enable.
		#
        if(defined $device && defined $params{ENABLED})
		{
            my ($rc, $value, $err) =  SetDeviceConfig($device, "DEVICE_ENABLED", "$params{ENABLED}");
			$errMsg = sprintf("%s$err", $errMsg);
            if(defined $DEVICE_CTRL[$device]->{ENABLED})
            {
                $http->{CHLDCMDBUF}[$chldcnt] = "U3SHIELD::SetDeviceConfig($device, \"DEVICE_ENABLED\", \"$params{ENABLED}\");";
                $chldcnt++;
            }
			if($rc != 0)
			{
                $DEVICE_CTRL[$device]->{ENABLED} = $sDISABLED;
			}
		}

        # If SAVE given as ACTION, save all variables into the config file.
        #
        if($params{ACTION} eq "SAVE")
        {
            lock($http->{CHLDCMDCNT});
            $http->{CHLDCMDBUF}[$chldcnt] = "writeParams();";
            $chldcnt++;
        }

        # If no errors occured (errMsg buf empty), update child command counter before freeing lock.
        #
		if($errMsg eq "")
		{
            $http->{CHLDCMDCNT} = $chldcnt;
		}
    }
    return($errMsg);
}

# Function to place all the Port Data into an HTML Table for display in a web page.
#
sub htmlGetPortDataTable
{
    # Parameters.
    #
    my ($http, $allPorts) = @_;

    # Build up the table subdivided into connected devices.
    #
    $HTMLBUF=<<"EOF";
              <!-- page start-->
              <div class="row">
                  <div class="col-sm-12">
EOF

    # For each connected device, output port configuration.
    #
    for(my $dvc=MIN_DEVICE_LIMIT; $dvc < MAX_DEVICE_LIMIT; $dvc++)
    {
        next if(not defined $DEVICE_CTRL[$dvc]->{ENABLED});
        next if($DEVICE_CTRL[$dvc]->{ENABLED} ne $sENABLED);

        $HTMLBUF = $HTMLBUF . <<"EOF";
                      <section class="panel">
                          <header class="panel-heading">
                             <strong>DEVICE $dvc ($DEVICE_CTRL[$dvc]->{NAME} - $DEVICE_CTRL[$dvc]->{DESCRIPTION}) Configuration</strong>
                              <span class="tools pull-right">
                                 <a href="javascript:;" class="fa fa-chevron-down"></a>
                                 <a href="javascript:;" class="fa fa-times"></a>
                              </span>
                          </header>
                          <div class="panel-body">
                              <div class="adv-table">
                                  <table  class="display table table-bordered table-striped" id="dynamic-nofrills-table">
                                      <thead>
                                          <tr>
                                              <th>PORT</th>
                                              <th>NAME</th>
                                              <th>DESCRIPTION</th>
                                              <th>ENABLED?</th>
                                              <th>MODE</th>
                                              <th class="hidden-phone">VALUE</th>
                                          </tr>
                                      </thead>
                                      <tbody>
EOF

        # Build list of in-use ports so user can see what is valid.
        #
        for(my $idx=$DEVICE_CTRL[$dvc]->{PORT_MIN}; $idx <= $DEVICE_CTRL[$dvc]->{PORT_MAX}; $idx++)
        {
            if(($allPorts == 0 && isEnabledPort($idx)) || $allPorts == 1)
            {
                $HTMLBUF = sprintf("%s  <tr>\n",           $HTMLBUF);
                $HTMLBUF = sprintf("%s    <td>%02d</td>",  $HTMLBUF, $idx);
                $HTMLBUF = sprintf("%s    <td>%-20s</td>", $HTMLBUF, $PORT_CTRL[$idx]->{NAME});
                $HTMLBUF = sprintf("%s    <td>%-40s</td>", $HTMLBUF, $PORT_CTRL[$idx]->{DESCRIPTION});
                $HTMLBUF = sprintf("%s    <td>%-6s</td>",  $HTMLBUF, $PORT_CTRL[$idx]->{ENABLED});
                $HTMLBUF = sprintf("%s    <td>%-10s</td>", $HTMLBUF, $PORT_CTRL[$idx]->{MODE});
                $HTMLBUF = sprintf("%s    <td>%-6s</td>",  $HTMLBUF, $ON_OFF{GetPortValue($idx)});
                $HTMLBUF = sprintf("%s  </tr>\n",          $HTMLBUF);
            }
        }

        # Finalise table.
        #
        $HTMLBUF = $HTMLBUF . <<"EOF";
                                      </tbody>
                                  </table>
                              </div>
                          </div>
                      </section>
EOF
    }

    # Finalise HTML response..
    #
    $HTMLBUF = $HTMLBUF . <<"EOF";
                  </div>
              </div>
EOF
}

# Function to place the device log of this module into an HTML table for inclusion in a web page.
#
sub htmlGetDeviceLog
{
    # Parameters.
    #
    my ($http) = @_;

    # Get a snapshot of the current log file.
    #
    my $logsnap;
    if(sysopen(SP, $LOGFILE, 0))
    {
        seek(SP, -10000, 2);
        undef $/;
        $logsnap = <SP>;
        $logsnap =~ s/^[^\n]+\n//s if (length($logsnap) > 9999);
        close(SP);
    }

    # Finish off the html before sending.
    #
    $HTMLBUF = $HTMLBUF . <<"EOF";
              <!-- page start-->
              <div class="row">
                  <div class="col-sm-12">
                      <section class="panel">
                          <header class="panel-heading">
                             <strong>U3SHIELD Log</strong>
                              <span class="tools pull-right">
                                 <a href="javascript:;" class="fa fa-chevron-down"></a>
                                 <a href="javascript:;" class="fa fa-times"></a>
                              </span>
                          </header>
                          <div class="panel-body">
                              <div class="adv-table">
                                  <table  class="display table table-bordered table-striped" id="dynamic-nofrills-table">
                                      <tbody>
                                          <tr>
                                              <td>
                                                  <form action = "/getpage" method = "post">
                                                      <textarea name = "bletch" rows = "30" cols = "132">$logsnap</textarea>
                                                  </form>
                                              </td>
                                          </tr>
                                      </tbody>
                                  </table>
                              </div>
                          </div>
                      </section>
                  </div>
              </div>
EOF

    # Return completed HTML to caller.
    #
    return $HTMLBUF;
}

# Function to place all the internal variables of this module into an HTML table for
# inclusion in a web page.
#
sub htmlGetVariablesTable
{
    # Parameters.
    #
    my ($http) = @_;

    # Get a snapshot of the current log file.
    #
    my $logsnap;
    if(sysopen(SP, $LOGFILE, 0))
    {
        seek(SP, -5000, 2);
        undef $/;
        $logsnap = <SP>;
        $logsnap =~ s/^[^\n]+\n//s if (length($logsnap) > 4999);
        close(SP);
    }
    
    # Build a table to hold the variables to be displayed.
    #
    $HTMLBUF = <<"EOF";
              <!-- page start-->
              <div class="row">
                  <div class="col-sm-12">
                      <section class="panel">
                          <header class="panel-heading">
                             <strong>General U3 Configuration</strong>
                              <span class="tools pull-right">
                                 <a href="javascript:;" class="fa fa-chevron-down"></a>
                                 <a href="javascript:;" class="fa fa-times"></a>
                              </span>
                          </header>
                          <div class="panel-body">
                              <div class="adv-table">
                                  <table  class="display table table-bordered table-striped" id="dynamic-nofrills-table">
                                      <thead>
                                          <tr>
                                              <th>LOGFILE</th>
                                          </tr>
                                      </thead>
                                      <tbody>
                                          <tr>
                                              <td align="left"><font size="2">$LOGFILE</font></td>
                                          </tr>
                                      </tbody>
                                  </table> 
                              </div>
                          </div>
                      </section>
EOF

    # For each connected device, output port configuration.
    #
    for(my $dvc=MIN_DEVICE_LIMIT; $dvc < MAX_DEVICE_LIMIT; $dvc++)
    {
        next if(not defined $DEVICE_CTRL[$dvc]->{ENABLED});
        next if($DEVICE_CTRL[$dvc]->{ENABLED} ne $sENABLED);

        $HTMLBUF = $HTMLBUF . <<"EOF";
                      <section class="panel">
                          <header class="panel-heading">
                             <strong>DEVICE $dvc ($DEVICE_CTRL[$dvc]->{NAME} - $DEVICE_CTRL[$dvc]->{DESCRIPTION}) Configuration</strong>
                              <span class="tools pull-right">
                                 <a href="javascript:;" class="fa fa-chevron-down"></a>
                                 <a href="javascript:;" class="fa fa-times"></a>
                              </span>
                          </header>
                          <div class="panel-body">
                              <div class="adv-table">
                                  <table  class="display table table-bordered table-striped" id="dynamic-nofrills-table">
                                      <thead>
                                          <tr>
                                              <th>TYPE</th>
                                              <th>NAME</th>
                                              <th>DESCRIPTION</th>
                                              <th>MIN PORT</th>
                                              <th>MAX PORT</th>
                                              <th>BASE ADDR</th>
                                              <th>UART DEVICE</th>
                                              <th>UART BAUD</th>
                                              <th>UART DATABITS</th>
                                              <th>UART PARITY</th>
                                              <th>UART STOPBITS</th>
                                          </tr>
                                      </thead>
                                      <tbody>
EOF

        $HTMLBUF = sprintf("%s  <tr>\n",           $HTMLBUF);
        $HTMLBUF = sprintf("%s    <td>%-10s</td>", $HTMLBUF, $DEVICE_CTRL[$dvc]->{TYPE});
        $HTMLBUF = sprintf("%s    <td>%-20s</td>", $HTMLBUF, $DEVICE_CTRL[$dvc]->{NAME});
        $HTMLBUF = sprintf("%s    <td>%-20s</td>", $HTMLBUF, $DEVICE_CTRL[$dvc]->{DESCRIPTION});
        $HTMLBUF = sprintf("%s    <td>%-5s</td>",  $HTMLBUF, $DEVICE_CTRL[$dvc]->{PORT_MIN});
        $HTMLBUF = sprintf("%s    <td>%-5s</td>",  $HTMLBUF, $DEVICE_CTRL[$dvc]->{PORT_MAX});
        $HTMLBUF = sprintf("%s    <td>%-5s</td>",  $HTMLBUF, $DEVICE_CTRL[$dvc]->{BASE_ADDR});
        $HTMLBUF = sprintf("%s    <td>%-20s</td>", $HTMLBUF, $DEVICE_CTRL[$dvc]->{UART});
        $HTMLBUF = sprintf("%s    <td>%-6s</td>",  $HTMLBUF, $DEVICE_CTRL[$dvc]->{UART_BAUD});
        $HTMLBUF = sprintf("%s    <td>%-5s</td>",  $HTMLBUF, $DEVICE_CTRL[$dvc]->{UART_DATABITS});
        $HTMLBUF = sprintf("%s    <td>%-8s</td>",  $HTMLBUF, $DEVICE_CTRL[$dvc]->{UART_PARITY});
        $HTMLBUF = sprintf("%s    <td>%-5s</td>",  $HTMLBUF, $DEVICE_CTRL[$dvc]->{UART_STOPBITS});
        $HTMLBUF = sprintf("%s  </tr>\n",          $HTMLBUF);

        # Finalise table.
        #
        $HTMLBUF = $HTMLBUF . <<"EOF";
                                      </tbody>
                                  </table>
                              </div>
                          </div>
EOF

        $HTMLBUF = $HTMLBUF . <<"EOF";
                          <div class="panel-body">
                              <section class="panel">
                                  <header class="panel-heading tab-bg-dark-navy-blue ">
                                      <ul class="nav nav-tabs">
EOF

        for(my $idx=$DEVICE_CTRL[$dvc]->{PORT_MIN}; $idx <= $DEVICE_CTRL[$dvc]->{PORT_MAX}; $idx+=1)
        {
            if($idx == $DEVICE_CTRL[$dvc]->{PORT_MIN})
            {
                $HTMLBUF = $HTMLBUF . <<"EOF";
                                          <li class="active">
                                              <a data-toggle="tab" href="#TAB${idx}">${idx}</a>
                                          </li>
EOF
            } else
            {
                $HTMLBUF = $HTMLBUF . <<"EOF";
                                          <li class="">
                                              <a data-toggle="tab" href="#TAB${idx}">${idx}</a>
                                          </li>
EOF
            }
        }
        $HTMLBUF = $HTMLBUF . <<"EOF";
                                      </ul>
                                  </header>
                                  <div class="panel-body">
                                      <div class="tab-content">
EOF
        for(my $idx=$DEVICE_CTRL[$dvc]->{PORT_MIN}; $idx <= $DEVICE_CTRL[$dvc]->{PORT_MAX}; $idx+=1)
        {
            if($idx == $DEVICE_CTRL[$dvc]->{PORT_MIN})
            {
                $HTMLBUF = $HTMLBUF . <<"EOF";
                                          <div id="TAB${idx}" class="tab-pane active">
EOF
            } else
            {
                $HTMLBUF = $HTMLBUF . <<"EOF";
                                          <div id="TAB${idx}" class="tab-pane">
EOF
            }
            $HTMLBUF = $HTMLBUF . <<"EOF";
                                              <div class="panel-body">
                                                  <div class="adv-table">
                                                      <table  class="display table table-bordered table-striped" id="dynamic-nofrills-table">
                                                          <thead>
                                                              <tr>
                                                                  <th width="30%">ENABLED</th>
                                                                  <td>$PORT_CTRL[$idx]->{ENABLED}</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>NAME</th>
                                                                  <td>$PORT_CTRL[$idx]->{NAME}</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>DESCRIPTION</th>
                                                                  <td>$PORT_CTRL[$idx]->{DESCRIPTION}</td>
                                                              </tr>
                                                              <tr>
                                                                  <th width="30%">LOCKED</th>
                                                                  <td>$PORT_CTRL[$idx]->{IS_LOCKED}</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>MODE</th>
                                                                  <td>$PORT_CTRL[$idx]->{MODE}</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>POWERUPSTATE</th>
                                                                  <td>$PORT_CTRL[$idx]->{POWERUPSTATE}</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>POWERDOWNSTATE</th>
                                                                  <td>$PORT_CTRL[$idx]->{POWERDOWNSTATE}</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>ON_STATE_VALUE</th>
                                                                  <td>$PORT_CTRL[$idx]->{ON_STATE_VALUE}</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>OFF_STATE_VALUE</th>
                                                                  <td>$PORT_CTRL[$idx]->{OFF_STATE_VALUE}</td>
                                                              </tr>
EOF
            for(my $pdx=MIN_TIMER_LIMIT; $pdx <= MAX_TIMER_LIMIT; $pdx++)
            {
                $HTMLBUF = $HTMLBUF . <<"EOF";
                                                              <tr>
                                                                  <th>ON_TIME_${pdx}</th>
                                                                  <td>$PORT_CTRL[$idx]->{ON_TIME}[$pdx]</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>ON_TIME_ENABLE_${pdx}</th>
                                                                  <td>$PORT_CTRL[$idx]->{ON_TIME_ENABLE}[$pdx]</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>OFF_TIME_${pdx}</th>
                                                                  <td>$PORT_CTRL[$idx]->{OFF_TIME}[$pdx]</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>OFF_TIME_ENABLE_${pdx}</th>
                                                                  <td>$PORT_CTRL[$idx]->{OFF_TIME_ENABLE}[$pdx]</td>
                                                              </tr>
EOF
            }

            for(my $pdx=MIN_PING_LIMIT; $pdx <= MAX_PING_LIMIT; $pdx++)
            {
                $HTMLBUF = $HTMLBUF . <<"EOF";
                                                              <tr>
                                                                  <th>PING_ENABLE ${pdx}</th>
                                                                  <td>$PORT_CTRL[$idx]->{PING_ENABLE}[$pdx]</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>PING_ADDR_${pdx}</th>
                                                                  <td>$PORT_CTRL[$idx]->{PING_ADDR}[$pdx]</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>PING_TYPE_${pdx}</th>
                                                                  <td>$PORT_CTRL[$idx]->{PING_TYPE}[$pdx]</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>PING_ADDR_WAIT_TIME_${pdx}</th>
                                                                  <td>$PORT_CTRL[$idx]->{PING_ADDR_WAIT_TIME}[$pdx]</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>PING_TO_PING_TIME_${pdx}</th>
                                                                  <td>$PORT_CTRL[$idx]->{PING_TO_PING_TIME}[$pdx]</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>PING_FAIL_COUNT_${pdx}</th>
                                                                  <td>$PORT_CTRL[$idx]->{PING_FAIL_COUNT}[$pdx]</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>PING_SUCCESS_COUNT_${pdx}</th>
                                                                  <td>$PORT_CTRL[$idx]->{PING_SUCCESS_COUNT}[$pdx]</td>
                                                              </tr>
EOF
            }

            $HTMLBUF = $HTMLBUF . <<"EOF";
                                                              <tr>
                                                                  <th>PING_LOGIC_FOR_FAIL</th>
                                                                  <td>$PORT_CTRL[$idx]->{PING_LOGIC_FOR_FAIL}</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>PING_LOGIC_FOR_SUCCESS</th>
                                                                  <td>$PORT_CTRL[$idx]->{PING_LOGIC_FOR_SUCCESS}</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>PING_ACTION_ON_FAIL</th>
                                                                  <td>$PORT_CTRL[$idx]->{PING_ACTION_ON_FAIL}</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>PING_ACTION_ON_SUCCESS</th>
                                                                  <td>$PORT_CTRL[$idx]->{PING_ACTION_ON_SUCCESS}</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>PING_ACTION_SUCCESS_TIME</th>
                                                                  <td>$PORT_CTRL[$idx]->{PING_ACTION_SUCCESS_TIME}</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>PING_ACTION_FAIL_TIME</th>
                                                                  <td>$PORT_CTRL[$idx]->{PING_ACTION_FAIL_TIME}</td>
                                                              </tr>
                                                              <tr>
                                                                  <th>RESET_TIME</th>
                                                                  <td>$PORT_CTRL[$idx]->{RESET_TIME}</td>
                                                              </tr>
                                                          </thead>
                                                      </table>
                                                  </div>
                                              </div>
                                          </div>
EOF
        }

        $HTMLBUF = $HTMLBUF . <<"EOF";
                                      </div>
                                  </div>
                          </section>
                      </div>
                    </section>
EOF
    }

    # Finish off the html before sending.
    #
    $HTMLBUF = $HTMLBUF . <<"EOF";
                  </div>
              </div>
EOF
}

# Function to create the HTML which allows a user to set the state of all active output ports.
#
sub htmlSetOutputs
{
    # Parameters.
    #
    my ($http) = @_;
    my ($errMsg) = ("");

    # Get current time for display.
    #
    my $currentTime = Utilities::getCurrentDate('DD/MM/YYYY hh:mm:ss');

    # Build a table to hold the variables to be displayed.
    #
    $HTMLBUF = <<"               EOF";
              <!-- page start-->
              <div class="row">
                <div class="col-sm-12">
                  <section class="panel">
                    <header class="panel-heading">
                      <div class="row">
                        <div class="col-lg-2">
                          <strong>Set Port Output State</strong>
                        </div>
                        <span class="tools pull-right">
                          <a href="javascript:;" class="fa fa-chevron-down"></a>
                          <a href="javascript:;" class="fa fa-times"></a>
                        </span>
                      </div>
                    </header>
                    <div class="panel-body">
                      <form class="form=horizontal tasi-form" method="post" id="id_formOutputState">
                        <div class="adv-table">
                          <table  class="display table table-bordered table-striped" id="dynamic-nofrills-table">
                            <thead>
                              <tr>
               EOF

    # Get a tally of the number of active ports which are outputs.
    #
    my $activePortCount = 0;
    for(my $idx=$MIN_PORT; $idx <= $MAX_PORT; $idx++)
    {
        if(isEnabledPort($idx) && isOutputPort($idx)) { $activePortCount++; }
    }

    # Output table header.
    #
    for(my $colCount=0; $colCount < ($activePortCount < 2 ? 1 : 2); $colCount++)
    {
        $HTMLBUF .= <<"                    EOF";
                                <th style="text-align:left;font-weight:bold;" width="6%">PORT #</th>
                                <th style="text-align:left;font-weight:bold;" width="13%">NAME</th>
                                <th style="text-align:left;font-weight:bold;" width="22%">DESCRIPTION</th>
                                <th style="text-align:center;font-weight:bold;" width="9%">OFF/ON</th>
                    EOF
    }
    $HTMLBUF .= <<"                EOF";
                              </tr>
                            </thead>
                            <tbody>
                EOF

    # Build list of in-use ports so user can see what is valid.
    #
    my $colCount = -1;
    for(my $idx=$MIN_PORT; $idx <= $MAX_PORT; $idx++)
    {
        if(isEnabledPort($idx) && isOutputPort($idx))
        {
            if($colCount == -1)
            {
                $HTMLBUF .= <<"                            EOF";
                              <tr>
                            EOF
                $colCount = 0;
            }

            $HTMLBUF .= <<"                        EOF";
                                <td style="text-align:center;font-weight:bold;">${idx}</td>
                                <td>$PORT_CTRL[$idx]->{NAME}</td>
                                <td>$PORT_CTRL[$idx]->{DESCRIPTION}</td>
                                <td style="text-align:center;">
                                  <div class="btn-group btn-toggle output-selector" id="id_ifOutputState_${idx}"
                                       value="$ON_OFF{$PORT_CTRL[${idx}]->{OUTPUT_STATE}}"> 
                        EOF

            if($PORT_CTRL[$idx]->{OUTPUT_STATE} eq $iOFF)
            {
                $HTMLBUF .= <<"                            EOF";
                                    <button class="btn btn-round btn-green btn-xs active" 
                                            id="id_ifOutputState_OFF_${idx}">
                                            $ON_OFF{$PORT_CTRL[$idx]->{OUTPUT_STATE}}
                                    </button>
                                    <button class="btn btn-round btn-grey btn-xs" 
                                            id="id_ifOutputState_ON_${idx}">
                                            $ON_OFF{$iON}
                                    </button>
                            EOF
            } else
            {
                $HTMLBUF .= <<"                            EOF";
                                    <button class="btn btn-round btn-grey btn-xs" 
                                            id="id_ifOutputState_OFF_${idx}">
                                            $ON_OFF{$iOFF}
                                    </button>
                                    <button class="btn btn-round btn-green btn-xs active" 
                                            id="id_ifOutputState_ON_${idx}">
                                            $ON_OFF{$PORT_CTRL[$idx]->{OUTPUT_STATE}}
                                    </button>
                            EOF
            }

            $HTMLBUF .= <<"                        EOF";
                                  </div>
                                </td>
                        EOF
            $colCount++;
        }

        if($colCount >= 2)
        {
            $HTMLBUF .= <<"                        EOF";
                              </tr>
                        EOF
            $colCount = -1;
        }
    }
    if($colCount != -1)
    {
        $HTMLBUF .= <<"                    EOF";
                              </tr>
                    EOF
    }

    # Finalise table.
    #
    my $setAllOnApplyChecked  = $http->{SESSION}->param('SetOnApply') == 1 ? "checked" : "";
    my $autoRefreshChecked    = $http->{SESSION}->param('AutoRefresh') == 1 ? "checked" : "";
    my $autoRefreshDisabled   = $http->{SESSION}->param('AutoRefresh') == 1 ? "disabled" : "";
    my $disabled = $http->{SESSION}->param('SetOnApply') == 1 ? "" : "disabled";
    $HTMLBUF = $HTMLBUF . <<"                          EOF";
                            </tbody>
                          </table>
                        </div>
                      </form>
                    </div>
                    <div class="panel-body">
                      <div class="row">
                        <div class="col-lg-8">
                          <div class="col-lg-4">
                            <form class="form=horizontal tasi-form" method="post" id="id_formSetPortSubmit">
                              <button class="btn btn-cyan btn-sm m-bot15 $disabled" type="submit" value="APPLY" id="id_ifConfigApply">
                                Apply
                              </button>
                              <button class="btn btn-blue btn-sm m-bot15 $autoRefreshDisabled" type="submit" value="REFRESH" id="id_ifConfigRefresh">
                                Refresh
                              </button>
                              <button class="btn btn-red active btn-sm m-bot15 $disabled" type="submit" value="CANCEL" id="id_ifConfigCancel">
                                Cancel
                              </button>
                            </form>
                          </div>
                          <div class="col-lg-6" id="id_ifControlMsg" value="$sUNLOCKED">
                            $errMsg
                          </div>
                        </div>
                      </div>
                      <div class="row">
                        <div class="col-lg-6">
                        <!--  <section class="panel"> -->
                          <div class="col-sm-3">
                            <input type="checkbox" class="m-bot15" id="id_ifAutoRefresh" $autoRefreshChecked>
                              &nbsp Auto Refresh
                          </div>
                          <div class="col-sm-4">
                            <input type="checkbox" class="m-bot15" id="id_ifSetAllOnApply" $setAllOnApplyChecked>
                              &nbsp Set All Changes On Apply
                          </div>
                       <!--   </section> -->
                        </div>
                      </div>
                    </div>
                  </section>
                </div>
              </div>
                          EOF
}

# Function to create the HTML which allows a user to read all the states of configured input ports.
#
sub htmlReadInputs
{
    # Parameters.
    #
    my ($http) = @_;
    my ($errMsg) = ("");

    # Get current time for display.
    #
    my $currentTime = Utilities::getCurrentDate('DD/MM/YYYY hh:mm:ss');

    # Build a table to hold the variables to be displayed.
    #
    $HTMLBUF = <<"               EOF";
              <!-- page start-->
              <div class="row">
                <div class="col-sm-12">
                  <section class="panel">
                    <header class="panel-heading">
                      <div class="row">
                        <div class="col-lg-2">
                          <strong>Read Port Input State</strong>
                        </div>
                        <span class="tools pull-right">
                          <a href="javascript:;" class="fa fa-chevron-down"></a>
                          <a href="javascript:;" class="fa fa-times"></a>
                        </span>
                      </div>
                    </header>
                    <div class="panel-body">
                        <div class="adv-table">
                          <table  class="display table table-bordered table-striped" id="dynamic-nofrills-table">
                            <thead>
                              <tr>
               EOF

    # Get a tally of the number of active ports which are outputs.
    #
    my $activePortCount = 0;
    for(my $idx=$MIN_PORT; $idx <= $MAX_PORT; $idx++)
    {
        if(isEnabledPort($idx) && isOutputPort($idx)) { $activePortCount++; }
    }

    # Output table header.
    #
    for(my $colCount=0; $colCount < ($activePortCount < 2 ? 1 : 2); $colCount++)
    {
        $HTMLBUF .= <<"                    EOF";
                                <th style="text-align:left;font-weight:bold;" width="6%">PORT #</th>
                                <th style="text-align:left;font-weight:bold;" width="13%">NAME</th>
                                <th style="text-align:left;font-weight:bold;" width="22%">DESCRIPTION</th>
                                <th style="text-align:center;font-weight:bold;" width="9%">OFF/ON</th>
                    EOF
    }
    $HTMLBUF .= <<"                EOF";
                              </tr>
                            </thead>
                            <tbody>
                EOF

    # Build list of in-use ports so user can see what is valid.
    #
    my $colCount = -1;
    for(my $idx=$MIN_PORT; $idx <= $MAX_PORT; $idx++)
    {
        if(isEnabledPort($idx) && isInputPort($idx))
        {
            if($colCount == -1)
            {
                $HTMLBUF .= <<"                            EOF";
                              <tr>
                            EOF
                $colCount = 0;
            }

            $HTMLBUF .= <<"                        EOF";
                                <td style="text-align:center;font-weight:bold;">${idx}</td>
                                <td>$PORT_CTRL[$idx]->{NAME}</td>
                                <td>$PORT_CTRL[$idx]->{DESCRIPTION}</td>
                                <td style="text-align:center;">
                                  <div class="btn-group btn-toggle" id="id_ifInputState_${idx}"
                                       value="$ON_OFF{$PORT_CTRL[${idx}]->{INPUT_STATE}}"> 
                        EOF

            if($PORT_CTRL[$idx]->{INPUT_STATE} eq $iOFF)
            {
                $HTMLBUF .= <<"                            EOF";
                                    <button class="btn btn-round btn-green btn-xs active" 
                                            id="id_ifInputState_OFF_${idx}">
                                            $ON_OFF{$PORT_CTRL[$idx]->{INPUT_STATE}}
                                    </button>
                                    <button class="btn btn-round btn-grey btn-xs" 
                                            id="id_ifInputState_ON_${idx}">
                                            $ON_OFF{$iON}
                                    </button>
                            EOF
            } else
            {
                $HTMLBUF .= <<"                            EOF";
                                    <button class="btn btn-round btn-grey btn-xs" 
                                            id="id_ifInputState_OFF_${idx}">
                                            $ON_OFF{$iOFF}
                                    </button>
                                    <button class="btn btn-round btn-green btn-xs active" 
                                            id="id_ifInputState_ON_${idx}">
                                            $ON_OFF{$PORT_CTRL[$idx]->{INPUT_STATE}}
                                    </button>
                            EOF
            }

            $HTMLBUF .= <<"                        EOF";
                                  </div>
                                </td>
                        EOF
            $colCount++;
        }

        if($colCount >= 2)
        {
            $HTMLBUF .= <<"                        EOF";
                              </tr>
                        EOF
            $colCount = -1;
        }
    }
    if($colCount != -1)
    {
        $HTMLBUF .= <<"                    EOF";
                              </tr>
                    EOF
    }

    # Finalise table.
    #
    my $autoRefreshChecked  = ($http->{SESSION}->param('AutoRefresh') == 1) ? "checked" : "";
    my $autoRefreshDisabled = ($http->{SESSION}->param('AutoRefresh') == 1) ? "disabled" : "";
    $HTMLBUF = $HTMLBUF . <<"                          EOF";
                            </tbody>
                          </table>
                        </div>
                    </div>
                    <div class="panel-body">
                      <div class="row">
                        <div class="col-lg-8">
                          <div class="col-lg-4">
                            <form class="form=horizontal tasi-form" method="post" id="id_formSetPortSubmit">
                              <button class="btn btn-blue btn-sm m-bot15 $autoRefreshDisabled" type="submit" value="REFRESH" id="id_ifConfigRefresh">
                                Refresh
                              </button>
                            </form>
                          </div>
                          <div class="col-lg-6" id="id_ifControlMsg" value="$sUNLOCKED">
                            $errMsg
                          </div>
                        </div>
                      </div>
                      <div class="row">
                        <div class="col-lg-6">
                          <div class="col-sm-3">
                            <input type="checkbox" class="m-bot15" id="id_ifAutoRefresh" $autoRefreshChecked>
                              &nbsp Auto Refresh
                          </div>
                        </div>
                      </div>
                    </div>
                  </section>
                </div>
              </div>
                          EOF
}

# Function to create the HTML which allows a user to configure the internal device setup.
#
sub htmlConfigDevices
{
    # Parameters.
    #
    my ($http) = @_;

    # Active Port.
    #
    my $activeDevice=$http->{SESSION}->param('ActiveDevice');

    # Build a table to hold the variables to be displayed.
    #
    $HTMLBUF = <<"               EOF";
              <!-- page start-->
              <div class="row">
                <div class="col-sm-12">
                  <section class="panel">
                    <header class="panel-heading">
                      <strong>Setup Device</strong>
                      <span class="tools pull-right">
                        <a href="javascript:;" class="fa fa-chevron-down"></a>
                        <a href="javascript:;" class="fa fa-times"></a>
                      </span>
                    </header>
                    <div class="panel-body">
                      <section class="panel">
                        <div class="col-sm-12">
                          <section class="panel">
                            <form method="post" id="id_formSelectConfig">
                              <div class="row">
                                <div class="form-group">
                                  <label class="col-sm-DEVICE control-label col-lg-2">DEVICE NUMBER</label>
                                  <div class="col-lg-10">
                                    <div class="btn-row">
                                      <div class="btn-toolbar">
                                        <div class="btn-group-xs m-bot15" id="id_divDeviceSelect" value="$activeDevice">
               EOF

    # For each possible device, output port configuration.
    #
    for(my $dvc=MIN_DEVICE_LIMIT; $dvc < MAX_DEVICE_LIMIT; $dvc++)
    {
        my $num=sprintf("%02d", $dvc);
        my $active = (defined $DEVICE_CTRL[$dvc]->{ENABLED} &&
                      $DEVICE_CTRL[$dvc]->{ENABLED} eq $sENABLED) ? "active" : "";

        if($dvc == $activeDevice)
        {
            $HTMLBUF .= <<"                            EOF";
                                          <label class="btn active">
                                            <button type="button" class="btn btn-green btn-xs active" name="device" value="$num"
                                                    id="id_ifDeviceButton$num">
                                                    $num
                                            </button>
                                          </label>
                            EOF
        } else
        {
            $HTMLBUF .= <<"                            EOF";
                                          <label class="btn ">
                                            <button type="button" class="btn btn-grey $active btn-xs" name="device" value="$num"
                                                    id="id_ifDeviceButton$num">
                                                    $num
                                            </button>
                                          </label>
                            EOF
        }
    }

    # If this device is not configured, set it up with default information.
    #
	my ($minport, $maxport, $minbase, $maxbase, $enabled) = ((defined $DEVICE_CTRL[$activeDevice]->{PORT_MIN} ? $DEVICE_CTRL[$activeDevice]->{PORT_MIN} : $MAX_PORT + 1), MAX_PORT_LIMIT -1, MIN_BASE_ADDR, MAX_BASE_ADDR, (defined $DEVICE_CTRL[$activeDevice]->{ENABLED} ? "$DEVICE_CTRL[$activeDevice]->{ENABLED}" : "DISABLED"));
    if(! defined($DEVICE_CTRL[$activeDevice]->{ENABLED}))
    {
        my ($rc, $value, $err) = SetDeviceConfig($activeDevice, "DEVICE_PORT_MIN", $MAX_PORT + 1);
		$http->{ERRMSG} = sprintf("%s\n$err", $http->{ERRMSG});
        SetDeviceConfig($activeDevice, "DEVICE_PORT_MAX", $MAX_PORT + 1);
		$http->{ERRMSG} = sprintf("%s\n$err", $http->{ERRMSG});
    }

    $HTMLBUF .= <<"                EOF";
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </form>
                          </section>
                        </div>
                        <div class="col-sm-12">
                          <section class="panel">
                            <form class="form=horizontal tasi-form device-config" method="post" name="deviceDataConfig" id="id_formConfig_DEVICE">
                              <div class="form-group">
                                <div class="row">
                                  <label class="col-sm-2 control-label col-lg-2">DEVICE IS</label>
                                  <div class="col-lg-10">
                                    <button class="btn btn-round btn-green btn-sm m-bot15" id="id_ifDeviceState"
                                            value="$enabled" >
                                            $enabled
                                    </button>
                                  </div>
                                </div>
                                <div id="deviceState">
                                  <div class="row">
                                    <label class="col-sm-2 control-label col-lg-2">TYPE OF DEVICE</label>
                                    <div class="col-lg-3 btn-group btn-toggle" id="id_divDeviceType" value="$DEVICE_CTRL[$activeDevice]->{TYPE}">
                EOF

    foreach my $key (sort {$DEVICE_TYPES{$a} <=> $DEVICE_TYPES{$b}} (keys %DEVICE_TYPES))
    {
         my $active = $DEVICE_CTRL[$activeDevice]->{TYPE} eq $key ? "btn-green active" : "btn-grey";

        $HTMLBUF .= <<"                EOF";
                                      <button class="btn btn-round btn-green btn-sm $active m-bot15" data-target="#id_divDeviceType_$key" 
                                              value="$key" id="id_ifDeviceType_$key">
                                              $key
                                      </button>
                EOF
    } 

    $HTMLBUF .= <<"                EOF";
                                    </div>
                                  </div>
                                  <div class="row">
                                    <label class="col-sm-2 control-label col-lg-2">NAME</label>
                                    <div class="col-lg-6">
                                      <input type="text" class="form-control round-input m-bot15"
                                             value="$DEVICE_CTRL[$activeDevice]->{NAME}"
                                             id="id_ifDeviceName" />
                                    </div>
                                  </div>
                                  <div class="row">
                                    <label class="col-sm-2 control-label col-lg-2">DESCRIPTION</label>
                                    <div class="col-lg-6">
                                      <input type="text" class="form-control round-input m-bot15"
                                             value="$DEVICE_CTRL[$activeDevice]->{DESCRIPTION}"
                                             id="id_ifDeviceDescription" />
                                    </div>
                                  </div>
                                  <div class="row">
                                    <label class="col-sm-2 control-label col-lg-2">PORT MIN</label>
                                    <div class="col-sm-2">
                                      <input type="text" class="form-control round-input m-bot15 port-value-check"
                                             value_start="$DEVICE_CTRL[$activeDevice]->{PORT_MIN}"
											 value_min="${minport}"
											 value_max="${maxport}"
                                             value="$DEVICE_CTRL[$activeDevice]->{PORT_MIN}"
                                             id="id_ifDevicePortMin" />
                                    </div>
                                    <div class="col-sm-4">
                                      <div class="panel-body" id="id_ifDeviceMinPort" value="${minport}">
									  Minimum port ${minport}
                                      </div>
                                    </div>
                                  </div>
                                  <div class="row">
                                    <label class="col-sm-2 control-label col-lg-2">PORT MAX</label>
                                    <div class="col-sm-2">
                                      <input type="text" class="form-control round-input m-bot15 port-value-check"
                                             value_start="$DEVICE_CTRL[$activeDevice]->{PORT_MAX}"
											 value_min="${minport}"
											 value_max="${maxport}"
                                             value="$DEVICE_CTRL[$activeDevice]->{PORT_MAX}"
                                             id="id_ifDevicePortMax" />
                                    </div>
                                    <div class="col-sm-4">
                                      <div class="panel-body" id="id_ifDeviceMaxPort" value="${maxport}">
									  Maximum port ${maxport}
                                      </div>
                                    </div>
                                  </div>
                                  <div class="collapse out" id="id_divDeviceType_ATMEGA328P"> 
                                    <div class="row">
                                      <label class="col-sm-2 control-label col-lg-2">UART DEVICE</label>
                                      <div class="col-sm-2">
                                        <input type="text" class="form-control round-input m-bot15"
                                               value_start="$DEVICE_CTRL[$activeDevice]->{UART}"
                                               value="$DEVICE_CTRL[$activeDevice]->{UART}"
                                               id="id_ifDeviceUart" />
                                      </div>
                                      <div class="col-sm-4">
                                        <div class="panel-body">
									    ie. /dev/ttyACM99
                                        </div>
                                      </div>
                                    </div>
                                    <div class="row">
                                      <label class="col-sm-2 control-label col-lg-2">UART BAUD</label>
                                      <div class="col-sm-2">
                                        <select class="form-control " id="id_ifDeviceBaud" name="DEVICE_BAUD"
                                                value="$DEVICE_CTRL[$activeDevice]->{UART_BAUD}" />
                EOF

    foreach my $key (sort {$DEVICE_BAUD_RATES{$a} <=> $DEVICE_BAUD_RATES{$b}} (keys %DEVICE_BAUD_RATES))
    {
         my $selected = $DEVICE_CTRL[$activeDevice]->{UART_BAUD} eq $key ? "selected" : "";

        $HTMLBUF .= <<"                EOF";
                                          <option $selected value="$key">$key</option>
                EOF
    } 

    $HTMLBUF .= <<"                EOF";
                                        </select>
                                      </div>
                                    </div>
                                    <div class="row">
                                      <label class="col-sm-2 control-label col-lg-2">UART DATABITS</label>
                                      <div class="col-sm-2">
                                        <select class="form-control " id="id_ifDeviceDataBits" name="DEVICE_DATABITS"
                                                value="$DEVICE_CTRL[$activeDevice]->{UART_DATABITS}" />
                EOF

    foreach my $key (sort {$DEVICE_DATABITS{$a} <=> $DEVICE_DATABITS{$b}} (keys %DEVICE_DATABITS))
    {
         my $selected = $DEVICE_CTRL[$activeDevice]->{UART_DATABITS} eq $key ? "selected" : "";

        $HTMLBUF .= <<"                EOF";
                                          <option $selected value="$key">$key</option>
                EOF
    } 

    $HTMLBUF .= <<"                EOF";
                                        </select>
                                      </div>
                                    </div>
                                    <div class="row">
                                      <label class="col-sm-2 control-label col-lg-2">UART PARITY</label>
                                      <div class="col-sm-2">
                                        <select class="form-control " id="id_ifDeviceParity" name="DEVICE_PARITY"
                                                value="$DEVICE_CTRL[$activeDevice]->{UART_PARITY}" />
                EOF

    foreach my $key (sort keys %DEVICE_PARITY)
    {
         my $selected = $DEVICE_CTRL[$activeDevice]->{UART_PARITY} eq $key ? "selected" : "";

        $HTMLBUF .= <<"                EOF";
                                          <option $selected value="$key">$key</option>
                EOF
    } 

    $HTMLBUF .= <<"                EOF";
                                        </select>
                                      </div>
                                    </div>
                                    <div class="row">
                                      <label class="col-sm-2 control-label col-lg-2">UART STOPBITS</label>
                                      <div class="col-sm-2">
                                        <select class="form-control " id="id_ifDeviceStopBits" name="DEVICE_STOPBITS"
                                                value="$DEVICE_CTRL[$activeDevice]->{UART_STOPBITS}" />
                EOF

    foreach my $key (sort {$DEVICE_STOPBITS{$a} <=> $DEVICE_STOPBITS{$b}} (keys %DEVICE_STOPBITS))
    {
         my $selected = $DEVICE_CTRL[$activeDevice]->{UART_STOPBITS} eq $key ? "selected" : "";

        $HTMLBUF .= <<"                EOF";
                                        <option $selected value="$key">$key</option>
                EOF
    } 

    $HTMLBUF .= <<"                EOF";
                                        </select>
                                      </div>
                                    </div>
                                  </div>
                                  <div class="collapse out" id="id_divDeviceType_TCA6416A"> 
                                    <div class="row">
                                      <label class="col-sm-2 control-label col-lg-2">BASE ADDRESS</label>
                                      <div class="col-sm-2">
                                        <input type="text" class="form-control round-input m-bot15"
                                               value_start="$DEVICE_CTRL[$activeDevice]->{BASE_ADDR}"
											   value_min="${minbase}"
											   value_max="${maxbase}"
                                               value="$DEVICE_CTRL[$activeDevice]->{BASE_ADDR}"
                                               id="id_ifDeviceBaseAddr" />
                                      </div>
                                      <div class="col-sm-4">
                                        <div class="panel-body">
									    Port Range (${minbase} -> ${maxbase})
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                EOF

    # Finish off the html before sending.
    #
    $HTMLBUF .= <<"                EOF";
                            </form>
                          </section>
                        </div>
                      </section>
                    </div>
                    <div class="body">
                      <div class="row">
                        <div class="col-lg-3">
                          <section class="panel">
                            <div class="panel-body">
                              <form class="form=horizontal tasi-form" method="post" name="deviceDataConfigSubmit" id="id_formConfigSubmit">
                                  <button class="btn btn-cyan btn-sm m-bot15" type="submit" value="APPLY" id="id_ifConfigApply">
                                          Apply
                                  </button>
                                  <button class="btn btn-blue btn-sm m-bot15" type="submit" value="SAVE" id="id_ifConfigSave">
                                          Save Config
                                  </button>
                                  <button class="btn btn-red active btn-sm m-bot15" type="submit" value="CANCEL" id="id_ifConfigCancel">
                                          Cancel
                                  </button>
                              </form>
                            </div>
                          </section>
                        </div>
                        <div class="col-lg-8">
                          <section class="panel">
                            <div class="panel-body" id="id_ifControlMsg" value="">
                              <strong>$http->{ERRMSG}</strong>
                            </div>
                          </section>
                        </div>
                      </div>
                    </div>
                  </section>
                </div>
              </div>
                EOF
}


# Function to create the HTML which allows a user to configure the internal port types and wether they are enabled.
#
sub htmlConfigPorts
{
    # Parameters.
    #
    my ($http) = @_;

    # Active Port.
    #
    my $activePort=$http->{SESSION}->param('ActivePort');

    # Build a table to hold the variables to be displayed.
    #
    $HTMLBUF = <<"               EOF";
              <!-- page start-->
              <div class="row">
                <div class="col-sm-12">
                  <section class="panel">
                    <header class="panel-heading">
                      <strong>Setup Port I/O</strong>
                      <span class="tools pull-right">
                        <a href="javascript:;" class="fa fa-chevron-down"></a>
                        <a href="javascript:;" class="fa fa-times"></a>
                      </span>
                    </header>
                    <div class="panel-body">
                      <section class="panel">
                        <div class="col-sm-12">
                          <section class="panel">
                            <form method="post" id="id_formSelectConfig">
                              <div class="form-group">
                                <label class="control-label col-lg-2">PORT</label>
                                <div class="col-lg-10">
                                  <div class="btn-row">
                                    <div class="btn-toolbar">
                                      <div class="btn-group-xs" id="id_divPortSelect" value="$activePort">
               EOF

    # For each connected device, output port configuration.
    #
    for(my $dvc=MIN_DEVICE_LIMIT; $dvc < MAX_DEVICE_LIMIT; $dvc++)
    {
        next if(not defined $DEVICE_CTRL[$dvc]->{ENABLED});
        next if($DEVICE_CTRL[$dvc]->{ENABLED} ne $sENABLED);

        for(my $idx=$DEVICE_CTRL[$dvc]->{PORT_MIN}; $idx <= $DEVICE_CTRL[$dvc]->{PORT_MAX}; $idx+=1)
        {
            my $num=sprintf("%02d", $idx);
            my $active = ($PORT_CTRL[$idx]->{IS_LOCKED} eq $sUNLOCKED &&
                          $PORT_CTRL[$idx]->{ENABLED} eq $sENABLED) ? "active" : "";

            if($idx == $activePort)
            {
                $HTMLBUF .= <<"                            EOF";
                                        <label class="btn active">
                                          <button type="button" class="btn btn-green btn-xs active" name="port" value="$num"
                                                  id="id_ifPortButton$num">
                                                  $num
                                          </button>
                                        </label>
                            EOF
            } else
            {
                $HTMLBUF .= <<"                            EOF";
                                        <label class="btn ">
                                          <button type="button" class="btn btn-grey $active btn-xs" name="port" value="$num"
                                                  id="id_ifPortButton$num">
                                                  $num
                                          </button>
                                        </label>
                            EOF
            }
        }
    }

    $HTMLBUF .= <<"                EOF";
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </form>
                          </section>
                        </div>
                        <div class="col-sm-12">
                          <section class="panel">
                            <form class="form=horizontal tasi-form port-config" method="post" name="portDataConfig" id="id_formConfig_IO">
                              <div class="form-group">
                                <label class="control-label col-lg-2">NAME</label>
                                <div class="col-lg-10">
                                   <input type="text" class="form-control round-input shadow-input m-bot15"
                                         value="$PORT_CTRL[$activePort]->{NAME}" id="id_ifPortName">
                                </div>
                                <label class="control-label col-lg-2">DESCRIPTION</label>
                                <div class="col-lg-10">
                                  <input type="text" class="form-control round-input shadow-input m-bot15"
                                         value="$PORT_CTRL[$activePort]->{DESCRIPTION}" id="id_ifPortDescription">
                                </div>
                                <label class="control-label col-lg-2">PORT IS</label>
                                <div class="col-lg-10">
                EOF

    if($PORT_CTRL[$activePort]->{ENABLED} eq $sENABLED)
    {
        $HTMLBUF .= <<"                    EOF";
                                  <button class="btn btn-round btn-green btn-sm active m-bot15" id="id_ifPortState"
                                          value="$PORT_CTRL[$activePort]->{ENABLED}">
                                          $PORT_CTRL[$activePort]->{ENABLED}
                                  </button>
                    EOF
    } else
    {
        $HTMLBUF .= <<"                    EOF";
                                  <button class="btn btn-round btn-grey btn-sm m-bot15" id="id_ifPortState"
                                          value="$PORT_CTRL[$activePort]->{ENABLED}">
                                          $PORT_CTRL[$activePort]->{ENABLED}
                                  </button>
                    EOF
    }
    $HTMLBUF .= <<"                EOF";
                                </div>
                              </div>
                              <div id="inoutData">
                                <label class="control-label col-lg-2">PORT MODE</label>
                                <div class="col-lg-10">
                                  <div class="btn-group btn-toggle" id="id_divModeSelector"> 
                EOF

    if($PORT_CTRL[$activePort]->{MODE} eq $sINPUT)
    {
        $HTMLBUF .= <<"                    EOF";
                                    <button class="btn btn-round btn-green btn-sm active m-bot15" data-target="#PortIsInput" 
                                            id="id_ifPortIsInput">
                                            $PORT_CTRL[$activePort]->{MODE}
                                    </button>
                                    <button class="btn btn-round btn-grey btn-sm m-bot15" data-target="#PortIsOutput" 
                                            id="id_ifPortIsOutput">
                                            $sOUTPUT
                                    </button>
                    EOF
    } else
    {
        $HTMLBUF .= <<"                    EOF";
                                    <button class="btn btn-round btn-grey btn-sm m-bot15" data-target="#PortIsInput" 
                                            id="id_ifPortIsInput">
                                            $sINPUT
                                    </button>
                                    <button class="btn btn-round btn-green btn-sm active m-bot15" data-target="#PortIsOutput" 
                                            id="id_ifPortIsOutput">
                                            $PORT_CTRL[$activePort]->{MODE}
                                    </button>
                    EOF
    }
    $HTMLBUF .= <<"                EOF";
                                  </div>
                                </div>
                                <div class="collapse out" id="PortIsInput"> 
                                  <label class="control-label col-lg-2">ON STATE</label>
                                  <div class="col-lg-10">
                                    <div class="btn-group btn-toggle state-selector" id="id_divOnStateSelector"
                                         value="$PORT_CTRL[$activePort]->{ON_STATE_VALUE}"> 
                EOF

    if($PORT_CTRL[$activePort]->{ON_STATE_VALUE} eq $sLOW)
    {
        $HTMLBUF .= <<"                    EOF";
                                      <button class="btn btn-round btn-green btn-sm active m-bot15" 
                                              id="id_ifOnStateSelectorLOW">
                                              $PORT_CTRL[$activePort]->{ON_STATE_VALUE}
                                      </button>
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifOnStateSelectorHIGH">
                                              $sHIGH
                                      </button>
                    EOF
    } else
    {
        $HTMLBUF .= <<"                    EOF";
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifOnStateSelectorLOW">
                                              $sLOW
                                      </button>
                                      <button class="btn btn-round btn-green btn-sm active m-bot15" 
                                              id="id_ifOnStateSelectorHIGH">
                                              $PORT_CTRL[$activePort]->{ON_STATE_VALUE}
                                      </button>
                    EOF
    }
    $HTMLBUF .= <<"                EOF";
                                    </div>
                                  </div>
                                  <label class="control-label col-lg-2">OFF STATE</label>
                                  <div class="col-lg-10">
                                    <div class="btn-group btn-toggle state-selector" id="id_divOffStateSelector"
                                         value="$PORT_CTRL[$activePort]->{OFF_STATE_VALUE}"> 
                EOF

    if($PORT_CTRL[$activePort]->{OFF_STATE_VALUE} eq $sLOW)
    {
        $HTMLBUF .= <<"                    EOF";
                                      <button class="btn btn-round btn-green btn-sm active m-bot15" 
                                              id="id_ifOffStateSelectorLOW">
                                              $PORT_CTRL[$activePort]->{OFF_STATE_VALUE}
                                      </button>
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifOffStateSelectorHIGH">
                                              $sHIGH
                                      </button>
                    EOF
    } else
    {
        $HTMLBUF .= <<"                    EOF";
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifOffStateSelectorLOW">
                                              $sLOW
                                      </button>
                                      <button class="btn btn-round btn-green btn-sm active m-bot15"
                                              id="id_ifOffStateSelectorHIGH">
                                              $PORT_CTRL[$activePort]->{OFF_STATE_VALUE}
                                      </button>
                    EOF
    }

    $HTMLBUF .= <<"                EOF";
                                    </div>
                                  </div>
                                </div> <!-- PortIsInput Well -->
                                <div class="collapse out" id="PortIsOutput"> 
                                  <label class="control-label col-lg-2">ON STATE</label>
                                  <div class="col-lg-10">
                                    <div class="btn-group btn-toggle state-selector" id="id_divOnStateSelector2"
                                         value="$PORT_CTRL[$activePort]->{ON_STATE_VALUE}"> 
                EOF

    if($PORT_CTRL[$activePort]->{ON_STATE_VALUE} eq $sLOW)
    {
        $HTMLBUF .= <<"                    EOF";
                                      <button class="btn btn-round btn-green btn-sm active m-bot15" 
                                              id="id_ifOnStateSelector2LOW">
                                              $PORT_CTRL[$activePort]->{ON_STATE_VALUE}
                                      </button>
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifOnStateSelector2HIGH">
                                              $sHIGH
                                      </button>
                    EOF
    } else
    {
        $HTMLBUF .= <<"                    EOF";
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifOnStateSelector2LOW">
                                              $sLOW
                                      </button>
                                      <button class="btn btn-round btn-green btn-sm active m-bot15" 
                                              id="id_ifOnStateSelector2HIGH">
                                              $PORT_CTRL[$activePort]->{ON_STATE_VALUE}
                                      </button>
                    EOF
    }
    $HTMLBUF .= <<"                EOF";
                                    </div>
                                  </div>
                                  <label class="control-label col-lg-2">OFF STATE</label>
                                  <div class="col-lg-10">
                                    <div class="btn-group btn-toggle state-selector" id="id_divOffStateSelector2"
                                         value="$PORT_CTRL[$activePort]->{OFF_STATE_VALUE}"> 
                EOF

    if($PORT_CTRL[$activePort]->{OFF_STATE_VALUE} eq $sLOW)
    {
        $HTMLBUF .= <<"                    EOF";
                                      <button class="btn btn-round btn-green btn-sm active m-bot15" 
                                              id="id_ifOffStateSelector2LOW">
                                              $PORT_CTRL[$activePort]->{OFF_STATE_VALUE}
                                      </button>
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifOffStateSelector2HIGH">
                                              $sHIGH
                                      </button>
                    EOF
    } else
    {
        $HTMLBUF .= <<"                    EOF";
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifOffStateSelector2LOW">
                                              $sLOW
                                      </button>
                                      <button class="btn btn-round btn-green btn-sm active m-bot15"
                                              id="id_ifOffStateSelector2HIGH">
                                              $PORT_CTRL[$activePort]->{OFF_STATE_VALUE}
                                      </button>
                    EOF
    }

    $HTMLBUF .= <<"                EOF";
                                    </div>
                                  </div>
                                  <label class="control-label col-lg-2">POWER UP STATE</label>
                                  <div class="col-lg-10">
                                    <div class="btn-group btn-toggle onoff-selector" id="id_divPowerUpSelector"> 
                EOF

    if($PORT_CTRL[$activePort]->{POWERUPSTATE} eq $sOFF)
    {
        $HTMLBUF .= <<"                    EOF";
                                      <button class="btn btn-round btn-green btn-sm active m-bot15" 
                                              id="id_ifPowerUpSelectorOFF">
                                              $PORT_CTRL[$activePort]->{POWERUPSTATE}
                                      </button>
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifPowerUpSelectorON">
                                              $sON
                                      </button>
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifPowerUpSelectorCURRENT">
                                              $sCURRENT
                                      </button>
                    EOF
    } 
    elsif($PORT_CTRL[$activePort]->{POWERUPSTATE} eq $sON)
    {
        $HTMLBUF .= <<"                    EOF";
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifPowerUpSelectorOFF">
                                              $sOFF
                                      </button>
                                      <button class="btn btn-round btn-green btn-sm active m-bot15"
                                              id="id_ifPowerUpSelectorON">
                                              $PORT_CTRL[$activePort]->{POWERUPSTATE}
                                      </button>
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifPowerUpSelectorCURRENT">
                                              $sCURRENT
                                      </button>
                    EOF
    } else
    {
        $HTMLBUF .= <<"                    EOF";
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifPowerUpSelectorOFF">
                                              $sOFF
                                      </button>
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifPowerUpSelectorON">
                                              $sON
                                      </button>
                                      <button class="btn btn-round btn-green btn-sm active m-bot15"
                                              id="id_ifPowerUpSelectorCURRENT">
                                              $PORT_CTRL[$activePort]->{POWERUPSTATE}
                                      </button>
                    EOF
    }

    $HTMLBUF .= <<"                EOF";
                                    </div>
                                  </div>
                                  <label class="control-label col-lg-2">POWER DOWN STATE</label>
                                  <div class="col-lg-10">
                                    <div class="btn-group btn-toggle onoff-selector" id="id_divPowerDownSelector2"> 
                EOF

    if($PORT_CTRL[$activePort]->{POWERDOWNSTATE} eq $sOFF)
    {
        $HTMLBUF .= <<"                    EOF";
                                      <button class="btn btn-round btn-green btn-sm active m-bot15" 
                                              id="id_ifPowerDownSelectorOFF">
                                              $PORT_CTRL[$activePort]->{POWERDOWNSTATE}
                                      </button>
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifPowerDownSelectorON">
                                              $sON
                                      </button>
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifPowerDownSelectorCURRENT">
                                              $sCURRENT
                                      </button>
                    EOF
    } 
    elsif($PORT_CTRL[$activePort]->{POWERDOWNSTATE} eq $sON)
    {
        $HTMLBUF .= <<"                    EOF";
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifPowerDownSelectorOFF">
                                              $sOFF
                                      </button>
                                      <button class="btn btn-round btn-green btn-sm active m-bot15"
                                              id="id_ifPowerDownSelectorON">
                                              $PORT_CTRL[$activePort]->{POWERDOWNSTATE}
                                      </button>
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifPowerDownSelectorCURRENT">
                                              $sCURRENT
                                      </button>
                    EOF
    } else
    {
        $HTMLBUF .= <<"                    EOF";
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifPowerDownSelectorOFF">
                                              $sOFF
                                      </button>
                                      <button class="btn btn-round btn-grey btn-sm m-bot15" 
                                              id="id_ifPowerDownSelectorON">
                                              $sON
                                      </button>
                                      <button class="btn btn-round btn-green btn-sm active m-bot15"
                                              id="id_ifPowerDownSelectorCURRENT">
                                              $PORT_CTRL[$activePort]->{POWERDOWNSTATE}
                                      </button>
                    EOF
    }

    $HTMLBUF .= <<"                EOF";
                                    </div>
                                  </div>
                                </div> <!-- PortIsOutput well -->
                              </div>  <!-- inoutData -->
                            </form> <!-- id_formConfig_IO -->
                          </section>
                        </div>
                      </section>
                    </div>
                    <div class="body">
                      <div class="row">
                        <div class="col-lg-3">
                          <section class="panel">
                            <div class="panel-body">
                              <form class="form=horizontal tasi-form" method="post" name="portDataConfigSubmit" id="id_formConfigSubmit">
                                  <button class="btn btn-cyan btn-sm m-bot15" type="submit" value="APPLY" id="id_ifConfigApply">
                                          Apply
                                  </button>
                                  <button class="btn btn-blue btn-sm m-bot15" type="submit" value="SAVE" id="id_ifConfigSave">
                                          Save Config
                                  </button>
                                  <button class="btn btn-red active btn-sm m-bot15" type="submit" value="CANCEL" id="id_ifConfigCancel">
                                          Cancel
                                  </button>
                              </form>
                            </div>
                          </section>
                        </div>
                        <div class="col-lg-4">
                          <section class="panel">
                EOF

    if($PORT_CTRL[$activePort]->{IS_LOCKED} eq $sLOCKED)
    {
        $HTMLBUF .= <<"                    EOF";
                            <div class="panel-body" id="id_ifControlMsg" value="$sLOCKED">
                              Port $activePort is <strong>Factory Locked</strong>
                            </div>
                    EOF
    } else
    {
        $HTMLBUF .= <<"                    EOF";
                            <div class="panel-body" id="id_ifControlMsg" value="$sUNLOCKED">
                            </div>
                    EOF
    }

    # Finish off the html before sending.
    #
    $HTMLBUF .= <<"                EOF";
                          </section>
                        </div>
                      </div>
                    </div>
                  </section>
                </div>
              </div>
                EOF
}

# Function to create the HTML which allows a user to configure the internal port timers.
#
sub htmlConfigTimers
{
    # Parameters.
    #
    my ($http) = @_;
    my $activePort = $http->{SESSION}->param('ActivePort');

    # Build a table to hold the variables to be displayed.
    #
    $HTMLBUF = <<"               EOF";
              <!-- page start-->
              <div class="row">
                <div class="col-sm-12">
                  <section class="panel">
                    <header class="panel-heading">
                      <strong>Setup Output Timers</strong>
                      <span class="tools pull-right">
                        <a href="javascript:;" class="fa fa-chevron-down"></a>
                        <a href="javascript:;" class="fa fa-times"></a>
                      </span>
                    </header>
                    <div class="panel-body">
                      <section class="panel">
                        <div class="col-sm-12">
                          <section class="panel">
                            <form method="post" id="id_formSelectConfig">
                              <div class="form-group">
                                <label class="col-sm-1 control-label col-lg-1">PORT</label>
                                <div class="col-sm-11">
                                  <div class="btn-row">
                                    <div class="btn-toolbar">
                                      <div class="btn-group-xs" id="id_divPortSelect" value="$activePort">
               EOF

    # For each connected device, output port configuration.
    #
    for(my $dvc=MIN_DEVICE_LIMIT; $dvc < MAX_DEVICE_LIMIT; $dvc++)
    {
        next if(not defined $DEVICE_CTRL[$dvc]->{ENABLED});
        next if($DEVICE_CTRL[$dvc]->{ENABLED} ne $sENABLED);

        for(my $idx=$DEVICE_CTRL[$dvc]->{PORT_MIN}; $idx <= $DEVICE_CTRL[$dvc]->{PORT_MAX}; $idx+=1)
        {
            my $num=sprintf("%02d", $idx);
            my $active = ($PORT_CTRL[$idx]->{IS_LOCKED} eq $sUNLOCKED &&
                          $PORT_CTRL[$idx]->{MODE} eq $sOUTPUT &&
                          $PORT_CTRL[$idx]->{ENABLED} eq $sENABLED) ? "active" : "";
            
            if($idx == $activePort)
            {
                $HTMLBUF .= <<"                            EOF";
                                        <label class="btn active">
                                          <button type="button" class="btn btn-green btn-xs active" name="port" value="$num"
                                                  id="id_ifPortButton$num">
                                                  $num
                                          </button>
                                        </label>
                            EOF
            } else
            {
                $HTMLBUF .= <<"                            EOF";
                                        <label class="btn ">
                                          <button type="button" class="btn btn-grey $active btn-xs" name="port" value="$num"
                                                  id="id_ifPortButton$num">
                                                  $num
                                          </button>
                                        </label>
                            EOF
            }
        }
    }

    $HTMLBUF .= <<"                EOF";
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </form>
                          </section>
                        </div>
                        <div class="row">
                          <div class="col-lg-6">
                            <section class="panel">
<!--
                              <div class="panel-body">&nbsp</div>
-->
                            </section>
                          </div>
                        </div>
                        <div class="col-sm-12">
                          <section class="panel">
                            <form class="form=horizontal tasi-form port-config" method="post" name="portDataConfig" id="id_formConfig_TIMER">
                              <div class="form-group">
                                <div class="adv-table">
                                  <table width="75%" class="display table table-bordered table-striped" id="dynamic-nofrills-table">
                                    <thead>
                                      <tr>
                                        <th style="text-align:center;" width="6%">TIMER #</th>
                                        <th style="text-align:center;" width="7%">ON ENABLE</th>
                                        <th style="text-align:center;" width="6%">ON TIME</th>
                                        <th style="text-align:center;" width="18%">ON DAYS IN WEEK</th>
                                        <th style="text-align:center;" width="7%">OFF ENABLE</th>
                                        <th style="text-align:center;" width="6%">OFF TIME</th>
                                        <th style="text-align:center;" width="18%">OFF DAYS IN WEEK</th>
                                      </tr>
                                    </thead>
                                    <tbody>
                EOF

    for(my $idx=MIN_TIMER_LIMIT; $idx <= MAX_TIMER_LIMIT; $idx+=1)
    {
        my ($onEnabled, $offEnabled, $onTime, $offTime, $active, $disabled, $value) = 
           (undef,      undef,       undef,   undef,    undef,   undef,     undef);

        $onEnabled  = $PORT_CTRL[$activePort]->{ON_TIME_ENABLE}[$idx];
        $offEnabled = $PORT_CTRL[$activePort]->{OFF_TIME_ENABLE}[$idx];
        $onTime     = substr($PORT_CTRL[$activePort]->{ON_TIME}[$idx], 0, 8);
        $offTime    = substr($PORT_CTRL[$activePort]->{OFF_TIME}[$idx], 0, 8);
        $active = ($onEnabled eq $sDISABLED) ? "btn-grey" : "btn-green active";
        $disabled = ($onEnabled eq $sDISABLED) ? "disabled" : "";

        $HTMLBUF .= <<"                    EOF";
                                      <tr>
                                        <td style="text-align:center;vertical-align:middle;font-weight:normal;">$idx</td>
                                        <td style="text-align:center;vertical-align:middle;font-weight:normal;">
                                          <button class="btn btn-round $active btn-xs timer-enable" id="id_ifTimerEnable_ON_${idx}"
                                                  value="$onEnabled">
                                                  $onEnabled
                                          </button>
                                        </td>
                                        <td style="text-align:center;vertical-align:middle;font-weight:normal;">
                                            <input id="id_ifTimerTime_ON_${idx}" value="$onTime"
                                                   data-inputmask="'alias': 'hh:mm:ss'" style="height:25px;"
                                                   class="form-control round-input shadow-input" $disabled>
                                        </td>
                                        <td style="text-align:center;vertical-align:middle;font-weight:normal;">
                                          <div class="btn-group" data-toggle="buttons">
                    EOF

        for(my $idx2=0; $idx2 <=6; $idx2++)
        {
            $value = index(substr($PORT_CTRL[$activePort]->{ON_TIME}[$idx], 9), "$idx2") == -1 ? 0 : 1;
            $active = ($value == 0) ? "btn-grey" : "btn-green active";

            $HTMLBUF .= <<"                        EOF";
                                            <button class="btn $active $disabled btn-round btn-xs dow-enable" id="id_ifTimerDOW_ON_${idx}_${idx2}"
                                                    style="width:45px;height:25px;text-align:cemter;vertical-align:middle;"
                                                    value="$value">
                                                    $DOW_ABBR{$idx2}
                                            </button>
                        EOF
        }

        $active = ($offEnabled eq 'DISABLED') ? "btn-grey" : "btn-green active";
        $disabled = ($offEnabled eq $sDISABLED) ? "disabled" : "";
        $HTMLBUF .= <<"                    EOF";
                                          </div>
                                        </td>
                                        <td style="text-align:center;vertical-align:middle;font-weight:normal;">
                                          <button class="btn btn-round $active btn-xs timer-enable" id="id_ifTimerEnable_OFF_${idx}"
                                                  value="$offEnabled">
                                                  $offEnabled
                                          </button>
                                        </td>
                                        <td style="text-align:center;vertical-align:middle;font-weight:normal;">
                                          <div class="input-append bootstrap-timepicker">
                                            <input id="id_ifTimerTime_OFF_${idx}" value="$offTime"
                                                   data-inputmask="'alias': 'hh:mm:ss'" style="height:25px;"
                                                   class="form-control round-input shadow-input" $disabled>
                                          </div>
                                        </td>
                                        <td style="text-align:center;vertical-align:middle;font-weight:normal;">
                                          <div class="btn-group" data-toggle="buttons">
                    EOF

        for(my $idx2=0; $idx2 <=6; $idx2++)
        {
            $value = index(substr($PORT_CTRL[$activePort]->{OFF_TIME}[${idx}], 9), "$idx2") == -1 ? 0 : 1;
            $active = ($value == 0) ? "btn-grey" : "btn-green active";

            $HTMLBUF .= <<"                        EOF";
                                            <button class="btn $active $disabled btn-round btn-xs dow-enable" id="id_ifTimerDOW_OFF_${idx}_${idx2}"
                                                    style="width:45px;height:25px;text-align:cemter;vertical-align:middle;"
                                                    value="$value">
                                                    $DOW_ABBR{$idx2}
                                            </button>
                        EOF
        }

        $HTMLBUF .= <<"                    EOF";
                                          </div>
                                        </td>
                                      </tr>
                    EOF
    }

    $HTMLBUF .= <<"                EOF";
                                    </tbody>
                                  </table>
                                </div>
                              </div>
                            </form> <!-- id_formConfig_TIMER -->
                          </section>
                        </div>
                      </section>
                    </div>
                    <div class="body">
                      <div class="row">
                        <div class="col-lg-3">
                          <section class="panel">
                            <div class="panel-body">
                              <form class="form=horizontal tasi-form" method="post" name="portDataConfigSubmit" id="id_formConfigSubmit">
                                  <button class="btn btn-cyan btn-sm m-bot15" type="submit" value="APPLY" id="id_ifConfigApply">
                                          Apply
                                  </button>
                                  <button class="btn btn-blue btn-sm m-bot15" type="submit" value="SAVE" id="id_ifConfigSave">
                                          Save Config
                                  </button>
                                  <button class="btn btn-red active btn-sm m-bot15" type="submit" value="CANCEL" id="id_ifConfigCancel">
                                          Cancel
                                  </button>
                              </form>
                            </div>
                          </section>
                        </div>
                        <div class="col-lg-4">
                          <section class="panel">
                EOF

    if($PORT_CTRL[$activePort]->{IS_LOCKED} eq $sLOCKED)
    {
        $HTMLBUF .= <<"                    EOF";
                            <div class="panel-body" id="id_ifControlMsg" value="$sLOCKED">
                              Port $activePort is <strong>Factory Locked</strong>
                            </div>
                    EOF
    }
    elsif($PORT_CTRL[$activePort]->{ENABLED} eq $sDISABLED)
    {
        $HTMLBUF .= <<"                    EOF";
                            <div class="panel-body" id="id_ifControlMsg" value="$sDISABLED">
                              Port $activePort is <strong>Disabled</strong>
                            </div>
                    EOF
    }
    elsif($PORT_CTRL[$activePort]->{MODE} eq $sINPUT)
    {
        $HTMLBUF .= <<"                    EOF";
                            <div class="panel-body" id="id_ifControlMsg" value="$sINPUT">
                              Port $activePort is configured as an <strong>Input Port</strong>
                            </div>
                    EOF
    } else
    {
        $HTMLBUF .= <<"                    EOF";
                            <div class="panel-body" id="id_ifControlMsg" value="$sUNLOCKED">
                            </div>
                    EOF
    }

    # Finish off the html before sending.
    #
    $HTMLBUF .= <<"                EOF";
                          </section>
                        </div>
                      </div>
                    </div>
                  </section>
                </div>
              </div>
                EOF
}

# Function to create the HTML which allows a user to configure the internal pinging mechanism.
#
sub htmlConfigPing
{
    # Parameters.
    #
    my ($http) = @_;
    my $activePort = $http->{SESSION}->param('ActivePort');
    my $maxPinger = MAX_PING_LIMIT;

    # Build a table to hold the variables to be displayed.
    #
    $HTMLBUF = <<"               EOF";
              <!-- page start-->
              <div class="row">
                <div class="col-sm-12">
                  <section class="panel">
                    <header class="panel-heading">
                      <strong>Setup Ping Activity</strong>
                      <span class="tools pull-right">
                        <a href="javascript:;" class="fa fa-chevron-down"></a>
                        <a href="javascript:;" class="fa fa-times"></a>
                      </span>
                    </header>
                    <div class="panel-body">
                      <section class="panel">
                        <div class="col-sm-12">
                          <section class="panel">
                            <form method="post" id="id_formSelectConfig">
                              <div class="form-group">
                                <label class="col-sm-1 control-label col-lg-1">PORT</label>
                                <div class="col-sm-11">
                                  <div class="btn-row">
                                    <div class="btn-toolbar">
                                      <div class="btn-group-xs" id="id_divPortSelect" value="$activePort">
               EOF

    # For each connected device, output port configuration.
    #
    for(my $dvc=MIN_DEVICE_LIMIT; $dvc < MAX_DEVICE_LIMIT; $dvc++)
    {
        next if(not defined $DEVICE_CTRL[$dvc]->{ENABLED});
        next if($DEVICE_CTRL[$dvc]->{ENABLED} ne $sENABLED);

        for(my $idx=$DEVICE_CTRL[$dvc]->{PORT_MIN}; $idx <= $DEVICE_CTRL[$dvc]->{PORT_MAX}; $idx+=1)
        {
            my $num=sprintf("%02d", $idx);
            my $active = ($PORT_CTRL[$idx]->{IS_LOCKED} eq $sUNLOCKED &&
                          $PORT_CTRL[$idx]->{MODE} eq $sOUTPUT &&
                          $PORT_CTRL[$idx]->{ENABLED} eq $sENABLED) ? "active" : "";
            
            if($idx == $activePort)
            {
                $HTMLBUF .= <<"                            EOF";
                                        <label class="btn active">
                                          <button type="button" class="btn btn-green btn-xs active" name="port" value="$num"
                                                  id="id_ifPortButton$num">
                                                  $num
                                          </button>
                                        </label>
                            EOF
            } else
            {
                $HTMLBUF .= <<"                            EOF";
                                        <label class="btn ">
                                          <button type="button" class="btn btn-grey $active btn-xs" name="port" value="$num"
                                                  id="id_ifPortButton$num">
                                                  $num
                                          </button>
                                        </label>
                            EOF
            }
        }
    }

    $HTMLBUF .= <<"                EOF";
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </form>
                          </section>
                        </div>
                        <div class="row">
                          <div class="col-lg-6">
                            <section class="panel">
<!--
                              <div class="panel-body">&nbsp</div>
-->
                            </section>
                          </div>
                        </div>
                        <div class="col-sm-12">
                          <section class="panel">
                            <form class="form=horizontal tasi-form port-config" method="post" name="portDataConfig" id="id_formConfig_PING">
                              <div class="form-group">
                                <div class="col-lg-10">
                EOF


    $HTMLBUF .= <<"                EOF";
                                </div>
                                <div class="adv-table">
                                  <table width="75%" class="display table-bordered table-striped" id="dynamic-nofrills-table">
                                    <thead>
                                      <tr>
                                        <td width="13%" style="text-align:left;font-weight:bold;"></td>
                EOF

    for(my $pdx=MIN_PING_LIMIT; $pdx <= MAX_PING_LIMIT; $pdx++)
    {
        $HTMLBUF .= <<"                    EOF";
                                        <td width="10%" style="text-align:center;vertical-align:middle;font-weight:bold;">PINGER ${pdx}</td>
                    EOF
        if($pdx == MIN_PING_LIMIT)
        {
            $HTMLBUF .= <<"                        EOF";
                                        <td width="8%" style="text-align:center;vertical-align:middle;font-weight:bold;">INTER PINGER LOGIC</td>
                        EOF
        }
    }

    $HTMLBUF .= <<"                EOF";
                                        <td width="12%" style="text-align:center;vertical-align:middle;font-weight:bold;">TRIGGERED ACTION</td>
                                        <td width="8%" style="text-align:center;vertical-align:middle;font-weight:bold;" width="8%">ACTION PAUSE TIME</td>
                                      </tr>
                                      <tr>
                                        <td style="text-align:left;vertical-align:middle;font-weight:bold;">PING MODE</td>
                EOF

    for(my $pdx=MIN_PING_LIMIT; $pdx <= MAX_PING_LIMIT; $pdx++)
    {
        my $active = (($pdx == MIN_PING_LIMIT && $PORT_CTRL[$activePort]->{PING_ENABLE}[$pdx] eq $sENABLED) ||
                      ($pdx != MIN_PING_LIMIT && $PORT_CTRL[$activePort]->{PING_ENABLE}[MIN_PING_LIMIT] eq $sENABLED &&
                                                $PORT_CTRL[$activePort]->{PING_ENABLE}[$pdx] eq $sENABLED)) ? "btn-green active" : "btn-grey";
        
        $HTMLBUF .= <<"                    EOF";
                                        <td style="text-align:center;vertical-align:middle;font-weight:normal;">
                                          <button class="btn btn-round btn-xs $active ping-enable"
                                                  id="id_ifPingState_${maxPinger}_${pdx}"
                                                  value="$PORT_CTRL[$activePort]->{PING_ENABLE}[$pdx]">
                                                  $PORT_CTRL[$activePort]->{PING_ENABLE}[$pdx]
                                          </button>
                                        </td>
                    EOF
        if($pdx == MIN_PING_LIMIT)
        {
            $HTMLBUF .= <<"                        EOF";
                                        <td style="text-align:center"></td>
                        EOF
        }
    }

    $HTMLBUF .= <<"                EOF";
                                        <td style="text-align:center;vertical-align:middle;"></td>
                                        <td style="text-align:center;vertical-align:middle;"></td>
                                      </tr>
                                      <tr>
                                        <td style="text-align:left;vertical-align:middle;font-weight:bold;">PING ADDRESS</td>
                EOF

    for(my $pdx=MIN_PING_LIMIT; $pdx <= MAX_PING_LIMIT; $pdx++)
    {
        $HTMLBUF .= <<"                    EOF";
                                        <td style="text-align:center;vertical-align:middle;">
                                            <input id="id_ifPingIP_${pdx}" data-inputmask="'alias': 'ip'"
                                                   class="ping-enable-${pdx} round-input shadow-input"
                                                   size="14" 
                                                   value="$PORT_CTRL[$activePort]->{PING_ADDR}[$pdx]">
                                        </td>
                    EOF
        if($pdx == MIN_PING_LIMIT)
        {
            $HTMLBUF .= <<"                        EOF";
                                        <td style="text-align:center;vertical-align:middle;"></td>
                        EOF
        }
    }

    $HTMLBUF .= <<"                EOF";
                                        <td style="text-align:center;vertical-align:middle;"></td>
                                        <td style="text-align:center;vertical-align:middle;"></td>
                                      </tr>
                                      <tr>
                                        <td style="text-align:left;vertical-align:middle;font-weight:bold;">PING TYPE</td>
                EOF

    for(my $pdx=MIN_PING_LIMIT; $pdx <= MAX_PING_LIMIT; $pdx++)
    {
        $HTMLBUF .= <<"                    EOF";
                                        <td style="text-align:center;vertical-align:middle;">
                                          <select class="form-control ping-enable-${pdx} input-select"
                                                  id="id_ifPingType_${pdx}">
                    EOF

        foreach my $key (sort keys %PING_TYPES)
        {
            my $selected = "";
            if($PORT_CTRL[$activePort]->{PING_TYPE} eq $key)
            {
                $selected = "selected";
            }
            $HTMLBUF .= <<"                        EOF";
                                              <option value="$key" $selected>$key</option>
                        EOF
        }

        $HTMLBUF .= <<"                    EOF";
                                          </select>
                                        </td>
                    EOF

        if($pdx == MIN_PING_LIMIT)
        {
            $HTMLBUF .= <<"                        EOF";
                                        <td style="text-align:center;vertical-align:middle;"></td>
                        EOF
        }
    }


    $HTMLBUF .= <<"                EOF";
                                        <td style="text-align:center;vertical-align:middle;"></td>
                                        <td style="text-align:center;vertical-align:middle;"></td>
                                      </tr>
                                      <tr>
                                        <td style="text-align:left;vertical-align:middle;font-weight:bold;">INTER PING TIME</td>
                EOF

    for(my $pdx=MIN_PING_LIMIT; $pdx <= MAX_PING_LIMIT; $pdx++)
    {
        $HTMLBUF .= <<"                    EOF";
                                        <td style="text-align:center;vertical-align:middle;">
                                            <input data-inputmask="'alias': 'decimal', 'groupSeparator': ',', 'autoGroup': true" size="8"
                                                   id="id_ifInterPingTime_${pdx}" class="ping-enable-${pdx} round-input shadow-input"
                                                   value="$PORT_CTRL[$activePort]->{PING_TO_PING_TIME}[$pdx]">
                                        </td>
                    EOF
        if($pdx == MIN_PING_LIMIT)
        {
            $HTMLBUF .= <<"                        EOF";
                                        <td style="text-align:center;vertical-align:middle;"></td>
                        EOF
        }
    }

    $HTMLBUF .= <<"                EOF";
                                        <td style="text-align:center;vertical-align:middle;"></td>
                                        <td style="text-align:center;vertical-align:middle;"></td>
                                      </tr>
                                      <tr>
                                        <td style="text-align:left;vertical-align:middle;font-weight:bold;">MAX PING WAIT TIME</td>
                EOF

    for(my $pdx=MIN_PING_LIMIT; $pdx <= MAX_PING_LIMIT; $pdx++)
    {
        $HTMLBUF .= <<"                    EOF";
                                        <td style="text-align:center;vertical-align:middle;">
                                            <input data-inputmask="'alias': 'decimal', 'groupSeparator': ',', 'autoGroup': true" size="6"
                                                   id="id_ifPingWaitTime_${pdx}" class="ping-enable-${pdx} round-input shadow-input"
                                                   value="$PORT_CTRL[$activePort]->{PING_ADDR_WAIT_TIME}[$pdx]">
                                        </td>
                    EOF
        if($pdx == MIN_PING_LIMIT)
        {
            $HTMLBUF .= <<"                        EOF";
                                        <td style="text-align:center;vertical-align:middle;"></td>
                        EOF
        }
    }

    $HTMLBUF .= <<"                EOF";
                                        <td style="text-align:center;vertical-align:middle;"></td>
                                        <td style="text-align:center;vertical-align:middle;"></td>
                                      </tr>
                                      <tr>
                                        <td style="text-align:left;vertical-align:middle;font-weight:bold;">FAIL COUNT</td>
                EOF

    for(my $pdx=MIN_PING_LIMIT; $pdx <= MAX_PING_LIMIT; $pdx++)
    {
        $HTMLBUF .= <<"                    EOF";
                                        <td style="text-align:center;vertical-align:middle;">
                                            <input data-inputmask="'alias': 'decimal', 'groupSeparator': ',', 'autoGroup': true" size="6"
                                                   id="id_ifFailCount_${pdx}" class="ping-enable-${pdx} round-input shadow-input"
                                                   value="$PORT_CTRL[$activePort]->{PING_FAIL_COUNT}[$pdx]">
                                        </td>
                    EOF
        if($pdx == MIN_PING_LIMIT)
        {
            $HTMLBUF .= <<"                        EOF";
                                        <td style="text-align:center;vertical-align:middle;">
                                          <select class="form-control ping-enable-1 input-select"
                                                  id="id_ifLogicForFail">
                        EOF

            foreach my $key (sort {$LOGIC_OPER{$a} <=> $LOGIC_OPER{$b}} (keys %LOGIC_OPER))
            {
                my $selected = "";
                if($PORT_CTRL[$activePort]->{PING_LOGIC_FOR_FAIL} eq $key)
                {
                    $selected = "selected";
                }
                $HTMLBUF .= <<"                    EOF";
                                              <option value="$key" $selected>$key</option>
                    EOF
            }

            $HTMLBUF .= <<"                        EOF";
                                        </td>
                        EOF
        }
    }

    $HTMLBUF .= <<"                EOF";
                                        <td style="text-align:center;vertical-align:middle;">
                                          <select class="form-control ping-enable-0 input-select"
                                                  id="id_ifActionOnFail">
                EOF

    foreach my $key (sort {$PING_ACTION{$a} <=> $PING_ACTION{$b}} keys %PING_ACTION)
    {
        my $selected = "";
        if($PORT_CTRL[$activePort]->{PING_ACTION_ON_FAIL} eq $key)
        {
            $selected = "selected";
        }
        $HTMLBUF .= <<"                    EOF";
                                              <option value="$key" $selected>$key</option>
                    EOF
    }

    $HTMLBUF .= <<"                EOF";
                                          </select>
                                        </td>
                                        <td style="text-align:center;vertical-align:middle;">
                                            <input data-inputmask="'alias': 'decimal', 'groupSeparator': ',', 'autoGroup': true" size="6"
                                                   id="id_ifActionSuccessTime" class="ping-enable-0 round-input shadow-input"
                                                   value="$PORT_CTRL[$activePort]->{PING_ACTION_SUCCESS_TIME}">
                                        </td>
                                      </tr>
                                      <tr>
                                        <td style="text-align:left;vertical-align:middle;font-weight:bold;">SUCCESS COUNT</td>
                EOF

    for(my $pdx=MIN_PING_LIMIT; $pdx <= MAX_PING_LIMIT; $pdx++)
    {
        $HTMLBUF .= <<"                    EOF";
                                        <td style="text-align:center;vertical-align:middle;">
                                            <input data-inputmask="'alias': 'decimal', 'groupSeparator': ',', 'autoGroup': true" size="6"
                                                   id="id_ifSuccessCount_${pdx}" class="ping-enable-${pdx} round-input shadow-input"
                                                   value="$PORT_CTRL[$activePort]->{PING_SUCCESS_COUNT}[$pdx]">
                                        </td>
                    EOF
        if($pdx == MIN_PING_LIMIT)
        {
            $HTMLBUF .= <<"                        EOF";
                                        <td style="text-align:center;vertical-align:middle;">
                                          <select class="form-control ping-enable-1 input-select"
                                                  id="id_ifLogicForSuccess">
                        EOF

            foreach my $key (sort {$LOGIC_OPER{$a} <=> $LOGIC_OPER{$b}} (keys %LOGIC_OPER))
            {
                my $selected = "";
                if($PORT_CTRL[$activePort]->{PING_LOGIC_FOR_SUCCESS} eq $key)
                {
                    $selected = "selected";
                }
                $HTMLBUF .= <<"                    EOF";
                                              <option value="$key" $selected>$key</option>
                    EOF
            }

            $HTMLBUF .= <<"                        EOF";
                                        </td>
                        EOF
        }
    }

    $HTMLBUF .= <<"                EOF";
                                        <td style="text-align:center;vertical-align:middle;">
                                          <select class="form-control ping-enable-0 input-select"
                                                  id="id_ifActionOnSuccess">
                EOF

    foreach my $key (sort {$PING_ACTION{$a} <=> $PING_ACTION{$b}} keys %PING_ACTION)
    {
        my $selected = "";
        if($PORT_CTRL[$activePort]->{PING_ACTION_ON_SUCCESS} eq $key)
        {
            $selected = "selected";
        }
        $HTMLBUF .= <<"                    EOF";
                                              <option value="$key" $selected>$key</option>
                    EOF
    }

    $HTMLBUF .= <<"                EOF";
                                          </select>
                                        </td>
                                        <td style="text-align:center;vertical-align:middle;">
                                            <input data-inputmask="'alias': 'decimal', 'groupSeparator': ',', 'autoGroup': true" size="6"
                                                   id="id_ifActionFailTime" class="ping-enable-0 round-input shadow-input"
                                                   value="$PORT_CTRL[$activePort]->{PING_ACTION_FAIL_TIME}">
                                        </td>
                                      </tr>
                                    </thead>
                                  </table>
                                </div>
                EOF

    $HTMLBUF .= <<"                EOF";
                              </div>
                            </form> <!-- id_formConfig_PING -->
                          </section>
                        </div>
                      </section>
                    </div>
                    <div class="body">
                      <div class="row">
                        <div class="col-lg-3">
                          <section class="panel">
                            <div class="panel-body">
                              <form class="form=horizontal tasi-form" method="post" name="portDataConfigSubmit" id="id_formConfigSubmit">
                                  <button class="btn btn-cyan btn-sm" type="submit" value="APPLY" id="id_ifConfigApply">
                                          Apply
                                  </button>
                                  <button class="btn btn-blue btn-sm" type="submit" value="SAVE" id="id_ifConfigSave">
                                          Save Config
                                  </button>
                                  <button class="btn btn-red active btn-sm" type="submit" value="CANCEL" id="id_ifConfigCancel">
                                          Cancel
                                  </button>
                              </form>
                            </div>
                          </section>
                        </div>
                        <div class="col-lg-4">
                          <section class="panel">
                EOF

    if($PORT_CTRL[$activePort]->{IS_LOCKED} eq $sLOCKED)
    {
        $HTMLBUF .= <<"                    EOF";
                            <div class="panel-body" id="id_ifControlMsg" value="$sLOCKED">
                              Port $activePort is <strong>Factory Locked</strong>
                            </div>
                    EOF
    }
    elsif($PORT_CTRL[$activePort]->{ENABLED} eq $sDISABLED)
    {
        $HTMLBUF .= <<"                    EOF";
                            <div class="panel-body" id="id_ifControlMsg" value="$sDISABLED">
                              Port $activePort is <strong>Disabled</strong>
                            </div>
                    EOF
    }
    elsif($PORT_CTRL[$activePort]->{MODE} eq $sINPUT)
    {
        $HTMLBUF .= <<"                    EOF";
                            <div class="panel-body" id="id_ifControlMsg" value="$sINPUT">
                              Port $activePort is configured as an <strong>Input Port</strong>
                            </div>
                    EOF
    } else
    {
        $HTMLBUF .= <<"                    EOF";
                            <div class="panel-body" id="id_ifControlMsg" value="$sUNLOCKED">
                            </div>
                    EOF
    }

    # Finish off the html before sending.
    #
    $HTMLBUF .= <<"                EOF";
                          </section>
                        </div>
                      </div>
                    </div>
                  </section>
                </div>
              </div>
                EOF
}
}
1;
