#########################################################################
#                      execloadLUT  1.3                                 #
#  Written by:                                                          #
#    M. Flynn, HFHS                                                     #
#                                                                       #
#  X-ray Imaging Lab, Henry Ford Health Systems, Detroit, MI            #
#                                                                       #
#  Simple script to exec the loadLUT application.                       #
#  loadLUT.exe can be easily executed directly with a shortcut having   #
#  the LUT directory path as an argument. However, the application      #
#  flashes a command window during a normal load and writes the messages#
#  reported in a log to the command window when an error occurs.        #
#  This script avoids the command window flash and allows a more        #
#  flexible method to respond to an error in loading the LUT.           #
#                                                                       #
#  Version 1.0   May 2005   - Initial release.                          #
#  Version 1.1   Oct 2006   - Adjusted to new directory structure.      #
#                Nov 2006   - Adjusted to new directory structure.      #
#                             C:/Program Files/HFHS/pacsDisplay         #
#  Version 1.2   Dec 2006   - Adjusted to new LUT-Library structure.    #
#  Version 1.3   Dec 2013   - Read LUTs path from LUTsDir.txt file.     #
#                Feb 2014   - Sets optional delay in config file.       #
#                                                                       #
#########################################################################

#console show
wm withdraw .
#########################################################################
set title "execloadLUT 1.3"
set copydate "Nov 2013"
# first tell the user what version he is using
#
puts "$title" 
#puts "Copyright:       Xray Imaging Research Laboratory"
#puts "                         Henry Ford Health System"
#puts "                         Detroit, MI"
#puts "                                         $copydate"
#
#########################################################################
#
#########################################################################
#  variables that need to be initialized
#
# Define the directory where execLoadLUT.exe is located.
# This must be in the same directory
# as for loadLUT.exe and the associated LUTs direcoty.

set loadLUT_dir [pwd]
source [file join $loadLUT_dir config_execLL.txt]

#**********************************************************************
# Get the common paths.
#
source getInstalledPaths.txt
#
#**********************************************************************
# Get the paths to the current system and linear folders.

set systemDir   [file join $userDir LUTs "Current System"]    ;# System LUT configuration
set linearDir   [file join $systemDir Linear]                 ;# Linear LUT configuration

#**********************************************************************
# interpret usage
if {$argc != 1} {
	tk_messageBox -title "loadLUT ERROR" \
                    -type  "ok"            \
	              -icon  "error"         \
	              -message $usage
	exit
} else {
	if {$argv == "system"} {
		set input $systemDir
	} elseif {$argv == "linear"} {
		set input $linearDir
	} else {
		tk_messageBox -title "loadLUT ERROR" \
            	        -type  "ok"            \
		              -icon  "error"         \
	      	        -message $usage
		exit
	}
}
#**********************************************************************
# delay if specified in config_execLL.txt

if {$delay > 0} {
	after $delay ;# pause before executing loadLUT
}

#**********************************************************************
#  run loadLUT.exe

if { [catch {exec loadLUT.exe $input} output]} {
	;# $output contains the same information as written to log.
	tk_messageBox -type "ok" \
	              -icon "error"          \
	              -title "loadLUT ERROR" \
	              -message $warning
} else {
	;# no message for a successful load
}
exit

