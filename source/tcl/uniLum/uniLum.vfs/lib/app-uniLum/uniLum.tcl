package provide app-uniLum 1.0

# ==============================================================================
# MODULE VERSION: 1.2
# ==============================================================================

#############################################################################
#							uniLum 1.2										#
#	Written by:																#
#	Nicholas B. Bevins														#
#																			#
#	Henry Ford Health, Detroit, MI											#
#																			#
#	09 MAY 2022	Version 1.0													#
#			-	Initial version												#
#			-	Based on i1meter v1.2										#
#			-	Allows for 9-point uniformity meas't w 1, 3, 18 GLs			#
#			-	Outputs Luni.txt file with results in tsv format			#
#	08 JAN 2025	Version 1.1													#
#			-	Update to remove adding of Lamb to readings (still use for 	#
#				uniformity calcs)											#
#			-	Add ability for external measurements						#
#	17 FEB 2026	Version 1.2													#
#			-	Update to starkit version
#			-	Add scaling for high dpi systems
#																			#
#############################################################################
#

#console show;#Comment this line (use for debugging)

set title "uniLum v1.2"
# first tell the user what version is running
#
puts "$title"
puts "Copyright:  Xray Imaging Research Laboratory"
puts "                   Henry Ford Health"
puts "                   Detroit, Michigan"
puts "                   Feb 2026 N. Bevins"
#
#**********************************************************************
# Variable definitions and procedures from other files
# reference to 'apps_path directory to support wrapping starkits

source uniConfig.txt  ;# variable definitions (not wrapped)

set apps_path [file dirname [info script]]
set binpath $LIB	;# BIN directory for spotread
source [file join $apps_path tcl eyeoneUtil.tsp]	;# i1Display procedures
source [file join $apps_path tcl xirlDefs-v06.tsp]	;# standard widget style

#**********************************************************************
#   define application variables
# flags indicating on (1) or off (0).

set meter		i1DisplayPro	;# default meter, currently only support the one
set meterStatus	0		;# initialize the meter status to not reading (sort of n/a wo Expect)
set info		0		;# initialize the help window to off
set Lcnt		1		;# initialize the count of luminance values to 1 (for averaging)
set ioneLmode	lum		;# lum (for luminance) or lux (for illuminance)
set ioneCmode	upvp	;# upvp (for u'v') or Cuv (for D65 difference)
set uniPos		0		;# initial position for uniformity measure
set uniB		0		;# gray level of the meas't window background
set dim(h)		750		;# default meas't window height
set dim(w)		750		;# default meas't window width
set dim(td)		200		;# pixel diameter of target circle
set uniDataReady	0	;# uniformity data ready to be written
set uniDataSaved	0	;# uniformity data is saved

# set the measurement order (w NA as the 0th index)
set order {NA UL UC UR CR CC CL LL LC LR}


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

frame .cmdbar	-relief flat 	-borderwidth [scaled 2]
frame .name		-relief flat	-borderwidth [scaled 2]
pack .cmdbar .name  -side top -fill both

# name the frame for the measurement window
set w .uni


#**********************************************************************
#   RADIO BUTTON SELECTIONS
#**********************************************************************

frame .cmdbar.modes -borderwidth [scaled 1] ;# packed in next section

# --- option to set the number of measurement locations (5-point measures
# --- the corners and center, 9-point the corners, edges, and center) 
#frame .cmdbar.modes.u -borderwidth 1 -relief groove
#radiobutton .cmdbar.modes.u.five -text "5-point" -font {arial 8 bold} \
						-variable unimode	\
						-cursor hand2 		\
						-value    5
#radiobutton .cmdbar.modes.u.nine -text "9-point" -font {arial 8 bold} \
						-variable unimode	\
						-cursor hand2 		\
						-value    9

#pack .cmdbar.modes.u.five .cmdbar.modes.u.nine  -anchor w -side top

# --- option to set the number of luminance steps
frame .cmdbar.modes.l -borderwidth [scaled 1] -relief groove
radiobutton .cmdbar.modes.l.one -text "1-level" -font {arial 8 bold} \
						-variable Lsteps	\
						-cursor hand2 		\
						-value    1			\
						-command {external 0}
radiobutton .cmdbar.modes.l.three -text "3-level" -font {arial 8 bold} \
						-variable Lsteps	\
						-cursor hand2 		\
						-value    3			\
						-command {external 0}
radiobutton .cmdbar.modes.l.egtn -text "18-level" -font {arial 8 bold} \
						-variable Lsteps	\
						-cursor hand2 		\
						-value    18		\
						-command {external 0}
radiobutton .cmdbar.modes.l.ext -text "External" -font {arial 8 bold} \
						-variable Lsteps	\
						-cursor hand2 		\
						-value    "External"		\
						-command {external 1}

pack .cmdbar.modes.l.one .cmdbar.modes.l.three .cmdbar.modes.l.egtn .cmdbar.modes.l.ext -anchor w -side top

#  .cmdbar.modes.u (add to next line to reinclude)
pack .cmdbar.modes.l -side left
#**********************************************************************
# IMAGE, READ, STOP, HELP, and QUIT in the top command bar
#**********************************************************************
#

# --- frame to hold the measurement and options buttons
frame .cmdbar.meas

# --- frame to hold the image, read, and save buttons
frame .cmdbar.meas.imgrdsv

button .cmdbar.meas.imgrdsv.image		\
		-text IMAGE						\
		-font {arial 8 bold}			\
		-cursor hand2 					\
		-command {image $w}

button .cmdbar.meas.imgrdsv.read		\
		-text READ						\
		-font {arial 8 bold}			\
		-cursor hand2 					\
		-state disabled					\
		-command {uniformity $Lsteps}

button .cmdbar.meas.imgrdsv.save		\
		-text SAVE						\
		-font {arial 8 bold}			\
		-cursor hand2 					\
		-state disabled					\
		-command {if {$uniDataReady == 1} [uniDataSave $uniLavg]}

# initialize the pause variable
# the command toggles between 0/1
set pause 0
button .cmdbar.meas.pause				\
		-text \u23F8					\
		-font {arial 8 bold}			\
		-cursor hand2 					\
		-state disabled					\
		-command {playpause}

# --- frame to hold the help and quit buttons
frame .cmdbar.helpquit
		
button .cmdbar.helpquit.help			\
		-text ?							\
		-font {arial 8 bold}			\
		-width [scaled 2]				\
		-cursor hand2					\
		-command "Help_message"

button .cmdbar.helpquit.quit			\
		-text QUIT						\
		-font {arial 8 bold}			\
		-cursor hand2					\
		-command "MeterQuit ."

# --- pack helpquit
pack .cmdbar.helpquit.quit .cmdbar.helpquit.help 	\
		-side top -pady [scaled 5] -anchor e

pack .cmdbar.helpquit -side right -padx [scaled 5] -pady [scaled 2] -fill x 

# --- pack imgrdsv
pack .cmdbar.meas.imgrdsv.image .cmdbar.meas.imgrdsv.read	\
			.cmdbar.meas.imgrdsv.save						\
			-side left -padx [scaled 5] -pady [scaled 2] -fill x
			
# --- pack meas
pack .cmdbar.meas.imgrdsv .cmdbar.meas.pause			\
			-side top -pady [scaled 5]
			
pack .cmdbar.modes .cmdbar.meas 					\
			-side left -padx [scaled 5] -pady [scaled 2] -fill x 
			
# --- frame to hold the display name
frame	.name.disp

label	.name.disp.lab		\
		-text "Display ID"	\
		-font {arial 8 bold}

entry	.name.disp.id			\
		-width 25				\
		-textvariable dispID	\
		-font {arial 8 bold}
		
pack .name.disp.lab .name.disp.id -side left -padx 5 -pady 2 -anchor nw

# --- frame to hold the Lamb value
frame	.name.lamb

label	.name.lamb.lab			\
		-text "Lamb"			\
		-font {arial 8 bold}

entry	.name.lamb.val			\
		-width	8				\
		-textvariable Lamb		\
		-font {arial 8 bold}
		
pack .name.lamb.lab .name.lamb.val -side left -padx [scaled 5] -pady [scaled 2] -anchor ne	

# --- pack the disp id and lamb
pack .name.disp .name.lamb -side left

#
#**********************************************************************
#   METER DISPLAY at window bottom
#**********************************************************************
#
set bgClr      #204080  ;# 'blueprint' blue
set hbgClr     #305090  ;# 'blueprint' blue highlight
set fgClr      #f0f0f0  ;# near white
set offgrey    #808080  ;# gray for values before starting.
set hlClr      #00ff00  ;# highlight color indicating value copied to clipboard.

set labelText(lum,upvp)  "LUMINANCE, cd/m\u00B2"

# --- unicode depictions of uniformity image ---
set unitext(0) "\u25A0 \u25A0 \u25A0\n\u25A0 \u25A0 \u25A0\n\u25A0 \u25A0 \u25A0"	;# NA
set unitext(1) "\u25A1 \u25A0 \u25A0\n\u25A0 \u25A0 \u25A0\n\u25A0 \u25A0 \u25A0"	;# UL
set unitext(2) "\u25A0 \u25A1 \u25A0\n\u25A0 \u25A0 \u25A0\n\u25A0 \u25A0 \u25A0"	;# UC
set unitext(3) "\u25A0 \u25A0 \u25A1\n\u25A0 \u25A0 \u25A0\n\u25A0 \u25A0 \u25A0"	;# UR
set unitext(4) "\u25A0 \u25A0 \u25A0\n\u25A0 \u25A0 \u25A1\n\u25A0 \u25A0 \u25A0"	;# CR
set unitext(5) "\u25A0 \u25A0 \u25A0\n\u25A0 \u25A1 \u25A0\n\u25A0 \u25A0 \u25A0"	;# CC
set unitext(6) "\u25A0 \u25A0 \u25A0\n\u25A1 \u25A0 \u25A0\n\u25A0 \u25A0 \u25A0"	;# CL
set unitext(7) "\u25A0 \u25A0 \u25A0\n\u25A0 \u25A0 \u25A0\n\u25A1 \u25A0 \u25A0"	;# LL
set unitext(8) "\u25A0 \u25A0 \u25A0\n\u25A0 \u25A0 \u25A0\n\u25A0 \u25A1 \u25A0"	;# LC
set unitext(9) "\u25A0 \u25A0 \u25A0\n\u25A0 \u25A0 \u25A0\n\u25A0 \u25A0 \u25A1"	;# LR

frame .lumMeter  -height [scaled 140] -width [scaled 350] -relief flat -bg $bgClr \
	           -borderwidth [scaled 10] -highlightthickness [scaled 1] -highlightbackground $fgClr
pack  .lumMeter

# --- meter model label ---
label .lumMeter.model -text $meter -font {arial 6 bold} \
                      -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.model -in .lumMeter -anchor nw -relx .00 -rely .00
 
# --- meter header labels ---
label .lumMeter.labels -text $labelText($ioneLmode,$ioneCmode) \
	                 -font {arial 8 bold} -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.labels -in .lumMeter -anchor nw -relx .10 -rely .25

# --- meter average luminance main result ---
set Lavg_display [format %7.3f 0]
label .lumMeter.avg -textvariable Lavg_display -font {courier 16 bold} \
                    -bg $bgClr -fg $offgrey -padx [scaled 1] -pady [scaled 1]
place .lumMeter.avg -in .lumMeter -anchor nw -relx .15 -rely .45

# --- uniformity measurement ---
set unitext_disp $unitext($uniPos)
label .lumMeter.unitxt -textvariable unitext_disp -font {courier 23 bold} \
					  -bg $bgClr -fg $offgrey -padx [scaled 1] -pady [scaled 1]
place .lumMeter.unitxt -in .lumMeter -anchor nw -relx .625 -rely .00

# --- meter real time reponse at bottom ---
set Lval [format %8.3f 0]
label .lumMeter.val -textvariable Lval -font {courier 8 bold} \
                    -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.val -in .lumMeter -anchor nw -relx .25 -rely .85

# --- meter count for averages at bottom --- 
label .lumMeter.num -text "\# avg:" -font {courier 8 bold} \
                    -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.num -in .lumMeter -anchor nw -relx .05 -rely .85

# --- meter count for averages at bottom --- 
label .lumMeter.avgn -textvariable avgN -font {courier 8 bold} \
                    -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.avgn -in .lumMeter -anchor nw -relx .2 -rely .85
# --- create a key binding to increase the averages on B1 ---
bind .lumMeter.avgn <Button-1> {incr avgN}
# --- create a key binding to decrease the averages on B3 ---
bind .lumMeter.avgn <Button-3> {set avgN [expr {max(1, [incr avgN -1])}]}

# --- display label at bottom
label .lumMeter.delaylab -text "delay:" -font {courier 8 bold} \
		                    -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.delaylab -in .lumMeter -anchor nw -relx .60 -rely .85			

# --- display timer at bottom ---
label .lumMeter.delay -textvariable delay -font {courier 8 bold} \
                    -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.delay -in .lumMeter -anchor ne -relx .81 -rely .85

# --- display units at bottom ---
label .lumMeter.delayu -text "s" -font {courier 8 bold} \
                    -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.delayu -in .lumMeter -anchor nw -relx .80 -rely .85

# --- display adjust up at bottom ---
label .lumMeter.delayup -text "\u25B2" -font {courier 8 bold} \
		                    -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.delayup -in .lumMeter -anchor nw -relx .85 -rely .85
# --- create a key binding to increase the delay on B1 ---
bind .lumMeter.delayup <Button-1> {incr delay}

# --- display adjust down at bottom ---
label .lumMeter.delaydown -text "\u25BC" -font {courier 8 bold} \
		                    -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.delaydown -in .lumMeter -anchor nw -relx .88 -rely .85
# --- create a key binding to decrease the delay on B1 ---
bind .lumMeter.delaydown <Button-1> {boundDelay [incr delay -1]}

###########################################################################
#                  ----------- Procedures -----------
###########################################################################
#
#*********************************************************************
# process to change between internal and external measurements
proc external {flag} {
	global w fgClr offgrey unitext
	
	# if the passed flag is 1, switch to external measurements
	if {$flag == 1} {
		# close the image window, if it exists
		if {[winfo exists $w]} {
			destroy $w
			variable Labort 1
		}
		
		# disable the image button from creating a window
		.cmdbar.meas.imgrdsv.image configure -state disabled
		# make the read button available
		.cmdbar.meas.imgrdsv.read configure -state normal
		# recolor the unitxt display
		.lumMeter.unitxt configure  -fg $fgClr
		# allow delay adjustments
		delayAdj 1
		# set the measurement to the first one
		variable unitext_disp $unitext(0)
		
		# set a variable to flag that the measurements are external
		variable extmeas 1
		
	} elseif {$flag == 0} {
		# if the image window is not open, reinitialize things
		# identical to what happens if the image window is closed
		if {![winfo exists $w]} {
			.cmdbar.meas.imgrdsv.image configure -state normal
			.cmdbar.meas.imgrdsv.read configure -state disabled
			variable unitext_disp $unitext(0)
			.lumMeter.unitxt configure  -fg $offgrey
			variable Labort 1
			delayAdj 1
		}
		# if the window is already open, just leave be
		
		# set a variable to flag that the measurements are internal
		variable extmeas 0
	}
}

proc image {w} {
	global uniB dim title uniL Lsteps uniPos fgClr offgrey
	
	# create a new toplevel window for the measurements
	toplevel $w
	
	# retitle the window
	wm title $w "$title: Luminance Uniformity"
	
	# init with background
	canvas $w.can  -width $dim(w) -height $dim(h)
	pack $w.can
	# create a background region to hide things
	$w.can create rectangle 0 0 [expr $dim(w)+4] [expr $dim(h)+4] \
				-width	0			\
				-fill	[grayhex 0] \
				-tags	{bkgd}
	
	# create meas't region
	$w.can create rectangle [rectpos $uniPos]					\
				-width		0									\
				-fill		[grayhex [lindex $uniL($Lsteps) 0]]	\
				-tags		{meast all}
				
	# create target indicated region
	$w.can create rectangle [rectpos $uniPos]	\
				-width		6					\
				-outline	[grayhex [expr ($uniB+128)%255]]		\
				-fill		[grayhex 0]			\
				-tags		{rtarget target all}
	$w.can create oval 		[ovalpos $uniPos]	\
				-width		6					\
				-outline	[grayhex [expr ($uniB+128)%255]]		\
				-fill		[grayhex 0]			\
				-tags		{otarget target all}
				
	
	#  set start to indicate that image initialization is done
	set start 1
	
	# position the boxes in position 1
	repos 1

	# set the command window to always be visible
	wm attributes . -topmost 1
	focus -force $w
	
	# disable the image button from creating another window
	.cmdbar.meas.imgrdsv.image configure -state disabled
	# make the read button available
	.cmdbar.meas.imgrdsv.read configure -state normal
	# recolor the unitxt display
	.lumMeter.unitxt configure  -fg $fgClr
	
	# create a binding to resize everything when the window size changes
	bind $w <Configure> {resize %w %h}
	
	# create binding to reset everything if the display window is closed
	bind $w <Destroy> {
		.cmdbar.meas.imgrdsv.image configure -state normal
		.cmdbar.meas.imgrdsv.read configure -state disabled
		variable unitext_disp $unitext(0)
		.lumMeter.unitxt configure  -fg $offgrey
		variable Labort 1
		delayAdj 1
	}
	
}

# process to take a value from 0-255 and return a hexidecimal equivalent
proc grayhex {grayval} {
	set grayhex [format %02x [bound $grayval]]
	set grayHex #$grayhex$grayhex$grayhex

	return $grayHex
}

# process to truncate values outside 0-255
proc bound {num} {
	if {$num > 255} {set num 255}
	if {$num < 0  } {set num 0  }
	return $num
}

# set a lower bound for the delay timer (1 sec)
proc boundDelay {t} {
	if {$t < 1  } {variable delay 1}
}

# alter the play/pause button and variable
proc playpause {} {
	global pause
	
	set pause [expr {$pause ? 0 : 1}]
	if {$pause==1} {
		.cmdbar.meas.pause configure -text \u25B6
	} else {
		.cmdbar.meas.pause configure -text \u23F8
	}
}

# show/hide delay adjustments
proc delayAdj {i} {
	if {$i == 1} {
		place .lumMeter.delayup -in .lumMeter -anchor nw -relx .85 -rely .85
		place .lumMeter.delaydown -in .lumMeter -anchor nw -relx .88 -rely .85
	} elseif {$i == 0} {
		place forget .lumMeter.delayup
		place forget .lumMeter.delaydown
	}
}

# process to take a position i (1-9) and return rectangle coordinates
# for the measurement area.
proc rectpos {i} {
	global dim w
	
	if {$i >= 0 && $i < 10} {
		# increment i if i==0 (NA pos) to put in the upper left
		if {$i == 0} {incr i}
		
		# set the x and y indicies each from 0-2 where xi = 0 is 
		# the left and yi = 0 is the top
		# the x is tricky - it needs to reverse order for the middle row
		set yi [expr int(($i-1)/3)]
		set xi [expr (($i-1)%3-1+(-1)**$yi)*(-1)**$yi]
		
		set x1 [expr $xi*($dim(w)+4)/3]
		set x2 [expr ($xi+1)*($dim(w)+4)/3]
		set y1 [expr $yi*($dim(h)+4)/3]
		set y2 [expr ($yi+1)*($dim(h)+4)/3]
		return [list $x1 $y1 $x2 $y2]
	} else {
		puts "invalid position"
	}
}

# process to take a position i (1-9) and return the position of the 
# oval at the center of the target region
proc ovalpos {i} {
	global dim w
	
	if {$i >= 0 && $i < 10} {
		# increment i if i==0 (NA pos) to put in the upper left
		if {$i == 0} {incr i}
	
		# call the rectpos to get the rect coordinates
		set coor	[rectpos $i]
		# calc the center of the rect based on width and height
		set rcx		[expr [lindex $coor 0]/2+[lindex $coor 2]/2]
		set rcy		[expr [lindex $coor 1]/2+[lindex $coor 3]/2]
		# calc the bounding box coordinates
		set x1	[expr $rcx-$dim(td)/2]
		set x2	[expr $rcx+$dim(td)/2]
		set y1	[expr $rcy-$dim(td)/2]
		set y2	[expr $rcy+$dim(td)/2]
		
		return [list $x1 $y1 $x2 $y2]
	} else {
		return
	}
}

# process to reposition the target and measurement region to position i
proc repos {i} {
	global w unitext
	
	# update the uniPos variable
	variable uniPos $i
	
	# update the display
	variable unitext_disp $unitext($i)
	
	# set the new coordinates for the different regions
	$w.can coords meast		[rectpos $i]
	$w.can coords rtarget	[rectpos $i]
	$w.can coords otarget	[ovalpos $i]
	
	# arrange the content (assumed that on repos, the target should
	# raise to the top, and the meast box drops to the back)
	# uniPos 0 should hide both in position 1
	if {$i == 0} {
		$w.can lower target
	} else {
		$w.can raise target
	}
	$w.can lower meast
}

# process to reposition measurement region to position i for external measurements
proc reposext {i} {
	global unitext
	
	# update the uniPos variable
	variable uniPos $i
	
	# update the display
	variable unitext_disp $unitext($i)
}


# process to resize the canvas based on a new window size
proc resize {w2 h2} {
	global dim w uniPos
	
	# account for the extra pixels along the edges from the winfo
	set w2 [expr $w2-4]; set h2 [expr $h2-4]
	
	# if the new width/height are different, resize the canvas
	# and move the object
	if {$w2 != $dim(w) || $h2 != $dim(h)} {
		# determine ratio of new width & height to old
		# account for the border width to properly scale
		set wratio [expr ($w2)/($dim(w)+0.0)]
		set hratio [expr ($h2)/($dim(h)+0.0)]
		
		# overwrite the old w and h variables
		set dim(w) $w2
		set dim(h) $h2
		
		# redraw the canvas with the new width and height
		$w.can configure -width $dim(w) -height $dim(h)
		
		# scale and position the targets/meast regions
		$w.can scale bkgd	0	0  $wratio $hratio
		repos	$uniPos		
		
	} else {
		# leave the canvas and position as-is
	}
}

proc countdown {t def} {
    global ioneLmode delay pause Labort
	
	variable delay $t
	if {$t == -1} {
		variable delay $def
		variable countDone 1
		return
	} 
	if {$pause != 1} {
		incr t -1
	}
    set id [after 1000 [list countdown $t $def]]
	if {$Labort==1} {
		after cancel $id
		variable delay $def
		variable countDone 1
		return
	}
}

proc uniformity {steps} {
	global uniL ioneLmode w delay delay_text Lamb
	global uniLavg Lavg uniDataReady uniDataSaved
	global unimld uniludm ludmmax mldmax Labort extmeas
	
	# for the commands involving the measurement window, only perform them
	# for internal measurments. use an if statement to limit them with this
	# syntax: if {$extmeas != 1} { command }
	
	# check if there's unsaved data
	if {$uniDataReady == 1 && $uniDataSaved != 1} {
		set    unsavmsg "There's unsaved uniformity data.\n"
		append unsavmsg "Proceeding will overwrite data.\n"
		append unsavmsg "Do you want to proceed?"
		set answer [tk_messageBox -type yesno \
					-title "Warning: Unsaved Data"	\
					-message $unsavmsg]
		switch -- $answer {
			yes {}
			no {return}
		}
	}
	
	# initialize values
	set Lnum 0		;# counter to know which step we're on
	set Labort 0	;# variable to flag when the meas't window is destroyed
	set uniLavg [dict create]	;# clear the uniLavg dict
	set uniludm [dict create]
	set unimld [dict create]
	
	# disable the read and save buttons
	# both will be enabled after the measurements are complete
	.cmdbar.meas.imgrdsv.read configure -state disabled
	.cmdbar.meas.imgrdsv.save configure -state disabled
	
	# enable the play/pause button
	.cmdbar.meas.pause configure -state normal
	
	# disable resizing to lock in the current window
	# it will be reenabled after the measurements are complete
	if {$extmeas != 1} {wm resizable $w 0 0}
	
	# disable delay adjustments
	delayAdj 0
	
	# begin with the data collection
	# check if the auto flag is checked and proceed accordingly
	for {set i 1} {$i <= 9} {incr i} {
		if {$Labort == 1} {return}
		if {$extmeas != 1} {repos $i}
		if {$extmeas == 1} {reposext $i}
		variable countDone 0
		# record the default delay to pass to the countdown (for reset)
		variable def $delay
		# call the countdown proc, passing delay and the def. value
		countdown $delay $def
		# wait for the counter to finish
		vwait countDone
		# exit the proc if the window is closed
		if {$Labort == 1} {return}
		# lower the target, raise the meast box
		if {$extmeas != 1} {$w.can lower target}
		if {$extmeas != 1} {$w.can raise meast}
		# enter a foreach loop to measure each level
		foreach gl $uniL($steps) {
			if {$Labort == 1} {return}
			if {$extmeas != 1} {$w.can itemconfigure meast -fill [grayhex $gl]}
			# read the meter and get a new Lavg value
			readMeter $ioneLmode
			# store the measurements in a dict  
			# each value is a list of luminance values, with each key
			# equal to the gray level
			dict lappend uniLavg $gl [expr $Lavg]
		}
	}
	
	# calculate the ludm and mld
	ludmmld $uniLavg
	
	# calculate the max ludm/mld
	set ludmmax	[dictmax $uniludm]
	set mldmax	[dictmax $unimld]
	
	# reset and move to position 1 (UL)
	if {$extmeas != 1} {repos 1}
	
	set    donemsg "Uniformity Measurement Complete.\n"
	append donemsg "Do you wish to view the results?"
	set answer [tk_messageBox -type yesno \
				-title "Measurement Complete"	\
				-message $donemsg]
	switch -- $answer {
		yes {uniDataView $uniLavg}
		no {}
	}
	
	# set a variable to flag there is data to save
	set uniDataReady 1
	set uniDataSaved 0
	
	# enable saving
	.cmdbar.meas.imgrdsv.save configure -state normal
	
	# restore the read button, resizing, delay, pause
	if {$extmeas != 1} {wm resizable $w 1 1}
	.cmdbar.meas.imgrdsv.read configure -state normal
	delayAdj 1
	.cmdbar.meas.pause configure -state disabled
}

proc readMeter {mode} {
	;# The Argyll spotread.exe program is used to read the meter.
	;# The i1DisplayPro uses the standard USB interface and doesn't need a driver.
	;# The spotread program has an -O option to return a single measurement and exit -
	;# this avoids the need to use the Expect package, which doesn't currently
	;# function in W10. The current version of i1meter reads only a single set 
	;# of averages and then reports it out. Subsequent readings require additional
	;# calls. 

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
	# ...configure L window to "active" color format
	.lumMeter.avg configure    -fg $fgClr
	
	set meterStatus 1
}
# initialize external measurement flag based on config file
# put toward the end to avoid conflicts with process definition order
if {$Lsteps != "External"} {
	external 0
} else {
	external 1
}

#*********************************************************************
#  handler to process each luminance value from the meter
#      Updates the meter
#
proc nit {lum} {

	global meter iLcalVal Lval ionex ioney avgN meterStatus
	global Lcnt Lavg Lval_display ioneu ionev CHRuAvg CHRvAvg
	global Lval_display Lavg_display unitext_display fgClr

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
			set Lval $lum
			set Lval [expr $Lval * $iLcalVal]
			set Lval_display [format %8.3f $Lval]

		}
	} else {
		tk_messageBox -type ok -message "Undefined Photometer type in LRconfig.txt"
	}

	;#---> if avgN indicates, accumulate and average values.
	;#     Otherwise accept the current values.
	
	if {$Lcnt == 1 || $avgN == 1} {
		set Lavg $Lval
		;# update count for the next value
		;#       if $avgN is 1 we stay in this section and Lcnt has no effect.
		;#       if we are averaging, this section initializes the values
		if {$avgN == 1} {
			set Lavg_display [format %7.3f $Lavg]
		} else {
			incr Lcnt
		}
	} else {
		;# This section is entered only if we are averaging (avgN>1)
		;# and the values have been initialized at ILctn=1.
		;# from 2 to avgN accumulate values

		if {$Lcnt > 1 && $Lcnt <= $avgN} {
			set Lavg   [expr $Lavg + $Lval]
		}

		;# ... for Lcnt = avgN compute the average and reset
		if {$Lcnt == $avgN} {
			set Lavg [expr $Lavg/$avgN]
			set Lavg_display  [format %7.3f $Lavg]
			;# reset the count to begin a new average
			set Lcnt 1
		} else {
			;# update count for the next value
			incr Lcnt
		}
	}
	;# reset the color in case it was changed when copying to the clipboard.
	.lumMeter.avg configure    -fg $fgClr

	update idletasks
}	
#*********************************************************************
# procedure to reshape the uniformity data to a more useful structure and display in a new window
#
proc uniDataView {unid} {
	global uniludm unimld ludmmax mldmax
	
	set w .data
	toplevel $w
	wm title $w "Uniformity Measurements"

	text $w.text -bg white -height 20 -width 45 -padx 10 \
				-relief sunken -setgrid 1 \
				-font {arial 8} \
				-yscrollcommand "$w.scroll set"
	scrollbar $w.scroll -command "$w.text yview"

	pack $w.scroll -side right -fill y
	pack $w.text -expand yes -fill both

	$w.text insert end  "Max. LUDM:\t[lindex $ludmmax 1] (GL [format %03.0f [lindex $ludmmax 0]])\n"
	$w.text insert end  "Max. MLD:\t[lindex $mldmax 1] (GL [format %03.0f [lindex $mldmax 0]])\n\n"
	
	foreach {gl L} [dict get $unid] {
		$w.text insert end  "GL [format %03.0f $gl] (LUDM [dict get $uniludm $gl]) (MLD [dict get $unimld $gl])\n"
		$w.text insert end  "[format %.3f [lindex $L 0]]\t[format %.3f [lindex $L 1]]\t[format %.3f [lindex $L 2]]\n"
		$w.text insert end  "[format %.3f [lindex $L 5]]\t[format %.3f [lindex $L 4]]\t[format %.3f [lindex $L 3]]\n"
		$w.text insert end  "[format %.3f [lindex $L 6]]\t[format %.3f [lindex $L 7]]\t[format %.3f [lindex $L 8]]\n"
		$w.text insert end  "\n"
	}

	$w.text configure -state disabled
	
	bind $w <Destroy> {destroy .data}
}

#*********************************************************************
# procedure to reshape the uniformity data to a more useful structure and display in a new window
#
proc uniDataSave {unid} {
	global dispID title meter uniL Lsteps uniDataSaved lumFilePath avgN
	global uniludm unimld Lamb ludmmax mldmax
	
	# replace spaces from the dispID variable with underscores
	set dispIDf [join $dispID _]
	
	set saveFile  Luni_${dispIDf}.txt

	set types {
	  {{Text Files}    {.txt}   }
	  {{All Files}     {*}      }
	}
	set filename [tk_getSaveFile -filetypes $types				\
	                             -initialdir $lumFilePath		\
	                             -initialfile $saveFile			\
	                             -title "SELECT SAVE DATA FILE"]
								 
	# open a file to write the data to
	if { [catch {open $filename {WRONLY CREAT TRUNC}} fid ] } {
		tk_messageBox \
			-type ok \
			-title "Fatal Error" \
			-message "Error opening $filename\n$fid"
		return
	} else {
		set io_file $fid
	}
	
	# write the list of gl and format to follow the ### syntax
	foreach gl $uniL($Lsteps) {lappend fgl [format %03.0f $gl]}
	
	# begin header
	puts $io_file "#\t$title - [clock format [clock seconds] -format "%D %T"]"
	puts $io_file "#\tDisplay ID: $dispID"
	puts $io_file "#\tAverage # of Readings = $avgN"
	puts $io_file "#\tLamb = $Lamb cd/m^2"
	puts $io_file "#\tMeter = $meter"
	puts $io_file "#\tMode = $Lsteps step(s)"
	# output the gray levels
	puts $io_file "#\tGray Level(s): $fgl\n#"
	# output the max LUDM/MLD
	puts $io_file "#\tMax. LUDM:\t[lindex $ludmmax 1]\t(GL [format %03.0f [lindex $ludmmax 0]])"
	puts $io_file "#\tMax. MLD:\t[lindex $mldmax 1]\t(GL [format %03.0f [lindex $mldmax 0]])\n#"
	# display a map of values
	puts $io_file "#\tLuminance values (L, not L') are reported as a matrix for each gray level in cd/m^2"
	puts $io_file "#\tThe position in the matrix corresponds to the following on-screen arrangement:"
	puts $io_file "#\tUL UC UR"
	puts $io_file "#\tCL CC CR"
	puts $io_file "#\tLL LC LR\n#"
	# end header

	# output the uniformity measurements
	foreach {gl L} [dict get $unid] {
		puts $io_file "GL [format %03.0f $gl] (LUDM [dict get $uniludm $gl]) (MLD [dict get $unimld $gl])"
		puts $io_file "[format %.3f [lindex $L 0]]\t[format %.3f [lindex $L 1]]\t[format %.3f [lindex $L 2]]"
		puts $io_file "[format %.3f [lindex $L 5]]\t[format %.3f [lindex $L 4]]\t[format %.3f [lindex $L 3]]"
		puts $io_file "[format %.3f [lindex $L 6]]\t[format %.3f [lindex $L 7]]\t[format %.3f [lindex $L 8]]"
		puts $io_file ""
	}

	# flush the io and close the file
	flush $io_file ; close $io_file
	
	# set the data save variable to 1
	set uniDataSaved 1
	
	return
}

#*********************************************************************
#  procedure to calculate the MLD and LUDM
#
proc ludmmld {unid} {
	global unimld uniludm Lamb
	
	foreach {gl L} [dict get $unid] {
		# put the list in order
		set Llist [lsort -real $L]
		
		# Add Lamb to each value in Llist
		set Llist [lmap l $Llist {expr {$l + $Lamb}}]
		
		# ludm calc
		set med [median $Llist]
		set ludmlist [lmap l $Llist {expr 100*abs($l-$med)/$med}]
		set ludm [tcl::mathfunc::max {*}$ludmlist]
		
		# mld calc
		set max [lindex $Llist end]
		set min [lindex $Llist 0]
		set mld [expr 200*($max-$min)/($max+$min)]
		
		dict lappend uniludm $gl [format %.3f $ludm]
		dict lappend unimld	 $gl [format %.3f $mld]
	}
}


# proc to find the max of a dict with single values per key
proc dictmax {d} {
	set maxVal -Inf
	dict for {k v} $d {
		if {$v > $maxVal} {
			set maxKey $k
			set maxVal $v
		}
	}
	
	# return the max key and value pair
	return [list $maxKey $maxVal]
}

# proc to calculate the mean of a list
proc mean {list} {
    expr {[tcl::mathop::+ {*}$list 0.0] / max(1, [llength $list])}
}

# proc to calculate the median of a list
proc median {list {mode -real}} {
    set list [lsort $mode $list]
    set len [llength $list]
    if {$len & 1} {
       # Odd number of elements, unique middle element
       return [lindex $list [expr {$len >> 1}]]
    } else {
       # Even number of elements, mean of the middle two
       return [mean [lrange $list [expr {($len >> 1) - 1}] [expr {$len >> 1}]]]
    }
}

#*********************************************************************
#  procedure to put up the information message
#
proc Help_message {}  {
	global info apps_path

	if {$info == 0}  {
		# open file for reading
		set input [file join $apps_path "INSTRUCTIONSu.txt"]
		if [catch {open $input r} hfilein] {
			puts stderr "Cannnot open $input $hfilein"
			tk_messageBox -type ok -message "Cannot open $input $hfilein"
			return
		}
		
		set w .help
		toplevel $w
		wm title $w "Instructions for uniLum"
		wm iconname $w "Instructions"

		text $w.text -bg white -height 30 -width 70 -padx 10 \
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
# includes check on IL1700 status
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
