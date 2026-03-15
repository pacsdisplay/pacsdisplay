#**********************************************************************
#	... Procedure to make the gnuplot file and execute

proc plotUlr {fileName} {

	global LUTmode gnuplot phase Lamb

	;# if this is the QC 16x2 mode, trap it here and handle with a different procedure
	if {$LUTmode == 16} {
		;# Get the gray offset and difference from the phase file
		set GLlow [lindex $phase(0) 0]
		set GLhi  [lindex $phase(1) 0]
		set dGL      [expr  $GLhi - $GLlow]
		set GLoffset [expr ($GLhi + $GLlow)/2.0]
		evalQClr $fileName $Lamb $GLoffset $dGL
		return
	} elseif {$LUTmode == 11 || $LUTmode == 18 || $LUTmode == 181 || $LUTmode == 52 || $LUTmode == 256} {
		if {$LUTmode == 181} {set LUTmode 18}
		set dGL      [expr  255/($LUTmode - 1)]
		set GLoffset 0
		evalQClr $fileName $Lamb $GLoffset $dGL
		return
	}

	set plotULRname "uLR-PlotULR.png"
	set plotdLLname "uLR-Plot-dL_L.png"
	
	set gnufile [file join [file dirname $fileName] uLR-plot.gpl]
	set plotFID [open $gnufile w]

	puts $plotFID "# ---------- plot all uLRs to screen-----------"
	puts $plotFID "set size ratio 0.7"
	puts $plotFID "set autoscale"
	puts $plotFID "set logscale y"
	puts $plotFID "set xlabel \"Palette Indice\""
	puts $plotFID "set ylabel \"Luminance\""
	puts $plotFID "plot '$fileName' w l notitle"
	puts $plotFID "pause -1"

	puts $plotFID "# ---------- plot dL/L of average -----------"
	puts $plotFID "set size ratio 0.7"
	puts $plotFID "set ylabel \"dL/L\""
	puts $plotFID "set xlabel \"Major Palette Indice\""
	puts $plotFID "plot '$fileName' using 4:(\$5==1 ? \$6 : 1/0) title '1',\\"
	puts $plotFID "     '$fileName' using 4:(\$5==2 ? \$6 : 1/0) title '2',\\"
	puts $plotFID "     '$fileName' using 4:(\$5==3 ? \$6 : 1/0) title '3',\\"
	puts $plotFID "     '$fileName' using 4:(\$5==4 ? \$6 : 1/0) title '4',\\"
	puts $plotFID "     '$fileName' using 4:(\$5==5 ? \$6 : 1/0) title '5',\\"
	puts $plotFID "     '$fileName' using 4:(\$5==6 ? \$6 : 1/0) title '6',\\"
	puts $plotFID "     '$fileName' using 4:(\$5==7 ? \$6 : 1/0) title '7'"
	puts $plotFID "pause -1"

	puts $plotFID "# ---------- change to larger png -----------"
	puts $plotFID "set terminal png transparent giant size 1000,700"
	puts $plotFID "set size ratio 0.7"

	puts $plotFID "# ---------- plot uLR to png -----------"
	puts $plotFID "set output '$plotULRname'"
	puts $plotFID "set autoscale"
	puts $plotFID "set logscale y"
	puts $plotFID "set xlabel \"Palette Indice\""
	puts $plotFID "set ylabel \"Luminance\""
	puts $plotFID "plot '$fileName' w l notitle"

	puts $plotFID "# ---------- plot dL/L of average -----------"
	puts $plotFID "set output '$plotdLLname' "
	puts $plotFID "set size ratio 0.7"
	puts $plotFID "set ylabel \"dL/L\""
	puts $plotFID "set xlabel \"Major Palette Indice\""
	puts $plotFID "plot '$fileName' using 4:(\$5==1 ? \$6 : 1/0) title '1',\\"
	puts $plotFID "     '$fileName' using 4:(\$5==2 ? \$6 : 1/0) title '2',\\"
	puts $plotFID "     '$fileName' using 4:(\$5==3 ? \$6 : 1/0) title '3',\\"
	puts $plotFID "     '$fileName' using 4:(\$5==4 ? \$6 : 1/0) title '4',\\"
	puts $plotFID "     '$fileName' using 4:(\$5==5 ? \$6 : 1/0) title '5',\\"
	puts $plotFID "     '$fileName' using 4:(\$5==6 ? \$6 : 1/0) title '6',\\"
	puts $plotFID "     '$fileName' using 4:(\$5==7 ? \$6 : 1/0) title '7'"

	close $plotFID
	update idletasks

	;# gnuplot needs to be executed in the directory with the *.gpl file.
	set currentDir [pwd]
	cd [file dirname $fileName]
	exec $gnuplot uLR-plot.gpl
	cd $currentDir
}

#------------------------------------------------------------------------
#	... Procedure to evaluted QC date reported by evalQClr
#
#	    Note: This procedure is called at the end of evalQClr
#	          after the file QC-lr.txt has been closed.
#
#	    Arguments
#	       filename -  full path name of the QC-lr.txt file
#	                   (used for directory path)
#	       dLLplotLabel - label with max error
#	       JNDplotLabel - label with max error
#
#------------------------------------------------------------------------

proc plotQClr {fileName dLLplotLabel JNDplotLabel uvPlotLabel JNDperP} {

	global gnuplot qcTitle

	;# ----------------The remaining script plots the analyzed QC results file ------------

	set plotLUMname "QC-Plot-LUM.png"
	set plotdLLname "QC-Plot-dLL.png"
	set plotJNDname "QC-Plot-JND.png"

	set gnufile [file join [file dirname $fileName] QC-plot.gpl]
	set plotFID [open $gnufile w]

;#------------------------------------------------------------------------------------------------
# For the following, gnuplot commands were copied from a gpl file
# and pasted here. This section does not have procedure indenting.
# The following changes were then made
#   - all of the \ characters in this section were replaced with \\.
#   - all of the " characters in this section were replaced with \".
#   - all of the [ characters in this section were replaced with \[.
#   - all of the ] characters in this section were replaced with \].
#   - The values for $dLLplotLabel, $JNDplotLabel, and $JNDperP were inserted
# This was done so that development could be done in the gpl file.
;#-----------------------------------------------------------------------------------------------

puts $plotFID "# GNUPLOT command file created by lumResponse
set title \"$qcTitle\" offset 0,-1
# ------ start with windows presentations ------
set terminal wxt size 800,600
set linetype 21 lc rgb \"gray50\"  lw 1 pt 9 ps .5
set linetype 22 lc rgb \"black\"   lw 1 pt 7 ps .3
set linetype 23 lc rgb \"#B0B0FF\" lw 4
set linetype 24 lc rgb \"#B0FFB0\" lw 4
set linetype 25 lc rgb \"#FFB0B0\" lw 4
# ---------- plot luminance response -----------
set autoscale
set xrange \[0:255\]
set logscale y
set xlabel \"Gray Level\"
set ylabel \"Luminance\"
set label  $dLLplotLabel at 150,0.7
plot 'QC-lr.txt' using 1:2 w p lt 8 notitle,\\
     'QC-lr.txt' using 1:3 w l lt 2 notitle
pause -1
# ------------ plot dL/L per JND ---------------
set xlabel \"Gray Level\"
set ylabel \"dL/L per JND\"
set label  $dLLplotLabel at 10,0.0025
plot 'QC-lr.txt' using 1:6 w p lt 8 notitle,\\
     'QC-lr.txt' using 1:7 w l lt 2 title 'DICOM GSDF',\\
     'QC-lr.txt' using 1:8 w l lt 0 title 'DICOM +/- 10%',\\
     'QC-lr.txt' using 1:9 w l lt 0 notitle,\\
     'QC-lr.txt' using 1:(\$7*1.20) w l lt 0 title 'DICOM +/- 20%',\\
     'QC-lr.txt' using 1:(\$7*0.80) w l lt 0 notitle
pause -1
# ------------- plot JNDs per GL  --------------
unset logscale y
set yrange \[0:4\]
set xlabel \"Gray Level\"
set ylabel \"JNDs per GL\"
unset label
set label  $JNDplotLabel at 10,3.8
plot 'QC-lr.txt' using 1:4 w p lt 8 notitle ,  [format %5.3f $JNDperP] lt 2, \
     [format %5.3f [expr $JNDperP*1.10]] lt 0 notitle, \
     [format %5.3f [expr $JNDperP*0.90]] lt 0 notitle, \
     [format %5.3f [expr $JNDperP*1.20]] lt 0 notitle, \
     [format %5.3f [expr $JNDperP*0.80]] lt 0 notitle
pause -1
# ----------- change to png -------------
set terminal wxt close
set terminal png font arial 12 size 800,600
unset label
# ---------- plot luminance response -----------
set output 'QC-Plot-LUM.png'
set autoscale
set xrange \[0:255\]
set logscale y
set xlabel \"Gray Level\"
set ylabel \"Luminance\"
plot 'QC-lr.txt' using 1:2 w p lt 12 notitle,\\
     'QC-lr.txt' using 1:3 w l lt 2  notitle
# ------------- plot dL/L per JND -------------
set output 'QC-Plot-dLL.png' 
set xlabel \"Gray Level\"
set ylabel \"dL/L per JND\"
set label  $dLLplotLabel at 10,0.0025
plot 'QC-lr.txt' using 1:6 w p lt 12 notitle,\\
     'QC-lr.txt' using 1:7 w l lt 2 title 'DICOM GSDF',\\
     'QC-lr.txt' using 1:8 w l lt 0 title 'DICOM +/- 10%',\\
     'QC-lr.txt' using 1:9 w l lt 0 notitle,\\
     'QC-lr.txt' using 1:(\$7*1.20) w l lt 0 title 'DICOM +/- 20%',\\
     'QC-lr.txt' using 1:(\$7*0.80) w l lt 0 notitle
# ------------ plot JNDs per GL  --------------
set output 'QC-Plot-JND.png' 
unset logscale y
set yrange \[0:4\]
set xlabel \"Gray Level\"
set ylabel \"JNDs per GL\"
unset label
set label  $JNDplotLabel at 10,3.8
plot 'QC-lr.txt' using 1:4 w p lt 12 notitle ,  [format %5.3f $JNDperP] lt 2,\
     [format %5.3f [expr $JNDperP*1.10]] lt 0 notitle, \
     [format %5.3f [expr $JNDperP*0.90]] lt 0 notitle, \
     [format %5.3f [expr $JNDperP*1.20]] lt 0 notitle, \
     [format %5.3f [expr $JNDperP*0.80]] lt 0 notitle
# ----------------------------------------------
# Do u'v' last because of objects defined
set terminal wxt size 800,800
# --------------- plot u',v'  ------------------
set size ratio -1
set xrange \[0.15:0.25\]
set yrange \[0.42:0.52\]
set xlabel \"u'\"
set ylabel \"v'\"
set label  1 \"D65 (2 degr.) Target\\n0.01 & 0.02 radii\" at 0.152,0.517
set label  2 \"For L > 5.0 cd/m2\"                        at 0.229,0.511
set label  3 $uvPlotLabel          at 0.152,0.423
set object 20 circle at 0.1978,0.4683 size 0.02 behind fc rgb \"gray70\"
set object 10 circle at 0.1978,0.4683 size 0.01 back   fc rgb \"gray70\"
set arrow 1 from 0.1978,0.4383 to 0.1978,0.4983 lt 0  nohead
set arrow 2 from 0.1678,0.4683 to 0.2278,0.4683 lt 0  nohead
set arrow   from 0.1900,0.4206 to 0.2100,0.4206 lt 23 nohead back
set arrow   from 0.1506,0.4700 to 0.1506,0.4900 lt 24 nohead back
set arrow   from 0.2494,0.4600 to 0.2494,0.4800 lt 25 nohead back
# conditionally plot values above 5 cd/m2
plot 'QC-lr.txt' using 11:(\$2>=5.0 && \$1<128 ? \$12 : 1/0) w lp lt 21 title 'GL < 128',\\
     'QC-lr.txt' using 11:(\$2>=5.0 && \$1>=128 ? \$12 : 1/0) w lp lt 22 title 'GL ≥ 128'
pause -1
set terminal wxt close

# ----------- change to png -------------
set terminal png font arial 12 size 800,800
set linetype 21 lc rgb \"gray50\"  lw 1 pt 13 ps 1.2
set linetype 22 lc rgb \"black\"   lw 1 pt  7 ps 1.2

# --------------- plot u',v'  ------------------
set output 'QC-Plot-uv.png'
# conditionally plot values above 5 cd/m2
plot 'QC-lr.txt' using 11:(\$2>=5.0 && \$1<128 ? \$12 : 1/0) w lp lt 21 title 'GL < 128',\\
     'QC-lr.txt' using 11:(\$2>=5.0 && \$1>=128 ? \$12 : 1/0) w lp lt 22 title 'GL ≥ 128'
# ---------------
exit gnuplot
"
#------------------------------------------------------------------------------------------------

	close $plotFID
	update idletasks

	;# gnuplot needs to be executed in the directory with the *.gpl file.
	set currentDir [pwd]
	cd [file dirname $fileName]
	exec $gnuplot $gnufile
	cd $currentDir
}
