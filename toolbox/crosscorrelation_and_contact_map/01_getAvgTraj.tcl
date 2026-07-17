#set psfFile "../../dcd/tmd_500ps/oxy_patched.psf"
#set dcdFile "../../dcd/tmd_500ps/tmd.dcd"
#set halfWidth4smooth 100
#set repeatNum 1
#set outDCD_filePrefix "avg"
#set avgSel "all"


source "setting/01_setting_file.txt"

set start 0

mol new $psfFile type psf first $startDcdFrame last $endDcdFrame step $stepFrame filebonds 1 autobonds 1 waitfor all
mol addfile $dcdFile type dcd first $startDcdFrame last $endDcdFrame step $stepFrame filebonds 1 autobonds 1 waitfor all

source "source/get_sequence.tcl"

if {$bbAlign == "yes"} {
  set refSel [atomselect top "backbone and noh" frame 0]
  set compareSel [atomselect top "backbone and noh"]
  set moveSel [atomselect top "all"]
  set frameNum [molinfo 0 get numframes]
  for {set i 1} {$i < $frameNum} {incr i 1} {
    $compareSel frame $i
    $moveSel frame $i
    set moveMat [measure fit $compareSel $refSel]
    $moveSel move $moveMat
  }
}


mol new $psfFile type psf first $startDcdFrame last $endDcdFrame step $stepFrame filebonds 1 autobonds 1 waitfor all
mol addfile $dcdFile type dcd first $startDcdFrame last $endDcdFrame step $stepFrame filebonds 1 autobonds 1 waitfor all

if {$bbAlign == "yes"} {
  set refSel [atomselect top "backbone and noh" frame 0]
  set compareSel [atomselect top "backbone and noh"]
  set moveSel [atomselect top "all"]
  set frameNum [molinfo 0 get numframes]
  for {set i 1} {$i < $frameNum} {incr i 1} {
    $compareSel frame $i
    $moveSel frame $i
    set moveMat [measure fit $compareSel $refSel]
    $moveSel move $moveMat
  }
}


set atomSel1 [atomselect 0 "all"]
set atomSel2 [atomselect 1 "all"]

set frameNum [molinfo top get numframes]
set last [expr $frameNum - 1]


source "source/trajectory_smooth_sans.tcl"

for {set i 0} {$i < $repeatNum} {incr i 1} {
  puts "repeat $i"
  if {[expr $i % 2] == 0} {
    sliding_avg_pos $atomSel1 $atomSel2 $halfWidth4smooth "$outDCD_filePrefix${halfWidth4smooth}_F$frameNum.dcd" $start $last
  } else {
    sliding_avg_pos $atomSel2 $atomSel1 $halfWidth4smooth "$outDCD_filePrefix${halfWidth4smooth}_F$frameNum.dcd" $start $last
  }
}

set f [open "temporal_file/02_avgdcdFile_Name.txt" w]
puts $f "set avgdcdFile \"$outDCD_filePrefix${halfWidth4smooth}_F$frameNum.dcd\""
close $f

exit 0
