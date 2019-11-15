/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Name:            ix.c
// Created:         September 2015
// Author(s):       Philip Smart
// Description:     A wrapper script which runs root SUID and takes parameters of the program it is
//                  required to run. If a valid subprogram which needs to run root SUID is given along
//                  with the correct number of arguments then the program is launched otherwise error
//                  exit. This is done to ensure no other programs are run root SUID by this wrapper.
//
// Credits:         
// Copyright:       (c) 2015-2019 Philip Smart <philip.smart@net2net.org>
//
// History:         September 2015    - Initial program creation.
//
// Notes:           
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
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

int main( int argc, char *argv[] )
{
    /* Local variables.
    */
    int  error;
    int  idx;
    int  result;
    char script_to_run[255];
    char arg[255];
    char arg_string[4096];

    /* Verify that a valid script name was given with correct number of parameters.
    */
    error = 1;
    if(argc > 1)
    {
        if( (strcmp(argv[1], "ix_setDate")        == 0) )
        {
            if( argc == 8 )
            {
                error = 0;
            }
        }
        if( (strcmp(argv[1], "ix_setNTP")         == 0) )
        {
            if( argc == 6 )
            {
                error = 0;
            }
        }
        if( (strcmp(argv[1], "ix_setDDNS")        == 0) )
        {
            if( argc == 10 )
            {
                error = 0;
            }
        }
        if( (strcmp(argv[1], "ix_cfgTCA6416A")    == 0) )
        {
            if( argc == 3 )
            {
                error = 0;
            }
        }
        if( (strcmp(argv[1], "ix_cfgATMega328p")  == 0) )
        {
            if( argc == 3 )
            {
                error = 0;
            }
        }
    }

    /* If we do not recognise script name or its expected number of parameters, exit as the script
       is not being called by DPWR.
    */
    if(error == 1)
    {
        printf("Usage: %s scriptname [param 1] .. [param (n)]\n\n", argv[0]);
        printf("Parameters (%d) not recognised!\n", argc);
        return(129);
    }

    /* Change to run as root.
    */
    setuid( 0 );

    /* Build up a linear string of arguments.
    */
    arg_string[0] = 0x00;
    for(idx=2; idx < argc; idx++)
    {
        sprintf(arg, "\"%s\" ", argv[idx]);
        strcat(arg_string, arg);
    }

    /* Launch the script.
    */
    sprintf(script_to_run, "/usr/local/DPWR/bin/%s %s", argv[1], arg_string);

    /* Run command, get exist status and return to caller.
    */
    result=WEXITSTATUS(system( script_to_run ));
    return(result);
}
