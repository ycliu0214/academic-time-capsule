#!/usr/bin/env python

cat << EOF > temp.vmd
set startDcdFrame 0
set endDcdFrame 1000
set stepFrame 1

mol new ../ionized.psf type psf first 0 last -1 step 1 waitfor all
mol addfile ../s3_equi_out.dcd type dcd first \$startDcdFrame last \$endDcdFrame step \$stepFrame waitfor all

set macroMole "(protein or nucleic) and noh"
set water [atomselect top "(same residue as water within 4.0 of \$macroMole) and name OH2" frame 0]
set surface [atomselect top "protein within 4.0 of index [\$water get index]" frame 0]
set gridSize 1.0

set output [open "rgyrFiles/set_0.dat" w]
namespace import ::tcl::mathfunc::*
foreach index [\$surface get index] {
    set rg_list {}
    set tarSur [atomselect top "index \$index"]
    set init_x [round [expr [\$tarSur get x] / \$gridSize]]
    set init_y [round [expr [\$tarSur get y] / \$gridSize]]
    set init_z [round [expr [\$tarSur get z] / \$gridSize]]
    set init_coord "\${init_x}_\${init_y}_\${init_z}"
    set target [atomselect top "protein within 4.0 of index \$index" frame 0]
    for {set i 0} {\$i < [molinfo top get numframes]} {incr i 1} {
        \$target frame \$i
        lappend rg_list [measure rgyr \$target weight mass]
    }
    puts \$output "\$init_coord [expr ([join \$rg_list +])/[llength \$rg_list]]"
    unset target
    unset rg_list
}

close \$output

exit 0
EOF


if [ ! -d rgyrFiles ]; then
    mkdir rgyrFiles
fi

for i in {0..244}
do
    echo "run $(($i * 200)) to $(($i * 200 + 1100))"
    sed -i "1c set startDcdFrame $(($i * 200))" temp.vmd
    sed -i "2c set endDcdFrame $(($i * 200 + 1100))" temp.vmd
    sed -i "13c set output [open \"rgyrFiles/set_$(($i + 1)).dat\" w]" temp.vmd
    vmd -dispdev text -e temp.vmd >/dev/null 2>&1
    #vmd -dispdev text -e temp.vmd
    #vmd -dispdev text -e temp_s1.tcl
    echo "done $(($i * 200)) to $(($i * 200 + 1100))"
done

rm temp.vmd
