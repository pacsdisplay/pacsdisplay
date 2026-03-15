#------------------------------------------------------------------------
#	... Procedure to evaluate the QC 16x2 data
#	    in relation to the DICOM GSDF
#
#	    Note: The data is specifically assumed to be acquired
#	          with gray values (P values) ranging from 0 to 255
#	          (i.e. R=G=B). The data file reports three Lmin
#	          values in the header, followed by 16 value pairs,
#	          and ending with one Lmax value. The value pairs
#	          are obtained with low and high gray levels
#	          defined in the phase file and increments of 16.
#	            For dGL=6 P;
#	              i     Plow    Phi
#	              1       5     11
#	              2      21     27
#	              3      37     43
#	              .       .      .
#	              .       .      .
#	             16     245    251
#	          That is the values start with low and high values
#	          of 5 and 11 and increase by 16 for each i step.
#	          For dP = 6 and the above phase values (5 & 11),
#	          the mean P value for each measure
#	          of luminance change is 8, 14, 30, 46 ....
#	          The value of dGl is passed as an arguement and must
#	          be consistent with the 16phase.txt configuration file.
#
#	    QC 16x2 mode is tested at the beginning of the plotULr procedure.
#	    If true; the phase file is read, the gray levels set,
#	    and interpretation sent to this procedure with
#	        Arguements:
#	            fileName - luminance response data filename           
#	            Lamb     - Lamb from photometer parameters
#	            GLoffset - gray level offset from phase file
#	            dGL      - gray level change between paired measures.
#
#	...	Beginning with version 5C, the process has been expanded to
#		include both the 18- and 52-point measurements.
#		The qcLUT variable is determined from the last line of the 
#		input file header. 
#------------------------------------------------------------------------

proc evalQClr {fileName Lamb GLoffset dGL} {
	global qcTitle htmlCont aratio dllplot qctmlFile logoFile

	;#----------------------------------------------------------
	;# define the reference u',v' white point (D65)

	set xD65  0.31271 ;# 2 degree observer
	set yD65  0.32902 ;# 2 degree observer
	set upD65 0.19783 ;# 2 degree observer
	set vpD65 0.46833 ;# 2 degree observer
	set D65label "          D65(2°) u',v' =[format %7.4f $upD65],[format %7.4f $vpD65]"

	;#----------------------------------------------------------
	;# open and read the QC luminance response data

	set inFID [open $fileName r]
	set outFID [open [file join [file dirname $fileName] QC-lr.txt] w]

	;# read the first three ID lines
	set line [gets $inFID]
	set lrVers [lindex $line 3]
	set lrDate [lindex $line 5]
	set lrTime [lindex $line 6]
	puts $outFID "$line, QC analysis"

	set line [gets $inFID]
	set lrID [lindex $line 3]
	puts $outFID $line

	;# read the LUT type from the cLR (52, 18, 16 [16x2], etc.)
	;# if the type is missing (for old cLR, make it 16)
	set line [gets $inFID]
	if {[string first LUTmode $line] != -1} {
		set qcLUT [string range [lindex $line end] 8 end]
	} else {
		set qcLUT 16
	}

	set qcTitle "$lrID , $lrDate"

	;# Get Lmin from the first three readings.
	;# The averaging is handled below depending on the
	;# QC type. 
	;# The 16x2 readings have three Lmin readings, followed
	;# by the paired readings. The other QC types have 
	;# three Lmin readings, then one more Lmin reading at 
	;# the beginning of the lum sequence. The fourth
	;# reading is added in the section below.
	set Lmin [lindex [gets $inFID] 1]
	set Lmin [expr $Lmin + [lindex [gets $inFID] 1]]
	set Lmin [expr $Lmin + [lindex [gets $inFID] 1]]
		
	if	{$qcLUT == 16} {
		;# finish the Lmin averaging routines
		;# add in Lamb now, as well
		set Lmin  [expr $Lmin/3 + $Lamb]
		
		;# get the 16 dL/L & x,y color results from paired readings
		for {set i 1} {$i <= 16} {incr i} {

			set line  [gets $inFID]
			set Llow  [lindex $line 1]
			set uplow  [lindex $line 6]
			set vplow  [lindex $line 7]

			set line  [gets $inFID]
			set Lhi   [lindex $line 1]
			set uphi   [lindex $line 6]
			set vphi   [lindex $line 7]

			;# adjust luminance readings for Lamb
			set Llow [expr $Llow + $Lamb]
			set Lhi  [expr $Lhi  + $Lamb]

			set L($i)	[expr ($Llow + $Lhi)/2.0]
			set up($i)	[expr ($uplow + $uphi)/2.0]
			set vp($i)	[expr ($vplow + $vphi)/2.0]

			set dLL($i) [expr ($Lhi - $Llow) / $L($i) ] ;# dL/L for dGL
			set JNDlow [LUMtoJND $Llow]
			set JNDhi  [LUMtoJND $Lhi ]
			set dJND   [expr $JNDhi - $JNDlow]
			set dJNDperGL($i)     [expr $dJND / $dGL]
		}
		
		;# get Lmax & up,vp from the last reading
		;# incorpate Lamb 
		set line  [gets $inFID]
		set Lmax  [lindex $line 1]
		set Lmax  [expr $Lmax + $Lamb]
		set upmax  [lindex $line 6]
		set vpmax  [lindex $line 7]
		
	} else {
		;# process the luminances from the other (non-16x2) QC routines	
		
		;# collect the luminance readings
		for {set i 1} {$i <= $qcLUT} {incr i} {
			set line  [gets $inFID]
			if {$i == 1} {
				
				;# get another Lmin and incorporate with the Lamb variable
				;# make the first element of the luminance list L $Lmin
				set Lmin [expr $Lmin + [lindex $line 1]]
				set Lmin [expr $Lmin/4 + $Lamb]
				set L($i) $Lmin
				
			} elseif {$i == $qcLUT} {
				
				;# collect the Lmax reading
				set Lmax  [lindex $line 1]
				;# adjust luminance readings for Lamb
				set Lmax [expr $Lmax + $Lamb]
				set L($i) $Lmax
				
			} else {
				
				;# collect the non min/max luminance readings
				set Lmid  [lindex $line 1]
				
				;# adjust luminance readings for Lamb
				set L($i) [expr $Lmid + $Lamb]
			}
  
			;# fill the u',v' results list
			set up($i)	[lindex $line 6]
			set vp($i)	[lindex $line 7]
			
			;# convert the luminance to JND for each measured luminance
			set JNDm($i) [LUMtoJND $L($i)]
			
			;# calculate dL/L and dJND/GL for all luminances after Lmin
			if {$i > 1} {
				set dLL($i) [expr 2*($L($i) - $L([expr $i - 1])) / ($L($i) + $L([expr $i - 1])) ] 
				set dJND   [expr $JNDm($i) - $JNDm([expr $i - 1])]
				set dJNDperGL($i)     [expr $dJND / $dGL]
			}
		}
	}

	close $inFID

	;#----------------------------------------------------------
	;# get total JND range.

	set Jhi     [LUMtoJND $Lmax] 
	set Jlow    [LUMtoJND $Lmin]
	set JNDperP [expr ( $Jhi - $Jlow )/255.0]

	;#----------------------------------------------------------
	;# Now get the values that depend on P values scaled to JND values
	;# For non-16x2 QC, the Pval step size is just dGL. For the 16x2, it's
	;# 16. Use a variable for the loop.
	if {$qcLUT == 16} {
		set Pstep 16
	} else {
		set Pstep $dGL
	}

	if {$qcLUT == 16} {
		for {set i 1} {$i <= $qcLUT} {incr i} {
			set Pval($i)          [expr $GLoffset + ($i - 1.0)*$Pstep]
			set JND($i)           [expr $Jlow + $Pval($i)*$JNDperP]
			set Lgsdf($i)         [JNDtoLUM $JND($i)]
			set dLLPerJND($i)     [expr $dLL($i) / ($dGL*$JNDperP)]

			;# deduce the DICOM expected result
			set dLLdcm($i)        [expr ( [JNDtoLUM [expr $JND($i) + 0.5]] - [JNDtoLUM [expr $JND($i) - 0.5]] ) / [JNDtoLUM $JND($i)] ]
			set dLLdcmPlus10($i)  [expr $dLLdcm($i) * 1.1]
			set dLLdcmMinus10($i) [expr $dLLdcm($i) * 0.9]
		}
	} else {

		for {set i 1} {$i <= $qcLUT} {incr i} {
			set Pval($i)          [expr $GLoffset + ($i - 1.0)*$Pstep]
			set JND($i)           [expr $Jlow + $Pval($i)*$JNDperP]
			set Lgsdf($i)         [JNDtoLUM $JND($i)]
			
			# The non-16x2 data doesn't populate dLL(1), so it needs to be skipped
			if {$i != 1} {
				set dLLPerJND($i)     [expr $dLL($i) / ($dGL*$JNDperP)]

				;# deduce the DICOM expected result
				set dLLdcm($i)        [expr (2*($Lgsdf($i) - $Lgsdf([expr $i - 1]))/($Lgsdf($i) + $Lgsdf([expr $i - 1]))) / ($dGL * $JNDperP)]
				set dLLdcmPlus10($i)  [expr $dLLdcm($i) * 1.1]
				set dLLdcmMinus10($i) [expr $dLLdcm($i) * 0.9]
			}
		}
	}

	;#----------------------------------------------------------
	;# And for the plots, get the dicom dLL at Lmin and Lmax

	set dLLdcm(lmin)        [expr ( [JNDtoLUM [expr $Jlow + 0.5]] - [JNDtoLUM [expr $Jlow - 0.5]] ) / [JNDtoLUM $Jlow] ]
	set dLLdcmPlus10(lmin)  [expr $dLLdcm(lmin) * 1.1]
	set dLLdcmMinus10(lmin) [expr $dLLdcm(lmin) * 0.9]
	set dLLdcm(lmax)        [expr ( [JNDtoLUM [expr $Jhi + 0.5]] - [JNDtoLUM [expr $Jhi - 0.5]] ) / [JNDtoLUM $Jhi] ]
	set dLLdcmPlus10(lmax)  [expr $dLLdcm(lmax) * 1.1]
	set dLLdcmMinus10(lmax) [expr $dLLdcm(lmax) * 0.9]

	;#----------------------------------------------------------
	;# compute the maximum error values

	set JNDperGLrelErrMax  0.0
	set dLLperJNDrelErrMax 0.0
	set uvErrMax5          0.0
	for {set i 1} {$i <= $qcLUT} {incr i} {
		
		;# exclude i=1 for the non-16x2 routines (Lmin) from error analysis
		if {$i == 1 && $qcLUT != 16} {
		 ;# do nothing
		} else {
			set JNDperGLrelErr($i) [expr ($dJNDperGL($i) - $JNDperP)/$JNDperP]
			set absErr [expr abs( $JNDperGLrelErr($i) )]
			if {$absErr > $JNDperGLrelErrMax } {
				set JNDperGLrelErrMax $absErr
				set iJNDerrMax $i
			}

			set dLLrelErr($i) [expr ( $dLLPerJND($i) - $dLLdcm($i) ) / $dLLdcm($i) ]
			set absErr [expr abs( $dLLrelErr($i) )]
			if {$absErr > $dLLperJNDrelErrMax  } {
				set dLLperJNDrelErrMax $absErr
				set idLLerrMax $i
			}
		}
		set uvErr($i) [expr sqrt( ($upD65 - $up($i))**2 + ($vpD65 - $vp($i))**2 ) ]
		if {$L($i) >= 5.0 && $uvErr($i) >= $uvErrMax5} {
			set uvErrMax5 $uvErr($i)
			set iuvErrMax5 $i
		}
	}
	set JNDperGLrelErrMax   $JNDperGLrelErr($iJNDerrMax)
	set dLLperJNDrelErrMax  $dLLrelErr($idLLerrMax) 

	;# for the 16x2 routine, determine the uvErr for the max reading
	;# this is unnecessary for the non-16x2 routines
	if {$qcLUT == 16} {
		set uvErrmax [expr sqrt( ($upD65 - $upmax)**2 + ($vpD65 - $vpmax)**2 ) ]
	}

	;#----------------------------------------------------------
	;# header report: Lmax, Lmin, luminance ratio, ambient ratio

	puts $outFID "#"
	puts $outFID "# Lamb  = [format %7.2f $Lamb]  (Value entered)"
	puts $outFID "# L'max = [format %7.2f $Lmax]"
	puts $outFID "# L'min = [format %7.2f $Lmin]"
	puts $outFID "# LR    =  [expr round($Lmax/$Lmin)]"
	puts $outFID "# AR    = [format %7.2f [expr $Lamb/($Lmin-$Lamb)]]"
	puts $outFID "#"
	puts $outFID "#    Note1 - dL measures from a $dGL gray level change."
	puts $outFID "#    Note2 - Gray levels (GL) from 0 to 255 (256 levels total)."
	if {$qcLUT == 16} {
		puts $outFID "#    Note3 - Tabulated GL is the midpoint between two GLs."
	}
	puts $outFID "#"
	puts $outFID "# JND per Gray Level, Mean value         = [format %6.3f $JNDperP]"
	puts $outFID "# JND per Gray Level, Max relative error = [format %6.3f $JNDperGLrelErrMax]"
	puts $outFID "# dL/L per JND, Max relative error       = [format %6.3f $dLLperJNDrelErrMax]"
	puts $outFID "# (u',v') Max error for L >= 5.0         = [format %6.4f $uvErrMax5]        $D65label"
	puts $outFID "#"

	;#----------------------------------------------------------
	;# report columnar results

	puts $outFID "# GL    L'avg    Lgsdf  dJND/GL   relErr (dL/L)/JND  DCM    DCM+10%  DCM-10%   relErr   u'       v'       uvErr"

	set GL [format %5.1f 0.0]
	;# Print the Lmin line. For the 16x2 routine, include the dLL values. Exclude these for
	;# non-16x2 routines. Include the u',v' readings for Lmin for the non-16x2 readings. 
	if {$qcLUT == 16} {
		puts -nonewline $outFID "$GL [format %7.2f $Lmin]  [format %7.2f $Lmin]    -        -        -      "
		puts -nonewline $outFID "[format %7.4f $dLLdcm(lmin)]  [format %7.4f $dLLdcmPlus10(lmin)]  [format %7.4f $dLLdcmMinus10(lmin)]    -"
		puts            $outFID "       -        -        -"
	} else {
		puts -nonewline $outFID "$GL [format %7.2f $Lmin]  [format %7.2f $Lmin]    -        -        -      "
		;# include the dLLdcm at Lmin
#		puts -nonewline $outFID "[format %7.4f $dLLdcm(lmin)]  [format %7.4f $dLLdcmPlus10(lmin)]  [format %7.4f $dLLdcmMinus10(lmin)]    -     "
		#; exclude the dLLdcm at Lmin
		puts -nonewline $outFID "  -        -        -        -     "
		puts            $outFID "[format %7.4f $up(1)]  [format %7.4f $vp(1)]  [format %7.4f $uvErr(1)]"
	}

	set GL [format %5.1f $GLoffset]
	for {set i 1} {$i <= $qcLUT} {incr i} {
		
		;# skip i == 1 for the non-16x2 routines (Lmin)
		if {$i == 1 && $qcLUT != 16} {
		 ;# do nothing
		} else {
		puts -nonewline $outFID "$GL [format %7.2f $L($i)]  [format %7.2f $Lgsdf($i)]  [format %6.3f $dJNDperGL($i)]"
		puts -nonewline $outFID "   [format %6.3f $JNDperGLrelErr($i)]   [format %7.4f $dLLPerJND($i)]  [format %7.4f $dLLdcm($i)]"
		puts -nonewline $outFID "  [format %7.4f $dLLdcmPlus10($i)]  [format %7.4f $dLLdcmMinus10($i)]  [format %6.3f $dLLrelErr($i)]"
		puts            $outFID "  [format %7.4f $up($i)]  [format %7.4f $vp($i)]  [format %7.4f $uvErr($i)]"
		}

		set GL  [format %5.1f [expr $GL + $Pstep]]
	}

	;# For the 16x2 routine, print the Lmax line. This is handled in the for loop 
	;# above for the non-16x2 routines.
	if {$qcLUT == 16} {
		set GL [format %5.1f 255.0]
		puts -nonewline $outFID "$GL [format %7.2f $Lmax]  [format %7.2f $Lmax]    -        -        -      "
		puts -nonewline $outFID "[format %7.4f $dLLdcm(lmax)]  [format %7.4f $dLLdcmPlus10(lmax)]  [format %7.4f $dLLdcmMinus10(lmax)]    -"
		puts            $outFID "     [format %7.4f $upmax]  [format %7.4f $vpmax]  [format %7.4f $uvErrmax]"
	}

	close $outFID

	;#----------------------------------------------------------
	;# prepare the plot labels and call the plot procedure

	set dLLplotLabel   "\"Max Relative Error = [format %5.3f $dLLperJNDrelErrMax] at i=$idLLerrMax \\n \
            L'max = [format %7.2f $Lmax] \\n \
            L'min = [format %7.2f $Lmin] \\n \
            LR    = [format %7.2f [expr round($Lmax/$Lmin)]] \\n \
			AR    = [format %7.2f [expr round($Lamb/($Lmin-$Lamb))]]\""

	set JNDplotLabel   "\"Max Relative Error = [format %5.3f $JNDperGLrelErrMax]  at i=$iJNDerrMax\""

	set uvPlotLabel    "\"Max (u',v') Error = [format %6.4f $uvErrMax5] at i=$iuvErrMax5\""

	plotQClr $fileName $dLLplotLabel $JNDplotLabel $uvPlotLabel $JNDperP
	
	;#----------------------------------------------------------
	;# put qc results and plots into an html document
	;# using the qcHTML.tml template
		
	set htmlinFID [open $qctmlFile r]
	set htmlCont [read $htmlinFID]
	close $htmlinFID
	set htmloutFID [open [file join [file dirname $fileName] $lrID.html] w]
	
	# Convert plots/images to base64 and put into html

	set pngList {QC-Plot-dLL QC-Plot-JND QC-Plot-LUM QC-Plot-uv}

	foreach img $pngList {
		set fid [open [file join [file dirname $fileName] ${img}.png] r]
		fconfigure $fid -translation binary
		set raw [read $fid]
		close $fid
		set ${img}_raw [base64::encode $raw]
	}	
	# Top left logo	
	set fid [open $logoFile r]
	fconfigure $fid -translation binary
	set raw [read $fid]
	close $fid
	set pdQC-logo_raw [base64::encode $raw]
	
	# Create formatted versions of the values. 
	set lpmax    [format %.2f $Lmax]
	set lpmin    [format %.2f $Lmin]
	set lamb     [format %.2f $Lamb]
	set lratio   [expr round($Lmax/$Lmin)]
	set totalJND [format %.1f [expr ( $Jhi - $Jlow )]]
	set aratio   [format %.2f [expr $Lamb/($Lmin-$Lamb)]]
	set dllerr   [format %.2f [expr 100*abs($dLLperJNDrelErrMax)]]%
	set meanjnd  [format %.3f $JNDperP]
	set jnderr   [format %.2f [expr 100*abs($JNDperGLrelErrMax)]]%
	set colorerr [format %.4f $uvErrMax5]
	
	# Replace the information in the top table
	regsub "##DATE" $htmlCont $lrDate htmlCont
	regsub "##TIME" $htmlCont $lrTime htmlCont
	regsub "##LUMRESVERS" $htmlCont $lrVers htmlCont
	regsub "##DISPLAYID" $htmlCont $lrID htmlCont
	regsub "##LPMAX" $htmlCont $lpmax htmlCont
	regsub "##LPMIN" $htmlCont $lpmin htmlCont
	regsub "##LAMB" $htmlCont $lamb htmlCont
	regsub "##LR" $htmlCont $lratio htmlCont
	regsub "##TOTALJND" $htmlCont $totalJND htmlCont
	regsub "##AR" $htmlCont $aratio htmlCont
	regsub "##DLLMAXERR" $htmlCont $dllerr htmlCont
	regsub "##MEANJND" $htmlCont $meanjnd htmlCont
	regsub "##JNDMAXERR" $htmlCont $jnderr htmlCont
	regsub "##MAXCOLORERR" $htmlCont $colorerr htmlCont
		
	# Use regsub command to replace plot placeholders.
	regsub "##DLLPLOT"   $htmlCont ${QC-Plot-dLL_raw} htmlCont
	regsub "##JNDPLOT"   $htmlCont ${QC-Plot-JND_raw} htmlCont
	regsub "##LUMPLOT"   $htmlCont ${QC-Plot-LUM_raw} htmlCont
	regsub "##COLORPLOT" $htmlCont ${QC-Plot-uv_raw} htmlCont
	regsub "##QCLOGO"    $htmlCont ${pdQC-logo_raw} htmlCont
	
	puts $htmloutFID $htmlCont
	close $htmloutFID
}