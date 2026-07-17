if(open(SETFILE, "setting/09_setting_file.txt") !=1){
	print "Can not find \"setting/09_setting_file.txt\"";
	exit 1;
}
my $ccThreshold;

while($line=<SETFILE>){
	chomp($line);
	if($line =~ /^>>>/){
		if($line eq ">>>start setting max CC volume"){
			$case = 0;
		}
	}
	elsif($case == 0){
		$ccThreshold = $line;
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


#start makeGridLine
my $minX = 0.5;
my $maxX = $#word + 1.5;
my $itvlX = 1.0;
my $minY = 0.5;
my $maxY = $#word + 1.5;
my $itvlY = 1.0;
my $outFile = "09_gridLine.txt";
my @i;
my $line;
my $itvlX2 = $itvlX * 0.9999;
my $itvlY2 = $itvlY * 0.9999;

if(open(OUTF, "> $outFile") != 1)
{
  print "Can not open $outFile\n";
  exit 1;
}

for($i[0] = $minX, $i[1] = $maxX; $i[0] < $i[1]; $i[0] += $itvlX)
{
  for($i[2] = $minX, $i[3] = $maxX; $i[2] < $i[3]; $i[2] += $itvlX)
  {
    $line = sprintf("%.6f %.6f %d\n", $i[0], $i[2], 0);
    print OUTF "$line";
    $line = sprintf("%.6f %.6f %d\n", $i[0], $i[2] + $itvlY2, 0);
    print OUTF "$line";
  }
  print OUTF "\n";

  $i[4] = $i[0] + $itvlX2;
  for($i[2] = $minX, $i[3] = $maxX; $i[2] < $i[3]; $i[2] += $itvlX)
  {
    $line = sprintf("%.6f %.6f %d\n", $i[4], $i[2], 0);
    print OUTF "$line";
    $line = sprintf("%.6f %.6f %d\n", $i[4], $i[2] + $itvlY2, 0);
    print OUTF "$line";
  }
  print OUTF "\n";
}

close OUTF;

#end makeGridLine

#start getDataArray
my $ccFile = "08_target_maxMatrix_cc.txt";
my $tlFile = "08_target_maxMatrix_timeLag.txt";
#my $ccThreshold = 0.5;
my $outfile = "09_dataArray.txt";
my @line;
my @word1;
my @word2;
my @i;

if(open(INF1, "$ccFile") != 1)
{
  print "Can not open $ccFile\n";
  exit 1;
}

if(open(INF2, "$tlFile") != 1)
{
  print "Can not open $tlFile\n";
  exit 1;
}

if(open(OUTF, "> $outfile") != 1)
{
  print "Can not open $outfile\n";
  exit 1;
}

$line[0] = <INF1>;
$line[1] = <INF2>;
$i[4] = 0;
while($line[0] = <INF1>)
{
  if($line[1] = <INF2>)
  {
    chomp($line[0]);
    chomp($line[1]);
    @word1 = split(/\s+/, $line[0]);
    @word2 = split(/\s+/, $line[1]);
    $i[1] = $#word1 + 1;
    $i[2] = $#word2 + 1;
    if($i[1] != $i[2])
    {
      print "The data number in $ccFile is different with that in $tlFile\n";
      print "$ccFile ($i[1]):\n$line[0]\n";
      print "$tlFile ($i[2]):\n$line[1]\n";
      close INF1;
      close INF2;
      close OUTF;
      exit 1;
    }

    for($i[0] = 0; $i[0] < $i[1]; $i[0]++)
    {
      $i[3] = abs($word1[$i[0]]);
      if($i[3] >= $ccThreshold && $i[4] != $i[0])
      {
        $line[2] = sprintf("%.6f %.6f %.6f\n", $i[0] * 1 + 0.5, $i[4] * 1 + 0.5, $word2[$i[0]]);
        print OUTF "$line[2]";
        $line[2] = sprintf("%.6f %.6f %.6f\n", $i[0] * 1 + 1.4999, $i[4] * 1 + 0.5, $word2[$i[0]]);
        print OUTF "$line[2]";
        print OUTF "\n";
        $line[2] = sprintf("%.6f %.6f %.6f\n", $i[0] * 1 + 0.5, $i[4] * 1 + 1.4999, $word2[$i[0]]);
        print OUTF "$line[2]";
        $line[2] = sprintf("%.6f %.6f %.6f\n", $i[0] * 1 + 1.4999, $i[4] * 1 + 1.4999, $word2[$i[0]]);
        print OUTF "$line[2]";
        print OUTF "\n\n";
      }
    }
  }
  else
  {
    print "The data in $tlFile is less than $ccFile\n";
    print "$ccFile:\n$line[0]\n";
    close INF1;
    close INF2;
    close OUTF;
    exit 1;
  }
  $i[4]++;
}

if($line[1] = <INF2>)
{
  print "The data in $ccFile is less than $tlFile\n";
  print "$tlFile:\n$line[1]\n";
  close INF1;
  close INF2;
  close OUTF;
  exit 1;
}

close INF1;
close INF2;
close OUTF;

#end getDataArray

exit 0;
