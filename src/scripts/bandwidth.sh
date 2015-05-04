#! /bin/bash

TIME=timebench.out
MEMR=memrbench.out
MEMW=memwbench.out
OUT=bandwidth.out

declare -a testname
declare -a alonet
declare -a aloner
declare -a alonew
declare -a monot
declare -a monor
declare -a monow
declare -a multit
declare -a multir
declare -a multiw
declare -a alonebw
declare -a monobw
declare -a multibw

echo "start"

i=0
while read name alone mono multi
do
    testname[$i]=$name
    alonet[$i]=$alone
    monot[$i]=$mono
    multit[$i]=$multi
    i=$((i+1))
done < $TIME

echo "memr"

i=0
while read name alone mono multi
do
    aloner[$i]=$alone
    monor[$i]=$mono
    multir[$i]=$multi
    i=$((i+1))
done < $MEMR

echo "memw"

i=0
while read name alone mono multi
do
    alonew[$i]=$alone
    monow[$i]=$mono
    multiw[$i]=$multi
    i=$((i+1))
done < $MEMW

echo "perl"

echo "RTtask alone w/3routinos w/routinoMT3" > $OUT

for j in $(seq 1 $((i-1)))
do
    echo "$j"
    echo "${testname[$j]} ${alonet[$j]} ${aloner[$j]} ${alonew[$j]} ${monot[$j]} ${monor[$j]} ${monow[$j]} ${multit[$j]} ${multir[$j]} ${multiw[$j]}"\
 | perl -ne '@t=split / /, $_;
$a=(($t[2]+$t[3])/1000000)/($t[1]/1000000000);
$b=(($t[5]+$t[6])/1000000)/($t[4]/1000000000);
$c=(($t[8]+$t[9])/1000000)/($t[7]/1000000000);
print "$t[0] $a $b $c\n"' >> $OUT
done 
