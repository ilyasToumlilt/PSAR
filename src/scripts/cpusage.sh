#! /bin/bash

[ -z "$1" ] && {
    echo "Usage: $0 <pid>"
    exit 1
}

pid=$1
stop=0
count=0
ncpu=$(nproc)

for i in $(seq 0 $((ncpu-1)))
do
    totaltime[$i]=0
done;

PROC=$(cat /proc/stat)

for file in $(ls /proc/$pid/task)
do
    task[$cpt]=$(cat /proc/$pid/task/$file/stat)
    cpt=$((cpt+1))
done;

for i in $(seq 0 $((ncpu-1)))
do
    cpu=$(echo "$PROC" | grep cpu$i)
    starttime[$i]=$((`echo ${cpu#cpu$i} | tr ' ' '+'`))
done;

for i in $(seq 0 $((cpt-1)))
do
    utimeb[$i]=$(echo "${task[$i]}" | cut -f14 -d' ')
    stimeb[$i]=$(echo "${task[$i]}" | cut -f15 -d' ')
done;

sleep 1

while [ -f /proc/$pid/stat ]
do
    #STAT=$(cat /proc/$pid/stat)
    PROC=$(cat /proc/stat)
    cpt=0

    for file in $(ls /proc/$pid/task)
    do
	task[$cpt]=$(cat /proc/$pid/task/$file/stat)
	cpt=$((cpt+1))
    done;

   # utime=$(($(echo $STAT | cut -f14 -d' ')-utime))
   # stime=$(($(echo $STAT | cut -f15 -d' ')-stime))
    
    for i in $(seq 0 $((cpt-1)))
    do
	cpuIndex=$(echo "${task[$i]}" | cut -f39 -d' ')
	utimea[$cpuIndex]=$(echo "${task[$i]}" | cut -f14 -d' ')
	stimea[$cpuIndex]=$(echo "${task[$i]}" | cut -f15 -d' ')
    done;

    for i in $(seq 0 $((ncpu-1)))
    do
	cpu=$(echo "$PROC" | grep cpu$i)
	#echo $cpu
	totaltime[$i]=$((`echo ${cpu#cpu$i} | tr ' ' '+'`))
	#echo "cpu$i: ${totaltime[$i]}"
	use[$i]=$(((100*(utimea[$i]+stimea[$i]-utimeb[$i]-stimeb[$i]))/(totaltime[$i]-starttime[$i])))
	starttime[$i]=${totaltime[$i]}
	utimeb[$i]=${utimea[$i]}
	stimeb[$i]=${stimea[$i]}
    done;
    
    echo ${use[@]}
    sleep 1
done;
