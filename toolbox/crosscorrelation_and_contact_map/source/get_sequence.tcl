set OUTF [open "temporal_file/protein_sequence.txt" w]
set caSel [atomselect top "protein and name CA"]

set caSelSeg [$caSel get segname]
set caSelResi [$caSel get resid]

puts $OUTF "$caSelSeg"
puts $OUTF "$caSelResi"

$caSel delete

close $OUTF

exec perl source/sequence_transform.pl
