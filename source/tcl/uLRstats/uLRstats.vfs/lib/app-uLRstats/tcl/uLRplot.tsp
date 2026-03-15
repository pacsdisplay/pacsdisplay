#**********************************************************************
#	... Procedure to make the gnuplot file and execute

proc plotUlrAvg {} {

	global fileCount fileName gnuplot manf model

	set plotFID [open uLR-plot.gpl w]
	set ulrFile uLR_${manf}_${model}_GENERIC.txt

	puts $plotFID "set size square"

	puts $plotFID "# ----------  Lmax Lmin plot to screen  -----------"
	puts $plotFID "set size ratio 1.0"
	puts $plotFID "set xrange \[0.0:2.0\]"
	puts $plotFID "set yrange \[100:500\]"
	puts $plotFID "set xlabel \"Lmin\""
	puts $plotFID "set ylabel \"Lmax\""
	puts $plotFID "plot 'uLR-LminLmax.txt' notitle"
	puts $plotFID "pause -1"

	puts $plotFID "# ---------- plot all uLRs to screen-----------"
	puts $plotFID "set size ratio 0.7"
	puts $plotFID "set autoscale"
	puts $plotFID "set logscale y"
	puts $plotFID "set xlabel \"Palette Indice\""
	puts $plotFID "set ylabel \"Luminance\""
	puts $plotFID "plot '[file tail $fileName(1)]' w l  title '1',\\"
	for {set i 2} {$i < $fileCount} {incr i} {
		puts $plotFID "     '[file tail $fileName($i)]' w l  title '$i',\\"
	}
	puts $plotFID "     '[file tail $fileName($fileCount)]' w l  title '$fileCount'"
	puts $plotFID "pause -1"

	puts $plotFID "# ---------- plot dL/L of average -----------"
	puts $plotFID "set size ratio 0.7"
	puts $plotFID "set ylabel \"dL/L\""
	puts $plotFID "set xlabel \"Major Palette Indice\""
	puts $plotFID "plot '$ulrFile' using 4:(\$5==1 ? \$6 : 1/0) title '1',\\"
	puts $plotFID "     '$ulrFile' using 4:(\$5==2 ? \$6 : 1/0) title '2',\\"
	puts $plotFID "     '$ulrFile' using 4:(\$5==3 ? \$6 : 1/0) title '3',\\"
	puts $plotFID "     '$ulrFile' using 4:(\$5==4 ? \$6 : 1/0) title '4',\\"
	puts $plotFID "     '$ulrFile' using 4:(\$5==5 ? \$6 : 1/0) title '5',\\"
	puts $plotFID "     '$ulrFile' using 4:(\$5==6 ? \$6 : 1/0) title '6',\\"
	puts $plotFID "     '$ulrFile' using 4:(\$5==7 ? \$6 : 1/0) title '7'"
	puts $plotFID "pause -1"



	puts $plotFID "# ---------- change to png terminal -----------"
	puts $plotFID "set terminal png font arial 12 size 600,600"
	puts $plotFID "set size ratio 1.0"

	puts $plotFID "# ----------  Lmax Lmin plot to png  -----------"
	puts $plotFID "set output 'uLR-Plot_LminLmax.png' "
	puts $plotFID "unset logscale y"
	puts $plotFID "set xrange \[0.0:2.0\]"
	puts $plotFID "set yrange \[100:500\]"
	puts $plotFID "set xlabel \"Lmin\""
	puts $plotFID "set ylabel \"Lmax\""
	puts $plotFID "plot 'uLR-LminLmax.txt' notitle"

	puts $plotFID "# ---------- change to larger png -----------"
	puts $plotFID "set terminal png font arial 12 size 1000,700"
	puts $plotFID "set size ratio 0.7"

	puts $plotFID "# ---------- plot all uLRs to png-----------"
	puts $plotFID "set output 'uLR-PlotULRs.png' "
	puts $plotFID "set autoscale"
	puts $plotFID "set logscale y"
	puts $plotFID "set xlabel \"Palette Indice\""
	puts $plotFID "set ylabel \"Luminance\""
	puts $plotFID "plot '[file tail $fileName(1)]' w l title '1',\\"
	for {set i 2} {$i < $fileCount} {incr i} {
		puts $plotFID "     '[file tail $fileName($i)]' w l title '$i',\\"
	}
	puts $plotFID "     '[file tail $fileName($fileCount)]' w l title '$fileCount'"

	puts $plotFID "# ---------- plot dL/L of average -----------"
	puts $plotFID "set output 'uLR-Plot-dL_L.png' "
	puts $plotFID "set size ratio 0.7"
	puts $plotFID "set ylabel \"dL/L\""
	puts $plotFID "set xlabel \"Major Palette Indice\""
	puts $plotFID "plot '$ulrFile' using 4:(\$5==1 ? \$6 : 1/0) title '1',\\"
	puts $plotFID "     '$ulrFile' using 4:(\$5==2 ? \$6 : 1/0) title '2',\\"
	puts $plotFID "     '$ulrFile' using 4:(\$5==3 ? \$6 : 1/0) title '3',\\"
	puts $plotFID "     '$ulrFile' using 4:(\$5==4 ? \$6 : 1/0) title '4',\\"
	puts $plotFID "     '$ulrFile' using 4:(\$5==5 ? \$6 : 1/0) title '5',\\"
	puts $plotFID "     '$ulrFile' using 4:(\$5==6 ? \$6 : 1/0) title '6',\\"
	puts $plotFID "     '$ulrFile' using 4:(\$5==7 ? \$6 : 1/0) title '7'"

	close $plotFID

	exec $gnuplot uLR-plot.gpl
}

