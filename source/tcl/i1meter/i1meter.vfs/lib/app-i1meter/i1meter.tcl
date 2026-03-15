package provide app-i1meter 1.0

# ==============================================================================
# MODULE VERSION: 1.4
# ==============================================================================

#############################################################################
#							i1meter 1.4                                     #
#	Written by:																#
#	Michael J. Flynn														#
#	Nicholas B. Bevins														#
#																			#
#	Henry Ford Health Systems, Detroit, MI									#
#																			#
#	22 DEC 2013	Version 1.0													#
#			- Initial test version.											#
#	29 DEC 2013	Version 1.1													#
#			- Resets meterStatus to 0 after iOneQuit calls.					#
#			- Posts a message at the beginning about the meter.				#
#			- For mode changes, changes display to grey 0s.					#
#			- Added bindings to put values on the clipboard.				#
#			- Completed the INSTRUCTIONSm.txt file.							#
#	07 OCT 2019	Version 1.2													#
#			- Rewrite to remove dependencies on Expect						#
#			- Current spotread options only allow for one readout			#
#				- (Look at potential future releases of spotread for		#
#					coninuous output readings for scripting)				#
#	20 FEB 2026	Version 1.4													#
#			- Starkit version updates										#
#			- include dpi scaling for high dpi displays						#
#																			#
#############################################################################
#

#console show;#Comment this line (use for debugging)

set title "i1meter v1.4"
# first tell the user what version is running
#
puts "$title"
puts "Copyright:  Xray Imaging Research Laboratory"
puts "                Henry Ford Health System"
puts "                   Detroit, Michigan"
puts "             Feb 2026 - M. Flynn, N. Bevins"
#
#**********************************************************************
# Variable definitions and procedures from other files
# reference to 'apps_path directory to support wrapping with tclApp

source  config-meter.txt  ;# variable definitions (not wrapped)

set apps_path [file dirname [info script]]
set binpath $LIB	;# BIN directory for spotread
source [file join $apps_path tcl eyeoneUtil.tsp]	;# i1Display procedures
source [file join $apps_path tcl xirlDefs-v06.tsp]	;# standard widget style

#**********************************************************************
#   define application variables
# flags indicating on (1) or off (0).

set meter       i1DisplayPro
set meterStatus 0
set info        0
set ILcnt       1
set ioneLmode   lum  ;# lum (for luminance) or lux (for illuminance)
set ioneCmode   upvp ;# upvp (for u'v') or Cuv (for D65 difference)

#
#**********************************************************************
# setup frames for the window
#
wm title .  "$title"
#
# retrieve the dpi for scaling
#
set dpiscale [expr {[winfo pixels . 1i] / 96.0}]
#
# create a proc to scale all the sizes for the dpi
#
proc scaled {size} {global dpiscale; expr {int($size * $dpiscale)}}
#
#
frame .cmdbar -relief raised -borderwidth [scaled 2]
frame .spacer_bar -relief raised -borderwidth [scaled 2] -height [scaled 5]
frame .save_bar -relief raised -borderwidth [scaled 2]
pack .cmdbar .spacer_bar  -side top -fill both
#
#**********************************************************************
#   RADIO BUTTON SELECTIONS
#**********************************************************************

frame .cmdbar.modes -borderwidth [scaled 1] ;# packed in next section

# --- option to set luminance or illuminance modes
frame .cmdbar.modes.l -borderwidth [scaled 1] -relief groove
radiobutton .cmdbar.modes.l.lum -text "lum" -font {arial 8 bold} \
						-variable ioneLmode \
						-command  {changeMode $ioneLmode} \
						-value    lum
radiobutton .cmdbar.modes.l.illum -text "lux" -font {arial 8 bold} \
						-variable ioneLmode \
						-command  {changeMode $ioneLmode} \
						-value    lux

pack .cmdbar.modes.l.lum .cmdbar.modes.l.illum  -anchor w -side top

# --- option to set luminance or illuminance modes
frame .cmdbar.modes.c -borderwidth [scaled 1] -relief groove
radiobutton .cmdbar.modes.c.lum -text "u',v'" -font {arial 8 bold} \
						-variable ioneCmode \
						-command  {changeMode $ioneCmode} \
						-value    upvp
radiobutton .cmdbar.modes.c.illum -text "Cuv" -font {arial 8 bold} \
						-variable ioneCmode \
						-command  {changeMode $ioneCmode} \
						-value    Cuv

pack .cmdbar.modes.c.lum .cmdbar.modes.c.illum  -anchor w -side top

pack .cmdbar.modes.l .cmdbar.modes.c -side left
#**********************************************************************
# READ (formerly START), [STOP,] HELP, and QUIT in the top command bar
#**********************************************************************
#

button .cmdbar.start \
		-text " READ "      \
		-font {arial 8 bold} \
		-command {readMeter $ioneLmode}
		
button .cmdbar.help  \
		-text ?                 \
		-font {arial 8 bold} \
		-width [scaled 1] \
		-cursor hand2                   \
		-command "Help_message"

button .cmdbar.quit  \
		-text QUIT           \
		-font {arial 8 bold} \
		-command "MeterQuit ."

pack  .cmdbar.start .cmdbar.modes \
		-side left -padx [scaled 5] -pady [scaled 2] -fill x 
pack  .cmdbar.quit .cmdbar.help  \
		-side right -padx [scaled 5] -pady [scaled 2] -fill x
#
#**********************************************************************
#   LUMINANCE METER DISPLAY at window bottom
#**********************************************************************
#
set bgClr      #204080  ;# 'blueprint' blue
set hbgClr     #305090  ;# 'blueprint' blue highlight
set fgClr      #f0f0f0  ;# near white
set offgrey    #808080  ;# gray for values before starting.
set hlClr      #00ff00  ;# highlight color indicating value copied to clipboard.

set labelText(lum,upvp)  "CHROMATICITY (u',v')                     LUMINANCE, cd/m2"
set labelText(lum,Cuv)   "D65 Distance (C_u'v')                    LUMINANCE, cd/m2"
set labelText(lux,upvp)  "CHROMATICITY (u',v')                     ILLUMINANCE, lux"
set labelText(lux,Cuv)   "D65 Distance (C_u'v')                    ILLUMINANCE, lux"

frame .lumMeter  -height [scaled 140] -width [scaled 375] -relief sunken -bg $bgClr \
	           -borderwidth [scaled 10] -highlightthickness [scaled 1] -highlightbackground $fgClr
pack  .lumMeter

# --- meter model label ---
label .lumMeter.model -text $meter -font {arial 6 bold} \
                      -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.model -in .lumMeter -anchor nw -relx .00 -rely .00
 
# --- meter header labels ---
label .lumMeter.labels -text $labelText($ioneLmode,$ioneCmode) \
	                 -font {arial 8} -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.labels -in .lumMeter -anchor nw -relx .04 -rely .25

# --- meter average luminance main result ---
set ILavg_display [format %7.3f 0]
label .lumMeter.avg -textvariable ILavg_display -font {courier 16 bold} \
                    -bg $bgClr -fg $offgrey -padx [scaled 1] -pady [scaled 1]
place .lumMeter.avg -in .lumMeter -anchor nw -relx .65 -rely .45
bind  .lumMeter.avg <Button-3> {
	puts $ILavg_display
	clipboard clear
	clipboard append $ILavg_display
	.lumMeter.avg configure -fg $hlClr
	after 100 	.lumMeter.avg configure -fg $fgClr
}

bind  .lumMeter.avg <Shift-Button-3> {
	puts $ILavg_display
	clipboard clear
	clipboard append $ILavg_display 
	clipboard append \t
	clipboard append $CHRuAvg
	clipboard append \t
	clipboard append $CHRvAvg
	.lumMeter.avg configure -fg $hlClr
	after 100 	.lumMeter.avg configure -fg $fgClr
}

# --- meter color coordinates ---
set CHRavg_display "([format %5.4f 0],[format %5.4f 0])"
label .lumMeter.color -textvariable CHRavg_display -font {courier 12 bold} \
					  -bg $bgClr -fg $offgrey -padx [scaled 1] -pady [scaled 1]
place .lumMeter.color -in .lumMeter -anchor nw -relx .00 -rely .475
bind  .lumMeter.color <Button-3> {
	puts $CHRavg_display
	clipboard clear
	clipboard append $CHRavg_display
	.lumMeter.color configure -fg $hlClr
	after 100 .lumMeter.color configure -fg $fgClr
}

bind  .lumMeter.color <Shift-Button-3> {
	puts $CHRavg_display
	clipboard clear
	clipboard append $ILavg_display 
	clipboard append \t
	clipboard append $CHRuAvg
	clipboard append \t
	clipboard append $CHRvAvg
	.lumMeter.color configure -fg $hlClr
	after 100 	.lumMeter.color configure -fg $fgClr
}

# --- meter real time reponse at bottom ---
set ILval [format %8.3f 0]
label .lumMeter.val -textvariable ILval -font {courier 8 bold} \
                    -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.val -in .lumMeter -anchor nw -relx .3 -rely .85

# --- meter count for averages at bottom ---
label .lumMeter.num -textvariable avgN -font {courier 8 bold} \
                    -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.num -in .lumMeter -anchor nw -relx .1 -rely .85
# --- create a key binding to increase the averages on B1 ---
bind .lumMeter.num <Button-1> {incr avgN}
# --- create a key binding to decrease the averages on B3 ---
bind .lumMeter.num <Button-3> {set avgN [expr {max(1, [incr avgN -1])}]}
		
###########################################################################
#                  ----------- Procedures -----------
###########################################################################
#
#*********************************************************************
#Procedure to initialize the meter and start continuous reading.

proc readMeter {mode} {
	;# The Argyll spotread.exe program is used to read the meter.
	;# The i1DisplayPro uses the standard USB interface and doesn't need a driver.
	;# The spotread program has an -O option to return a single measurement and exit -
	;# this avoids the need to use the Expect package, which doesn't currently
	;# function in W10. The current version of i1meter reads only a single set 
	;# of averages and then reports is out. Subsequent readings require additional
	;# presses by the user. 

	global meter meterStatus i1yval fgClr srMode avgN iOneCover
	
	set srMode $mode
	
	if {$meter == "i1DisplayPro"} {
		set i1yval "n" ;# takes n|l NB: check on this for modern displays. l uses CCFL IPS, not LED
	} else {
		tk_messageBox \
			-type ok             \
			-title "FATAL ERROR" \
			-message "meter not set to i1DisplayPro"
		return 0
	}		

	;# Call the nit procedure and pass the luminance measure directly.
	for {set i 0} {$i < $avgN} {incr i 1} {
		if {[iOneRead] != 1 || $iOneCover == 1} {
			set    msg_i1 "Error: i1Display read utility\n"
			tk_messageBox \
				-type ok             \
				-title "FATAL ERROR" \
				-message $msg_i1
			return 0
		}
	}
	# ...configure IL window to "active" color format
	.lumMeter.avg configure    -fg $fgClr
	.lumMeter.color configure  -fg $fgClr
	
	set meterStatus 1
}
#*********************************************************************
#  handler to process each luminance value from the meter
#      Called from expect. 
#      Updates the meter
#
proc nit {lum} {

	global meter iLcalVal ILval ionex ioney avgN meterStatus
	global ILcnt ILavg ILval_display ioneu ionev CHRuAvg CHRvAvg
	global ILval_display ILavg_display CHRavg_display fgClr

	;#---> check the value and , if valid, apply calibrations

	if {$meter == "i1DisplayPro"} {

		;# In this case, the lum variable has the meter luminance reading
		;# Just need to format it here.

		if {$lum == "0" } {
			;# failed i1Display read
			iOneQuit
			set    msg_i1 "Error: no XYZ found in i1Display reading\n"
			append msg_i1 "(check ambient light cover position)"
			tk_messageBox -type ok -message $msg_i1
			return
		} else {
			set ILval $lum
			set ILval [expr $ILval * $iLcalVal]
			set ILval_display [format %8.3f $ILval]

			;# chromaticity u,v coordinates
			set CHRu $ioneu
			set CHRv $ionev
		}
	} else {
		tk_messageBox -type ok -message "Undefined Photometer type in LRconfig.txt"
	}

	;#---> if avgN indicates, accumulate and average values.
	;#     Otherwise accept the current values.
	;#     Chrominance is averages in u,v space (? perhaps should be X,Y).
	
	if {$ILcnt == 1 || $avgN == 1} {
		set ILavg $ILval
		set CHRuAvg $CHRu
		set CHRvAvg $CHRv
		;# update count for the next value
		;#       if $avgN is 1 we stay in this section and ILcnt has no effect.
		;#       if we are averaging, this section initializes the values
		if {$avgN == 1} {
			set ILavg_display [format %7.3f $ILavg]
			set CHRavg_display [uvFormat $CHRuAvg $CHRvAvg]
		} else {
			incr ILcnt
		}
	} else {
		;# This section is entered only if we are averaging (avgN>1)
		;# and the values have been initialized at ILctn=1.
		;# from 2 to avgN accumulate values

		if {$ILcnt > 1 && $ILcnt <= $avgN} {
			set ILavg   [expr $ILavg + $ILval]
			set CHRuAvg [expr $CHRuAvg + $CHRu]
			set CHRvAvg [expr $CHRvAvg + $CHRv]
		}

		;# ... for ILcnt = avgN compute the average and reset
		if {$ILcnt == $avgN} {
			set ILavg [expr $ILavg/$avgN]
			set CHRuAvg        [expr $CHRuAvg/$avgN]
			set CHRvAvg        [expr $CHRvAvg/$avgN]
			set ILavg_display  [format %7.3f $ILavg]
			set CHRavg_display [uvFormat $CHRuAvg $CHRvAvg]
			;# reset the count to begin a new average
			set ILcnt 1
		} else {
			;# update count for the next value
			incr ILcnt
		}
	}
	;# reset the color in case it was changed when copying to the clipboard.
	.lumMeter.avg configure    -fg $fgClr
	.lumMeter.color configure  -fg $fgClr

	update idletasks
}	
#*********************************************************************
#  compute and format u',v'

proc uvFormat {u v} {
	;# Compute the chromaticity coordinates (u',v' CIE1976) from x, y
	;# Current output from spotread already has chromaticity in u',v'
	global ioneCmode
		
	;# define the reference u',v' white point (D65)
	set xD65  0.31271 ;# 2 degree observer
	set yD65  0.32902 ;# 2 degree observer
	set upD65 0.19783 ;# 2 degree observer
	set vpD65 0.46833 ;# 2 degree observer

	;# compute up,vp
	#set up [expr 4.0*$x / (-2.0*$x + 12.0*$y +3.0) ]
	#set vp [expr 9.0*$y / (-2.0*$x + 12.0*$y +3.0) ]
	set up $u
	set vp $v
	
	if {$ioneCmode == "upvp"} {
		set uvFormat "([format %5.4f $up],[format %5.4f $vp])"
	} elseif {$ioneCmode == "Cuv"} {
		set uvFormat [expr sqrt( ($up-$upD65)**2 + ($vp-$vpD65)**2 )]
		set uvFormat [format %8.4f $uvFormat]
	} else {
		tk_messageBox \
			-type ok             \
			-title "ERROR" \
			-message "Error: invalid ioneCmode passed to uvFormat"
		return 0
	}
}

#*********************************************************************
#  procedure to change the meter mode: luminance or illuminance

proc changeMode {mode} {

	global ioneLmode ioneCmode meterStatus labelText
	global offgrey CHRavg_display ILavg_display
	
	if {$meterStatus != 0} {
		;# stop the meter
		iOneQuit
	}
	
	set ILavg_display [format %7.3f 0]
	if {$ioneCmode == "upvp"} {
		set CHRavg_display "([format %5.4f 0],[format %5.4f 0])"
	} elseif {$ioneCmode == "Cuv"} {
		set CHRavg_display  [format %8.4f 0]
	}
	
	.lumMeter.avg    configure -fg $offgrey
	.lumMeter.color  configure -fg $offgrey
	.lumMeter.labels configure -text $labelText($ioneLmode,$ioneCmode)	
	
}
#*********************************************************************
#  procedure to put up the information message
#
proc Help_message {}  {
	global info apps_path

	if {$info == 0}  {
		# open file for reading
		set input [file join $apps_path "INSTRUCTIONSm.txt"]
		if [catch {open $input r} hfilein] {
			puts stderr "Cannnot open $input $hfilein"
			tk_messageBox -type ok -message "Cannot open $input $hfilein"
			return
		}
		
		set w .help
		toplevel $w
		wm title $w "Instructions for i1meter"
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
#**********************************************************************
# procedure to quit
#
proc MeterQuit { w } {

	global meterStatus logFID info

	if {$meterStatus != 0} {
		;# stop the meter
		iOneQuit
	}
	
	if {$info != 0} {
		;# close the instructions window
		destroy .help
	}

	destroy .
}
#
#  END FILE	
