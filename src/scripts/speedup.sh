#! /bin/bash

#Path leading to the directory containing the xml files (translations.xml and
#profiles.xml)
XMLDIR=/home/redha/m1/psar/git/PSAR/src/routino-2.7.3/src/xml

#Directory that contains the *.mem files
MEMDIR=/home/redha/m1/psar/france

#File containing the list of waypoints you want to use.
WAYPOINTSFILE="../tourdefrance.wp";

#Path of the non multithreaded router
ROUTERPATH=/home/redha/m1/psar/routino-2.7.3/src/router

#Path of the multithreaded router
MTROUTERPATH=/home/redha/m1/psar/git/PSAR/src/routino-2.7.3/src/router

#Type of transport to use
TRANSPORT="bicycle";

#Output file
OUTPUTFILE="values.out";

#Number of thread for the multithreaded router
NBTHREADS="4";

print_usage () {
    cat <<EOF
Usage : $0 [Options]

Options :
  --xmldir=<dir>        Path to the directory containing the xml files.
                          Default : $XMLDIR
  --memdir=<dir>        Path leading to the *.mem files.
                          Default : $MEMDIR
  --waypoints=<file>    Path of the file containing the waypoints. 
                          Mandatory.
  --router=<file>       Path to the non-multithreaded router
                          Default : $ROUTERPATH
  --mtrouter=<file>     Path to the multithreaded router
                          Default : $MTROUTERPATH
  --transport=<type>    Type of transport to use. Can be foot, horse,
                          wheelchair, bicycle, moped, motorcycle, motorcar.
                          Default : $TRANSPORT
  --output=<file>       Output file.
                          Default : $OUTPUTFILE
  --threads=<number>    Number of threads to use.
                          Default : $NBTHREADS
EOF
}

while [ ! -z "$1" ]
do
    case $1 in 
	--xmldir=*)
	    XMLDIR=${1#--*=};
	    [ -d "$XMLDIR" ] || {
		echo "ERR : $XMLDIR is not a reachable directory";
		exit 1;
	    }
	    shift 1;;
	--memdir=*)
	    MEMDIR=${1#--*=};
	    [ -d "$MEMDIR" ] || {
		echo "ERR : $MEMDIR is not a reachable directory";
		exit 1;
	    }
	    shift 1;;
	--waypoints=*)
	    WAYPOINTSFILE=${1#--*=};
	    [ -f "$WAYPOINTSFILE" ] || {
		echo "ERR : $WAYPOINTSFILE does not exist"
		exit 1;
	    }
	    shift 1;;
	--router=*)
	    ROUTERPATH=${1#--*=};
	    [ -x "$ROUTERPATH" ] || {
		echo "ERR : $ROUTERPATH is not an executable file";
		exit 1;
	    }
	    shift 1;;
	--mtrouter=*)
	    MTROUTERPATH=${1#--*=};
	    [ -x "$MTROUTERPATH" ] || {
		echo "ERR : $MTROUTERPATH is not an executable file";
		exit 1;
	    }
	    shift 1;;
	--transport=*)
	    TRANSPORT=${1#--*=};
	    case "$TRANSPORT" in
		foot|horse|wheelchair|bicycle|moped|motorcycle|motorcar)
		    ;;
		*)
		    echo "ERR : $TRANSPORT is not a valid type of transport"
		    exit 1;;
	    esac
	    shift 1;;
	--output=*)
	    OUTPUTFILE=${1#--*=};
	    shift 1;;
	--threads=*)
	    NBTHREADS=${1#--*=};
	    [[ "$NBTHREADS" =~ ^[0-9]+$ ]] || {
		echo "ERR : $NBTHRADS is not a number";
		exit 1;
	    }
	    shift 1;;
	--help|-h)
	    print_usage;
	    exit 1;;
	--*)
	    echo "ERR : unknown option $1"
	    exit 1;;
	*)
	    echo "Invalid number of arguments"
	    exit 1;;
    esac;
done;


[ -z "$WAYPOINTSFILE" ] && {
    echo "ERR : No waypoints file specified. --waypoints is mandatory."
    exit 1;
}

CMDLINE="$ROUTERPATH --quiet --output-none --transport=$TRANSPORT --dir=$MEMDIR --profiles=$XMLDIR/profiles.xml --translations=$XMLDIR/translations.xml "
MTCMDLINE="$MTROUTERPATH --quiet --output-none --threads=$NBTHREADS --transport=$TRANSPORT --dir=$MEMDIR --profiles=$XMLDIR/profiles.xml --translations=$XMLDIR/translations.xml "

{
    read lat lon 
    CMDLINE="$CMDLINE --lat1=$lat --lon1=$lon"
    MTCMDLINE="$MTCMDLINE --lat1=$lat --lon1=$lon"
    read lat lon 
    CMDLINE="$CMDLINE --lat2=$lat --lon2=$lon"
    MTCMDLINE="$MTCMDLINE --lat2=$lat --lon2=$lon"
    
    index=2;
    total=$(wc -l $WAYPOINTSFILE | cut -f 1 -d " ");
    
    env echo -n "" > $OUTPUTFILE;
    
    while [[ ! -z "$lon" && ! -z "$lat" ]]
    do
	start=$(date +%s%N);
	$CMDLINE >/dev/null &
	./cpusage.sh $! > usage.mono.$index
	end=$(date +%s%N);
	routertime=$(((end-start)/1000000));

	start=$(date +%s%N);
	$MTCMDLINE >/dev/null &
	./cpusage.sh $! > usage.multi.$index
	end=$(date +%s%N);
	mtroutertime=$(((end-start)/1000000));
	
	echo "$index $routertime $mtroutertime">>$OUTPUTFILE;
	env echo -e -n "\b\b\b\b$(((index*100)/total))%";

	index=$((index+1))
	read lat lon 
	CMDLINE="$CMDLINE --lat$index=$lat --lon$index=$lon"
	MTCMDLINE="$MTCMDLINE --lat$index=$lat --lon$index=$lon"
    done;

    echo "";
}< $WAYPOINTSFILE
