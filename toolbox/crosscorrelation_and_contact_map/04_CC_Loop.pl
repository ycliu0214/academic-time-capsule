
#setting
my $CC_name = "source/crossCorrelation.pl";
my $preOut = "04_cc";
my $circular = "n";
#my $timeScale = "0.1";
#

if(open(SETFILE, "setting/04_setting_file.txt") !=1){
	print "Can not find \"setting/04_setting_file.txt\"";
	exit 1;
}
my $timeScale;

while($line=<SETFILE>){
	chomp($line);
	if($line =~ /^>>>/){
		if($line eq ">>>set dcd timeScale"){
			$case = 0;
		}
	}
	elsif($case == 0){
		$timeScale = $line;
	}
}
close SETFILE;

system("ls 03_avgVel_*.txt > 01_tmptmp");

if(open(TEST, "$CC_name") != 1){
  print "Can not find $CC_name\n";
  exit 1;
}
close TEST;

if(open(INF1, "01_tmptmp") != 1){
  print "Can not open 01_tmptmp\n";
  exit 1;
}

while($line=<INF1>){
	chomp($line);
	push @files, "$line";
	$line =~ s/03_avgVel_//g;
	$line =~ s/.txt//g;
	push @newfiles, "$line";
}
close INF1;


if(open(INF2, "$files[0]") !=1){
	print "Can not fine 03_avgVel_*.txt\n";
	exit 1;
}

my $maxDelay = 0;
while($line=<INF2>){
	$maxDelay++;
}
print "The number of frames is $maxDelay\n";
close INF2;

for($i=0; $i<=$#files; $i++){
	for($j=0; $j<=$#files; $j++){
		if($i <= $j){
			print "$newfiles[$i] $newfiles[$j]\n";
			system("perl $CC_name $files[$i] $files[$j] $maxDelay $circular $timeScale ${preOut}_${newfiles[$i]}_${newfiles[$j]}.txt\n");
		}
	}
}

exit;
