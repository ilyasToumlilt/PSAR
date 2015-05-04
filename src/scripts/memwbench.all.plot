# Make the x axis labels easier to read.
set xtics rotate out
# Select histogram data
set style data histogram
# Give the bars a plain fill pattern, and draw a solid line around them.
set style fill solid border

set style histogram clustered
plot for [COL=2:4] 'memwbench.all.out' using COL:xticlabels(1) title columnheader

set yrange [0:1 < *]

set terminal png size 1920,1080
set output 'memwbench.all.png'
set border 3

#set title 'Routino MT - CPU usage per core' font "sans,25"
set ylabel 'Bytes written' font "sans,15"

replot
