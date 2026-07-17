#!/usr/bin/perl
#Coding by Yu-Cheng Liu

use strict;
use Math::Trig;


my $lib_path = "lib"; 
if(open(INF, "${lib_path}/Au_electrode/2.83_bottom_left.gjf") != 1){
	$lib_path = "/usr1/ycliu2/bin/AutoOpt2Ant/lib";
}
close INF;
if(open(INF, "${lib_path}/Au_electrode/2.83_bottom_left.gjf") != 1){
	print "Can not fine lib folder.\n";
	exit 1;
}


#protein
###############################################################################################
if($#ARGV != 0){
	print "Typing your filename\n";
	print "perl test.pl <your .gjf>\n";
	exit 1;
}

my $inpfile = $ARGV[0];

my $cutname = $inpfile;
while(){
	if($cutname =~ /(\.gjf)$/){
		$cutname =~ s/\.gjf//;
		last;
	}
	elsif($cutname =~ /(\.com)$/){
		$cutname =~ s/\.com//;
		last;
	}
	else{
		print "Check your input file.\n";
		exit 1;
	}
}

if(open (INF, "$inpfile") != 1){
	print "Can not open ${inpfile}.\n";
	exit 1;
}

my $line;
my @word;
my @atom;
my @coorx;
my @coory;
my @coorz;
my $i;
my $j;

while($line=<INF>){
	@word=split(/\s+/, $line);
	if($word[1] =~ /(^[A-Z])([a-zA-Z]?$)/ && $word[2] =~ /(-?\d+)(\.)(\d+)?$/ && $word[3] =~ /(-?\d+)(\.)(\d+)?$/ && $word[4] =~ /(-?\d+)(\.)(\d+)?$/ && $#word == 4){
		push @atom, $word[1];
		push @coorx, $word[2];
		push @coory, $word[3];
		push @coorz, $word[4];
	}
}

close INF;

my $LS; #$LS = left electrode sulfur number
my $RS; #$RS = right electrode sulfur number

while(){
	print "Enter the number of left electrode sulfur.\n";
	$LS = <STDIN>;
	chomp $LS;
	if($LS =~ /^[0-9]*[1-9][0-9]*$/ && $atom[$LS - 1] eq "S"){
		last;
		print "Your selection is \"${LS}\".\n";
	}
	else{
		print "Check your selection.\n";
	}
}

while(){
	print "Enter the number of right electrode sulfur.\n";
	$RS = <STDIN>;
	chomp $RS;
	if($RS =~ /^[0-9]*[1-9][0-9]*$/ && $atom[$RS - 1] eq "S" && $RS != $LS){
		last;
		print "Your selection is \"${RS}\".\n";
	}
	else{
		print "Check your selection.\n";
	}
}

$LS -= 1; #number transform array index
$RS -= 1; #number transform array inder

my @shift_x = map { $_ - $coorx[$LS] } @coorx; #shift $LS - x to origin of coordinates
my @shift_y = map { $_ - $coory[$LS] } @coory; #shift $LS - y to origin of coordinates
my @shift_z = map { $_ - $coorz[$LS] } @coorz; #shift $LS - z to origin of coordinates

my $theta = asin(sqrt((($shift_y[$RS])**2)/((($shift_y[$RS])**2)+(($shift_z[$RS])**2))));
if(($shift_y[$RS] * $shift_z[$RS]) < 0){
	$theta = $theta * (-1);
}
my @rotate_x;
my @rotate_y;
my @rotate_z;
for($i=0; $i<=$#shift_x; $i++){
	$rotate_x[$i] = $shift_x[$i];
	$rotate_y[$i] = $shift_y[$i] * cos($theta) - $shift_z[$i] * sin($theta);
	$rotate_z[$i] = $shift_y[$i] * sin($theta) + $shift_z[$i] * cos($theta);
}

my $phi = asin(sqrt((($rotate_x[$RS])**2)/((($rotate_x[$RS])**2)+(($rotate_z[$RS])**2))));
if(($rotate_x[$RS] * $rotate_z[$RS]) < 0){
	$phi = $phi * (-1);
}
my @temporal_x;
my @temporal_y;
my @temporal_z;
for($i=0; $i<=$#rotate_x; $i++){
	$temporal_x[$i] = $rotate_x[$i] * cos($phi) - $rotate_z[$i] * sin($phi);
	$temporal_y[$i] = $rotate_y[$i];
	$temporal_z[$i] = $rotate_x[$i] * sin($phi) + $rotate_z[$i] * cos($phi);
}

my @result_x;
my @result_y;
my @result_z;


if($temporal_z[$RS] < 0){
	for($i=0; $i<=$#temporal_x; $i++){
		$result_x[$i] = ($temporal_x[$i] * -1) - ($temporal_z[$i] * 0);
		$result_y[$i] = $temporal_y[$i];
		$result_z[$i] = ($temporal_x[$i] * 0) + ($temporal_z[$i] * -1);
	}
}
else{
	@result_x = @temporal_x;
	@result_y = @temporal_y;
	@result_z = @temporal_z;
}

if(open (INF, "$inpfile") != 1){
	print "Can not open ${inpfile}.\n";
	exit 1;
}
my @bond_inf;
my $basic_set;
my $line_num=0;
my $line_check=0;
while($line=<INF>){
	@word=split(/\s+/, $line);
	if($word[1] =~ /(^[A-Z])([a-zA-Z]?$)/ && $word[2] =~ /(-?\d+)(\.)(\d+)?$/ && $word[3] =~ /(-?\d+)(\.)(\d+)?$/ && $word[4] =~ /(-?\d+)(\.)(\d+)?$/ && $#word == 4){
		$basic_set = $line_num - $line_check - 1;
		$line_check++;
	}
	if($line_num - $basic_set > $#result_x+2 && $line_num - $basic_set <= $#result_x*2+3){
		push @bond_inf, $line;
	}
	$line_num ++;
}

close INF;
###############################################################################################


#find bonding atoms with sulfur
###############################################################################################
my @LS_ARD; #$LS_ARD = around left sulfur and having bonding
my @RS_ARD; #$RS_ARD = aronnd right sulfur and having bonding

for($i=0; $i<=$#bond_inf; $i++){
	@word=split(/\s+/, $bond_inf[$i]);
	if($word[1] == $LS + 1){
		for($j=2; $j<=$#word; $j=$j+2){
			push @LS_ARD, $word[$j];
		}
	}
	elsif($word[1] == $RS + 1){
		for($j=2; $j<=$#word; $j=$j+2){
			push @RS_ARD, $word[$j];
		}
	}
	else{
		if($#word > 1){
			for($j=2; $j<=$#word; $j=$j+2){
				if($word[$j] == $LS + 1){
					push @LS_ARD, $word[1];
				}
				if($word[$j] == $RS + 1){
					push @RS_ARD, $word[1];
				}
			}
		}
	}
}

@LS_ARD = map { $_ - 1 } @LS_ARD;
@RS_ARD = map { $_ - 1 } @RS_ARD;

my $LH; #LS = the hydrogen which bonding with left sulfur
my $RH; #RS = the hydrogen which bonding with right sulfur
my $LHV; #LHV = the heavy atom which bonding with left sulfur
my $RHV; #RHV = the heavy atom which bonding with right sulfur

for($i=0; $i<=$#LS_ARD; $i++){
	if($atom[$LS_ARD[$i]] eq "H"){
		$LH=$LS_ARD[$i];
	}
	else{
		$LHV=$LS_ARD[$i];
	}
}
for($i=0; $i<=$#RS_ARD; $i++){
	if($atom[$RS_ARD[$i]] eq "H"){
		$RH=$RS_ARD[$i];
	}
	else{
		$RHV=$RS_ARD[$i];
	}
}
###############################################################################################

#choose the Au lattice length
###############################################################################################
my $lattice_length;
while(){
	print "Choose the Au lattice length.\n";
	print "You can choose \"2.83\" or \"2.88\" (angstrom)\n";
	$lattice_length = <STDIN>;
	chomp $lattice_length;
	if($lattice_length == 2.83 || $lattice_length == 2.88){ 
		last;
	}
	else{
		print "Check the Au lattice length.\n";
	}
}

###############################################################################################



#check overlap and repair the problem
###############################################################################################
my $special_case=0;

for($i=0; $i<=$#atom; $i++){
	if($i != $LS && $i != $RS && $i != $LH && $i != $RH){
		if($result_z[$i] <= $result_z[$LS] - 1.5 || $result_z[$i] >= $result_z[$RS] + 1.5){
			$special_case=1;
			last;
		}
	}
}

my $electrode_type = 5;

if($special_case==0){
	$electrode_type=4;
}

if($special_case == 1){
	@temporal_x = @result_x;
	@temporal_y = @result_y;
	@temporal_z = @result_z;
	my $rotate_rad;
	my @fixing_rad;
	$fixing_rad[0] = asin(${lattice_length} / (sqrt($result_x[$RS]**2 + $result_y[$RS]**2 + $result_z[$RS]**2)));
	$fixing_rad[1] = asin(2 * ${lattice_length} / (sqrt($result_x[$RS]**2 + $result_y[$RS]**2 + $result_z[$RS]**2)));
	$fixing_rad[2] = -1 * asin(${lattice_length} / (sqrt($result_x[$RS]**2 + $result_y[$RS]**2 + $result_z[$RS]**2)));
	$fixing_rad[3] = -1 * asin(2 * ${lattice_length} / (sqrt($result_x[$RS]**2 + $result_y[$RS]**2 + $result_z[$RS]**2)));
	my @fixing_x;
	my @fixing_y;
	my @fixing_z;
	for($rotate_rad = pi / 18; $rotate_rad < pi * 2; $rotate_rad += pi / 18){
		my $end_rotate = 0;
		for($i=0; $i<=$#atom; $i++){
			$rotate_x[$i] = $temporal_x[$i] * cos($rotate_rad) - $temporal_y[$i] * sin($rotate_rad);
			$rotate_y[$i] = $temporal_x[$i] * sin($rotate_rad) + $temporal_y[$i] * cos($rotate_rad);
			$rotate_z[$i] = $temporal_z[$i];
		}
		for($i=0; $i<=$#fixing_rad; $i++){
			my $fixing_check=0;
			for($j=0; $j<=$#atom; $j++){
				$fixing_x[$j] = $rotate_x[$j] * cos($fixing_rad[$i]) - $rotate_z[$j] * sin($fixing_rad[$i]);
				$fixing_y[$j] = $rotate_y[$j];
				$fixing_z[$j] = $rotate_x[$j] * sin($fixing_rad[$i]) + $rotate_z[$j] * cos($fixing_rad[$i]);
			}
			for($j=0; $j<=$#atom; $j++){
				if($j != $LS && $j != $RS && $j != $LH && $j != $RH){
					if($fixing_z[$j] < $fixing_z[$LS] - 1.5 || $fixing_z[$j] > $fixing_z[$RS] + 1.5){
						$fixing_check = 1;
						last;
					}
				}
			}
			if($fixing_check == 0){
				@result_x = @fixing_x;
				@result_y = @fixing_y;
				@result_z = @fixing_z;
				$electrode_type = $i;
				$end_rotate = 1;
				last;
			}
		}
		if($end_rotate == 1){
			last;
		}
	}
}



###############################################################################################


#define electrode type
###############################################################################################
my $left_elec_file;
my $right_elec_file;

if($electrode_type == 4){
	$left_elec_file = "${lib_path}/Au_electrode/${lattice_length}_middle_left.gjf";
	$right_elec_file = "${lib_path}/Au_electrode/${lattice_length}_middle_right.gjf";
}
elsif($electrode_type == 3){
	$left_elec_file = "${lib_path}/Au_electrode/${lattice_length}_middle_left.gjf";
	$right_elec_file = "${lib_path}/Au_electrode/${lattice_length}_middle_right.gjf";
}
elsif($electrode_type == 2){
	$left_elec_file = "${lib_path}/Au_electrode/${lattice_length}_middle_left.gjf";
	$right_elec_file = "${lib_path}/Au_electrode/${lattice_length}_middle_right.gjf";
}
elsif($electrode_type == 1){
	$left_elec_file = "${lib_path}/Au_electrode/${lattice_length}_middle_left.gjf";
	$right_elec_file = "${lib_path}/Au_electrode/${lattice_length}_middle_right.gjf";
}
elsif($electrode_type == 0){
	$left_elec_file = "${lib_path}/Au_electrode/${lattice_length}_middle_left.gjf";
	$right_elec_file = "${lib_path}/Au_electrode/${lattice_length}_middle_right.gjf";
}
elsif($electrode_type == 5){
	print "Your structure can't be connected to electrodes.\n";
	print "You need to check the structure.\n";
	exit;
}
###############################################################################################



#left_electrode
###############################################################################################
if(open(INF, "$left_elec_file") != 1){
	print "Can not open ${left_elec_file}.\n";
	exit 1;
}

my @left_atom;
my @left_coorx;
my @left_coory;
my @left_coorz;
while($line=<INF>){
	@word=split(/\s+/, $line);
	if($word[1] =~ /(^[A-Z])([a-zA-Z]?$)/ && $word[2] =~ /(-?\d+)(\.)(\d+)?$/ && $word[3] =~ /(-?\d+)(\.)(\d+)?$/ && $word[4] =~ /(-?\d+)(\.)(\d+)?$/ && $#word == 4){
		push @left_atom, $word[1];
		push @left_coorx, $word[2];
		push @left_coory, $word[3];
		push @left_coorz, $word[4];
	}
}

close INF;



open INF,"$left_elec_file";
$basic_set=0;
$line_num=0;
$line_check=0;
my @left_bond_inf;
while($line=<INF>){
	@word=split(/\s+/, $line);
	if($word[1] =~ /(^[A-Z])([a-zA-Z]?$)/ && $word[2] =~ /(-?\d+)(\.)(\d+)?$/ && $word[3] =~ /(-?\d+)(\.)(\d+)?$/ && $word[4] =~ /(-?\d+)(\.)(\d+)?$/ && $#word == 4){
		$basic_set = $line_num - $line_check - 1;
		$line_check++;
	}
	if($line_num - $basic_set > $#left_coorx+2 && $line_num - $basic_set <= $#left_coorx*2+3){
		push @left_bond_inf, $line;
	}
	$line_num ++;
}

map {chomp $_} @left_bond_inf;

close INF;

my $shift_x_length = $left_coorx[36] - $result_x[$LS];
my $shift_y_length = $left_coory[36] - $result_y[$LS];
my $shift_z_length = $left_coorz[36] - $result_z[$LS];

@left_coorx = map {$_ - $shift_x_length} @left_coorx;
@left_coory = map {$_ - $shift_y_length} @left_coory;
@left_coorz = map {$_ - $shift_z_length} @left_coorz;

###############################################################################################

#right_electrode
###############################################################################################
if(open(INF, "$right_elec_file") != 1){
	print "Can not open ${right_elec_file}.\n";
	exit 1;
}

my @right_atom;
my @right_coorx;
my @right_coory;
my @right_coorz;
while($line=<INF>){
	@word=split(/\s+/, $line);
	if($word[1] =~ /(^[A-Z])([a-zA-Z]?$)/ && $word[2] =~ /(-?\d+)(\.)(\d+)?$/ && $word[3] =~ /(-?\d+)(\.)(\d+)?$/ && $word[4] =~ /(-?\d+)(\.)(\d+)?$/ && $#word == 4){
		push @right_atom, $word[1];
		push @right_coorx, $word[2];
		push @right_coory, $word[3];
		push @right_coorz, $word[4];
	}
}

close INF;

open INF,"$right_elec_file";
$basic_set=0;
$line_num=0;
$line_check=0;
my @right_bond_inf;
while($line=<INF>){
	@word=split(/\s+/, $line);
	if($word[1] =~ /(^[A-Z])([a-zA-Z]?$)/ && $word[2] =~ /(-?\d+)(\.)(\d+)?$/ && $word[3] =~ /(-?\d+)(\.)(\d+)?$/ && $word[4] =~ /(-?\d+)(\.)(\d+)?$/ && $#word == 4){
		$basic_set = $line_num - $line_check - 1;
		$line_check++;
	}
	if($line_num - $basic_set > $#right_coorx+2 && $line_num - $basic_set <= $#right_coorx*2+3){
		push @right_bond_inf, $line;
	}
	$line_num ++;
}

map {chomp $_} @right_bond_inf;

close INF;

$shift_x_length = $right_coorx[0] - $result_x[$RS];
$shift_y_length = $right_coory[0] - $result_y[$RS];
$shift_z_length = $right_coorz[0] - $result_z[$RS];

@right_coorx = map {$_ - $shift_x_length} @right_coorx;
@right_coory = map {$_ - $shift_y_length} @right_coory;
@right_coorz = map {$_ - $shift_z_length} @right_coorz;

###############################################################################################



#first atom number shift
###############################################################################################
my $j;
for($i=0; $i<=$#bond_inf; $i++){
	@word=split(/\s+/, $bond_inf[$i]);
	$word[1]=$word[1] + $#left_atom + 1;
	if($#word > 1){
		for($j=2; $j<=$#word; $j+=2){
			$word[$j]=$word[$j] + $#left_atom + 1;
		}
	}
	$bond_inf[$i]='';
	for($j=1; $j<=$#word; $j++){
		$bond_inf[$i] .= " $word[$j]";
	}
}

for($i=0; $i<=$#right_bond_inf; $i++){
	@word=split(/\s+/, $right_bond_inf[$i]);
	$word[1]=$word[1] + $#left_atom + $#atom + 2;
	if($#word > 1){
		for($j=2; $j<=$#word; $j+=2){
			$word[$j]=$word[$j] + $#left_atom + $#atom + 2;
		}
	}
	$right_bond_inf[$i]='';
	for($j=1; $j<=$#word; $j++){
		$right_bond_inf[$i] .= " $word[$j]";
	}
}

###############################################################################################

#delete unnecessary atoms
###############################################################################################

for($i=0; $i<=$#atom; $i++){
	if($i==$LH || $i==$RH || $i==$LS || $i==$RS){
		$atom[$i] = '';
	}
}

my @del_atoms = ($LH , $RH , $LS , $RS);
@del_atoms = sort { $a<=>$b } map {$_ + $#left_bond_inf + 2} @del_atoms;

my $LHV_temp;
my $RHV_temp;

for($i=0; $i<=$#bond_inf; $i++){
	@word=split(/\s+/, $bond_inf[$i]);
	if($word[1] < $del_atoms[0]){
		if($word[1] == $LHV + $#left_bond_inf + 2){
			$LHV_temp = $word[1];
		}
		elsif($word[1] == $RHV + $#left_bond_inf + 2){
			$RHV_temp = $word[1];
		}
	}
	elsif($word[1] < $del_atoms[1] && $word[1] > $del_atoms[0]){
		if($word[1] == $LHV + $#left_bond_inf + 2){
			$LHV_temp = $word[1] - 1;
		}
		elsif($word[1] == $RHV + $#left_bond_inf + 2){
			$RHV_temp = $word[1] - 1;
		}
		$word[1] = $word[1] - 1;
	}
	elsif($word[1] < $del_atoms[2] && $word[1] > $del_atoms[1]){
		if($word[1] == $LHV + $#left_bond_inf + 2){
			$LHV_temp = $word[1] - 2;
		}
		elsif($word[1] == $RHV + $#left_bond_inf + 2){
			$RHV_temp = $word[1] - 2;
		}
		$word[1] = $word[1] - 2;
	}
	elsif($word[1] < $del_atoms[3] && $word[1] > $del_atoms[2]){
		if($word[1] == $LHV + $#left_bond_inf + 2){
			$LHV_temp = $word[1] - 3;
		}
		elsif($word[1] == $RHV + $#left_bond_inf + 2){
			$RHV_temp = $word[1] - 3;
		}
		$word[1] = $word[1] - 3;
	}
	elsif($word[1] > $del_atoms[3]){
		if($word[1] == $LHV + $#left_bond_inf + 2){
			$LHV_temp = $word[1] - 4;
		}
		elsif($word[1] == $RHV + $#left_bond_inf + 2){
			$RHV_temp = $word[1] - 4;
		}
		$word[1] = $word[1] - 4;
	}
	elsif($word[1] == $del_atoms[0] || $word[1] == $del_atoms[1] || $word[1] == $del_atoms[2] || $word[1] == $del_atoms[3]){
		@word=();
	}
	if($#word > 1){
		for($j=2; $j<=$#word; $j+=2){
			if($word[$j] < $del_atoms[1] && $word[$j] > $del_atoms[0]){
				$word[$j] = $word[$j] - 1;
			}
			elsif($word[$j] < $del_atoms[2] && $word[$j] > $del_atoms[1]){
				$word[$j] = $word[$j] - 2;
			}
			elsif($word[$j] < $del_atoms[3] && $word[$j] > $del_atoms[2]){
				$word[$j] = $word[$j] - 3;
			}
			elsif($word[$j] > $del_atoms[3]){
				$word[$j] = $word[$j] - 4;
			}
			elsif($word[$j] == $LH + $#left_bond_inf + 2 || $word[$j] == $RH + $#left_bond_inf + 2 || $word[$j] == $LS + $#left_bond_inf + 2){
				$word[$j] = '';
				$word[$j+1] = '';
			}
			elsif($word[$j] == $RS + $#left_bond_inf + 2){
				my @tempword=split(/\s+/, $right_bond_inf[0]);
				$word[$j] = $tempword[1] - 4;
			}
		}
	}
	$bond_inf[$i]='';
	for($j=1; $j<=$#word; $j++){
		if($word[$j] ne ''){
			$bond_inf[$i] .= " $word[$j]";
		}
	}
}

$LHV = $LHV_temp;
$RHV = $RHV_temp;

@word=split(/\s+/, $left_bond_inf[$#left_bond_inf]);
push @word, "$LHV";
push @word, "1.0";
$left_bond_inf[$#left_bond_inf]='';
for($j=1; $j<=$#word; $j++){
	$left_bond_inf[$#left_bond_inf] .= " $word[$j]";
}

for($i=0; $i<=$#right_bond_inf; $i++){
	@word=split(/\s+/, $right_bond_inf[$i]);
	$word[1]=$word[1] - 4;
	if($#word > 1){
		for($j=2; $j<=$#word; $j+=2){
			$word[$j]=$word[$j] - 4;
		}
	}
	$right_bond_inf[$i]='';
	for($j=1; $j<=$#word; $j++){
		$right_bond_inf[$i] .= " $word[$j]";
	}
}


###############################################################################################




#print result
###############################################################################################
if(open(OUTF, ">${cutname}_Au.gjf") != 1){
	print "Can not open ${cutname}_Au.gjf.\n";
	exit 1;
}


my $memo;
my $node;
my $charge;
my $spin;


while(){
	print "Select your shared processors (core).\n";
	print "ex: 2, 4, 8, 12 or not typing\n";
	$node=<STDIN>;
	chomp $node;
	if($node =~ /^?\d+$/){
		print OUTF "%nprocshared=${node}\n";
		last;
	}
	elsif($node eq ''){
		last;
	}
	else{
		print "Check your shared processors setting\n";
	}
}

while(){
	print "Select your memory limit.\n";
	print "ex: 8GB, 30GB, 500MB or not typing\n";
	$memo=<STDIN>;
	chomp $memo;
	if($memo =~ /(^?\d+)(GB)$/ || $memo =~ /(^?\d+)(MB)$/){
		print OUTF "%mem=${memo}\n";
		last;
	}
	elsif($memo eq ''){
		last;
	}
	else{
		print "Check your momery limit setting\n";
	}
}

print OUTF "%chk=${cutname}_Au.chk\n";
print OUTF "%Subst L502 /usr1/ycliu2/bin/hclin.alacant/g09/antg09.bin/\n";
print OUTF "%Subst L101 /usr1/ycliu2/bin/hclin.alacant/g09/antg09.bin/\n";
print OUTF "#p b3lyp/gen nosymm pop=(full,nbo) geom=connectivity formcheck gfinput pseudo=read\n";
print OUTF "scf=(dsymm,conver=5,nodamp,maxcycle=1000)\n\n";
print OUTF "${cutname}_Au\n\n";
while(){
	print "Select your charge.\n";
	print "ex: 0, 1, 2, -1, -2 or other\n";
	print "Please use integer.\n";
	$charge=<STDIN>;
	chomp $charge;
	if($charge =~ /^-?\d+$/){
		print OUTF "$charge ";
		last;
	}
	else{
		print "Check your charge setting\n";
	}
}
while(){
	print "Select your spin.\n";
#	print "If your charge is even, your spin would be set 1, 3, 5, ...\n";
#	print "If your charge is odd, your spin would be set 2, 4, 6, ...\n";
	print "1: singlet, 2: doublet, 3: triplet...\n";
	print "Do not set too large (1~10).\n";
	$spin=<STDIN>;
	chomp $spin;
	if($spin =~ /^\d+$/){
		print OUTF "$spin\n";
		last;
	}
#	my $decide = $charge;
#	if($decide < 0){
#		$decide = $decide * -1;
#	}
#	$decide = $decide % 2;
#	if($decide == 1){
#		if($spin == 2 || $spin == 4 || $spin == 6 || $spin == 8 || $spin == 10){
#			print OUTF "$spin\n";
#			last;
#		}
#	}
#	elsif($decide == 0 || $charge == 0){
#		if($spin == 1 || $spin == 3 || $spin == 5 || $spin == 7 || $spin == 9){
#			print OUTF "$spin\n";
#			last;
#		}
#	}
	else{
		print "Check your spin setting\n";
	}
}


for($i=0; $i<=$#left_atom; $i++){
	printf OUTF ("\t%s\t%.8f\t%.8f\t%.8f\n", $left_atom[$i], $left_coorx[$i], $left_coory[$i], $left_coorz[$i]);
}
for($i=0; $i<=$#atom; $i++){
	if($atom[$i] ne ''){
		printf OUTF ("\t%s\t%.8f\t%.8f\t%.8f\n", $atom[$i], $result_x[$i], $result_y[$i], $result_z[$i]);
	}
}
for($i=0; $i<=$#right_atom; $i++){
	printf OUTF ("\t%s\t%.8f\t%.8f\t%.8f\n", $right_atom[$i], $right_coorx[$i], $right_coory[$i], $right_coorz[$i]);
}
print OUTF "\n";

for($i=0; $i<=$#left_bond_inf; $i++){
	print OUTF "$left_bond_inf[$i]\n";
}
for($i=0; $i<=$#bond_inf; $i++){
	@word=split(/\s+/, $bond_inf[$i]);
	if($word[1] ne ''){
		print OUTF "$bond_inf[$i]\n";
	}
}
for($i=0; $i<=$#right_bond_inf; $i++){
	print OUTF "$right_bond_inf[$i]\n";
}

print OUTF "\n";

@word=split(/\s+/, $left_bond_inf[0]);
print OUTF "${word[1]}-";
@word=split(/\s+/, $left_bond_inf[$#left_bond_inf - 1]);
print OUTF "${word[1]} ";
@word=split(/\s+/, $right_bond_inf[1]);
print OUTF "${word[1]}-";
@word=split(/\s+/, $right_bond_inf[$#right_bond_inf]);
print OUTF "$word[1]\n";
print OUTF "S        3        1.00\n";
print OUTF "         0.4409	 -0.7478\n";
print OUTF "         0.2626   0.8176\n";
print OUTF "         0.0617   0.8113\n";
print OUTF "P        3        1.00\n";
print OUTF "         0.6642  -0.0459\n";
print OUTF "         0.1073   0.3778\n";
print OUTF "         0.0318   0.7233\n";
print OUTF "D        4        1.00\n";
print OUTF "         1.3517   0.4787\n";
print OUTF "         0.5149   0.4582\n";
print OUTF "         0.1994   0.2203\n";
print OUTF "         0.0776   0.0412\n";
print OUTF "****\n";
@word=split(/\s+/, $left_bond_inf[$#left_bond_inf]);
printf OUTF ("%d-", $word[1] + 1);
@word=split(/\s+/, $right_bond_inf[0]);
printf OUTF ("%d\n", $word[1] - 1);
print OUTF "6-31g(d,p)\n";
print OUTF "****\n";
@word=split(/\s+/, $left_bond_inf[$#left_bond_inf]);
print OUTF "$word[1] ";
for($i=0; $i<=$#atom; $i++){
	if($atom[$i] eq "S" || $atom[$i] eq "P"){
		@word=split(/\s+/, $bond_inf[$i]);
		print OUTF "$word[1] ";
	}
}
@word=split(/\s+/, $right_bond_inf[0]);
print OUTF "$word[1]\n";
print OUTF "6-311g(d,p)\n";
print OUTF "****\n";
my @metal = qw/Li Na K Rb Cs Be Mg Ca Sr Ba Sc Ti V Cr Mn Fe Co Ni Cu Zn Ga Ge Y Zr Nb Mo Tc Ru Rh Pd Ag Cd In Sn Sb/;
my $lanl2dz_case=0;
for($i=0; $i<=$#atom; $i++){
	for($j=0; $j<=$#metal; $j++){
		if($atom[$i] eq $metal[$j]){
			@word=split(/\s+/, $bond_inf[$i]);
			print OUTF "$word[1] ";
			$lanl2dz_case=1;
		}
	}
}
if($lanl2dz_case == 1){
	print OUTF "\n";
	print OUTF "LanL2DZ\n";
	print OUTF "****\n\n";
}
else{
	print OUTF "\n";
}
@word=split(/\s+/, $left_bond_inf[0]);
print OUTF "${word[1]}-";
@word=split(/\s+/, $left_bond_inf[$#left_bond_inf - 1]);
print OUTF "${word[1]} ";
@word=split(/\s+/, $right_bond_inf[1]);
print OUTF "${word[1]}-";
@word=split(/\s+/, $right_bond_inf[$#right_bond_inf]);
print OUTF "$word[1]\n";
print OUTF "ECP10CE   4   68\n";
print OUTF "L=4 COMPONENT\n";
print OUTF "  6\n";
print OUTF "    2    0.965700   -0.986902   -0.036453\n";
print OUTF "    2    2.290400   -9.686306    0.089980\n";
print OUTF "    2    6.438400  -32.572463   -0.136746\n";
print OUTF "    2   16.364600 -118.530878    0.451632\n";
print OUTF "    2   55.989300 -286.254646    0.371907\n";
print OUTF "    1  171.101400  -51.274231    2.242298\n";
print OUTF "L=0 COMPONENT\n";
print OUTF "  8\n";
print OUTF "    2    1.224800  -84.969303\n";
print OUTF "    2    1.433600  280.177643\n";
print OUTF "    2    1.892900 -354.643566\n";
print OUTF "    2    2.696300  334.331909\n";
print OUTF "    2    3.989900 -219.392605\n";
print OUTF "    2    6.005500  170.858744\n";
print OUTF "    1   14.582600   56.338731\n";
print OUTF "    0   39.310700    6.409300\n";
print OUTF "L=1 COMPONENT\n";
print OUTF "  8\n";
print OUTF "    2    0.906400   -6.911901   15.779047\n";
print OUTF "    2    1.031100   72.125463  -23.146780\n";
print OUTF "    2    1.328700 -114.975335    3.512895\n";
print OUTF "    2    1.903700  123.616682   12.024899\n";
print OUTF "    2    2.836400  -71.135709  -12.913723\n";
print OUTF "    2    4.588400   79.016603    6.283896\n";
print OUTF "    1   11.198100   51.287008   -0.405461\n";
print OUTF "    0   32.295700    5.651983    0.054812\n";
print OUTF "L=2 COMPONENT\n";
print OUTF "  8\n";
print OUTF "    2    0.293100   -0.113657   -0.016533\n";
print OUTF "    2    1.030100   -2.404025    0.328001\n";
print OUTF "    2    2.018600   62.581116  -11.521077\n";
print OUTF "    2    3.439200  255.447176  -32.439090\n";
print OUTF "    2    5.157900 -161.806480   18.860086\n";
print OUTF "    2    2.514900 -175.770760   29.831210\n";
print OUTF "    1    8.062400   63.620792   -0.309918\n";
print OUTF "    0   41.028500    6.750320    0.072853\n";
print OUTF "L=3 COMPONENT\n";
print OUTF "  8\n";
print OUTF "    2    0.433500  -47.607799   -0.895041\n";
print OUTF "    2    0.509700  176.318029    3.139580\n";
print OUTF "    2    0.579600 -168.676897   -2.813752\n";
print OUTF "    2    0.771100   54.492446    0.687538\n";
print OUTF "    2    2.593500   37.715393   -0.284013\n";
print OUTF "    2    8.390700  -24.139676   -1.292557\n";
print OUTF "    1    6.929400   49.168024    0.129708\n";
print OUTF "    0   22.258900    4.759586   -0.005240\n";
print OUTF "\n\n\n\n";

close OUTF;


if(open(OUTF, ">${cutname}_Au.ini") != 1){
	print "Can not open ${cutname}_Au.ini.\n";
	exit 1;
}
print OUTF "! *********************************\n";
print OUTF "! * Parameter initialization file *\n";
print OUTF "! *********************************\n";
print OUTF "!\n";
print OUTF "! This example file contains all parameters and options\n";
print OUTF "! which can be user-defined. Just uncomment the one you\n";
print OUTF "! want to modify or switch on.\n";
print OUTF "!\n";
print OUTF "! This file must have the name xxx.ini\n";
print OUTF "! where xxx is the character string given in the title line of\n";
print OUTF "! the input file (.com). Both must be in the same directory.\n";
print OUTF "!\n";
print OUTF "! If there is no parameter file the program will run with\n";
print OUTF "! the default values, which are given here in this example.\n";
print OUTF "! The same holds true for an empty file or a file only\n";
print OUTF "! containing comments and/or blank lines.\n";
print OUTF "!\n";
print OUTF "! Syntax rules:\n";
print OUTF "!\n";
print OUTF "! 1) comment lines start with a !\n";
print OUTF "!\n";
print OUTF "! 2) empty lines are ignored\n";
print OUTF "!\n";
print OUTF "! 3) Syntax for real and integer variable assignment\n";
print OUTF "!\n";
print OUTF "!	KEYWORD = value\n";
print OUTF "!\n";
print OUTF "!    where KEYWORD is always in uppercase. All allowed\n";
print OUTF "!    keywords are listed below with the default value\n";
print OUTF "!    assigned to it.\n";
print OUTF "!\n";
print OUTF "! 4) Logical variable syntax:\n";
print OUTF "!\n";
print OUTF "!	KEYWORD\n";
print OUTF "!\n";
print OUTF "!    If the Keyword is specified, the variable\n";
print OUTF "!    is given the value .TRUE.\n";
print OUTF "!    The default value is .FALSE.\n";
print OUTF "!    Thus the logical varibles act as switches turning\n";
print OUTF "!    on a specific feature. For example, the keyword ALPHA\n";
print OUTF "!    controls the mixing in the selfconsistency\n";
print OUTF "!\n";
print OUTF "! 5) The order of statements is arbitrary.\n";
print OUTF "!\n";
print OUTF "! ********************************\n";
print OUTF "! * Basic calculation parameters *\n";
print OUTF "! ********************************\n";
print OUTF "!\n";
print OUTF "! *** Mixing parameter for density matrix (0.0 < alpha < 0.1)\n";
print OUTF "!\n";
print OUTF "   ALPHA      =    2.9D-2\n";
print OUTF "!\n";
print OUTF "! *** Pauly parameter for density matrix (1 < NPauly < 10)\n";
print OUTF "!\n";
print OUTF "   NPULAY      =    4\n";
print OUTF "!\n";
print OUTF "! *** Maximum accuracy in numerical integration of density matrix (%)\n";
print OUTF "!\n";
print OUTF "   PACC  =    1.0D-5\n";
print OUTF "!\n";
print OUTF "! *** Maximum accuracy of total charge in the system (%)\n";
print OUTF "!\n";
print OUTF "   CHARGEACC  =    1.0D-5\n";
print OUTF "!\n";
print OUTF "! *** Maximum accuracy of the Fermi level (%)\n";
print OUTF "!\n";
print OUTF "   FERMIACC   =    1.0D-5\n";
print OUTF "!\n";
print OUTF "! *** Setting full accuracy\n";
print OUTF "!\n";
print OUTF "!  FULLACC\n";
print OUTF "!\n";
print OUTF "! *** Maximum number of search steps for Fermi energy\n";
print OUTF "!\n";
print OUTF "!  MAX = 15\n";
print OUTF "!\n";
print OUTF "! *** Accuracy for the selfenergy\n";
print OUTF "!\n";
print OUTF "   SELFACC   =    1.0D-5\n";
print OUTF "!\n";
print OUTF "! *** Parameters for determining Bethe lattice directions\n";
print OUTF "!\n";
print OUTF "!  SMALL   =    0.1\n";
print OUTF "!  SMALLD   =    0.1\n";
print OUTF "!\n";
print OUTF "! *** Bias Voltage (V)\n";
print OUTF "!\n";
print OUTF "  BIASVOLT  =    0.0\n";
print OUTF "!\n";
print OUTF "! *** Excess charge\n";
print OUTF "!\n";
my $qexcess = 0 - $charge;
printf OUTF ("   QEXCESS  =    %.1f\n", $qexcess);
#print OUTF "!  QEXCESS  =    0.0\n";
print OUTF "!\n";
print OUTF "! *** Small imaginary part for Green's function\n";
print OUTF "!\n";
print OUTF "!  ETA        =    1.0D-10\n";
print OUTF "!\n";
print OUTF "! *** Switching on leads\n";
print OUTF "!\n";
print OUTF "!  SL         =    1.0d-4\n";
print OUTF "!\n";
print OUTF "! *** Start value for Fermi level search\n";
print OUTF "!\n";
print OUTF "!  FERMISTART =   -5.0D0\n";
print OUTF "!\n";
print OUTF "! *** Type of electrode\n";
print OUTF "!\n";
print OUTF "!   TYPE1 = BETHE\n";
print OUTF "!   TYPE2 = BETHE\n";
print OUTF "!\n";
print OUTF "! *** Coupling strength of Bethe lattice\n";
print OUTF "!\n";
print OUTF "!  GLUE = 1.0\n";
print OUTF "!\n";
print OUTF "! *** Type of electrode parameters\n";
print OUTF "!\n";
print OUTF "   BLPAR1 = Papacon\n";
print OUTF "   BLPAR2 = Papacon\n";
print OUTF "!\n";
print OUTF "! *** Overlap parameter\n";
print OUTF "!\n";
print OUTF "   OVERLAP = 0.0\n";
print OUTF "!\n";
print OUTF "! *** Number of atoms to be considered for connection to the Bethe lattice\n";
print OUTF "!\n";
print OUTF "    NEMBED1 = 9\n";
print OUTF "    NEMBED2 = 9\n";
print OUTF "!\n";
print OUTF "! *** Number of atoms in each electrode (useful for single-element systems)\n";
print OUTF "!\n";
print OUTF "   NATOMEL1 = 36\n";
print OUTF "   NATOMEL2 = 36\n";
print OUTF "!\n";
print OUTF "! *******************************\n";
print OUTF "! * Reinitialization parameters *\n";
print OUTF "! *******************************\n";
print OUTF "!\n";
print OUTF "! *** Name of the file containing a previously computed density matrix to be partially used\n";
print OUTF "!\n";
print OUTF "! PFIX\n";
print OUTF "! 'P.file_with_density_matrix.dat'\n";
print OUTF "!\n";
print OUTF "! *** Number of atoms (and their labels) to be kept in the new calculation\n";
print OUTF "!\n";
print OUTF "! NFIX = 3\n";
print OUTF "! 1 2 3\n";
print OUTF "!\n";
print OUTF "! *****************************\n";
print OUTF "! * Spin transport parameters *\n";
print OUTF "! *****************************\n";
print OUTF "!\n";
print OUTF "! *** Fix spin multiplicity for the given number of steps\n";
print OUTF "!\n";
print OUTF "   NSPINLOCK = 10000\n";
print OUTF "!\n";
print OUTF "! *** Or fix spin state until a given covergence\n";
print OUTF "!\n";
print OUTF "!  SWOFFSPL = 1.0d-3\n";
print OUTF "!\n";
print OUTF "! *** Manipulate the direction of atomic spins in initial guess\n";
print OUTF "!\n";
print OUTF "!  SPINEDIT\n";
print OUTF "!  10         ! Manipulate three atoms\n";
print OUTF "!  1,-1\n";
print OUTF "!  1,1       ! Leave the spin as is (not really useful)\n";
print OUTF "!  2,-1      ! Reverse this spin: Spin-up occupation becomes Spin-down occupation and vice versa\n";
print OUTF "!  3,0       ! Erase this spin: Spin-up and Spin-down occupation become equal\n";
print OUTF "!\n";
print OUTF "! *** Reverse magnetization of cluster in initial guess\n";
print OUTF "!     for all atoms starting from the atom given by MRSTART.\n";
print OUTF "!     If MRSTART=0 (default) do not reverse magnetization\n";
print OUTF "!     Useful for starting antiparallel calculation from a converged ferromagnetic calculation\n";
print OUTF "!\n";
print OUTF "!  MRSTART = 1\n";
print OUTF "!\n";
print OUTF "! *** Change magnetic boundary conditions, e.g., UD: Up (first electrode)-Down (second electrode)\n";
print OUTF "!     Useful con starting with a modified density matrix as initial guess. The default is UU.\n";
print OUTF "!\n";
print OUTF "!  UD      !Up-Down\n";
print OUTF "!  DU      !Down-Up\n";
print OUTF "!  DD      !Down-Down\n";
print OUTF "!\n";
print OUTF "! *** Number of Alpha and Beta Electrons (useful to overrule multiplicity given in the GAUSSIAN input file)\n";
print OUTF "!\n";
print OUTF "  NALPHA = 483\n";
print OUTF "  NBETA = 483\n";
print OUTF "!\n";
print OUTF "! *********************\n";
print OUTF "! * Output parameters *\n";
print OUTF "! *********************\n";
print OUTF "!\n";
print OUTF "! *** Print out Mulliken population analysis to a file\n";
print OUTF "!\n";
print OUTF "   MULLIKEN = T\n";
print OUTF "!\n";
print OUTF "! *** Print out converged Kohn-Sham Hamiltonian to a file\n";
print OUTF "!\n";
print OUTF "!  HAMILTON\n";
print OUTF "!\n";
print OUTF "! *** Compute Transmision matrix in HERMITIAN Form\n";
print OUTF "!     T = Gamma_L^1/2 G^a Gamma_R G Gamma_L^1/2\n";
print OUTF "!\n";
print OUTF "!  HTRANSM\n";
print OUTF "!\n";
print OUTF "! *** Energy step\n";
print OUTF "!\n";
print OUTF "  ESTEP     =    1.0D-2\n";
print OUTF "!\n";
print OUTF "! *** Energy window for transmission function and DOS calcualtion from EW1 to EW2\n";
print OUTF "!\n";
print OUTF "   EW1 = -5.0D0\n";
print OUTF "   EW2 =  5.0D0\n";
print OUTF "!\n";
print OUTF "! *** On which atoms to evaluate local density of states\n";
print OUTF "!\n";
@word=split(/\s+/, $left_bond_inf[$#left_bond_inf]);
print OUTF "   LDOS_BEG   =    $word[1]\n";
@word=split(/\s+/, $right_bond_inf[0]);
print OUTF "   LDOS_END   =    $word[1]\n";
print OUTF "!\n";
print OUTF "! *** Number of eigenchannels to print out in T.dat\n";
print OUTF "!\n";
print OUTF "!  NCHANNELS  =    5\n";
print OUTF "!\n";
print OUTF "! *** Printout Bulk DOS of Leads\n";
print OUTF "!     Output files: Lead1DOS.dat, Lead2DOS.dat\n";
print OUTF "!\n";
print OUTF "!  LEADDOS\n";
print OUTF "!\n";
print OUTF "! *** Perform eigenchannel analysis with Reduced Transmission Matrix\n";
print OUTF "!     from atom# REDTRANSMB to atom# REDTRANSME\n";
print OUTF "!\n";
print OUTF "!  RTM_BEG = 14\n";
print OUTF "!  RTM_END = 14\n\n";


###############################################################################################





exit;
