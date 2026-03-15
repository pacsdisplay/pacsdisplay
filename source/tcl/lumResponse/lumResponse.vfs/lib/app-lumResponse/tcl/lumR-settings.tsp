#############################################################
# Variable names, initial values, and labels
# for parameters settings in lumResponse.
#
# includes a procedure to build an entry window
# for the secondary variables. (see end of file).
#
#	Author: M. Flynn 
#	Date:   Dec 2006
#
#	Updated 2019 to remove IL1700, LXcan, i1Display2
#	Edited: N. Bevins
#
#------------------------------------------------------------
# Define test window geometry entry variables and labels

set geomLIST {toolOffset width height rectX rectY}

#variables are initialized in ILconfig.txt

set varLabel(toolOffset) "window upper left corner, +X+Y"
set varLabel(width)      "window canvas width in pixels"
set varLabel(height)     "window canvas height in pixels"
set varLabel(rectX)      "gray region width in pixels"
set varLabel(rectY)      "gray region height in pixels"

#------------------------------------------------------------
# Define photometer entry variables and labels

set ilLIST {iLcalVal iLdelay avgN outlierpause\
            ILlimit_abs ILlimit_plus ILlimit_minus   \
            ILtolerance outlierNum verboselog Lamb }

#variables are initialized in ILconfig.txt

set varLabel(iLcalVal)         "Calibration factor for photometer"
set varLabel(iLdelay)          "Measures skipped after gray change"
set varLabel(avgN)             "Measures averaged for each gray level"
set varLabel(outlierpause)     "millisec delay used for outlier repeats"
set varLabel(ILlimit_abs)      "Outlier limit of luminance difference"
set varLabel(ILlimit_plus)     "Outlier limit for + relative change"
set varLabel(ILlimit_minus)    "Outlier limit for - relative change"
set varLabel(ILtolerance)      "Tolerance factor for persistent outliers"
set varLabel(outlierNum)       "Number of times an outlier is retried"
set varLabel(verboselog)       "0/1, Logs all values (delay, avg N)"
set varLabel(Lamb)             "cd/m2, ambient luminance for QC analysis"

#------------------------------------------------------------
proc optionWindow {type } {

	global varLabel varDflag geomLIST ilLIST meter
	global toolOffset height width pitch pitchNum
	global iLcalVal iLdelay avgN outlierpause
	global ILlimit_abs ILlimit_plus ILlimit_minus outlierTestLimit 
	global verboselog record

	if {$record == 1} {
		tk_messageBox -type ok -message \
			"Data acquisition must be stopped before changing settings."
		return
	}

	set options .options
	catch {destroy $options}
	toplevel $options

	if {$type == "geom"} {
		set list $geomLIST
		set table "Geometry Values"
	} elseif {$type == "il"} {
		set list $ilLIST
		set table "Photometer Values"
	} else {
		return
	}
	wm title $options $table

	set cmd $options.cmd
	frame $cmd -borderwidth 2
	button $cmd.close  -text "close"  -command [list destroy $options ]
	label  $cmd.label  -text $table
	pack $cmd.close -side right -fill y
	pack $cmd.label -side left -fill y
	pack $cmd -side top -fill both -padx 10 -pady 10

	if {$type == "geom"} {
		set geo $options.geo
		frame $geo -borderwidth 2
		label $geo.label -text "Pixel Pitch, mm: "
		pack $geo.label -side left -fill y
		radiobutton $geo.one -text "$pitch(1)" \
		                          -variable pitchNum \
		                          -command setGeom \
		                          -value 1
		radiobutton $geo.two -text "$pitch(2)" \
		                          -variable pitchNum \
		                          -command setGeom \
		                          -value 2
		radiobutton $geo.three -text "$pitch(3)" \
		                          -variable pitchNum \
		                          -command setGeom \
		                          -value 3
		radiobutton $geo.four -text "$pitch(4)" \
		                          -variable pitchNum \
		                          -command setGeom \
		                          -value 4
		pack $geo.one   -side left -fill y
		pack $geo.two   -side left -fill y
		pack $geo.three -side left -fill y
		pack $geo.four  -side left -fill y
		pack $geo -side top -fill both -padx 10 -pady 10
	}

	if {$type == "il"} {
		set mtr $options.mtr
		frame $mtr -borderwidth 2
		label $mtr.label -text "Model: "
		pack $mtr.label -side left -fill y
		#radiobutton $mtr.one -text "IL1700" \
		                          -variable meter \
		                          -command changeMeter \
		                          -value IL1700
		#radiobutton $mtr.two -text "LXcan" \
		                          -variable meter \
		                          -command changeMeter \
		                          -value LXcan
		#radiobutton $mtr.three -text "i1Display2" \
		                          -variable meter \
		                          -command changeMeter \
		                          -value i1Display2
		radiobutton $mtr.four -text "i1DisplayPro" \
		                          -variable meter \
		                          -command changeMeter \
		                          -value i1DisplayPro
		#pack $mtr.one   -side left -fill y
		#pack $mtr.two   -side left -fill y
		#pack $mtr.three -side left -fill y
		pack $mtr.four  -side left -fill y
		pack $mtr -side top -fill both -padx 10 -pady 10
	}

	foreach ID $list {
		set box  $options.w_$ID
		frame $box -relief raised -borderwidth 2
		label $box.vname -text "$ID:" -width 12 -anchor e
		label $box.label -text "$varLabel($ID)"
		entry $box.value \
				-width 6   \
				-relief sunken \
				-textvariable $ID
		button $box.help        \
				-text ?                 \
				-font {arial 8 bold} \
				-width 1 \
				-cursor hand2                   \
				-command [list showHelp $ID $options]
		pack $box.vname -side left  -fill y    -padx 5 -pady 5
		pack $box.value -side left  -fill y    -padx 5 -pady 5
		pack $box.label -side left  -fill y    -padx 2 -pady 5
		if {$varDflag($ID) == 1} {
			pack $box.help  -side right -fill y    -padx 2 -pady 5
		}
		pack $box       -side top   -fill both -padx 5 -pady 5
	}
}

#------------------------------------------------------------
proc changeMeter {} {
	global model 
	setMeter   ;# procedure to change parameter values
	.lumMeter.model configure -text $model 
}

proc setGeom {} {
	global height width mmHeight mmWidth pitch pitchNum
	global grayRegionSize rectX rectY grayBackground

	if {$grayBackground == 1} {
		set height [expr round( $mmHeight / $pitch($pitchNum) )]
		set width  [expr round( $mmWidth  / $pitch($pitchNum) )]
	} elseif {$grayBackground == 0} {
		set height [expr round( $grayRegionSize / $pitch($pitchNum) )]
		set width  [expr round( $grayRegionSize  / $pitch($pitchNum) )]
	} else {
		tk_messageBox \
			-type ok             \
			-title "ERROR" \
			-message "Invalid Gray Background Option Selection (0/1)"
	}
	
	set rectX [expr round($grayRegionSize / $pitch($pitchNum) ) ]
	set rectY $rectX
}