plot 'values.out' using 1:2 with linespoint title 'routino' lt rgb "blue" lw 2
replot 'values.out' using 1:3 with linespoint title 'routino MT' lt rgb "red" lw 2

set terminal png size 1920,1080
set output 'speedup.png'
set border 3

set lmargin 10
set bmargin 5

set key spacing 3 font "sans,20"

set xlabel 'Waypoints number' font "sans,25" offset 0,-1,0
set ylabel 'Execution time (in s)' font "sans,25"
set xtics font "sans,20"
set ytics font "sans,20"
set key font "sans,20" spacing 3

replot
