plot 'values.out' using 1:2 with line title 'routino' lt rgb "blue" lw 2
replot 'values.out' using 1:3 with line title 'routino MT' lt rgb "#FF8000" lw 2

set terminal png size 1920,1080
set output 'speedup.png'
set border 3

set xlabel 'Waypoints number' font "sans,23"
set ylabel 'Time (in ms)' font "sans,23" offset 2.5,-2,0
set xtics font "sans,20"
set ytics font "sans,20"
set key font "sans,15"

replot
