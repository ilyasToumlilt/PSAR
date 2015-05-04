# Make the x axis labels easier to read.
set xtics font "sans,20"
set ytics font "sans,20"
# Select histogram data
set style data histogram
# Give the bars a plain fill pattern, and draw a solid line around them.
set style fill solid border

set style histogram clustered
plot for [COL=2:4] 'bandwidth.out' using COL:xticlabels(1) title columnheader

set terminal png size 1920,1080
set output 'bandwidth.png'
set border 3
set grid

#set title 'Routino MT - CPU usage per core' font "sans,25"
#set ylabel 'Bandwidth usage (in MB)' font "sans,25"
set key spacing 2 font "sans,20"

replot
