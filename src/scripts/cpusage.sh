#! /bin/bash

#Path to the multithreaded router
ROUTER=./router_multi

#Type of transport
TRANSPORT=bicycle

#Number of threads
THREADS=4

#Directory containing the *.mem files
MEMDIR=.

#Path to the profile file
PROFILES=/home/maxime/Bureau/psar/src/routino-2.7.3/src/xml/profiles.xml

#Path to the translation file
TRANSLATIONS=/home/maxime/Bureau/psar/src/routino-2.7.3/src/xml/translations.xml

#Coordinates
COORDS="--lat1=50.275225 --lon1=2.788303 --lat2=49.897684 --lon2=2.294304 --lat3=50.105713 --lon3=1.833776 --lat4=49.507293 --lon4=0.123546 --lat5=49.005850 --lon5=0.166520 --lat6=48.352540 --lon6=-1.194488 --lat7=48.116374 --lon7=-1.677726 --lat8=48.202492 --lon8=-2.988113 --lat9=47.658356 --lon9=-2.761005 --lat10=47.837615 --lon10=-2.641045 --lat11=43.294549 --lon11=-0.370265 --lat12=43.232417 --lon12=0.077903 --lat13=42.977432 --lon13=-0.745326 --lat14=43.294299 --lon14=-0.370093 --lat15=42.890072 --lon15=-0.115152 --lat16=43.125720 --lon16=0.385237 --lat17=42.729286 --lon17=1.687378 --lat18=43.461782 --lon18=1.331508 --lat19=44.349249 --lon19=2.575691 --lat20=44.517784 --lon20=3.499265 --lat21=44.933500 --lon21=4.888060 --lat22=45.040834 --lon22=5.050856 --lat23=44.556680 --lon23=6.093170 --lat24=44.092068 --lon24=6.245705 --lat25=44.370070 --lon25=6.603937 --lat26=45.275614 --lon26=6.346081 --lat27=45.255176 --lon27=6.257293 --lat28=45.187805 --lon28=6.652442 --lat29=45.092654 --lon29=6.069295 --lat30=48.820824 --lon30=2.211443 --lat31=50.275225 --lon31=2.788303 --lat32=48.820824 --lon32=2.211443 --lat33=50.275225 --lon33=2.788303 --lat34=48.820824 --lon34=2.211443 --lat35=50.275225 --lon35=2.788303 --lat36=48.820824 --lon36=2.211443 --lat37=50.275225 --lon37=2.788303"

#Output file
OUTPUTFILE='cpuvals.out'

#Final command line
CMDLINE="$ROUTER --quiet --output-none --transport=$TRANSPORT --threads=$THREADS --dir=$MEMDIR --profiles=$PROFILES --translations=$TRANSLATIONS $COORDS"

$CMDLINE &
routerpid=$!
top -b -d 1 -H -p $routerpid > $OUTPUTFILE &
toppid=$!
wait $routerpid
kill -9 $toppid

./parse_cpusage.pl $OUTPUTFILE > cpusage.out
./thread_usage.pl $OUTPUTFILE > threadusage.out

