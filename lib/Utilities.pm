#########################################################################################################
##
## Name:            Utilities.pm
## Created:         September 2015
## Author(s):       Philip Smart
## Description:     A perl module which forms part of the dPWR program.
##                  This module provides all the required utility and helper methods to aid the
##                  dPWR program in its tasks.
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
package Utilities;
require 5.8.0;

BEGIN {
    use Exporter ();
    use vars qw(@ISA @EXPORT $VERSION);
    our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

    $VERSION = 1.00;

    @ISA     = qw(Exporter);

    %EXPORT_TAGS = ( 'all' => [ qw(
                                  ) ] );

    @EXPORT_OK   = ( @{ $EXPORT_TAGS{'all'} } );

    @EXPORT  = qw(init
                  log
                  forkrun
                  forkthread
                  expandFileName
                  isInt
                  trNumeric
                  trString
                  cutWhiteSpace
                  formatData
                  encryptPassword
                  trim
                  atrim
                  ltrim
                  rtrim
                  getCurrentDate
                  getCurrentTime
                  setTime
				  setupDDNS
                  getNextFile
                  isInActiveTimeRange
                 );       # Symbols to autoexport (:DEFAULT tag)
}

#################################################################################
# Utilities tools package.
#
# Description: This package contains an array of Utility methods to aid in DPWR
#              processing.
#
# Member Functions:-
#        init( )
#        log( )
#        forkrun( )
#        forkthread( )
#        expandFileName( )
#        isInt( )
#        trString( )
#        trNumeric( )
#        trNumeric
#        cutWhiteSpace( )
#        formatData( )
#        encryptPassword( )
#        trim( )
#        atrim( )
#        ltrim( )
#        rtrim( )
#        getCurrentDate( )
#        getCurrentTime( )
#        setTime( )
#        setupDDNS( )
#        getNextFile( )
#        isInActiveTimeRange( )
#
# Members Variables:
#
# Comments: 
#
#################################################################################
{
    # Public variables (our)
    #
    our $LOGFILE                         =  "/usr/local/DPWR/log/dpwr.log";
    our $DEBUG                           =  0;
    our $LOGLEVEL                        =  5;

    # Constants.
    #
    use constant MODULE                  => "Utilities";
	my  $NTP_PORT                        =  123;
    my  $NTP_MAXLEN                      =  1024;

    # Init method. Pseudo instantiator passes required configuration parameters.
    #
    sub init
    {
        ($LOGFILE, $DEBUG, $LOGLEVEL) = @_;
    }

    # Method to log information from this module, seperate from callers logging.
    #
    sub log
    {
        my ($error, $module, $function, $msg) = @_;

        # Dont log if the error message is lower than the current logging level.
        #
        return if($error > $LOGLEVEL);

        my $date = scalar localtime;
        my ($dow, $mon, $dt, $tm, $yr) = ($date =~ m/(...) (...) (..) (..:..:..) (....)/);
        $dt += 0;
        $dt = substr("0$dt", length("0$dt") - 2, 2);
        $date = "$dt/$mon/$yr:$tm"; 
        if (open(LG_HDL, ">>$LOGFILE")) {
            print LG_HDL <<"EOF";
[$date-$error-$module($function)]=$msg
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
        }
        else {
            Utilities::log(1, MODULE, "forkrun", "Failed to run command:$cmd");
            return 0;
        }
    }

    # Method to run a detached procedure and return its integer result.
    #
    sub forkthread {
        my ($cmd)=@_;
        my $pid;
        my $result;

        # Fork a child.
        #
        if( $pid = fork )
        {
            # Parent.
            Utilities::log(6, MODULE, "forkthread", "Forked:$pid");
            return $pid;
        }
        elsif( defined $pid )
        {
            # Child, basically place procedure into a dynamic string and execute via eval.
            #
            my $dynstr="\$result = $cmd";
            Utilities::log(6, MODULE, "forkthread", "Child:$dynstr");
            eval $dynstr;
            exit $result;
        }
        else {
            Utilities::log(1, MODULE, "forkthread", "Failed to run procedure:$cmd");
            return -1;
        }
    }

    # Method to expand a filename macros.
    #
    sub expandFileName
    {
        my $filename  = shift;
        my $year      = "";
        my ($sec, $min, $hour, $day, $month, $lyear, undef, undef, undef) = localtime();

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

    # Function to determine if a scalar is an integer.
    #
    sub isInt
    {
        my $val = shift;
        return ($val =~ m/^\d+$/);
    }

    # Sub-routine to test if a string is empty, and if so, replace
    # with an alternative string. The case of the returned string
    # can be adjusted according to the $convertCase parameter.
    #
    sub trString
    {
        my( $tstString, $replaceString, $convertCase ) = @_;
        my( $dstString );

        $tstString=cutWhiteSpace($tstString);
        $replaceString=cutWhiteSpace($replaceString);
        if($tstString eq "")
        {
            $dstString = $replaceString;
        } else
        {
            $dstString = $tstString;
        }

        # Convert to Lower Case?
        #
        if($convertCase == 1)
        {
            $dstString =~ lc($dstString);
        }
        # Convert to Upper Case?
        #
        elsif($convertCase == 2)
        {
            $dstString =~ uc($dstString);
        }
        return($dstString);
    }

    # Sub-routine to test if a numeric is empty, and if so, set to a
    # given value.
    #
    sub trNumeric
    {
        my( $tstNumber, $replaceNumber ) = @_;
        my( $dstNumber );

        if(!defined($tstNumber) || $tstNumber eq "" || cutWhiteSpace($tstNumber) eq "")
        {
            $dstNumber = $replaceNumber;
        } else
        {
            $dstNumber = $tstNumber;
        }

        return($dstNumber);
    }

    # Sub-routine to truncate whitespace at the front (left) of a string, returning the
    # truncated string.
    #
    sub cutWhiteSpace
    {
        my( $srcString ) = @_;
        my( $c, $dstString, $idx );
        $dstString = "";

        for($idx=0; $idx < length($srcString); $idx++)
        {
            # If the character is a space or tab, delete.
            #
            $c = substr($srcString, $idx, 1);
            if(length($dstString) == 0)
            {
                if($c ne " " && $c ne "\t")
                {
                    $dstString = $dstString . $c;
                }
            } else
            {
                $dstString = $dstString . $c;
            }
        }
        return($dstString);
    }

    # Function to encrypt a password.
    #
    sub encryptPassword
    {
        my ($pwd, $count) = @_;
        my @salt = ('.', '/', 'a'..'z', 'A'..'Z', '0'..'9');  
        my $salt = "";
        $salt.= $salt[rand(63)] foreach(1..$count);
        return crypt($pwd, $salt);
    }

    # Perl trim function to remove whitespace from the start and end of the string
    #
    sub trim($)
    {
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
    }

    # Trim function to handle a string or an array of string.
    #
    sub atrim
    {
        my @out = @_;
        for (@out)
        {
            s/^\s+//;
            s/\s+$//;
            #s/^\"//;
            #s/\"$//;
        }
        return wantarray ? @out : $out[0];
    }

    # Left trim function to remove leading whitespace
    #
    sub ltrim($)
    {
        my $string = shift;
        $string =~ s/^\s+//;
        return $string;
    }

    # Right trim function to remove trailing whitespace
    #
    sub rtrim($)
    {
        my $string = shift;
        $string =~ s/\s+$//;
        return $string;
    }

    # Get the current Date/Time in a requried format.
    #
    sub getCurrentDate
    {
        my $format = shift;
        my $date;
        my ($sec,$min,$hour,$mday,$mon,$year) = localtime;

        $mon++; $year += 1900;
        $date = sprintf "%02d%02d%02d", $year-2000, $mday, $mon if $format eq "YYMMDD";
        $date = sprintf "%02d%02d%04d", $mon, $mday, $year if $format eq "DDMMYYYY";
        $date = sprintf "%02d-%02d-%04d", $mday, $mon, $year if $format eq "DD-MM-YYYY";
        $date = sprintf "%04d-%02d-%02d", $year, $mon, $mday if $format eq "YYYY-MM-DD";
        $date = sprintf "%04d-%02d-%02dT%02d:%02d:%02d", $year, $mon, $mday,$hour,$min,$sec if $format eq "YYYY-MM-DDThh:mm:ss";
        $date = sprintf "%02d/%02d/%04d %02d:%02d:%02d", $mday, $mon, $year,$hour,$min,$sec if $format eq "DD/MM/YYYY hh:mm:ss";
        $date = sprintf "%04d%02d%02d", $year, $mon, $mday if ! $format;
        return $date;
    }

    # Function to get the current 'Week' time in seconds. This is used for scheduling.
    #
    sub getCurrentTime
    {
        my ($sec, $min, $hour, undef, undef, undef, $wday, undef, $isdst) = localtime();
        my $current_time = (($wday + 1) * 24 * 60 * 60) + ($hour * 60 * 60) + ($min * 60) + $sec;
        return $current_time;
    }

    # Method to set the system date/time, either by locally given values or via an NTP server.
    #
	sub setTime
	{
        my ($mode, $localDate, $localTime, $serverIP, $timezoneId, $timezoneDst, $timezoneOffset) = @_;

        # If mode is local, use the provided time and date to change the System time and date.
        #
		if($mode eq "LOCAL")
        {
            my ($day, $month, $year) = split(/\//, $localDate);
            my ($hour, $minute, $seconds) = split(/:/, $localTime);
            Utilities::log(0, MODULE, "setTime", "Launching(ix ix_setDate \"$year\" \"$month\" \"$day\" \"$hour\" \"$minute\" \"$seconds\"\)");
            system("$ENV{'BINDIR'}/ix ix_setDate \"$day\" \"$month\" \"$year\" \"$hour\" \"$minute\" \"$seconds\" 2>/dev/null >/dev/null");
        } else
		{
            Utilities::log(0, MODULE, "setTime", "Launching(ix ix_setNTP \"$serverIP\" \"$timezoneId\" \"$timezoneDst\" \"$timezoneOffset\")");
            system("$ENV{'BINDIR'}/ix ix_setNTP \"$serverIP\" \"$timezoneId\" \"$timezoneDst\" \"$timezoneOffset\" 2>/dev/null >/dev/null");
		}
        if($? == -1)
        {
			$result = $? >> 8;
            Utilities::log(0, MODULE, "setTime", "Failed to set time, Mode:$mode, Result:$result");
        }
	}

    # Method to setup the Dynamic DNS service.
    #
	sub setupDDNS
	{
        my ($enabled, $serverIP, $clientDomain, $clientUserName, $clientPassword, $proxyEnable, $proxyIP, $proxyPort) = @_;

		# Call the underlying script which runs with superuser priviledge to setup the DDNS address.
        #
        Utilities::log(0, MODULE, "setupDDNS", "Launching(ix ix_setDDNS \"$enabled\" \"$serverIP\" \"$clientDomain\" \"$clientUserName\" \"$clientPassword\" \"$proxyEnable\" \"$proxyIP\" \"$proxyPort\")");
        system("$ENV{'BINDIR'}/ix ix_setDDNS \"$enabled\" \"$serverIP\" \"$clientDomain\" \"$clientUserName\" \"$clientPassword\" \"$proxyEnable\" \"$proxyIP\" \"$proxyPort\" >/dev/null >/dev/null");
        if($? == -1)
        {
			$result = $? >> 8;
            Utilities::log(0, MODULE, "setupDDNS", "Failed to set DDNS, Server:$serverIP, Result:$result");
        }
	}

    # Function to look for the first or the next sequential file in a given directory.
    #
    sub getNextFile
    {
        # Pop parameters.
        #
        my ($firstOrNext, $lockFile, $dir, $base, $ext) = @_;
        my $firstFileNumber;
        my $lastFileNumber;
        my $nextFileNumber;
        my $result;
    
        # Get the current list of exec files.
        my @execFiles = glob( "${dir}/${base}*${ext}*" );
        
        # If files exist, sort and process to get right file number.
        #
        if( @execFiles )
        {
            # A Schwartian transform
            @execFiles = map  { $_->[0]                                     }  # Original
                         sort { $a->[1] <=> $b->[1]                         }  # Sort by second field which are numbers
                         map  { [ $_, do{ ( my $n = $_ ) =~ s/\D//g; $n } ] }  # Create an anonymous array with original value and file digits.
                         @execFiles;

            # Get id's of first and last files in sequence.
            #
            $firstFileNumber = $execFiles[0];  $firstFileNumber =~ s/^.*${base}(\d+)${ext}$/$1/e;
                                               $firstFileNumber =~ s/^.*${base}(\d+)${ext}.tmp$/$1/e;
            $lastFileNumber = $execFiles[-1];  $lastFileNumber =~ s/^.*${base}(\d+)${ext}$/$1/e;
                                               $lastFileNumber =~ s/^.*${base}(\d+)${ext}.tmp$/$1/e;
            $nextFileNumber = $lastFileNumber + 1;

            # Return first available file or next unused file which can be created.
            #
            if($firstOrNext == 0)
            {
                # Find the first file available for processing.
                #
                for(my $idx=$firstFileNumber; $idx <= $lastFileNumber; $idx++)
                {
                    # We want populated whole files, not temporary ones which are currently being filled.
                    #
                    $result = "${dir}/${base}${idx}${ext}";
                    last if(-s $result);
                }
            } else
            {
                $result = "${dir}/${base}${nextFileNumber}${ext}";
            }
        } else
        {
            # Directory is empty so indicate this with an empty string (first) or a start string (next).
            #
            if($firstOrNext == 0)
            {
                $result = "";
            } else
           {
                $result = "${dir}/${base}1${ext}";
           }
        }
    
        # If lock parameter given, create empty file so that no other process can grab this file.
        #
        if($lockFile == 1 && $firstOrNext == 1)
        {
            open(FH, ">${result}.tmp") or Utilities::log(0, MODULE, "getNextFile", "Can't create empty locking file:${result}.tmp");
            close(FH);
        }
    
        # Return the final file name.
        #
        return $result;
    }

    # Method to determine if current time falls within a given Start/End time.
    # Input times are in format: HH:MM:SS DOW,DOW,DOW,DOW,DOW,DOW,DOW
    # DOW can be 0 or many to indicate which days the time is applicable to.
    #
    sub isInActiveTimeRange
    {
        my ($startTime, $endTime) = @_;
        my $startActive   = (defined $startTime && $startTime ne "") ? 1 : 0;
        my $endActive     = (defined $endTime   && $endTime ne "")   ? 1 : 0;
        my @parts         = ();
        my @timeParts     = ();
        my @startDOW      = ();
        my @endDOW        = ();
        my $lowerStartDOW = -1;
        my $lowerEndDOW   = -1;
        my $calcStartTime = 0;
        my $calcEndTime   = 0;
        my $result        = 0;

        # Get current date and time.
        #
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
        # Weekday, 0 = Sunday - 6 = Saturday - adjust: 0 = Monday, 6 = Sunday
        if($wday == 0) { $wday = 6; } else { $wday--; }; # Correct to same format as input, Mon=0 - Sun=6
        my $timeNow = $wday*604800 + $hour*3600 + $min*60 + $sec;
 
        # Break down input times into numerics.
        #
        if($startActive)
        {
            @parts         = split(/ /, $startTime);
            @timeParts     = split(/:/, $parts[0]);
            @startDOW      = split(/,/, $parts[1]);
            foreach my $dow (sort { $a <=> $b } @startDOW) {
                if($dow <= $wday || $lowerStartDOW == -1) { $lowerStartDOW = $dow; }
            }
            $calcStartTime = $lowerStartDOW*604800 +$timeParts[0]*3600 + $timeParts[1]*60 + $timeParts[2];
        }
        #
        if($endActive)
        {
            @parts         = split(/ /, $endTime);
            @timeParts     = split(/:/, $parts[0]);
            @endDOW        = split(/,/, $parts[1]);
            foreach my $dow (sort { $b <=> $a } @endDOW) {
                if($dow >= $wday || $lowerEndDOW == -1) { $lowerEndDOW = $dow; }
            }
            $calcEndTime = $lowerEndDOW*604800 + $timeParts[0]*3600 + $timeParts[1]*60 + $timeParts[2];
        }

        # Current time between start and end, return 1 (active).
        # Only Start time given, current time >= start time, return 1 (active).
        # Only End time given, current time >= end time, return 1 (active).
        #
        if($startActive == 1 && $endActive == 1 && $timeNow >= $calcStartTime && $timeNow <= $calcEndTime)
        {
            $result = 1;
        }
        elsif($startActive == 1 && $endActive == 0 && $timeNow >= $calcStartTime)
        {
            $result = 1;
        }
        elsif($endActive == 1 && $startActive == 0 && $timeNow > $calcEndTime)
        {
            $result = 1;
        }
#Utilities::log(0, MODULE, "isInActiveTimeRange", "$lowerStartDOW:$lowerEndDOW:$wday=>$calcStartTime,$calcEndTime,$timeNow:RESULT=$result");
        return $result;   
    }

}

END {

}
1;
