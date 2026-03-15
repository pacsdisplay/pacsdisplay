package provide app-lumResponse 1.0

# ==============================================================================
# MODULE VERSION: 2.5
# ==============================================================================

#############################################################################
#							lumResponse 2.5									#
#	Written by:																#
#		Michael J. Flynn													#
#		Philip M. Tchou														#
#		Nicholas B. Bevins													#
#																			#
#	X-ray Imaging Lab, Henry Ford Health Systems, Detroit, MI				#
#	Nuclear Engineering and Radiological Sciences, Univ. of Michigan		#
#	Imaging Physics, MaineHealth Maine Medical Center - Portland, ME		#
#																			#
#	This program will put up a large window on the screen with a grey		#
#	background and a central target region. This pattern is intended for	#
#	assessing display luminance response.  The grey intensity of the		#
#	target region is cycled through increasing intensity values to measure	#
#	luminance versus grey value.											#
#																			#
#		Copyright:			Xray Imaging Research Laboratory				#
#								Henry Ford Health System					#
#								Detroit, MI									#
#																			#
#										DT	Vers 1.1	JUN	1999			#
#										DT	Vers 1.2	OCT  1999			#
#										DT   Vers 1.3	NOV  2001			#
#								            Vers 1.4	AUG  2002			#
#								            Vers 1.5	OCT  2002			#
#								            Vers 1.5a	NOV  2002			#
#								            Vers 1.5b	APR  2003			#
#								            Vers 1.5c	JAN  2004			#
#								            Vers 1.5d	MAY  2005			#				
#								            Vers 1.5e	NOV  2005			#
#								            Vers 1.5f	SEP  2006			#				
#								            Vers 1.6	DEC  2006			#				
#								            Vers 1.7	APR  2006			#				
#								            Vers 1.8	OCT  2008			#				
#								            Vers 1.9	Jun  2011			#				
#								            Vers 2.0	Feb  2013			#				
#								            Vers 2.1	Jun  2013			#
#											Vers 2.2 	OCT 2019			#
#											Vers 2.2b	APR 2020			#
#											Vers 2.2c	JAN 2022			#
#											Vers 2.3	JUL 2022			#
#											Vers 2.4	JAN 2025			#
#											Vers 2.5	DEC 2025			#
#																			#
#           History:                                                      #
#                    v1.1  changed region color definition to support     #
#                           RGB color types for special calibrations      #
#                           Background remains a gray with R=G=B          #
#                    v1.2  Added support to sequence RGB values           #
#                          through a 3 x 256 set.                         #
#                    v1.4  Stripped down version of 1.3 for the           #
#                          measurement of grey palettes.                  #
#                    v1.5  allowed RGB phase changes to be directed by    #
#                          a text file and added a means by which to 	  #
#                          filter out extraneous luminence values.  A	  #
#                          log file output was also added.                #
#                    v1.5  Provided a means to cancel data acquisition    #
#                           without closing the entire program.           #
#                    v1.5b Included tests of the pure R, G, and B outputs #
#                           with pauses to allow the IL1700 time to       #
#                           adjust                                        #
#                    v1.5c Default output filename changed to include     #
#                           "cLR" or "uLR" depending on mode              #
#                    v1.5d Line changed in lumConfig.txt that permits     #
#                          improved wrapping with tclApp. New exe.        #
#                    v1.5e Allowed switching of COM ports in config file. #
#                                                                         #
#  Ver. 1.5f - Sep 2006    Added dL/L column to output file and an option #
#                           to plot the dL/L after saving.  Requires      #
#                           Gnuplot in the same directory.                #
#            - Nov         Made the command and IL1700 windows visible    #
#                           over all other program windows.               #
#            - Dec 1       Changed the output so the color measurements   #
#                           start with '#' and are treated as comments    #
#                           while the grayscale measurements start at 1.  #
#            - Dec 5       Added major and minor grey level steps to the  #
#                           output, before the DL/L column.               #
#                          Changed outlier treat to catch negative        #
#                           luminance changes as outliers, regardless of  #
#                           the outlier limit.                            #
#                          Altered the COMnum option to allow any number  #
#                           for the serial port, rather than just 1 or 2. #
#                          Moved wgnuplot.exe to a directory specified by #
#                           the lumConfig.txt file.                       #
#            - Dec 6       Changed the IL1700 window to display the major #
#                           and minor grey levels starting at 1 instead   #
#                           of 0.                                         #
#                          Changed name of config file from lumConfig.txt #
#                           to LRconfig.txt.                              #
#                          Included major and minor phases in log file,   #
#                           relative luminance change, and header labels. #
#                          An option was added to the config file that    #
#                           allows for the filtering of negative changes  #
#                           in luminance separate from positive ones.     #
#                          Negative changes are no longer automatically   #
#                           treated as outliers.                          #
#                          Outlier filtering is no longer turned off if   #
#                           the limit values are set to 0.                #
#            - Dec 7       Included an option when an outlier is found to #
#                           accept it as a measurement value.             #
#                          Formatted log file to line up columns.         #
#                          Formatted output file to line up columns.      #
#                          Fixed an error with the major and minor phases #
#                           in the output file.                           #
#            - Dec 14      Fixed an error in the outlier handling.  Will  #
#                           now be handled in lumResponse.tcl rather than #
#                           in tL_IL1700.tsp.                             #
#                          Included config option to limit the number of  #
#                           outlier tests.                                #
#                          Included config option for verbose logging.    #
#                           When set, the log file will include all data  #
#                           from the IL1700.  This was previously the     #
#                           default.                                      #
#            - Dec 15      Restructured code to put procedures in a sub   #
#                           directory. Moved xirlDef to sourced file.     #
#                          Output log entries to console for debugging.   #
#                          Minor formatting changes to log and output     #
#                           files including a timestamp.                  #
#                          Fixed an error where the outliers were not     #
#                           being tallied properly.                       #
#                          Changed default mode to 1786.                  #
#                                                                         #
#   Ver. 1.6 - Dec 17      Added window for defining settings used for    #
#                          test window properties and IL1700 init.        #
#                          Redstructured main window design with IL1700   #
#                           result incorporated in main window.           #
#                          Help dialoques incorporated for settings.      #
#            - Dec 18      Added option to build a Display ID from the    #
#                           EDID values.                                  #
#            - Dec 19      Fixed error preventing test image from being   #
#                           re-initialized.                               #
#                          Added messages to instruct users before and    #
#                           during a measurement.                         #
#                          Merged DisplayID and EDID options bar.         #
#                          Added tolerance option to outlier checks.      #
#                          Added number of outliers resolved/accepted to  #
#                           the output at the end of a measurement.       #
#                          Updated plot options to include a plot of the  #
#                           luminance vs. p-value and save the plots as   #
#                           PNG files.                                    #
#            - Dec 22      Added an additional delay during outlier tests #
#                           controlled by a config file setting.          #
#                          Adjusted display of minor/major states in IL   #
#                           window to correctly match the ILavg value.    #
#            - Jan 3 2007  Updated some of the messages before and after  #
#                           the luminance acquisition.                    #
#            - Jan 4       Changed font color to a dark grey for the main #
#                           values in the IL window until initialized.    #
#            - Jan 5       Added outlier indicator in IL window.          #
#            - Jan 8       Minor changes to message windows.              #
#            - Jan 10      Fixed minor error in display of last sub-step. #
#   Ver. 1.7 - Apr 09      Updated to use getEDID 1.1                     #
#   Ver. 1.8 - Oct 02 2008 Incorporated routines to support the LXcan     #
#                          Luminance meter using a USB connection.        #
#                          Generalized the GUI for any luminance meter.   #
#   Ver. 1.9 - Jun 01 2011 Incorporated routines to support the           #
#                          Display 2 Luminance USB meter.                 #
#                          The Argyll spotread program is used to read    #
#                          the meter continuously and parse the reply.    #
#                        - The three measures at the beginning with red,  #
#                          green, and blue colors changed to present      #
#                          measures with black value, #000000.            #
#                          The i1Display2 stops returning when taken from #
#                          a high luminance quickly to black (probably    #
#                          due to automatic integration time adjustment). #
#                          Moreover, the Argll routines are a better way  #
#                          to measure white point and color space.        #
#                          Keeping three measures keeps the uLR format    #
#                          the same for lutGenerate. Using black may help #
#                          stabilize the meter.                           #
#                       -  Added message for record with OTHER mode.      #
#                       -  Added QC mode with 16 measure of 2 values      #
#                          used to assess dL/L vs gray level.             #
#                       -  corrected help window title.                   #
#   Ver. 2.0 - Feb 28 2013 For photometers using the Argyll spotread      #
#                          program, the chrominance in now read; u'v'     #
#                          The QC(16x2) more software to evaluate the     #
#                          luminance/chrominance response has been        #
#                          rewritten and the plot formats upgraded.       #
#                       -  Developed under W7 64 bit with version 4.6     #
#                          gnuplot and version 1.4.0 Argyll.              #
#                       -  Support for the X-rite i1Display Pro           #
#                          using the Argyll spotread program.             #
#                       -  New QC color white point tracking analysis     #
#                          and plots for a D65 (2degree) target.          #
#   Ver. 2.1 - Dec 15 2013 2.0 beta feedback update.                      #
#                       -  Results saved to a named directory.            #
#                       -  QC plots include manf & model information      #
#                          QC plots now have +/-10%, +/-20%               #
#                       -  Demo mode now has some fake luminance values   #
#                       -  Log now written to directory from config file. #
#                       -  Region size in test image now set from Config. #
#                       -  Gnuplots changed to wxt terminal type and      #
#                          QC16 u',v' limited to L>=5.0 cd/m2(IEC).       #
#                       -  Now using new eyeoneUtil.tsp (same as i1meter).#
#                       -  Now specifying widgth and height of window and #
#                          gray region in mm and setting pixel pitch using#
#                          one of fours values set in the config file.    #
#                       -  QC 16x2 evaluation generates a standalong      #
#                          html report withing the results folder.        #
#            - Mar 22 2014 Increased cLR output format to support the     #
#                          larger precision of the i1Display Pro.         #
#	Ver 2.2	 - Oct 2019 -  Complete overhaul to remove Expect usage       #
#                       -  Incorporate other QC methods                   #
#                       -  Clean up related tsp scripts                   #
#                       -  Remove support for IL1700 and LXcan photometers#
#                       -  TODO: Add ability to measure external devices  #
#	v2.2b	- Apr 2020	-	Move qcmode to the LRconfig file				#
#	v2.2c	- Jan 2022	-	Make use of env var I1D3_ESCAPE to allow for	#
#							3rd party i1d3 meters not already included		#
#							in spotread										#
#	v2.3	- Jul 2022	-	Modify save routine to only ask for directory	#
#							and not use the workstation name for folders	#
#	v2.4	- Jan 2025	-	Include addition acquisition modes for external	#
#							(e.g., AWS) display systems	with typical		#
#							patterns										#
#						-	Correct issue where 256 mode doesn't load		#
#							correctly after 18/52 is used					#
#	v2.5	- Dec 2025	-	Include HOLD/MOVE information for user in GUI	#
#							for external display measurements				#
#						-	Move to starkit based application				#
#						-	Update eval html file to remove targets			#
#							and include total JNDs							#
#						-	Revert to txt based help (instead of pdf)		#
#						-	Use logging flag in config to enable/disable	#
#																			#
#																			#
#############################################################################

#console show

set title "lumResponse vers. 2.5"
# first tell the user the version
#
puts "$title"
puts "Copyright:  Xray Imaging Research Laboratory"
puts "                   Henry Ford Health"
puts "                   Detroit, Michigan"
puts "        12/2025 - M.J Flynn, N.B Bevins, P.M Tchou"
#
#**********************************************************************
# Variable definitions and procedures from other files
# reference to 'apps_path directory to support wrapping with tclApp

package require base64	  ;# used for converting plots for embedding into html.

source LRconfig.txt        ;# variable definitions (not wrapped)

set apps_path [file dirname [info script]]
source [file join $apps_path tcl xirlDefs-v06.tsp]  ;# standard widget style
source [file join $apps_path tcl lumR-evalQClr.tsp] ;# evaluate QC mode LR data
source [file join $apps_path tcl lumR-settings.tsp] ;# settings window
source [file join $apps_path tcl lumR-IL.tsp]       ;# lum meter procedures
source [file join $apps_path tcl lumR-plot.tsp]     ;# plotting procedures
source [file join $apps_path tcl lumR-Help.tsp]     ;# help text content
source [file join $apps_path tcl eyeoneUtil.tsp]    ;# i1Display procedures
source [file join $apps_path tcl JNDdicom.tsp]      ;# JNDtoLUM & LUMtoJND

set qctmlFile [file join $apps_path tcl html qcHTML.tml]    ;# used in evalQC
set logoFile  [file join $apps_path tcl html pdQC-logo_sm.png] ;# used in evalQC
set EDIDtxt "getEDIDlog.txt"
set binpath $LIB	;# BIN directory for spotread, getEDID

setMeter  ;# procedure to initialize the defined photometer parameters
setGeom   ;# procedure to initialize the gray region geometry in pixels

#**********************************************************************
#   define application variables
#
#
set plotFileName "temp.gnu"

# sequence of "numgrey" background grey values 
set numgrey 3
set initNum 2
set num $initNum

set Ngrey(1) 5 
set Ngrey(2) 151  ;#init to 20% lum for calibrated display of 1-250 nit
set Ngrey(3) 250 

set greyB $Ngrey($num) ;# initialize background grey

# parameters defining the test region shape
set shape_init rectangle   ;#set to either rectangle or oval
set shape $shape_init

# parameters defining the grey levels for the rectangle
set greyR_init -3     ;#initial value (Originally for R,G, & B. Now black measures)
set greyR $greyR_init ;#current value
set dGrey 1           ;#difference between grey levels
set greyR_offset 0    ;#offset for the displayed gray values
set greyR_display [format %3i [expr $greyR + $greyR_offset]]		;# Major grey level display value

# parameters for the pattern type
set patrn_init 1        ;#patrn=1 => square
set patrn patrn_init    ;#patrn=2 => circle

# flags indicating on (1) or off (0).
set start 0
set info 0
set rect 0
set record 0

# set luminance meter, IL, and LUT parameters
set IL 0		;# Communication channel for the IL1700
set ILautoNum 0  ;#keeps track of the No. of measures
set ILstatus  0  ;# start with the IL status at off
set LUTphase 0   ;# initialize variable for RGB pattern, 0 to 6 is displayed as 1 to 7
set LUTphase_display [expr $LUTphase + 1]		;# Minor grey level display value
set phase(0) "0	0	0"
if {$logging == 1} {set logfile [file join $logDir Lmeter.log]}
set log 0
set error 0
set offgrey #606060

# set display ID and EDID parameters
set displayN 1

# message shown when OTHER selected
set msgOther "      When the OTHER mode is selected, \
      a valid phase file must be selected to modify the \
      gray levels for each of 256 major gray levels. \
 \
      Do you want to continue? \
      "
#
#**********************************************************************
#
# set up the control window and test pattern window
#
wm title .  "$LUTmode Palette"
wm geometry . $controlOffset
if {$resize == 0} {
	wm resizable . 0 0
}
#
# retrieve the dpi for scaling
#
set dpiscale [expr {[winfo pixels . 1i] / 96.0}]
#
# create a proc to scale all the sizes for the dpi
#
proc scaled {size} {global dpiscale; expr {int($size * $dpiscale)}}
#
#       ... name for the image pattern window
#
set w .lum 
#
# set up the command bar and initial message
#
frame .modequit_bar -relief raised -borderwidth [scaled 2]
frame .spacer_bar -relief raised -borderwidth [scaled 2] -height [scaled 5]
frame .displayID_bar -relief raised -borderwidth [scaled 2]
frame .init_bar -relief raised -borderwidth [scaled 2]
frame .init-IL_bar -relief raised -borderwidth [scaled 2]
frame .rec_bar -relief raised -borderwidth [scaled 2]
frame .save_bar -relief raised -borderwidth [scaled 2]
pack .modequit_bar .spacer_bar .displayID_bar .init_bar .init-IL_bar .rec_bar .save_bar -side top -fill both
#
#**********************************************************************
#   HELP, MODE, AND QUIT
#**********************************************************************
#
#  button on the left to display the info message
#
button .modequit_bar.help  \
		-text ?                 \
		-font {arial 8 bold} \
		-width 1 \
		-cursor hand2                   \
		-command Help_message

#
#  menu to select the mode
#
menubutton .modequit_bar.mode -text " MODE " -font {arial 8 bold underline} -width 8 \
	-menu .modequit_bar.mode.menu
		set m [menu .modequit_bar.mode.menu -tearoff 0]
			$m add radiobutton     \
				-label "QC (256x1)" \
				-value 256          \
				-variable LUTmode   \
				-command {wm title .  "$LUTmode Palette"; \
					.lumMeter.delay configure -fg $bgClr; \
					.lumMeter.move configure -fg $bgClr}
			$m add separator
			$m add radiobutton     \
				-label "QC (52x1)" \
				-value 52          \
				-variable LUTmode   \
				-command {wm title .  "$LUTmode Palette"; \
					.lumMeter.delay configure -fg $bgClr; \
					.lumMeter.move configure -fg $bgClr}
			$m add separator
			$m add radiobutton     \
				-label "QC (18x1)" \
				-value 18          \
				-variable LUTmode   \
				-command {wm title .  "$LUTmode Palette"; \
					.lumMeter.delay configure -fg $bgClr; \
					.lumMeter.move configure -fg $bgClr}
			$m add separator
			$m add radiobutton     \
				-label "QC (16x2)" \
				-value 16          \
				-variable LUTmode   \
				-command {wm title .  "$LUTmode Palette"; \
					.lumMeter.delay configure -fg $bgClr; \
					.lumMeter.move configure -fg $bgClr}
			$m add separator
			$m add radiobutton     \
				-label "QC (Ext 11)" \
				-value 11          \
				-variable LUTmode   \
				-command {wm title .  "11 Palette External"; \
					.lumMeter.delay configure -fg $fgClr; \
					.lumMeter.move configure -fg $fgClr}
			$m add separator
			$m add radiobutton     \
				-label "QC (Ext 18)" \
				-value 181          \
				-variable LUTmode   \
				-command {wm title .  "18 Palette External"; \
					.lumMeter.delay configure -fg $fgClr; \
					.lumMeter.move configure -fg $fgClr}
			$m add separator
			$m add radiobutton     \
				-label "1786 Palette" \
				-value 1786          \
				-variable LUTmode   \
				-command {wm title .  "$LUTmode Palette"; \
					.lumMeter.delay configure -fg $bgClr; \
					.lumMeter.move configure -fg $bgClr}
			$m add separator
			$m add radiobutton     \
				-label "766 Palette" \
				-value 766          \
				-variable LUTmode   \
				-command {wm title .  "$LUTmode Palette"; \
					.lumMeter.delay configure -fg $bgClr; \
					.lumMeter.move configure -fg $bgClr}
			$m add separator
			$m add radiobutton     \
				-label "DEMO MODE" \
				-value 0          \
				-variable LUTmode   \
				-command {wm title .  "DEMO MODE"; \
					.lumMeter.delay configure -fg $bgClr; \
					.lumMeter.move configure -fg $bgClr}
			$m add separator
			$m add radiobutton     \
				-label "OTHER" \
				-value 1          \
				-variable LUTmode   \
				-command {wm title .  "Designated Palette"; \
					.lumMeter.delay configure -fg $bgClr; \
					.lumMeter.move configure -fg $bgClr}
#
#  quit button
#
button .modequit_bar.quit  \
                    -text QUIT \
                    -command  "set toolStatus 0; Tool_quit ."
button .modequit_bar.geom  \
                    -text  GEOM\
                    -font {arial 8 bold} \
                    -command {optionWindow geom}
button .modequit_bar.il  \
                    -text  METER\
                    -font {arial 8 bold} \
                    -command {optionWindow il}

pack  \
		.modequit_bar.mode  \
                    -side left -padx 1m -pady 1m -fill x
pack  \
           .modequit_bar.geom  .modequit_bar.il    \
                    -side left -padx 1m -pady 1m -fill x
pack  \
		.modequit_bar.quit  \
		.modequit_bar.help  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   DISPLAY ID
#**********************************************************************
#
#  text variable to include the system/monitor name
#
frame .displayID_bar.left
frame .displayID_bar.right

label .displayID_bar.left.displayID_label -text {Display ID:}
label .displayID_bar.left.displayID_spacer

entry .displayID_bar.right.displayID_entry \
			  -justify left \
                    -width 25   \
                    -relief sunken \
                    -textvariable DisplayName
#
#  Windows display identifier
#
label .displayID_bar.right.displayNum_label -text "Display #:"
entry .displayID_bar.right.displayNum_entry \
			  -justify center \
                    -width 2   \
                    -relief sunken \
                    -textvariable displayN
#
#  get EDID monitor and serial number values 1
#
button .displayID_bar.right.getEDID  \
                    -text "GET EDID ID" \
                    -width 10 \
                    -command "getEDID"
#
# now pack the widgets
# note that for pack -side left/right, 1st entry is most left/right
#
pack .displayID_bar.left .displayID_bar.right -side left -fill x

pack   \
           .displayID_bar.left.displayID_spacer  \
                    -side top -padx 1m -pady 1m -fill x
pack   \
           .displayID_bar.left.displayID_label  \
                    -side top -padx 1m -pady 1m -fill x
pack   \
           .displayID_bar.right.displayID_entry   \
                    -side bottom -padx 1m -pady 1m -fill x
pack   \
           .displayID_bar.right.displayNum_label  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .displayID_bar.right.displayNum_entry  \
                    -side left -padx 1m -pady 1m -fill x
pack   \
           .displayID_bar.right.getEDID  \
                    -side left -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   LUMINANCE RESPONSE 4 STEP SEQUENCE
#**********************************************************************
#
# make test window button
#
label .init_bar.label -text {Step 1: Position Test Image}
button .init_bar.init  \
                    -text  IMAGE -width 6  \
                    -command "Initialize $w"

pack  \
           .init_bar.label  \
                    -side left -padx 1m -pady 1m -fill x
pack  \
           .init_bar.init  \
                    -side right -padx 1m -pady 1m -fill x

#
# initialize the luminance meter
#
label .init-IL_bar.label -text {Step 2: Initialize Meter}
button .init-IL_bar.init  \
                    -text  METER -width 6  \
                    -command [list  IL_init]
pack  \
           .init-IL_bar.label  \
                    -side left -padx 1m -pady 1m -fill x
pack  \
           .init-IL_bar.init  \
                    -side right -padx 1m -pady 1m -fill x

#
#  button to start auto sequence
#
label .rec_bar.label -text {Step 3: Record Data}
button .rec_bar.auto \
                    -text RECORD -width 6  \
                    -command [list IL_rec $w]
pack  \
           .rec_bar.label  \
                    -side left -padx 1m -pady 1m -fill x
pack  \
           .rec_bar.auto  \
                    -side right -padx 1m -pady 1m -fill x

#
#  button to save the acquired data
#
label .save_bar.label -text {Step 4: Save Data}
button .save_bar.save  \
                    -text SAVE -width 6  \
                    -command  [list IL_save]
pack  \
           .save_bar.label  \
                    -side left -padx 1m -pady 1m -fill x
pack  \
           .save_bar.save  \
                    -side right -padx 1m -pady 1m -fill x
#
#**********************************************************************
#   LUMINANCE METER DISPLAY at window bottom
#**********************************************************************
#
set bgClr #204080  ;# 'blueprint' blue
set fgClr #f0f0f0  ;# near white

frame .lumMeter  -height [scaled 140] -width [scaled 360] -relief sunken -bg $bgClr \
	           -borderwidth [scaled 10] -highlightthickness [scaled 1] -highlightbackground $fgClr

# ... photometer information
label .lumMeter.model -text $model -font {courier 6 bold} \
                      -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.model -in .lumMeter -anchor nw -relx .00 -rely .00

# ... external delay information
label .lumMeter.delay -text "$extDelay sec" -font {courier 8 bold} \
					  -bg $bgClr -fg $bgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.delay -in .lumMeter -anchor nw -relx .7 -rely .00
# ... key binding to inc/dec the delay
bind .lumMeter.delay <Button-1> {
	global extDelay
	if {$extDelay > 1} {
		incr extDelay -1
		.lumMeter.delay configure -text "$extDelay sec"
	}
}
bind .lumMeter.delay <Button-3> {
	global extDelay
	incr extDelay
	.lumMeter.delay configure -text "$extDelay sec"
}

# ... external delay move/hold information
label .lumMeter.move -text "" -font {courier 8 bold} \
					  -bg $bgClr -fg $bgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.move -in .lumMeter -anchor nw -relx .9 -rely .00

# ... luminance and step numbers in center
 
label .lumMeter.labels -text "GRAY LEVEL           SUB LEVEL              AVG LUMINANCE" \
	                 -font {arial 8} -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.labels -in .lumMeter -anchor nw -relx .05 -rely .25

set ILavg_display [format %7.3f 0]
label .lumMeter.avg -textvariable ILavg_display -font {courier 20 bold} \
                    -bg $bgClr -fg $offgrey -padx [scaled 1] -pady [scaled 1]
place .lumMeter.avg -in .lumMeter -anchor nw -relx .575 -rely .45

set greyR_display [format %3i 0]
label .lumMeter.gmajor -textvariable greyR_display -font {courier 20 bold} \
                       -bg $bgClr -fg $offgrey -padx [scaled 1] -pady [scaled 1]
place .lumMeter.gmajor -in .lumMeter -anchor nw -relx .05 -rely .45

set LUTphase_display 1
label .lumMeter.gminor -textvariable LUTphase_display -font {courier 20 bold} \
                       -bg $bgClr -fg $offgrey -padx [scaled 1] -pady [scaled 1]
place .lumMeter.gminor -in .lumMeter -anchor nw -relx .4 -rely .45

# ... meter reponse and autonum at bottom
set ILval_display [format %8.3f 0]
label .lumMeter.val -textvariable ILval_display -font {courier 8 bold} \
                    -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.val -in .lumMeter -anchor nw -relx .3 -rely .85

label .lumMeter.num -textvariable ILautoNum -font {courier 8 bold} \
                    -bg $bgClr -fg $fgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.num -in .lumMeter -anchor nw -relx .1 -rely .85

label .lumMeter.outlier -text "OUTLIER" -font {courier 8 bold} \
                        -bg $bgClr -fg $bgClr -padx [scaled 1] -pady [scaled 1]
place .lumMeter.outlier -in .lumMeter -anchor nw -relx .7 -rely .85

pack  .lumMeter

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
		wm title $w "Instructions for lumResponse"
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
# includes check on IL1700 status
#
proc Tool_quit { w } {

	global ILstatus IL log record

	if {$record == 1} {
		tk_messageBox -type ok -message \
			"Data acquisition must be stopped before closing this window."
		return
	}

	if {$ILstatus == 1} {
		if {$IL != 0} {close $IL}
		set ILstatus 0
	}
	if {$log != 0} {
		close $log
	}
	destroy $w
}
#
#**********************************************************************
#   utility procedure to make a color variable from a greylevel 
#	use of int operator handles decimal greys (SMPTE is ill-defined)
#
proc Color {grey} {

	set red [format "%02x" [expr int($grey)]]
	set green $red
	set blue $red
	return #$red$green$blue
}
#
#**********************************************************************
#   utility procedure to make a color variable from a greylevel 
#   This routine is used only for the central region of the luminance
#   calibration where the color options can be invoked to define
#   colors where R, G, and B may not be equal. 
#   This permits special calibrations for certain monitors
#   One mode is supported in this version;
#          LUTmode sequences depending on the LUTphase variable
#
#	use of int operator handles decimal greys (SMPTE is ill-defined)
proc ColorRGB {grey} {

	global phase LUTmode LUTphase lastRGB

	if {$grey >= 0} {
		if {$grey == 255} {
			set red ff
			set green ff
			set blue ff
			set lastRGB #$red$green$blue
		} else {
			if {$LUTmode != 0} {
				set red [format "%02x" [expr int($grey + [lindex $phase($LUTphase) 0])]]
				set green [format "%02x" [expr int($grey + [lindex $phase($LUTphase) 1])]]
				set blue [format "%02x" [expr int($grey + [lindex $phase($LUTphase) 2])]]
				set lastRGB #$red$green$blue
			} else {
				set lastRGB [Color $grey]
			}
		}
	} else {
		;# These were originally used for red, green, and blue tests.
		;# They are now set to #000000 to stabilize the meter.
		if {$grey == -3} {
			set red 00
			set green 00
			set blue 00
		} elseif {$grey == -2} {
			set red 00
			set green 00
			set blue 00
		} elseif {$grey == -1} {
			set red 00
			set green 00
			set blue 00
		}
		set lastRGB #$red$green$blue
	}

	return $lastRGB
}
#
#*********************************************************************
#  procedure to initialize the test pattern window 
#
proc Initialize {w} {
	global title width height rect_init rectX rectY greyB start 
	global shape rect greyR_init greyR greyB_init greyB resize
	global rect_tag patrn patrn_init info initNum Ngrey num
	global bb_llx bb_lly bb_urx bb_ury W colormap toolOffset
	global greyR_display record rectX rectY greyR_offset

	if {$record == 1} {
		tk_messageBox -type ok -message \
			"Data acquisition must be stopped before re-initializing."
		return
	}
     #
	set greyR 0			      ;# reset rectangle grey
	set greyB $Ngrey($initNum)	;# reset background grey
	set num $initNum			;# reset background grey index
	set greyR_display [format %3i [expr {max($greyR + $greyR_offset,0)}]]		;# reset major grey level display value

     #	... get the grey index for the next call
     set num [expr $num - 1]
     if {$num == 0} {set num $numgrey}
     #
     #  for the initial start
     #  define the window with a canvas for the test patterns 
	catch {destroy $w}
	if {$colormap == 1} {
		toplevel $w -colormap new
	} else {
		toplevel $w
	}
	wm title $w  "$title: Luminance Response"
	wm geometry $w $toolOffset
	if {$resize == 0} {
		wm resizable $w 0 0
	}
	#  init with backgrd(2)
	canvas $w.canvas  -width $width -height $height \
				-background [Color $greyB]
	pack $w.canvas

	#  set start to indicate that initialization is done
	set start 1


     # reconfigure the background grey level
     $w.canvas configure -background [Color $greyB]

     # delete the prior rectangle if this is not the initial start
     #
     if {$rect == 1} {
          $w.canvas delete rect_tag
     } else {
     set rect 1
     }
           
     SetRect $width $height $rectX $rectY

     # create the rectangle
     $w.canvas create $shape \
                   $bb_llx $bb_lly $bb_urx $bb_ury \
                   -fill [ColorRGB $greyR] \
                   -outline [ColorRGB $greyR] \
                   -tag rect_tag

	# ...set the command window to always be visible
	wm attributes . -topmost 1
	focus -force $w
}
#*********************************************************************
#  procedure to initialize the test pattern values for external measurements 
#
proc InitializeExt {} {
	global rect_init greyB start 
	global greyR_init greyR greyB_init greyB resize
	global initNum Ngrey num
	global greyR_display record greyR_offset

	set greyR 0			      ;# reset rectangle grey
	set greyB $Ngrey($initNum)	;# reset background grey
	set num $initNum			;# reset background grey index
	set greyR_display [format %3i [expr {max($greyR + $greyR_offset,0)}]]		;# reset major grey level display value

     #	... get the grey index for the next call
     set num [expr $num - 1]
     if {$num == 0} {set num $numgrey}
     #

	#  set start to indicate that initialization is done
	set start 1
}
#
#*********************************************************************
#  procedure to change the rectangle grey level
#
proc  Next_greyR {w change}  {

	global greyR greyR_display
	global start info W greyR_offset

	if {$start == 0} {
		Initialize $w
	}

	if {$greyR >= 0} {
		set greyR [expr $greyR + $change]
	} else {
		incr greyR
	}

	#adjust last step to help keep max at 255, min at 0
	if {$greyR > 255} {set greyR 255}
	if {$greyR_display > [expr 255 + $greyR_offset]} {set greyR_display [expr 255 + $greyR_offset]}

	# reconfigure the button and the background grey level
	$w.canvas itemconfigure rect_tag \
		-fill [ColorRGB $greyR] \
		-outline [ColorRGB $greyR]
}
#
#*********************************************************************
#  procedure to udpated the grey level for external measurements
#
proc  Next_greyR_ext {change}  {

	global greyR greyR_display
	global info W greyR_offset

	if {$greyR >= 0} {
		set greyR [expr $greyR + $change]
	} else {
		incr greyR
	}

	#adjust last step to help keep max at 255, min at 0
	if {$greyR > 255} {set greyR 255}
	if {$greyR_display > [expr 255 + $greyR_offset]} {set greyR_display [expr 255 + $greyR_offset]}

	# determine the rgb level for the desired gray level step
	ColorRGB $greyR
}
#
#**********************************************************************
#   procedure to set bounding box for a rectangle 
#   in the center of the canvas.
#
proc SetRect {width height rectX rectY}  {
     global bb_llx bb_lly bb_urx bb_ury  

set bb_llx    [expr {$width/2 -$rectX/2}]
set bb_lly    [expr {$height/2 -$rectY/2}]
set bb_urx    [expr {$width/2 +$rectX/2}] 
set bb_ury    [expr {$height/2 +$rectY/2}] 
}

#
#**********************************************************************
#   procedure to begin or cancel data acquisition
#
proc IL_rec {w} {

	global record log LUTmode ILstatus logging

	if {$ILstatus == 0} {
		tk_messageBox -type ok -message \
			"Meter has not been initialized."
		return
	}

	if {$record == 0} {
		set textmsg "Beginning luminance measurement.\n\nPlease check the following:\n\n"
		append textmsg "1 - Assert LINEAR LUT (1786 or 766 Mode)\n"
		append textmsg "    Assert DICOM LUT (256, 52, 18, 16x2 QC Mode)\n\n"
		append textmsg "    External readings require four measurements at 0 (black)\n\n"
		append textmsg "2 - Ambient lighting should be minimized\n\n"
		append textmsg "3 - Turn off screensavers (set to \"None\")\n"
		append textmsg "    Turn off power-saving (set to \"Never\")\n\n"
		append textmsg "Start measurement?"

		;# NOTE: modified version of tk_messageBox
		set answer [tk_messageBox -type yesno -message $textmsg]
		switch -- $answer {
			yes {
				set record 1
				.rec_bar.auto config -text STOP
				IL_auto $w
			}
			no {return}
		}
	} else {
		set answer [tk_messageBox -type yesno -message \
			"Do you wish to cancel the current operation?"]
		switch -- $answer {
			yes {
				set record 0
				set textmsg "Measurement aborted by user."
				puts $textmsg
				if {$logging == 1} {puts $log $textmsg}
			}
			no {return}
		}
	}

	set record 0
	.rec_bar.auto config -text RECORD
	return
}

#
#*********************************************************************
#  Countdown procedure for external measurements
proc countdown {remaining greyR} {
	global extDelay countdone

	.lumMeter.delay configure -text "$remaining sec"
	if {$greyR > 0} {
		.lumMeter.move configure -text "MOVE"
	}
	if {$remaining > 0} {
		after 1000 [list countdown [expr {$remaining - 1}] $greyR]
	} else {
		.lumMeter.delay configure -text "0 sec"
		.lumMeter.move configure -text "HOLD"
		set countdone 1
		return
	}
}
#**********************************************************************
#   procedure to sequence gray values and measure luminance
#
proc IL_auto {w} {

	global ILstatus ILcnt ILavg ILautoNum iLdelay ILdataReady avgN
	global autoPause autoLumVal autoLumRGB ILfilt greyR_init
	global greyR dGrey LUTmode LUTphase lastRGB numPhases phase
	global start info W log outlierTotal lastILavg record error
	global greyR_display LUTphase_display ILlimit_plus ILlimit_minus
	global outlierNum outlierTestCount pause_flag ILtolerance
	global relChange absChange ILavg_display outlierResolve outlierAccept
	global LIB logfile outlierTestCount outlierpause bgClr fgClr msgOther
	global CHRuAvg CHRvAvg autoCHRuVal autoCHRvVal meter greyR_offset
	global extDelay countdone logging

	# set starting flags
	set error 0

	# ...turn off outlier indicator
	.lumMeter.outlier configure -fg $bgClr

	# check mode
	if {$LUTmode != 0} {
		# open phase file for reading
		if {$LUTmode == 1786} {
			set directory [pwd]
			set input $directory
			append input /1786phase.txt
			set dGrey 1
		} elseif {$LUTmode == 766} {
			set directory [pwd]
			set input $directory
			append input /766phase.txt
			set dGrey 1
		} elseif {$LUTmode == 256} {
			set directory [pwd]
			set input $directory
			append input /256phase.txt
			set dGrey 1
		} elseif {$LUTmode == 52} {
			set directory [pwd]
			set input $directory
			append input /256phase.txt
			set dGrey 5
		} elseif {$LUTmode == 18 || $LUTmode == 181} {
			# internal or external 18 point
			set directory [pwd]
			set input $directory
			append input /256phase.txt
			set dGrey 15
		} elseif {$LUTmode == 11} {
			# external 11 point (SMPTE)
			set directory [pwd]
			set input $directory
			append input /256phase.txt
			set dGrey 25.5
		} elseif {$LUTmode == 16} {
			set directory [pwd]
			set input $directory
			append input /16phase.txt
			set dGrey 16
		} elseif {$LUTmode == 1} {
			set reply [tk_messageBox -type yesno -message $msgOther]
			if {$reply == "yes"} {
				set input [tk_getOpenFile -title "Select PHASE file"]
			} else {
				return
			}
			set dGrey 1
		}

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
			if {[eof $filein] == 1} {
				puts stderr "Incorrect number of lines in phase file"
				tk_messageBox -type ok -message \
					"Incorrect number of lines in phase file"
				close $filein
				return
			}
			set phase($i) [gets $filein]
		}

		gets $filein
		if {[eof $filein] != 1} {
			puts stderr "Incorrect number of lines in phase file"
				tk_messageBox -type ok -message \
					"Incorrect number of lines in phase file"
			close $filein
			return
		}

		close $filein
	}

#	...set up the luminance window to the initial gray level
	if {$LUTmode != 11 && $LUTmode != 181} {
		if {$start == 0} {
			Initialize $w
		}
	} else {
		if {$start == 0} {
			# unlike internal meas'ts, start will always be 0 for external meas'ts
			# because there was no initialization of the meas't window
			InitializeExt
		}
	}

		# reconfigure the target region to the initial value
		set greyR $greyR_init
		set greyR_display [format %3i [expr {max($greyR + $greyR_offset,0)}]]
		if {$LUTmode != 11 && $LUTmode != 181} {
			$w.canvas itemconfigure rect_tag \
				-fill [ColorRGB $greyR] \
				-outline [ColorRGB $greyR]
		} else {
			ColorRGB $greyR
		}
		update idletasks


#	... If IL channel has been initialized, sequence the gray
#	    levels and get the average luminance values.
#	    If the IL channel has been initialized, a monitor application
#	    will continuously collect and display averaged values.
#	    ILautoNum is incremented every time the IL1700 monitoring
#	    routine gets a new average value. It is used here as an argument
#	    to vwait as an indication that a new measurement is in.

	# set up log file for output
	if {$logging == 1} {set log [open $logfile w]}

	set textmsg "# Photometer filter log - [clock format [clock seconds] -format "%D %T"]"
	puts $textmsg
	if {$logging == 1} {puts $log $textmsg}

	set textmsg "# Major Minor   ILavg   lastRGB  lastILavg  relChange  absChange"
	puts $textmsg
	if {$logging == 1} {puts $log $textmsg}

	if {$ILstatus != 0} {

		set ILautoNum 0
		set lastILavg 0
		set outlierTestCount 0
		set outlierTotal 0
		set outlierResolve 0
		set outlierAccept 0
		set relChange_display 0
		if {$LUTmode != 0 && $LUTmode != 11 && $LUTmode != 181} {

			while {$greyR < 256} {

				for {set LUTphase 0} {$LUTphase < $numPhases} {incr LUTphase} {

					if {$greyR >= 0} {
						Next_greyR $w +0  ;# do phase increment
						update idletasks
					}

					if {$greyR <= 0 && $LUTphase == 0} {
						# delay to let luminance meter adjust
						set x 0
						# force a delay larger than iLdelay (legacy 1000 ms, reduce to 10 ms for now)
						after 10 {set x 1} 
						vwait x

						# turn filtering function on only during graylevel sequence
						if {$greyR == 0 && $LUTmode != 16 && $LUTmode != 18 && $LUTmode != 52} {
							set ILfilt 1
						}
					}

					set ILcnt [expr 1 - $iLdelay]
					set ILavg 0.0
					set CHRuAvg 0.0
					set CHRvAvg 0.0

					# ----------> MAIN TIMING CONTROL <--------------------
					after 100 ;# allow the display to stabilize at the new level
					iOneCall
					#  The iOneCall procedure calls a single read
					#  from the luminance meter. It will not return
					#  until a valid reading is generated. Within
					#  the iOneCall, iOneRead is called, which passes
					#  the valid reading to the nit procedure. 
					#  The ILautoNum variable is changed in the
					#  nit procedure (lumR-IL.tsp) after the required
					#  delay and averaging of values to get 'ILavg'.
					# ----------> MAIN TIMING CONTROL <--------------------

					# check for errors or cancel
					if {$error != 0 || $record == 0} break

					# update data arrays
					set autoLumVal($ILautoNum) $ILavg
					set autoLumRGB($ILautoNum) $lastRGB
					set ILavg_display [format %7.3f $ILavg]

					# update chrominance arrays
					set autoCHRuVal($ILautoNum) $CHRuAvg
					set autoCHRvVal($ILautoNum) $CHRvAvg

					# update display values
					set greyR_display [format %3i [expr {max($greyR + $greyR_offset,0)}]]
					set LUTphase_display [expr $LUTphase + 1]
					update idletasks

					# check for outlier values
					# if an outlier, go back and try again.
					if {$ILfilt != 0 && [ILoutlierTest] != 0} {
						if {$error != 0} {
							break
						} else {
							# ...turn on outlier indicator
							.lumMeter.outlier configure -fg $fgClr

							# ...delay to let luminance meter adjust
							set x 0
							after $outlierpause {set x 1} ;# force a delay larger than iLdelay
							vwait x

							set ILautoNum [expr $ILautoNum - 1]
							set LUTphase [expr $LUTphase - 1]
						}
					} else {
						# ...turn off outlier indicator
						.lumMeter.outlier configure -fg $bgClr

						# ...keep track of valid measurements
						if {$ILfilt != 0} {
							set lastILavg $ILavg
							set textmsg    "  [format %4i $greyR_display]   $LUTphase_display"
							append textmsg "     [format %7.3f $ILavg]  $lastRGB   [format %7.3f $lastILavg]"
							append textmsg "    [format %1.4f $relChange] [format %1.4f $absChange]"
							puts $textmsg
							if {$logging == 1} {puts $log $textmsg}
						} else {
							set textmsg    "  [format %4i $greyR_display]   $LUTphase_display"
							append textmsg "     [format %7.3f $ILavg]  $lastRGB   [format %7.3f $lastILavg]"
							puts $textmsg
							if {$logging == 1} {puts $log $textmsg}
						}
					}

					# ...measurement complete or color check
					if {$greyR == 255 || $greyR < 0} break
				}
				if {$error != 0 || $record == 0} break

				set LUTphase 0  ;#should change back to 0
	
				;# ... the sequence is stopped here after the
				;#     value at G255 is read
				if {$greyR == 255} break

				Next_greyR $w +$dGrey  ;# only used dGrey when >= 0, otherwise incr by 1.
				update idletasks
			}

			# turn off filtering
			set ILfilt 0

		;# else LUTmode = 11 or 181, set up acquisition for external test patterns
		;# LUTmode = 11 is intended for use with the SMPTE pattern, 181 is for 18 equally spaced gray levels
		;# remove routines to update the test pattern within lumresponse
		} elseif {$LUTmode == 11 || $LUTmode == 181} {

			while {$greyR < 256} {

				for {set LUTphase 0} {$LUTphase < $numPhases} {incr LUTphase} {

					if {$greyR >= 0} {
						Next_greyR_ext +0  ;# do phase increment
						update idletasks
					}

					if {$greyR <= 0 && $LUTphase == 0} {
						# delay to let luminance meter adjust
						set x 0
						# force a delay larger than iLdelay (legacy 1000 ms, reduce to 10 ms for now)
						after 10 {set x 1} 
						vwait x

					}

					set ILcnt [expr 1 - $iLdelay]
					set ILavg 0.0
					set CHRuAvg 0.0
					set CHRvAvg 0.0

					# ----------> MAIN TIMING CONTROL <--------------------
					set countdone 0
					countdown $extDelay $greyR
					vwait countdone
					iOneCall
					#  The iOneCall procedure calls a single read
					#  from the luminance meter. It will not return
					#  until a valid reading is generated. Within
					#  the iOneCall, iOneRead is called, which passes
					#  the valid reading to the nit procedure. 
					#  The ILautoNum variable is changed in the
					#  nit procedure (lumR-IL.tsp) after the required
					#  delay and averaging of values to get 'ILavg'.
					# ----------> MAIN TIMING CONTROL <--------------------

					# check for errors or cancel
					if {$error != 0 || $record == 0} break

					# update data arrays
					set autoLumVal($ILautoNum) $ILavg
					set autoLumRGB($ILautoNum) $lastRGB
					set ILavg_display [format %7.3f $ILavg]

					# update chrominance arrays
					set autoCHRuVal($ILautoNum) $CHRuAvg
					set autoCHRvVal($ILautoNum) $CHRvAvg

					# update display values
					set greyR_display [format %3i [expr {int(max($greyR + $greyR_offset,0))}]]
					set LUTphase_display [expr $LUTphase + 1]
					update idletasks

					# log measurements
					set textmsg    "  [format %4i $greyR_display]   $LUTphase_display"
					append textmsg "     [format %7.3f $ILavg]  $lastRGB   [format %7.3f $lastILavg]"
					puts $textmsg
					if {$logging == 1} {puts $log $textmsg}

					# ...measurement complete or color check
					if {$greyR == 255 || $greyR < 0} break
				}
				if {$error != 0 || $record == 0} break

				set LUTphase 0  ;#should change back to 0
	
				;# ... the sequence is stopped here after the
				;#     value at G255 is read
				if {$greyR == 255} {
					.lumMeter.move configure -text ""
					break
				}

				Next_greyR_ext +$dGrey  ;# only used dGrey when >= 0, otherwise incr by 1.
				update idletasks
			}

			# turn off filtering
			set ILfilt 0

		;# else LUTmode = 0, set demo parameters, no vwait on ILautoNum
		} elseif {$LUTmode == 0} {	
			set avgN 2      ;# slow it up a bit for the demo
			set iLdelay 2
			set dGrey 15    ;# coarsely step through the gray values.
			set numPhases 1
			while {$greyR < 256} {

				set ILavg 0.0
				if {$greyR >= 0.0} {set ILavg $greyR}
				set CHRuAvg 0.3127
				set CHRvAvg 0.3290

				set x 0
				after 1000 {set x 1}	;# inserted delay
				vwait x
				incr ILautoNum
			
				set autoLumVal($ILautoNum) $ILavg
				set autoLumRGB($ILautoNum) $lastRGB
				set ILavg_display [format %7.3f $ILavg]

				set autoCHRuVal($ILautoNum) $CHRuAvg
				set autoCHRvVal($ILautoNum) $CHRvAvg

				# update display values
				set greyR_display [format %3i [expr {max($greyR + $greyR_offset,0)}]]
				update idletasks

				;# ... the sequence is stopped here after the
				;#     value at G255 is read
				if {$greyR == 255 || $record == 0} break

				Next_greyR $w +$dGrey  ;# only used dGrey when >= 0, otherwise incr by 1.
				update idletasks
			}
			set dGrey 1			;# reset parameters
		}

	} else {

		tk_messageBox -type ok -message \
                "ERROR - Photometer needs to be initialized before auto sequence"
		return
	}

	# reconfigure the target region back to 0 gray value
	set greyR 0
	set greyR_display [format %3i [expr {max($greyR + $greyR_offset,0)}]]
	if {$LUTmode != 11 && $LUTmode != 181} {
		$w.canvas itemconfigure rect_tag \
			-fill [ColorRGB $greyR] \
			-outline [ColorRGB $greyR]
	}
	update idletasks

	if {$error != 0} {
		tk_messageBox -type ok -message \
			"ERROR - See log file for details."
		return
	} else {
		puts "Measurement complete."
	}

	# close log file
	if {$logging == 1} {close $log}
	set log 0
	if {$record == 0} return

	set textmsg "Luminance Measurement Complete\n\n"
	append textmsg "Number of outliers = $outlierTotal\n"
	append textmsg "Resolved outliers  = $outlierResolve\n"
	append textmsg "Accepted outliers  = $outlierAccept\n\n"
	append textmsg "SAVE RESULTS BEFORE CHANGING SETTINGS\n\n"
	if {$logging == 1} {append textmsg "Would you like to view the log file?"}

	set ILdataReady 1  ;# set to permit IL_save
	if {$logging == 1} {
		set answer [tk_messageBox -type yesno -message $textmsg]
		if {$answer == "yes"} {
			if {[catch {exec notepad $logfile} fid]} {
				set msg "Error opening logfile with notepad\n$fid"
				tk_messageBox -message $msg -type ok -icon warning -title "WARNING"
			}
		}
	} else {
		tk_messageBox -message $textmsg -type ok
	}
}
#
#*********************************************************************
#  Procedure to initialize the luminance probe
#
proc IL_init {} {

	global ILdataReady ILfilt lastILavg 
	global ILstatus ILval ILavg ILcnt avgN ILautoNum record
	global fgClr meter

	if {$record == 1} {
		tk_messageBox -type ok -message \
			"Data acquisition must be stopped before re-initializing."
		return
	}

	set answer [tk_messageBox -message \
		"Is the $meter Photometer connected and positioned in the black square?" \
		-type yesno -icon question]
		
	if {$answer == "yes"} {
		set ILstatus 1
		set ILval 0.00
		set ILavg 0.00
		set ILcnt    [expr $avgN + 2]     ;#initial value skips averaging section
		set ILautoNum 0                   ;#keeps track of the No. of measures
		
		;#  activate the meter
		if {[initIL] == 0} {
			tk_messageBox -type ok -message \
				"ERROR: Meter did not initialize"
			set ILstatus 0
			return
		}

		# ...configure IL window to "active" color format
		.lumMeter.avg configure -fg $fgClr
		.lumMeter.gmajor configure -fg $fgClr
		.lumMeter.gminor configure -fg $fgClr

	} else {
		return
	}
	
	set ILdataReady 0  ;# block saving until auto measurements are made
	set ILfilt      0  ;# turn data filtering off until needed
	set lastILavg   0
	return
}
#
#**********************************************************************
#  Procedure to save measured luminance data in a file
#
proc IL_save {} {

	global ILstatus ILdataReady lumFilePath LUTmode ILautoNum
	global autoLumVal autoLumRGB gnuplot plotFileName numPhases
	global iLdelay avgN ILlimit_plus ILlimit_minus title DisplayName
	global plotULRname plotdLLname meter
	global autoCHRuVal autoCHRvVal

	if {$ILstatus != 1} {
		tk_messageBox -type ok -message \
		   "ERROR: Photometer I/O channel not initialized, INIT-IL"
		return
	}

	if {$ILdataReady != 1} {
		tk_messageBox -type ok -message \
		   "ERROR: Luminance measurements have not been completed."
		return
	}

	;# NB: This text is included for historical reference. It no longer
	;# applies. A single prompt is now used.
	;# This involves several user responses but provides in sequence;	
	;#    - selection of a workstation directory name (default _TEMP).
	;#    - selection of a display manf_model directory name (default from EDID).
	;#      This is requested in case a repeat is to be saved.
	;#    - confirmation of the file name to use with the results (default from EDID).

	set DisplayNamef [join $DisplayName _]  ;# combines manf & model with underscore

	if {$LUTmode == 256 || $LUTmode == 52 || $LUTmode == 18 || $LUTmode == 16 || $LUTmode == 181 || $LUTmode == 11} {
		set saveFile  cLR_${DisplayNamef}.txt
	} else {
		set saveFile  uLR_${DisplayNamef}.txt
	}
	
	# Correct LUTmode to 18 for the external 18 point measurement to enable processing
	if {$LUTmode == 181} {
		set LUTmodeSave 18
	} else {
		set LUTmodeSave $LUTmode
	}
	
	set types {
	  {{Text Files}    {.txt}   }
	  {{All Files}     {*}      }
	}
	set filename [tk_getSaveFile -filetypes $types              \
	                             -initialdir $lumFilePath       \
	                             -initialfile $saveFile         \
	                             -title "SELECT DATA SAVE DIRECTORY"]

	if {$filename != ""} {

#		... open a file to write the data to
		if { [catch {open $filename {WRONLY CREAT TRUNC}} fid ] } {
			tk_messageBox \
				-type ok \
				-title "Fatal Error" \
				-message "Error opening $filename\n$fid"
			exit 1
		} else {
			set io_file $fid
		}

		puts $io_file "#  $title - [clock format [clock seconds] -format "%D %T"]"
		puts $io_file "#  Display ID: $DisplayName"
		puts $io_file \
			"#  iLdelay=$iLdelay  avgN=$avgN  ILlimit_plus=$ILlimit_plus ILlimit_minus=$ILlimit_minus  Meter=$meter LUTmode=$LUTmodeSave"

#		... output the initial stabilization measurements
		for {set i 1} {$i < 4} {incr i} {
			puts $io_file "#  [format %8.6f $autoLumVal($i)]  $autoLumRGB($i)"
		}
#		... output the grayscale measurements
		set majorPnum 1
		set minorPnum 1
		set dLL(4) 0
		puts $io_file "[format %4i 1]  [format %12.7f $autoLumVal(4)]  $autoLumRGB(4)  [format %3i $majorPnum] $minorPnum  [format %1.4f $dLL(4)]  [format %10.7f $autoCHRuVal(4)]  [format %10.7f $autoCHRvVal(4)]"
		incr minorPnum
		for {set i 5} {$i <= $ILautoNum} {incr i} {
			# ...check phase values
			if {$minorPnum > $numPhases} {
				set minorPnum 1
				incr majorPnum
			}

			set j [expr $i-1]
			set k [expr $i-3]
			set dLL($i) [expr ($autoLumVal($i) - $autoLumVal($j))/(($autoLumVal($i) + $autoLumVal($j))/2.0)]
			puts $io_file "[format %4i $k]  [format %12.7f $autoLumVal($i)]  $autoLumRGB($i)  [format %3i $majorPnum] $minorPnum  [format %1.4f $dLL($i)]  [format %10.7f $autoCHRuVal($i)]  [format %10.7f $autoCHRvVal($i)]"

			# ...increment phase value
			incr minorPnum
		}
#		... flush the io and close the file
		flush $io_file ; close $io_file

#		... option to plot the dL/L data
		if {$LUTmode == 256 || $LUTmode == 52 || $LUTmode == 18 || $LUTmode == 181 || $LUTmode == 11 ||  $LUTmode == 16} {
			set savePlotMsg "Do you wish to analyze the QC (256, 52, 18, 11, or 16x2) saved data?"
		} else {
			set savePlotMsg "Do you wish to see plots of the luminance and dL/L values?"
		}
		set answer [tk_messageBox -message $savePlotMsg \
				-type yesno -icon question]
		if {$answer == "yes"} {
			plotUlr $filename
		}
	}
	return
}
#
#**********************************************************************
# Outlier test procedure. Checks last two values in autoLumVal()

proc ILoutlierTest {} {

	global autoLumVal ILautoNum greyR LUTphase ILavg lastILavg lastRGB
	global greyR_display LUTphase_display error outlierTotal
	global outlierNum outlierTestCount outlierResolve outlierAccept
	global absChange relChange ILlimit_plus ILlimit_minus ILlimit_abs 
	global pause_flag log ILtolerance logging

	# ...Relative change
	if {$greyR == 0 && $LUTphase == 0} {
		# ...Cannot check first palette entry
		set relChange  0
		set absChange  0
		set mabsChange 0
	} else {
		# ...Determine change
		set absChange [expr ($ILavg - $lastILavg)]
		set mabsChange [expr abs($absChange)]
		set relChange [expr $absChange/(($ILavg + $lastILavg)/2.0) ]
	}

	# ...Check for outlier
	if {$mabsChange <= $ILlimit_abs || ($relChange <= $ILlimit_plus && $relChange >= $ILlimit_minus) } {
		# ...NO OUTLIER
		if {$outlierTestCount != 0} {
			incr outlierResolve	;# Count number of resolved outliers
			set outlierTestCount 0	;# Reset outlier count
		}
		return 0
	} else {
		# ...OUTLIER FOUND
		incr outlierTestCount

		# ...output to log file
		if {$outlierTestCount == 1} {
			incr outlierTotal		;# ...update total number of outliers for the measurement
			set textmsg    "  [format %4i $greyR_display]   $LUTphase_display"
			append textmsg "     [format %7.3f $ILavg]  $lastRGB   [format %7.3f $lastILavg]"
			append textmsg "    [format %1.4f $relChange] [format %1.4f $absChange] **"
			puts $textmsg
			if {$logging == 1} {puts $log $textmsg}
		} else {
			set textmsg    "  [format %4i $greyR_display]   $LUTphase_display"
			append textmsg "     [format %7.3f $ILavg]  $lastRGB   [format %7.3f $lastILavg]"
			append textmsg "    [format %1.4f $relChange] [format %1.4f $absChange] *"
			puts $textmsg
			if {$logging == 1} {puts $log $textmsg}
		}

		# Keep track of the number of times the same number
		# comes back for an outlier check.
		# If excessive, pause and ask the user what to do.

		if {$outlierTestCount < $outlierNum} {
			# ...notify calling function
			return 1
		} else {
			# ...outlier limit reached
			set outlierTestCount 0

			# ...final check with tolerance limits
			set tolerance_abs [expr $ILlimit_abs * $ILtolerance]
			set tolerance_plus [expr $ILlimit_plus * $ILtolerance]
			set tolerance_minus [expr $ILlimit_minus * $ILtolerance]

			if {$mabsChange <= $tolerance_abs || ($relChange <= $tolerance_plus && $relChange >= $tolerance_minus) } {
				# ...bypassing the outlier check for this value
				incr outlierAccept	;# Count number of accepted outliers

				set textmsg "WARNING: Too many outliers.  Outlier value accepted by tolerance limit."
				puts $textmsg
				if {$logging == 1} {puts $log $textmsg}
				return 0
			} else {
				# ...pause luminance acquisition
				set pause_flag 1

				# ...ask user whether to accept outlier
				set textmsg    "Persistent outlier detected.\n\nCurrent values:\n"
				append textmsg "  ILavg     = [format %7.3f $ILavg]\n"
				append textmsg "  lastRGB   = $lastRGB\n"
				append textmsg "  lastILavg = [format %7.3f $lastILavg]\n"
				append textmsg "  relChange = [format %1.4f $relChange]\n"
				append textmsg "  absChange = [format %1.4f $absChange]\n\n"
				append textmsg "Do you wish to accept the outlier value?"

				set answer [tk_messageBox -message $textmsg -type yesno -icon question]
				if {$answer == "yes"} {
					# ...bypassing the outlier check for this value
					incr outlierAccept	;# Count number of accepted outliers

					set textmsg "WARNING: Too many outliers.  Outlier value accepted by user."
					puts $textmsg
					if {$logging == 1} {puts $log $textmsg}
					set pause_flag 0
					return 0
				} else {
					# ...aborting the measurement
					set error 1
					set textmsg "ERROR: Too many outliers.  Measurement aborted by user."
					puts $textmsg
					if {$logging == 1} {puts $log $textmsg}
					set pause_flag 0
					return 1
				}
			}
		}
	}
}

#*********************************************************************
#  procedure to get the EDID monitor and serial number for a display
#
proc getEDID {} {
	global EDIDtxt DisplayName displayN binpath

	set Mon_Desc ""
	set 4_Digit_Serial ""
	set Ext_Serial ""

	set 4_serialflag 0
	set use_ext 1
	set ext_serialflag 0
	set mon_descflag 0

	if {[catch {exec [file join $binpath getEDID.exe] $displayN} output]} {
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

	#  set Display ID
	if {$mon_descflag && ($4_serialflag || $ext_serialflag)} {
		if {$use_ext} {
			set temp "$Mon_Desc $Ext_Serial"
		} else {
			set temp "$Mon_Desc $4_Digit_Serial"
		}

		# replace spaces with underscores
		set length [string length $temp]
		for {set i 0} {$i < $length} {incr i} {
			if {[string index $temp $i] == " "} {
				set temp [string replace $temp $i $i _]
			}
		}
		set DisplayName $temp
	}
}

#  END FILE
