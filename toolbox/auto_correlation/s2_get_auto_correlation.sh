cat << EOF > temp.pl

#!/usr/bin/env perl

use strict;

#command, input and output check
if(\$#ARGV != 1){
    print "You need to give <inputFile> and <outputFile>.\n";
    die "Command: perl temp.pl <inputFile> <outputFile";
}
if(!(open INF, "\$ARGV[0]")){
    die "Can't find \$ARGV[0], please check your inputFile.\n";
}
if(!(open OUTF, ">\$ARGV[1]")){
    die "Can't find \$ARGV[1], please check your outputFile.\n";
}


#calculate single water correlation
my @ref = split(/\s+/, <INF>);
my \$dotProduct = \$ref[1]**2 + \$ref[2]**2 + \$ref[3]**2;
print OUTF \$ref[0],"\t",\$dotProduct/\$dotProduct,"\n";

while(my \$line=<INF>){
    my @word = split(/\s+/, \$line);
    my \$result = (\$word[1] * \$ref[1] + \$word[2] * \$ref[2] + \$word[3] * \$ref[3]) / \$dotProduct;
    print OUTF \$word[0],"\t",\$result,"\n";
}

exit;
EOF


FILE=(`ls water_*.txt`)
for ((i=0; i<${#FILE[@]}; i=i+1))
do
    perl temp.pl ${FILE[$i]} auto_correlation_${FILE[$i]}
done
rm temp.pl
