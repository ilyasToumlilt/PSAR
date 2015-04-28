#! /bin/bash

[ -z "$1" ] && {
    echo "Usage: $0 <pid>"
    exit 1
}

pid=$1
stop=0
count=0
ncpu=$(nproc)

while [ $count -eq 0 ]
do
    for i in $(seq 0 $ncpu)
    do
	usage[$i]=0
    done;
    ps -p $pid -L -o tid,psr,pcpu | {
	read tid psr cpu
	while read tid psr cpu
	do
	    count=$count+1
	    usage[$psr]=cpu
	done;
    }
    count=${PIPESTATUS[0]}
    [ $count -eq 1 ] || echo ${usage[@]:1:$ncpu}    
done;

