package provide app-uLRstats 1.0

# ==============================================================================
# MODULE VERSION: 1.2
# ==============================================================================

#############################################################
#               uLRstats.tcl
#
#  Application to read multiple uncalibrated luminance
#  response files, uLR files, and analyze the contents.
#  On initiation a directory select dialoque requests
#  the directory path containing the files.
#  Files of interest can be identified with a 'glob' feature.
#  Results are reported in the direcory selected:
#     - uLR_<MANF_MODEL>_GENERIC.txt,
#         A uLR file containing the average response of
#         all files. The format is suitable for conversion
#         to a generic LUT  using lutGenerate.
#     - uLR-colorLum.txt,
#         Statistics for all files including
#              R, G, B luminance,
#              Lmin and Lmax, and
#              R to G and B to G ratios.
#     - uLR-plot.gnu,
#         Gnuplot command file for;
#              Color ratio plot
#              Luminance plot from all files
#              dL/L of the average for each minor palette entry.
#
#	Author: M. Flynn, N. Bevins
#	Date:   Feb 2026
#
#############################################################
#
#  20061205 - uLRstats version 1.0
#
#    - Added dL/L plot for average palette.
#    - Checks each file and the average file for
#      non increasing values and write to log.
#      Adds a note in message dialoque if 
#      non-increasing values have been found.
#    - Checks the palette size to see if a file
#      with a different palette size is encountered.
#      Reads each file, tests first line
#      and checks the  number of lines.
#    - Added hex RGB column to average response so
#      that lutGenerate can create a calibration LUT.
#
#  20131212 - uLRstats version 1.1
#
#    - Revised config file similar to lumResponse
#      Now finds install path or open in directory.
#      Will run from within the dev directory with
#      LIB and _NEW directorys that are there.
#    - Log file now written to user LOGs for installed app.
#    - Now using generic notepad call not notepad.exe in LIB.
#    - Disabled the initial presentation of the select window.
#    - lumResponse no longer measure red, green, blue at the
#      beginning. Removed the color comparison analysis.
#      Values are still read and processed but not reported.
#    - Updated for current gnuplot version.
#    - Manf and Model extracted and used to label generic file.
#
#  20260223 - uLRstats version 1.2
#
#    - Updated to starkit distribution
#    - Organized support scripts into tcl subdir within kit
#    - Reverted to text-based help file
#
#############################################################
# 
#console show
set title "uLRstats v1.2"
set copydate "Feb 2026"
# first tell the user what version he is using
#
puts "$title" 
#puts "Copyright:       Xray Imaging Research Laboratory"
#puts "                         Henry Ford Health System"
#puts "                         Detroit, MI"
#puts "                                         $copydate"
#
#**********************************************************************
# get home directory to support wrapping with tclApp

#
set apps_path [file dirname [info script]]
source [file join $apps_path tcl xirlDefs-v06.tsp]	;# standard widget style
source [file join $apps_path tcl selectFiles.tsp]
source [file join $apps_path tcl initStats.tsp]
source [file join $apps_path tcl uLRplot.tsp]

set info 0 ;# flag indicating whether help message is up or off.

wm title .  $title
wm resizable . 0 0

set fileCount  0
set ptestLow   0   ;# dumps file values to console for test.
set ptestHi    0   ;# if these two are non-zero.

#**********************************************************************
# get configured parameters
#
source config-uStats.txt  ;# not packaged in starkit
#
#**********************************************************************
# start the application.

initStats       ;# build the GUI

#select_files .  ;# force the user to select files first

#**********************************************************************
# Primary procedure to do the analysis.
# The select_files procedures leaves the application in the uLR directory.

proc analyzeUlrFiles {} {
	global fileCount fileName red grn blu
	global logDir LIB ptestLow ptestHi logFID
	global limitNum lowLimit hiLimit pRGB manf model

	;# .. test to affirm fileCount
	if {$fileCount == 0} {
		tk_messageBox -type ok         \
		              -icon warning    \
		              -parent .        \
		              -title "WARNING" \
		              -message "No files selected"
		return
	}

	;# .. open log file
	set logFID [open [file join $logDir logURLstats.txt] w]

	;# .. validate first file and get the palette size
	set palette [validateULRfile RGB $fileName(1)]
	if { $palette == "invalidFile"} {
		set exitMsg "First file: invalid uLR format\nPalette size not found\n\nRETURNING!" 
		tk_messageBox -message $exitMsg -type ok -icon error -title "ERROR"
		puts $logFID "\n--- ERROR: invalid first file: [file tail $fileName(1)] ---\n"
		set fileCount 0
		.inits.load configure -text "0 FILES SELECTED"
		close $logFID
		return
	}
	puts $logFID "\n--- Palette size of $palette found in first file\n"

	;# .. initialize


	set updateMsg "."
	set redavg 0
	set grnavg 0
	set bluavg 0
	set limitNum   0   ;# counts dL/L values outside of limits.
	for {set pnum 1} {$pnum <= $palette} {incr pnum} {
		set plum($pnum) 0
	}

	;# .. read each file and accumulate luminance values
	for {set i 1} {$i <= $fileCount} {incr i} {

		;# .. validate each file
		if {[validateULRfile noRGB $fileName($i)] == "invalidFile"} {
			set exitMsg "Invalid uLR file found\n\n[file tail $fileName($i)]\n\nRETURNING!"
			tk_messageBox -message $exitMsg -type ok -icon error -title "ERROR"
			puts $logFID "\n--- ERROR: invalid file detected: [file tail $fileName($i)] ---\n"
			set fileCount 0
			.inits.load configure -text "0 FILES SELECTED"
			close $logFID
			return
		}

		puts $logFID "\n--- Processing File $i: [file tail $fileName($i)] ---\n"

		;# .. open file and read initial lines
		set fileID [open $fileName($i) r]
		set lineskip 3
		for {set line 1} {$line <= $lineskip} {incr line} {
			gets $fileID
		}

		;# .. get color luminance and accumulate for average
		set red($i) [lindex [gets $fileID] 1]
		set grn($i) [lindex [gets $fileID] 1]
		set blu($i) [lindex [gets $fileID] 1]
		set redavg [expr $redavg + $red($i) ]
		set grnavg [expr $grnavg + $grn($i) ]
		set bluavg [expr $bluavg + $blu($i) ]

		;# .. get palette and accumulate for average
		for {set pnum 1} {$pnum <= $palette} {incr pnum} {
			set  lum($pnum) [lindex [gets $fileID] 1] 
			set plum($pnum) [expr $plum($pnum) + $lum($pnum) ]

			;# output selected values if needed
			if {$pnum >= $ptestLow && $pnum <= $ptestHi} {
				puts "$pnum $lum($pnum)"
			}

			;# test for bad transition values
			if {$pnum > 1} {
				set dL_L [expr ($lum($pnum) - $lumPrior)*2.0/($lum($pnum) + $lumPrior)]
				set dL_L [format %10.5f $dL_L]
				if {$dL_L < $lowLimit || $dL_L > $hiLimit } {
					puts -nonewline $logFID "    --- Warning: dL/L out of limits for Pn & Pn-1,"
					puts            $logFID " n = $pnum, dL/L = $dL_L"
					incr limitNum
				}
			}
			set lumPrior $lum($pnum)

		}
		;# store Lmin and Lmax
		set Lmin($i) $lum(1)
		set Lmax($i) $lum($palette)

		close $fileID
		.inits.load configure -text $updateMsg
		append updateMsg "."
		update
	}

	;# .. compute color average and 2D color point metric and write
	set redavg  [format %9.3f [expr $redavg/$fileCount]]
	set grnavg  [format %9.3f [expr $grnavg/$fileCount]]
	set bluavg  [format %9.3f [expr $bluavg/$fileCount]]
	set r2g     [format %8.5f [expr $redavg/$grnavg]]
	set b2g     [format %8.5f [expr $bluavg/$grnavg]]
	set LminAvg [format %9.3f [expr $plum(1)/$fileCount]]
	set LmaxAvg [format %9.3f [expr $plum($palette)/$fileCount]]

	set lumFID [open uLR-LminLmax.txt w]
	puts $lumFID "# Lmin and Lmax for all files analyzed"
	puts $lumFID "# $fileCount files"
	puts $lumFID "#   Lmin      Lmax      FILE"
	puts $lumFID "#$LminAvg $LmaxAvg   Average"
	for {set i 1} {$i <= $fileCount} {incr i} {
		puts -nonewline $lumFID " [format %9.3f $Lmin($i)]"
		puts -nonewline $lumFID " [format %9.3f $Lmax($i)]"
		puts            $lumFID "  [file tail $fileName($i)]"
	}
	close $lumFID

	;# .. initialize substate indices for each file
	set majorPnum 1
	set minorPnum 1
	if {$palette == 1786} {
		set minorStates 7
	} elseif {$palette == 766} {
		set minorStates 3
	} elseif {$palette == 256} {
		set minorStates 1
	} else {
		set minorStates 1
	}

	;# .. get average and write to file
	set fileID [open "uLR_${manf}_${model}_GENERIC.txt" w]
	puts $logFID "\n--- Processing Average File: uLR_${manf}_${model}_GENERIC.txt---\n"
	puts $fileID "#  lumResponse - average luminance response"
	puts $fileID "#  Display ID: GENERIC $manf $model"
	puts $fileID "#  $fileCount files"
	puts $fileID "# [format %10.4f $redavg] #ff0000"
	puts $fileID "# [format %10.4f $grnavg] #00ff00"
	puts $fileID "# [format %10.4f $bluavg] #0000ff"
	for {set pnum 1} {$pnum <= $palette} {incr pnum} {
		set plum($pnum) [expr $plum($pnum)/$fileCount]
		puts -nonewline $fileID "[format %4i $pnum]  [format %10.4f $plum($pnum)]"
		puts -nonewline $fileID "  $pRGB($pnum)"
		puts -nonewline $fileID " [format %4i $majorPnum]"
		puts -nonewline $fileID " [format %3i $minorPnum]"
		if {$pnum > 1} {
			set dL_L [expr ($plum($pnum) - $plumPrior)*2.0/($plum($pnum) + $plumPrior)]
			puts            $fileID " [format %10.5f  $dL_L]"
			if {$dL_L < $lowLimit || $dL_L > $hiLimit } {
				puts -nonewline $logFID "    --- Warning: dL/L out of limits for Pn & Pn-1,"
				puts            $logFID " n = $pnum, dL/L = $dL_L"
				incr limitNum
			}
		} else {
			puts $fileID " "
		}
		;# settings for use in next pass
		set plumPrior $plum($pnum)
		incr minorPnum 
		if {$minorPnum > $minorStates} {
			set minorPnum 1
			incr majorPnum 
		}
	}
	close $fileID
	close $logFID

	if {$limitNum > 0} {
		set msg    " $limitNum out of limit dL/L values\n detected in files processed\n\n"
		append msg " Do you want to view the log file?\n"
		set answer [tk_messageBox -message $msg -type yesno -icon warning -title "WARNING"]
		if {$answer eq "yes"} {
			if { [catch {exec [file join $LIB notepad.exe] [file join $logDir logURLstats.txt]} fid] } {
				set msg "Error opening logfile with notepad\n$fid"
    				tk_messageBox -message $msg -type ok -icon warning -title "WARNING"
			}
		}
	}

	set answer [tk_messageBox -message "PLOT?" -type yesno -icon question -title "DONE"]
	if {$answer eq "yes"} {plotUlrAvg}

	set fileCount 0
	.inits.load configure -text "0 FILES SELECTED"

}

#**********************************************************************
# procedure to validate the selected files.

proc validateULRfile {mode uLRfile} {

	global pRGB manf model
	;# application returns the size of the palette.
	;# use mode = RGB to get the RGB palette from file
	;# and store in the pRGB array.

	set FID 0
	set FID [open $uLRfile r]

	;# check first line to verify that this is a lumResponse file.
	set keyword [ lindex [gets $FID] 1]
	if {$keyword != "lumResponse"} {
		return "invalidFile"
		close $FID
	}

	;# get the manf and model.
	set manfModel [lindex [gets $FID] 3]
	set mList [split $manfModel "_"]
	set manf  [lindex $mList 0]
	set model [lindex $mList 1]

	set lineskip 4
	for {set line 1} {$line <= $lineskip} {incr line} {
		gets $FID
	}

	if {$mode == "RGB"} {
		for {set lines 1} {$lines <= 2000} {incr lines} {
			set line [gets $FID]
			set pRGB($lines) [lindex $line 2]
			if { [eof $FID] == 1} break
		}
	} else {
		for {set lines 1} {$lines <= 2000} {incr lines} {
			set line [gets $FID]
			if { [eof $FID] == 1} break
		}
	}

	close $FID
	set palette [expr $lines - 1]

	if {$palette == 1786 || $palette == 766 || $palette == 256} {
		return $palette
	} else {
		return "invalidFile"
	}
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
		wm title $w "Instructions for uLRstats"
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
#*********************************************************************
