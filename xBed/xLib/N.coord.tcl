# thisFile = N.coord.tcl
#
# Copyright:
# Franc Brglez, Sun Jun 22 10:37:22 EDT 2014
#
#------- keep here as a 80-character reference line to check text width -------#

proc N.coord.rand {
    {N      4}
    {nDim  20}
    {ABOUT "This proc take the dimension number (nDim) and returns
    a N-ary coordinate (coordType = N) of length nDim."} } {
      
    set thisProc N.coord.rand
    # NOTE from tests beloe: for a given random coord of length nDim, 
    # the coord weight and coord runs are random variables. 
    for {set i 0} {$i < $nDim} {incr i} {
        append coord [expr {int(0.5 + ($N-1)*rand())}],
    }
    return [string trimright $coord ,]
#~dd 
# 
# % set init [expr {srand(123)}]
# 0.0009626434189093501
# 
# % N.coord.rand 4 20
# 1,3,1,2,3,2,2,2,3,1,3,1,1,2,0,2,3,0,1,1
# 
# % N.coord.rand 4 20
# 1,1,1,0,2,1,1,1,1,3,2,1,3,2,1,2,0,3,3,1
# 
# % N.coord.rand 5 40
# 3,4,3,1,4,3,3,2,3,1,3,1,3,1,2,3,2,3,2,1,0,2,1,1,3,3,1,2,0,2,1,0,2,1,1,3,1,3,3,3
# 
# % N.coord.rand 5 40
# 2,4,3,3,2,2,1,4,1,3,3,1,1,3,0,3,2,1,0,0,2,1,4,4,1,3,0,3,1,2,0,1,2,3,2,3,1,4,0,1
# % 
# Copyright: 
# Franc Brglez, Sat Jun 21 17:23:52 EDT 2014
#~dd 
} ;# N.coord.rand

proc N.coord.is { 
    {N      4}
    {coordN "2,1,3,1,1,1,2,1,0,0"} } {

    set coordN [split $coordN ","]
    set coordSize [llength $coordN]  
    for {set i 0} {$i < $coordSize} {incr i} { 
        set val [lindex $coordN $i]
        if {$val < 0 || $val > [expr {$N - 1}]} {
            return FALSE
        } 
    }
    return TRUE
#~dd 
# % N.coord.is 4 "2,1,3,1,1,1,2,1,0,0"
# TRUE
# 
# % N.coord.is 4 "2,1,3,1,1,1,2,1,0,5"
# FALSE
# 
# % N.coord.is 4 "2,1,2,1,1,1,2,1,0,2"
# TRUE
# % 
# Copyright:
# Franc Brglez, Sat Jun 21 17:23:52 EDT 2014
#~dd
} ;# N.coord.is 


proc N.coord.runs { 
    {coordN "0,1,2,3,2"} 
    {ABOUT "This procedure returns the runs value
    of a N-ary coordinate."} } {

    set coordN [split $coordN ","]
    set L      [llength $coordN]  
    set runs 1 ; set vPrev [lindex $coordN 0] 
    
    for {set j 0} {$j < $L} {incr j} {
        set v [lindex $coordN $j]
        if {$v != $vPrev} {incr runs}
        set vPrev $v
    }
    return $runs
#~dd 
# % N.coord.runs 3,3,3,3,3
# 1
# % N.coord.runs 0,1,2,3,3
# 4
# % N.coord.runs 0,1,2,3,2
# 5
# % N.coord.runs 0,1,2,3,0
# 5
# % 
# Copyright:
# Franc Brglez, Sun Jun 22 10:50:48 EDT 2014
#~dd
} ;# N.coord.runs


proc N.coord.rank { 
    {coordN "0,1,2,3,2"} 
    {ABOUT "This procedure returns the rank of a N-ary
    coordinate. This value is equivalent to distance
    between 0,0,0,...,0,0 and coordN"} } {

    set coordN [split $coordN ","]
    set L      [llength $coordN]  
    set rank 0       
    for {set j 0} {$j < $L} {incr j} {
        set v [lindex $coordN $j]
        set rank [expr {$rank + $v}]
    }
    return $rank 
#~dd 
# % N.coord.rank 0,1,2,3,2
# 8
# % N.coord.rank 0,1,2,3,0
# 6
# % N.coord.rank 3,1,2,3,0
# 9
#
# Copyright:
# Franc Brglez, Sun Jun 22 10:59:57 EDT 2014
#~dd
} ;# N.coord.rank

proc N.coord.distance { 
    {coordL "0,0,0,0,0"} 
    {coordR "3,3,3,3,3"} 
    {ABOUT "This procedure returns the distance between
    two N-ary coordinates."} } {

    set thisProc N.coord.distance
    set coordL [split $coordL ,] 
    set coordR [split $coordR ,]
    set L      [llength $coordL]
    if {$L != [llength $coordR]} {
        error "\nERROR from $thisProc ... unequal length strings: $L vs\
          [llength $coordR]\
          \n$coordL\n$coordR"
    }
    set dist 0
    for {set j 0} {$j < $L} {incr j} {
        set vL [lindex $coordL $j]
        set vR [lindex $coordR $j]
        set dist [expr {$dist + abs($vL - $vR)}]
    }
    return $dist 
#~dd 
# % N.coord.distance 0,0,0,0,0 3,3,3,3,3
# 15
# % N.coord.distance 2,1,3,1,1,1,2,1,0,0 2,1,2,1,1,1,2,1,0,2
# 3
# % N.coord.distance 2,1,3,1,1,1,2,1,0,0 2,1,2,1,1,1,2,1,0,0
# 1
# % N.coord.distance 2,1,3,1,1,1,2,1,0,0 2,1,3,1,1,1,2,1,0,0
# 0
# % N.coord.distance 2,1,3,1,1,1,2,1,0,0 2,1,3,1,1,1,2,0,0,0
# 1
# % N.coord.distance 2,1,3,1,1,1,2,1,0,0 2,1,3,1,1,1,2,2,0,0
# 1
# % N.coord.distance 2,1,3,1,1,1,2,1,0,0 2,1,3,1,1,1,2,3,0,0
# 2
#
# Copyright:
# Franc Brglez, Sun Jun 22 10:37:22 EDT 2014
#~dd
} ;# N.coord.distance

proc N.coord.list.gray {
    {coordRef 0,1,2}   
    {ABOUT "This procedure returns an exhaustive set of N-valued coordinates 
    in the 'gray' sequence wrt to the specified (reference) coordinate 
    coordRef."} } {
        
    set thisProc N.coord.list.gray
    set coordType "N"
    # This code extracted from "old" generic procedure 'dice.coord.gray'
    # I don't really understand it anymore -- comments are needed ...
    set traceIsOn 0
    set L [llength [split $coordRef ,]] 
    set radix $L ; set sizeMax [expr {int(pow($radix,$L))}]  
    for {set j 0} {$j < $L} {incr j} {
        set period($j) [expr {int(pow($radix,$j+1))}]
    }
    if {$traceIsOn} {parray period ;# return}
    for {set j 0} {$j < $L} {incr j} {
        for {set i 0} {$i < $period($j)} {incr i} {
            set idx [expr {int($i*$radix/$period($j)) % $radix}]
            lappend dnAry($j) $idx 
        }
    }
    if {$traceIsOn} {parray dnAry}
    for {set j 0} {$j < $L} {incr j} {             
        set col($j) {}
        for {set repeat 0} {$repeat < $sizeMax} {incr repeat} {
            set col($j) [concat $col($j) $dnAry($j)]
            if {[llength $col($j)] == $sizeMax} {break}
            set col($j) [concat $col($j) [list.reverse  $dnAry($j)]]
            if {[llength $col($j)] == $sizeMax} {break}
        }
    }
    if {$traceIsOn} {parray col ;# return}
    for {set i 0} {$i < $sizeMax} {incr i} {
        set coord {}
        for {set j 0} {$j < $L} {incr j} {                    
            set idx  [lindex $col($j) $i]
            append  coord $idx,
        }
        set coord [string trimright $coord ","]
        lappend coordList $coord
    }
    if {$traceIsOn} {
        puts "\ncoordList ... coordType=$coordType, nVar=$L ... \
          sizeMax=[llength $coordList]\
          \n[join $coordList \n] "
        puts "\ncoordList ... coordType=$coordType, nVar=$L ... \
          sizeMax=[llength $coordList]"
        return
    }
    set idx [lsearch -exact $coordList $coordRef]
    if {$idx < 0} {
        error "ERROR ... $coordRef not found in coordList\n"
    } elseif {$idx == 0} {
        set coordListR $coordList
    } else {
        set coordListR [concat \
          [lrange $coordList $idx end] [lrange $coordList 0 [expr {$idx - 1}]]]
    }
    if {[llength $coordList] != $sizeMax} {
        error "\nERROR ... length of coordList = [llength $coordList],\
          expected length = $sizeMax\n"
    } else {
        puts "** from $thisProc **\
          \n.. created coordList in gray sequence, starting at $coordRef\
          \n   coordType=$coordType, nVar=$L, listLength=[llength $coordList]"
    }
    return $coordListR
#~dd
# % N.coord.list.gray 0,1,2
# ** from N.coord.list.gray ** 
# .. created coordList in gray sequence, starting at 0,1,2 
#    coordType=N, nVar=3, listLength=27
# 0,1,2 0,2,2 1,2,2 2,2,2 0,0,0 1,0,0 2,0,0 2,1,0 1,1,0 0,1,0 0,2,0 1,2,0 2,2,0 2,2,1 1,2,1 0,2,1 
# 0,1,1 1,1,1 2,1,1 2,0,1 1,0,1 0,0,1 0,0,2 1,0,2 2,0,2 2,1,2 1,1,2
# 
# % N.coord.list.gray 0,1,2,3
# ** from N.coord.list.gray ** 
# .. created coordList in gray sequence, starting at 0,1,2,3 
#    coordType=T, nVar=4, listLength=256
#    
# % N.coord.list.gray 0,1,2,3,4
# ** from N.coord.list.gray ** 
# .. created coordList in gray sequence, starting at 0,1,2,3,4 
#    coordType=T, nVar=5, listLength=3125
# 
# % N.coord.list.gray 0,1,2,3,4,5
# ** from N.coord.list.gray ** 
# .. created coordList in gray sequence, starting at 0,1,2,3,4,5 
#    coordType=T, nVar=6, listLength=46656
# % 
# Copyright:
# Franc Brglez, Sat Jun 21 17:23:52 EDT 2014
#~dd   
} ;# N.coord.list.gray