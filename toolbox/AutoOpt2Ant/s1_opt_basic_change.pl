#!/usr/bin/perl
#Coding by Yu-Cheng Liu
#If you give b3lyp/sto-3g .gjf and .log files, you will get b3lyp/3-21g .gjf file.
#If you give b3lyp/3-21g .gjf and .log files, you will get b3lyp/6-31g .gjf file.


use strict;

if($#ARGV != 2){
	print "Typing your filename\n";
	print "perl test.pl <initial .gjf> <initial .log> <new .gjf>\n";
	exit 1;
}

my $initial_gjf = $ARGV[0];
my $initial_log = $ARGV[1];
my $new_gjf = $ARGV[2];
my @word;
my $line;
my $i;
my $j;
my $NAtoms;
my $case = 0;
my @coorx;
my @coory;
my @coorz;
if(open (INF, "$initial_log") != 1){
	print "Can not open ${initial_log}.\n";
	exit 1;
}
while($line=<INF>){
	@word=split(/\s+/, $line);
	if($word[1] eq 'NAtoms='){
		$NAtoms = $word[2];
	}
	elsif($word[4] eq 'Coordinates' && $word[5] eq '(Angstroms)' && $#word == 5){
		$case = 1;
		@coorx=();
		@coory=();
		@coorz=();
	}
	elsif($word[1] eq 'Distance' && $word[2] eq 'matrix' && $word[3] eq '(angstroms):'){
		$case = 0;
	}
	elsif($case == 1){
		if($word[4] =~ /^(-?\d+)(\.\d+)/ && $word[5] =~ /^(-?\d+)(\.\d+)/ && $word[6] =~ /^(-?\d+)(\.\d+)/){
			push @coorx, $word[4];
			push @coory, $word[5];
			push @coorz, $word[6];
		}
	}
}
close INF;

if(open (INF, "$initial_gjf") != 1){
	print "Can not open ${initial_gjf}.\n";
	exit 1;
}

if(open (OUTF, ">$new_gjf") !=1){
	print "Can not open ${$new_gjf}.\n";
	exit 1;
}

while($line=<INF>){
	@word=split(/\s+/, $line);
	if($word[0] eq "" && $word[1] =~ /^[A-Z]/ && $word[2] =~ /^(-?\d+)(\.\d+)/ && $word[3] =~ /^(-?\d+)(\.\d+)/ && $word[4] =~ /^(-?\d+)(\.\d+)/ && $i <= $#coorx){
		printf OUTF (" %s\t%.8f\t%.8f\t%.8f\n", $word[1], $coorx[$i], $coory[$i], $coorz[$i]);
		$i++;
	}
	elsif($line =~ /b3lyp\/sto-3g/){
		$line =~ s/b3lyp\/sto-3g/b3lyp\/3-21g/;
		print OUTF "$line";
		next;
	}
	elsif($line =~ /b3lyp\/3-21g/){
		$line =~ s/b3lyp\/3-21g/b3lyp\/6-31g/;
		print OUTF "$line";
		next;
	}
	elsif($line =~ /b3lyp\/6-31g/){
		$line =~ s/maxcycle=1000\)/maxcycle=1000\,verytight\)/;
		print OUTF "$line";
	}
	else{
		print OUTF "$line";
	}
}

close INF;
close OUTF;

exit;
