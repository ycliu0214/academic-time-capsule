#setting
my $preOut = "04_cc";
#

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

for($i=0; $i<=$#files; $i++){
	for($j=0; $j<=$#files; $j++){
		if($i > $j){
			print "$newfiles[$i] $newfiles[$j]\n";
			if(open(INF,"${preOut}_${newfiles[$j]}_${newfiles[$i]}.txt") !=1){
				print "Can not open ${preOut}_${newfiles[$j]}_${newfiles[$i]}.txt\n";
				exit 1;
			}
			my @timeLag;
			my @cc;
			while($line=<INF>){
				@word=split(/\s+/, $line);
				push @timeLag, $word[0];
				push @cc, $word[1];
			}
			for($k=0; $k<=$#timeLag; $k++){
				$l = $#timeLag - $k;
				$timeLag2[$l] = $timeLag[$k] * -1;
				$cc2[$l] = $cc[$k];
			}
			open OUTF,">${preOut}_${newfiles[$i]}_${newfiles[$j]}.txt";
			for($k=0; $k<=$#timeLag; $k++){
				$finaldata = sprintf("%.13f %.13f\n", $timeLag2[$k], $cc2[$k]);
				print OUTF "$finaldata";
			}
			close OUTF;
			close INF;
		}
	}
}

exit;
