if(open(INF1, "temporal_file/protein_sequence.txt") !=1){
	print "Can not find \"temporal_file/protein_sequence.txt\"";
	exit 1;
}

if(open(INF2, "setting/08_setting_file.txt") !=1){
	print "Can not find \"setting/08_setting_file.txt\"";
	exit 1;
}

if(open(INF3, "07_maxMatrix_cc.txt") !=1){
	print "Can not find \"07_maxMatrix_cc.txt\"";
	exit 1;
}

if(open(INF4, "07_maxMatrix_timeLag.txt") !=1){
	print "Can not find \"07_maxMatrix_timeLag.txt\"";
	exit 1;
}

my @data;
while($line=<INF1>){
	@word=split(/\s+/, $line);
	for($i=0; $i<=$#word; $i++){
		push @data, $word[$i];
	}
}

my $xx = ($#data + 1) / 2;

for($i=0; $i<=$#data; $i++){
	if($i < $xx){
		push @Seg, $data[$i];
	}
	else{
		push @Resi, $data[$i];
	}
}

close INF1;


my $case;
my @tarUnitSeg;
my @tarSegNum;
my @tarSeg;
my @tarResi;
my @cc;
my @timeLag;
my @datIndex;
my @ccM;
my @timeM;


while($line=<INF2>){
	chomp($line);
	if($line =~ /^>>>/){
		if($line eq ">>>segment name of user's selection (only protein)"){
			$case = 0;
		}
		elsif($line eq ">>>number of residue for each segment"){
			$case = 1;
		}
		elsif($line eq ">>>resid of user's selection"){
			$case = 2;
		}
		else{
			print "Can not recognize the meaning of \"$line\"\n";
			close INF2;
			exit 1;
		}
	}
	elsif($case == 0){
		push @tarUnitSeg, $line;
	}
	elsif($case == 1){
		push @tarSegNum, $line;
	}
	elsif($case == 2){
		push @tarResi, $line;
	}
}

if($#tarUnitSeg != $#tarSegNum){
	print "number of residue setting error!!\n";
	exit 1;
}

my $tarSegSum;
grep {$tarSegSum += $_} @tarSegNum;
if($tarSegSum != ($#tarResi + 1)){
	print "resid setting error!!\n";
	print "$#tarResi\n";
	exit 1;
}

for($i=0; $i<=$#tarUnitSeg; $i++){
	for($j=0; $j < $tarSegNum[$i]; $j++){
		push @tarSeg, $tarUnitSeg[$i];
	}
}

close INF2;

readline INF3;
my $i;
while($line=<INF3>){
	@word=split(/\s+/, $line);
	for($j=0; $j<=$#word; $j++){
		$cc[$i][$j] = $word[$j];
	}
	$i++;
}


readline INF4;
my $i;
while($line=<INF4>){
	@word=split(/\s+/, $line);
	for($j=0; $j<=$#word; $j++){
		$timeLag[$i][$j] = $word[$j];
	}
	$i++;
}


for($i=0; $i<=$#Seg; $i++){
	for($j=0; $j<=$#tarSeg; $j++){
		if(($Seg[$i] eq "$tarSeg[$j]") && ($Resi[$i] == $tarResi[$j])){
			push @datIndex, $i;
		}
	}
}


open OUTF1,">08_target_maxMatrix_cc.txt";
print OUTF1 "\n";
open OUTF2,">08_target_maxMatrix_timeLag.txt";
print OUTF2 "\n";

for($i=0; $i<=$#Seg; $i++){
	for($j=0; $j<=$#datIndex; $j++){
		if($i == $datIndex[$j]){
			for($k=0; $k<=$#Seg; $k++){
				for($l=0; $l<=$#datIndex; $l++){
					if($k == $datIndex[$l]){
						$ccM = sprintf("%.6f", $cc[$i][$k]);
						$timeM = sprintf("%.6f", $timeLag[$i][$k]);
						print OUTF1 "$ccM ";
						print OUTF2 "$timeM ";
					}
				}
			}
			print OUTF1 "\n";
			print OUTF2 "\n";
		}
	}
}


close OUTF1;
close OUTF2;

exit;
