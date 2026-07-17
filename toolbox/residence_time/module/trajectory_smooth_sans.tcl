# SMOOTHING A TRAJECTORY
#---------------------------
# sliding_avg_pos $atomSel1 $atomSel2 $halfWidth $file $firstframe $lastframe 

# examples:
# set psfFile TT.H.psf
# set dcdFile F1601.dcd
# 
# mol new $psfFile type psf waitfor all
# mol addfile $dcdFile type dcd waitfor all
# mol new $psfFile type psf waitfor all
# mol addfile $dcdFile type dcd waitfor all
# 
# set atomSel1 [atomselect 0 "protein"]
# set atomSel2 [atomselect 1 "protein"]
# sliding_avg_pos $atomSel1 $atomSel2 2 avg_win9.dcd 0 1000
# sliding_avg_pos $atomSel1 $atomSel2 1 avg_win9.dcd 200 205

proc sliding_avg_pos {atomSel1 atomSel2 halfWidth outDCD first last} {
  set mol1 [$atomSel1 molid]
  set mol2 [$atomSel2 molid]
  set frameNum [molinfo $mol1 get numframes]
  set lastF [expr $frameNum - 1]

  if { $halfWidth < 1} {
    puts "the half of window width (${halfWidth}) should be larger or equal to 1"
    return -1
  }
  if {$first < 0} {
    puts "the index of first frame (${first} (start from 0)) should larger of equal to 0"
    return -2
  }
  if {$last >= $frameNum} {
    puts "the index of last frame (${last} (start from 0)) should be smaller than frame number (${frameNum})"
    return -3
  }

  if {$first != 0 || $last != $lastF} {
    animate delete beg [expr $last - $first + 1] end $lastF $mol2
  }

  # initialize vector $sum
  set zerolist ""
  for {set i(0) 0} {$i(0) < [$atomSel1 num]} {incr i(0) 1} {
    lappend zerolist {0 0 0}
  }
  set sum $zerolist

  set frameNumInWin [expr $halfWidth + $halfWidth + 1]
  set scale [expr 1.0 / $frameNumInWin]
  # first frame
  set j 0
  puts -nonewline "$j "
  set i(0) $first
  ## first frame, center
  $atomSel1 frame i(0)
  set coors [$atomSel1 get {x y z}]
  set sum $coors
  ## first frame, left
  for {set i(1) 0; set i(2) [expr $halfWidth - $i(0)]} {$i(1) < $i(2)} {incr i(1) 1} {
    $atomSel1 frame 0
    set coors [$atomSel1 get {x y z}]
    set tmplist ""
    foreach coor $coors coorInSum $sum {
      lappend tmplist [vecadd $coorInSum $coor]
    }
    set sum $tmplist
  }

  if {$i(0) <= $halfWidth} {
    set i(1) 0
  } else {
    set i(1) [expr $i(0) - $halfWidth]
  }
  for {set i(2) $i(0)} {$i(1) < $i(2)} {incr i(1) 1} {
    $atomSel1 frame $i(1)
    set coors [$atomSel1 get {x y z}]
    set tmplist ""
    foreach coor $coors coorInSum $sum {
      lappend tmplist [vecadd $coorInSum $coor]
    }
    set sum $tmplist
  }

  ## first frame, right
  set rightLength [expr $lastF - $i(0)]
  for {set i(1) 0; set i(2) [expr $halfWidth - $rightLength]} {$i(1) < $i(2)} {incr i(1) 1} {
    $atomSel1 frame $lastF
    set coors [$atomSel1 get {x y z}]
    set tmplist ""
    foreach coor $coors coorInSum $sum {
      lappend tmplist [vecadd $coorInSum $coor]
    }
    set sum $tmplist
  }

  if {$rightLength <= $halfWidth} {
    set i(2) $lastF
  } else {
    set i(2) [expr $i(0) + $halfWidth]
  }
  for {set i(1) [expr $i(0) + 1]} {$i(1) <= $i(2)} {incr i(1) 1} {
    $atomSel1 frame $i(1)
    set coors [$atomSel1 get {x y z}]
    set tmplist ""
    foreach coor $coors coorInSum $sum {
      lappend tmplist [vecadd $coorInSum $coor]
    }
    set sum $tmplist
  }
  #finish sum of first frame

  set avgCoors ""
  foreach coors $sum {
    lappend avgCoors [vecscale $coors $scale]
  }
  $atomSel2 frame $j
  $atomSel2 set {x y z} $avgCoors

  # other frames
  for {incr i(0) 1} {$i(0) <= $last} {incr i(0) 1} {
    incr j 1
    puts -nonewline "$j "
    ## other frames, subtracte one in left
    if {$i(0) <= $halfWidth} {
      $atomSel1 frame 0
      set coors [$atomSel1 get {x y z}]
      set tmplist ""
      foreach coor $coors coorInSum $sum {
        lappend tmplist [vecsub $coorInSum $coor]
      }
      set sum $tmplist
    } else {
      $atomSel1 frame [expr $i(0) - $halfWidth - 1]
      set coors [$atomSel1 get {x y z}]
      set tmplist ""
      foreach coor $coors coorInSum $sum {
        lappend tmplist [vecsub $coorInSum $coor]
      }
      set sum $tmplist
    }

    ## other frames, add one in right
    set maxRight [expr $i(0) + $halfWidth] 
    if {$maxRight > $last} {
      $atomSel1 frame $last
      set coors [$atomSel1 get {x y z}]
      set tmplist ""
      foreach coor $coors coorInSum $sum {
        lappend tmplist [vecadd $coorInSum $coor]
      }
      set sum $tmplist
    } else {
      $atomSel1 frame $maxRight
      set coors [$atomSel1 get {x y z}]
      set tmplist ""
      foreach coor $coors coorInSum $sum {
        lappend tmplist [vecadd $coorInSum $coor]
      }
      set sum $tmplist
    }

    set avgCoors ""
    foreach coors $sum {
      lappend avgCoors [vecscale $coors $scale]
    }
    $atomSel2 frame $j
    $atomSel2 set {x y z} $avgCoors
  }

  animate write dcd $outDCD beg 0 end $j waitfor all $mol2
  puts " avg DCD file is generated"
}
