#------- keep here as a 80-character reference line to check text width -------#

# B.coord.string_vs_list (L, sampleSize, seedInit)
# 
# as we discussed ... send mail asap if we need to discuss this again ...
# 
# L == even, total number of bits
# coordRefList = L/2 0's, followed by L/2 1's
# 
# 
# This function will produce a table with the following tabbed columns
# 
# # seedInit = ????
# # sampleSize = 1000 (or 2000 or 4000)
# #     coord_as_list   coord_as_string
# L     runtime_list    runtime_string
#  32    ?secs?         ?secs?
#  64    ?secs?         ?secs?
# 128    ?secs?         ?secs?
# 256    ?secs?         ?secs?
# 512    ?secs?         ?secs?
# 1024    ?secs?                ?secs?
# 2048    ?secs?                ?secs?
# 
# I will try to do a tcl version of B.coord.string_vs_list and mail results ...
# Try to make a decision about this (for python) before this Friday ....

proc B.coord.string_vs_list {
    {L 32} {Lpoints 3} {sampleSize 1000} {seedInit 1215}} {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.coord.string_vs_list 
set ABOUT "\
Example: $thisCmd   L   Lpoints    sampleSize   seedInit
          $thisCmd   32  7          2000        1066
         
The command  $thisCmd implements an asympototic experiment to test  
runtime costs of decoding binary coordinates represented either as a binary 
string  or a binary list. There are 4 input parameters:
  the length of a binary coordinate L, 
  the value of Lpoints (points in the asymptotic experiments)
  the value of sampleSize, and 
  the value of seedInit. 
  
The experiment proceeds as follows:
(1) creates  a refererence coordinate list of alternating 0's and 1's.
(2) creates two coordinate samples as random permutations of coordRefList;
one sample as a list of binary strings; the other as a list of binary lists.
(3) decodes commponent values of each coordinate sample.
(4) measures the total runtime of the two decoding operations for each L.
"
    if {$L == "??"} { puts $ABOUT ; return }
    if {$L == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    global tcl_platform tcl_patchLevel
    
    if {$L % 2}  {
        error "\nERROR from $thisProc:\
          \nthe value of L=$L is expected to be even!\n"
    } 
    if {$seedInit == ""} {
        # initialize the RNG  with a random seed
        set seedInit [expr {int(1e9*rand())}] ; expr {srand($seedInit)} 
    } elseif {[string is integer $seedInit]} {
        # initialize the RNG  with a user-selected seed
        expr {srand($seedInit)}
    } else { 
        error "ERROR from $thisCmd:\
          \n.. only seedInit={} or seedInit=<int> are valid assignments,\
          not -seedInit $seedInit\n"
    }
    
    for {set points 1} {$points <= $Lpoints} {incr points} {
        lappend L_list [expr {$L*2**($points - 1)}]
    }
    append hostID $tcl_platform(user)  @ \
      [lindex [split [info hostname] .] 0] - $tcl_platform(os) - \
      $tcl_platform(osVersion)
    
    append tableFile $thisCmd -$sampleSize -$seedInit -asympTest.txt
    set tableLines "# file = $tableFile (an R-compatible file of labeled columns\
      \n# commandLine = $thisCmd $L  $Lpoints    $sampleSize   $seedInit\
      \n# invoked on [join [clock format [clock seconds] -gmt 0]]\
      \n# hostID = $hostID\
      \n# compiler = tcl-$tcl_patchLevel\
      \n#\
      \n# seedInit = $seedInit\
      \n# sampleSize = $sampleSize\
      \n#\
      \n#               coordAsString   coordAsList     \
      \n# coordSize     runtimeString   runtimeList   runtimeRatio\
      \ncoordSize\truntimeString\truntimeList\truntimeRatio\n"
    
    foreach L $L_list {
        
        set coordRefList {}
        for {set i 0} {$i < $L} {incr i} {
            if { $i % 2} {
                lappend coordRefList 1
            } else {
                lappend coordRefList 0
            }
        }
        #puts $L/$coordRefList
        set runtimeList 0.0 ; set runtimeString 0.0
        
        for {set sample 1} {$sample <= $sampleSize} {incr sample} {
            set coordList   [list.shuffle10 $coordRefList]
            set coordString [join $coordList ""]
            set rankList 0  ; set rankString 0
            
            set microSecs [lindex [time {
                foreach item $coordList {
                    if {$item} {#incr rankList}
                }
            } 1 ] 0 ]
            set runtimeList [expr {$runtimeList + ($microSecs/1e6)}]
            
            set microSecs [lindex [time {
                for {set i 0} {$i < $L} {incr i} {
                    set item [string index $coordString $i] 
                    if {$item} {#incr rankString}
                }
            } 1 ] 0 ]
            set runtimeString [expr {$runtimeString + ($microSecs/1e6)}]            
            
            if {$rankList != $rankString} {
                error "\nERROR from $thisCmd:\n.. rank mismatch:\
                  rankList=$rankList, rankString=$rankString \n"
            }
            set runtimeRatio [expr {$runtimeString/$runtimeList}]
        }
        append tableLines $L\t$runtimeString\t$runtimeList\t$runtimeRatio\n   
    }
    puts \n$tableLines
    file.write $tableFile $tableLines
    puts ".. created file $tableFile"
    return
# ~dd   
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xProj/B.lightp/xWork
# 
# % source ../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# %
# 
# % B.coord.string_vs_list 32 9 100
# 
# # file = B.coord.string_vs_list-100-1215-asympTest.txt (an R-compatible file of labeled columns 
# # commandLine = B.coord.string_vs_list 32  9    100   1215 
# # invoked on Sun Jul 19 20:17:53 EDT 2015 
# # hostID = brglez@belair-Darwin-14.4.0 
# # compiler = tcl-8.5.8 
# # 
# # seedInit = 1215 
# # sampleSize = 100 
# # 
# #             coordAsString   coordAsList      
# # coordSize   runtimeString   runtimeList   runtimeRatio 
# coordSize     runtimeString   runtimeList     runtimeRatio
# 32    0.004275000000000007    0.0030510000000000016   1.4011799410029515
# 64    0.005363000000000004    0.003684000000000001    1.4557546145494036
# 128   0.010620999999999998    0.007169999999999996    1.4813110181311024
# 256   0.021288999999999995    0.014268000000000003    1.4920801794224832
# 512   0.041974000000000004    0.028239        1.48638407875633
# 1024  0.08593300000000006     0.05768299999999998     1.489745678969542
# 2048  0.17658800000000002     0.11764799999999995     1.500985992112064
# 4096  0.34206400000000003     0.2265790000000002      1.5096897770755442
# 8192  0.6999490000000002      0.464292        1.5075620514676114
# 
# .. created file B.coord.string_vs_list-100-1215-asympTest.txt
# %
# 
# % B.coord.string_vs_list 32 9 1000
# 
# # file = B.coord.string_vs_list-1000-1215-asympTest.txt (an R-compatible file of labeled columns 
# # commandLine = B.coord.string_vs_list 32  9    1000   1215 
# # invoked on Sun Jul 19 20:18:17 EDT 2015 
# # hostID = brglez@belair-Darwin-14.4.0 
# # compiler = tcl-8.5.8 
# # 
# # seedInit = 1215 
# # sampleSize = 1000 
# # 
# #             coordAsString   coordAsList      
# # coordSize   runtimeString   runtimeList   runtimeRatio 
# coordSize     runtimeString   runtimeList     runtimeRatio
# 32    0.0285469999999996      0.02030300000000036     1.4060483672363244
# 64    0.05322799999999957     0.036419000000000375    1.4615447980449496
# 128   0.11005399999999915     0.07430600000000119     1.481091701881374
# 256   0.21582499999999857     0.14581300000000189     1.4801492322357799
# 512   0.43374699999999916     0.29109800000000063     1.4900377192560519
# 1024  0.8888449999999996      0.593277999999998       1.4981930899173788
# 2048  1.7303170000000003      1.1549459999999983      1.4981800014892497
# 4096  3.5032119999999947      2.3303730000000074      1.5032838090726177
# 8192  6.983555000000003       4.667928999999996       1.4960713841191688
# 
# .. created file B.coord.string_vs_list-1000-1215-asympTest.txt
# %
# 
# % B.coord.string_vs_list 32 9 2000
# 
# # file = B.coord.string_vs_list-2000-1215-asympTest.txt (an R-compatible file of labeled columns 
# # commandLine = B.coord.string_vs_list 32  9    2000   1215 
# # invoked on Sun Jul 19 20:19:37 EDT 2015 
# # hostID = brglez@belair-Darwin-14.4.0 
# # compiler = tcl-8.5.8 
# # 
# # seedInit = 1215 
# # sampleSize = 2000 
# # 
# #             coordAsString   coordAsList      
# # coordSize   runtimeString   runtimeList   runtimeRatio 
# coordSize     runtimeString   runtimeList     runtimeRatio
# 32    0.055647999999998934    0.039257000000000555    1.417530631479689
# 64    0.11062499999999761     0.07582400000000009     1.4589707744249512
# 128   0.21681599999999443     0.146251999999999       1.4824822908404391
# 256   0.43458599999999953     0.29139300000000146     1.4914085101563777
# 512   0.8910939999999958      0.5948769999999978      1.4979466343462584
# 1024  1.747565999999996       1.16581999999999        1.4990015611329457
# 2048  3.491572999999999       2.332569999999999       1.4968781215569094
# 4096  7.188618000000003       4.802943000000009       1.4967110790196738
# 8192  13.992334999999997      9.332137999999992       1.499370776557313
# 
# .. created file B.coord.string_vs_list-2000-1215-asympTest.txt
# % 
#     
# Copyright:
# Franc Brglez, Mon Jan 19 15:50:16 EST 2015
#~dd   
} ;# B.coord.string_vs_list 
    
    
proc B.coord.neighborhood { {coordPivot 0101010} {withDetails 0} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.coord.neighborhood
set ABOUT \
" Example: B.coord.neighborhood 0101010

The command  $thisCmd takes a binary coordinate such as 0101010 (here of 
size L = 7) and returns a set of all ** adjacent coordinates **, i.e. the
coordinates with the Hamming distance of 1 from the input coordinate.
The size of this set is L. 
"
    if {$coordPivot == "??"} { puts $ABOUT ; return }
    if {$coordPivot == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    set L [string length $coordPivot]  ; set coordNeighbors {}
    
    for {set i 0} {$i < $L} {incr i} {  
        set bit [string index $coordPivot $i]
        if {$bit} {
            set coordAdj [string replace $coordPivot $i $i 0]
        } else {
            set coordAdj [string replace $coordPivot $i $i 1]
        } 
        lappend coordNeighbors $coordAdj
    }
    if {$withDetails} {
        set details "Details from $thisCmd\
          \ncoordPivot\tcoordRank\
          \n$coordPivot\t[B.coord.rank $coordPivot]\
          \ncoordNeighbors\tcoordRank\n"
        foreach coord $coordNeighbors {
            append details $coord\t[B.coord.rank $coord]\n
        }
        return $details
    } else {
        return $coordNeighbors
    }
#~dd  
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xProj/B.ogr/xWork
# % source ../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# % 
# % B.coord.neighborhood 1001000010 1
# Details from B.coord.neighborhood 
# coordPivot    coordRank 
# 1001000010    3 
# coordNeighbors        coordRank
# 0001000010    2
# 1101000010    4
# 1011000010    4
# 1000000010    2
# 1001100010    4
# 1001010010    4
# 1001001010    4
# 1001000110    4
# 1001000000    2
# 1001000011    4
# 
# % B.coord.neighborhood 11111111 1
# Details from B.coord.neighborhood 
# coordPivot    coordRank 
# 11111111      8 
# coordNeighbors        coordRank
# 01111111      7
# 10111111      7
# 11011111      7
# 11101111      7
# 11110111      7
# 11111011      7
# 11111101      7
# 11111110      7
# 
# % B.coord.neighborhood 01010101 1
# Details from B.coord.neighborhood 
# coordPivot    coordRank 
# 01010101      4 
# coordNeighbors        coordRank
# 11010101      5
# 00010101      3
# 01110101      5
# 01000101      3
# 01011101      5
# 01010001      3
# 01010111      5
# 01010100      3
# 
# % B.coord.neighborhood 01010101 
# 11010101 00010101 01110101 01000101 01011101 01010001 01010111 01010100
# % 
#     
# Copyright:
# Franc Brglez, Mon Jan 19 15:50:16 EST 2015
#~dd 
} ;# B.coord.neighborhood

proc B.coord.neighbors_down { 
    {coordPivot 1001000010} 
    {functionName {}}
    {withDetails 0} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.coord.neighbors_down
set ABOUT \
" Example: B.coord.neighbors_down 1001000010

NEEDS EDITS ...
The command  $thisCmd takes a binary coordinate such as 0101010
which has length L = 7 and rank r = 3. This command returns a subset of 
** adjacent coordinates **,  all with the Hamming distance of 1 from the 
input coordinate and with rank (r-1). The size of this subset is r.
For input coordinate of rank 0, this command returns an empty set.
"
    if {$coordPivot == "??"} { puts $ABOUT ; return }
    if {$coordPivot == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    set L [string length $coordPivot]  ; set coordNeighbors {}
    
    if {$functionName == {}} {
        error "\nERROR from $thisCmd:\
          \nfunctionName MUST be specified, e.g. B.labs.f, B.ogr.f, etc\n"
    }
    set coordAdj {}   
    for {set i 0} {$i < $L} {incr i} {  
        unset coordAdj
        set bit [string index $coordPivot $i]
        if {$bit} {
            set coordAdj [string replace $coordPivot $i $i 0]
        } 
        if {[info exists coordAdj]} {lappend coordNeighbors $coordAdj}
        set coordAdj {}
    }
    set valuePivot [$functionName  $coordPivot]
    foreach coord $coordNeighbors {
        lappend valueAry([$functionName  $coord]) $coord
    }
    if {$withDetails} {
        set details "Details from $thisCmd\
          \ncoordPivot\tcoordRank\tvaluePivot\
          \n$coordPivot\t[B.coord.rank $coordPivot]\t$valuePivot\
          \ncoordNeighbors\tcoordRank\tvalueNeighbor\n"
        foreach coord $coordNeighbors {
            append details $coord\t[B.coord.rank $coord]\
              \t[$functionName  $coord]\n
        }
        append details \
          "AllNeighborsBelowRankOfPivot = [llength $coordNeighbors]\n"
        return $details
    } else {
        return [list $valuePivot [array get valueAry] ]
    } 
#~dd  
# % source ../xLib/all_tcl
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xProj/B.ogr/xWork
# 
# % B.coord.neighbors_down 1001000010 B.ogr.f 1
# Details from B.coord.neighbors_down 
# coordPivot    coordRank       valuePivot 
# 1001000010    3       0 
# coordNeighbors        coordRank       valueNeighbor
# 0001000010    2       0
# 1000000010    2       0
# 1001000000    2       0
# %
# % B.coord.neighbors_down 1001000010 B.ogr.f 
# 0 {0 {0001000010 1000000010 1001000000}}
# %
# %
# % B.coord.neighbors_down 11011010000 B.labs.f
# 37 {444 11011000000 13 {10011010000 11001010000} 41 11010010000 443 01011010000}
# %
# Copyright:
# Franc Brglez, Tue Jun  9 10:24:38 EDT 2015
#~dd 
} ;# B.coord.neighbors_down

proc B.coord.neighbors_up { 
    {coordPivot 1001000010} 
    {functionName {}}
    {withDetails 0} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.coord.neighbors_up
set ABOUT \
" Example: B.coord.neighbors_up 1001000010

NEEDS EDITS ...
The command  $thisCmd takes a binary coordinate such as 0101010
which has length L = 7 and rank r = 3. This command returns a subset of 
** adjacent coordinates **,  all with the Hamming distance of 1 from the 
input coordinate and with rank (r+1). The size of this subset is L-r.
For input coordinate of rank L, this command returns an empty set.
"
    if {$coordPivot == "??"} { puts $ABOUT ; return }
    if {$coordPivot == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    set L [string length $coordPivot]  ; set coordNeighbors {}
    
    if {$functionName == {}} {
        error "\nERROR from $thisCmd:\
          \nfunctionName MUST be specified, e.g. B.labs.f, B.ogr.f, etc\n"
    }
    set coordAdj {}   
    for {set i 0} {$i < $L} {incr i} {  
        unset coordAdj
        set bit [string index $coordPivot $i]
        if {!$bit} {
            set coordAdj [string replace $coordPivot $i $i 1]
        } 
        if {[info exists coordAdj]} {lappend coordNeighbors $coordAdj}
        set coordAdj {}
    }
    set valuePivot [$functionName  $coordPivot]
    foreach coord $coordNeighbors {
        lappend valueAry([$functionName  $coord]) $coord
    }
    if {$withDetails} {
        set details "Details from $thisCmd\
          \ncoordPivot\tcoordRank\tvaluePivot\
          \n$coordPivot\t[B.coord.rank $coordPivot]\t$valuePivot\
          \ncoordNeighbors\tcoordRank\tvalueNeighbor\n"
        foreach coord $coordNeighbors {
            append details $coord\t[B.coord.rank $coord]\
              \t[$functionName  $coord]\n
        }
        append details \
          "AllNeighborsAboveRankOfPivot = [llength $coordNeighbors]\n"
        return $details
    } else {
        return [list $valuePivot [array get valueAry] ]
    }
#~dd  
# % source ../xLib/all_tcl
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xProj/B.ogr/xWork
# 
# % B.coord.neighbors_up 1001000010 B.ogr.f 1
# Details from B.coord.neighbors_up 
# coordPivot    coordRank       valuePivot 
# 1001000010    3       0 
# coordNeighbors        coordRank       valueNeighbor
# 1101000010    4       5
# 1011000010    4       4
# 1001100010    4       4
# 1001010010    4       4
# 1001001010    4       4
# 1001000110    4       5
# 1001000011    4       4
# %
# % B.coord.neighbors_up 1001000010 B.ogr.f 
# 0 {4 {1011000010 1001100010 1001010010 1001001010 1001000011} 5 {1101000010 1001000110}}
# % 
# %
# % B.coord.neighbors_up 10000110100 B.labs.f
# 45 {488 {10010110100 10000111100} 419 10000110101 33 10001110100 
# 37 {11000110100 10000110110} 452 10100110100}
#     
# Copyright:
# Franc Brglez, Tue Jun  9 10:24:38 EDT 2015
#~dd 
} ;# B.coord.neighbors_up


#------- keep here as a 80-character reference line to check text width -------#



proc B.coord.as_int { {bstr "0001101"} } {
#~dd 
#
# TITLE: 
# Binary string conversion to a positive integer
#
# DESCRIPTION: 
# This procedure takes a binary string and returns a positive integer.
#
# ARGUMENTS:
# \code{bstr} ... a binary string
#
# RETURNS:
# a positive integer in the range [0, 2^length(bstr) - 1]
#
# ERRORS:
# returns an error if bstr is not a binary string
#
# EXAMPLES:
# % B.coord.as_int 
# 13
# % B.coord.as_int   11001000
# 200
# % B.coord.as_int   00111
# 7
# % B.coord.as_int "10001"
# 17
# % B.coord.as_int "10002"
# ERROR ... the string = '10002' is not a binary string
# B.coord.as_int " 10001"
# ERROR ... the string = ' 10001' is not a binary string
# % 
# NOTES:
# none
#
# Copyright:
# Franc Brglez <brglez@ncsu.edu>, Mon Dec 21 10:09:18 EST 2009
#
#~dd
    if {![B.coord.is $bstr]} {
        error "\nERROR ... the string = '$bstr' is not a binary string\n"
    }
    set maxBits [string length $bstr] ; set val 0
    for {set i 0} {$i < $maxBits} {incr i} {
        set j   [expr {$maxBits - $i -1}] 
    set bit [string index $bstr $i]
        set val [expr {$val + int($bit*pow(2,$j))}]
    }
    if {[string is integer $val]} {
        return $val
    } else {
        # this check is now likely redundant, left here just as s reminder ...
        error "\nERROR ... the string = $val is not an integer \n" 
    }         
} ;# B.coord.as_int


proc B.coord.from_PlusMinus  { 
    {bPlusMinus -++-+-+-++--+++++++--} 
    {ABOUT "This procedure  converts a PlusMinus string
    to binary string."}} {
        
    # B.coord.from_PlusMinus -++-+-+-++--+++++++--
    set thisCmd B.coord.from_PlusMinus 
    set ABOUT "This procedure takes a +/- string and returns  
    a 0/1 binary string. 
    Look for examples of invocations under the copyright line at the tail 
    end of this procedure. To access the list of procedure arguments, use 
    the tclsh command 'info args $thisCmd'"
    if {$bPlusMinus == "?"} {puts "    $ABOUT" ; return } 
    
    set len [string length $bPlusMinus]
    set bstr {}
    for {set i 0} {$i < $len} {incr i} {
        set bit [string index $bPlusMinus $i]
        if {$bit == "+"} {
            append bstr 1
        } elseif {$bit == "-"} {
            append bstr 0
        } else {
            error "\ERROR from B.coord.from_PlusMinus\
              \n value=$bit can only be + or -\n"
        }
    }
    return $bstr
#~dd   
# Copyright: 
# Franc Brglez, Thu Jul 19 15:25:36 EDT 2012
#
# % B.coord.from_PlusMinus -++-+-+-++--+++++++--
# 011010101100111111100
# % 
# % B.coord.from_PlusMinus +-+-+--++-+-++-+-++---++---++-+-+-+-+--+----++--+-++++--++-+---++++++++++--+--++-++-----+++++--++++++
# 10101001101011010110001100011010101010010000110010111100110100011111111110010011011000001111100111111
# % string length 10101001101011010110001100011010101010010000110010111100110100011111111110010011011000001111100111111
# 101
# % B.coord.energy 10101001101011010110001100011010101010010000110010111100110100011111111110010011011000001111100111111
# 578 ;# known best energy for L=101
#
#~dd  
} ;# B.coord.from_PlusMinus

proc B.coord.from_int { {val 31} {maxBits 5} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd coord.from_int
set ABOUT \
"This procedure takes an integer and the length of the binary string that
can represent this integer and returns a binary string that actually
represents this integer.
"
    if {$val == "??"} { puts $ABOUT ; return }
    if {$val == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
 
    set intMax [expr {int(pow(2,$maxBits)) - 1}]
    if {$val > $intMax} {
        error "\nERROR from $thisCmd ...\
          maxBits=$maxBits cannot represent an integer=$val \n"
    } 
    if {$val < 0} {
        error "\nERROR from $thisCmd ... negative input value, val = $val \n"
    } 
    if {$val > 0} {
        set nBits [expr {int(log($val)/log(2.0))}]
        set bstr {}
        set remainder $val
        
        for {set i $nBits} {$i > -1} {incr i -1} {
                
            set base      [expr {int(pow(2, $i))}]
            set quotient  [expr {int($remainder/ $base)}]
            set remainder [expr {$remainder % $base}]
            append bstr   $quotient    
            #puts "i=$i $base $quotient $remainder $bstr"
        }
    } else {
        # if $val == 0
        set bstr 0
    }
    set numZeros [expr {$maxBits - [string length $bstr]}]
    set zeros {}
    for {set i 0} {$i < $numZeros} {incr i} {append zeros 0}
    set bstr [append zeros $bstr]
    return $bstr
#~dd 
# % B.coord.from_int 16 4
# ERROR ... maxBits of 4 cannot represent an integer of size 16 
# % B.coord.from_int -15 4
# ERROR ... negative input value, val = -15 
# % B.coord.from_int 15 4
# 1111
# % B.coord.from_int 10 4
# 1010
# % B.coord.from_int 8 4
# 1000
# % B.coord.from_int 3 4
# 0011
# % B.coord.from_int 1 4
# 0001
# % B.coord.from_int 0 4
# 0000
# %
# NOTES:
# \item
# The basis of the algorithm is mod2 division/remaindering, i.e.  
#                                                              
#         num%base = (quotient, remainder)                     
#                                                              
#         6%4 = (1, 2)     13%16 = (0, 13)                     
#         2%2 = (1, 0)     13%8  = (1, 5)                     
#         0%1 = (0, 0)      5%4  = (1, 1)                     
#                           1%2  = (0, 1)                     
#                           1%1  = (1, 0)  
# % 
# Copyright:
# Franc Brglez, Mon Dec 21 10:18:28 EST 2009
#
#~dd
} ;# B.coord.from_int

proc B.coord.make_skewsym { 
    {bstrLeft "0000011"} 
    {ABOUT "This procedure takes a binary string of length L and returns
    a skew-symmetric binary string of odd length Lskew = 2*L + 1.
    See the examples under comments below: the right-most bit in the
    bstrLeft become the 'middleBit' and can determine whether the
    full string is optimal or not!!"} } {
        
    # extract the middleBit as the last bit in bstrLeft
    set middleBit [string index $bstrLeft end]
    # remove the last bit in bstrLeft
    set bstrLeft [string replace $bstrLeft end end]
    set L2 [string length $bstrLeft]  
    
    for {set i 0} {$i < $L2} {incr i} {
        # copy into RHS the reversed  LHS
        # and then complement the even bits in RHS
        set bit [string index $bstrLeft [expr {$L2 - 1 - $i}]]
        if {[expr {$i%2}]} {
            append bstrRight $bit
        } else {
            if {$bit} {
                append bstrRight 0
            } else {
                append bstrRight 1
            }
        }
    }
    # return the assembled coordinate without computing the energy value
    append bstr $bstrLeft $middleBit $bstrRight
    return $bstr
#~dd
# % B.coord.make_skewsym 0000010
# 0000010001010
# % B.coord.energy 0000010001010
# 78
# % B.coord.make_skewsym 0000011
# 0000011001010
# % B.coord.energy 0000011001010
# 6
#
# Copyright:
# Franc Brglez, Sun Mar  7 22:04:59 EST 2010
#
#~dd
} ;# B.coord.make_skewsym

proc B.coord.merit { {bstr "0001101"} } {

    if {![B.coord.is $bstr]} {return "NA"}
    set L [string length $bstr]
    set energy [B.coord.energy $bstr]
    if {$L > 1} {
        set merit [expr {0.5*$L*$L/$energy}]
    } else {
        set merit 0
    }
    return [format.decimalPlaces $merit 6]
#~dd 
# % B.coord.merit
# 8.166666666666666
# % B.coord.merit 0000011001010
# 14.083333333333334
# % B.coord.merit 001111111001101010110
# 8.48076923076923
# % 
# Copyright:
# Franc Brglez, Mon Dec 21 15:26:58 EST 2009
#~dd    
} ;# B.coord.merit   

proc B.coord.energy { {bstr "0001101"} } {

    # this code is copied from the procedure B.coord.autocor
    if {![B.coord.is $bstr]} {return "NA"}
    set L [string length $bstr] ;# puts "$L\n $bstr"
    set Lm1 [expr {$L - 1}]
    for {set i 0} {$i < $Lm1} {incr i} {
        set iL [expr {$Lm1 - $i}] ; set iR [expr {$i + 1}]
        set strL [string range $bstr 0   [expr {$iL - 1}]] 
        set strR [string range $bstr $iR end]
        # compute the Hamming distance between strL and strR
        set dist 0
        for {set j 0} {$j < $iL} {incr j} {
            set bL [string index $strL $j]
            set bR [string index $strR $j]
            if {$bL != $bR} {incr dist}
        }
        #puts "i=$iL\n strL=$strL\n strR=$strR\n dist=$dist"
        # AC = list of autocorrelation coefficients
        lappend AC [expr {($L - $i - 1) - $dist - $dist}]        
    }
    # now, compute the side-lobe auto-correlation energy
    set energy 0 
    for {set i 0} {$i < $Lm1} {incr i} { 
        set coeff [lindex $AC $i]
        set energy [expr {$energy + $coeff*$coeff}]
        #puts i=$i..coeff=$coeff..energy=$energy
    }
    return $energy
#~dd 
# % B.coord.energy "00010"
# 2
# % B.coord.energy
# 3
# % B.coord.energy "0000011001010"
# 6
# % B.coord.energy "001111111001101010110"
# 26
# % 
# Copyright:
# Franc Brglez, Mon Dec 21 15:26:58 EST 2009
#
#~dd
} ;# B.coord.energy

proc B.coord.autocor   { {bstr "0001101"} } {

    if {![B.coord.is $bstr]} {return "NA"}
    set L [string length $bstr] ;# puts "$L\n $bstr"
    set Lm1 [expr {$L - 1}]
    for {set i 0} {$i < $Lm1} {incr i} {
        set iL [expr {$Lm1 - $i}] ; set iR [expr {$i + 1}]
        set strL [string range $bstr 0   [expr {$iL - 1}]] 
        set strR [string range $bstr $iR end]
        # compute the Hamming distance between strL and strR
        set dist 0
        for {set j 0} {$j < $iL} {incr j} {
            set bL [string index $strL $j]
            set bR [string index $strR $j]
            if {$bL != $bR} {incr dist}
        }
        #puts "$iL\n $strL\n $strR\n $dist"
        # AC = list of autocorrelation coefficients
        lappend AC [expr {($L - $i - 1) - $dist - $dist}]        
    }
    return $AC
#~dd 
# EXAMPLES:
# In this run, internal "puts" statements have been UN-commented
# % B.coord.autocor
# 7
#  0001101
# 6
#  000110
#  001101
#  3
# 5
#  00011
#  01101
#  3
# 4
#  0001
#  1101
#  2
# 3
#  000
#  101
#  2
# 2
#  00
#  01
#  1
# 1
#  0
#  1
#  1
# 0 -1 0 -1 0 -1
# %  
# In these runs, internal "puts" statements have been commented
# % B.coord.autocor 0000011001010
# 0 1 0 1 0 1 0 1 0 1 0 1
# % B.coord.autocor 000101001
# -2 1 0 -1 2 1 0 -1
# % B.coord.autocor 000011010
# 0 1 0 -3 0 1 0 1
# % B.coord.autocor 000000000
# 8 7 6 5 4 3 2 1
# % B.coord.autocor 111111111
# 8 7 6 5 4 3 2 1
# % 
# In the example above, "000101001" is NOT skewsymmetric and
# ac-coefficients are NOT alternating 0's, as we get them for "000011010"
# which IS skewsymmetric. However, BOTH strings will produce the same global
# minimum energy, as shown below:
# % B.coord.energy "000101001"
# 12
# % B.coord.energy "000011010"
# 12
# % 
# For context, see 1977-IEEET.IT-Golay-labs.pdf 
#   author = "M. J. E. Golay",
#   title  = "Sieves for Low Autocorrelation Binary Sequences",
#   journal = "IEEE  Transactions on Information Theory",
#   volume = "23",
#   pages = "43--51",
#   year = "1977"
# \item 
# For more generic ideas on autocorrelation, 
# see S. Golomb et al, p.48, Prentice Hall, 1964, TK5101 G6
# -  rho(x,y) = (A-D)/(A+D)
# -  A is the number of term-by-term agreements of x with y
# -  D is the number of disagreements
# -  note that we consider BINARY (0/1) sequences, not sequences of +1Õs and -1Õs
#
# Copyright:
# Franc Brglez, Mon Dec 21 15:26:58 EST 2009
#~dd
} ;# B.coord.autocor

proc B.coord.as_brun { {bstr "0001101"} 
    {ABOUT "This  function takes a binary string of length 'L' and returns 
            'a runs' representation of a binary string, the number 
        partitions of interger 'L', and the value of 'L'"} } {
    
    set L [string length $bstr]
    set cnt 1 ; set bitPrev [string index $bstr 0] ; set brun {}
    for {set i 1} {$i < $L} {incr i} {
        set bit [string index $bstr $i] 
        set transition [expr {($bit + $bitPrev)%2}] ; incr cnt
        if {$transition == 1} {
            lappend brun [expr {$cnt - 1}] ; set cnt 1
        }
        set bitPrev $bit
    }
    lappend brun $cnt
    set nPartitions [llength $brun]
    set brun [join $brun ","]
    return "$brun $nPartitions $L"

#~dd 
# % B.coord.as_brun 1000011001010
# 1,4,2,2,1,1,1,1 8 13
# % B.coord.as_brun 0000011001010
# 5,2,2,1,1,1,1 7 13
# % B.coord.as_brun 0110011001010
# 1,2,2,2,2,1,1,1,1 9 13
#
# Copyright:
# Franc Brglez, Sun May 22 14:35:38 EDT 2011
#~dd 
} ;# B.coord.as_brun


proc B.coord.from_brun  { 
    {brun 5,2,2,1,1,1,1} 
    {ABOUT "This procedure  converts a binary runs-string
    to binary string."}} {

    set brun [split $brun ,] ; set len [llength $brun]
    set bstr [string repeat 0 [lindex $brun 0]]
    for {set i 1} {$i < $len} {incr i} {
        set r [lindex $brun $i] ; set bit [expr {$i%2}]
        set bstr [append bstr [string repeat $bit $r]]
    }
    return $bstr
#~dd 
# % B.coord.from_brun 5,2,2,1,1,1,1
# 0000011001010
# % 
#
# Copyright:
# Franc Brglez, Mon Dec 21 10:18:28 EST 2009
#~dd  
} ;# B.coord.from_brun

proc B.coord.from_array  { 
    {coordAry_ "0 1 1 1 2 0 3 0 4 1 5 0 6 0 7 0 8 0 9 1 10 0 11 1"} 
    {ABOUT "This procedure  converts an array of binary values
    to a binary string."}} {

    array set coordAry $coordAry_
    foreach i [lsort -integer [array names coordAry]] {
        append coord $coordAry($i)
    }
    return $coord
#~dd 
# % B.coord.from_array "0 1 1 1 2 0 3 0 4 1 5 0 6 0 7 0 8 0 9 1 10 0 11 1"
% 110010000101
# % 
#
# Copyright:
# Franc Brglez, Sun Aug  9 12:36:57 EDT 2015
#~dd  
} ;# B.coord.from_array

proc B.coord.canonic_labs { {bstrInit 1010110011111} } {
    
    set thisCmd B.coord.canonic_labs 
    set ABOUT "This procedure takes a binary string and generates three  
    additional binary strings that are related in the context of symmetry 
    rules for the labs problem. It returns the 'canonic labs binary  
    string' which by definition is the string with largest laevus number
    (the number of zeros at the left side of the string). 
    Look for examples of invocations under comment lines at the tail 
    end of this procedure. Here are two examples of the command:
    \nB.coord.canonic_labs  ;# takes default input values
    \nB.coord.canonic_labs 1010110011111"
    if {$bstrInit == "?"} {
        puts "    $ABOUT"
        puts "\nList of all arguments expected by ${thisCmd}:\n[info args $thisCmd]"
        return 
    }
    set bstrExpanded $bstrInit
    set bstr2 [B.coord.compl   $bstrInit]  ; lappend bstrExpanded $bstr2
    set bstr3 [B.coord.reverse $bstr2]  ; lappend bstrExpanded $bstr3
    set bstr4 [B.coord.compl   $bstr3]  ; lappend bstrExpanded $bstr4
    #puts [join [lsort $bstrExpanded] \n]
    
    # the canonic string is the one with maximum laevus0 number!     
    set bstrCanonic [lindex [lsort $bstrExpanded] 0]
    return $bstrCanonic
#~dd   
# % B.coord.canonic_labs 1010110011111
# 0000011001010
# % B.coord.canonic_labs 011010101100111111100
# 001111111001101010110
# % B.coord.canonic_labs 10101001101011010110001100011010101010010000110010111100110100011111111110010011011000001111100111111
# 00000011000001111100100110110000000000111010011000010110011110110101010100111001110010100101001101010
#
# Copyright: 
# Franc Brglez, Thu Jul 19 15:25:36 EDT 2012
#~dd 
} ;# B.coord.canonic_labs

proc B.coord.expand4 { 
    {coord 1010110011101} 
    {ABOUT "This procedure takes a binary string and makes a 
    expansion into four equivalent strings. Note that for some coorrdinates
    the expansion does not produce four prefixes 00, 01, 10, 11 -- however
    B.coord.energy values STILL remain invariant under this expansion"} } {
    
    set thisCmd B.coord.expand4 
    # perform the canonic coordinate expansion
    set coord1 $coord                   ; lappend coordExpanded $coord1
    set coord2 [B.coord.compl   $coord1] ; lappend coordExpanded $coord2
    set coord3 [B.coord.reverse $coord2] ; lappend coordExpanded $coord3
    set coord4 [B.coord.compl   $coord3] ; lappend coordExpanded $coord4
    
    return [lsort -uniq $coordExpanded]
#~dd 
# % B.coord.expand4 1111100110101
# 0000011001010 0101001100000 1010110011111 1111100110101
# 
# % B.coord.expand4 0111100110101
# 0101001100001 0111100110101 1000011001010 1010110011110
# 
# Copyright: 
# Franc Brglez, Tue Jun 30 10:17:37 EDT 2015
#~dd
} ;# B.coord.expand4 

proc B.coord.compl { {bstr "000100"} } {

    if {![B.coord.is $bstr]} {return "NA"}
    set L [string length $bstr]
    for {set i 0} {$i < $L} {incr i} {
        if {[string index $bstr $i]} {
            set bstr [string replace $bstr $i $i 0]
        } else {
            set bstr [string replace $bstr $i $i 1]
        }
    }
    return $bstr
#~dd 
# % B.coord.compl
# 111011
# % B.coord.compl 1110001
# 0001110
# % 
# Copyright:
# Franc Brglez, Wed Dec 23 10:19:18 EST 2009
#~dd
} ;# B.coord.compl

proc B.coord.reverse { {bstr "0001101"} } {

    if {![B.coord.is $bstr]} {return "NA"}
    set L [string length $bstr] ; set Lm1 [expr {$L - 1}]
    for {set i $Lm1} {$i >= 0} {incr i -1} {
        set bit [string index $bstr $i] ; append bstrRev $bit
    }
    return $bstrRev
#~dd 
# % B.coord.reverse
# 1011000
# % B.coord.reverse 0001
# 1000
# % 
# Copyright:
# Franc Brglez, Wed Dec 23 10:19:18 EST 2009
#~dd
} ;# B.coord.reverse

proc B.coord.is { {coordB "0001101"} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.coord.is
set ABOUT \
"This procedure takes a binary string and returns TRUE
if the string is a binary string and FALSE otherwise.
"
    if {$coordB == "??"} { puts $ABOUT ; return }
    if {$coordB == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    set maxBits [string length $coordB]  
    for {set i 0} {$i < $maxBits} {incr i} { 
        set bit [string index $coordB $i]
        if {$bit < 0 || $bit > 1} {
            return FALSE
        } 
    }
    return TRUE
#~dd 
# % B.coord.is " 1 01"
# FALSE
# % B.coord.is "1 01"
# FALSE
# % B.coord.is "101"
# TRUE
# B.coord.is "10a1"
# FALSE
# % B.coord.is "abc"
# FALSE
# % B.coord.is "123"
# FALSE
# % B.coord.is 01011
# TRUE
# % 
# Copyright:
# Franc Brglez, Mon Dec 21 10:29:18 EST 2009
#~dd
} ;# B.coord.is 

proc B.coord.distance { {bstrL "0101"} {bstrR "1001"} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.coord.distance
set ABOUT \
"This procedure takes two binary strings and returns
the value of the Hamming distance between the strings.
"
    if {$bstrL == "??"} { puts $ABOUT ; return }
    if {$bstrL == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    set L [string length $bstrL] ; set dist 0
    if {$L != [string length $bstrR]} {
        error "\nERROR ... unequal length strings: $L vs\
          [string length $bstrR]"
    }
    for {set j 0} {$j < $L} {incr j} {
        set bL [string index $bstrL $j]
        set bR [string index $bstrR $j]
        if {$bL != $bR} {incr dist}
    }
    return $dist
#~dd 
# % B.coord.distance 0101 1001
# 2
# % B.coord.distance 0111 0011
# 1
# % B.coord.distance 0111 00110
# ERROR ... unequal length strings: 4 vs 5
# % 
# % 
# Copyright:
# Franc Brglez, Wed Dec 23 10:19:18 EST 2009
#
#~dd
} ;# B.coord.distance

proc B.coord.weight { {bstr "0001101"} } {

    # this is the faster implementation ...
    #set L [string length $bstr]
    if {![B.coord.is $bstr]} {return "NA"}
    set tmp [split $bstr 0] ;# get a list of 1's only
    set weight [string length [join $tmp ""]]
    
    return $weight
#~dd 
# % B.coord.weight 0011
# 2
# % B.coord.weight 0101
# 2
# % 
# Copyright:
# Franc Brglez, Mon Dec 21 10:29:18 EST 2009
#
#~dd
} ;# B.coord.weight

proc B.coord.rank { {bstr "0001101"} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.coord.distance
set ABOUT \
"This proc takes a binary coordinate as a string such as '010101' and
returns its weight number as the number of 'ones', which can also be 
interpreted as the distance from '000000' or as 'the rank' of the 
coordinate in the Hasse graph with respect to its 'bottom' coordinate 
of all 'zeros'.
"
    if {$bstr == "??"} { puts $ABOUT ; return }
    if {$bstr == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    # this is the faster implementation ...
    #set L [string length $bstr]
    if {![B.coord.is $bstr]} {return "NA"}
    set tmp [split $bstr 0] ;# get a list of 1's only
    set weight [string length [join $tmp ""]]
    
    # rank of a binary coordinate is defined by its weight
    # see  tests for B.coord.weight
    return $weight
#~dd 
# % B.coord.rank 001101
# 3
# % B.coord.rank 111111
# 6
# % 
# Copyright:
# Franc Brglez, Mon Dec 21 10:29:18 EST 2009
#
#~dd
} ;# B.coord.rank


proc B.coord.runs  { 
    {bstr "0001101"}
    {ABOUT "This procedure takes a binary string and returns 
    an integer as its runs-value"} } {

    if {![B.coord.is $bstr]} {return "NA"}
    set L [string length $bstr]
    set runs 1 ; set bitPrev [string index $bstr 0]
    for {set i 0} {$i < $L} {incr i} {
        set bit        [string index $bstr $i] 
        set transition [expr {($bit + $bitPrev) % 2}]
        if {$transition} {incr runs}
        set bitPrev $bit
    }
    return $runs
#~dd 
# % B.coord.runs
# 4
# % B.coord.runs 0000000
# 1
# % B.coord.runs 1010101
# 7
# % 
# Copyright:
# Franc Brglez,  Wed Dec 23 10:19:18 EST 2009
#
#~dd
} ;# B.coord.runs

proc B.coord.rand_with_rank {L rank  
    {ABOUT "This proc takes two integers L and rank and returns a random 
    binary coordinate (coordType = B) of length L with the specified 
    value of rank, 0 <= rank <= L "} } {
      
    set thisCmd B.coord.rand_with_rank
    if {$rank == 0} {
        set coord [string repeat 0 $L]
        return $coord
        
    } elseif {$rank == $L} {
        set coord [string repeat 1 $L]
        return $coord
        
    } elseif {$rank > 0 && $rank < $L} {
        set coord [string repeat 0 [expr {$L - $rank}]][string repeat 1 $rank]
        set coord [join [list.shuffle10 [split $coord ""]] ""]
        return $coord
        
    } else {
        error "\nERROR from $thisCmd:\
          \nThe specified value of rank=$rank exceed the range \
          0 <= rank <= $L\n"
    }
#~dd 
# % B.coord.rand.withRank 8 0
# 00000000
# % B.coord.rand.withRank 8 8
# 11111111
# % B.coord.rand.withRank 8 3
# 10010010
# % B.coord.rand.withRank 8 3
# 00001110
# % B.coord.rand.withRank 8 3
# 00101001
# % 
# Copyright: 
# Franc Brglez, Fri Aug 23 14:07:00 EDT 2013
#~dd 
} ;# B.coord.rand.withRank

proc B.coord.rand { {L  41} {weightFactor "NA"} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.coord.rand
set ABOUT \
"This proc takes an integer L, and optionally a weightFactor > 0 and <= 1.
By default, weightFactor = NA, and an unbiased binary coordinate of length L
is returned. For weightFactor=0.5, a biased random coordinate of length L 
is returned: it will have  a random distribution of exactly L/2 'ones' 
for L even and (L+1)/2 'ones' for L odd.
"
    if {$L == "??"} { puts $ABOUT ; return }
    if {$L == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#      
    
    if {$weightFactor == "NA"} {
        # return an unbiased random coordinate
        for {set i 0} {$i < $L} {incr i} {
            append coord [expr {int(0.5 + rand())}]
        }
        return $coord
        
    } else {
        if {$weightFactor > 0. && $weightFactor <= 1} {
            set weight [expr {int(ceil($weightFactor*$L))}]
            set coord \
              [string repeat 1 $weight][string repeat 0 [expr {$L - $weight}]]
            set coord [join [list.shuffle10 [split $coord ""]] ""]
            return $coord
        } else {
            error "\nERROR from $thisCmd:\
              \nweightFactor=$weightFactor is out bound \[0.0, 1.0\]"
        }
    }
#~dd 
# % # initialize RNG
# % expr srand(123)
# 0.0009626434189093501
# 
# % B.coord.rand 6
# 010111
# 
# % B.coord.rand 6
# 010110
# 
# % B.coord.rand 6
# 000000
# 
# % B.coord.rand 6
# 100001
# 
# % B.coord.rand 6 0.5
# 101010
# 
# % B.coord.rand 6 0.5
# 001101
# 
# % B.coord.rand 6 0.5
# 001101
# 
# % B.coord.rand 6 0.5
# 101010
# 
# % B.coord.rand 6 0.5
# 100101
# 
# % B.coord.rand 6 0.1
# 001000
# % B.coord.rand 6 0.8
# 111011
# %
# Copyright: 
# Franc Brglez, Fri Aug 23 14:07:00 EDT 2013
#~dd 
} ;# B.coord.rand

#------- keep here as a 80-character reference line to check text width -------#

proc B.coord.list_gray { 
    {refB 000} 
    {ABOUT "An ordered list of 2^L  binary coordinates in gray order;
    also thinks of it as face labels of an L-dimensional binary dice
    or corresponding labeled Hasse graph.
    (in old version, known as dice.coordB)"} } {  
 
    # initialize
    set L     [string length $refB]    
    set lmbit [string index $refB end] ;# left-most-bit
    if {$lmbit} {set lmbitC 0} else {set lmbitC 1}
    set binOld "$lmbit $lmbitC"

    for {set k 2} {$k <= $L} {incr k} {        
    
        set lmbit [string index  $refB [expr {$L - $k}]]
        if {$lmbit} {set lmbitC 0} else {set lmbitC 1}
        set iMax [expr {int(pow(2,$k)/2. - 1)}] ; set binNew {}

        # coordinates list in first-half of binNew
        for {set i 0} {$i <= $iMax} {incr i} {
            lappend binNew  ${lmbit}[lindex  $binOld $i]
            #puts binNew-top=$binNew...$i
        }
        # coordinates list in second-half of binNew
        for {set i $iMax} {$i >= 0} {incr i -1} {
            lappend binNew  ${lmbitC}[lindex  $binOld $i]
            #puts binNew-bot=$binNew...$i
        }
        set binOld $binNew
    }
    return $binNew
#~dd 
# % B.coord.list_gray 0000
# 0000 0001 0011 0010 0110 0111 0101 0100 1100 1101 1111 1110 1010 1011 1001 1000
#
# % B.coord.list_gray 0101
# 0101 0100 0110 0111 0011 0010 0000 0001 1001 1000 1010 1011 1111 1110 1100 1101
#
# NOTES:
# \item
# see examples under http://en.wikipedia.org/wiki/Gray.code
# \item
# To understand the code above, follow this example:
#     refB = 0101
#    (1)    (2)    (3)    (4)     
#     1      01     101    0101
#     -      00     100    0100
#     0      --     110    0110
#            10     111    0111
#            11     ---    0011
#                   011    0010
#                   010    0000
#                   000    0001
#                   001    ----
#                          1001
#                          1000
#                          1010
#                          1011
#                          1111
#                          1110
#                          1100
#                          1101
#
# Copyright:
# Franc Brglez, Sat Jul 10 14:34:17 EDT 2010
#~dd   
} ;# B.coord.list_gray
