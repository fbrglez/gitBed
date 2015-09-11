# thisFile = P.coord.tcl
#
# Most procedures, arguments, and returned values relate to 
# coordType = P (permutation coordinate).
#
# Copyright:
# Franc Brglez, Mon Jan 19 23:42:26 EST 2015
#
#------- keep here as a 80-character reference line to check text width -------#

proc P.coord.rank { {coord "4 1 2 3"} } {

#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.coord.rank
set ABOUT \
"This proc takes a permutation coordinate as a list such as **4 1 2 3** and
returns its inversion number, which can also be interpreted as the distance
from **1 2 3 4** or also as 'the rank' of the coordinate in the Hasse graph
with respect to its coordinate in natural order, here **1 2 3 4**."
    if {$coord == "??"} { puts $ABOUT ; return }
    if {$coord == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    # Standard definition for permutation inversion: given a permutation 
    # b_1, b_2, b_3,..., b_n of the n integers 1, 2, 3, ..., n, 
    # an inversion is a pair (b_i, b_j) where i < j and b_i > b_j.
    set inversion 0 ; set size [llength $coord]  
    for {set i 1} {$i < $size} {incr i} {
        set b_i [lindex $coord [expr {$i - 1}]]
        #puts i,b_i=$i,$b_i
        for {set j [expr {$i + 1}]} {$j <= $size} {incr j} {
            set b_j [lindex $coord [expr {$j - 1}]]
            #puts ..j,b_j=$i,$b_j
           if {$i < $j && $b_i > $b_j }  {
               incr inversion ;# puts inversion=$inversion
           }
       }
   }
   return $inversion
#~dd ... few tests
# % P.coord.rank "4 3 2 1"
# 6
# % P.coord.rank "4 1 2 3"
# 3
# % P.coord.rank "3 1 2 4"
# 2
# % P.coord.rank "4 1 2 3"
# 3
# % 
# Copyright: 
# Franc Brglez, Mon Jan 19 11:07:11 EST 2015
#~dd     
} ;# P.coord.rank

proc P.coord.distance { 
    {coord0 "3 1 2 4"} 
    {coord1 "4 1 2 3"}
    {ABOUT "This procedure takes two permutations such as **3 1 2 4** and
    **4 1 2 3** and returns the value of permutation distance, which is
    defined by the crossing number of edges in a two layer graph formed
    by the permutation at each layer. For details and a citation, see the
    example under the comments at the tail of this proc."} } {

#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.coord.distance
set ABOUT \
"This procedure takes two permutations such as **3 1 2 4** and **4 1 2 3**
and returns the value of permutation distance, which is defined by the 
crossing number of edges in a two layer graph formed by the permutation at 
each layer. This formulation is a special case of formulas introduced in 
the  article 
JOHN N. WARFIELD
Crossing Theory and Hierarchy Mapping
IEEE TRANSACTIONS ON SYSTEMS, MAN, AND CYBERNETICS, 
VOL. SMC-7, NO. 7, JuLY 1977, pp. 505--524"
    if {$coord0 == "??"} { puts $ABOUT ; return }
    if {$coord0 == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    # create a position indices of elements in one of the coordinates 
    set size [llength $coord1]
    for {set i 0} {$i < $size} {incr i} {set pos([lindex $coord0 $i]) $i}
    #parray pos ;# positions array 
    set distance 0
    foreach i $coord0 j $coord1 {
        set a_i $pos($i) ; set b_j $pos($j)
        #puts i,j...a_i,b_j=$i,$j...$a_i,$b_j
        foreach i1 $coord0 j1 $coord1 {
            set a_i1 $pos($i1) ; set b_j1 $pos($j1)
            #puts i,j...a_i,b_j=$i,$j...$a_i1,$b_j1
           if {$a_i1 > $a_i && $b_j1 < $b_j || $a_i1 < $a_i && $b_j1 > $b_j }  {
               incr distance ;# puts  distance=$distance
           }
       }
   }
   # the computed distance represents total number of edge crossings and
   # must be divided by 2
   return [expr {$distance/2}]
#~dd 
# NOTE: this calculation of the permutation distance is equivalent to computing
#       the crossing number of a 2-layer graph, where the edges in the graph 
#       connect coordinate  elements of permutation coord0 to coord1 as 
#       illustrated below.
#   coord0  coord1
# 0 "2"    "4"   
#      \  /   
#       \/
#       /\
#      /  \
# 1 "4"    "2"   
#          
#       
#        
#      
# 2 "1"    "3"   
#      \  /   
#       \/
#       /\
#      /  \ 
# 3 "3"    "1"   
# % P.coord.distance "2 4 1 3" "4 2 3 1"
# 2
# % P.coord.distance "4 2 3 1" "2 4 1 3"
# 2
# Formulation used here is the special case of formulas introduced in this article:   
#   JOHN N. WARFIELD
#   Crossing Theory and Hierarchy Mapping
#   IEEE TRANSACTIONS ON SYSTEMS, MAN, AND CYBERNETICS, 
#   VOL. SMC-7, NO. 7, JuLY 1977, pp. 505--524
#
# % P.coord.distance "3 1 2 4" "4 1 2 3"
# 5
# % P.coord.distance "1 2 3 4" "4 1 2 3"
# 3
# % P.coord.distance "3 1 2 4" "4 1 2 3"
# 5
# % P.coord.distance "2 4 1 3" "4 1 2 3"
# 2
# % P.coord.distance "4 3 2 1" "4 1 2 3"
# 3
#  P.coord.distance "1 3 2 4" "4 2 3 1"
# 6
# % P.coord.distance "2 1 4 3 6 5 8 7 9" "9 7 8 5 6 3 4 1 2"
# 36   <<== (9*8)/2
# % 
# Copyright: 
# Franc Brglez, Mon Jan 19 11:07:11 EST 2015
#~dd   
} ;# P.coord.distance

proc P.coord.is { {coord "3 1 2 4"} } {
        
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.coord.is
set ABOUT \
"This proc takes a permutation coordinate as a list such as **4 1 2 3** and
returns 1 if coordinate is a valid permutation and returns 0 otherwise."
    if {$coord == "??"} { puts $ABOUT ; return }
    if {$coord == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    if {$coord == "NA"} {return 0}
    set size    [llength $coord]
    set coord [lsort -integer -unique $coord]
    if {$size == [llength $coord]} {
        # coord is a valid permutation coordinate
        return 1
    } else {
        return 0
    }
#~dd 
# % P.coord.is "10 5 7 21 17 1 19 15 13 3 11 20 4 2 12 9 8 18 16 6 14"
# 1
# % P.coord.is "10 5 7 21 17 1 19 15 13 3 11 20 4 2 12 9 8 18 16 6 13"
# 0
# % 
# Copyright: 
# Franc Brglez, Mon Jan 19 15:45:04 EST 2015
#~dd 
} ;# P.coord.is 

proc P.coord.rand { {nDim 21} } {   
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.coord.rand
set ABOUT \
"This proc take the length of the permutation coordinate (nDim) and returns
a random permutation of coordinate (coordType = P) of specified length."
    if {$nDim == "??"} { puts $ABOUT ; return }
    if {$nDim == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    for {set i 1} {$i <= $nDim} {incr i} {lappend coord $i}
    set coord [list.shuffle10 $coord]
    return $coord 
#~dd 
# 
# % expr srand(123)
# 0.0009626434189093501
# % P.coord.rand 4
# 1 4 3 2
# % P.coord.rand 4
# 3 4 2 1
# % P.coord.rand 21
# 11 13 21 7 20 9 10 16 4 8 3 2 14 6 18 15 19 12 1 5 17
# % P.coord.rand 21
# 10 5 7 21 17 1 19 15 13 3 11 20 4 2 12 9 8 18 16 6 14
# % 
# Copyright: 
# Franc Brglez, Mon Jan 19 15:38:17 EST 2015
#~dd 
} ;# P.coord.rand

proc P.coord.rand_with_rank { {L 4} {rankTarget NA} } {   
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.coord.rand_with_rank ; set sandbox P.lop
set ABOUT \
"
          $thisCmd  coordLength rankTarget
Example:  $thisCmd  10          22
         
The command $thisCmd takes the value of coordLength  compatible with    
the sandbox $sandbox and the value of rankTarget. It returns a pseudo-random  
coordinate with the rank of rankTarget."
    if {$L == "??"} { puts $ABOUT ; return }
    if {$L == "?"}  { error "Valid query is '$thisProc ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    # define permutation coordinate with rank=0
    for {set i 1} {$i <= $L} {incr i} {lappend coordRef $i}
    
    set rankMax [expr {$L*($L - 1)/2}]
    set rankMid [expr {int($L*($L - 1)/4.)}]
    if {$rankTarget == "NA"} {
        set rankTarget $rankMid
    } elseif {$rankTarget > $rankMax && $rankTarget <= 0} {
        error "\nERROR from $thisCmd about rankTarget=$rankTarget\n\
          \n .. the value of rankTarget must be in the range [1, $rankMax]\n"
    }
    #puts ".. processsing $thisCmd\
      \ncoordLength=$L, rankTarget=$rankTarget, \
      rankMax=$rankMax, rankMid=$rankMid"

    # at each rank, make a selection of 'i,j' to reach next rank coordinate
    set inversion 0 ; set rank 0 ; set step 0 ; set coordPiv $coordRef
    while {$inversion < $rankTarget}   {
        incr rank
	set tmp $coordPiv ; set isRankNew 0
        #puts \ninversionTarget=$rank...coordPiv=$coordPiv...inv=$inversion
        # check coord neighbors, break on first neighbor with rank > inversion
	for {set ip 0} {$ip < $L-1} {incr ip} {
            set i $ip
	    set j [expr {$ip + 1}]
            #puts i=$i...j=$j
	    lset tmp $i [lindex $coordPiv $j]
	    lset tmp $j [lindex $coordPiv $i]
	    set inversion [P.coord.rank $tmp]
            #puts ip=$ip...$i,$j....coordNeighb=$tmp...inv=$inversion...rank=$rank
            if {$inversion == $rank} {
                set coordPiv $tmp ; incr step ; set isRankNew 1
		#puts ++step=$step...coordPiv=$coordPiv...coordRank=$inversion 
	    }
	    if {$isRankNew} {
                break
            } else {
                set tmp $coordPiv
            }
	}
    }
    return $coordPiv
#~dd 
# 
# % P.coord.rand_with_rank 4 3
# .. processsing P.coord.rand_with_rank 
# coordLength=4, rankTarget=3,  rankMax=6, rankMid=3 
# 
# inversionTarget=1...coordPiv=1 2 3 4...inv=0
# ++step=1...coordPiv=2 1 3 4...coordRank=1
# inversionTarget=2...coordPiv=2 1 3 4...inv=1
# ++step=2...coordPiv=2 3 1 4...coordRank=2
# inversionTarget=3...coordPiv=2 3 1 4...inv=2
# ++step=3...coordPiv=3 2 1 4...coordRank=3
# 3 2 1 4
# 
# % P.coord.rand_with_rank 4 6
# .. processsing P.coord.rand_with_rank 
# coordLength=4, rankTarget=6,  rankMax=6, rankMid=3 
# 
# inversionTarget=1...coordPiv=1 2 3 4...inv=0
# ++step=1...coordPiv=2 1 3 4...coordRank=1
# inversionTarget=2...coordPiv=2 1 3 4...inv=1
# ++step=2...coordPiv=2 3 1 4...coordRank=2
# inversionTarget=3...coordPiv=2 3 1 4...inv=2
# ++step=3...coordPiv=3 2 1 4...coordRank=3
# inversionTarget=4...coordPiv=3 2 1 4...inv=3
# ++step=4...coordPiv=3 2 4 1...coordRank=4
# inversionTarget=5...coordPiv=3 2 4 1...inv=4
# ++step=5...coordPiv=3 4 2 1...coordRank=5
# inversionTarget=6...coordPiv=3 4 2 1...inv=5
# ++step=6...coordPiv=4 3 2 1...coordRank=6
# 4 3 2 1
# 
# % P.coord.rand_with_rank 6 7
# .. processsing P.coord.rand_with_rank 
# coordLength=6, rankTarget=7,  rankMax=15, rankMid=7 
# 
# inversionTarget=1...coordPiv=1 2 3 4 5 6...inv=0
# ++step=1...coordPiv=2 1 3 4 5 6...coordRank=1
# inversionTarget=2...coordPiv=2 1 3 4 5 6...inv=1
# ++step=2...coordPiv=2 3 1 4 5 6...coordRank=2
# inversionTarget=3...coordPiv=2 3 1 4 5 6...inv=2
# ++step=3...coordPiv=3 2 1 4 5 6...coordRank=3
# inversionTarget=4...coordPiv=3 2 1 4 5 6...inv=3
# ++step=4...coordPiv=3 2 4 1 5 6...coordRank=4
# inversionTarget=5...coordPiv=3 2 4 1 5 6...inv=4
# ++step=5...coordPiv=3 4 2 1 5 6...coordRank=5
# inversionTarget=6...coordPiv=3 4 2 1 5 6...inv=5
# ++step=6...coordPiv=4 3 2 1 5 6...coordRank=6
# inversionTarget=7...coordPiv=4 3 2 1 5 6...inv=6
# ++step=7...coordPiv=4 3 2 5 1 6...coordRank=7
# 4 3 2 5 1 6 
# %   
# % P.coord.rand_with_rank 10
# .. processsing P.coord.rand_with_rank 
# coordLength=10, rankTarget=22,  rankMax=45, rankMid=22
# 7 6 5 4 3 2 8 1 9 10
# 
# % P.coord.rand_with_rank 20
# .. processsing P.coord.rand_with_rank 
# coordLength=20, rankTarget=95,  rankMax=190, rankMid=95
# 14 13 12 11 10 9 8 7 6 5 15 4 3 2 1 16 17 18 19 20
# 
# % P.coord.rand_with_rank 30
# .. processsing P.coord.rand_with_rank 
# coordLength=30, rankTarget=217,  rankMax=435, rankMid=217
# 21 20 19 18 17 16 15 14 13 12 11 10 9 8 22 7 6 5 4 3 2 1 23 24 25 26 27 28 29 30
# % 
# Copyright: 
# Franc Brglez, Fri Jul 31 14:22:05 EDT 2015
#~dd 
} ;# P.coord.rand_with_rank

proc P.coord.neighborhood { {coord "a b c d e"} } {   
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.coord.neighborhood
set ABOUT \
"This proc takes a permutation coordinate such as **a b c d e** (here, of size 
L = 5) and returns the complete set of adjacent coordinates (i.e. coordinates
with the permutation distance of 1 from the reference permutation. The size 
of this set of adjacent (or neighborhood coordinates) is L-1."
    if {$coord == "??"} { puts $ABOUT ; return }
    if {$coord == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    set L [llength $coord] ; set Lm1 [expr {$L-1}]
    set doTabulate 1 ;# no table is generated when this line is a comment
    
    # we now do array based version, to avoid using procedure lindex 
    # store the permuted coordinate in an array
    for {set i 1} {$i <= $L} {incr i} {set aPerm($i) [lindex $coord $i-1]}

    # initialize the first elm_i to be swapped
    #set elm_i [lindex $coord 0]
    set elm_i $aPerm(1)
    # for {set i 0} {$i < $Lm1} {incr i} {}
    for {set i 1} {$i < $L} {incr i} {       
        set ip1 [expr {$i + 1}]   
        # swap elements at i & ip1
        #set elm_ip1 [lindex $coord $ip1]
        set elm_ip1 $aPerm($ip1)
        set swapL $coord 
        # using i-1 instead of i
        lset swapL $i-1 $elm_ip1 ;# puts ---swapL-i,elm_ip1=$swapL
        #if {$ip1 <= $Lm1} { }
        if {$ip1 <= $L} { 
             # using ip1-1 instead of ip1
            lset swapL $ip1-1 $elm_i ;# puts +++swapL-ip1,elm_i=$swapL\n
            lappend coordAdj $swapL
            #set elm_i [lindex $coord $ip1]
            set elm_i  $aPerm($ip1)
        }
    }
    if {[info exists doTabulate]} {
        puts "** coordinate-rank table from $thisCmd **\
          \n** the first coordinate is the pivot **\
          \n** adjacent coordinates follow **\
          \ncoordinate\trank\
          \n[join $coord ,]\t[P.coord.rank $coord]"
        foreach coord $coordAdj {
            puts [join $coord ,]\t[P.coord.rank $coord]
        }
    }
    return $coordAdj
#~dd  
# % P.coord.neighborhood "a b c d e"
# ** coordinate-rank table from P.coord.neighborhood ** 
# ** the first coordinate is the pivot ** 
# ** adjacent coordinates follow ** 
# coordinate	rank 
# a,b,c,d,e	0
# b,a,c,d,e	1
# a,c,b,d,e	1
# a,b,d,c,e	1
# a,b,c,e,d	1
# {b a c d e} {a c b d e} {a b d c e} {a b c e d}
# 
# % P.coord.neighborhood "2 1 4 5 3"
# ** coordinate-rank table from P.coord.neighborhood ** 
# ** the first coordinate is the pivot ** 
# ** adjacent coordinates follow ** 
# coordinate	rank 
# 2,1,4,5,3	3
# 1,2,4,5,3	2
# 2,4,1,5,3	4
# 2,1,5,4,3	4
# 2,1,4,3,5	2
# {1 2 4 5 3} {2 4 1 5 3} {2 1 5 4 3} {2 1 4 3 5}
# % 
#     
# Copyright:
# Franc Brglez, Mon Jan 19 15:50:16 EST 2015
#~dd 
} ;# P.coord.neighborhood




