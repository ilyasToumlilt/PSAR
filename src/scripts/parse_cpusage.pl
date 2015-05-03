#! /usr/bin/perl -l

use strict;


my@cpu0;
my@cpu1;
my@cpu2;
my@cpu3;
my$i=0;

open IN, "<$ARGV[0]";

while($_=<IN>){

if(/\%Cpu0.*?(\d+\.\d) id.*/) {
#	print "$i: cpu0=$1";
	$cpu0[$i]=100-$1;
	if($cpu0[$i]==""){
		$cpu0[$i]="0.0";
	}
}
elsif(/\%Cpu1.*?(\d+\.\d) id.*/) {
	#print "$i: cpu1=$1";
        $cpu1[$i]=100-$1;
        if($cpu1[$i] eq ""){
                $cpu1[$i]="0.0";  
        }
#	print $1;
}
elsif(/\%Cpu2.*?(\d+\.\d) id.*/) {
        #print "$i: cpu2=$1";
        $cpu2[$i]=100-$1;
        if($cpu2[$i]==""){
                $cpu2[$i]="0.0";  
        }
#	print $1;
}
elsif(/\%Cpu3.*?(\d+\.\d) id.*/) {
 #       print "$i: cpu3=$1";
        $cpu3[$i]=100-$1;
        if($cpu3[$i]==""){
                $cpu3[$i]="0.0";  
        }
#	print $1;
        print "$i $cpu0[$i] $cpu1[$i] $cpu2[$i] $cpu3[$i]";
	$i++;
}
}

close IN;

