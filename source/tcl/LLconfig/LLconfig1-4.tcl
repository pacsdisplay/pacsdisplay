#########################################################################
#                      LLconfig  1.4                                    #
#  Written by:                                                          #
#    Philip M. Tchou (pmtchou@umich.edu)                                #
#                                                                       #
#  X-ray Imaging Lab, Henry Ford Health Systems, Detroit, MI            #
#                                                                       #
#  This program builds a config file for LoadLUT v2.2 and supports up	#
#  to 4 displays.  The EDID functions require the getEDID executable be #
#  in the same directory.                                               #
#                                                                       #
#  Version 1.0   Jul 2005   - Initial release.                          #
#  Version 1.1   Oct 2006   - Adjusted to new directory structure and   #
#                             fixed an EDID error message typo.         #
#                Nov 2006   - Moved buttons to the bottom               #
#                           - Adjusted to new directory structure.      #
#                             C:/Program Files/HFHS/pacsDisplay         #
#                           - Fixed the capitalization of "LUTsearch"   #
#                             and "LDTsearch" in the configLL.txt file. #
#                Dec 2006   - Version included in window title.         #
#  Version 1.2   Jan 2007   - Code simplified.                          #
#                           - Default values included at start to make  #
#                             them more intuitive.                      #
#  Version 1.3   Apr 2007   - Updated to use getEDID v1.1               #
#  Version 1.4   Dec 2013   - Direcory to save configLL file now set    #
#                             in config-LLconfig.txt in the _NEW        #
#                             directory similar to other apps.          #
#                           - Added help button to view INSTRUCTIONS.txt#
#                                                                       #
#########################################################################
#
set title "LLconfig 1.4"
set copydate "Jan 2013"
# first tell the user what version he is using
#
puts "$title" 
#puts "Copyright:       Xray Imaging Research Laboratory"
#puts "                         Henry Ford Health System"
#puts "                         Detroit, MI"
#puts "                                         $copydate"
#
#########################################################################
#  misc variables that need to be initialized
#
set apps_path [file dirname [info script]]
source [file join $apps_path xirlDefs-v06.ts]  ;# standard widget style
source [file join $apps_path showManual.tsp]  ;# standard widget style
option add    *Button.width    16
#option add    *font     {arial 10}

package require img::bmp
image create photo iconHelp -format bmp -file [file join $apps_path help.bmp]
set info 0 ;# flag indicating whether help message is up or off.

#**********************************************************************
# get configured parameters
#
source config-LLconfig.txt  ;# not packages in exe file
#
#**********************************************************************
# set starting values

set defaultdir $lumFilePath       ;# from config-LLconfig.txt
set defaultconfig "configLL.txt"
set defaultLUT "linearLUT.txt"
set defaultModel "*"
set defaultSerial "*"
set EDIDtxt "getEDIDlog.txt"

for {set i 1} {$i <= 4} {incr i} {
	set Monitor($i) $defaultModel
	set Serial($i)  $defaultSerial
	set LUT($i)     $defaultLUT
}

set noloadflag	0
set noLOGflag	0
set noEDIDflag	0
set LUTsearchflag	0
set LDTsearchflag	0
set numDisplays	1

# configure window settings
#
#
wm title . $title
wm resizable . 0 0

# set up the command bar
#
#
frame .options -relief raised -borderwidth 2
frame .displayN -relief raised -borderwidth 2
frame .display1 -relief raised -borderwidth 2
frame .monitor1 -relief raised -borderwidth 2
frame .serial1 -relief raised -borderwidth 2
frame .lut1 -relief raised -borderwidth 2
frame .display2 -relief raised -borderwidth 2
frame .monitor2 -relief raised -borderwidth 2
frame .serial2 -relief raised -borderwidth 2
frame .lut2 -relief raised -borderwidth 2
frame .display3 -relief raised -borderwidth 2
frame .monitor3 -relief raised -borderwidth 2
frame .serial3 -relief raised -borderwidth 2
frame .lut3 -relief raised -borderwidth 2
frame .display4 -relief raised -borderwidth 2
frame .monitor4 -relief raised -borderwidth 2
frame .serial4 -relief raised -borderwidth 2
frame .lut4 -relief raised -borderwidth 2
frame .buildQuit -relief raised -borderwidth 2
pack .options .displayN .display1 .monitor1 .serial1 .lut1 \
		.display2 .monitor2 .serial2 .lut2 \
		.display3 .monitor3 .serial3 .lut3 \
		.display4 .monitor4 .serial4 .lut4 \
		.buildQuit \
		-side top -fill both
#
#**********************************************************************
#   loadLUT option flags
#**********************************************************************
#
#  noload option checkbox
#
checkbutton .options.checknoload \
			-text "noload" \
			-variable noloadflag
#
#  noLOG option checkbox
#
checkbutton .options.checknoLOG \
			-text "noLOG" \
			-variable noLOGflag
#
#  noEDID option checkbox
#
checkbutton .options.checknoEDID \
			-text "noEDID" \
			-variable noEDIDflag
#
#  LUTsearch option checkbox
#
checkbutton .options.checkLUTsearch \
			-text "LUTsearch" \
			-variable LUTsearchflag
#
#  LDTsearch option checkbox
#
checkbutton .options.checkLDTsearch \
			-text "LDTsearch" \
			-variable LDTsearchflag
#
#  HELP command
#
button .options.help        \
			-image iconHelp \
			-height [image height iconHelp] \
			-width  [image width  iconHelp] \
			-cursor hand2                   \
			-command "showManual 5"
#

#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .options.checknoload  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .options.checknoLOG  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .options.checknoEDID  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .options.checkLUTsearch  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .options.checkLDTsearch  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .options.help  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Number of Displays
#**********************************************************************
#
#  text variable to change the number of displays (1-4)
#
label .displayN.label -text "Number of displays: "
radiobutton .displayN.radio1 \
			-text 1 \
			-variable numDisplays \
			-value 1
radiobutton .displayN.radio2 \
			-text 2 \
			-variable numDisplays \
			-value 2
radiobutton .displayN.radio3 \
			-text 3 \
			-variable numDisplays \
			-value 3
radiobutton .displayN.radio4 \
			-text 4 \
			-variable numDisplays \
			-value 4
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .displayN.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .displayN.radio1   \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .displayN.radio2   \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .displayN.radio3   \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .displayN.radio4   \
                    -side left -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Display 1
#**********************************************************************
#
#  divider for Display 1
#
label .display1.label -text "DISPLAY #1"
#
#  get EDID monitor and serial number values 1
#
button .display1.getEDID  \
                    -text "GET EDID VALUES" \
                    -command "getEDID 1"
#
#  select LUT file 1
#
button .display1.selectLUT  \
			-text "SELECT LUT" \
			-width 12 \
			-command "selectLUT 1"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .display1.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .display1.selectLUT  \
                    -side right -padx 1m -pady 1m -fill x
pack   \
           .display1.getEDID  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Monitor 1
#**********************************************************************
#
#  text variable to change monitor descriptor 1
#
label .monitor1.label -text "    Monitor Descriptor 1: "
entry .monitor1.entry \
			  -justify left \
                    -width 40   \
                    -relief sunken \
                    -textvariable Monitor(1) 
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .monitor1.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .monitor1.entry  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Serial 1
#**********************************************************************
#
#  text variable to change serial number 1
#
label .serial1.label -text "    Serial Number 1: "
entry .serial1.entry \
			  -justify left \
                    -width 40   \
                    -relief sunken \
                    -textvariable Serial(1) 
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .serial1.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .serial1.entry  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   LUT 1
#**********************************************************************
#
#  text variable to change LUT file 1
#
label .lut1.label -text "    Default LUT file 1: "
entry .lut1.entry \
			  -justify left \
                    -width 40   \
                    -relief sunken \
                    -textvariable LUT(1) 
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .lut1.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .lut1.entry  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Display 2
#**********************************************************************
#
#  divider for Display 2
#
label .display2.label -text "DISPLAY #2"
#
#  get EDID monitor and serial number values 2
#
button .display2.getEDID  \
                    -text "GET EDID VALUES" \
                    -command "getEDID 2"
#
#  select LUT file 2
#
button .display2.selectLUT  \
			-text "SELECT LUT" \
 			-width 12 \
			-command "selectLUT 2"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .display2.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .display2.selectLUT  \
                    -side right -padx 1m -pady 1m -fill x
pack   \
           .display2.getEDID  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Monitor 2
#**********************************************************************
#
#  text variable to change monitor descriptor 1
#
label .monitor2.label -text "    Monitor Descriptor 2: "
entry .monitor2.entry \
			  -justify left \
                    -width 40   \
                    -relief sunken \
                    -textvariable Monitor(2) 
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .monitor2.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .monitor2.entry  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Serial 2
#**********************************************************************
#
#  text variable to change serial number 1
#
label .serial2.label -text "    Serial Number 2: "
entry .serial2.entry \
			  -justify left \
                    -width 40   \
                    -relief sunken \
                    -textvariable Serial(2) 
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .serial2.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .serial2.entry  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   LUT 2
#**********************************************************************
#
#  text variable to change LUT file 2
#
label .lut2.label -text "    Default LUT file 2: "
entry .lut2.entry \
			  -justify left \
                    -width 40   \
                    -relief sunken \
                    -textvariable LUT(2)
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .lut2.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .lut2.entry  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Display 3
#**********************************************************************
#
#  divider for Display 3
#
label .display3.label -text "DISPLAY #3"
#
#  get EDID monitor and serial number values 3
#
button .display3.getEDID  \
                    -text "GET EDID VALUES" \
                    -command "getEDID 3"
#
#  select LUT file 3
#
button .display3.selectLUT  \
			-text "SELECT LUT" \
			-width 12 \
			-command "selectLUT 3"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .display3.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .display3.selectLUT  \
                    -side right -padx 1m -pady 1m -fill x
pack   \
           .display3.getEDID  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Monitor 3
#**********************************************************************
#
#  text variable to change monitor descriptor 3
#
label .monitor3.label -text "    Monitor Descriptor 3: "
entry .monitor3.entry \
			  -justify left \
                    -width 40   \
                    -relief sunken \
                    -textvariable Monitor(3)
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .monitor3.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .monitor3.entry  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Serial 3
#**********************************************************************
#
#  text variable to change serial number 3
#
label .serial3.label -text "    Serial Number 3: "
entry .serial3.entry \
			  -justify left \
                    -width 40   \
                    -relief sunken \
                    -textvariable Serial(3)
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .serial3.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .serial3.entry  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   LUT 3
#**********************************************************************
#
#  text variable to change LUT file 3
#
label .lut3.label -text "    Default LUT file 3: "
entry .lut3.entry \
			  -justify left \
                    -width 40   \
                    -relief sunken \
                    -textvariable LUT(3)
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .lut3.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .lut3.entry  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Display 4
#**********************************************************************
#
#  divider for Display 4
#
label .display4.label -text "DISPLAY #4"
#
#  get EDID monitor and serial number values 4
#
button .display4.getEDID  \
                    -text "GET EDID VALUES" \
                    -command "getEDID 4"
#
#  select LUT file 4
#
button .display4.selectLUT  \
			-text "SELECT LUT" \
			-width 12 \
			-command "selectLUT 4"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .display4.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .display4.selectLUT  \
                    -side right -padx 1m -pady 1m -fill x
pack   \
           .display4.getEDID  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Monitor 4
#**********************************************************************
#
#  text variable to change monitor descriptor 4
#
label .monitor4.label -text "    Monitor Descriptor 4: "
entry .monitor4.entry \
			  -justify left \
                    -width 40   \
                    -relief sunken \
                    -textvariable Monitor(4)
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .monitor4.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .monitor4.entry  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Serial 4
#**********************************************************************
#
#  text variable to change serial number 4
#
label .serial4.label -text "    Serial Number 4: "
entry .serial4.entry \
			  -justify left \
                    -width 40   \
                    -relief sunken \
                    -textvariable Serial(4)
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .serial4.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .serial4.entry  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   LUT 4
#**********************************************************************
#
#  text variable to change LUT file 4
#
label .lut4.label -text "    Default LUT file 4: "
entry .lut4.entry \
			  -justify left \
                    -width 40   \
                    -relief sunken \
                    -textvariable LUT(4)
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .lut4.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .lut4.entry  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   Build, Reset, and Quit.
#**********************************************************************
#
# initiation button
#
button .buildQuit.bc  \
                    -text "BUILD CONFIG FILE" \
                    -command "BuildConfig"
#
# reset button
#
button .buildQuit.reset  \
			-text "RESET FORM" \
			-width 14 \
			-command "Reset"
#
#  quit button
#
button .buildQuit.quit  \
                    -text "QUIT" \
			  -width 5     \
                    -bg #304050 -fg #E0E0F4 \
                    -command  "Quit"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack  \
           .buildQuit.bc  \
                    -side left -padx 1m -pady 1m -fill x
pack  \
           .buildQuit.reset  \
                    -side left -padx 1m -pady 1m -fill x
pack  \
           .buildQuit.quit  \
                    -side right -padx 1m -pady 1m -fill x


#*********************************************************************
#  procedure to select the LUT
#
proc selectLUT {displayN} {
	global defaultdir LUT

	set LUT($displayN) [file tail [tk_getOpenFile -initialdir $defaultdir \
					-title "Select LUT file for Display #$displayN"]]
}


#*********************************************************************
#  procedure to get the EDID monitor and serial number for a display
#
proc getEDID {displayN} {
	global EDIDtxt Monitor Serial

	set Mon_Desc ""
	set 4_Digit_Serial ""
	set Ext_Serial ""

	set 4_serialflag 0
	set use_ext 1
	set ext_serialflag 0
	set mon_descflag 0

	if {[catch {exec getEDID.exe $displayN} output]} {
		;# $output contains the same information as written to log.
		tk_messageBox -type "ok" \
		              -icon "error"          \
		              -title "getEDID ERROR" \
		              -message "ERROR: Unable to retrieve EDID for display #$displayN"
		return
	}
	set line [split $output |]

	# 4-digit serial number
	set i 4
	if {[lindex $line $i] != ""} {
		set 4_serialflag 1
		set 4_Digit_Serial [lindex $line $i]
	}

	# extended serial number
	set i 5
	if {[lindex $line $i] != ""} {
		set ext_serialflag 1
		set Ext_Serial [lindex $line $i]
	}

	# monitor descriptor
	set i 6
	if {[lindex $line $i] != ""} {
		set mon_descflag 1
		set Mon_Desc [lindex $line $i]
	}


	#  Build output message
	set textmsg "EDID results for Display $displayN:\n"
	if {$mon_descflag} {
		append textmsg "- Monitor descriptor found ($Mon_Desc)\n"
	} else {
		append textmsg "- Monitor descriptor NOT FOUND\n"
	} 
	if {$4_serialflag} {
		append textmsg "- 4-digit S/N found ($4_Digit_Serial)\n"
	} else {
		append textmsg "- 4-digit S/N NOT FOUND\n"
	}
	if {$ext_serialflag} {
		append textmsg "- Extended S/N found ($Ext_Serial)\n"
	} else {
		append textmsg "- Extended S/N NOT FOUND\n"
		set use_ext 0
	}

	if {$4_serialflag && $ext_serialflag} {
		append textmsg "\nUse extended serial number?"
		set answer [tk_messageBox -type yesno -message $textmsg -icon question]
		if {$answer == "no"} {set use_ext 0}
	} else {
		tk_messageBox -type ok -message $textmsg
	}


	#  set new values

	set Monitor($displayN) $Mon_Desc
	if {$use_ext} {
		set Serial($displayN) $Ext_Serial
	} else {
		set Serial($displayN) $4_Digit_Serial
	}
}


#*********************************************************************
#  procedure to generate the LoadLUT config file
#
proc BuildConfig {} {
	global title defaultdir defaultconfig defaultLUT
	global noloadflag noLOGflag noEDIDflag LUTsearchflag LDTsearchflag numDisplays
	global Monitor Serial LUT defaultModel defaultSerial defaultLUT


	# check input values
	update


	# open output text file for writing
	set output [tk_getSaveFile -title "Select output config file"	\
		-initialfile $defaultconfig -initialdir $defaultdir]

	if {$output == ""} {
		return
	} else {
		set fileout [open $output w]
	}


	#  write config file
	puts $fileout "# $title - [clock format [clock seconds] -format "%m/%d/%y"]"
	puts $fileout "# "

	if {$noloadflag} {puts $fileout "/noload"}
	if {$noLOGflag} {puts $fileout "/noLOG"}
	if {$noEDIDflag} {puts $fileout "/noEDID"}
	if {$LUTsearchflag} {puts $fileout "/LUTsearch"}
	if {$LDTsearchflag} {puts $fileout "/LDTsearch"}

	puts $fileout "$numDisplays"

	for {set i 1} {$i <= $numDisplays} {incr i} {
		puts $fileout $i
		if {$Monitor($i) == ""} {
			set Monitor($i) $defaultModel
		}
		puts $fileout "\"$Monitor($i)\""

		if {$Serial($i) == ""} {
			set Serial($i) $defaultSerial
		}
		puts $fileout "\"$Serial($i)\""

		if {$LUT($i) == ""} {
			set LUT($i) $defaultLUT
		}
		puts $fileout "\"$LUT($i)\""
	}


	# close output files
	close $fileout

	tk_messageBox -type ok -message "Config file generated."
}


#**********************************************************************
# procedure to reset all values
#
proc Reset {} {
	global noloadflag noLOGflag noEDIDflag LUTsearchflag LDTsearchflag numDisplays
	global Monitor Serial LUT defaultModel defaultSerial defaultLUT

	set noloadflag	0
	set noLOGflag	0
	set noEDIDflag	0
	set LUTsearchflag	0
	set LDTsearchflag	0
	set numDisplays	1

	for {set i 1} {$i <= 4} {incr i} {
		set Monitor($i)	$defaultModel
		set Serial($i)	$defaultSerial
		set LUT($i)		$defaultLUT
	}

	update
}

#*********************************************************************
#  procedure to put up the information message
#  ----- NOT USED, CHANGED TO SHOWMANUAL -----
proc Help_message {}  {
	global info

	if {$info == 0}  {
		# open file for reading
		set input "INSTRUCTIONS.txt"
		if [catch {open $input r} hfilein] {
			puts stderr "Cannnot open $input $hfilein"
			tk-MessageBoxMod -type ok -message "Cannot open $input $hfilein"
			return
		}
		
		set w .help
		toplevel $w
		wm title $w "Instructions for lumResponse"
		wm iconname $w "Instructions"

		text $w.text -bg white -height 30 -relief sunken -setgrid 1 \
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
#**********************************************************************
# procedure to close open files and quit
#
proc Quit {} {
	exit
}

#************************************************************************
# END LutGenerate
#************************************************************************