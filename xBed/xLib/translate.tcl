#------- keep here as a 80-character reference line to check text width -------#
proc translate.graph.bool_vs_hash {
    {nVertex 32} {Vpoints 3} {sampleSize 1000} {seedInit 1215}} {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.coord.string_vs_list 
set ABOUT "\
Example: $thisCmd   nVertex   Vpoints    sampleSize   seedInit
          $thisCmd   32       7          2000        1066
	 
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
    
    set L $nVertex
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
    
    # create the adjaceny matrix adjUV
    set cnt -1
    for {set u 1} {$u <= $nVertex} {incr u} {
        for {set v [expr {$u+1}]} {$v <= $nVertex} {incr v} {
	    incr cnt
	    if {$cnt % 2}  {
		set adjUV($u,$v) 0 ; set adjUV($v,$u) 0
            } else {
		set adjUV($u,$v) 1 ; set adjUV($v,$u) 1
            }
        }
    }
    
    for {set u 1} {$u <= $nVertex} {incr u} {
        for {set v [expr {$u+1}]} {$v <= $nVertex} {incr v} {
            if {$adjUV($u,$v) || $adjUV($v,$u) } {
                if {![info exists aEdge($u,$v)]} {
                    set aEdge($u,$v) {} ; lappend edgeList "e $u $v"
                }
            }
        }
    }
    parray adjHash ; parray adjBool ; puts \nedgeList\n$edgeList
    return 
    puts edgeListHash\n$edgeListHash 
    puts edgeListBool\n$edgeListBool 
     
    for {set points 1} {$points <= $Vpoints} {incr points} {
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
      \n#        	coordAsString	coordAsList     \
      \n# coordSize	runtimeString   runtimeList   runtimeRatio\
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
}

proc translate.cnf2morph  {
    {instanceDef ../xBenchm/coverBinate/tiny/i-5-06-li-02.cnf}
    {seedInit 1901}
    {ABOUT "...."} } {
        
    set thisProc translate.cnf2morph
    global arrays: aPI aV aStruc 
    array unset aPI ; array unset aStruc   

    # read the instance file 
    set instanceFile $instanceDef
    set fileExtension [file extension $instanceFile]
    if {$fileExtension == ".cnf"} {
        # this format implies unit weighting for each variable
        # and unit weights are returned under aStruc(weightList)
        array set aStruc [translate.cnf2struc $instanceFile]
        set coverType B  
    } elseif {$fileExtension == ".cnfU"} {
        # this format implies unit weighting for each variable
        # and unit weights are returned under aStruc(weightList)
        array set aStruc [translate.cnf2struc $instanceFile]
        set coverType U
    } else {
        # this format supports specific weighting for each variable  
        error "ERROR from $thisProc:\
          \n.. only file extension .cnf is supported in this version\n"
    }
    #parray aStruc ; return
    set nDim        $aStruc(nVars)
    set nClauses    $aStruc(nClauses)
    set clauseList  $aStruc(clauseList)
    set varList     $aStruc(varList)
    
    # initialize the RNG  with a user-selected seed
    set init [expr {srand($seedInit)}]  
    
    set varList_perm [list.shuffle10 $varList]
    for {set i 1} {$i <= $nDim}    {incr i}  {
        set varAry($i) [lindex $varList_perm [expr {$i - 1}]]
    }
    set clauseList_perm [list.shuffle10 $clauseList]
   
    set clauseList_morph {}
    foreach clause $clauseList_perm {
        
        set clauseMorph {}
        foreach lit $clause {
            if {$lit > 0} { 
                lappend clauseMorph $varAry($lit)
            } else {  
                set var [string trimleft $lit "-"]
                lappend clauseMorph -$varAry($var)
            }
        }
        set clauseMorph [list.shuffle10 $clauseMorph]
        lappend clauseList_morph $clauseMorph
    }
    if {$nDim <= 5} {
        puts \nFROM...$thisProc
        puts varList=$varList
        puts clauseList=\n$clauseList\n
        puts seedInit=$seedInit
        puts varList_perm=$varList_perm
        parray varAry
        puts clauseList_perm=\n$clauseList_perm
        puts clauseList_morph=\n$clauseList_morph
    }
    set fileExtension [string trimleft [file extension $instanceDef] "."]
    set fileName  \
      [file rootname [file  tail $instanceDef]]-morph-$seedInit.$fileExtension
    set fileLines "c fileName = $fileName\
      \nc an isomorph based on seedInit = $seedInit\
      \nc created with $thisProc on [clock format [clock seconds]] \
      \nc\
      \np $fileExtension $nDim $nClauses\
      \n[join $clauseList_morph \n]"
    #puts \nfileLines\n$fileLines
    
    file.write $fileName $fileLines
    puts ".. created a file $fileName\n"
#~dd
# (xWork) 93 % translate.cnf2morph ../xBenchm/coverBinate/tiny/i-5-06-li-02.cnf 1
# FROM...translate.cnf2morph
# varList=1 2 3 4 5
# clauseList=
# {2 4} {1 3} {1 3 5} {-3 4} {3 -4} {-1 -4}
# 
# seedInit=1
# varList_perm=1 5 4 2 3
# varAry(1) = 1
# varAry(2) = 5
# varAry(3) = 4
# varAry(4) = 2
# varAry(5) = 3
# clauseList_perm=
# {1 3} {2 4} {3 -4} {-1 -4} {-3 4} {1 3 5}
# clauseList_morph=
# {1 4} {2 5} {-2 4} {-1 -2} {-4 2} {4 3 1}
# .. created a file ../xBenchm/coverBinate/tiny/i-5-06-li-02-1.cnf
# 
# (xWork) 94 % translate.cnf2morph ../xBenchm/coverBinate/tiny/i-5-06-li-02.cnf 2
# 
# FROM...translate.cnf2morph
# varList=1 2 3 4 5
# clauseList=
# {2 4} {1 3} {1 3 5} {-3 4} {3 -4} {-1 -4}
# 
# seedInit=2
# varList_perm=2 4 5 1 3
# varAry(1) = 2
# varAry(2) = 4
# varAry(3) = 5
# varAry(4) = 1
# varAry(5) = 3
# clauseList_perm=
# {1 3 5} {1 3} {-3 4} {3 -4} {-1 -4} {2 4}
# clauseList_morph=
# {3 5 2} {5 2} {-5 1} {5 -1} {-2 -1} {4 1}
# .. created a file ../xBenchm/coverBinate/tiny/i-5-06-li-02-2.cnf
# (xWork) 95 % 
#     
# Copyright:
# Franc Brglez, Wed Nov 05 04:06:10 EST 2014
#~dd
} ;# translate.cnf2morph

proc translate.cnf2struc {
    {file ../../../xBenchm/coverBinate/tiny/i-6-12-AMAI-04.cnf} 
    {ABOUT "Read a *.cnf file (cnf format) and return 
    nDim, nClauses, clauseList"}} {
    
    set thisProc translate.cnf2struc
     
    if {![file exists $file]} {
        error "\nERROR ... file $file could not be found\n"
    }
    set errorLines {} ; 
    set fileLines [split [file.read $file] \n]
     
    # read the instance file
    set clauseList {} 
    foreach line $fileLines {
        set firstChar [string index $line 0]
        if {$firstChar == "p"} {
            set nVars [lindex $line 2] ; set nClauses [lindex $line 3]
        }
        if {$firstChar != "c"  && $firstChar != "p"} {
            set clause [lrange $line 0 end-1]
            if {$clause != {}} {lappend clauseList $clause}
        }
    }
    # for now, skip checking if formula is consistent with nVars and nClauses
    set varList {}
    for {set i 1} {$i <= $nVars} {incr i} {lappend varList $i}
    # count all literals and store their positions
    set nLitsPos 0 ; set nLitsNeg 0
    foreach v $varList {
        for {set i 0} {$i < $nClauses}  {incr i}  {
            set clause [lindex $clauseList $i]
            if {[lsearch -exact $clause $v ] > -1} {
                set aLits($i,$v) {} ; incr nLitsPos
            } 
            if {[lsearch -exact $clause -$v ] > -1} {
                set aLits($i,-$v) {} ; incr nLitsNeg
            }
        }
    } ;# foreach v $varList
    set nLitsAll [expr {$nLitsPos + $nLitsNeg}] ;# parray litsAry
    
    if {$errorLines != {} } {
        error $errorLines 
    } else {
        #-- assemble and return the complete instance array 
        array unset aStruc
        set aStruc(nVars)          $nVars
        set aStruc(nClauses)       $nClauses 
        set aStruc(nLitsPos)       $nLitsPos
        set aStruc(nLitsNeg)       $nLitsNeg
        set aStruc(densityLitsPos) [expr {double($nLitsPos)/($nVars*$nClauses)}]
        set aStruc(densityLitsNeg) [expr {double($nLitsNeg)/($nVars*$nClauses)}]
        set aStruc(densityLitsAll) [expr {double($nLitsAll)/($nVars*$nClauses)}]
        set aStruc(varList)        $varList
        set aStruc(clauseList)     $clauseList
        set aStruc(aLits_)         [array get aLits]
        for {set i 1} {$i <= $nVars} {incr i} {lappend aStruc(weightList) 1}
        return [array get aStruc]
    }
#~dd
# % translate.cnf2struc ../../../xBenchm/coverBinate/tiny/i-6-12-AMAI-04.cnf
# weightList {1 1 1 1 1 1} nLitsNeg 20 nLitsPos 8 
# clauseList {{-1 -2} {-1 -3} {-1 -4} {-1 -5} {-1 -6} {-2 -3} {-2 -4} {-3 -4} {-5 -6} {1 2 3} {4 5 6} {-1 2 -3 4}} 
# varList {1 2 3 4 5 6} 
# densityLitsAll 0.3888888888888889 densityLitsNeg 0.2777777777777778 densityLitsPos 0.1111111111111111 
# nClauses 12 nVars 6 
# litsAry_ {5,-2 {} 3,-5 {} 5,-3 {} 0,-1 {} 7,-3 {} 0,-2 {} 7,-4 {} 2,-1 {} 4,-1 {} 9,1 {} 2,-4 {} 9,2 {} 9,3 {} 11,2 {} 10,4 {} 6,-2 {} 10,5 {} 11,4 {} 10,6 {} 4,-6 {} 6,-4 {} 1,-1 {} 11,-1 {} 1,-3 {} 3,-1 {} 8,-5 {} 11,-3 {} 8,-6 {}}
#
# Copyright: 
# Franc Brglez, Sat Nov 22 13:48:23 EST 2014
#~dd   
} ;# translate.cnf2struc 
    
proc translate.cnf2lpx {
    {file ../xBenchm/coverBinate/tiny/i-6-12-AMAI.cnf}
    
    {ABOUT "Read a *.cnf file (cnf format) and return 
    nDim, nClauses, clauseList"}} {
    
    set thisProc translate.cnf2struc
     
    if {![file exists $file]} {
        error "\nERROR ... file $file could not be found\n"
    }
    set errorLines {} ; 
    set fileLines [split [file.read $file] \n]
     
    # read the instance file
    set clauseList {} 
    foreach line $fileLines {
        set firstChar [string index $line 0]
        if {$firstChar == "p"} {
            set nVars [lindex $line 2] ; set nClauses [lindex $line 3]
        }
        if {$firstChar != "c"  && $firstChar != "p"} {
            set clause [lrange $line 0 end-1]
            if {$clause != {}} {lappend clauseList $clause}
        }
    }
    # for now, skip checking if formula is consistent with nVars and nClauses
    
    if {$errorLines != {} } {
        error $errorLines 
    } else {
        #-- assemble and return the complete instance array 
        array unset aStruc
        set aStruc(nVars)   $nVars
        set aStruc(nClauses) $nClauses  
        set aStruc(clauseList) $clauseList
        set aStruc(varList) {}
        for {set i 1} {$i <= $nVars} {incr i} {lappend aStruc(varList) $i}
        for {set i 1} {$i <= $nVars} {incr i} {lappend aStruc(weightList) 1}
        return [array get aStruc]
    }
} ;# translate.cnf2struc 

proc translate.hgr2struc {
    {file ../xBenchm/v-005-0004-ex1.hgr} 
    {ABOUT "Read a *.hgr file (metis jypergraph format) and return 
    nCell, nNet, netList, cellList, commentLines"}} {
    
    set thisProc translate.hgr2struc
    
    # look-up also graph_LIB.tcl
    if {![file exists $file]} {
        error "\nERROR ... file $file could not be found\n"
    }

    set errorLines {} ; set netList {} ; set commentLines {} 
    set cellList {} 
     
    # read the instance file
    #puts ".. reading file=$file"
    set linesAll [split [file.read $file] \n]
    set cntNet 0
    foreach line $linesAll {
        if {[string index $line 0] != "%" && $line != {}} {
            if {$cntNet == 0} {
                set nNet [lindex $line 0]
                set nCell   [lindex $line 1]
                
            } else {
                set net [lsort -integer $line]
                lappend netList  $net
                set cellList [lsort -integer -uniq [concat $cellList $net]]
            }
            incr cntNet
        } 
    }
    #puts cellList=$cellList ; puts netList=$netList
    
    # verify connectivity
    if {$nCell != [llength $cellList]} {
        append errorLines "\nERROR: mismatch in specified nCell=$nCell\
          versus cellList size=[llength $cellList]"
    }
    if {$nNet != [llength $netList]} {
        append errorLines "\nERROR: mismatch in specified nNet=$nNet versus\
          netList size=$nNet"  
    }
    if {$errorLines != {} } {
        error $errorLines 
    } else {
        # create the netlist as list in lexographical order
        set tmpList $netList ; set netList {}
        foreach net $tmpList {
            lappend netList [join $net ,]
        }
        set netList [lsort [concat $netList  $cellList]]
        
        return "$nCell $nNet [llength $netList] [list $netList]"
    }
#~dd
# % translate.hgr2struc data/v-005-0004-ex1.hgr
# .. reading file=data/v-005-0004-ex1.hgr
# cellList=1 2 3 4 5
# netList={2 4} {1 2 5} {1 2 3} {1 2 3 4 5}
# 5 4 9 {1 1,2,3 1,2,3,4,5 1,2,5 2 2,4 3 4 5}
# % 
# Copyright:
# Franc Brglez <brglez@ncsu.edu>, Fri Nov 29 15:09:40 EST 2013
#
#~dd
} ;# translate.hgr2struc


#------- keep here as a 80-character reference line to check text width -------#

proc translate.edge2struc { 
    {instanceFile translate/i-6-08-ex2.edge } } {
   
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd translate.edge2struc
set ABOUT "
         $thisCmd instanceFile
Example: $thisCmd translate/i-6-8-ex2.edge

The command $thisCmd takes the path name of a graph instance file with   
a file extension of *.edge and returns a data structure under the xBed 
naming convention."

    if {$instanceFile == "??"} { puts $ABOUT ; return }
    if {$instanceFile == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    if {![file exists $instanceFile]} {
    error "\nERROR from $thisCmd:\
      \n.. the file with name below has not found\
      \n   $instanceFile\n"
    }
    set errorLines {} ; set countE 0  
    # read the instance file
    set linesAll [split [file.read $instanceFile] \n]
    foreach line $linesAll {
        if {[string index $line 0] != "c" && $line != {}} {
            if {[lindex $line 0] == "p" && [lindex $line 1] == "edge"} {
                set nVertex [lindex $line 2]
                set nEdge   [lindex $line 3]
            } else {
                if {[lindex $line 0] != "e"} {
                    append errorLines \
                      "\nERROR ... edge line must contain 'e number1\
                      number2', not \n'$line'"
                } else {
                    set v1 [lindex $line 1]
                    set v2 [lindex $line 2]
                    if {$v1 == $v2} {
                        append errorLines "\nERROR from $thisCmd ... vertices\
              on edge line must be distinct, not \n'$line'"
                    } else {
                        set edge [join [lsort -integer "$v1 $v2"] ,]
                        if {![info exist aEdge($edge)]} {
                            set  aEdge($edge) {} ; incr countE
                            lappend aFreq($v1) $v1 ; lappend aFreq($v2) $v2 
                        } else {
                            append errorLines "\nERROR ... vertices on edge line\
                              must be repeated, such as \n'$line'"  
                        }
            if { ![info exists pairs($v1,$v2)] || \
              ![info exists aPairs($v2,$v1)]  } {
                set aPairs($v1,$v2) {} ;  set aPairs($v2,$v1) {}
            } 
            if { ![info exists aVertex($v1)] || \
              ![info exists aVertex($v2)]  } {
                set aVertex($v1) {} ; set aVertex($v2) {}
            }
                    }
                }
            }
        }
    }
    # verify against pLine
#     if {$nVertex != [array size aVertex]} {
#         append errorLines "\nERROR from $thisCmd: mismatch in specified nVertex=$nVertex\
#           versus SizeOf-aVertex=[array size aVertex]"
#     }
    if {$nEdge != $countE} {
        append errorLines "\nERROR from  $thisCmd: mismatch in specified nEdge=$nEdge versus\
          SizeOfedgeList=$countE"  
    }
    if {$errorLines != {} } {error $errorLines} 
    
    set aV(density) [expr { (2.0*$nEdge)/($nVertex*$nVertex - $nVertex)}]
    set aV(nVertex) $nVertex  ;  set aV(nEdge) $nEdge

    # create the edge arrays edgeU and edgeV
    set cnt 0
    foreach item [array names aEdge] {
        set pair [split $item ,]
        incr cnt
        set edgeU($cnt) [lindex $pair 0]
        set edgeV($cnt) [lindex $pair 1]
    }
    # create the adjaceny matrix adjUV
    for {set u 1} {$u <= $nVertex} {incr u} {
        for {set v [expr {$u+1}]} {$v <= $nVertex} {incr v} {
            if { [info exists aPairs($u,$v)] || \
             [info exists aPairs($v,$u)]    } {
            set adjUV($u,$v) 1 ; set adjUV($v,$u) 1
            } else {
            set adjUV($u,$v) 0 ; set adjUV($v,$u) 0
            }
        }
    }
    # extract variable orderings from the frequency array
    foreach v [array names aFreq] {lappend vOrder([llength ($aFreq($v)]) $v}
    
    foreach degree [lsort -integer -decreasing [array names  vOrder]] {
        foreach v $vOrder($degree) {
            lappend aV(vertexListDecr) $v
        }
    }
    foreach degree [lsort -integer -increasing [array names  vOrder]] {
        foreach v $vOrder($degree) {
            lappend aV(vertexListIncr) $v
        }
    }
    set aV(edgeU_)  [array get edgeU] ; set aV(edgeV_)  [array get edgeV]
    set aV(adjUV_)  [array get adjUV] 
    return [array get aV]
#~dd
# % source ../xLib/all_tcl2
# # .. sourced all tcl libraries defined under xBed/xLib (see the file all_tcl2)
# 
# % array unset aV
# % array set aV [translate.edge2struc translate/i-6-08-ex2.edge]
# % parray aV
# aV(adjUV_)         = 1,3 1 3,1 1 1,4 0 4,1 0 2,3 0 3,2 0 4,2 1 2,4 1 1,5 0 5,1 0 
#                      4,3 1 3,4 1 5,2 1 2,5 1 1,6 0 6,1 0 5,3 0 3,5 0 6,2 1 2,6 1 
#              5,4 0 4,5 0 6,3 0 3,6 0 6,4 1 4,6 1 6,5 1 5,6 1 1,2 1 2,1 1
# aV(density)        = 0.5333333333333333
# aV(edgeU_)         = 8 1 4 2 5 5 1 2 6 3 2 1 7 2 3 4
# aV(edgeV_)         = 8 2 4 4 5 6 1 6 6 4 2 3 7 5 3 6
# aV(nEdge)          = 8
# aV(nVertex)        = 6
# aV(vertexListDecr) = 2 4 6 5 1 3
# aV(vertexListIncr) = 5 1 3 4 6 2
# % 
# 
# % array unset aV
# % array set aV [translate.edge2struc translate/i-6-08-ex2-C.edge]
# % parray aV
# aV(adjUV_)         = 1,3 0 3,1 0 1,4 1 4,1 1 2,3 1 3,2 1 4,2 0 2,4 0 1,5 1 5,1 1 
#                      4,3 0 3,4 0 5,2 0 2,5 0 1,6 1 6,1 1 5,3 1 3,5 1 6,2 0 2,6 0 
#              5,4 1 4,5 1 6,3 1 3,6 1 6,4 0 4,6 0 6,5 0 5,6 0 1,2 0 2,1 0
# aV(density)        = 0.4666666666666667
# aV(edgeU_)         = 4 2 5 1 1 3 6 1 2 4 7 1 3 3
# aV(edgeV_)         = 4 3 5 4 1 5 6 5 2 5 7 6 3 6
# aV(nEdge)          = 7
# aV(nVertex)        = 6
# aV(vertexListDecr) = 5 1 3 4 6 2
# aV(vertexListIncr) = 2 4 6 5 1 3
# % 
# Copyright:
# Franc Brglez <brglez@ncsu.edu>, Sat Jul 11 22:04:30 EDT 2015
#
#~dd
} ;# translate.edge2struc

proc translate.struc2graph_complement {
    {nVertex 6}
    {adjUV_ "1,3 1 3,1 1 1,4 0 4,1 0 2,3 0 3,2 0 4,2 1 2,4 1 1,5 0 5,1 0 4,3 1 
    3,4 1 5,2 1 2,5 1 1,6 0 6,1 0 5,3 0 3,5 0 6,2 1 2,6 1 5,4 0 4,5 0 6,3 0 
    3,6 0 6,4 1 4,6 1 6,5 1 5,6 1 1,2 1 2,1 1"} } {  
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd translate.struc2graph_complement
set ABOUT "
         $thisCmd instanceFile
Example: $thisCmd translate/i-6-8-ex2.edge

The command $thisCmd takes the path name of a graph instance file with   
a file extension of *.edge and returns a data structure under the xBed 
naming convention."

    if {$nVertex == "??"} { puts $ABOUT ; return }
    if {$nVertex == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    # restore the adjacency matrix of the input graph
    array set adjUV_inp $adjUV_
    
    # create the adjaceny matrix of the complementary graph
    for {set u 1} {$u <= $nVertex} {incr u} {
    for {set v [expr {$u+1}]} {$v <= $nVertex} {incr v} {
        if {$adjUV_inp($u,$v)   && $adjUV_inp($v,$u) } {
        set  adjUV($u,$v) 0 ;   set adjUV($v,$u) 0
        } else {
        set  adjUV($u,$v) 1 ;   set adjUV($v,$u) 1
        }
    }
    }
    return [array get adjUV]
#~dd
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xBed/xLib
# 
# % source ../xLib/all_tcl2
# # .. sourced all tcl libraries defined under xBed/xLib (see the file all_tcl2)
# 
# % array unset aV
# % array set aV [translate.edge2struc translate/i-6-08-ex2.edge]
# % 
# % set nVertex $aV(nVertex)
# 6
# % set adjUV_inp $aV(adjUV_)
# 1,3 1 3,1 1 1,4 0 4,1 0 2,3 0 3,2 0 4,2 1 2,4 1 1,5 0 5,1 0 4,3 1 3,4 1 5,2 1 
# 2,5 1 1,6 0 6,1 0 5,3 0 3,5 0 6,2 1 2,6 1 5,4 0 4,5 0 6,3 0 3,6 0 6,4 1 4,6 1 
# 6,5 1 5,6 1 1,2 1 2,1 1
# % 
# % translate.struc2graph_complement $nVertex $adjUV_inp
# 1,3 0 3,1 0 1,4 1 4,1 1 2,3 1 3,2 1 4,2 0 2,4 0 1,5 1 5,1 1 4,3 0 3,4 0 5,2 0 
# 2,5 0 1,6 1 6,1 1 5,3 1 3,5 1 6,2 0 2,6 0 5,4 1 4,5 1 6,3 1 3,6 1 6,4 0 4,6 0 
# 6,5 0 5,6 0 1,2 0 2,1 0 
# % 
# Copyright:
# Franc Brglez <brglez@ncsu.edu>, Sat Jul 11 22:04:30 EDT 2015
#
#~dd    
} ;# translate.struc2graph_complement


proc translate.graph2struc {
    {file ../xBenchm/v-011-0015-man_BCC.graph} 
    {ABOUT "This proc reads a *.graph file (metis format) and returns an array 
    aStruc with variable names nVertex, nEdge, edgeList, vWeightList, vAdjAry_, 
    and commentLines. The list pair in vAdjAry_ is converted to associative 
    array within the proc."}} {
    
    # look-up also graph_LIB.tcl
    if {![file exists $file]} {
        error "\nERROR ... file $file could not be found\n"
    }
    set thisProc translate_graph2struc
    set errorLines {} ; set edgeLines {} ; set commentLines {} 
    
    # read the instance file
    set linesAll [split [file.read $file] \n]
    foreach line $linesAll {   
        if {[string index $line 0] != "%" && $line != {}} {
            lappend adjLines $line
        } else {
            # extract and save commentLines 
            append commentLinesOrig "$line  \n"
        }
    }
    append commentLinesOrig \
      "% ... translated from a (metis) *.graph format \n"
    set pLine     [lindex $adjLines 0]
    if {[llength $pLine] > 3 } {
        error "\nERROR in file [file tail $file] \
          \non line '$pLine' ... it should contain either 'nVertex nEdge'\
          \nor 'nVertex nEdge 10' where 10 implies that integer node weight\
          \nis the first number on each line forllowed by adj. node numbers\n"
    } else {            
        set nVertex    [lindex $pLine 0]
        set nEdge   [lindex $pLine 1]
        set FMT     [lindex $pLine 2]
    }   
    #-- create arrays vAdjAry and vWeightList (via vWeightAry)
    set adjLines  [lrange $adjLines  1 end] ; set i 0
    set allWeightsAreOne 0
    foreach line $adjLines {
        incr i
        if {$FMT == 10} {
            set vWeightAry($i) [lindex $line 0]
            set vAdjAry($i)    [lrange $line 1 end]
        } else {
            set allWeightsAreOne 1
            set vWeightAry($i) 1
            set vAdjAry($i)    $line
        }
    }
    set vWeightList {}
    foreach idx [lsort -integer [array names vWeightAry]] {
        lappend vWeightList $vWeightAry($idx)
    }
    array unset vWeightAry
    #-- create a list of all u-v edges  (1/2 of all undirected edges!)
    set edgeList {} ; set vertexList {}
    for {set u 1} {$u <= $nVertex} {incr u} { 
        lappend vertexList $u
        foreach v $vAdjAry($u) {
            set edge [lsort -integer "$u $v"]
            if {![info exists tmpE($edge)]} {
                set tmpE($edge) {} ; lappend edgeList $edge  
            }
        }
    }
    # verify against pLine
    if {$nVertex != [array size vAdjAry]} {
        append errorLines "\nERROR ... mismatch in specified nVertex=$nVertex\
          versus observed size of [array size vAdjAry]"
    }
    if {$nEdge != [llength $edgeList]} {
        append errorLines  "\nERROR ... mismatch in specified nEdge=$nEdge \
          versus observed size of [llength $edgeList]" 
    }
    if {$errorLines != {} } {
        puts "\n.. ERROR in $thisProc\n$errorLines" ; exit 1
    }
    #-- assemble and return the complete instance array (instanceAry)
    set aStruc(vertexList)      $vertexList
    set aStruc(edgeList)        $edgeList
    set aStruc(vWeightList)     $vWeightList  ;# vertex WeightList
    set aStruc(vAdjAry_)        [array get vAdjAry]
  
    set instanceAry_ [list instanceFile $file nVertex $nVertex \
      nEdge $nEdge aStruc_ [array get aStruc] commentLines $commentLinesOrig]
    return $instanceAry_
#~dd
# % translate_graph2struc
# .. return the 'structure array'
# aStruc(commentLines) = % slide_04_05_ref.graph (from 2004-Slides_MIT-Dai_Fiedler.pdf)  
# % 1 2 3 4  
# % ... translated from a (metis) *.graph format 
# aStruc(edgeList)     = {1 2} {1 3} {1 4} {2 4} {3 4}
# aStruc(instanceFile)    = ../xData/graph/v-004-0005-slide.graph
# aStruc(nEdge)        = 5
# aStruc(nVertex)         = 4
# aStruc(vAdjAry_)     = 4 {  1 2 3} 1 {    2 3 4} 2 {  1     4} 3 {  1     4}
# aStruc(vWeightList)  = 1 1 1 1
# % 
# AUTHOR_DATE:
# Franc Brglez <brglez@ncsu.edu>, Thu Jan 20 16:06:07 EST 2011
#
#~dd     
} ;# translate.graph2struc

proc translate.graph2edge { 
    {fileName ../xBenchm/v-005-0006-4.graph}
    {ABOUT "Take a .graph file and create .edge file"} } {
        
    set thisProc translate_graph2edge
    array set instanceAry [translate_graph2struc $fileName]
    #parray instanceAry ; return
    array set aStruc $instanceAry(aStruc_) 
    set edgeList $aStruc(edgeList)
    
    set fileBase [file rootname $fileName]
    set fileLines "c file = ${fileBase}.edge \
      \nc created by $thisProc on \
      [join [clock format [clock seconds] -gmt 0]]\
      \nc from file\
      \nc ${fileBase}.graph\
      \nc\n"
    #append fileLines $aStruc(commentLines) 
    append fileLines "p edge $instanceAry(nVertex) $instanceAry(nEdge) \n"
    foreach edge $edgeList {
        append fileLines "e $edge \n"
    }
    #puts $fileLines ; return
    file.write ${fileBase}.edge $fileLines
    puts "** file ${fileBase}.edge has been created **"
#~dd  
# % translate.graph2edge
# c file = ../xBenchm/v-005-0006-4.edge  
# c created by translate_graph2edge on  Mon Apr 21 12:44:45 EDT 2014 
# c from file 
# c ../xBenchm/v-005-0006-4.graph 
# c
# p edge 5 6 
# e 1 2 
# e 1 3 
# e 1 5 
# e 2 3 
# e 3 4 
# e 4 5 
# %
# Copyright: 
# Franc Brglez Mon Apr 21 12:45:33 EDT 2014
#
#~dd    
} ;# translate.graph2edge 

proc translate.edge2edgeFile_complement_foreach {
    {fileDir ../../../xBenchm/graph/tiny}
    {ABOUT "..."} } {
    set thisProc translate.edge2complement_foreach
    
    set fileList [glob -nocomplain $fileDir/*.edge]
    foreach file $fileList {
        puts "\ncomplementing graph in file=$file"
        translate.edge2edgeFile_complement $file
    }
} ;# translate.edge2complement_foreach

proc translate.edge2edgeFile_complement { 
    {instanceFile translate/i-6-08-ex2.edge} } {  
    
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd translate.edge2edgeFile_complement
set ABOUT "
         $thisCmd instanceFile
Example: $thisCmd translate/i-6-8-ex2.edge

The command $thisCmd takes the path name of a graph instance file with   
a file extension of *.edge and returns a graph complement file with
a file extension of *-C.edge."

    if {$instanceFile == "??"} { puts $ABOUT ; return }
    if {$instanceFile == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    if {![file exists $instanceFile]} {
    error "\nERROR from $thisCmd:\
      \n.. the file with name below has not found\
      \n   $instanceFile\n"
    }
    # read the instance file
    array set aV   [translate.edge2struc $instanceFile]
    set nVertex    $aV(nVertex)
    set adjUV_inp  $aV(adjUV_)
    
    # create the adjaceny matrix of the complementary graph
    array set adjUV [translate.struc2graph_complement $nVertex $adjUV_inp]
    
    # create the edgeList of the complementary graph
    set nEdge 0 ; array unset aEdge
    for {set u 1} {$u <= $nVertex} {incr u} {
        for {set v [expr {$u+1}]} {$v <= $nVertex} {incr v} {
            if {$adjUV($u,$v) || $adjUV($v,$u) } {
                if {![info exists aEdge($u,$v)]} {
                    set aEdge($u,$v) {} ; lappend edgeList "e $u $v"
                }
            }
        }
    }
    #puts edgeList\n$edgeList ;# return
    
    # verify the number of edges in the graph complement:
    set nEdge [llength $edgeList]
    set nEdgeExpected [expr {int(0.5*$nVertex*($nVertex - 1)) - $aV(nEdge)}]
    if {$nEdgeExpected != $nEdge} {
        error "\nERROR from $thisCmd:\
          \nincorrect complement computed for in file $instanceFile
          \n       input file: vertices = $nVertex, edges = $aV(nEdge)\
          \n  complement file: vertices = $nVertex, edges = $nEdge\
      \n           expected edges in complement = $nEdgeExpected\ 
          \n"
    }
  
    set fileBase [file tail [file rootname $instanceFile]]
    set fileDir  [file dirname $instanceFile]
    set fileComplement [file join $fileDir $fileBase]-C.edge
    
    set fileHeader "c file = $fileComplement \
      \nc created by $thisCmd on \
      [join [clock format [clock seconds] -gmt 0]]\
      \nc as a graph complement from file\
      \nc $instanceFile\
      \nc       input file: vertices=$nVertex, edges=$aV(nEdge)\
      \nc  complement file: vertices=$nVertex, edges=$nEdge\
      \nc edge count check: [expr {int(0.5*$nVertex*($nVertex - 1))}] == \
      $aV(nEdge) + $nEdge\
      \nc\
      \np edge $nVertex $nEdge"
    
    file.write $fileComplement $fileHeader\n[join $edgeList \n]
    puts "** file $fileComplement has been created **\n$fileHeader"
#~dd  
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xBed/xLib
# 
# % source ../xLib/all_tcl2
# # .. sourced all tcl libraries defined under xBed/xLib (see the file all_tcl2)
# 
# % translate.edge2edgeFile_complement translate/i-12-0018-adder.edge
# ** file translate/i-12-0018-adder-C.edge has been created **
# c file = translate/i-12-0018-adder-C.edge  
# c created by translate.edge2edgeFile_complement on  Mon Jul 13 20:07:59 EDT 2015 
# c as a graph complement from file 
# c translate/i-12-0018-adder.edge 
# c       input file: vertices=12, edges=18 
# c  complement file: vertices=12, edges=48 
# c edge count check: 66 ==  18 + 48 
# c p edge 12 48
# % 
# %
# Copyright: 
# Franc Brglez, Mon Jul 13 20:09:19 EDT 2015
#
#~dd    
} ;# translate.edge2complement 

proc translate.edge2isomorph {
    {instanceFile translate/i-6-08-ex2.edge} 
    {numFiles 5}
    {seedInit 1001} } { 
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd translate.edge2isomorph
set ABOUT "
         $thisCmd instanceFile <numFiles=5> <seedInit=1001> 
Example: $thisCmd translate/i-6-08-ex2.edge 100 2001

The command $thisCmd takes the path name of a graph instance file with   
a file extension of *.edge and returns a directory of graph isomorph files with
a file extension of *.edge."

    if {$instanceFile == "??"} { puts $ABOUT ; return }
    if {$instanceFile == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    if {![file exists $instanceFile]} {
	error "\nERROR from $thisCmd:\
	  \n.. the file with name below has not found\
	  \n   $instanceFile\n"
    }
    set fileBase   [file tail [file rootname $instanceFile]]
    set fileDir    [file dirname $instanceFile]
    set fileDirIso [file join $fileDir $fileBase]_ISO-$seedInit
    file mkdir $fileDirIso
    expr {srand($seedInit)} ; # initialize RNG
    
    # read the instance file
    array set aV     [translate.edge2struc $instanceFile] ;# parray aV ; return
    set nVertex      $aV(nVertex)
    set nEdge        $aV(nEdge)
    set density      $aV(density)
    set vListRef     $aV(vertexListDecr) 
    array set edgeU  $aV(edgeU_)
    array set edgeV  $aV(edgeV_)
      

    # create the isomorph files
    for {set cnt 1} {$cnt <= $numFiles} {incr cnt} {
        
        set vList [list.shuffle10 $vListRef]
        #puts \nList=$vList
        for {set i 1} {$i <= $nVertex} {incr i} {
            set P($i) [lindex $vList [expr {$i - 1}]]
        }
        set edgeListIso {} 
        for {set e 1} {$e <= $nEdge} {incr e} {
            set u $edgeU($e) ; set v $edgeV($e) 
            lappend edgeListIso "$P($u) $P($v)"
        }
        set fileIso [file join $fileDirIso $fileBase]-$cnt.edge
        set fileLines "c file = $fileIso \
          \nc vertexPermutation = [join $vList ,]\
          \nc an isomorph file under the seedInit=$seedInit with \
          serial number=$cnt\
          \nc generated on [join [clock format [clock seconds] -gmt 0]]\
          \nc by procedure $thisCmd\
          \nc density = $density \
          \nc\
          \np edge $nVertex $nEdge\
          \n"

        foreach edge $edgeListIso {
            append fileLines "e $edge \n"
        }
        #puts \n--------------\ncnt=$cnt...fileLines\n$fileLines
        file.write $fileIso $fileLines
        puts ".. created file $fileIso"
    }
#~dd
# % translate.edge2isomorph ../../../xBenchm/graph/small/i-11-0018-Herschel.edge 10 1066
# .. created file ../../../xBenchm/graph/small/i-11-0018-Herschel-ISO-1066/i-11-0018-Herschel-1.edge
# .. 
# ..
# .. created file ../../../xBenchm/graph/small/i-11-0018-Herschel-ISO-1066/i-11-0018-Herschel-9.edge
# .. created file ../../../xBenchm/graph/small/i-11-0018-Herschel-ISO-1066/i-11-0018-Herschel-10.edge
# 
# % translate.edge2isomorph ../../../xBenchm/graph/small/i-11-0018-Herschel-C.edge 10 1066
# .. created file ../../../xBenchm/graph/small/i-11-0018-Herschel-C-ISO-1066/i-11-0018-Herschel-1-C.edge
# .. created file ../../../xBenchm/graph/small/i-11-0018-Herschel-C-ISO-1066/i-11-0018-Herschel-2-C.edge
# .. 
# ..
# .. created file ../../../xBenchm/graph/small/i-11-0018-Herschel-C-ISO-1066/i-11-0018-Herschel-9-C.edge
# .. created file ../../../xBenchm/graph/small/i-11-0018-Herschel-C-ISO-1066/i-11-0018-Herschel-10-C.edge
# %
# Copyright: 
# Franc Brglez, Tue Jul 29 22:22:01 EDT 2014
#~dd 
} ;# translate.edge2isomorph


proc translate.graphAdj2edge { 
    {fileName ../xBenchm/small/v-010-0015-peterson.adjV}
    {ABOUT "Take a .adjV graph file and create .edge file"} } {
        
    set thisProc translate.graphAdj2edge
    set errorLines {}
    # read the instance file
    set linesAll [split [file.read $fileName] \n]
    foreach line $linesAll {   
        if {[string index $line 0] != "%" && $line != {}} {
            lappend adjLines $line
        } else {
            # extract and save commentLines 
            append commentLinesOrig "$line  \n"
        }
    }
    append commentLinesOrig \
      "c ... translated from a *.adjV graph file format \n"
    set nVertex [lindex $adjLines 0] 
    #-- create arrays vAdjAry 
    set i 0
    foreach line [lrange $adjLines 1 end] {
        incr i ; set vAdjAry($i) $line  
    }
    #parray vAdjAry ; return

    #-- create a list of all u-v edges  (1/2 of all undirected edges!)
    set edgeList {} ; set graphList {} ; set vertexList {}
    for {set u 1} {$u <= $nVertex} {incr u} { 
        lappend vertexList $u
        set line $vAdjAry($u)
        for {set v $u} {$v <= $nVertex} {incr v} {
            set idx [expr {$v - 1}]
            if {[lindex $line $idx]} {lappend edgeList "$u $v"}
        }
    }
    #puts edgeListSize=[llength $edgeList]\n$edgeList
    set nEdge [llength $edgeList]
    # verify against pLine
    if {$nVertex != [array size vAdjAry]} {
        append errorLines "\nERROR ... mismatch in specified nVertex=$nVertex\
          versus observed size of [array size vAdjAry]\
          \n file = $fileName"
    }
    if {$errorLines != {} } {
        puts "\n.. ERROR in $thisProc\n$errorLines" ;# exit 1
    }    
    set fileBase [file rootname $fileName]
    set fileLines "c file = ${fileBase}.edge \
      \nc created by $thisProc on \
      [join [clock format [clock seconds] -gmt 0]]\
      \nc from file\
      \nc ${fileBase}.adjV\
      \nc\n"
    append fileLines "p edge $nVertex $nEdge \n"
    foreach edge $edgeList {
        append fileLines "e $edge \n"
    }
    #puts $fileLines ; return
    file.write ${fileBase}.edge $fileLines
    puts "** file ${fileBase}.edge has been created **"
#~dd  
# % translate.graphAdj2edge ../xBenchm/small/v-010-0015-peterson.adjV
# ** file ../xBenchm/small/v-010-0015-peterson.edge has been created **
# 
# % 2 3 4 5 6 7 8 9 10  
# 10 
# 0 1 0 0 1 0 1 0 0 0  
# 1 0 1 0 0 0 0 1 0 0  
# 0 1 0 1 0 0 0 0 1 0  
# 0 0 1 0 1 0 0 0 0 1  
# 1 0 0 1 0 1 0 0 0 0  
# 0 0 0 0 1 0 0 1 1 0  
# 1 0 0 0 0 0 0 0 1 1  
# 0 1 0 0 0 1 0 0 0 1  
# 0 0 1 0 0 1 1 0 0 0  
# 0 0 0 1 0 0 1 1 0 0 
# 
# p edge 10  15 
# e 1 2 
# e 1 5 
# e 1 7 
# e 2 3 
# e 2 8 
# e 3 4 
# e 3 9 
# e 4 5 
# e 4 10 
# e 5 6 
# e 6 8 
# e 6 9 
# e 7 9 
# e 7 10 
# e 8 10 
#
# Copyright: 
# Franc Brglez Tue Apr 22 11:34:30 EDT 2014
#
#~dd    
} ;# translate.graphAdj2edge 