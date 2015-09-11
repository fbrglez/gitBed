#------- keep here as a 80-character reference line to check text width -------#


proc P.lop.genF { {instanceSize 8} {coordWeight 0.4} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.genF ; set sandbox P.lop
set ABOUT \
"
          $thisCmd  instanceSize
Example:  $thisCmd  10
         
The command $thisCmd takes the value of instanceSize  compatible the sandbox   
$sandbox and generates an instance filea named as i-${instanceSize}-genA-xx.txt.
The value of xx in the file name is determined dynamically during generation
and represents the maximum sum matrix elements above the diagonal under
an optimal ordering of matrix rows and columns.
"
    if {$instanceSize == "??"} { puts $ABOUT ; return }
    if {$instanceSize == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
  
    puts ".. processsing $thisCmd with instanceSize=$instanceSize"
    set L $instanceSize
    
    # create the first full row as the stem row
    set row1 [split [B.coord.rand $L $coordWeight] ""]
    lset row1 0 0
    lset row1 1 1
    lset row1 end 1
    #puts L=$L\nrow1=$row1 ; return
    
    # create the naturalOrderMatrix
    set sum 0
    for {set ii 0} {$ii < $L} {incr ii} {
	set i [expr {$ii + 1}]
	set row [lrange $row1 0 [expr {$L-1-$ii}]]
	set row [concat [string repeat "x " $ii] $row]
	#puts i=$i...row=$row
	#set mAry($i,$i) 0
	for {set jj $ii} {$jj < $L}  {incr jj} {
	    set j [expr {$jj + 1}]
	    if {$i == $j} {
		set mAry($i,$j) 0
	    } else {
		set elm      [lindex $row [expr {$jj}]]
		set sum      [expr {$sum + $elm}]
		set mAry($i,$j) $elm
		if {round(rand())} {
		    set tmp [expr {$elm - 1}]
		} else {
		    set tmp $elm
		}
                if {$tmp < 0} {set tmp 0}
                set mAry($j,$i) $tmp 
	    }
	}
    }
    # create rowLines
    set rowLines $L\n
    for {set i 1} {$i <= $L} {incr i} {
	set row {}
	for {set j 1} {$j <= $L} {incr j} {
	    lappend row  $mAry($i,$j)
	}
	append rowLines [join $row \t]\n
    }
    #puts naturalOrderMatrix\n$rowLines\n ;# return
  
    # get the permutation of coordinates at rankMid
    set rankMid [expr {int($L*($L - 1)/4.)}]
    set coordPerm [P.coord.rand_with_rank $instanceSize $rankMid]
    
    # permute the matrix rows and columns
    for {set i 1} {$i <= $L} {incr i} {
        set iP [lindex $coordPerm [expr {$i-1}]]
        for {set j 1} {$j <= $L} {incr j} {
            set jP [lindex $coordPerm [expr {$j-1}]]
            #puts $i,$iP...$j,$jP
            set pAry($i,$j) $mAry($iP,$jP)
        }
    } 
    # create rowLines
    set rowLines $L\n
    for {set i 1} {$i <= $L} {incr i} {
	set row {}
	for {set j 1} {$j <= $L} {incr j} {
	    lappend row  $pAry($i,$j)
	}
	append rowLines [join $row \t]\n
    }
    #puts permutedOrderMatrix\n$rowLines\n
    set instanceClass \
      [lindex [split $thisCmd .] end][expr {round(100*$coordWeight)}]
    set instanceFile i-${instanceSize}-${instanceClass}-${sum}.lop
    file.write $instanceFile $rowLines
    puts ".. created file $instanceFile\
      \n   under permutation = [join $coordPerm ,]"

#~dd

# 
# % P.lop.genD 24
# .. processsing P.lop.genD with instanceSize=24
# .. created file i-24-genD-144.lop 
#    under permutation = 17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,18,2,1,19,20,21,22,23,24
# % 
# Copyright: 
# Franc Brglez, Sat Aug  1 11:50:28 EDT 2015
#~dd 
} ;# P.lop.genF

#------- keep here as a 80-character reference line to check text width -------#

proc P.lop.genE { {instanceSize 8} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.genE ; set sandbox P.lop
set ABOUT \
"
          $thisCmd  instanceSize
Example:  $thisCmd  10
         
The command $thisCmd takes the value of instanceSize  compatible the sandbox   
$sandbox and generates an instance filea named as i-${instanceSize}-genA-xx.txt.
The value of xx in the file name is determined dynamically during generation
and represents the maximum sum matrix elements above the diagonal under
an optimal ordering of matrix rows and columns.
"
    if {$instanceSize == "??"} { puts $ABOUT ; return }
    if {$instanceSize == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
  
    puts ".. processsing $thisCmd with instanceSize=$instanceSize"
    set L $instanceSize
    
    # create the first full row as the stem row
    set row1 [split [B.coord.rand $L 0.5] ""]
    lset row1 0 0
    lset row1 1 1
    lset row1 end 1
    #puts L=$L\nrow1=$row1 ; return
    
    # create the naturalOrderMatrix
    set sum 0
    for {set ii 0} {$ii < $L} {incr ii} {
	set i [expr {$ii + 1}]
	set row [lrange $row1 0 [expr {$L-1-$ii}]]
	set row [concat [string repeat "x " $ii] $row]
	#puts i=$i...row=$row
	#set mAry($i,$i) 0
	for {set jj $ii} {$jj < $L}  {incr jj} {
	    set j [expr {$jj + 1}]
	    if {$i == $j} {
		set mAry($i,$j) 0
	    } else {
		set elm      [lindex $row [expr {$jj}]]
		set sum      [expr {$sum + $elm}]
		set mAry($i,$j) $elm
		if {round(rand())} {
		    set tmp [expr {$elm - 1}]
		} else {
		    set tmp $elm
		}
                if {$tmp < 0} {set tmp 0}
                set mAry($j,$i) $tmp 
	    }
	}
    }
    # create rowLines
    set rowLines $L\n
    for {set i 1} {$i <= $L} {incr i} {
	set row {}
	for {set j 1} {$j <= $L} {incr j} {
	    lappend row  $mAry($i,$j)
	}
	append rowLines [join $row \t]\n
    }
    #puts naturalOrderMatrix\n$rowLines\n ;# return
  
    # get the permutation of coordinates at rankMid
    set rankMid [expr {int($L*($L - 1)/4.)}]
    set coordPerm [P.coord.rand_with_rank $instanceSize $rankMid]
    
    # permute the matrix rows and columns
    for {set i 1} {$i <= $L} {incr i} {
        set iP [lindex $coordPerm [expr {$i-1}]]
        for {set j 1} {$j <= $L} {incr j} {
            set jP [lindex $coordPerm [expr {$j-1}]]
            #puts $i,$iP...$j,$jP
            set pAry($i,$j) $mAry($iP,$jP)
        }
    } 
    # create rowLines
    set rowLines $L\n
    for {set i 1} {$i <= $L} {incr i} {
	set row {}
	for {set j 1} {$j <= $L} {incr j} {
	    lappend row  $pAry($i,$j)
	}
	append rowLines [join $row \t]\n
    }
    #puts permutedOrderMatrix\n$rowLines\n
    set instanceClass [lindex [split $thisCmd .] end]
    set instanceFile i-${instanceSize}-${instanceClass}-${sum}.lop
    file.write $instanceFile $rowLines
    puts ".. created file $instanceFile\
      \n   under permutation = [join $coordPerm ,]"

#~dd
# % P.lop.genD 8
# .. processsing P.lop.genD with instanceSize=8
# naturalOrderMatrix
# 8
# 0	1	0	1	0	1	0	1
# 1	0	1	0	1	0	1	0
# 0	1	0	1	0	1	0	1
# 1	0	0	0	1	0	1	0
# 0	0	0	1	0	1	0	1
# 1	0	0	0	0	0	1	0
# 0	1	0	1	0	0	0	1
# 1	0	1	0	1	0	0	0
# permutedOrderMatrix
# 8
# 0	1	1	0	0	0	0	1
# 0	0	0	0	0	1	1	0
# 1	0	0	0	0	1	1	0
# 0	1	1	0	1	0	0	1
# 1	0	0	1	0	1	1	0
# 0	1	1	0	1	0	0	1
# 0	0	1	0	1	0	0	1
# 1	0	0	1	0	1	0	0
# .. created file i-8-genD-16.lop 
#    under permutation = 5,6,4,3,2,1,7,8
# % 
# 
# % P.lop.genD 24
# .. processsing P.lop.genD with instanceSize=24
# .. created file i-24-genD-144.lop 
#    under permutation = 17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,18,2,1,19,20,21,22,23,24
# % 
# Copyright: 
# Franc Brglez, Sat Aug  1 11:50:28 EDT 2015
#~dd 
} ;# P.lop.genE


proc P.lop.genD { {instanceSize 8} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.genD ; set sandbox P.lop
set ABOUT \
"
          $thisCmd  instanceSize
Example:  $thisCmd  10
         
The command $thisCmd takes the value of instanceSize  compatible the sandbox   
$sandbox and generates an instance filea named as i-${instanceSize}-genA-xx.txt.
The value of xx in the file name is determined dynamically during generation
and represents the maximum sum matrix elements above the diagonal under
an optimal ordering of matrix rows and columns.
"
    if {$instanceSize == "??"} { puts $ABOUT ; return }
    if {$instanceSize == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
  
    puts ".. processsing $thisCmd with instanceSize=$instanceSize"
    set L $instanceSize
    
    # create the first full row as the stem row
    for {set i 0} {$i < $L} {incr i} {
	if {$i % 2 == 0} {
	    lappend row1 0
	} elseif {$i % 2 == 1} {
	    lappend row1 1
	} 
    }
    #puts L=$L\nrow1=$row1 ; return
    
    # create the naturalOrderMatri
    set sum 0
    for {set ii 0} {$ii < $L} {incr ii} {
	set i [expr {$ii + 1}]
	set row [lrange $row1 0 [expr {$L-1-$ii}]]
	set row [concat [string repeat "x " $ii] $row]
	#puts i=$i...row=$row
	#set mAry($i,$i) 0
	for {set jj $ii} {$jj < $L}  {incr jj} {
	    set j [expr {$jj + 1}]
	    if {$i == $j} {
		set mAry($i,$j) 0
	    } else {
		set elm      [lindex $row [expr {$jj}]]
		set sum      [expr {$sum + $elm}]
		set mAry($i,$j) $elm
		if {round(rand())} {
		    set tmp [expr {$elm - 1}]
		} else {
		    set tmp $elm
		}
                if {$tmp < 0} {set tmp 0}
                set mAry($j,$i) $tmp 
	    }
	}
    }
    # create rowLines
    set rowLines $L\n
    for {set i 1} {$i <= $L} {incr i} {
	set row {}
	for {set j 1} {$j <= $L} {incr j} {
	    lappend row  $mAry($i,$j)
	}
	append rowLines [join $row \t]\n
    }
    #puts naturalOrderMatrix\n$rowLines\n ;# return
  
    # get the permutation of coordinates at rankMid
    set rankMid [expr {int($L*($L - 1)/4.)}]
    set coordPerm [P.coord.rand_with_rank $instanceSize $rankMid]
    
    # permute the matrix rows and columns
    for {set i 1} {$i <= $L} {incr i} {
        set iP [lindex $coordPerm [expr {$i-1}]]
        for {set j 1} {$j <= $L} {incr j} {
            set jP [lindex $coordPerm [expr {$j-1}]]
            #puts $i,$iP...$j,$jP
            set pAry($i,$j) $mAry($iP,$jP)
        }
    } 
    # create rowLines
    set rowLines $L\n
    for {set i 1} {$i <= $L} {incr i} {
	set row {}
	for {set j 1} {$j <= $L} {incr j} {
	    lappend row  $pAry($i,$j)
	}
	append rowLines [join $row \t]\n
    }
    #puts permutedOrderMatrix\n$rowLines\n
    set instanceClass [lindex [split $thisCmd .] end]
    set instanceFile i-${instanceSize}-${instanceClass}-${sum}.lop
    file.write $instanceFile $rowLines
    puts ".. created file $instanceFile\
      \n   under permutation = [join $coordPerm ,]"

#~dd
# % P.lop.genD 8
# .. processsing P.lop.genD with instanceSize=8
# naturalOrderMatrix
# 8
# 0	1	0	1	0	1	0	1
# 1	0	1	0	1	0	1	0
# 0	1	0	1	0	1	0	1
# 1	0	0	0	1	0	1	0
# 0	0	0	1	0	1	0	1
# 1	0	0	0	0	0	1	0
# 0	1	0	1	0	0	0	1
# 1	0	1	0	1	0	0	0
# permutedOrderMatrix
# 8
# 0	1	1	0	0	0	0	1
# 0	0	0	0	0	1	1	0
# 1	0	0	0	0	1	1	0
# 0	1	1	0	1	0	0	1
# 1	0	0	1	0	1	1	0
# 0	1	1	0	1	0	0	1
# 0	0	1	0	1	0	0	1
# 1	0	0	1	0	1	0	0
# .. created file i-8-genD-16.lop 
#    under permutation = 5,6,4,3,2,1,7,8
# % 
# 
# % P.lop.genD 24
# .. processsing P.lop.genD with instanceSize=24
# .. created file i-24-genD-144.lop 
#    under permutation = 17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,18,2,1,19,20,21,22,23,24
# % 
# Copyright: 
# Franc Brglez, Sat Aug  1 11:50:28 EDT 2015
#~dd 
} ;# P.lop.genD


#------- keep here as a 80-character reference line to check text width -------#

proc P.lop.genC { {instanceSize 8} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.genC ; set sandbox P.lop
set ABOUT \
"
          $thisCmd  instanceSize
Example:  $thisCmd  10
         
The command $thisCmd takes the value of instanceSize  compatible the sandbox   
$sandbox and generates an instance filea named as i-${instanceSize}-genA-xx.txt.
The value of xx in the file name is determined dynamically during generation
and represents the maximum sum matrix elements above the diagonal under
an optimal ordering of matrix rows and columns.
"
    if {$instanceSize == "??"} { puts $ABOUT ; return }
    if {$instanceSize == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
  
    puts ".. processsing $thisCmd with instanceSize=$instanceSize"
    set L $instanceSize
    
    # create the first full row as the stem row
    for {set i 0} {$i < $L} {incr i} {
	if {$i % 3 == 0} {
	    lappend row1 0
	} elseif {$i % 3 == 1} {
	    lappend row1 1
	} elseif {$i % 3 == 2} {
	    lappend row1 2
	}
    }
    #puts L=$L\nrow1=$row1 ; return
    
    # create the naturalOrderMatri
    set sum 0
    for {set ii 0} {$ii < $L} {incr ii} {
	set i [expr {$ii + 1}]
	set row [lrange $row1 0 [expr {$L-1-$ii}]]
	set row [concat [string repeat "x " $ii] $row]
	#puts i=$i...row=$row
	#set mAry($i,$i) 0
	for {set jj $ii} {$jj < $L}  {incr jj} {
	    set j [expr {$jj + 1}]
	    if {$i == $j} {
		set mAry($i,$j) 0
	    } else {
		set elm      [lindex $row [expr {$jj}]]
		set sum      [expr {$sum + $elm}]
		set mAry($i,$j) $elm
		if {round(rand())} {
		    set tmp [expr {$elm - 1}]
		} else {
		    set tmp $elm
		}
                if {$tmp < 0} {set tmp 0}
                set mAry($j,$i) $tmp 
	    }
	}
    }
    # create rowLines
    set rowLines $L\n
    for {set i 1} {$i <= $L} {incr i} {
	set row {}
	for {set j 1} {$j <= $L} {incr j} {
	    lappend row  $mAry($i,$j)
	}
	append rowLines [join $row \t]\n
    }
    #puts naturalOrderMatrix\n$rowLines\n ;# return
  
    # get the permutation of coordinates at rankMid
    set rankMid [expr {int($L*($L - 1)/4.)}]
    set coordPerm [P.coord.rand_with_rank $instanceSize $rankMid]
    
    # permute the matrix rows and columns
    for {set i 1} {$i <= $L} {incr i} {
        set iP [lindex $coordPerm [expr {$i-1}]]
        for {set j 1} {$j <= $L} {incr j} {
            set jP [lindex $coordPerm [expr {$j-1}]]
            #puts $i,$iP...$j,$jP
            set pAry($i,$j) $mAry($iP,$jP)
        }
    } 
    # create rowLines
    set rowLines $L\n
    for {set i 1} {$i <= $L} {incr i} {
	set row {}
	for {set j 1} {$j <= $L} {incr j} {
	    lappend row  $pAry($i,$j)
	}
	append rowLines [join $row \t]\n
    }
    #puts permutedOrderMatrix\n$rowLines\n
    set instanceClass [lindex [split $thisCmd .] end]
    set instanceFile i-${instanceSize}-${instanceClass}-${sum}.lop
    file.write $instanceFile $rowLines
    puts ".. created file $instanceFile"

#~dd
# % P.lop.genC 8
# .. processsing P.lop.genC with instanceSize=8
# naturalOrderMatrix
# 8
# 0	1	2	0	1	2	0	1
# 1	0	1	2	0	1	2	0
# 1	1	0	1	2	0	1	2
# 0	2	0	0	1	2	0	1
# 1	0	1	1	0	1	2	0
# 1	1	0	2	0	0	1	2
# 0	2	1	0	1	0	0	1
# 0	0	2	0	0	2	0	0
# permutedOrderMatrix
# 8
# 0	1	1	1	0	1	2	0
# 0	0	2	0	1	1	1	2
# 1	2	0	0	2	0	0	1
# 2	0	1	0	1	1	1	2
# 0	1	2	1	0	1	2	0
# 1	2	0	2	1	0	0	1
# 1	0	0	1	2	0	0	1
# 0	2	0	2	0	0	0	0
# .. created file i-8-genC-30.lop
# % 
# 
# % P.lop.genC 20
# .. processsing P.lop.genC with instanceSize=20
# .. created file i-20-genC-196.lop
# 
# % P.lop.genC 24
# .. processsing P.lop.genC with instanceSize=24
# .. created file i-24-genC-284.lop
# % 
# Copyright: 
# Franc Brglez, Sat Aug  1 11:50:28 EDT 2015
#~dd 
} ;# P.lop.genC

proc P.lop.genB { {instanceSize 8} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.genB ; set sandbox P.lop
set ABOUT \
"
          $thisCmd  instanceSize
Example:  $thisCmd  10
         
The command $thisCmd takes the value of instanceSize  compatible the sandbox   
$sandbox and generates an instance filea named as i-${instanceSize}-genA-xx.txt.
The value of xx in the file name is determined dynamically during generation
and represents the maximum sum matrix elements above the diagonal under
an optimal ordering of matrix rows and columns.
"
    if {$instanceSize == "??"} { puts $ABOUT ; return }
    if {$instanceSize == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
  
    puts ".. processsing $thisCmd with instanceSize=$instanceSize"
    
    set L $instanceSize
    set sum 0
    for {set i 1} {$i <= $L} {incr i} {
	
	for {set j $i} {$j <= $L}  {incr j} {
	    
	    if {$i == $j} {
		set mAry($i,$j) 0
	    } else {
		set elm      [expr {$j - $i}]
		set sum      [expr {$sum + $elm}]
		set mAry($i,$j) $elm
		set mAry($j,$i) [expr {$elm - 1}]
	    }
	}
    }
    # create rowLines
    set rowLines $L\n
    for {set i 1} {$i <= $L} {incr i} {
	set row {}
	for {set j 1} {$j <= $L} {incr j} {
	    lappend row  $mAry($i,$j)
	}
	append rowLines [join $row \t]\n
    }
    #puts naturalOrderMatrix\n$rowLines\n ;# return
    
    # get the permutation of coordinates at rankMid
    set rankMid [expr {int($L*($L - 1)/4.)}]
    set coordPerm [P.coord.rand_with_rank $instanceSize $rankMid]
    
    # permute the matrix rows and columns
    for {set i 1} {$i <= $L} {incr i} {
        set iP [lindex $coordPerm [expr {$i-1}]]
        for {set j 1} {$j <= $L} {incr j} {
            set jP [lindex $coordPerm [expr {$j-1}]]
            #puts $i,$iP...$j,$jP
            set pAry($i,$j) $mAry($iP,$jP)
        }
    } 
    # create rowLines
    set rowLines $L\n
    for {set i 1} {$i <= $L} {incr i} {
	set row {}
	for {set j 1} {$j <= $L} {incr j} {
	    lappend row  $pAry($i,$j)
	}
	append rowLines [join $row \t]\n
    }
    #puts permutedOrderMatrix\n$rowLines\n
    set instanceFile i-${instanceSize}-genB-${sum}.lop
    file.write $instanceFile $rowLines
    puts ".. created file $instanceFile"

#~dd
# % P.lop.genB 6
# .. processsing P.lop.genB with instanceSize=6
# naturalOrderMatrix
# 6
# 0	1	2	3	4	5
# 0	0	1	2	3	4
# 1	0	0	1	2	3
# 2	1	0	0	1	2
# 3	2	1	0	0	1
# 4	3	2	1	0	0
# 
# permutedOrderMatrix
# 6
# 0	0	1	1	2	2
# 1	0	0	2	1	3
# 2	1	0	3	0	4
# 0	1	2	0	3	1
# 3	2	1	4	0	5
# 1	2	3	0	4	0
# .. created file i-6-genA-35.lop
# 
# % P.lop.genB 20
# .. processsing P.lop.genB with instanceSize=20
# .. created file i-20-genA-1330.lop
# 
# % P.lop.genB 24
# .. processsing P.lop.genB with instanceSize=24
# .. created file i-24-genA-2300.lop
# % 
# Copyright: 
# Franc Brglez, Fri Jul 31 15:03:43 EDT 2015
#~dd 
} ;# P.lop.genB


proc P.lop.genA { {instanceSize 8} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.genA ; set sandbox P.lop
set ABOUT \
"
          $thisCmd  instanceSize
Example:  $thisCmd  10
         
The command $thisCmd takes the value of instanceSize  compatible the sandbox   
$sandbox and generates an instance filea named as i-${instanceSize}-genA-xx.txt.
The value of xx in the file name is determined dynamically during generation
and represents the maximum sum matrix elements above the diagonal under
an optimal ordering of matrix rows and columns.
"
    if {$instanceSize == "??"} { puts $ABOUT ; return }
    if {$instanceSize == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
  
    puts ".. processsing $thisCmd with instanceSize=$instanceSize"
    
    set L $instanceSize
    set sum 0
    for {set i 1} {$i <= $L} {incr i} {
	
	for {set j $i} {$j <= $L}  {incr j} {
	    
	    if {$i == $j} {
		set mAry($i,$j) 0
	    } else {
		set elm      [expr {$j - ($i - 1)}]
		set sum      [expr {$sum + $elm}]
		set mAry($i,$j) $elm
		set mAry($j,$i) [expr {$elm - 1}]
	    }
	}
    }
    # create rowLines
    set rowLines $L\n
    for {set i 1} {$i <= $L} {incr i} {
	set row {}
	for {set j 1} {$j <= $L} {incr j} {
	    lappend row  $mAry($i,$j)
	}
	append rowLines [join $row \t]\n
    }
    #puts naturalOrderMatrix\n$rowLines\n
    
    # get the permutation of coordinates at rankMid
    set rankMid [expr {int($L*($L - 1)/4.)}]
    set coordPerm [P.coord.rand_with_rank $instanceSize $rankMid]
    
    # permute the matrix rows and columns
    for {set i 1} {$i <= $L} {incr i} {
        set iP [lindex $coordPerm [expr {$i-1}]]
        for {set j 1} {$j <= $L} {incr j} {
            set jP [lindex $coordPerm [expr {$j-1}]]
            #puts $i,$iP...$j,$jP
            set pAry($i,$j) $mAry($iP,$jP)
        }
    } 
    # create rowLines
    set rowLines $L\n
    for {set i 1} {$i <= $L} {incr i} {
	set row {}
	for {set j 1} {$j <= $L} {incr j} {
	    lappend row  $pAry($i,$j)
	}
	append rowLines [join $row \t]\n
    }
    #puts permutedOrderMatrix\n$rowLines\n
    set instanceFile i-${instanceSize}-genA-${sum}.lop
    file.write $instanceFile $rowLines
    puts ".. created file $instanceFile"
    
#~dd
# % P.lop.genA 8
# .. processsing P.lop.genA with instanceSize=8
# naturalOrderMatrix
# 8
# 0	2	3	4	5	6	7	8
# 1	0	2	3	4	5	6	7
# 2	1	0	2	3	4	5	6
# 3	2	1	0	2	3	4	5
# 4	3	2	1	0	2	3	4
# 5	4	3	2	1	0	2	3
# 6	5	4	3	2	1	0	2
# 7	6	5	4	3	2	1	0
# 
# permutedOrderMatrix
# 8
# 0	2	1	2	3	4	3	4
# 1	0	2	3	4	5	2	3
# 2	3	0	1	2	3	4	5
# 3	4	2	0	1	2	5	6
# 4	5	3	2	0	1	6	7
# 5	6	4	3	2	0	7	8
# 2	1	3	4	5	6	0	2
# 3	2	4	5	6	7	1	0
# .. created file i-8-genA-112.lop
# % 
# % P.lop.genA 20
# .. processsing P.lop.genA with instanceSize=20
# .. created file i-20-genA-1520.lop
# 
# % P.lop.genA 24
# .. processsing P.lop.genA with instanceSize=24
# .. created file i-24-genA-2576.lop
# % 
# Copyright: 
# Franc Brglez, Fri Jul 31 15:03:43 EDT 2015
#~dd 
} ;# P.lop.genA
		
