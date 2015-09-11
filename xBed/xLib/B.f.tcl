proc B.f.gvc { {coord 01000} {functionMode 1} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.f.gvc ; set sandbox B.gvc ; set reader B.gvc.file_read
set ABOUT \
"The command $thisCmd takes a binary coordinate of length L. It also 
takes, as **global** associative arrays, data structures created  
under the sandbox $sandbox by the command $reader (which reads the 
instance file compatible with this sandbox). The command $thisCmd 
computes and returns the value of the graph vertex cover function, 
given the coordinate.
"
    if {$coord == "??"} { puts $ABOUT ; return }
    if {$coord == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV  
    
    # extract values from array aV
    set nVertex      $aV(nVertex)        ; set nEdge $aV(nEdge)
    array set edgeU  $aV(edgeU_)
    array set edgeV  $aV(edgeV_)
    set vertexList   $aV(vertexListDecr) ;# vertices in decreasing degree order
    
    if {$functionMode == 0} {
        set aV(valueTarget) -1
        set valueFunction 0 ;# special case, to test for trapped pivots
        return $valueFunction 
    }
    # proceed under assumption of functionMode == 1 
    
    # evaluate the graph vertex cover function
    set cntEdge 0 ; 
    for {set e 1} {$e <= $nEdge}  {incr e}  {set isCover($e) 0} 
    
    foreach v $vertexList {
	#puts vertex=$v
	# search edges for given v only if v is asserted via coord
	if { [ string index $coord $v-1 ] } {
 
	    for {set e 1} {$e <= $nEdge}  {incr e}  {
		if { !$isCover($e) } {
		    if {$v == $edgeU($e) || $v == $edgeV($e)} {
			# edge is covered
			set isCover($e) 1 ; incr cntEdge
			#puts "edge=$e is covered by v=$v...cntEdge=$cntEdge"
		    }
		}
	    }
	}
	if {$cntEdge == $nEdge} {break}
    }
    #puts edgeCoverSize=[llength $edgeCover]\nedgeCover=$edgeCover
    set cntNotCovered [expr {$nEdge - $cntEdge}]
    if {$cntNotCovered == 0} {
	set value [expr {[B.coord.rank $coord]}]
    } else {
	set value [expr {[B.coord.rank $coord] +\
	  $aV(nVertex) + $cntNotCovered}]
    }    
    return "$value"
#~dd
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xBed/xLib
# 
# % source all_tcl2
# # .. sourced all tcl libraries defined under xBed/xLib (see the file all_tcl2)
# 
# % array set aV [translate.edge2edgeUV translate/i-6-07-wiki.edge]
# % parray aV
# aV(density)        = 0.4666666666666667
# aV(edgeU_)         = 4 4 5 3 1 1 6 2 2 4 7 1 3 2
# aV(edgeV_)         = 4 6 5 4 1 3 6 5 2 5 7 2 3 3
# aV(nEdge)          = 7
# aV(nVertex)        = 6
# aV(vertexListDecr) = 4 2 3 5 1 6
# aV(vertexListIncr) = 6 5 1 4 2 3
# 
# % B.f.gvc 011100
# edge=2 is covered by v=4...cntEdge=1
# edge=4 is covered by v=4...cntEdge=2
# edge=5 is covered by v=4...cntEdge=3
# edge=3 is covered by v=2...cntEdge=4
# edge=6 is covered by v=2...cntEdge=5
# edge=7 is covered by v=2...cntEdge=6
# edge=1 is covered by v=3...cntEdge=7
# 3
# 
# % B.f.gvc 000000
# 13
# 
# % B.f.gvc 111111
# edge=2 is covered by v=4...cntEdge=1
# edge=4 is covered by v=4...cntEdge=2
# edge=5 is covered by v=4...cntEdge=3
# edge=3 is covered by v=2...cntEdge=4
# edge=6 is covered by v=2...cntEdge=5
# edge=7 is covered by v=2...cntEdge=6
# edge=1 is covered by v=3...cntEdge=7
# 6
# % 
# We can also use B.gvc.exhA to initialize the instance and 
# and to do exhaustive evaluation of this function
# % B.gvc.exhA ../xBenchm/graph/tiny/i-6-07-wiki.edge 1
# 
# hasseAry(0) = 000000:13
# hasseAry(1) = 000001:13 000010:12 000100:11 001000:11 010000:11 100000:12
# hasseAry(2) = 000011:12 000101:12 000110:11 001001:11 001010:10 001100:10 010001:11 010010:11 010100:9 011000:10 100001:12 100010:11 100100:10 101000:11 110000:11
# hasseAry(3) = 000111:12 001011:10 001101:11 001110:10 010011:11 010101:10 010110:10 011001:10 011010:10 011100:3 100011:11 100101:11 100110:10 101001:11 101010:10 101100:10 110001:11 110010:11 110100:3 111000:11
# hasseAry(4) = 001111:11 010111:11 011011:4 011101:4 011110:4 100111:11 101011:4 101101:11 101110:4 110011:11 110101:4 110110:4 111001:11 111010:11 111100:4
# hasseAry(5) = 011111:5 101111:5 110111:5 111011:5 111101:5 111110:5
# hasseAry(6) = 111111:6
# 
# coordRank   coordTotal
# 0              1
# 1              6
# 2              15
# 3              20
# 4              15
# 5              6
# 6              1
# 
# valueBest = 3
# solutionBest(rank=3) = 011100:3 110100:3
# 
# .. values returned by B.gvc.exhA for  processing by B.hasse
# ....
# % 
# Copyright:
# Franc Brglez, Sun Jul 12 11:27:58 EDT 2015
#~dd
} ;# B.f.gvc

proc B.f.gis { {coord 01000} {functionMode 1} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.f.gvc ; set sandbox B.gvc ; set reader B.gvc.file_read
set ABOUT \
"The command $thisCmd takes a binary coordinate of length L. It also 
takes, as **global** associative arrays, data structures created  
under the sandbox $sandbox by the command $reader (which reads the 
instance file compatible with this sandbox). The command $thisCmd 
computes and returns the value of the graph vertex cover function, 
given the coordinate.
"
    if {$coord == "??"} { puts $ABOUT ; return }
    if {$coord == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV  
    
    # extract values from array aV
    set nVertex      $aV(nVertex)        ; set nEdge $aV(nEdge)
    array set edgeU  $aV(edgeU_)
    array set edgeV  $aV(edgeV_)
    set vertexList   $aV(vertexListIncr) ;# vertices in increasing degree order
    
    if {$functionMode == 0} {
        set aV(valueTarget) -1
        set valueFunction 0 ;# special case, to test for trapped pivots
        return $valueFunction 
    }
    # proceed under assumption of functionMode == 1
    # evaluate the graph independent set function 
    set cntConnected 0
    for {set v 1} {$v <= $nVertex} {incr v} {
	set vp1 [expr {$v+1}]
	for {set u $vp1} {$u <= $nVertex} {incr u} {
	    
	    set bit_u [ string index $coord $u-1 ]
	    set bit_v [ string index $coord $v-1 ]
	    if {$bit_u  && $bit_v} {
		if { [info exists aStruc($i,$j)] || \
		     [info exists aStruc($j,$i)]    } {
		    incr cntConnected
		}
	    }
	}
    }
    return
    foreach v $vertexList {
	#puts vertex=$v
	# search edges for given v only if v is asserted via coord
	if { [ string index $coord $v-1 ] } {
 
	    for {set e 1} {$e <= $nEdge}  {incr e}  {
		if { !$isCover($e) } {
		    if {$v == $edgeU($e) || $v == $edgeV($e)} {
			# edge is covered
			set isCover($e) 1 ; incr cntEdge
			#puts "edge=$e is covered by v=$v...cntEdge=$cntEdge"
		    }
		}
	    }
	}
	if {$cntEdge == $nEdge} {break}
    }
    if {$cntConnected == 0} {
	set valueFunction [expr {-[B.coord.rank $coord]}]
    } else {
	#set valueFunction [expr {-[B.coord.rank $coord] +\
	  $aV(nVertex) + $cntConnected}]
	# we can decide for better penalty function later
	set valueFunction $cntConnected
    }    
    return "$valueFunction"

#~dd
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xBed/xLib
# 
# % source all_tcl2
# # .. sourced all tcl libraries defined under xBed/xLib (see the file all_tcl2)
# 
# % array set aV [translate.edge2edgeUV translate/i-6-07-wiki.edge]
# % parray aV
# aV(density)        = 0.4666666666666667
# aV(edgeU_)         = 4 4 5 3 1 1 6 2 2 4 7 1 3 2
# aV(edgeV_)         = 4 6 5 4 1 3 6 5 2 5 7 2 3 3
# aV(nEdge)          = 7
# aV(nVertex)        = 6
# aV(vertexListDecr) = 4 2 3 5 1 6
# aV(vertexListIncr) = 6 5 1 4 2 3
# 
# % B.f.gvc 011100
# edge=2 is covered by v=4...cntEdge=1
# edge=4 is covered by v=4...cntEdge=2
# edge=5 is covered by v=4...cntEdge=3
# edge=3 is covered by v=2...cntEdge=4
# edge=6 is covered by v=2...cntEdge=5
# edge=7 is covered by v=2...cntEdge=6
# edge=1 is covered by v=3...cntEdge=7
# 3
# 
# % B.f.gvc 000000
# 13
# 
# % B.f.gvc 111111
# edge=2 is covered by v=4...cntEdge=1
# edge=4 is covered by v=4...cntEdge=2
# edge=5 is covered by v=4...cntEdge=3
# edge=3 is covered by v=2...cntEdge=4
# edge=6 is covered by v=2...cntEdge=5
# edge=7 is covered by v=2...cntEdge=6
# edge=1 is covered by v=3...cntEdge=7
# 6
# % 
# We can also use B.gvc.exhA to initialize the instance and 
# and to do exhaustive evaluation of this function
# % B.gvc.exhA ../xBenchm/graph/tiny/i-6-07-wiki.edge 1
# 
# hasseAry(0) = 000000:13
# hasseAry(1) = 000001:13 000010:12 000100:11 001000:11 010000:11 100000:12
# hasseAry(2) = 000011:12 000101:12 000110:11 001001:11 001010:10 001100:10 010001:11 010010:11 010100:9 011000:10 100001:12 100010:11 100100:10 101000:11 110000:11
# hasseAry(3) = 000111:12 001011:10 001101:11 001110:10 010011:11 010101:10 010110:10 011001:10 011010:10 011100:3 100011:11 100101:11 100110:10 101001:11 101010:10 101100:10 110001:11 110010:11 110100:3 111000:11
# hasseAry(4) = 001111:11 010111:11 011011:4 011101:4 011110:4 100111:11 101011:4 101101:11 101110:4 110011:11 110101:4 110110:4 111001:11 111010:11 111100:4
# hasseAry(5) = 011111:5 101111:5 110111:5 111011:5 111101:5 111110:5
# hasseAry(6) = 111111:6
# 
# coordRank   coordTotal
# 0              1
# 1              6
# 2              15
# 3              20
# 4              15
# 5              6
# 6              1
# 
# valueBest = 3
# solutionBest(rank=3) = 011100:3 110100:3
# 
# .. values returned by B.gvc.exhA for  processing by B.hasse
# ....
# % 
# Copyright:
# Franc Brglez, Sun Jul 12 11:27:58 EDT 2015
#~dd
} ;# B.f.gis