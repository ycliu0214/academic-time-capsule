#!/usr/bin/env perl

use strict;

my @files = glob "auto_correlation_water_*.txt";


my @avg_result;
foreach my $file (@files) {
    open INF, "$file";
    while(my $line=<INF>){
        my @word=split(/\s+/, $line);
        $avg_result[$word[0]] += $word[1];
    }
    close INF;
}

@avg_result = map {$_ / @files} @avg_result;

for(my $i=0; $i<=$#avg_result; $i++){
    print $i,"\t",$avg_result[$i],"\n";
}
