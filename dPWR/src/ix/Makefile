#########################################################################################################
##
## Name:            Makefile
## Created:         September 2015
## Author(s):       Philip Smart
## Description:     Makefile to build the ix program.
##
## Credits:         
## Copyright:       (c) 2015-2019 Philip Smart <philip.smart@net2net.org>
##
## History:         September 2015        - Initial version.
##
## Notes:           
##
#########################################################################################################
## This source file is free software: you can redistribute it and/or modify
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
#BASE        	= zpu-elf
BASE        	= 
CC              = $(BASE)gcc
LD              = $(BASE)gcc
AS              = $(BASE)as
CP              = $(BASE)objcopy
DUMP            = $(BASE)objdump
BASEDIR         = .
BUILD_DIR       = $(BASEDIR)
#
MAIN_PRJ        = ix
MAIN_SRC        = ix.c
MAIN_OBJ        = $(patsubst %.c,$(BUILD_DIR)/%.o,$(MAIN_SRC))
#
CFLAGS          = -I.

# Our target.
all: $(BUILD_DIR) $(MAIN_PRJ)

clean:
	rm -f $(BUILD_DIR)/*.o *.hex *.lss *.map *.lst *.srec $(MAIN_PRJ) *~ */*.o *.bin *.srec *.dmp *.vhd *.rpt

# Link - this produces an ELF binary.

$(MAIN_PRJ).elf: $(MAIN_OBJ)
	$(LD) $(LFLAGS) -T $(LINKMAP) -o $@ $+ $(LIBS)

$(BUILD_DIR)/%.o: %.c Makefile
	$(CC) $(CFLAGS) $(OFLAGS) -o $@ -c $<

$(BUILD_DIR)/%.o: %.cpp Makefile
	$(CC) $(CFLAGS) $(OFLAGS) -o $@ -c $<

$(BUILD_DIR)/%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: $(STARTUP_DIR)/%.s
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR):
	mkdir $(BUILD_DIR)
