package provide app-lutGenerate 1.0

# ==============================================================================
# MODULE VERSION: 2.6
# ==============================================================================

#########################################################################
#                      lutGenerate  2.6                                 #
#  Written by:                                                          #
#    Philip M. Tchou                                                    #
#    Michael J. Flynn                                                   #
#    Nicholas B. Bevins                                                 #
#                                                                       #
#  X-ray Imaging Lab, Henry Ford Health Systems, Detroit, MI            #
#                                                                       #
#  This program uses uncalibrated luminance response data (uLR files)	#
#  to construct a dicom calibration LUT file.                           #
#                                                                       #
#       Version 2.2:                                                    #
#           Oct 2003    - Final release                                 #
#                                                                       #
#       Version 2.3:                                                    #
#           Sep 2006    - Removed mode button, using only text mode     #
#                       - Changed default ambient Luminance to 0.1      #
#                       - Updated displayed luminance values and        #
#                             processes to include ambient luminance,   #
#                             minimum luminance, and the luminance      #
#                             target values after ambient is included   #
#                       - Target minimum luminance font will change to  #
#                             red if it is lower than the available     #
#                             minimum luminance                         #
#                       - Added target amb/min luminance to displayed   #
#                             values.  The font changes color depending #
#                             on the value compared to the AAPM TG-18   #
#                             guidelines:                               #
#                                   0.00-0.25   black (good)            #
#                                   0.25-0.66   yellow (acceptable)     #
#                                   0.66+       red (unacceptable)      #
#                       - Starting directory for uLR files set to       #
#                             "C:\Program Files\HFHS\pacsDisplay-BIN"   #
#           Nov 2006    - Edited values to be more intuitive.           #
#                       - Altered Ambient ratio to match AAPM TG-16.    #
#                       - Added maximum possible luminance display      #
#                       - Target maximum luminance font will change to  #
#                             red if it is higher than the available    #
#                             maximum luminance                         #
#                       - Re-arranged interface and changed formatting  #
#                             of the text to be easier to understand    #
#                       - Starting directory changed to new LUTs        #
#                             directory                                 #
#                       - Removed starting luminance values             #
#           Dec 2006    - Version included in window title.             #
#       Version 2.4:                                                    #
#           Dec 2006    - Allowed the user to select the output file.   #
#                       - Included timestamp in output file.            #
#           Jan 2007    - modified output to print 'target Lum+Lamb'    #
#                             and 'uLR Lum+Lamb'.                       #
#           Dec 2013    - Reads the path to the LUT-directory from the  #
#                         Program Files installation directory and uses #
#                         this for the open/save initial directory.     #
#                       - Reorganized the widget layout and updated     #
#                         the terms to reflect AAPM, ACR, & IEC docs.   #
#                       - Now reporting the ambient ratio, Lamb/Lmin    #
#                         as a fraction (typically less than 1)         #
#                         with yellow set per TG18 and ACR (<1/4)       #
#                         and yellow set per TG18 (<2/3).               #
#                       - Added help button with INSTRUCTIONS.txt.      #
#       Version 2.6:                                                    #
#           Feb 2026    - Move to starkit distribution.                 #
#                       - Rearrange vfs to match other apps.            #
#                       - Revert to Help_message                        #
#                       - Add total JNDs information                    #
#########################################################################
#
#########################################################################
set title "lutGenerate 2.6"
set copydate "Feb 2026"
# first tell the user what version he is using
#
puts "$title" 
#puts "Copyright:       Xray Imaging Research Laboratory"
#puts "                         Henry Ford Health"
#puts "                         Detroit, MI"
#puts "                                         $copydate"
#
#########################################################################
#
set apps_path [file dirname [info script]]
source [file join $apps_path tcl xirlDefs-v06.tsp]	;# standard widget style

set info 0 ;# flag indicating whether help message is up or off.

source config-LutGen.txt  ;# not packages in exe file

#########################################################################
# configure window settings
#
#
wm title .  "$title"
wm resizable . 0 0

#  misc variables that need to be initialized
#
# set starting values
set LumAmb 0.20
set LumRatio 350.00
set MaxLum_tar_amb 350.0
set MaxLum_uLR ""
set MinLum_uLR ""

set MinLum_tar_amb [expr $MaxLum_tar_amb / $LumRatio]
set MaxLum_tar     [expr $MaxLum_tar_amb - $LumAmb]
set MinLum_tar     [expr $MinLum_tar_amb - $LumAmb]

set AmbRatio [expr $LumAmb / $MinLum_tar]
set AmbRatio_yellow .25
set AmbRatio_red .67

set TotalJND 581.6 ;# based on the starting values L'max 350 and Lamb 0.2

set input 0
set filein 0

set display_MaxLum_tar [format "%5.3f" $MaxLum_tar]
set display_MinLum_tar [format "%5.3f" $MinLum_tar]
set display_AmbRatio   [format "%5.3f" $AmbRatio]
set display_TotalJND   [format "%5.1f" $TotalJND]

# set up the command bar
#
#
frame .gen-quit_bar -relief raised -borderwidth 2
frame .displayname_bar -relief raised -borderwidth 2
frame .amblum_bar -relief raised -borderwidth 2
frame .des_maxlum_bar -relief raised -borderwidth 2
frame .lum_ratio_bar -relief raised -borderwidth 2
frame .divider1_bar -height 5 -relief raised -borderwidth 2
frame .tar_maxlum_bar -relief raised -borderwidth 2
frame .tar_minlum_bar -relief raised -borderwidth 2
frame .amb_ratio_bar -relief raised -borderwidth 2
frame .total_jnd_bar -relief raised -borderwidth 2
frame .divider2_bar -height 5 -relief raised -borderwidth 2
frame .maxlum_bar -relief raised -borderwidth 2
frame .minlum_bar -relief raised -borderwidth 2

pack .gen-quit_bar .displayname_bar .amblum_bar .des_maxlum_bar .lum_ratio_bar \
	.amb_ratio_bar .total_jnd_bar .divider1_bar .tar_maxlum_bar .tar_minlum_bar \
	.divider2_bar .maxlum_bar .minlum_bar \
	-side top -fill both
#
#**********************************************************************
#   COMMAND BAR 1: gen, help, and quit.
#**********************************************************************
#
# file select button
#
button .gen-quit_bar.sel \
				-width 12 \
				-text  "SELECT FILE" \
				-command "Select"
#
# initiation button
#
button .gen-quit_bar.gen  \
				-width 12 \
				-text  "GENERATE LUT" \
				-command "Generate"
#
button .gen-quit_bar.help        \
		-text ?                 \
		-font {arial 8 bold} \
		-width 1 \
		-cursor hand2                   \
		-command Help_message
#
#  quit button
#
button .gen-quit_bar.quit  \
			-text QUIT \
			-command  "Quit"
#
pack  \
           .gen-quit_bar.sel  \
           .gen-quit_bar.gen  \
                    -side left -padx 1m -pady 1m -fill x
#
pack  \
           .gen-quit_bar.quit  \
           .gen-quit_bar.help  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   COMMAND BAR 2: Display Name
#**********************************************************************
#
#  text variable to include the name of the display
#
label .displayname_bar.label -text {Display Name:}
entry .displayname_bar.back \
			  -justify left \
                    -width 30   \
                    -relief sunken \
                    -textvariable DisplayName 
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .displayname_bar.label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .displayname_bar.back   \
                    -side right -padx 1m -pady 1m -fill x

#
#**********************************************************************
#   COMMAND BAR 3: Ambient Luminance
#**********************************************************************
#
#  text variable to change the ambient luminance in cd/m2
#
label .amblum_bar.label1 -width 8 -text {Lamb}
label .amblum_bar.label2 -text {: Ambient Luminance, cd/m2}
entry .amblum_bar.back \
			  -justify right \
                    -width 8   \
                    -relief sunken \
                    -textvariable LumAmb 
	bind .amblum_bar.back <Return> "update_var"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack .amblum_bar.label1 .amblum_bar.back .amblum_bar.label2 \
                    -side left -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   COMMAND BAR 4: Desired Maximum Luminance w/ Ambient
#**********************************************************************
#
#  text variable to change the maximum luminance in cd/m2
#
label .des_maxlum_bar.label1 -width 8 -text {L'max}
label .des_maxlum_bar.label2 -text {: Maximum Luminance plus Lamb}
entry .des_maxlum_bar.back \
			  -justify right \
                    -width 8   \
                    -relief sunken \
                    -textvariable MaxLum_tar_amb
	bind .des_maxlum_bar.back <Return> "update_var"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack .des_maxlum_bar.label1 .des_maxlum_bar.back .des_maxlum_bar.label2 \
                    -side left -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   COMMAND BAR 5: Max/Min Luminance Ratio
#**********************************************************************
#
#  text variable to change the max/min luminance ratio
#
label .lum_ratio_bar.label1 -width 8 -text {r'}
label .lum_ratio_bar.label2 -text {: Luminance Ratio, L'max/L'min}
entry .lum_ratio_bar.back \
			-justify right \
			-width 8   \
			-relief sunken \
			-textvariable LumRatio 
	bind .lum_ratio_bar.back <Return> "update_var"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack .lum_ratio_bar.label1 .lum_ratio_bar.back .lum_ratio_bar.label2 \
                    -side left -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   COMMAND BAR 6: Lamb/Lmin, Ambient Luminance Ratio/Safety Factor
#**********************************************************************
#
#  text variable to display the minimum luminance plus ambient
#
label .amb_ratio_bar.label1 -width 8 -text {Ar}
label .amb_ratio_bar.label2 -text {: Ambient ratio, Lamb/Lmin}
label .amb_ratio_bar.back \
			-justify right \
			-relief  groove \
			-width   8     \
			-fg #00FF00 -bg #405060 \
			-textvariable display_AmbRatio
	bind .amb_ratio_bar.back <Return> "update_var"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack .amb_ratio_bar.label1 .amb_ratio_bar.back .amb_ratio_bar.label2 \
                    -side left -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   COMMAND BAR 6b: Total JNDs
#**********************************************************************
#
#  text variable to display the total JNDs for the specified luminances
#
label .total_jnd_bar.label1 -width 8 -text {JNDs}
label .total_jnd_bar.label2 -text {: Total GSDF JNDs}
label .total_jnd_bar.back \
			-justify right \
			-relief  groove \
			-width   8     \
			-textvariable display_TotalJND
	bind .total_jnd_bar.back <Return> "update_var"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack .total_jnd_bar.label1 .total_jnd_bar.back .total_jnd_bar.label2 \
                    -side left -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   COMMAND BAR 7: Target Maximum Luminance (without Ambient)
#**********************************************************************
#
#  text variable to display the maximum luminance plus ambient
#
label .tar_maxlum_bar.label \
			-text {Target Lmax =}
label .tar_maxlum_bar.back -width 8 \
			-justify right \
			-font {ansi 10 bold} \
			-foreground black \
			-textvariable display_MaxLum_tar
	bind .tar_maxlum_bar.back <Return> "update_var"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .tar_maxlum_bar.back .tar_maxlum_bar.label  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   COMMAND BAR 8: Target Minimum Luminance (without Ambient)
#**********************************************************************
#
#  text variable to display the minimum luminance plus ambient
#
label .tar_minlum_bar.label \
			-text {Target Lmin =}
label .tar_minlum_bar.back -width 8 \
			-justify right \
			-font {ansi 10 bold} \
			-foreground black \
			-textvariable display_MinLum_tar
	bind .tar_minlum_bar.back <Return> "update_var"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .tar_minlum_bar.back .tar_minlum_bar.label  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   COMMAND BAR 9: Maximum Possible Luminance (without Ambient)
#**********************************************************************
#
#  text variable to display the minimum luminance plus ambient
#
label .maxlum_bar.label -text {Possible Lmax =}
label .maxlum_bar.back -width 8 \
			-justify right \
			-textvariable MaxLum_uLR
	bind .maxlum_bar.back <Return> "update_var"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .maxlum_bar.back .maxlum_bar.label  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   COMMAND BAR 10: Minimum Possible Luminance (without Ambient)
#**********************************************************************
#
#  text variable to display the minimum luminance plus ambient
#
label .minlum_bar.label -text {Possible Lmin =}
label .minlum_bar.back -width 8 \
			-justify right \
			-textvariable MinLum_uLR
	bind .minlum_bar.back <Return> "update_var"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack   \
           .minlum_bar.back .minlum_bar.label  \
                    -side right -padx 1m -pady 1m -fill x


#*********************************************************************
# Procedures 
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
		wm title $w "Instructions for lutGenerate"
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
#**********************************************************************
#   utility procedure to calculate total JNDs
proc calc_JNDs {} {
	global MinLum_tar_amb MaxLum_tar_amb TotalJND

	if {$MinLum_tar_amb <= 0 || $MaxLum_tar_amb <= 0} return ;# return if invalid inputs
	
	set Lp(1) $MinLum_tar_amb
	set LogL(1) [expr log10($MinLum_tar_amb)]
	set Lp(256) $MaxLum_tar_amb
	set LogL(256) [expr log10($MaxLum_tar_amb)]

	set JND(1) [expr 71.498068 + 94.593053*$LogL(1) + 41.912053*pow($LogL(1),2) + \
		9.8247004*pow($LogL(1),3) + 0.28175407*pow($LogL(1),4) + \
		-1.1878455*pow($LogL(1),5) + -0.18014349*pow($LogL(1),6) + \
		0.14710899*pow($LogL(1),7) + -0.017046845*pow($LogL(1),8)]

	set JND(256) [expr 71.498068 + 94.593053*$LogL(256) + 41.912053*pow($LogL(256),2) + \
		9.8247004*pow($LogL(256),3) + 0.28175407*pow($LogL(256),4) + \
		-1.1878455*pow($LogL(256),5) + -0.18014349*pow($LogL(256),6) + \
		0.14710899*pow($LogL(256),7) + -0.017046845*pow($LogL(256),8)]

	set TotalJND [expr ($JND(256) - $JND(1))]

}
#**********************************************************************
#   utility procedure to update all text variables
#
proc update_var {} {
	global LumAmb MaxLum_tar MinLum_tar MinLum_uLR MaxLum_uLR LumRatio
	global MaxLum_tar_amb MinLum_tar_amb AmbRatio AmbRatio_yellow AmbRatio_red
	global display_MaxLum_tar display_MinLum_tar display_AmbRatio
	global TotalJND display_TotalJND

	# update Ambient Luminance
	if {$LumAmb < 0} {set LumAmb 0}

	# update Desired Maximum Luminance (w/ Ambient)
	if {$MaxLum_tar_amb < $LumAmb} {set MaxLum_tar_amb $LumAmb}

	# update Luminance Ratio
	if {$LumRatio < 1} {set LumRatio 1}

	# update Desired Minimum Luminance (w/ Ambient)
	set MinLum_tar_amb [expr $MaxLum_tar_amb / $LumRatio]

	# update Target Maximum Luminance (no Ambient)
	set MaxLum_tar [expr $MaxLum_tar_amb - $LumAmb]
	set display_MaxLum_tar [format "%5.3f" $MaxLum_tar]
	if {($MaxLum_uLR != "") && ($MaxLum_tar > $MaxLum_uLR)} {
		.tar_maxlum_bar.back configure -foreground red
	} else {
		.tar_maxlum_bar.back configure -foreground black
	}

	# update Target Minimum Luminance (no Ambient)
	set MinLum_tar [expr ($MaxLum_tar_amb / $LumRatio) - $LumAmb]
	set display_MinLum_tar [format "%5.3f" $MinLum_tar]
	if {($MinLum_uLR != "") && ($MinLum_tar < $MinLum_uLR)} {
		.tar_minlum_bar.back configure -foreground red
	} else {
		.tar_minlum_bar.back configure -foreground black
	}

	# update Target Min/Amb Luminance Ratio
	if {$LumAmb == 0} {
		set display_AmbRatio "N/A"
	} else {
		set AmbRatio [expr $LumAmb / $MinLum_tar]
		if {$AmbRatio > $AmbRatio_yellow} {
			if {$AmbRatio > $AmbRatio_red} {
				.amb_ratio_bar.back configure -fg #FF0000 -bg #405060 
			} else {
				.amb_ratio_bar.back configure -fg #FFFF00 -bg #405060 
			}
		} else {
			.amb_ratio_bar.back configure -fg #00FF00 -bg #405060 
		}

		set display_AmbRatio [format %5.3f $AmbRatio]
	}
	
	# update total JNDs
	calc_JNDs
    set display_TotalJND [format %5.1f $TotalJND]
}

#*********************************************************************
#  procedure to select and open the luminance data file
#
proc Select {} {
	global filein fileout title DisplayName lumN
	global input directory lumFilePath header1 header2 header3
	global LumAmb MaxLum_tar_amb MinLum_uLR MaxLum_uLR LumRatio

	# select new file
	set input2 [tk_getOpenFile -title "Select INPUT file" -initialdir $lumFilePath ]
	if {$input2 == ""} {
		return
	}
	set input $input2
	set directory [file dirname $input]

	# open file for reading
	if [catch {open $input r} filein] {
		puts stderr "Cannnot open $input $filein"
		return
	}

	#  skip header
	set header1 [gets $filein]
	set header2 [gets $filein]
	set header3 [gets $filein]

	set DisplayName [lindex $header2 3]

	# skip pure R, G, B readings
	for {set i 1} {$i <= 3} {incr i} {
		gets $filein
	}	

	# read number of lines and maximum luminance
	set uMaxLum 0.00
	set uMinLum 100.000
	for {set i -1} {[eof $filein]!= 1} {incr i} {
		set line [gets $filein]
		if {[lindex $line 1] != ""} {
			if {$uMaxLum < [lindex $line 1]} {
				set uMaxLum [lindex $line 1]
			}
			if {$uMinLum > [lindex $line 1]} {
				set uMinLum [lindex $line 1]
			}
		}
	}
	set MaxLum_tar_amb $uMaxLum
	set MaxLum_uLR [format "%5.3f" $uMaxLum]
	set MinLum_uLR [format "%5.3f" $uMinLum]
	set lumN $i

	# update variables
	update_var

	# close input file
	close $filein
}

#*********************************************************************
#  procedure to generate the calibrated LUT and registry files
#
proc Generate {} {
	global LumAmb LumRatio MaxLum_tar_amb MinLum_tar_amb filein fileout lumN
	global title DisplayName input directory header1 header2 header3

	.gen-quit_bar.gen  configure -text  "-PROCESSING-" -fg red
	update

	# check input values
	update_var

	# set parameters
	set MaxLum $MaxLum_tar_amb
	set MinLum [expr $MaxLum / $LumRatio]
	set uMaxLum 0.00
	set uMinLum 100.00

	# check input file
	if {$filein == 0} {
		tk_messageBox -type ok -message "No file selected."
		.gen-quit_bar.gen  configure -text  "GENERATE LUT" -fg black
		update
		return
	}


	# select output text file for writing
	set DisplayNamef [join $DisplayName _]
	set output $DisplayNamef
	append output _
	append output [format %5.2f $LumAmb]
	append output _
	append output [format %6.2f $MaxLum]
	append output _
	append output [format %6.2f $LumRatio]
	append output .txt

	set output [tk_getSaveFile -title "Select OUTPUT file"	\
		-initialfile $output -initialdir $directory]

	if {$output == ""} {
		tk_messageBox -type ok -message "LUT generation cancelled."
		.gen-quit_bar.gen  configure -text  "GENERATE LUT" -fg black
		update
		return		
	}


	# reset input file
	if [catch {open $input r} filein] {
		puts stderr "Cannnot re-open $input $filein"
		.gen-quit_bar.gen  configure -text  "GENERATE LUT" -fg black
		update
		return
	}

	# skip header
	set header1 [gets $filein]
	set header2 [gets $filein]
	set header3 [gets $filein]

	# skip pure R, G, B readings
	for {set i 1} {$i <= 3} {incr i} {
		gets $filein
	}	

	# read luminance data from file
	for {set i 1} {$i <= $lumN} {incr i} {
		set line [gets $filein]
		set L($i) [lindex $line 1]
		set L($i) [expr $L($i) + $LumAmb]
		set RGB($i) [lindex $line 2]
		set RGB($i) [string trimleft $RGB($i) #]

		if {$uMaxLum < $L($i)} {
			set uMaxLum $L($i)
		}
		if {$uMinLum > $L($i)} {
			set uMinLum $L($i)
		}
	}

	#  check input values
	if {$MaxLum > $uMaxLum} {
		tk_messageBox -type ok -message \
			"Maximum Luminance is too high and must be decreased. \
			\nThe highest luminance allowed for this file is [format "%5.3f" $uMaxLum]."
		.gen-quit_bar.gen  configure -text  "GENERATE LUT" -fg black
		update
		return
	} elseif {$MinLum < $uMinLum} {
		set uLumRatio [expr $uMaxLum / $uMinLum]
		tk_messageBox -type ok -message \
			"Minimum Luminance setting is too low - decrease the Luminance Ratio. \
			\nFor a Maximum Luminance of [format "%5.3f" $MaxLum], the maximum\
			Luminance Ratio allowed for this file is [format "%5.3f" [expr $MaxLum / $uMinLum]]."
		.gen-quit_bar.gen  configure -text  "GENERATE LUT" -fg black
		update
		return
	}


	#  construct calibrated LUT
	set Lp(1) $MinLum
	set LogL(1) [expr log10($MinLum)]
	set Lp(256) $MaxLum
	set LogL(256) [expr log10($MaxLum)]

	set JND(1) [expr 71.498068 + 94.593053*$LogL(1) + 41.912053*pow($LogL(1),2) + \
		9.8247004*pow($LogL(1),3) + 0.28175407*pow($LogL(1),4) + \
		-1.1878455*pow($LogL(1),5) + -0.18014349*pow($LogL(1),6) + \
		0.14710899*pow($LogL(1),7) + -0.017046845*pow($LogL(1),8)]

	set JND(256) [expr 71.498068 + 94.593053*$LogL(256) + 41.912053*pow($LogL(256),2) + \
		9.8247004*pow($LogL(256),3) + 0.28175407*pow($LogL(256),4) + \
		-1.1878455*pow($LogL(256),5) + -0.18014349*pow($LogL(256),6) + \
		0.14710899*pow($LogL(256),7) + -0.017046845*pow($LogL(256),8)]

	set TotalJND [expr ($JND(256) - $JND(1))]
	
	set JNDDL [expr ($JND(256) - $JND(1)) / 255]

	for {set i 2} {$i < 256} {incr i} {
		set j [expr $i - 1]
		set JND($i) [expr $JND($j) + $JNDDL]
		set LnJND($i) [expr log($JND($i))]
		set LogL($i) [expr (-1.3011877 + 0.080242636*$LnJND($i) + \
		0.13646699*pow($LnJND($i),2) + -0.025468404*pow($LnJND($i),3) + \
		0.0013635334*pow($LnJND($i),4)) / (1 + -0.025840191*$LnJND($i) + \
		-0.10320229*pow($LnJND($i),2) + 0.02874562*pow($LnJND($i),3) + \
		-0.0031978977*pow($LnJND($i),4) + 0.00012992634*pow($LnJND($i),5))]
		set Lp($i) [expr pow(10,$LogL($i))]
	}

	for {set i 1} {$i <=256} {incr i} {
		set a [expr abs($Lp($i)-$L(1))]
		set RGBf($i)    $RGB(1)
		set uLRamb($i)  $L(1)


		for {set j 2} {$j <= $lumN} {incr j} {
			set b [expr abs($Lp($i)-$L($j))]
			if {$b < $a} {
				set a $b
				set RGBf($i)    $RGB($j)
				set uLRamb($i)  $L($j)
			}
		}
	}

	for {set i 1} {$i <= 256} {incr i} {
		set R($i) [string range $RGBf($i) 0 1]
		set G($i) [string range $RGBf($i) 2 3]
		set B($i) [string range $RGBf($i) 4 5]
	}


	# select and open output text file for writing
	set fileout1 [open $output w]

	#  write LUT file
	puts $fileout1 \
		"# $title - [clock format [clock seconds] -format "%D %T"] - $header2"
	puts $fileout1 \
		"# Ambient = $LumAmb   Max. Luminance = $MaxLum   Luminance Ratio = $LumRatio"
	puts $fileout1 "$header1"
	puts $fileout1 "$header3"
	puts $fileout1 " DV    R    G    B     target Lum+Lamb   uLR Lum+Lamb"
	for {set i 1} {$i <= 256} {incr i} {
		set line "[format "%3i" $i]:  [format "%03i" 0x$R($i)]  [format "%03i" 0x$G($i)]  [format "%03i" 0x$B($i)]"
		append line "       [format "%9.3f" $Lp($i)]  [format "%9.3f" $uLRamb($i)]"
		puts $fileout1 $line
	}

	# close input and output files
	close $filein
	close $fileout1

	.gen-quit_bar.gen  configure -text  "GENERATE LUT" -fg black
	update

	tk_messageBox -type ok -title "LUT Generation Complete" \
		-message "LUT generated. \
		\nuLR: [format "%4.4f" $uMinLum] to [format "%4.4f" $uMaxLum] (cd/m^2)\
		\ncLR: [format "%4.2f" $MinLum] to [format "%4.2f" $MaxLum]"

}

#**********************************************************************
# procedure to close open files and quit
#
proc Quit {} {
	global filein

	exit
}

#************************************************************************
# END LutGenerate
#************************************************************************
