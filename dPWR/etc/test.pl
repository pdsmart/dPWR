#!/usr/bin/perl

$EXEC_FILE_DIR="/tmp";
$EXEC_FILE_BASE="TEST";
$EXEC_FILE_EXT="\.exec";

sub next_available_file {
    my $n = 1;
    my $d;
    $n ++ while -e ($d = "${EXEC_FILE_DIR}/${EXEC_FILE_BASE}$n${EXEC_FILE_EXT}");
    return $d;
}

sub getNextFile
{
    # Pop parameters.
    #
    my ($firstOrLast, $lockFile, $dir, $base, $ext) = @_;
    my $result;

    # Get the current list of exec files.
    my @execFiles = glob( "${dir}/${base}*${ext}" );
    
    # Set to the first number incase no other files exist.
    my $firstFileNumber = 1;
    my $nextFileNumber = 1;
    
    # check for others
    if( @execFiles )
    {
        # A Schwartian transform
        @execFiles = map  { $_->[0]                                     }  # Original
                     sort { $a->[1] <=> $b->[1]                         }  # Sort by second field which are numbers
                     map  { [ $_, do{ ( my $n = $_ ) =~ s/\D//g; $n } ] }  # Create an anonymous array with original value and file digits.
                     @execFiles;
    
        # Last file name is the biggest if it exists.
        #
        if($#execFiles > 0)
        {
            $firstFileNumber = $execFiles[0];  $firstFileNumber =~ s/^.*${base}(\d+)${ext}$/$1/e;
            $nextFileNumber  = $execFiles[-1]; $nextFileNumber  =~ s/^.*${base}(\d+)${ext}$/$1+1/e;
        }
    }

    # Return first available file or next unused file which can be created.
    #
    if($firstOrLast == 0)
    {
        $result = "${dir}/${base}${firstFileNumber}${ext}";
    } else
    {
        $result = "${dir}/${base}${nextFileNumber}${ext}";
    }

    # If lock parameter given, create empty file so that no other process can grab this file.
    #
    if($lockFile == 1 && $firstOrLast == 1)
    {
        touch ${result};
    }

    return $result;
}

my $first_file = getNextFile(0, 0, $EXEC_FILE_DIR, $EXEC_FILE_BASE, $EXEC_FILE_EXT);
my $last_file = getNextFile(1, 0, $EXEC_FILE_DIR, $EXEC_FILE_BASE, $EXEC_FILE_EXT);
printf("Next file:$last_file, First File:$first_file\n");
my $next=next_available_file();
printf("Next available file:$next\n");

#$OUTPUT_MAP = pack("B32", "0"x32);
##vec($OUTPUT_MAP, 29, 1) = 1;
#$NEW_MAP = unpack("B32", $OUTPUT_MAP);
##printf("$OUTPUT_MAP,$NEW_MAP\n");
#vec($NEW_MAP, 29, 32) = 1;
#substr($NEW_MAP, 2, 1, 1);
#printf("$OUTPUT_MAP,$NEW_MAP\n");
#printf("Value=%s", substr($NEW_MAP, 3, 1));

exit(0);
