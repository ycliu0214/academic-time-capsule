#!/usr/bin/perl
#Coding by Yu-Cheng Liu

use strict;

if($#ARGV != 3){
	print "Typing your filename\n";
	print "perl test.pl <your .gjf> <left electrode sulfur index> <right electrode sulfur index> <lattice length>\n";
	exit 1;
}

my $inpfile = $ARGV[0];
my $LS = $ARGV[1] - 1;
my $RS = $ARGV[2] - 1;
my $lattice_length = "$ARGV[3]";

if(open (INF, "$inpfile") != 1){
	print "Can not open ${inpfile}.\n";
	exit 1;
}

my @word;
my $line;
my $i;
my $j;
my $cpu=0;
my $memory=0;
my $charge;
my $spin;


$i=0;
while($line=<INF>){
	@word=split(/\s+/, $line);
	$i++;
	if($word[1] =~ /(^[A-Z])([a-zA-Z]?$)/ && $word[2] =~ /(-?\d+)(\.)(\d+)?$/ && $word[3] =~ /(-?\d+)(\.)(\d+)?$/ && $word[4] =~ /(-?\d+)(\.)(\d+)?$/ && $#word == 4){
		last;
	}
	elsif($line =~ /\%nprocshared/){
		$cpu = $line;
		chomp $cpu;
		$cpu =~ s/\%nprocshared\=//;
	}
	elsif($line =~ /\%mem/){
		$memory = $line;
		chomp $memory;
		$memory =~ s/\%mem\=//;
		$memory = uc($memory);
	}
}

close INF;

$j=$i - 1;

open INF, "$inpfile";

$i=0;
while($line=<INF>){
	@word=split(/\s+/, $line);
	$i++;
	if($i == $j && $word[0] =~ /^-?\d+$/ && $word[1] =~ /^-?\d+$/){
		$charge = $word[0];
		$spin = $word[1];
		last;
	}
}

close INF;

my @atom;
open INF, "$inpfile";
while($line=<INF>){
	@word=split(/\s+/, $line);
	if($word[1] =~ /(^[A-Z])([a-zA-Z]?$)/ && $word[2] =~ /(-?\d+)(\.)(\d+)?$/ && $word[3] =~ /(-?\d+)(\.)(\d+)?$/ && $word[4] =~ /(-?\d+)(\.)(\d+)?$/ && $#word == 4){
		push @atom, $word[1];
	}
}


if($atom[$LS] ne "S" || $atom[$RS] ne "S"){
	open OUTF, ">setting_error.dat";
	print OUTF "wrong number of electrode sulfur\n";
	close OUTF;
}
elsif($lattice_length != 2.83 && $lattice_length != 2.88){
	open OUTF, ">setting_error.dat";
	print OUTF "wrong Au lattice length\n";
	close OUTF;
}
else{
	open OUTF, ">>setting.dat";
	if($cpu =~ /^\d*[1-9]\d*$/){
		print OUTF "$cpu\n";
	}
	else{
		print OUTF "\n";
	}
	if($memory =~ /(^?\d+)(GB)$/ || $memory =~ /(^?\d+)(MB)$/){
		print OUTF "$memory\n";
	}
	else{
		print OUTF "\n";
	}
	print OUTF "$charge\n";
	print OUTF "$spin\n";
	close OUTF;
}

exit;
