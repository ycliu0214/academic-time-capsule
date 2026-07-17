
use strict;

#perl crossCorrelation.pl datafile_1.txt datafile_1.txt 1500 c 0.01 crossC_out.txt
#                         0              1              2    3 4    5

if($#ARGV != 5)
{
  print "perl crossCorrelation.pl 0 1 2 3 4 5\n";
  print "0: input file 1\n";
  print "1: input file 2\n";
  print "2: maximal delay\n";
  print "3: circular or not (c or n)\n";
  print "4: output time scale\n";
  print "5: output file name";
  exit 1;
}

my $inFile1 = "$ARGV[0]";
my $inFile2 = "$ARGV[1]";
my $maxDelay = $ARGV[2];
my $circular = "$ARGV[3]";
my $timeScale = $ARGV[4];
my $outFile = "$ARGV[5]";
my $line;
my @x;
my @i;
my $mx;
my $sx;
my @y;
my $my;
my $sy;
my $denom;
my $sxy;
my $r;
my $time;

if($circular ne "c" && $circular ne "n")
{
  print "Please enter \"c\" or \"n\" for indicating \"circular\" or \"not\" respectively\n";
  exit 1;
}

if(open(FIN, "$inFile1") != 1)
{
  print "Can not open $inFile1\n";
  exit 1;
}

$i[0] = 0;
$mx = 0;
while($line = <FIN>)
{
  chomp($line);
  $x[$i[0]] = $line;
  $mx += $line;
  $i[0]++;
}
$mx /= $i[0];

close FIN;

if(open(FIN, "$inFile2") != 1)
{
  print "Can not open $inFile2\n";
  exit 1;
}

$i[0] = 0;
while($line = <FIN>)
{
  chomp($line);
  $y[$i[0]] = $line;
  $my += $line;
  $i[0]++;
}
$my /= $i[0];

close FIN;

if($#x != $#y)
{
  $i[0] = $#x + 1;
  $i[1] = $#y + 1;
  print "The data number of two series is different ($i[0] & $i[1])\n";
  exit 1;
}

$sx = 0;
$sy = 0;
for($i[0] = 0, $i[1] = $#x + 1; $i[0] < $i[1]; $i[0]++)
{
  $i[2] = $x[$i[0]] - $mx;
  $sx += $i[2] * $i[2];
  $i[2] = $y[$i[0]] - $my;
  $sy += $i[2] * $i[2];
}
$denom = ($sx * $sy)**0.5;

if(open(FOUT, "> $outFile") != 1)
{
  print "Can not open $outFile\n";
  exit 1;
}

if($circular eq "n")
{
  for($i[0] = -$maxDelay, $i[1] = $maxDelay + 1; $i[0] < $i[1]; $i[0]++)
  {
    $sxy = 0;
    for($i[2] = 0, $i[3] = $#x + 1; $i[2] < $i[3]; $i[2]++)
    {
      $i[4] = $i[2] + $i[0];
      if(0 <= $i[4] && $i[4] < $i[3])
      {
        $sxy += ($x[$i[2]] - $mx) * ($y[$i[4]] - $my);
      }
    }
    $r = $sxy / $denom;
    $time = $i[0] * $timeScale;
    $line = sprintf("%.13f %.13f\n", $time, $r);
    print FOUT "$line";
  }
}
elsif($circular eq "c")
{
  for($i[0] = -$maxDelay, $i[1] = $maxDelay + 1; $i[0] < $i[1]; $i[0]++)
  {
    $sxy = 0;
    for($i[2] = 0, $i[3] = $#x + 1; $i[2] < $i[3]; $i[2]++)
    {
      $i[4] = $i[2] + $i[0];
      while($i[4] < 0)
      {
        $i[4] += $i[3];
      }
      $i[4] %= $i[3];
      $sxy += ($x[$i[2]] - $mx) * ($y[$i[4]] - $my);
    }
    $r = $sxy / $denom;
    $time = $i[0] * $timeScale;
    $line = sprintf("%.13f %.13f\n", $time, $r);
    print FOUT "$line";
  }
}
else
{
  print "What???\n";
  exit 1;
}

close FOUT;

exit 0;
