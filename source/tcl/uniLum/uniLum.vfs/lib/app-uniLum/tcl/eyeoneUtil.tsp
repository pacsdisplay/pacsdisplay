#########|#########|#########|#########|#########|#########|#########|#########|
#
# i1DOisplay 2/Pro tcl utility procedures (argyll spotread.exe)
#
# The Argyll utility program, spotread.exe, gets a reading from an attached
# photometer and returns the XYZ and Lab results. Running from a command window,
# it has a rather verbose text string with options that is returned for each
# reading. Entering characters at the keyboard either gets another value,
# or quits the routine.
#
# For these routines, the Argyll program is executed interactively using
# the routines in the Expect package. Opening the program with a open pipe
# command would not work. (NB: see release notes below - updated spotread
# allows for single return of a reading with -O flag)
#
# M. Flynn, May 2013
#
# 20130121, M. Flynn
#           Modified read and parse to get Yxy color space variables
# 20131222, M. Flynn
#           Modified for use in luminance or illuminance measures.
#           Presently illuminance is only supported by the i1DisplayPro meter.
#           iOneInit now needs a second arguement:
#                       lum - for the luminance measure as before.
#                       lux - for illuminance, lux.
#           This only need to be in the initiation procedure, iOneInit.
#           If the meter starts successfully, it is set in the srMode variable
#           so that the response can be appropriately parsed in iOneParse.
# 20191004, N. Bevins
#			Modified to remove depedencies on Expect
#				Complete rewrite of spotread interface
#				Relies on newer -O flag in spotread to read a single output
#				and return to an open pipe
#			Read natively in Yuv (instead of Yxy) - use the -u flag in spotread
#			Remove all references to meters other than the i1DisplayPro
# 20191004, N. Bevins
#			Modified spotread call to account for full directory names (spaces possible)
#
#########|#########|#########|#########|#########|#########|#########|#########|

#-------------------------------------------------------------------------------
# Procedure to use the argyll spotread program

proc iOneInit {mode} {

	global ioneInit i1yval srMode srid meterStatus binpath

	;#	launch the application in the requested mode.
	;#	To avoid using expect, return the reading
	;#	after each reading. The spotread program must
	;#	be continuously opened and closed. 

	if {$mode == "lum"} {

		if {[catch {open [list | [file join $binpath spotread.exe] -u -e -y $i1yval -O]} srid]} {
			puts "Error: $srid"
			return 0
		} else {
			puts "pid: $srid"
		}

	} elseif {$mode == "lux"} {

		if {[catch {open [list | [file join $binpath spotread.exe] -u -a -O} srid]} {
			puts "Error: $srid"
			return 0
		} else {
			puts "pid: $srid"
		}

	} else {
		set ioneInit 0
		puts "Error: iOneInit requires a mode of lum or lux"
		return 0
	}

	;#	check the open channel to see that spotread opened correctly
	;#	and returned a reading.

	set status 0
	set srout [read $srid 400]
	if {[string last "Result is" $srout] != 1} {
		set meterStatus 1
	}

	;#	If 'Reading is' was not found return an error.
	;#	Otherwise we are ready to request a fresh reading.
	if {$meterStatus == 1} {
		set ioneInit 1
		puts "Photometer initialized correctly."
		set srMode $mode
		return 1
	} else {
		set ioneInit 0
		puts "Error: Photometer failed to initialize."
		set srMode 0
		return 0
	}
}
#-------------------------------------------------------------------------------
# Procedure to get single reading
# The nit procedure is called and the luminance passed

proc iOneRead {} {

	global ioneInit ioneReading meterStatus srMode srout srid binpath i1yval iOneDone

	if {$srMode == "lum"} {
		set sropt "-e"
	} elseif {$srMode == "lux"} {
		set sropt "-a"
	}
	
	if {[catch {open [list | [file join $binpath spotread.exe] -u $sropt -y $i1yval -O]} srid]} {
		puts "Error: $srid"
		return 0
	} else {
		fconfigure $srid -blocking 0 ;# set the srid to non-blocking to not freeze application
		fileevent $srid readable [iOneCheck]
	}
	return 1
}

#-------------------------------------------------------------------------------
# Procedure to check the iOne USB output
# Updates the srout variable with a valid reading

proc iOneCheck {} {

	global srout srid srtemp iOneDone iOneCover

	set iOneDone 0
	set srtemp [read $srid]

while {$iOneDone != 1} {
	if {[string first XYZ $srtemp] == -1} {
		if {[string first failed $srtemp] != -1 || [string first hid $srtemp] != -1} {
			set KILL [file join {C:\Windows\System32\taskkill.exe}]
			set killid [pid $srid]
			exec $KILL /PID $killid /F
			iOneQuit
			tk_messageBox \
				-type ok             \
				-title "FATAL ERROR" \
				-message "Check ambient light cover position and try again"
			set iOneCover 1
			return
		}
		#puts "Waiting on valid i1Display reading"
		set srtemp [read $srid]
		update
	} else {
		set iOneCover 0
		set srout $srtemp
		nit [iOneParse]
		#puts "Captured valid i1Display reading"
		set iOneDone 1
	}
}
}

#-------------------------------------------------------------------------------
# Procedure to close the iOne USB connection
# Updates the meterStatus status variable

proc iOneQuit {} {
	global meterStatus srid
	set meterStatus 0
}
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Procedure to parse the string seen by expect from spotread
proc iOneParse {} {
	global ioneReading ioneY ioneu ionev ioneLux srout srMode
	set start [string first XYZ $srout]
	if {$start == -1} {
		puts "Error: no XYZ found in ioneReading input string"
		return 0
	}
	set end   [string first  \n $srout $start]
	set end   [expr $end - 1]
	set ioneReading [string range $srout $start $end]
	set ioneY [lindex $ioneReading 5]
	set ioneu [lindex $ioneReading 6]
	set ionev [lindex $ioneReading 7]
	;# puts $ioneReading

	if {$srMode == "lum"} {

		;# return the luminance, cd/m2
		return $ioneY

	} elseif {$srMode == "lux"} {

		;# get lux from the next line and return it.
		set start [string first "Ambient =" $srout]
		set end   [string first  \n $srout $start]
		set end   [expr $end - 1]
		set ioneReading [string range $srout $start $end]
		set ioneLux [lindex $ioneReading 2]
		return $ioneLux

	} else {
		puts "Error: srMode must be lum or lux"
		return 0
	}
}




