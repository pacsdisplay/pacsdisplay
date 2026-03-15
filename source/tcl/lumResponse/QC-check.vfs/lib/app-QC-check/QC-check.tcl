package provide app-QC-check 1.0

# ==============================================================================
# MODULE VERSION: 2.5
# ==============================================================================

############################################################################
#                    QC-check  (lumResponse v2.5)                          #
#  Written by:                                                             #
#    Michael J. Flynn                                                      #
#    Nicholas B. Bevins                                                    #
#                                                                          #
#  Utility program for a user to re-analyze cLR data obtained in QC mode   #
#  using a different value for ambient luminance.                          #
#  Measured data in cLR file format is read and analyzed to evaluate       #
#  the contrast response in relation to the DICOM standard.                #
#                                                                          #
#                       Oct 2019  - Update to have user input QC type      #
#                       Feb 2026  - Update to starkit dist			       #
############################################################################
#console show

set LUTmode 18  ;# need to set this for plotUlr procedure
set Lamb  0.15  ;# library generics are .10, .15, .18, or .20

#**********************************************************************
# Variable definitions and procedures from other files
# reference to 'apps_path directory to support wrapping with tclApp

package require base64	  ;# used for converting plots for embedding into html.
source LRconfig.txt        ;# variable definitions (not wrapped)

set apps_path [file dirname [info script]]
source [file join $apps_path tcl lumR-evalQClr.tsp] ;# plotting procedures
source [file join $apps_path tcl lumR-plot.tsp]     ;# plotting procedures
source [file join $apps_path tcl JNDdicom.tsp]      ;# JNDtoLUM & LUMtoJND
source [file join $apps_path tcl xirlDefs-v06.tsp]  ;# standard widget style

set qctmlFile [file join $apps_path tcl html qcHTML.tml]    ;# used in evalQC
set logoFile  [file join $apps_path tcl html pdQC-logo_sm.png] ;# used in evalQC

#**********************************************************************
# read the phase file.

set input 16phase.txt
if [catch {open $input r} filein] {
	puts stderr "Cannnot open $input $filein"
	tk_messageBox -type ok -message "Cannot open $input $filein"
	return
}
#  skip header and read input file
for {set i 1} {$i <= 2} {incr i} {
	gets $filein
}
set numPhases [gets $filein]
for {set i 0} {$i < $numPhases} {incr i} {
	set phase($i) [gets $filein]
}
close $filein

#**********************************************************************
# Simple window to get Lamb and run the process

#  -------------------
#  set up the frames
frame  .quitbar        -relief raised -borderwidth 2
frame  .spacer_bar     -relief raised -borderwidth 2 -height 5
frame  .qc_bar        -relief raised -borderwidth 2
pack   .quitbar .spacer_bar .qc_bar -side top -fill both


#  -------------------
#  make the top bar
label  .quitbar.label1 -text "QC-check: Re-Analyze cLR"
button .quitbar.quit  \
                    -text QUIT \
                    -command  "destroy ."
pack   .quitbar.label1 \
                    -side left -padx 1m -pady 1m -fill x
pack   .quitbar.quit \
                    -side right -padx 1m -pady 1m -fill x

#  -------------------
#  Lamb and file name entry.
#
frame .qc_bar.left
frame .qc_bar.right

# file name line
label .qc_bar.left.clr_label -text {cLR Filename:}
label .qc_bar.left.clr_spacer

label .qc_bar.right.clr_entry \
			  -justify left \
                    -width 25   \
                    -relief groove \
                    -text "  -------------  "

#  ambient luminance entry
label .qc_bar.right.lamb_label -text "Lamb, cd/m2:"
entry .qc_bar.right.lamb_entry \
			  -justify center \
                    -width 10   \
                    -relief sunken \
                    -textvariable Lamb

#  LUTmode type entry
label .qc_bar.right.qc_label -text "QC Mode:"
entry .qc_bar.right.qc_entry \
			  -justify center \
                    -width 10   \
                    -relief sunken \
                    -textvariable LUTmode

#  get filename
button .qc_bar.right.getCLR  \
                    -text "GET cLR Filename" \
                    -width 15 \
                    -command getCLR
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack .qc_bar.left .qc_bar.right -side left -fill x

pack   \
           .qc_bar.left.clr_spacer  \
                    -side top -padx 1m -pady 1m -fill x
pack   \
           .qc_bar.left.clr_label  \
                    -side top -padx 1m -pady 1m -fill x
pack   \
           .qc_bar.right.clr_entry   \
                    -side bottom -padx 1m -pady 1m -fill x
pack   \
           .qc_bar.right.lamb_label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .qc_bar.right.lamb_entry  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .qc_bar.right.qc_label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .qc_bar.right.qc_entry  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .qc_bar.right.getCLR  \
                    -side left -padx 1m -pady 1m -fill x
#

#**********************************************************************
# procedure to get the Ulr filename and process

proc getCLR {} {

	global lumFilePath ;# defined in getInstalledPaths.txt (sourced in LRconfig.txt)
	
	set text    "Measured data must have been obtained "
	append text "with the entered QC Mode "
	append text "(256 for 256-point, 52 for 52-point, "
	append text "18 for 18-point, 16 for 16x2)\n\n"
	append text "Do you want to continue?"

	set answer [tk_messageBox -message $text -icon question -type yesno]

	if {$answer == "no"} {
		return
	}


	set types {
		{{cLR files}   {cLR*.txt} }
		{{text files}  {.txt}     }
		{{All Files}    *         }
	}
	set filename [tk_getOpenFile -filetypes $types -title "Select cLR file" -initialdir $lumFilePath]

	if {$filename != ""} {
		.qc_bar.right.clr_entry configure -text [file tail $filename]
		update idletasks
		plotUlr $filename ;# LUTmode 16 is trapped in this procedure
	}
}
