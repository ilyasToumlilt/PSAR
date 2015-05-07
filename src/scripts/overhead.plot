# Make the x axis labels easier to read.
set xtics font "sans,20"
set ytics font "sans,20"
# Select histogram data
set style data histogram
# Give the bars a plain fill pattern, and draw a solid line around them.
set style fill solid border

set lmargin 10

set key spacing 3 font "sans,20"

set style histogram clustered
plot for [COL=2:3] 'overhead.out' using COL:xticlabels(1) title columnheader

set yrange [0:1<*<100]

set terminal png size 1920,1080
set output 'overhead.png'
set border 3

#set title 'Routino MT - CPU usage per core' font "sans,25"
set ylabel 'Overhead (%)' font "sans,25"

replot
