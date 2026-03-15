###########################################################################
# lumR-IL.ts - luminance meter initialization and handler procedures.     #
#                                                                         #
#       Procedures to monitor a channel reading luminance                 #
#       data from defined luminance meters.                               #
#                                                                         #
#       Copyright:       Xray Imaging Research Laboratory                 #
#                               Henry Ford Health System                  #
#                               Detroit, MI                               #
#                                                                         #
#                        M.J Flynn,            11/2002                    #
#                        P.M Tchou, M.J Flynn  12/2006                    #
#                        N.B Bevins, M.J Flynn 10/2019                    #
#                                                                         #
#            - Dec 5, 2006 Changed outlier treat to catch negative        #
#                           luminance changes as outliers, regardless of  #
#                           the outlier limit.                            #
#                          Altered the COMnum option to allow any number  #
#                           for the serial port, rather than just 1 or 2. #
#            - Dec 6       Changed the IL1700 window to display the major #
#                           and minor grey level phases starting at 1     #
#                           instead of 0.                                 #
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
#                           accept an outlier it as a measurement value   #
#                           if it persists.                               #
#                          Formatted log file to line up columns.         #
#    Ver. 5g - Dec 14      Fixed an error in the outlier handling.  Will  #
#                           now be handled in lumResponse.tcl rather than #
#                           in tL_IL1700.ts.                              #
#                          Included config option to limit the number of  #
#                           outlier tests.                                #
#                          Included config option for verbose logging.    #
#                           When set, the log file will include all data  #
#                           from the IL1700.  This was previously the     #
#                           default.                                      #
#  Ver. 1.6  - Dec 18      Converted to a set of procedures.              #
#  Ver. 1.8  - Oct 21      Updated to handle multiple meter types.        #
#  Ver. 1.9  - Oct 21      Updated to handle i1Display 2 meter using the  #
#                          Argyll spotread program.                       #
#                          Add a 16 step QC acquisition.                  #
#  Ver. 2.0  - Jan 21,2013 Modified to include chromaticity x,y           #
#  Ver. 2.1  - Oct    2019 Overhaul to exclude Expect dependencies        #
#                          Remove all meters other than i1DisplayPro      #
#                                                                         #
###########################################################################
#
# set up miscellaneous flags and counters
#
set pause_flag 0

###########################################################################
# procedures for channel initialization and event handling
#
proc initIL {} {

	;# This procedure opens the meter and runs a test read.

	global meter
	global IL LUTmode
	global LXFID BINLX numLumLX lxcanInit i1yval

	if {$LUTmode == 0} {
		return ;# don't initialize for demo mode.
	} elseif {$meter == "i1DisplayPro"} {

		;# For these devices, the Argyll spotread.exe program is used to read the meter.
		;# The spotread program gets a value whenever a keyboard entry is made to a prompt.
		;# Using the -O flag returns a single value and exits spotread. Use this to avoid
		;# issues with Expect in W10. 

		set i1yval "n" ;# takes n|l

		if {[iOneInit lum] != 1} {
			tk_messageBox \
				-type ok             \
				-title "FATAL ERROR" \
				-message "Error initializing i1Display"
			return 0
		}

	} else {
		tk_messageBox -type ok -message "Undefined Photometer type in LRconfig.txt"
	}
	return 1
}
#
#**********************************************************************
#	procedure to call for a single read of the i1meter
#
proc iOneCall {} {

global avgN

	for {set i 0} {$i < $avgN} {incr i 1} {
		if {[iOneRead] != 1} {
			set    msg_i1 "Error: i1Display read utility\n"
			tk_messageBox \
				-type ok             \
				-title "FATAL ERROR" \
				-message $msg_i1
			return 0
		}
	}
	return 1
}
###########################################################################
# event handler to process each luminance value from the meter
#
proc nit {lum} {

	global meter LXFID
	global ILval ILavg iLcalVal ILcnt ILwin ILautoNum ILfilt lastRGB log error 
	global avgN greyR LUTphase lastILavg ILlimit_plus ILlimit_minus
	global greyR_display LUTphase_display pause_flag verboselog ILval_display
	global ioneu ionev CHRuAvg CHRvAvg

	;# ----------------------------------------------------------------------------
	;# Meter specific section.

	if {$meter == "i1DisplayPro"} {

		;# The lum variable has the meter luminance reading
		;# Just need to format it here.

		set ILval $lum
		set ILval [expr $ILval * $iLcalVal]
		set ILval_display [format %8.3f $ILval]

		;# chromaticity x,y coordinates
		set CHRu $ioneu
		set CHRv $ionev
	} else {
		tk_messageBox -type ok -message "Undefined Photometer type in LRconfig.txt"
	}

	;# ----------------------------------------------------------------------------
	;# Generic section - applicable to all meter models.

	# The 'pause_flag' provides a mechanism to let the meter keep delivering
	# values without the application doing anything with them.
	if {$pause_flag != 0} {
		return
	}

	if {$verboselog == 1 && $log != 0} {
		puts $log "[format %4i $greyR_display]   $LUTphase_display      [format %7.3f $ILval]  $lastRGB  [format %7.3f $lastILavg] -IL1700"
	}

	;#	process averages if avgN indicates so and if the count
	;#	indicates that a request has been made.
	
	if {$avgN >= 1} {
	    if {$ILcnt <= $avgN} {

		;# ... from 1 to avgN accumulate values
		if {$ILcnt >= 1 && $ILcnt <= $avgN} {
			set ILavg [expr $ILavg + $ILval]
			set CHRuAvg [expr $CHRuAvg + $CHRu]
			set CHRvAvg [expr $CHRvAvg + $CHRv]
		}

		;# ... for ILcnt of avgN+1 compute the average
		if {$ILcnt == $avgN} {
			set ILavg [expr $ILavg/$avgN]
			set CHRuAvg [expr $CHRuAvg/$avgN]
			set CHRvAvg [expr $CHRvAvg/$avgN]
			set ILautoNum [expr 1 +$ILautoNum]
			# The autosequence procedure has a vwait on autoNum
			# to determine when to increment lum for the next measure.
			# When ILautoNum is changed, the graylevel loop advances
			# and ILcnt is set back to (1 - ILdelay).
		}

		;# ... increment the ILcnt variable. This is set back as noted
		;#	above when ILcnt hits the limit determined by avgN and
		;#	ILautoNum triggers the vwait in the calling routine.
		set ILcnt [expr 1 + $ILcnt]
	    }
	}
	update idletasks
}

proc average {} {

	global ILcnt ILavg CHRuAvg CHRvAvg 
	set ILcnt 1
	set ILavg 0.0
	set CHRuAvg 0.0
	set CHRvAvg 0.0
}

proc quit {com} {

	global ILwin ILstatus iLdelay avgN record

	if {$record == 1} {
		tk_messageBox -type ok -message \
			"Data acquisition must be stopped before closing this window."
		return
	}

	set ILstatus 0
	if {$com != 0} {close $com}
}
#
#########################################################################

