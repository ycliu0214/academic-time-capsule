if(open(INF, "temporal_file/protein_sequence.txt") !=1){
	print "Can not find protein_sequence.txt";
	exit 1;
}

my @data;
while($line=<INF>){
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

my @unitSeg = grep {!$saw{$_}++} @Seg;

#OUTF name
open OUTF,">temporal_file/02_calc_target.txt";

#print segmentNum
my $unitNum = $#unitSeg + 1;
print OUTF "set segmentNum $unitNum\n";

#print atomSelSegment
for($i=0; $i<=$#unitSeg; $i++){
	print OUTF "set atomSelSegment($i) \"${unitSeg[$i]}\"\n";
#	print OUTF "set sep($i)\n";
}

#print sep
for($i=0; $i<=$#unitSeg; $i++){
	my @sepdata = grep {$_ eq "$unitSeg[$i]"} @Seg;
	my $sepNum = $#sepdata + 1;
	print OUTF "set sep($i) $sepNum\n";
}



#print atomSelText
for($i=0; $i<=$#Resi; $i++){
	print OUTF "set atomSelText($i) \"resid $Resi[$i] and noh\"\n";
}

exit;
