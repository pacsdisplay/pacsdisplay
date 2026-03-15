package provide app-loadLUTsingle 1.0

# ==============================================================================
# MODULE VERSION: 1.4
# ==============================================================================

#########################################################################
#                      LoadLUTsingle  1.4                               #
#  Written by:                                                          #
#    Philip M. Tchou                                                    #
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
#  Version 1.4   Feb 2026   - Revive for use within the pdQC            #
#                             within the pdQC application set           #
#                                                                       #
#########################################################################
#
#########################################################################
set title "LoadLUTsingle 1.4"
set copydate "Feb 2026"
# first tell the user what version he is using
#
puts "$title" 
#puts "Copyright:       Xray Imaging Research Laboratory"
#puts "                         Henry Ford Health System"
#puts "                         Detroit, MI"
#puts "                                         $copydate"
#
#########################################################################
# get configured parameters
#
source loadLUT-config.txt  ;# not packaged in starkit
#
#**********************************************************************

# get set apps_path for vfs and starkits/starpacks

set apps_path [file dirname [info script]]
set binpath $LIB	;# BIN directory for loadLUTsingle
source [file join $apps_path tcl xirlDefs-v06.tsp]	;# standard widget style

#**********************************************************************


set dev 1
set input 0
set info 0

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
		-text  LUT \
		-command Select
#
# initiation button
#
button .cmdbar1.load  \
		-text  LOAD \
		-command Load
#
#  help button
#
button .cmdbar1.help  \
		-text ?                 \
		-font {arial 8 bold} \
		-width 1 \
		-cursor hand2                   \
		-command Help_message
#
#  quit button
#
button .cmdbar1.quit  \
		-text QUIT \
		-command  Quit
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
		.cmdbar1.help  \
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
label .cmdbar3.label -text {Display Number:}
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
	global input dev binpath

	# check input values
	update
	if {$input == 0} {
		tk_messageBox -type ok -message "No LUT file selected."
		return
	}

	# run loadLUTtest.exe
	if {[exec [file join $binpath loadLUTsingle.exe] $dev $input]} {
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
#*********************************************************************
#  procedure to put up the information message
proc Help_message {}  {
	global info apps_path

	if {$info == 0}  {
		# open file for reading
		set input [file join $apps_path "INSTRUCTIONS.txt"]
		if [catch {open $input r} hfilein] {
			puts stderr "Cannnot open $input $hfilein"
			tk_messageBox -type ok -message "Cannot open $input $hfilein"
			return
		}
		
		set w .help
		toplevel $w
		wm title $w "Instructions for loadLUTsingle"
		wm iconname $w "Instructions"

		text $w.text -bg white -height 30 -width 65 -padx 10 \
					-relief sunken -setgrid 1 \
					-yscrollcommand "$w.scroll set"
		scrollbar $w.scroll -command "$w.text yview"

		pack $w.scroll -side right -fill y
		pack $w.text -expand yes -fill both

		foreach line [split [read $hfilein] \n] {
			$w.text insert end "$line\n"
		}
		close $hfilein

		$w.text configure -state disabled

		set info 1
	} else  {
		set info 0
		destroy .help
	}
}
#
#************************************************************************
# END loadLUTdemo
#************************************************************************
