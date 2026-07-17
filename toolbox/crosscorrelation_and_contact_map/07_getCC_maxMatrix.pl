

use strict;

my $prefixCC_file = "data/04/04_cc_";
my $outFile = "07_maxMatrix";
my @line;
my @word1;
my @word2;
my @word3;
my $max;
my $maxT;

system "ls ${prefixCC_file}*.txt > 07_tmptmp";

if(open(INF1, "07_tmptmp") != 1)
{
  print "Can not open 07_tmptmp\n";
  exit 1;
}

if(open(OUTF, "> ${outFile}.txt") != 1)
{
  print "Can not open ${outFile}.txt\n";
  exit 1;
}

if(open(OUTFTL, "> ${outFile}_timeLag.txt") != 1)
{
  print "Can not open ${outFile}_timeLag.txt\n";
  exit 1;
}

if(open(OUTFCC, "> ${outFile}_cc.txt") != 1)
{
  print "Can not open ${outFile}_cc.txt\n";
  exit 1;
}

while($line[0] = <INF1>)
{
  chomp($line[0]);

  @word1 = split(/$prefixCC_file/, "$line[0]");
  @word1 = split(/_/, "$word1[1]");
  if($word1[0] ne $word2[0] || $word1[1] ne $word2[1])
  {
    print OUTF "\n";
    print OUTFTL "\n";
    print OUTFCC "\n";
  }
  else
  {
    print OUTF " ";
    print OUTFTL " ";
    print OUTFCC " ";
  }

  if(open(INF2, "$line[0]") != 1)
  {
    print "Can not open $line[0]\n";
    exit 1;
  }

  $max = -1;
  while($line[1] = <INF2>)
  {
    chomp($line[1]);
    @word3 = split(/\s+/, "$line[1]");
    if($word3[1] > $max)
    {
      $max = $word3[1];
      $maxT = $word3[0];
    }
  }
  close INF2;

  $line[2] = sprintf("%.6f(%.6f)", $maxT, $max);
  print OUTF "$line[2]";
  $line[2] = sprintf("%.6f", $maxT);
  print OUTFTL "$line[2]";
  $line[2] = sprintf("%.6f", $max);
  print OUTFCC "$line[2]";

  $word2[0] = $word1[0];
  $word2[1] = $word1[1];
}

close INF1;
close OUTF;
close OUTFTL;
close OUTFCC;

system "rm 07_tmptmp";

exit 0;
