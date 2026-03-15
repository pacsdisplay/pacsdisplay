#########################################################################
#                      LoadLUTdemo  1.2                                 #
#  Written by:                                                          #
#    Philip M. Tchou (pmtchou@umich.edu)                                #
#                                                                       #
#  X-ray Imaging Lab, Henry Ford Health Systems, Detroit, MI            #
#                                                                       #
#  This program is a user interface for the loadLUTtest program.        #
#  loadLUT is a program to read display LUTs and load it into the       #
#  display card to set the luminance response.                          #
#                                                                       #
#  Version 1.0   May 2005   - Version included in window title.         #
#                Dec 2006   - Version included in window title.         #
#  Version 1.1   Dec 2006   - Adjusted to new LUT-Library structure.    #
#  Version 1.2   Dec 2013   - Read LUTs path from LUTsDir.txt file.     #
#                                                                       #
#########################################################################
#
#########################################################################
set title "LoadLUTdemo 1.1"
set copydate "Dec 2013"
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
option add *background  #E0E0E4    ;# defined consist with xirldefs-v06
option add    *font     {arial 10 bold}
#########################################################################
#  misc variables that need to be initialized
#
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

set dev 1
set input 0

# configure window settings
#
#
wm title . $title
wm resizable . 0 0

# set up the command bar
#
#
frame .cmdbar1 -relief raised -borderwidth 2
frame .cmdbar2 -relief raised -borderwidth 2
frame .cmdbar3 -relief raised -borderwidth 2
pack .cmdbar1 .cmdbar2 .cmdbar3 -side top -fill both
#
#**********************************************************************
#   COMMAND BAR 1: select lut, display, load, and quit.
#**********************************************************************
#
# file select button
#
button .cmdbar1.sel \
	-text  "SELECT LUT" \
	-command "Select"
#
# initiation button
#
button .cmdbar1.load  \
                    -text  LOAD \
                    -command "Load"
#
#  quit button
#
button .cmdbar1.quit  \
                    -text QUIT \
                    -command  "Quit"
#
pack  \
           .cmdbar1.sel  \
                    -side left -padx 1m -pady 1m -fill x
#
pack  \
           .cmdbar1.load  \
                    -side left -padx 1m -pady 1m -fill x
#
pack  \
           .cmdbar1.quit  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   COMMAND BAR 2: LUT File
#**********************************************************************
#
#  text variable to include the name of the display
#
label .cmdbar2.label -text {LUT File:}
entry .cmdbar2.back \
			  -justify left \
                    -width 20   \
                    -relief sunken \
                    -textvariable input 
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .cmdbar2.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .cmdbar2.back   \
                    -side right -padx 1m -pady 1m -fill x

#
#**********************************************************************
#   COMMAND BAR 3: Display Number
#**********************************************************************
#
#  text variable to change the ambient luminence in cd/m^2
#
label .cmdbar3.label -text {Display Number =}
entry .cmdbar3.back \
			  -justify right \
                    -width 6   \
                    -relief sunken \
                    -textvariable dev 
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .cmdbar3.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .cmdbar3.back   \
                    -side right -padx 1m -pady 1m -fill x

#*********************************************************************
#  procedure to select and open the luminance data file
#
proc Select {} {
	global input lumFilePath

	# select new file
	set input2 [tk_getOpenFile -title "Select INPUT file" -initialdir $lumFilePath]
	if {$input2 == ""} {
		return
	} else {
		set input $input2
	}
}

#*********************************************************************
#  procedure to load the LUT
#
proc Load {} {
	global input dev

	# check input values
	update
	if {$input == 0} {
		tk_messageBox -type ok -message "No LUT file selected."
		return
	}

	# run loadLUTtest.exe
	if {[exec loadLUTtest.exe $dev $input]} {
		set error 1
	} else {
		set error 0
	}

#	catch {exec loadLUTtest.exe $dev $input &} error

	if {$error == 0} {
		tk_messageBox -type ok -message \
			"loadLUT process completed successfully.\nCheck log file to confirm."
	} else {
		tk_messageBox -type ok -message \
			"ERROR: loadLUT did not complete successfully.\nCheck log file."
	}
}

#**********************************************************************
# procedure to close open files and quit
#
proc Quit {} {
	exit
}

#************************************************************************
# END loadLUTdemo
#************************************************************************