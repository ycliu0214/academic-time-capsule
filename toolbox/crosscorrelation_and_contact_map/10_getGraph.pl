if(open(SETFILE, "setting/10_setting_file.txt") !=1){
	print "Can not find \"setting/10_setting_file.txt\"";
	exit 1;
}

my $cbrange;

while($line=<SETFILE>){
	chomp($line);
	if($line =~ /^>>>/){
		if($line eq ">>>start setting color bar range (timeLag range or user\'s definition)"){
			$case = 0;
		}
	}
	elsif($case == 0){
		$cbrange = $line;
	}
}
close SETFILE;


if(open(INF,"08_target_maxMatrix_cc.txt") !=1){
	print "Can not find \"08_target_maxMatrix_cc.txt\"";
	exit 1;
}
readline INF;
$line=<INF>;
@word=split(/\s+/, $line);

my $dataNum = $#word + 1;
my $xrangeMax = $#word + 3;
my $xtics;


if(open(OUTF1,">temporal_file/10_gnuP_01.txt") !=1){
	print "Can not find \"temporal_file/10_gnuP_01.txt\"\n";
	exit 1;
}
print OUTF1 "set pm3d\n";
print OUTF1 "set size square\n";
print OUTF1 "set terminal wxt enhanced\n";
print OUTF1 "set palette rgbformulae 2,2,2\n";
print OUTF1 "set style fill transparent solid 0.50\n";
print OUTF1 "set xrange [-1:${xrangeMax}]\n";
print OUTF1 "set yrange [-1:${xrangeMax}]\n";
print OUTF1 "set cbrange [-${cbrange}:${cbrange}]\n";
print OUTF1 "set xtics font \"Arial, 40\"\n";
print OUTF1 "set ytics font \"Arial, 40\"\n";
print OUTF1 "set cbtics font \"Arial, 46\"\n";
print OUTF1 "set xtics offset 0,-2 (";
for($i=1; $i<=$dataNum; $i=$i+5){
	$j=$i+5;
	if($j<$dataNum){
		print OUTF1 "\"${i}\" ${i}, ";
	}
	else{
		print OUTF1 "\"${i}\" ${i}";
	}
}
print OUTF1 ")\n";
print OUTF1 "set ytics (";
for($i=1; $i<=$dataNum; $i=$i+5){
	$j=$i+5;
	if($j<$dataNum){
		print OUTF1 "\"${i}\" ${i}, ";
	}
	else{
		print OUTF1 "\"${i}\" ${i}";
	}
}
print OUTF1 ")\n";
print OUTF1 "set pm3d map\n";
print OUTF1 "set terminal pngcairo enhanced color truecolor linewidth 3.0 size 2000,2000\n";
print OUTF1 "set output \"10_gnuP_01grid.png\"\n";
print OUTF1 "splot \"09_gridLine.txt\" using 1:2:3 with lines linetype 1 linecolor rgb \"#000000\" title \"\"\n";

close OUTF1;





if(open(OUTF2,">temporal_file/10_gnuP_02.txt") !=1){
	print "Can not find \"temporal_file/10_gnuP_02.txt\"\n";
	exit 1;
}

print OUTF2 "set pm3d\n";
print OUTF2 "set size square\n";
print OUTF2 "set terminal wxt enhanced\n";
print OUTF2 "set palette defined ( 0 0 1 0, 0.3333 0 0 1, 0.498 0.498 0 0.502, 0.499 0 0 0, 0.501 0 0 0, 0.502 0.502 0 0.498, 0.6667 1 0 0, 1 1 0.6471 0 )\n";
print OUTF2 "set ticslevel 0\n";
print OUTF2 "set xrange [-1:${xrangeMax}]\n";
print OUTF2 "set yrange [-1:${xrangeMax}]\n";
print OUTF2 "set cbrange [-${cbrange}:${cbrange}]\n";
print OUTF2 "set xtics font \"Arial, 40\"\n";
print OUTF2 "set ytics font \"Arial, 40\"\n";
print OUTF2 "unset ytics\n";
print OUTF2 "set cbtics font \"Arial, 46\"\n";
print OUTF2 "set xtics offset 0,79 (";
for($i=1; $i<=$dataNum; $i=$i+5){
	$j=$i+5;
	if($j<$dataNum){
		print OUTF2 "\"${i}\" ${i}, ";
	}
	else{
		print OUTF2 "\"${i}\" ${i}";
	}
}
print OUTF2 ")\n";
print OUTF2 "set pm3d map\n";
print OUTF2 "set terminal pngcairo enhanced color transparent truecolor linewidth 3.0 size 2000,2000\n";
print OUTF2 "set output \"10_gnuP_02data.png\"\n";
print OUTF2 "splot \"09_dataArray.txt\" using 1:2:3 with lines linetype 1 linecolor rgb \"#000000\" title \"\"\n";

close OUTF2;


system("/usr/bin/gnuplot temporal_file/10_gnuP_01.txt\n");
system("/usr/bin/gnuplot temporal_file/10_gnuP_02.txt\n");

exit;
