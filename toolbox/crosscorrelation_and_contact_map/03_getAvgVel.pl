system("ls 02_CM_*.txt > 01_tmptmp");
open INF, "01_tmptmp";
while($line=<INF>){
	chomp($line);
	push @files, "$line";
	$line =~ s/02_CM_//g;
	$line =~ s/.txt//g;
	push @newfiles, "$line";
}

close INF;

system("rm 01_tmptmp");

for($i=0; $i<=$#files; $i++){
	open INF,"$files[$i]";
	open OUTF, ">03_avgVel_$newfiles[$i].txt";
	print "$newfiles[$i]\n";
	my @data;
	my @xcor;
	my @ycor;
	my @zcor;
	while($line=<INF>){
		@word=split(/\s+/, $line);
		push @xcor, $word[1];
		push @ycor, $word[2];
		push @zcor, $word[3];
	}
	for($k=1; $k<=$#xcor; $k++){
		$l = $k - 1;
		$calc = ((($xcor[$k] - $xcor[$l])**2)+(($ycor[$k] - $ycor[$l])**2)+(($zcor[$k] - $zcor[$l])**2))**0.5;
		push @data, $calc;
	}
#	for($j=0; $j<=$#data; $j++){
#		$min = $j - 50;
#		$max = $j + 50;
#		my $volu;
#		if($min < 0){
#			$min = 0;
#		}
#		if($max > $#data){
#			$max = $#data;
#		}
#		for($k = $min; $k <= $max; $k++){
#			$volu = $volu + $data[$k];
#		}
#		$tot = $max - $min + 1;
#		$avolu = $volu / $tot;
#		$data[$j] = $avolu;
#	}
	for($j=0; $j<=$#data; $j++){
		print OUTF "$data[$j]\n";
	}
	close OUTF;
	close INF;
}


exit;

