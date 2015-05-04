#! /bin/bash

######################################################
#                   ENVIRONMENT                      #
######################################################

TIMEOUTPUT=/home/root/timebench.out
OVEROUTPUT=/home/root/overhead.out
MEMROUTPUT=/home/root/memrbench.out
MEMWOUTPUT=/home/root/memwbench.out
FULLTIMEOUTPUT=/home/root/timebench.all.out
FULLOVEROUTPUT=/home/root/overhead.all.out
FULLMEMROUTPUT=/home/root/memrbench.all.out
FULLMEMWOUTPUT=/home/root/memwbench.all.out
RTPATH=/home/root/realtime_tasks
STPATH=/home/root/routino/src/router
MTPATH=/home/root/routinoMT/src/router
MAP=/home/root/france
XML=/home/root/routinoMT/src/xml
COORD="--lat1=50.275225 --lon1=2.788303  --lat2=49.897684 --lon2=2.294304\
 --lat3=50.105713 --lon3=1.833776 --lat4=49.507293 --lon4=0.123546\
 --lat5=49.005850 --lon5=0.166520 --lat6=48.352540 --lon6=-1.194488\
 --lat7=48.116374 --lon7=-1.677726 --lat8=48.202492 --lon8=-2.988113\
 --lat9=47.658356 --lon9=-2.761005 --lat10=47.837615 --lon10=-2.641045\
 --lat11=43.294549 --lon11=-0.370265 --lat12=43.232417 --lon12=0.077903\
 --lat13=42.977432 --lon13=-0.745326 --lat14=43.294299 --lon14=-0.370093\
 --lat15=42.890072 --lon15=-0.115152 --lat16=43.125720 --lon16=0.385237\
 --lat17=42.729286 --lon17=1.687378 --lat18=43.461782 --lon18=1.331508\
 --lat19=44.349249 --lon19=2.575691 --lat20=44.517784 --lon20=3.499265\
 --lat21=44.933500 --lon21=4.888060 --lat22=45.040834 --lon22=5.050856\
 --lat23=44.556680 --lon23=6.093170 --lat24=44.092068 --lon24=6.245705\
 --lat25=44.370070 --lon25=6.603937 --lat26=45.275614 --lon26=6.346081\
 --lat27=45.255176 --lon27=6.257293 --lat28=45.187805 --lon28=6.652442\
 --lat29=45.092654 --lon29=6.069295 --lat30=48.820824 --lon30=2.211443\
 --lat31=50.275225 --lon31=2.788303 --lat32=48.820824 --lon32=2.211443\
 --lat33=50.275225 --lon33=2.788303 --lat34=48.820824 --lon34=2.211443\
 --lat35=50.275225 --lon35=2.788303 --lat36=48.820824 --lon36=2.211443\
 --lat37=50.275225 --lon37=2.788303"
TRANSPORT=bicycle

######################################################
#                 ENVIRONMENT END                    #
######################################################




# We declare the results arrays
declare -a alonet
declare -a aloner
declare -a alonew
declare -a monot
declare -a monor
declare -a monow
declare -a multit
declare -a multir
declare -a multiw

# parse_json <file> <testnb>
function parse_json {
    file=$1      # get filename as parameter
    testnb=$2    # get test number

    timevalues=$(grep "time" $file | cut -f6 -d' ' | cut -f1 -d'}')
    memrvalues=$(grep "core\" : 0" $file | cut -d' ' -f5)
    memwvalues=$(grep "core\" : 0" $file | cut -d' ' -f7)
    i=0
    duration=0
    memw=0
    memr=0
    for v in $timevalues
    do
	duration=$((duration+v))
	i=$((i+1))
    done;
    for v in $memrvalues
    do
	memr=$((memr+v))
    done;
    for v in $memwvalues
    do
	memw=$((memw+v))
    done;
    duration=$((duration/i))
    memr=$((memr/i))
    memw=$((memw/i))
    echo "$duration $memr $memw"
}

######################################################
#                      SCRIPT                        #
######################################################

cd $RTPATH

# We read the commands that are going to be executed as RT tasks
commands=$(cat run.sh)
readarray cmds < run.sh

# Cleanup json files
rm -f *.json

# Put data in ram to avoid I/Os
mkdir -p /media/tmpfs
mount -t tmpfs -o size=20m tmpfs /media/tmpfs
cp data/* /media/tmpfs/

testnb=0

############################################################
# For each RT app, launch bench                            #
############################################################

for c in "${cmds[@]}"
do
    # if not a command (empty line/comment), next command
    [[ "$c" == "
" || "$c" =~ ^# ]] && continue;

    ############################################################
    # First launch, alone		   		       #
    ############################################################

    echo "Starting ${c%% *} running alone."

    `$c`

    file=$(ls *.json)
    testnames[$testnb]=${file%.json}
    res=$(parse_json $file $testnb)
    read t r w <<< $res
    alonet[$testnb]=$t
    aloner[$testnb]=$r
    alonew[$testnb]=$w

    rm -f *.json
    
    ############################################################
    # Second launch, with 3 single threaded routinos running   #
    ############################################################

    echo "Starting ${c%% *} running with 3 single-threaded Routinos."

    $STPATH --dir=$MAP --profiles=${XML}/profiles.xml\
 --translations=${XML}/translations.xml --transport=$TRANSPORT\
 $COORD --quiet --output-none &
    disown
    pid1=$!
    $STPATH --dir=$MAP --profiles=${XML}/profiles.xml\
 --translations=${XML}/translations.xml --transport=$TRANSPORT\
 $COORD --quiet --output-none --reverse &
    disown
    pid2=$!
    $STPATH --dir=$MAP --profiles=${XML}/profiles.xml\
 --translations=${XML}/translations.xml --transport=$TRANSPORT\
 $COORD --quiet --output-none &
    disown
    pid3=$!
    `$c`
    kill -9 $pid1 $pid2 $pid3

    file=$(ls *.json)
    res=$(parse_json $file $testnb)
    read t r w <<< $res
    monot[$testnb]=$t
    monor[$testnb]=$r
    monow[$testnb]=$w

    rm -f *.json

    #############################################################
    # Third launch, with a multit-threaded routino using 3 cores#
    #############################################################

    echo "Starting ${c%% *} running with a multithreaded Routino\
 (3 threads)."

    $MTPATH --threads=4 --dir=$MAP --profiles=${XML}/profiles.xml\
 --translations=${XML}/translations.xml --transport=$TRANSPORT\
 $COORD --quiet --output-none &
    disown
    pid=$!
    `$c`
    kill -9 $pid

    file=$(ls *.json)
    res=$(parse_json $file $testnb)
    read t r w <<< $res
    multit[$testnb]=$t
    multir[$testnb]=$r
    multiw[$testnb]=$w

    rm -f *.json

    testnb=$((testnb+1))
done;

############################################################
# Bench all apps together as one                           #
############################################################

    ############################################################
    # First launch, alone		   		       #
    ############################################################

    echo "Running all real-time applications alone."

    for c in "${cmds[@]}"
    do
	# if not a command (empty line/comment), next command
	[[ "$c" == "
" || "$c" =~ ^# ]] && continue;
	
	`$c`
    done;

    duration=0
    memr=0
    memw=0
    for file in $(ls *.json)
    do
	d=0
	mr=0
	mw=0
	i=0
	timevalues=$(grep "time" $file | cut -f6 -d' ' | cut -f1 -d'}')
	memrvalues=$(grep "core\" : 0" $file | cut -d' ' -f5)
	memwvalues=$(grep "core\" : 0" $file | cut -d' ' -f7)
	for v in $timevalues
	do
	    d=$((d+v))
	    i=$((i+1))
	done;
	for v in $memrvalues
	do
	    mr=$((mr+v))
	done;
	for v in $memwvalues
	do
	    mw=$((mw+v))
	done;
	duration=$((duration+(d/i)))
	memr=$((memr+(mr/i)))
	memw=$((memw+(mw/i)))
    done;
    alonet[$testnb]=$duration
    aloner[$testnb]=$memr
    alonew[$testnb]=$memw
    
    ############################################################
    # Second launch, with 3 single threaded routinos running   #
    ############################################################

    echo "Running all real-time applications with 3 single-threaded Routinos."

    $STPATH --dir=$MAP --profiles=${XML}/profiles.xml\
 --translations=${XML}/translations.xml --transport=$TRANSPORT\
 $COORD --quiet --output-none &
    disown
    pid1=$!
    $STPATH --dir=$MAP --profiles=${XML}/profiles.xml\
 --translations=${XML}/translations.xml --transport=$TRANSPORT\
 $COORD --quiet --output-none --reverse &
    disown
    pid2=$!
    $STPATH --dir=$MAP --profiles=${XML}/profiles.xml\
 --translations=${XML}/translations.xml --transport=$TRANSPORT\
 $COORD --quiet --output-none &
    disown
    pid3=$!

    for c in "${cmds[@]}"
    do
	# if not a command (empty line/comment), next command
	[[ "$c" == "
" || "$c" =~ ^# ]] && continue;
	`$c`
    done;
    kill -9 $pid1 $pid2 $pid3

    duration=0
    memr=0
    memw=0
    for file in $(ls *.json)
    do
	d=0
	mr=0
	mw=0
	i=0
	timevalues=$(grep "time" $file | cut -f6 -d' ' | cut -f1 -d'}')
	memrvalues=$(grep "core\" : 0" $file | cut -d' ' -f5)
	memwvalues=$(grep "core\" : 0" $file | cut -d' ' -f7)
	for v in $timevalues
	do
	    d=$((d+v))
	    i=$((i+1))
	done;
	for v in $memrvalues
	do
	    mr=$((mr+v))
	done;
	for v in $memwvalues
	do
	    mw=$((mw+v))
	done;
	duration=$((duration+(d/i)))
	memr=$((memr+(mr/i)))
	memw=$((memw+(mw/i)))
    done;
    monot[$testnb]=$duration
    monor[$testnb]=$memr
    monow[$testnb]=$memw

    #############################################################
    # Third launch, with a multit-threaded routino using 3 cores#
    #############################################################

    echo "Running all real-time applications with a multithreaded Routino\
 (3 threads)."

    $MTPATH --threads=4 --dir=$MAP --profiles=${XML}/profiles.xml\
 --translations=${XML}/translations.xml --transport=$TRANSPORT\
 $COORD --quiet --output-none &
    disown
    pid=$!

    for c in "${cmds[@]}"
    do
	# if not a command (empty line/comment), next command
	[[ "$c" == "
" || "$c" =~ ^# ]] && continue;
	`$c`
    done;
    kill -9 $pid

    duration=0
    memr=0
    memw=0
    for file in $(ls *.json)
    do
	d=0
	mr=0
	mw=0
	i=0
	timevalues=$(grep "time" $file | cut -f6 -d' ' | cut -f1 -d'}')
	memrvalues=$(grep "core\" : 0" $file | cut -d' ' -f5)
	memwvalues=$(grep "core\" : 0" $file | cut -d' ' -f7)
	for v in $timevalues
	do
	    d=$((d+v))
	    i=$((i+1))
	done;
	for v in $memrvalues
	do
	    mr=$((mr+v))
	done;
	for v in $memwvalues
	do
	    mw=$((mw+v))
	done;
	duration=$((duration+(d/i)))
	memr=$((memr+(mr/i)))
	memw=$((memw+(mw/i)))
    done;
    multit[$testnb]=$duration
    multir[$testnb]=$memr
    multiw[$testnb]=$memw
 

############################################################
# Fill the output file with timevalues for gnuplot	   #
############################################################

echo "Creating outputs for gnuplot..."

echo "RTtask alone w/3routinos w/routinoMT3" > $TIMEOUTPUT
echo "RTtask w/3routinos w/routinoMT3" > $OVEROUTPUT
echo "RTtask alone w/3routinos w/routinoMT3" > $MEMROUTPUT
echo "RTtask alone w/3routinos w/routinoMT3" > $MEMWOUTPUT

for j in $(seq 0 $((testnb-1)))
do
    echo "${testnames[$j]} ${alonet[$j]} ${monot[$j]} ${multit[$j]}"\
 >> $TIMEOUTPUT
    echo "${testnames[$j]} ${aloner[$j]} ${monor[$j]} ${multir[$j]}"\
 >> $MEMROUTPUT
    echo "${testnames[$j]} ${alonew[$j]} ${monow[$j]} ${multiw[$j]}"\
 >> $MEMWOUTPUT
done;

cat $TIMEOUTPUT | perl -ne 'if($_ !~ /routino/) {@t=split / /, $_; $a=100*(($t[2]/$t[1])-1); $b=100*(($t[3]/$t[1])-1); print "$t[0] $a $b\n";}' >> $OVEROUTPUT

echo "RTtask alone w/3routinos w/routinoMT3" > $FULLTIMEOUTPUT
echo "all ${alonet[$testnb]} ${monot[$testnb]} ${multit[$testnb]}"\
 >> $FULLTIMEOUTPUT

echo "RTtask w/3routinos w/routinoMT3" > $FULLOVEROUTPUT
cat $FULLTIMEOUTPUT | perl -ne 'if($_ !~ /routino/) {@t=split / /, $_; $a=100*(($t[2]/$t[1])-1); $b=100*(($t[3]/$t[1])-1); print "$t[0] $a $b\n";}' >> $FULLOVEROUTPUT

echo "RTtask alone w/3routinos w/routinoMT3" > $FULLMEMROUTPUT
echo "all ${aloner[$testnb]} ${monor[$testnb]} ${multir[$testnb]}"\
 >> $FULLMEMROUTPUT

echo "RTtask alone w/3routinos w/routinoMT3" > $FULLMEMWOUTPUT
echo "all ${alonew[$testnb]} ${monow[$testnb]} ${multiw[$testnb]}"\
 >> $FULLMEMWOUTPUT

