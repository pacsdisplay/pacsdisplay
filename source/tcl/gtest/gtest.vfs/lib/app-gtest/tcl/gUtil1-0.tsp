# -----------------------------------------------------------------------
#
#					gUtil.tsp
#
#	Tcl utility procedures for the gray level (and color) patch
#	test script (gtest.tcl)
#
#	v1.0 NB April 2021	- Initial version
#						- Port procs from original script
#						- Removed tweakProcs
#						- Mod solidColor to allow changing from one color
#						to another without neededing to turn off first
#
# -----------------------------------------------------------------------

# ------------------------------------------------------------
#    Utility Procedures
# ------------------------------------------------------------

# limit the gray values to 0-255 (8-bit)
proc bound {num} {
	if {$num > 255} {set num 255}
	if {$num < 0  } {set num 0  }
	return $num
}

# limit the color deltas to +/- 255
proc dbound {num} {
	global grayVal

	if {$num > [expr 255-$grayVal]} {set num [expr 255-$grayVal]}
	if {$num <   [expr 0-$grayVal]} {set num   [expr 0-$grayVal]}
	return $num
}

proc rgbhex {grayval} {
	global dR dG dB  ;# RGB change values
	global grayHex

	set grayhex [format %02x $grayval]
	set grayHex #$grayhex$grayhex$grayhex

	set dR [dbound $dR]
	set dG [dbound $dG]
	set dB [dbound $dB]

	set rval [bound [expr $grayval + $dR]]
	set gval [bound [expr $grayval + $dG]]
	set bval [bound [expr $grayval + $dB]]
	.can itemconfigure rtext -text "[format %3s $dR]" 
	.can itemconfigure gtext -text "[format %3s $dG]" 
	.can itemconfigure btext -text "[format %3s $dB]" 

	set rhex [format %02x $rval]
	set ghex [format %02x $gval]
	set bhex [format %02x $bval]
	set rgbhex #$rhex$ghex$bhex

	set rgblabel "([format %3s $rval],[format %3s $gval],[format %3s $bval])  $rgbhex"
	.can itemconfigure rgbtext -text $rgblabel

	return $rgbhex
}

# ------------------------------------------------------------
#    Callback Procedures
# ------------------------------------------------------------

proc changeGray {delta} {
	global grayVal grayHex
	set grayVal [bound [expr $grayVal + $delta]]
	.can itemconfigure color -fill  [rgbhex $grayVal]
	.can itemconfigure gray  -fill  $grayHex
}

proc changeColor {color delta} {
	global dR dG dB grayVal grayHex
	if {$color == "red"} {
		set dR [dbound [expr $dR + $delta]]
	} elseif {$color == "grn"} {
		set dG [dbound [expr $dG + $delta]]
	} elseif {$color == "blu"} {
		set dB [dbound [expr $dB + $delta]]
	} else {
		return
	}
	.can itemconfigure color -fill  [rgbhex $grayVal]
	.can itemconfigure gray  -fill  $grayHex
}
proc solidColor {color} {
	# sets pure colors but does not change grayVal or grayHex
	# so that the pure color can be easily removed with changeGray 0.
	global solidClrFlag
	
	# check for called color and current state
	# if already displaying the solid color, remove it
	if {$color == "red" && $solidClrFlag != "red"} {
		.can itemconfigure color -fill  #ff0000
		set rgblabel "(255,  0,  0)  #ff0000"
		set solidClrFlag "red"
	} elseif {$color == "grn" && $solidClrFlag != "grn"} {
		.can itemconfigure color -fill  #00ff00
		set rgblabel "(  0,255,  0)  #00ff00"
		set solidClrFlag "grn"
	} elseif {$color == "blu" && $solidClrFlag != "blu"} {
		.can itemconfigure color -fill  #0000ff
		set rgblabel "(  0,  0,255)  #0000ff"
		set solidClrFlag "blu"
	} else {
		changeGray 0 ;# restore the display, removing solid color
		set solidClrFlag 0
	}
	
	# if displaying a solid color, change the text
	if {$solidClrFlag != 0} {
		.can itemconfigure rgbtext -text $rgblabel
	}

}
# process to show/hide the focus pattern
proc showFocus {} {
	global fstate
	if {$fstate == 1} {
		.can lower focus both
		set fstate 0
	} else {
		.can raise focus both
		set fstate 1
	}

}
# process to show/hide the rbg values area
proc hidergb {} {
	global rgbstate
	if {$rgbstate == 1} {
		.can raise both
		set rgbstate 0
	} else {
		.can lower both textbar
		set rgbstate 1
	}

}

# process to resize the canvas based on a new window size
proc resize {w2 h2} {
	global w h border cborder
	global x1 y1
	global x1c y1c
	
	# read and split the window size (assume wxh format with x delimiter)
	# assign to temp variables to calculate a ratio
	# not necessary if passing from bind Configure of main window
	#set geo [winfo geometry .]
	#set dims [string first + $geo]
	#lassign [split [string range $geo 0 [expr $dims-1]] x] w2 h2
	
	set w2 [expr $w2-4]; set h2 [expr $h2-4]
	
	# if the new width/height are different, resize the canvas
	# and move the object
	if {$w2 != $w || $h2 != $h} {
		# determine ratio of new width & height to old
		# account for the border width to properly scale
		set wratiog [expr ($w2)/($w+0.0)]
		set hratiog [expr ($h2)/($h+0.0)]
		set wratioc [expr ($w2-2*$cborder)/($w-2*$cborder+0.0)]
		set hratioc [expr ($h2-2*$cborder)/($h-2*$cborder+0.0)]
		
		# overwrite the old w and h variables
		set w $w2
		set h $h2
		
		# redraw the canvas with the new width and height
		.can configure -width $w -height $h
		
		# scale the rectangles
		.can scale gray		$x1  $y1  $wratiog $hratiog
		.can scale color	$x1c $y1c $wratioc $hratioc
		.can scale focus	$x1  $y1  $wratiog $hratiog
		.can scale textbar	0	 0    $wratiog 1
		
		# reposition the text
		.can coords rtext [expr $w [scaled -120]] 20
		.can coords gtext [expr $w  [scaled -70]] 20
		.can coords btext [expr $w  [scaled -20]] 20
		.can coords rgbtext  [expr $w/2] 20
	} else {
		# leave the canvas and position as-is
	}
}

# ------------------------------------------------------------
#  procedure to put up the information message
#
proc Help_message {}  {
	global home

		# open file for reading
		set input [file join $home "INSTRUCTIONS.txt"]
		if [catch {open $input r} hfilein] {
			puts stderr "Cannnot open $input $hfilein"
			tk-MessageBoxMod -type ok -message "Cannot open $input $hfilein"
			return
		}
		
		set w .help
		# don't open the help if it's already open
		if { [catch {toplevel $w}] } {return}
		wm title $w "Instructions for iQC"
		wm iconname $w "Instructions"

		text $w.text -bg white \
				-height 34 -width 45  \
				-relief sunken -setgrid 1 \
				-font {Courier 10}  \
				-yscrollcommand "$w.scroll set"
			
		scrollbar $w.scroll -command "$w.text yview"

		pack $w.scroll -side right -fill y
		pack $w.text -expand yes -fill both

		foreach line [split [read $hfilein] \n] {
			$w.text insert end "$line\n"
		}
		close $hfilein

		$w.text configure -state disabled
}
