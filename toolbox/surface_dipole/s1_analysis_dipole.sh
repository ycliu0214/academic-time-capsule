#!/usr/bin/env python

cat << EOF > temp.vmd
set startDcdFrame 0
set endDcdFrame 1000
set stepFrame 1

mol new ../ionized.psf type psf first 0 last -1 step 1 waitfor all
mol addfile ../s3_equi_out.dcd type dcd first \$startDcdFrame last \$endDcdFrame step \$stepFrame waitfor all

set macroMole "(protein or nucleic) and noh"
set gridSize 1.0

set output [open "dipoleFiles/set_0.dat" w]
namespace import ::tcl::mathfunc::*
for {set i 0} {\$i < [molinfo top get numframes]} {incr i 1} {
    set molecule [atomselect top "\$macroMole" frame \$i]
    set molCenter [measure center \$molecule weight mass]
    set water [atomselect top "(same residue as water within 3.5 of \$macroMole) and name OH2" frame \$i]
    foreach index [\$water get index] {
        set tarWat [atomselect top "index \$index" frame \$i]
        set init_x [round [expr [\$tarWat get x] / \$gridSize]]
        set init_y [round [expr [\$tarWat get y] / \$gridSize]]
        set init_z [round [expr [\$tarWat get z] / \$gridSize]]
        set init_coord "\${init_x}_\${init_y}_\${init_z}"
        set tmpWat [atomselect top "same residue as index \$index" frame \$i]
        set dipole [vecnorm [measure dipole \$tmpWat]]
        set refVec [vecnorm [vecsub [measure center \$tmpWat weight mass] \$molCenter]]
        set dotResult [vecdot \$dipole \$refVec]
        puts \$output "\$init_coord \$dotResult"
        \$tarWat delete
        \$tmpWat delete
    }
    \$molecule delete
    \$water delete
}

close \$output

exit 0
EOF


if [ ! -d dipoleFiles ]; then
    mkdir dipoleFiles
fi

for i in {240..244}
do
    echo "run $(($i * 200)) to $(($i * 200 + 1100))"
    sed -i "1c set startDcdFrame $(($i * 200))" temp.vmd
    sed -i "2c set endDcdFrame $(($i * 200 + 1100))" temp.vmd
    sed -i "11c set output [open \"dipoleFiles/set_$(($i + 1)).dat\" w]" temp.vmd
    vmd -dispdev text -e temp.vmd >/dev/null 2>&1
    #vmd -dispdev text -e temp.vmd
    echo "done $(($i * 200)) to $(($i * 200 + 1100))"
done

rm temp.vmd
