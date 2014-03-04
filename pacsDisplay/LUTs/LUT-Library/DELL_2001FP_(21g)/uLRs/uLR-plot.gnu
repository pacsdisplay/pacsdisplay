set size square
# ----------  color plot to screen  -----------
set size ratio 1.0
set xrange [0.25:0.50]
set yrange [0.05:0.20]
set xlabel "red/green luminance ratio"
set ylabel "blue/green luminance ratio"
plot 'uLR-colorLum.txt' notitle
pause -1
# ---------- plot all uLRs to screen-----------
set size ratio 0.7
set autoscale
set logscale y
set xlabel "Palette Indice"
set ylabel "Luminance"
plot 'uLR_DELL_2001FP_C064657T2NUL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T2NVL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T2P0L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T2P3L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T2P8L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T2P9L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T2PAL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T2PCL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T36JL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T36NL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T36WL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T370L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T371L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T375L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T377L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T379L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T37CL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T37DL.txt' w l notitle
pause -1
# ---------- plot dL/L of average -----------
set size ratio 0.7
set ylabel "dL/L"
set xlabel "Major Palette Indice"
plot 'uLR-average.txt' using 4:($5==1 ? $6 : 1/0) title '1',\
     'uLR-average.txt' using 4:($5==2 ? $6 : 1/0) title '2',\
     'uLR-average.txt' using 4:($5==3 ? $6 : 1/0) title '3',\
     'uLR-average.txt' using 4:($5==4 ? $6 : 1/0) title '4',\
     'uLR-average.txt' using 4:($5==5 ? $6 : 1/0) title '5',\
     'uLR-average.txt' using 4:($5==6 ? $6 : 1/0) title '6',\
     'uLR-average.txt' using 4:($5==7 ? $6 : 1/0) title '7'
pause -1
# ---------- change to png terminal -----------
set terminal png transparent giant size 600,600 \
    xffffff x000000 x000000 x000000 x000000 x000000 x000000 \
            x000000 x000000 x000000 x000000 x000000 x000000 \
            x000000 x000000 x000000 x000000 x000000 x000000 \
            x000000 x000000 x000000 x000000 x000000 x000000 \
            x000000 x000000 x000000 x000000 x000000 x000000 
set size ratio 1.0
# ----------  color plot to png     -----------
set output 'uLR-PlotColor.png' 
unset logscale y
set xrange [0.25:0.40]
set yrange [0.05:0.20]
set xlabel "red/green luminance ratio"
set ylabel "blue/green luminance ratio"
plot 'uLR-colorLum.txt' notitle
# ---------- change to larger png -----------
set terminal png transparent giant size 1000,700 \
    xffffff x000000 x000000 x000000 x000000 x000000 x000000 \
            x000000 x000000 x000000 x000000 x000000 x000000 \
            x000000 x000000 x000000 x000000 x000000 x000000 \
            x000000 x000000 x000000 x000000 x000000 x000000 \
            x000000 x000000 x000000 x000000 x000000 x000000 
set size ratio 0.7
# ---------- plot all uLRs to png-----------
set output 'uLR-PlotULRs.png' 
set autoscale
set logscale y
set xlabel "Palette Indice"
set ylabel "Luminance"
plot 'uLR_DELL_2001FP_C064657T2NUL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T2NVL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T2P0L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T2P3L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T2P8L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T2P9L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T2PAL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T2PCL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T36JL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T36NL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T36WL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T370L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T371L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T375L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T377L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T379L.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T37CL.txt' w l notitle,\
     'uLR_DELL_2001FP_C064657T37DL.txt' w l notitle
# ---------- plot dL/L of average -----------
set output 'uLR-Plot-dL_L.png' 
set size ratio 0.7
set ylabel "dL/L"
set xlabel "Major Palette Indice"
plot 'uLR-average.txt' using 4:($5==1 ? $6 : 1/0) title '1',\
     'uLR-average.txt' using 4:($5==2 ? $6 : 1/0) title '2',\
     'uLR-average.txt' using 4:($5==3 ? $6 : 1/0) title '3',\
     'uLR-average.txt' using 4:($5==4 ? $6 : 1/0) title '4',\
     'uLR-average.txt' using 4:($5==5 ? $6 : 1/0) title '5',\
     'uLR-average.txt' using 4:($5==6 ? $6 : 1/0) title '6',\
     'uLR-average.txt' using 4:($5==7 ? $6 : 1/0) title '7'
