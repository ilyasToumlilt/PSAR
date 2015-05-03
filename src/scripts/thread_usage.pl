#! /usr/bin/perl

use strict;


my@cpu0;
my@cpu1;
my@cpu2;
my@cpu3;
my$i=0;
my@result;
my%hash;

$/="top -";

open IN, "<$ARGV[0]";

$_=<IN>;

while($_=<IN>){
    #print $i;
    my@lines=split /\n/, $_;
    foreach my$l (@lines) {
	if($l =~ /router/){
	    my@thread=split /[ \t]+/, $l;
	    $hash{$thread[1]}[$i] = $thread[9];
	   # print "$thread[1] $thread[9]";
	}
    }
    $i++;
}

for (my$j=0; $j<$i; $j++){
    print "$j ";
    foreach my$v (keys %hash){
	if(defined $hash{$v}[$j]){
	    print "$hash{$v}[$j] ";
	}
	else{
	    print "0 ";
	}
    }
    print "\n";
}

close IN;
