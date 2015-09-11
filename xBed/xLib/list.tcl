#------- keep here as a 80-character reference line to check text width -------#

proc list.shuffle10 { 
    {list "0 1 2 3 4 5"}
     {ABOUT "This proc takes a list and returns a randomly permuted list.
      As per tests under http://wiki.tcl.tk/941, it seems to be a winner."} } {

    set len [llength $list]
    set len2 $len
    #puts list=$list
    for {set i 0} {$i < $len-1} {incr i} {
        set n [expr {int($i + $len2 * rand())}]
        incr len2 -1

        # Swap elements at i & n
        set temp [lindex $list $i]
        #puts i=$i...n=$n...temp=$temp
        lset list $i [lindex $list $n]
        #puts list=$list
        lset list $n $temp
        #puts list=$list
    }
    return $list

#~dd
# as shuffle10 from http://wiki.tcl.tk/941
# KPV: Here's an unbiased version that uses lset.
# shown to be significantly faster than all other shuffles ....!!!!
#
# % list.shuffle10 "1 2 3 4"
# list=1 2 3 4
# i=0...n=1...temp=1
# list=2 2 3 4
# list=2 1 3 4
# i=1...n=1...temp=1
# list=2 1 3 4
# list=2 1 3 4
# i=2...n=2...temp=3
# list=2 1 3 4
# list=2 1 3 4
# 2 1 3 4
#
# % list.shuffle10 "1 2 3 4"
# list=1 2 3 4
# i=0...n=2...temp=1
# list=3 2 3 4
# list=3 2 1 4
# i=1...n=3...temp=2
# list=3 4 1 4
# list=3 4 1 2
# i=2...n=3...temp=1
# list=3 4 2 2
# list=3 4 2 1
# 3 4 2 1
# %
#~dd
} ;# list.shuffle10

proc list.reverse {
    {vList "a b c 0 1 2"}
    {ABOUT "This proc takes a list and returns it in the reversed order"} } {

    set rList {}
    for {set i 0} {$i < [llength $vList]} {incr i} {
        lappend rList [lindex $vList end-$i]
    }
    return $rList
#~dd
#     % list.reverse
#     2 1 0 c b a
#~dd
} ;# list.reverse

proc list.swap.forD1 { 
    {refL "1 2 3 4 5"}
     {ABOUT "This proc takes a reference list L objects and returns L-1 
     permutations of these objects, each with permutation distance = 1
     from the reference list."} } {

    set swapList {}
    set Lm1 [expr {[llength $refL] - 1}]
    set tmp1 [lindex $refL 0]
    for {set i 0} {$i < $Lm1} {incr i} {
        set i1 $i ; set i2 [expr {$i + 1}]
        set swapL $refL
        # swap elements at i1 & i2
        set tmp2 [lindex $refL $i2]
        lset swapL $i1 $tmp2
        #puts \ni1,i2,swapL=$i1,$i2,$swapL
        lset swapL $i2 $tmp1
        #puts i1,i2,swapL=$i1,$i2,$swapL
        set tmp1 [lindex $refL $i2]
        lappend swapList $swapL
    }
    return $swapList
#~dd 
# % list.swap.forD1 "1 2 3 4 5"
# {2 1 3 4 5} {1 3 2 4 5} {1 2 4 3 5} {1 2 3 5 4}
# 
# % list.swap.forD1 "2 4 1 5 3"
# {4 2 1 5 3} {2 1 4 5 3} {2 4 5 1 3} {2 4 1 3 5}
# %    
# Copyright:
# Franc Brglez, Thu Nov 28 00:18:09 EST 2013
#~dd 
} ;# list.swap.forD1