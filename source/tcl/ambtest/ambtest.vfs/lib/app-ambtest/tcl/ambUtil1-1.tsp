# -----------------------------------------------------------------------
#
#					ambUtil.tsp
#
#	Tcl utility procedures for the ambient lighting
#	visual test script (ambtest.tcl)
#
#	v1.0 NB April 2021	- Initial version
#						- Port procs from original script
#
# -----------------------------------------------------------------------

# limit the gray values to 0-255 (8-bit)
proc bound {num} {
	if {$num > 255} {set num 255}
	if {$num < 0  } {set num 0  }
	return $num
}

# process to turn an integer graylevel into its rgb hex value
proc hex {grayval} {
	set grayval [bound $grayval]
	set grayhex [format %02x $grayval]
	set grayHex #$grayhex$grayhex$grayhex
	
	return $grayHex
}

# process to generate the bar pattern between 0 (bkgd) and the requested gray level
proc patgen {gray} {
	global objp objhp objh objw
	
	set gl [hex $gray]
	set bk [hex 0]
	
	set pattern {}
	for {set i 0} {$i<$objh} {incr i} {
		set line {}
		for {set j 0} {$j<$objw} {incr j} {
			lappend line [lindex "$bk $gl" [expr {[expr {$j%$objp}] < $objhp}]]
		}
		lappend pattern $line
	}
	return $pattern
}

proc generate {img width height} {
    set data {}
    for {set i 0} {$i<$height} {incr i} {
		set line {}
		for {set j 0} {$j<$width} {incr j} {
			lappend line [lindex "#000000 #FFFFFF" [expr {rand() < 0.5}]]
		}
		lappend data $line
    }
    $img put $data
}
 

# process to generate random number between two numbers
proc myRand {min max} {
    expr {int(rand() * ($max + 1 - $min)) + $min}
}

# process to position the low contrast object
proc position {object} {
	global w h
	global can
	
	# generate location of the low contrast object
	# pad the edges of the canvas by 100 pixels
	set xloc1 [myRand 100 [expr $w-200]]
	set yloc1 [myRand 100 [expr $h-200]]

	# poisition the object at the new coords
	$can coords $object $xloc1 $yloc1
}

# process to resize the canvas based on a new window size
proc resize {w2 h2} {
	global lowc bkgd can
	global w h
	
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
		set wratio [expr $w2/($w+0.0)]; set hratio [expr $h2/($h+0.0)]
		
		# overwrite the old w and h variables
		set w $w2
		set h $h2
		
		# redraw the canvas with the new width and height
		$can configure -width $w -height $h
		
		# scale the background
		$can scale $bkgd 0 0 $wratio $hratio
			
		# reposition the object randomly on the resized canvas
		position $lowc
		
		# reposition the text
		$can coords resz [expr $w/2] 20
		$can coords graylvl [expr $w-20] 20
		$can raise help
	} else {
		# leave the canvas and position as-is
	}
}
# process to change the contrast of the object
proc changecontrast {chng} {
	global can lowc gl bar
	
	# retrieve current fill
	#set fill [$can itemconfigure $lowc -fill]
	#set grayind [string first gray $fill]
	#set graylvl [string range $fill $grayind+4 end]
	
	if {$chng == "up"} {
		set gl [bound [incr gl]]
		bar put [patgen $gl]
		$can itemconfigure graylvl -text "Current Contrast: ${gl} GLs"
	} elseif {$chng == "down"} {
		if {$gl != 0} {
			incr gl -1
			bar put [patgen $gl]
			$can itemconfigure graylvl -text "Current Contrast: ${gl} GLs"
		} else {
			# do nothing if already min gray level
		}
	}
}

# -----------------------------------------------------------------------
# processes to display messages after correct or incorrect click
proc failure {object} {
	set textmsg "Low contrast object not found!\n\n"
		append textmsg "Adjust ambient lighting or recalibrate display\n\n"
		append textmsg "Select \"Retry\" to move the object and try again\n"
		append textmsg "Select \"Cancel\" to quit"		
	set answer [tk_messageBox -message $textmsg \
		-type retrycancel -icon warning -title "Failure!" ]
	switch -- $answer {
		retry {position $object} ;# move the object 
		cancel exit ;# exit the script
	}	
}
proc success {object} {
	global gl

	set textmsg "Low contrast object found!\n\n"
		append textmsg "Ambient lighting appropriate for ${gl} gray level contrast visualization\n\n"
		append textmsg "Select \"Retry\" to move the object and try again\n"
		append textmsg "Select \"Cancel\" to quit"
	set answer [tk_messageBox -message $textmsg \
		-type retrycancel -icon info -title "Success!" ]
	switch -- $answer {
		retry {position $object} ;# move the object 
		cancel exit ;# exit the script
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
		wm title $w "Instructions"
		wm iconname $w "Instructions"

		text $w.text -bg white \
				-height 45 -width 42  \
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