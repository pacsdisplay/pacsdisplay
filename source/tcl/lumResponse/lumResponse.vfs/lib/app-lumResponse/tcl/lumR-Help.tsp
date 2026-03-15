#########################################################################
# lumResponse Help support                                              #
#                                                                       #
#       Copyright:       Xray Imaging Research Laboratory               #
#                               Henry Ford Health System                #
#                               Detroit, MI                             #
#                                               DEC 2003 tShow          #
#                                               OCT 2005 penChip        #
#                                               DEC 2006 lumResponse    #
# explanation of entry widget variables is provided by messageboxes     #
# invoked by pressing '?' buttons to the right of the entry.            #
# Text is defined here with text variable names used as indices.        #
#                                                                       #
#########################################################################
#
#*********************************************************************
#  Procedure for displaying help messages specific to an entry when user
#       clicks on the "?" next to the label.
#
proc showHelp {var win} {
   global varDescr
   tk_messageBox \
		-icon info                 \
        -message "$varDescr($var)"     \
        -type ok                       \
		-title "lumResponse Help"  \
		-parent $win
}
#
#*********************************************************************
# Read ICONS to photo objects

#image create photo iconHelp -format bmp \
-file [file join $apps_path tcl help.bmp]

#
#*********************************************************************
# Define variable labels and descriptions
#   For each variable with a help button, two array 
#   elements must be defined
#        varLabel(param)  "short text string used as label"
#        varDflag(param)  "1 if text help available, 0 if not"
#        varDescr(param)  "text paragraphy with help material"
#
# For this application, the varLabel elements
# are defined in lumR-settings.ts.
#
#*********************************************************************
# Define default values for all description variables.
#*********************************************************************

#--------------------------------------------
# Help for window geometry
# Default entry
foreach ID $geomLIST {
	set varDflag($ID) 0
	set varDescr($ID) "No additional help entered for $ID"
}
#--------------------------------------------
# Help for luminance measurements
# Default entry
foreach ID $ilLIST {
	set varDflag($ID) 0
	set varDescr($ID) "No additional help entered for $ID"
}

#*********************************************************************
# Define Help text for specific variables.
#*********************************************************************
#set varDflag(xx) 1
#set varDescr(xx) " "

#--------------------
# GEOM variables
#--------------------

set varDflag(toolOffset) 1
set varDescr(toolOffset) "
  The main test window is positioned with 
  the upper left corner placed X pixels to
  the right and Y pixels down from the upper
  left corner of the primary monitor. The
  offsets must be entered as +X+Y.
  To place the window on a non-primary monitor
  to the left of the primary monitor, the
  values must be entered as -X+Y with the
  window appearing -X pixels from the primary.
  The + or - sign must always appear.

  The default position is +5+5.  "

set varDflag(height) 1
set varDescr(height) "
  DICOM part 14, which was developed in a CRT era,
  specifies a background image on the full screen.
  LCD devices have minimal glare and do not require this.
  pacsDisplay sets the size of the window by default
  to a 250 mm square (defined in LRconfig.txt).
  The number of pixels is computed from the
  pixel pitch which is selected above.
  Changing the pitch will recompute this size.
  Further adjustments in size can be made in this entry."

set varDflag(width) 1
set varDescr(width) $varDescr(height)

set varDflag(rectX) 1
set varDescr(rectX) "
  DICOM part 14, which was developed in a CRT era,
  specifies a with 20% of the full screen area.
  LCD devices have minimal glare and do not require this.
  pacDisplay sets the size of the region with varying gray
  levels to a square size of 100 mm which is somewhat larger
  than that of typical contact photometer
  The number of pixels is computed from the
  pixel pitch which is selected above.
  Changing the pitch will recompute this size.
  Further adjustments in size can be made in this entry."
  
set varDflag(rectY) 1
set varDescr(rectY) $varDescr(rectX)

#--------------------
# Luminance meter variables
#--------------------

set varDflag(iLcalVal) 1
set varDescr(iLcalVal) "
  In general, the photometer should be calibrated
  to report luminances in cd/m2. This is done
  using a calibration 'FACTOR' selected using
  the 'FACTOR SELECT' feature of the meter.
  The lumResponse software provides a feature
  to apply a multiplicative correction
  to the number reported by the meter.

  This parameter is normally set to 1.00.
  Set differently to adjust cd/m2 values"

set varDflag(iLdelay) 0
set varDescr(iLdelay) "
  When a gray level has been set and a
  new luminance value read, the lumResponse
  software changes the gray value and refreshes
  the screen. The number of subsequent readings
  to be skipped can be set by this parameter.
  This allows the meter to stablize at the new 
  gray level.

  This parameter is typically set to 0. "

set varDflag(avgN) 1
set varDescr(avgN) "
  The reported luminance values can
  have some noise in the value reported.
  The lumResponse software will average N
  values for each luminance value recorded.

  This parameter is typically set to 1
  for maximum recording speed. "


set outLierCommon "
  Occasionally, a monitor may experience a transient
  during refresh. Secondly, the meter may report an
  aberrant value when the luminance range of the meter
  display changes. The lumResponse applies an outlier
  rejection algorithm to reject these
  values and make a new measurement.

"

set varDflag(outlierpause) 1
set varDescr(outlierpause) "$outLierCommon
  outlierpause sets the millisecond delay used
  when lumResponse is trying to resolve a
  detected outlier.

  This parameter is normally set to 1000."

set varDflag(ILlimit_abs) 1
set varDescr(ILlimit_abs) "$outLierCommon
  ILlimit_abs sets a limit on the absolute value of
  the difference between the current measure and the
  prior measure. (See also LRconfig.txt)

  This parameter is typically set to 0.10."

set varDflag(ILlimit_plus) 1
set varDescr(ILlimit_plus) "$outLierCommon
  ILlimit_plus sets a limit on the relative luminance
  change, dL/L, between the current measure and the
  prior measure for positive changes. (See also LRconfig.txt)

  This parameter is typically set to 0.20."

set varDflag(ILlimit_minus) 1
set varDescr(ILlimit_minus) "$outLierCommon
  ILlimit_minus sets a limit on the relative luminance
  change, dL/L, between the current measure and the
  prior measure for negative changes. (See also LRconfig.txt)

  This parameter is typically set to -0.05."

set varDflag(ILtolerance) 1
set varDescr(ILtolerance) "$outLierCommon
  ILtolerance adjusts the outlier limits to
  establish what is acceptable. After a number
  of retries (see outlierNum), the measured value
  is accepted if it is within the ILtolerance times
  the relevelant outlier limits (abs, plus, minus).
  (See also LRconfig.txt)

  This parameter is typically set to 2.00."

set varDflag(outlierNum) 1
set varDescr(outlierNum) "$outLierCommon
  ILtolerance adjusts the outlier limits to
  establish what is acceptable. After a number
  of retries, determined by outlierNum, the measured
  value is accepted if it is within ILtolerance times
  the relevelant outlier limits (abs, plus, minus).
  (See also LRconfig.txt and ILtolerance)

  This parameter is typically set to 5."

set varDflag(verboselog) 1
set varDescr(verboselog) "
  Normally the log records only the accepted 
  luminance value and not values that are 
  reported as a part of delay cycles or
  values that contribute to an average value.
  For diagnostic purposes, this parameter
  can be set to 1 to report all values.

  This parameter is normally set to 0. "

set varDflag(Lamb) 1
set varDescr(Lamb) "
  The ambient luminance is measured using
  a spot photometer when the display is off.
  Room lights should be at their normal
  level and no specular reflections should
  be present. This value is added to the luminance
  values measure for QC analysis with 'QC (16x2)'.

  Lamb is commonly set to 0.10 "

#*********************************************************************
# END DEFINITIONS