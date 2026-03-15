###########################################################################
#                    EDIDprofile-proc.ts                                  #
#  Written by:                                                            #
#    Michael J. Flynn (mikef@rad.hfh.edu)                                 #
#                                                                         #
#  Procedures specific to the EDIDprofile tcl script.                     #
#                                                                         #
#                                                                         #
#       FEB 2026	NB		- Update with common dir for getEDID          #
#                                                                         #
###########################################################################
#
# ----> procedure to get the edid string and put the content in an array
# ----------------------------------------------------------------------
proc dumpEdid {dN} {

	global edid edidError ;# both are 2D arrays of (dN,param)
	global edidParams     ;# list of edid parameters
	global keyValuePairs  ;# mappings from *config.ts
	global binpath        ;# getEDID common dir

	;#------> Run getEdid and get the returned record

	if {[catch {exec [file join $binpath getEDID.exe] $dN} output]} {
		;# $output contains the same information as written to log.
		;# decode output if getEDID.exe failed
		set errorlist [split $output "|\n"] ;# either | or \n to separate exec msg
		set edidError($dN,code)   [lindex $errorlist 0]
		set edidError($dN,string) [lindex $errorlist 1]
		set edid($dN,code) $edidError($dN,code)
		return  ;# NOTE => return error, array elements not build
	} else {
		set linelist [split $output |]
		set edidError($dN,code)   [lindex $linelist 0]
		set edidError($dN,string) "getEDID.exe exited successfully"
		set edid($dN,code) $edidError($dN,code)
	}

	;#------> Decode the record and put in array elements

	;# This list is in the order of the pipe delineated getEDID return string
	set edidParams [ list dNum    manfID  prodID                  \
                            shrtSN  longSN  descrp  week    year    \
                            sizeHcm sizeVcm sizeHmm sizeVmm         \
                            natCol  natRow  curCol  curRow          \
                            ddID ddDesc                             ]
	set lN 0
	foreach P $edidParams {
		set edid($dN,$P) [lindex $linelist [expr $lN+1]]
		incr lN
	}

	;#------> compute the pixel dimensions

	;# assume sizeH is always larger than sizeV.
	if {$edid($dN,curCol) > $edid($dN,curRow) } {
		set edid($dN,psizeH)  [format %6.1f [expr 1000.0*$edid($dN,sizeHmm)/$edid($dN,curCol)]]
		set edid($dN,psizeV)  [format %6.1f [expr 1000.0*$edid($dN,sizeVmm)/$edid($dN,curRow)]]
	} else {
		set edid($dN,psizeH)  [format %6.1f [expr 1000.0*$edid($dN,sizeHmm)/$edid($dN,curRow)]]
		set edid($dN,psizeV)  [format %6.1f [expr 1000.0*$edid($dN,sizeVmm)/$edid($dN,curCol)]]
	}

	;#------> add place holders for grayscale tests
	set edid($dN,order) "?"
	set edid($dN,iQC)   "?"
	set edid($dN,Lmax)  "?"

	;#------> clean up the adapter strings
	set edid($dN,ddID) [string trimleft $edid($dN,ddID) {\\ .}]
	set edid($dN,ddDesc) [string map -nocase $keyValuePairs  $edid($dN,ddDesc)]

	;#------> RETURN the description
	return $edid($dN,descrp)
}

# ----> procedure to initial the descriptor for the edit output table
# ----------------------------------------------------------------------
proc initEdidTable {} {
	global edidTable ;# array elements in the order returned by getEdid.exe
	                 ;# computed values at the end.
	set edidTable(dNum)       "getEdid request number          = "
	set edidTable(manfID)     "Manufacturer ID (hex)           = "
	set edidTable(prodID)     "Product ID (hex)                = "
	set edidTable(shrtSN)     "4-digit S/N                     = "
	set edidTable(longSN)     "Extended S/N                    = "
	set edidTable(descrp)     "Monitor Descriptor              = "
	set edidTable(week)       "Week of manufacture             = "
	set edidTable(year)       "Year of manufacture             = "
	set edidTable(sizeHcm)    "Max. horizontal image size (cm) = "
	set edidTable(sizeVcm)    "Max. vertical   image size (cm) = "
	set edidTable(sizeHmm)  "\nMax. horizontal image size (mm) = "
	set edidTable(sizeVmm)    "Max. vertical   image size (mm) = "
	set edidTable(natCol)   "\nHorizontal array size: Native   = "
	set edidTable(curCol)     "Horizontal array size: Current  = "
	set edidTable(natRow)   "\nVertical array size: Native     = "
	set edidTable(curRow)     "Vertical array size: Current    = "
	set edidTable(ddID)       "Adapter display ID              = "
	set edidTable(ddDesc)     "Adapter string                  = "
	set edidTable(psizeH)   "\nEst. hor. pixel size (microns)  = "
	set edidTable(psizeV)     "Est. ver. pixel size (microns)  = "
	set edidTable(order)      "Left->Right position (A, B ..)  = "

	return 23
}

# ----> procedure to get registry data with errors caught
# ----------------------------------------------------------------------
proc regGet {keyName valueName} {

	if { [catch {registry get $keyName $valueName} value] } {
		return "na"
	} else {
		return $value
	}
}