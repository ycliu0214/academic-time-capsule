#!/usr/bin/env bash


cat << EOF > temp_s1.tcl
set psfName "../ionized.psf"
set dcdName "../s3_equi_out.dcd"
set halfWidth4smooth 50
set startDcdFrame 0
set endDcdFrame 1000
set stepFrame 1
set repeatNum 1
set outDCD_filePrefix "avg"
set avgSel "all"

mol new \$psfName type psf first 0 last -1 step 1 waitfor all
mol addfile \$dcdName type dcd first \$startDcdFrame last \$endDcdFrame step \$stepFrame waitfor all

mol new \$psfName type psf first 0 last -1 step 1 waitfor all
mol addfile \$dcdName type dcd first \$startDcdFrame last \$endDcdFrame step \$stepFrame waitfor all

source "module/trajectory_smooth_sans.tcl"

set atomSel1 [atomselect 0 "all"]
set atomSel2 [atomselect 1 "all"]


set start 0
set frameNum [molinfo top get numframes]
set last [expr \$frameNum - 1]

for {set i 0} {\$i < \$repeatNum} {incr i 1} {
  puts "repeat \$i"
  if {[expr \$i % 2] == 0} {
    sliding_avg_pos \$atomSel1 \$atomSel2 \$halfWidth4smooth "\$outDCD_filePrefix\${halfWidth4smooth}_F\$frameNum.dcd" \$start \$last
  } else {
    sliding_avg_pos \$atomSel2 \$atomSel1 \$halfWidth4smooth "\$outDCD_filePrefix\${halfWidth4smooth}_F\$frameNum.dcd" \$start \$last
  }
}

exit 0
EOF

cat << EOF > temp_s2.tcl
set psfName "../ionized.psf"
set dcdName "../s3_equi_out.dcd"
set halfWidth4smooth 50
set startDcdFrame 0
set endDcdFrame 1000
set stepFrame 1
set repeatNum 1
set outDCD_filePrefix "avg"
set avgSel "all"
set gridSize 1
set shift_criteria 2.8

set start \${halfWidth4smooth}
set last [expr \$endDcdFrame - \$startDcdFrame - \${halfWidth4smooth} - 1]

set frameNum [expr (\${endDcdFrame} - \$startDcdFrame + 1) / \${stepFrame}]

mol new \$psfName type psf first 0 last -1 step 1 waitfor all
mol addfile \$outDCD_filePrefix\${halfWidth4smooth}_F\$frameNum.dcd type dcd first \$start last \$last step 1 waitfor all

set macroMole "(protein or nucleic) and noh"
set water [atomselect top "(same residue as water within 4 of \$macroMole) and name OH2" frame 0]

set output [open "coordFiles/set_0.dat" w]
namespace import ::tcl::mathfunc::*
foreach index [\$water get index] {
    set target [atomselect top "index \$index"]
    \$target frame 0
    set coor_x [\$target get x]
    set coor_y [\$target get y]
    set coor_z [\$target get z]
    set init_x [round [expr [\$target get x] / \$gridSize]]
    set init_y [round [expr [\$target get y] / \$gridSize]]
    set init_z [round [expr [\$target get z] / \$gridSize]]
    set init_coord "\${init_x}_\${init_y}_\${init_z}"
    set time_count [molinfo top get numframes]
    for {set i 1} {\$i < [molinfo top get numframes]} {incr i 1} {
        \$target frame \$i
        set now_x [\$target get x]
        set now_y [\$target get y]
        set now_z [\$target get z]
        set coor_shift [expr ((\$coor_x - \$now_x)**2 + (\$coor_y - \$now_y)**2 + (\$coor_z - \$now_z)**2)**0.5]
        if {\$coor_shift > \$shift_criteria} {
            set time_count \$i
            break
        }
    }
    puts \$output "\$init_coord \$time_count"
    unset target
}
close \$output

exit 0
EOF

if [ ! -d coordFiles ]; then
    mkdir coordFiles
fi

#for i in {0..244}
for i in {130..244}
do
    echo "run $(($i * 200)) to $(($i * 200 + 1100))"
    sed -i "4c set startDcdFrame $(($i * 200))" temp_s*.tcl
    sed -i "5c set endDcdFrame $(($i * 200 + 1100))" temp_s*.tcl
    sed -i "24c set output [open \"coordFiles/set_$(($i + 1)).dat\" w]" temp_s2.tcl
    vmd -dispdev text -e temp_s1.tcl >/dev/null 2>&1
    vmd -dispdev text -e temp_s2.tcl >/dev/null 2>&1
    #vmd -dispdev text -e temp_s1.tcl
    echo "done $(($i * 200)) to $(($i * 200 + 1100))"
done

rm temp_s1.tcl temp_s2.tcl
