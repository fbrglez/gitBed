# Copyright:
# Franc Brglez, Fri Jan  4 06:52:09 EST 2013
#
#------- keep here as a 80-character reference line to check text width -------#

# main_WS (wander-simple)
# main_WT (wander-tableau)
# main_MS (meander-simple)
# main_MT (meander-tableau)


proc B.ogr.main { rulerMarks methods args } {   
    
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
    
    foreach name "all_info all_valu aV aStruc aCoordHash0 aWalkProbed" {
        eval "array unset $name" ;# puts "unsetting array $name"
    }
    set isInitOnly 0
    # this decoding of 'args' is essential!!!!!
    if {[llength $args] == 0} {set argsOptions ""}
    if {[llength $args] == 1} {set argsOptions [lindex $args 0]}

    if {$argsOptions == ""} {
        set seedInit NA
    }  else {
        if {[lindex $argsOptions 0] != "-seedInit"} {
            error "ERROR ... the only option is '-seedInit int'"
        } else {
            set seedInit [lindex $argsOptions 1]
        }
    }

    # until we implement "proper commandLine", we enter all input variables HERE 
    set aV(rulerMarks)   $rulerMarks ;# required value: 4 or 5 or 6 or 7 or ....
    set aV(runtimeLmt)   3600
    set aV(seedInit)     $seedInit   ;# random integer if NA, use 7407 for m=5
    set aV(coordInit)    NA          ;# random binary coordinate if NA
    set aV(rankInit)     NA          ;# (rulerMarks - 3) if NA 
    set aV(writeVar)     0           ;# 0 or 3
    set aV(isWalkTables) 0           ;# 0 or 1
    
    set aV(neighbBestPercent) NA ;# percent_neigbBest, 
                                 ;# if NA, take the first best neighbor
                                
    if {$methods == "WS"} {
        set aV(solverMethod) wander       ;# wander or meander or reverse
        set aV(isSimple)     NA           ;# isSimple if NA (tableau if FALSE)
    } elseif {$methods == "WT"} {
        set aV(solverMethod) wander       ;# wander or meander or reverse
        set aV(isSimple)     FALSE        ;# isSimple if NA (tableau if FALSE)
    } elseif {$methods == "MS"} {
        set aV(solverMethod) meander      ;# wander or meander or reverse
        set aV(isSimple)     NA           ;# isSimple if NA (tableau if FALSE)
    } elseif {$methods == "MT"} {
        set aV(solverMethod) meander      ;# wander or meander or reverse
        set aV(isSimple)     FALSE        ;# isSimple if NA (tableau if FALSE)
    }
    set argsList "$aV(rulerMarks) $aV(seedInit) $aV(coordInit) $aV(rankInit) \
      $aV(isSimple) $aV(solverMethod) $aV(writeVar) $aV(isWalkTables)" 
    
    set aV(commandLine) "B.ogr.main $argsList"
    
    # initialize all variables
    B.ogr.init
    if {$isInitOnly} {
        puts ".. from B.ogr.init (for isInitOnly = 1)"
        parray aV ; return
    }
    
    puts "# .. variables have been initialized, \
      proceeding with the search under method=saw_${aV(solverMethod)}\
      with option isSimple=$aV(isSimple)"
    
    if {$aV(solverMethod) == "wander"} {
        
        B.ogr.saw_wander
        
    } elseif {$aV(solverMethod) == "meander"} {
        
        if {$aV(isSimple)} {
            B.ogr.saw_meander_simple
        } else {
            B.ogr.saw_meander 
        }
    } elseif {$aV(solverMethod) == "reverse"} {
        
        B.ogr.saw_reverse
        
    } else {
        error "ERROR from $thisCmd:\nsolverMethod = $aV(solverMethod) is not supported"
    }
#!! return results in a standardized name-valueString format
    # (instanceDef is the first keyword name) 
    B.ogr.stdout [set withWarning 1] 
    
    if {$aV(isWalkTables)} {
        walk.tables $aV(solverID) $aV(instanceDef)\
          $aV(seedInit) $aV(walkLength) [array get aWalkProbed]
    }
    return
        
} ;# B.ogr.main

proc B.ogr.main_old { rulerMarks  {isInitOnly 0} } {   
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.ogr.main 
set ABOUT \
"
"
    #if {$instanceDef == "??"} { puts $ABOUT ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
    
    set xPerimentAll 1
    if {$xPerimentAll} {
        # initialize under xPeriment*.tcl
        foreach name "all_info all_valu aV aStruc aCoordHash0 aWalkProbed" {
            eval "array unset $name" ;# puts "unsetting array $name"
        }
        set aV(runtimeLmt)   3600
        set aV(solverMethod) meander     ;# wander or meander or reverse
        set aV(seedInit)     NA          ;# random integer if NA, use 7407 for m=5
        set aV(isSimple)     FALSE       ;# isSimple if NA (tableau if FALSE)
    }
    # until we implement "proper commandLine", we enter all input variables HERE        
    set aV(rulerMarks)   $rulerMarks ;# required value: 4 or 5 or 6 or 7 or ....
         

    
    set aV(coordInit)    NA          ;# random binary coordinate if NA
    set aV(rankInit)     NA          ;# (rulerMarks - 3) if NA

    set aV(writeVar)     0           ;# 0 or 3
    set aV(isWalkTables) 0           ;# 0 or 1
    
    set aV(neighbBestPercent) NA ;# percent_neigbBest, 
                                ;# if NA, take the first best neighbor
    
    set argsList "$aV(rulerMarks) $aV(seedInit) $aV(coordInit) $aV(rankInit) \
      $aV(isSimple) $aV(solverMethod) $aV(writeVar) $aV(isWalkTables)" 
    
    set aV(commandLine) "B.ogr.main $argsList"
    
    # initialize all variables
    B.ogr.init
    if {$isInitOnly} {
        puts ".. from B.ogr.init (for isInitOnly = 1)"
        parray aV ; return
    }
    
    puts "# .. variables have been initialized, \
      proceeding with the search under method=saw_${aV(solverMethod)}\
      with option isSimple=$aV(isSimple)"
    
    if {$aV(solverMethod) == "wander"} {
        
        B.ogr.saw_wander
        
    } elseif {$aV(solverMethod) == "meander"} {
        
        if {$aV(isSimple)} {
            B.ogr.saw_meander_simple1
        } else {
            B.ogr.saw_meander 
        }
    } elseif {$aV(solverMethod) == "reverse"} {
        
        B.ogr.saw_reverse
        
    } else {
        error "ERROR from $thisCmd:\nsolverMethod = $aV(solverMethod) is not supported"
    }
#!! return results in a standardized name-valueString format
    # (instanceDef is the first keyword name) 
    B.ogr.stdout [set withWarning 1] 
    
    if {$aV(isWalkTables)} {
        walk.tables $aV(solverID) $aV(instanceDef)\
          $aV(seedInit) $aV(walkLength) [array get aWalkProbed]
    }
    return
        
} ;# B.ogr.main

    
    

proc B.ogr.saw_wander {{ABOUT ""}} {
    #-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.ogr.saw_wander
set ABOUT \
  "Procedure $thisCmd takes global array values initialized under B.ogr.init
 and constructs a segment of a self-avoiding walk (SAW). Either B.ogr.saw_pivot_simple 
 or the significantly more efficient procedure B.ogr.saw_pivot.ant is invoked.
 More to come ...."
    if {$ABOUT == "??"} { puts $ABOUT ; return }
    if {$ABOUT == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
#!! global variable names MUST be listed HERE
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
    
    # relevant primary input variables (remaining constant)
    set runtimeLmt      $aV(runtimeLmt) 
    set cntProbeLmt     $aV(cntProbeLmt) 
    set walkLengthLmt   $aV(walkLengthLmt)
    set walkSegmLmt     $aV(walkSegmLmt)
    set valueTarget     $aV(valueTarget) ;# parray aV
    
    if {$aV(isSimple)} {
        set procPivotNext  B.ogr.fAdj_simple
    } else {
        set procPivotNext  B.ogr.fAdj
    } 
    puts "\# FROM: $thisCmd, searching for pivotBest via $procPivotNext**"
    # auxiliary variables (changing dynamically)
    set aV(coordBest) $aV(coordInit)  ; set aV(valueBest) $aV(valueInit)
    set    coord      $aV(coordInit)  ; set    value      $aV(valueInit)
    set    step       0                      

    while {1} {       
        #!! #** timing starts ***  
        set microSecs [lindex [time {
            
            #puts \nstep=$step...coordPivot=$coord
            # PROBE the neighborhood of the current pivot
            set bestNeighb [$procPivotNext  $coord  $value]
                
            # SELECT the next pivot from bestNeighb
            set coordNext      [lindex $bestNeighb 0] 
            set valueNext      [lindex $bestNeighb 1]
            set neighbSize     [lindex $bestNeighb 2]
            # this hash array is critical to maintaining a SAW segment!!
            set aCoordHash0($coordNext) {}
            
        } 1 ] 0 ]
        #!! #** timing ends *** 
        # RECORD runtime for current step
        set aV(runtime)      [expr {$aV(runtime) + ($microSecs/1e6)}]
        set aV(speedProbe)   [expr {int($aV(cntProbe)/$aV(runtime))}]
    
        # UPDATE valueBest, aValueBest
        if {$valueNext <=  $aV(valueBest)} {  
            set aV(valueBest) $valueNext 
            set aV(coordBest) $coordNext 
        }       
        if {$aV(isWalkTables)} {
            set aV(coordProbedList) [lindex $bestNeighb 3]
            set aV(valueProbedList) [lindex $bestNeighb 4]

            set cntNeighb 0 ; set isPivot 0
            foreach coordPr $aV(coordProbedList) valuePr $aV(valueProbedList) {
                #puts coordPr=$coordPr...$valuePr
                incr cntNeighb 
                set rankPr [B.coord.rank $coordPr]
                set aWalkProbed([format "%05d" $step],$cntNeighb) \
                  "$step $aV(cntRestart)\
                  $coordPr $valuePr $rankPr $isPivot $cntNeighb NA"  
            }
            set isPivot 1 ; set neighbSize $cntNeighb
            set rank   [B.coord.rank $coord]
            set aWalkProbed([format "%05d" $step],0) "$step $aV(cntRestart)\
              $coord  $value $rank $isPivot $cntNeighb \
              $aV(cntProbe)"
        }
        if {$neighbSize == 0} {
            # CHECK the neighborhoodSize
            set aV(isTrapped) 1 
            set aV(speedProbe) [expr {int($aV(cntProbe)/(1e-9 + $aV(runtime)))}] 
            puts "# WARNING from $thisCmd: isTrapped=1, neighbSize=$neighbSize, there are\
              no free adjacent coordinates ..." 
            break   
        }
        if {$aV(valueBest) <= $valueTarget} {
            incr step ; set aV(walkLength) $step
            if {$aV(isWalkTables)} {
                set isPivot 1 
                set rank  [B.coord.rank $aV(coordBest)]
                set aWalkProbed([format "%05d" $step],0) "$step $aV(cntRestart)\
                  $aV(coordBest) $aV(valueBest) $rank  $isPivot $cntNeighb \
                  $aV(cntProbe)"    
            }
            break
        } else {
            # UPDATE coord, value, walkLength 
            incr step ; set aV(walkLength) $step
            set  coord  $coordNext  ; set value $valueNext
            #puts ".. updated walkLength, next step = $aV(walkLength)"
        }
        if {$aV(cntProbe) > $cntProbeLmt} {
            set aV(isCensored) 1 ; set aV(speedProbe) [expr {int($aV(cntProbe)/$aV(runtime))}] 
            puts "# WARNING from $thisCmd: isCensored=1, cntProbe=$aV(cntProbe) >\
              cntProbeLmt=$aV(cntProbeLmt)" ;  break 
        }
        if {$step == $walkLengthLmt} {
            set aV(isCensored) 1 ; set aV(speedProbe) [expr {int($aV(cntProbe)/$aV(runtime))}] 
            puts "# WARNING from $thisCmd: isCensored=1, step=$step >\
              walkLengthLmt=$aV(walkLengthLmt)" ; break
        }
        if {$aV(runtime) > $runtimeLmt} {
            set aV(isCensored) 1 ; set aV(speedProbe) [expr {int($aV(cntProbe)/$aV(runtime))}] 
            puts "# WARNING from $thisCmd: isCensored=1, runtime=$aV(runtime) >\
              runtimeLmt=$aV(runtimeLmt)" ;  break
        }
    } ;#  while {1} 
    
    # RESOLVE whether valueBest reached or exceeded valueTarget
    if {$aV(valueBest) == $aV(valueTarget)} {
        set aV(targetReached) 1 ; set aV(isCensored) 0
    } elseif {$aV(valueBest) < $aV(valueTarget)} {
        set aV(targetReached) 2 ; set aV(isCensored) 0
    } else {
        set aV(targetReached) 0 ; set aV(isCensored) 1
    }
    #parray aV
    return  $aV(targetReached)
#~dd
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xProj/B.ogr/xWork
# % source ../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# % 
# % B.ogr.main 7
# # .. variables have been initialized,  proceeding with the search under method = wander
# # FROM: B.ogr.saw_wander, searching for pivotBest via B.ogr.fAdj_simple**
# # FROM B.ogr.stdout: A SUMMARY OF NAME-VALUE PAIRS 
# # commandLine = B.ogr.main 7 NA NA NA  NA wander 0 0 
# #    dateLine = Thu Aug 27 16:11:06 EDT 2015  
# #   timeStamp = 20150827201106  
# #
# instanceDef		7,25
# solverID		B.ogr-wander
# solverMethod		wander
# isSimple		TRUE
# coordInit		010110000000000100000010
# coordBest		100000100010000000010010
# rulerInit		0,2,4,5,16,23,25
# rulerBest		0,1,7,11,20,23,25
# nDim		24
# walkLengthLmt		2147483647
# walkLength		14
# cntRestartLmt		2147483647
# cntRestart		0
# cntProbeLmt		2147483647
# cntProbe		322
# runtimeLmt		5
# runtime		0.021
# speedProbe		15363
# hostID		brglez@triangle-Darwin-14.5.0
# compiler		tcl-8.5.8
# walkSegmLmt		NA
# walkSegmCoef		NA
# seedInit		8814
# valueInit		-1
# valueBest		-5
# valueTarget		-5
# valueTol		0.0
# targetReached		1
# isCensored		0
# 
# % B.ogr.main 7
# # .. variables have been initialized,  proceeding with the search under method = wander
# # FROM: B.ogr.saw_wander, searching for pivotBest via B.ogr.fAdj_simple**
# # FROM B.ogr.stdout: A SUMMARY OF NAME-VALUE PAIRS 
# # commandLine = B.ogr.main 7 NA NA NA  NA wander 0 0 
# #    dateLine = Thu Aug 27 16:11:20 EDT 2015  
# #   timeStamp = 20150827201120  
# #
# instanceDef		7,25
# solverID		B.ogr-wander
# solverMethod		wander
# isSimple		TRUE
# coordInit		000000110000010000000011
# coordBest		001100000001000001000010
# rulerInit		0,7,8,14,23,24,25
# rulerBest		0,3,4,12,18,23,25
# nDim		24
# walkLengthLmt		2147483647
# walkLength		20
# cntRestartLmt		2147483647
# cntRestart		0
# cntProbeLmt		2147483647
# cntProbe		461
# runtimeLmt		5
# runtime		0.03
# speedProbe		15191
# hostID		brglez@triangle-Darwin-14.5.0
# compiler		tcl-8.5.8
# walkSegmLmt		NA
# walkSegmCoef		NA
# seedInit		35
# valueInit		0
# valueBest		-5
# valueTarget		-5
# valueTol		0.0
# targetReached		1
# isCensored		0
# 
# % B.ogr.main 8
# # .. variables have been initialized,  proceeding with the search under method = wander
# # FROM: B.ogr.saw_wander, searching for pivotBest via B.ogr.fAdj_simple**
# # FROM B.ogr.stdout: A SUMMARY OF NAME-VALUE PAIRS 
# # commandLine = B.ogr.main 8 NA NA NA  NA wander 0 0 
# #    dateLine = Thu Aug 27 16:11:30 EDT 2015  
# #   timeStamp = 20150827201129  
# #
# instanceDef		8,34
# solverID		B.ogr-wander
# solverMethod		wander
# isSimple		TRUE
# coordInit		000001100100000000000001010100000
# coordBest		010000000001000000100000100001001
# rulerInit		0,6,7,10,24,26,28,34
# rulerBest		0,2,12,19,25,30,33,34
# nDim		33
# walkLengthLmt		2147483647
# walkLength		434
# cntRestartLmt		2147483647
# cntRestart		0
# cntProbeLmt		2147483647
# cntProbe		13844
# runtimeLmt		5
# runtime		1.11
# speedProbe		12499
# hostID		brglez@triangle-Darwin-14.5.0
# compiler		tcl-8.5.8
# walkSegmLmt		NA
# walkSegmCoef		NA
# seedInit		8031
# valueInit		1
# valueBest		-6
# valueTarget		-6
# valueTol		0.0
# targetReached		1
# isCensored		0
# 
# % B.ogr.main 8
# # .. variables have been initialized,  proceeding with the search under method = wander
# # FROM: B.ogr.saw_wander, searching for pivotBest via B.ogr.fAdj_simple**
# # FROM B.ogr.stdout: A SUMMARY OF NAME-VALUE PAIRS 
# # commandLine = B.ogr.main 8 NA NA NA  NA wander 0 0 
# #    dateLine = Thu Aug 27 16:12:13 EDT 2015  
# #   timeStamp = 20150827201210  
# #
# instanceDef		8,34
# solverID		B.ogr-wander
# solverMethod		wander
# isSimple		TRUE
# coordInit		001000000010010000110000000010000
# coordBest		010000000001000000100000100001001
# rulerInit		0,3,11,14,19,20,29,34
# rulerBest		0,2,12,19,25,30,33,34
# nDim		33
# walkLengthLmt		2147483647
# walkLength		1262
# cntRestartLmt		2147483647
# cntRestart		0
# cntProbeLmt		2147483647
# cntProbe		40185
# runtimeLmt		5
# runtime		3.22
# speedProbe		12470
# hostID		brglez@triangle-Darwin-14.5.0
# compiler		tcl-8.5.8
# walkSegmLmt		NA
# walkSegmCoef		NA
# seedInit		6582
# valueInit		2
# valueBest		-6
# valueTarget		-6
# valueTol		0.0
# targetReached		1
# isCensored		0
#  
# % B.ogr.main 8
# # .. variables have been initialized,  proceeding with the search under method = wander
# # FROM: B.ogr.saw_wander, searching for pivotBest via B.ogr.fAdj_simple**
# # WARNING from B.ogr.saw_wander: isCensored=1, runtime=5.000957000000003 > runtimeLmt=5
# # FROM B.ogr.stdout: A SUMMARY OF NAME-VALUE PAIRS 
# # commandLine = B.ogr.main 8 NA NA NA  NA wander 0 0 
# #    dateLine = Thu Aug 27 16:16:36 EDT 2015  
# #   timeStamp = 20150827201631  
# #
# instanceDef		8,34
# solverID		B.ogr-wander
# solverMethod		wander
# isSimple		TRUE
# coordInit		000001010000101000000000010000010
# coordBest		010000000001001000000000000010001
# rulerInit		0,6,8,13,15,26,32,34
# rulerBest		0,2,12,15,29,33,34
# nDim		33
# walkLengthLmt		2147483647
# walkLength		1955
# cntRestartLmt		2147483647
# cntRestart		0
# cntProbeLmt		2147483647
# cntProbe		62131
# runtimeLmt		5
# runtime		5.0
# speedProbe		12424
# hostID		brglez@triangle-Darwin-14.5.0
# compiler		tcl-8.5.8
# walkSegmLmt		NA
# walkSegmCoef		NA
# seedInit		8329
# valueInit		3
# valueBest		-5
# valueTarget		-6
# valueTol		0.0
# targetReached		0
# isCensored		1
# % 
# Copyright:
# Franc Brglez, Tue Apr 21 16:19:47 EDT 2015
#~dd 
} ;# proc B.ogr.saw

#------- keep here as a 80-character reference line to check text width -------#


proc B.ogr.saw_meander_simple {{ABOUT ""}} {
    #-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.ogr.saw_meander_simple1
set ABOUT \
  "Procedure $thisCmd takes global array values initialized under B.ogr.init
 and constructs a segment of a self-avoiding walk (SAW). Either B.ogr.saw_pivot_simple 
 or the significantly more efficient procedure B.ogr.saw_pivot.ant is invoked.
 More to come ...."
    if {$ABOUT == "??"} { puts $ABOUT ; return }
    if {$ABOUT == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
#!! global variable names MUST be listed HERE
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
    
    # relevant primary input variables (remaining constant)
    set runtimeLmt      $aV(runtimeLmt) 
    set cntProbeLmt     $aV(cntProbeLmt) 
    set walkLengthLmt   $aV(walkLengthLmt)
    set walkSegmLmt     $aV(walkSegmLmt)
    set valueTarget     $aV(valueTarget) ;# parray aV
    
#     if {$aV(isSimple)} {
#         set procPivotNext  B.ogr.fAdj_simple
#     } else {
#         set procPivotNext  B.ogr.fAdj
#     } 
    puts "\# FROM: $thisCmd, searching for pivotBest**"
    # auxiliary variables (changing dynamically)
    set aV(coordBest) $aV(coordInit)  ; set aV(valueBest) $aV(valueInit)
    set    coord      $aV(coordInit)  ; set    value      $aV(valueInit)
    set    step       0   
    
### NOTE: pivot at step 0 has coordInit with rankInit = (rulerMarks - 3)
###       pivot at step 1 has coord     with rank     = (rulerMarks - 2)
###       pivot at step 2 has coord     with rank     = (rulerMarks - 3)
###       pivot at step 3 has coord     with rank     = (rulerMarks - 2)
###       etc
### ALSO: before step 1, invoke B.ogr.fAdj_simple_up
###       before step 2, invoke B.ogr.fAdj_simple_dn
###       before step 3, invoke B.ogr.fAdj_simple_up
###       etc
###       valueBest=valueTarget can only be found with B.ogr.fAdj_simple_up
    
    while {1} {       
        #!! #** timing starts ***  
        set microSecs [lindex [time {
            
            #puts \nstep=$step...coordPivot=$coord
            # PROBE the neighborhood of the current pivot
            array unset coordAry ; array unset valueAry
            if {!($step % 2)} {
                set procPivotNext "B.ogr.fAdj_simple_up"
                # do a single call to $procPivotNext to select coordNext
                set bestNeighb [$procPivotNext  $coord  $value]
                # SELECT the next pivot from bestNeighb
                set coordNext      [lindex $bestNeighb 0] 
                set valueNext      [lindex $bestNeighb 1]
                set neighbSize     [lindex $bestNeighb 2]
                #puts "\n** step=$step, single call to $procPivotNext, coordPiv=$coord, valuePiv=$value,\
                  neighbSize=$neighbSize, coordNext=$coordNext,\
                  valueNext=$valueNext"
                
            } else {
                set procPivotNext "B.ogr.fAdj_simple_dn"
                set bestNeighb [$procPivotNext  $coord  $value]
                # SELECT the next pivot from bestNeighb
                set coordNext      [lindex $bestNeighb 0] 
                set valueNext      [lindex $bestNeighb 1]
                set neighbSize     [lindex $bestNeighb 2]
                #array set coordAry [lindex $bestNeighb 3]
                #array set valueAry [lindex $bestNeighb 4]
                #set coordBestUp $coordAry(1)
                #set valueBestUp $valueAry(1)
                #puts "\n** step=$step, single call to $procPivotNext, coordPiv=$coord, valuePiv=$value,\
                  neighbSize=$neighbSize, coordNext=$coordNext,\
                  valueNext=$valueNext"
            }
            # this hash array is critical to maintaining a SAW segment!!
            set aCoordHash0($coordNext) {}
            
        } 1 ] 0 ]
        #!! #** timing ends *** 
        # RECORD runtime for current step
        set aV(runtime)      [expr {$aV(runtime) + ($microSecs/1e6)}]
        set aV(speedProbe)   [expr {int($aV(cntProbe)/$aV(runtime))}]
    
        # UPDATE valueBest, aValueBest
        if {$valueNext <=  $aV(valueBest)} {  
            set aV(valueBest) $valueNext 
            set aV(coordBest) $coordNext 
        }       
        if {$aV(isWalkTables)} {
            set aV(coordProbedList) [lindex $bestNeighb 3]
            set aV(valueProbedList) [lindex $bestNeighb 4]

            set cntNeighb 0 ; set isPivot 0
            foreach coordPr $aV(coordProbedList) valuePr $aV(valueProbedList) {
                #puts coordPr=$coordPr...$valuePr
                incr cntNeighb 
                set rankPr [B.coord.rank $coordPr]
                set aWalkProbed([format "%05d" $step],$cntNeighb) \
                  "$step $aV(cntRestart)\
                  $coordPr $valuePr $rankPr $isPivot $cntNeighb NA"  
            }
            set isPivot 1 ; set neighbSize $cntNeighb
            set rank   [B.coord.rank $coord]
            set aWalkProbed([format "%05d" $step],0) "$step $aV(cntRestart)\
              $coord  $value $rank $isPivot $cntNeighb \
              $aV(cntProbe)"
        }
        if {$neighbSize == 0} {
            # CHECK the neighborhoodSize
            set aV(isTrapped) 1 
            set aV(speedProbe) [expr {int($aV(cntProbe)/(1e-9 + $aV(runtime)))}] 
            puts "# WARNING from $thisCmd: isTrapped=1, neighbSize=$neighbSize, there are\
              no free adjacent coordinates ..." 
            break   
        }
        if {$aV(valueBest) <= $valueTarget} {
            incr step ; set aV(walkLength) $step
            if {$aV(isWalkTables)} {
                set isPivot 1 
                set rank  [B.coord.rank $aV(coordBest)]
                set aWalkProbed([format "%05d" $step],0) "$step $aV(cntRestart)\
                  $aV(coordBest) $aV(valueBest) $rank  $isPivot $cntNeighb \
                  $aV(cntProbe)"    
            }
            break
        } else {
            # UPDATE coord, value, walkLength 
            incr step ; set aV(walkLength) $step
            set  coord  $coordNext  ; set value $valueNext
            #puts ".. updated walkLength, next step = $aV(walkLength)"
        }
        if {$aV(cntProbe) > $cntProbeLmt} {
            set aV(isCensored) 1 ; set aV(speedProbe) [expr {int($aV(cntProbe)/$aV(runtime))}] 
            puts "# WARNING from $thisCmd: isCensored=1, cntProbe=$aV(cntProbe) >\
              cntProbeLmt=$aV(cntProbeLmt)" ;  break 
        }
        if {$step == $walkLengthLmt} {
            set aV(isCensored) 1 ; set aV(speedProbe) [expr {int($aV(cntProbe)/$aV(runtime))}] 
            puts "# WARNING from $thisCmd: isCensored=1, step=$step >\
              walkLengthLmt=$aV(walkLengthLmt)" ; break
        }
        if {$aV(runtime) > $runtimeLmt} {
            set aV(isCensored) 1 ; set aV(speedProbe) [expr {int($aV(cntProbe)/$aV(runtime))}] 
            puts "# WARNING from $thisCmd: isCensored=1, runtime=$aV(runtime) >\
              runtimeLmt=$aV(runtimeLmt)" ;  break
        }
    } ;#  while {1} 
    
    # RESOLVE whether valueBest reached or exceeded valueTarget
    if {$aV(valueBest) == $aV(valueTarget)} {
        set aV(targetReached) 1 ; set aV(isCensored) 0
    } elseif {$aV(valueBest) < $aV(valueTarget)} {
        set aV(targetReached) 2 ; set aV(isCensored) 0
    } else {
        set aV(targetReached) 0 ; set aV(isCensored) 1
    }
    #parray aV
    return  $aV(targetReached)
#~dd
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xProj/B.ogr/xWork
# % source ../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# % 
# % B.ogr.main 7

# % 
# Copyright:
# Franc Brglez, Tue Apr 21 16:19:47 EDT 2015
#~dd 
} ;# B.ogr.saw_meander_simple

#------- keep here as a 80-character reference line to check text width -------#


proc B.ogr.saw_meander  {{ABOUT ""}} {
    #-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.ogr.saw_meander 
set ABOUT \
  "Procedure $thisCmd takes global array values initialized under B.ogr.init
 and constructs a segment of a self-avoiding walk (SAW). Either B.ogr.saw_pivot_simple 
 or the significantly more efficient procedure B.ogr.saw_pivot.ant is invoked.
 More to come ...."
    if {$ABOUT == "??"} { puts $ABOUT ; return }
    if {$ABOUT == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
#!! global variable names MUST be listed HERE
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
    
    # relevant primary input variables (remaining constant)
    set runtimeLmt      $aV(runtimeLmt) 
    set cntProbeLmt     $aV(cntProbeLmt) 
    set walkLengthLmt   $aV(walkLengthLmt)
    set walkSegmLmt     $aV(walkSegmLmt)
    set valueTarget     $aV(valueTarget) ;# parray aV
    
#     if {$aV(isSimple)} {
#         set procPivotNext  B.ogr.fAdj_simple
#     } else {
#         set procPivotNext  B.ogr.fAdj
#     } 
    puts "\# FROM: $thisCmd, searching for pivotBest**"
    # auxiliary variables (changing dynamically)
    set aV(coordBest) $aV(coordInit)  ; set aV(valueBest) $aV(valueInit)
    set    coord      $aV(coordInit)  ; set    value      $aV(valueInit)
    set    step       0   
    
### NOTE: pivot at step 0 has coordInit with rankInit = (rulerMarks - 3)
###       pivot at step 1 has coord     with rank     = (rulerMarks - 2)
###       pivot at step 2 has coord     with rank     = (rulerMarks - 3)
###       pivot at step 3 has coord     with rank     = (rulerMarks - 2)
###       etc
### ALSO: before step 1, invoke B.ogr.fAdj_simple_up
###       before step 2, invoke B.ogr.fAdj_simple_dn
###       before step 3, invoke B.ogr.fAdj_simple_up
###       etc
###       valueBest=valueTarget can only be found with B.ogr.fAdj_simple_up
    
    while {1} {       
        #!! #** timing starts ***  
        set microSecs [lindex [time {
            
            #puts \nstep=$step...coordPivot=$coord
            # PROBE the neighborhood of the current pivot
            array unset coordAry ; array unset valueAry
            if {!($step % 2)} {
                set procPivotNext "B.ogr.fAdj_up"
                # do a single call to $procPivotNext to select coordNext
                set bestNeighb [$procPivotNext  $coord  $value]
                # SELECT the next pivot from bestNeighb
                set coordNext      [lindex $bestNeighb 0] 
                set valueNext      [lindex $bestNeighb 1]
                set neighbSize     [lindex $bestNeighb 2]
                #puts "\n** step=$step, single call to $procPivotNext, coordPiv=$coord, valuePiv=$value,\
                  neighbSize=$neighbSize, coordNext=$coordNext,\
                  valueNext=$valueNext"
                
            } else {
                set procPivotNext "B.ogr.fAdj_dn"
                set bestNeighb [$procPivotNext  $coord  $value]
                # SELECT the next pivot from bestNeighb
                set coordNext      [lindex $bestNeighb 0] 
                set valueNext      [lindex $bestNeighb 1]
                set neighbSize     [lindex $bestNeighb 2]
                #array set coordAry [lindex $bestNeighb 3]
                #array set valueAry [lindex $bestNeighb 4]
                #set coordBestUp $coordAry(1)
                #set valueBestUp $valueAry(1)
                #puts "\n** step=$step, single call to $procPivotNext, coordPiv=$coord, valuePiv=$value,\
                  neighbSize=$neighbSize, coordNext=$coordNext,\
                  valueNext=$valueNext"
            }
            # this hash array is critical to maintaining a SAW segment!!
            set aCoordHash0($coordNext) {}
            
        } 1 ] 0 ]
        #!! #** timing ends *** 
        # RECORD runtime for current step
        set aV(runtime)      [expr {$aV(runtime) + ($microSecs/1e6)}]
        set aV(speedProbe)   [expr {int($aV(cntProbe)/$aV(runtime))}]
    
        # UPDATE valueBest, aValueBest
        if {$valueNext <=  $aV(valueBest)} {  
            set aV(valueBest) $valueNext 
            set aV(coordBest) $coordNext 
        }       
        if {$aV(isWalkTables)} {
            set aV(coordProbedList) [lindex $bestNeighb 3]
            set aV(valueProbedList) [lindex $bestNeighb 4]

            set cntNeighb 0 ; set isPivot 0
            foreach coordPr $aV(coordProbedList) valuePr $aV(valueProbedList) {
                #puts coordPr=$coordPr...$valuePr
                incr cntNeighb 
                set rankPr [B.coord.rank $coordPr]
                set aWalkProbed([format "%05d" $step],$cntNeighb) \
                  "$step $aV(cntRestart)\
                  $coordPr $valuePr $rankPr $isPivot $cntNeighb NA"  
            }
            set isPivot 1 ; set neighbSize $cntNeighb
            set rank   [B.coord.rank $coord]
            set aWalkProbed([format "%05d" $step],0) "$step $aV(cntRestart)\
              $coord  $value $rank $isPivot $cntNeighb \
              $aV(cntProbe)"
        }
        if {$neighbSize == 0} {
            # CHECK the neighborhoodSize
            set aV(isTrapped) 1 
            set aV(speedProbe) [expr {int($aV(cntProbe)/(1e-9 + $aV(runtime)))}] 
            puts "# WARNING from $thisCmd: isTrapped=1, neighbSize=$neighbSize, there are\
              no free adjacent coordinates ..." 
            break   
        }
        if {$aV(valueBest) <= $valueTarget} {
            incr step ; set aV(walkLength) $step
            if {$aV(isWalkTables)} {
                set isPivot 1 
                set rank  [B.coord.rank $aV(coordBest)]
                set aWalkProbed([format "%05d" $step],0) "$step $aV(cntRestart)\
                  $aV(coordBest) $aV(valueBest) $rank  $isPivot $cntNeighb \
                  $aV(cntProbe)"    
            }
            break
        } else {
            # UPDATE coord, value, walkLength 
            incr step ; set aV(walkLength) $step
            set  coord  $coordNext  ; set value $valueNext
            #puts ".. updated walkLength, next step = $aV(walkLength)"
        }
        if {$aV(cntProbe) > $cntProbeLmt} {
            set aV(isCensored) 1 ; set aV(speedProbe) [expr {int($aV(cntProbe)/$aV(runtime))}] 
            puts "# WARNING from $thisCmd: isCensored=1, cntProbe=$aV(cntProbe) >\
              cntProbeLmt=$aV(cntProbeLmt)" ;  break 
        }
        if {$step == $walkLengthLmt} {
            set aV(isCensored) 1 ; set aV(speedProbe) [expr {int($aV(cntProbe)/$aV(runtime))}] 
            puts "# WARNING from $thisCmd: isCensored=1, step=$step >\
              walkLengthLmt=$aV(walkLengthLmt)" ; break
        }
        if {$aV(runtime) > $runtimeLmt} {
            set aV(isCensored) 1 ; set aV(speedProbe) [expr {int($aV(cntProbe)/$aV(runtime))}] 
            puts "# WARNING from $thisCmd: isCensored=1, runtime=$aV(runtime) >\
              runtimeLmt=$aV(runtimeLmt)" ;  break
        }
    } ;#  while {1} 
    
    # RESOLVE whether valueBest reached or exceeded valueTarget
    if {$aV(valueBest) == $aV(valueTarget)} {
        set aV(targetReached) 1 ; set aV(isCensored) 0
    } elseif {$aV(valueBest) < $aV(valueTarget)} {
        set aV(targetReached) 2 ; set aV(isCensored) 0
    } else {
        set aV(targetReached) 0 ; set aV(isCensored) 1
    }
    #parray aV
    return  $aV(targetReached)
#~dd
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xProj/B.ogr/xWork
# % source ../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# % 
# % B.ogr.main 7

# % 
# Copyright:
# Franc Brglez, Tue Apr 21 16:19:47 EDT 2015
#~dd 
} ;# B.ogr.saw_meander 


proc B.ogr.fAdj_simple_up { {coordPiv 01010} {valuePiv 1} } {   
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.ogr.fAdj_simple_up
set ABOUT \
" 
         $thisCmd coordPiv
Example: $thisCmd $coordPiv

NEEDS EDITS ...
The command  $thisCmd takes a binary coordinate such as 0101010
which has length L = 7 and rank r = 3. This command returns a subset of 
** adjacent coordinates **,  all with the Hamming distance of 1 from the 
input coordinate and with rank (r-1). The size of this subset is r.
For input coordinate of rank 0, this command returns an empty set.
"
    if {$coordPiv == "??"} { puts $ABOUT ; return }
    if {$coordPiv == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
        
    set coordBest  NA ; set valueBest 2147483641 ; set valueProbedList {}
    set neighbSize 0  ; set coordBestList  {}    ; set coordProbedList {}
    
    set L          $aV(L)
    set rankTarget $aV(rankTarget)
    
    if {$aV(writeVar) == 3} {
        set distance 0 ; 
        set rank [B.coord.rank $coordPiv]
        set rowLines "FROM: $thisCmd\
          \nProbing ALL distance=1 neighbors of the\ninitial pivot\
          coordinate = $coordPiv\
          \ncntProbe\tIdx\tcoordPivot\tvalPivot\tcoordAdj\tvalAdj\tdist\trank\
          \n~\t~\t$coordPiv\t$valuePiv\t~\t~\t$distance\t$rank\n"
    }
    for {set i 0} {$i < $L} {incr i} {  
        
        set bit [string index $coordPiv $i]
        if {!$bit} {
            # increase the rank of coordAdj by 1
            set coordAdj [string replace $coordPiv $i $i 1]
            #set mAdj     [expr {$mPiv + 1}]

            ##!! To maintain a self-avoiding walk, coordinates from the walk
            ##!! should be excluded from the neighborhood of the current pivot.
            #parray aCoordHash0  
            if {![info exists aCoordHash0($coordAdj)]} {
                incr neighbSize
                set valueAdj [B.ogr.f $coordAdj $rankTarget] ; incr aV(cntProbe)
                lappend valueAry($valueAdj) $coordAdj
                
                if {$aV(isWalkTables)} {
                    lappend coordProbedList $coordAdj
                    lappend valueProbedList $valueAdj
                }
                #!! aggregate coordBestList for random selection later
                if {$valueAdj <= $valueBest} {
                    if {$valueAdj < $valueBest} {set coordBestList {}}
                    set valueBest $valueAdj ; set coordBest $coordAdj
                    lappend coordBestList $coordBest
                }
                if {$aV(writeVar) == 3} {
                    set distance [B.coord.distance  $coordAdj  $coordPiv]
                    set rank     [B.coord.rank $coordAdj]
                    append rowLines $aV(cntProbe)\t$i\t$coordBest\t$valueBest\
                      \t$coordAdj\t$valueAdj\t$distance\t$rank\n
                }
            }
        }
    }
    if {$aV(writeVar) == 3} {puts "$rowLines --neighbSize=$neighbSize"}
    
    #!! randomize the choice of coordBest from coordBestList 
    set idx [expr {int([llength $coordBestList]*rand())}]
    set coordBest [lindex $coordBestList $idx]
    
    # create a coord-value pair of priority arrays
    set idx 0 
    foreach value [lsort -integer [array names valueAry]] {
        foreach coord $valueAry($value) {
            incr idx
            set coordProbedAry($idx) $coord
            set valueProbedAry($idx) $value
        }
    }
    if {$neighbSize > 0} {
        return "$coordBest $valueBest $neighbSize \
          [list [array get coordProbedAry]] [list [array get valueProbedAry]] \
          [list $coordProbedList] [list $valueProbedList]"
    } else {
        return "NA NA $neighbSize {} {}"
    }
#~dd
# % source ../xLib/all_tcl
# .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
#   
# % B.ogr.main 4 1
# aV(L)             = 5
# aV(instanceDef)   = 4,6
# aV(coordInit)     = 10100
# aV(valueInit)     = -1
# aV(writeVar)      = 3
# 
# % B.ogr.fAdj_simple_up 10100 -1
# FROM: B.ogr.fAdj_simple_up 
# Probing ALL distance=1 neighbors of the
# initial pivot coordinate = 10100 
# cntProbe	Idx	coordPivot	valPivot	coordAdj	valAdj	dist	rank 
# ~	~	10100	-1	~	~	0	2
# 8	1	11100	4	11100	4	1	3
# 9	3	10110	4	10110	4	1	3
# 10	4	10101	4	10101	4	1	3
#  --neighbSize=3
# 11100 4 3  {1 11100 2 10110 3 10101} {1 4 2 4 3 4}  {} {}
# % 
#
# Copyright: 
# Franc Brglez, Sat Aug 29 11:40:40 EDT 2015
#~dd 
} ;# B.ogr.fAdj_simple_up

proc B.ogr.fAdj_simple_dn { {coordPiv 01010} {valuePiv 1} } {   
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.ogr.fAdj_simple_dn
set ABOUT \
" 
         $thisCmd coordPiv
Example: $thisCmd $coordPiv

NEEDS EDITS ...
The command  $thisCmd takes a binary coordinate such as 0101010
which has length L = 7 and rank r = 3. This command returns a subset of 
** adjacent coordinates **,  all with the Hamming distance of 1 from the 
input coordinate and with rank (r-1). The size of this subset is r.
For input coordinate of rank 0, this command returns an empty set.
"
    if {$coordPiv == "??"} { puts $ABOUT ; return }
    if {$coordPiv == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
        
    set coordBest  NA ; set valueBest 2147483641 ; set valueProbedList {}
    set neighbSize 0  ; set coordBestList  {}    ; set coordProbedList {}
    
    set L          $aV(L)
    set rankTarget $aV(rankTarget)
    
    if {$aV(writeVar) == 3} {
        set distance 0 ; 
        set rank [B.coord.rank $coordPiv]
        set rowLines "FROM: $thisCmd\
          \nProbing ALL distance=1 neighbors of the\ninitial pivot\
          coordinate = $coordPiv\
          \ncntProbe\tIdx\tcoordPivot\tvalPivot\tcoordAdj\tvalAdj\tdist\trank\
          \n~\t~\t$coordPiv\t$valuePiv\t~\t~\t$distance\t$rank\n"
    }
    for {set i 0} {$i < $L} {incr i} {  
        
        set bit [string index $coordPiv $i]
        if {$bit} {
            # decrease the rank of coordAdj by 1
            set coordAdj [string replace $coordPiv $i $i 0]
            #set mAdj     [expr {$mPiv - 1}]

            ##!! To maintain a self-avoiding walk, coordinates from the walk
            ##!! should be excluded from the neighborhood of the current pivot.
            #parray aCoordHash0  
            if {![info exists aCoordHash0($coordAdj)]} {
                incr neighbSize
                set valueAdj [B.ogr.f $coordAdj $rankTarget] ; incr aV(cntProbe)
                lappend valueAry($valueAdj) $coordAdj
                
                if {$aV(isWalkTables)} {
                    lappend coordProbedList $coordAdj
                    lappend valueProbedList $valueAdj
                }
                #!! aggregate coordBestList for random selection later
                if {$valueAdj <= $valueBest} {
                    if {$valueAdj < $valueBest} {set coordBestList {}}
                    set valueBest $valueAdj ; set coordBest $coordAdj
                    lappend coordBestList $coordBest
                }
                if {$aV(writeVar) == 3} {
                    set distance [B.coord.distance  $coordAdj  $coordPiv]
                    set rank     [B.coord.rank $coordAdj]
                    append rowLines $aV(cntProbe)\t$i\t$coordBest\t$valueBest\
                      \t$coordAdj\t$valueAdj\t$distance\t$rank\n
                }
            }
        }
    }
    if {$aV(writeVar) == 3} {puts "$rowLines --neighbSize=$neighbSize"}
    
    #!! randomize the choice of coordBest from coordBestList 
    set idx [expr {int([llength $coordBestList]*rand())}]
    set coordBest [lindex $coordBestList $idx]
    
    # create a coord-value pair of priority arrays
    set idx 0 
    foreach value [lsort -integer [array names valueAry]] {
        foreach coord $valueAry($value) {
            incr idx
            set coordProbedAry($idx) $coord
            set valueProbedAry($idx) $value
        }
    }
    if {$neighbSize > 0} {
        return "$coordBest $valueBest $neighbSize \
          [list [array get coordProbedAry]] [list [array get valueProbedAry]] \
          [list $coordProbedList] [list $valueProbedList]"
    } else {
        return "NA NA $neighbSize {} {}"
    }
#~dd
# % source ../xLib/all_tcl
# .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
#   
# % B.ogr.main 4 1
# aV(L)             = 5
# aV(instanceDef)   = 4,6
# aV(coordInit)     = 10100
# aV(valueInit)     = -1
# aV(writeVar)      = 3
# 
# % B.ogr.fAdj_simple_dn 10100 -1
# FROM: B.ogr.fAdj_simple_dn 
# Probing ALL distance=1 neighbors of the
# initial pivot coordinate = 10100 
# cntProbe	Idx	coordPivot	valPivot	coordAdj	valAdj	dist	rank 
# ~	~	10100	-1	~	~	0	2
# 11	0	00100	0	00100	0	1	1
# 12	2	10000	-1	10000	-1	1	1
#  --neighbSize=2
# 10000 -1 2  {1 10000 2 00100} {1 -1 2 0}  {} {}
# % 
#
# Copyright: 
# Franc Brglez, Sat Aug 29 11:40:40 EDT 2015
#~dd
} ;# B.ogr.fAdj_simple_dn



proc B.ogr.f { {coord 10010} {rankTarget 2} {withDetails 0} } {   
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.ogr.f 
set ABOUT \
" 
         $thisCmd coord         rankTarget
Example: $thisCmd 0000000000    3

*******NEEDS EDITS ...*******
The command  $thisCmd takes a binary coordinate such as 0101010
which has length L = 7 and rank r = 3. This command returns a subset of 
** adjacent coordinates **,  all with the Hamming distance of 1 from the 
input coordinate and with rank (r-1). The size of this subset is r.
For input coordinate of rank 0, this command returns an empty set.
"
    if {$coord == "??"} { puts $ABOUT ; return }
    if {$coord == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    set coordSize [string length  $coord]
    set nDim      $coordSize
    set n [expr {1 + $coordSize}]               ;# length of the ruler 
    set m [expr {2 + [B.coord.rank   $coord]}]  ;# marks on the pegboard
    
    # peg positions of the Golomb Ruler
    # processing lists is more efficient than processing strings!
    # processing arrays is more efficient than processing lists!
    set peg(1) 0 ; set peg($m) $n
    set i 1 ; set j 1
    foreach bit [split $coord ""] {if {$bit} {incr j ; set peg($j) $i} ; incr i}
    #parray peg ; return
    
    # form the edge-weighted graph clique and 
    # count the number of repeated edge weights
    set numRepeats 0 ; array unset weightHash
    
    for {set i 1} {$i < $m} {incr i} {  
        for {set j [expr {$i+1}]} {$j <= $m} {incr j} {       
            set weight [expr {$peg($j) - $peg($i)}]
            #set eWeight($i,$j) $weight ;# eWeight is NEEDED under tableau
            if {[info exists weightHash($weight)]} {
                incr numRepeats
            }
            set weightHash($weight) {}
        }
    }
    #parray weightHash ; puts numRepeats=$numRepeats ; return
    
    set coordRank [B.coord.rank $coord]
    if {$coordRank > $rankTarget} {
        set value $numRepeats
    } else {
        set value [expr {$numRepeats - $coordRank}]
    }
    if {$withDetails} {
        set details "m = $m, n = $n, coordRank = [expr {$m - 2}], \
          numRepeats = $numRepeats, functionValue = $value\
          \nTheRuler = [B.ogr.ruler_from_bin $coord]"
        return $details
    } else {
        return $value
    }
#~dd 
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xProj/B.ogr/xWork
# % source ../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# %
# % B.ogr.f 01010 2 
# 1
# % B.ogr.f 01010 2 1
# m = 4, n = 6, coordRank = 2,  numRepeats = 3, functionValue = 1 
# TheRuler = 0,2,4,6
#   
# % B.ogr.f 10001 2 1
# m = 4, n = 6, coordRank = 2,  numRepeats = 2, functionValue = 0 
# TheRuler = 0,1,5,6
# 
# % B.ogr.f 01001 2 1
# m = 4, n = 6, coordRank = 2,  numRepeats = 0, functionValue = -2 
# TheRuler = 0,2,5,6
# 
# % B.ogr.f 10010 2 1
# m = 4, n = 6, coordRank = 2,  numRepeats = 0, functionValue = -2 
# TheRuler = 0,1,4,6
# 
# % B.ogr.f 10000 2 1
# m = 3, n = 6, coordRank = 1,  numRepeats = 0, functionValue = -1 
# TheRuler = 0,1,6
# 
# % B.ogr.f 01000 2 1
# m = 3, n = 6, coordRank = 1,  numRepeats = 0, functionValue = -1 
# TheRuler = 0,2,6
# 
# % B.ogr.f 00100 2 1
# m = 3, n = 6, coordRank = 1,  numRepeats = 1, functionValue = 0 
# TheRuler = 0,3,6
# 
# % B.ogr.f 00000 2 1
# m = 2, n = 6, coordRank = 0,  numRepeats = 0, functionValue = 0 
# TheRuler = 0,6
# 
# % B.ogr.f 0101000001 3 1
# m = 5, n = 11, coordRank = 3,  numRepeats = 1, functionValue = -2 
# TheRuler = 0,2,4,10,11
# 
# % B.ogr.f 0101000100 3 1
# m = 5, n = 11, coordRank = 3,  numRepeats = 2, functionValue = -1 
# TheRuler = 0,2,4,8,11
# 
# % B.ogr.f 0101001000 3 1
# m = 5, n = 11, coordRank = 3,  numRepeats = 3, functionValue = 0 
# TheRuler = 0,2,4,7,11
# 
# % B.ogr.f 0101000010 3 1
# m = 5, n = 11, coordRank = 3,  numRepeats = 4, functionValue = 1 
# TheRuler = 0,2,4,9,11

# % B.ogr.ruler_to_bin [join "0 1 4 9 11" ,] ;# canonic form, from Wikipedia
# 1001000010
# %
# % B.ogr.f 1001000010 1
# m = 5, n = 11, coordRank = 3,  numRepeats = 0 
# TheRuler = 0,1,4,9,11

# % B.ogr.ruler_to_bin [join "0 2 7 8 11" ,] ;# canonic form, from Wikipedia
# 0100001100
# % 
# % B.ogr.f 0100001100 3 1
# m = 5, n = 11, coordRank = 3,  numRepeats = 0, functionValue = -3 
# TheRuler = 0,2,7,8,11

# % B.ogr.ruler_to_bin [join "0 1 4 9 15 22 32 34" ,] ;# canonic form, from Wikipedia
# 100100001000001000000100000000010
# % 
# % B.ogr.f 100100001000001000000100000000010 6 1
# m = 8, n = 34, coordRank = 6,  numRepeats = 0, functionValue = -6 
# TheRuler = 0,1,4,9,15,22,32,34
 
# % B.ogr.ruler_to_bin [join "0 1 4 11 26 32 56 68 76 115 117 134 150 163 168 177" ,]
# 10010000001000000000000001000001000000000000000000000001000000000001000000010000000000000000000000000000000000000010100000000000000001000000000000000100000000000010000100000000
# % 
# % B.ogr.f 10010000001000000000000001000001000000000000000000000001000000000001000000010000000000000000000000000000000000000010100000000000000001000000000000000100000000000010000100000000 14 1
# m = 16, n = 177, coordRank = 14,  numRepeats = 0, functionValue = -14 
# TheRuler = 0,1,4,11,26,32,56,68,76,115,117,134,150,163,168,177
# 

#
# Copyright: 
# Franc Brglez, Wed Aug 26 11:58:44 EDT 2015
#~dd 
} ;# B.ogr.f

#------- keep here as a 80-character reference line to check text width -------#

proc B.ogr.fAdj_dn { {coordPiv 01010} {valuePiv 1} } {   
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.ogr.fAdj_dn
set ABOUT \
" 
         $thisCmd coordPiv
Example: $thisCmd $coordPiv

NEEDS EDITS ...
The command  $thisCmd takes a binary coordinate such as 0101010
which has length L = 7 and rank r = 3. This command returns a subset of 
** adjacent coordinates **,  all with the Hamming distance of 1 from the 
input coordinate and with rank (r-1). The size of this subset is r.
For input coordinate of rank 0, this command returns an empty set.
"
    if {$coordPiv == "??"} { puts $ABOUT ; return }
    if {$coordPiv == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
        
    set coordBest  NA ; set valueBest 2147483641 ; set valueProbedList {}
    set neighbSize 0  ; set coordBestList  {}    ; set coordProbedList {}
    
    set m          $aV(rulerMarks)
    set n          $aV(rulerLength)
    set L          $aV(nDim)
    set rankTarget $aV(rankTarget)
    
    if {$aV(writeVar) == 3} {
        set withDetails 1
    } else {
        set withDetails 0
    }
    #set withDetails 1
### PASS 1: 
    # peg positions of the Golomb Ruler
    # processing lists is more efficient than processing strings!
    # processing arrays is more efficient than processing lists!
    set peg(0) 1 ; set peg($n) [expr {$n+1}]
    set i 1  
    foreach bit [split $coordPiv ""] {
        if {$bit} {
            set peg($i) [expr {$i+1}]
        } else {
            set peg($i) 0
        }
        incr i
    }
    #parray peg ; return
    
    # form the edge-weighted graph clique and 
    # count the number of repeated edge weights
    array unset pegEdges ; array unset aRepeats ; 
    array unset eWeight  ; array unset isInit
    for {set i 0} {$i < $n} {incr i} {  
        for {set j [expr {$i+1}]} {$j <= $n} {incr j} { 
            if {$peg($i) > 0 && $peg($j) > 0} {
                set weight [expr {$peg($j) - $peg($i)}]
                set eWeight($i,$j) $weight ;# eWeight is NEEDED under tableau
                lappend pegEdges($i) $i,$j
                lappend pegEdges($j) $i,$j
                if {[info exists isInit($weight)] } {
                    incr aRepeats($weight)
                } else {
                    set  isInit($weight)   1
                    set  aRepeats($weight) 1
                }
            }
        }
    }
    # store as numRepeatsPiv for this pivot
    set numRepeatsPiv 0 ; 
    foreach weight [array names aRepeats] {
        set numRepeatsPiv [expr {$numRepeatsPiv + $aRepeats($weight) - 1}]
    }
    # Now, compute valuePiv (standard definition of ogr)
    set coordRank [B.coord.rank $coordPiv]
    if {$coordRank > $rankTarget} {
        set valuePiv $numRepeatsPiv
    } else {
        set valuePiv [expr {$numRepeatsPiv - $coordRank}]
    }
    incr aV(cntProbe)

    if {$withDetails} {
        ##### to be cleaned-up LATER
        set details_init "Details from $thisCmd\
          \n** PASS 1 **\
          \nTheRuler = [B.ogr.ruler_from_bin $coordPiv]\
          \nm = $m, n = $n, coordRank = [expr {$m - 2}], \
          numRepeats = $numRepeatsPiv, size_of_aRepeats = [array size aRepeats]\
            \ncoordPivot\tvaluePivot\tcoordRank\
            \n$coordPiv\t$valuePiv\t[B.coord.rank $coordPiv]"
#           \ncoordNeighbors\tcoordRank\tvalueNeighbor\tcheckDiff"
        puts $details_init
        parray peg ;  parray pegEdges ; parray aRepeats
    }
    #return
    
### PASS 2: 
    # compute numRepeats for adjacent coordinates at rank 1-up
    if {$withDetails} {
        puts "\n** PASS 2 **\
          \ncoordPiv=$coordPiv , valuePiv=$valuePiv"
    }
    for {set iPos 0} {$iPos < $L} {incr iPos} {  
        
        set bit [string index $coordPiv $iPos]
        if {$bit} {
            # decrease the rank of coordAdj by 1
            set coordAdj [string replace $coordPiv $iPos $iPos 0]
            ##!! To maintain a self-avoiding walk, coordinates from the walk
            ##!! should be excluded from the neighborhood of the current pivot.
            #parray aCoordHash0  
            if {![info exists aCoordHash0($coordAdj)]} {
                # remove the peg and recalculate numRepeats
                set iRemove [expr {$iPos+1}] ; incr neighbSize
                array unset aRepeatsAdj ; array set aRepeatsAdj [array get aRepeats]

                foreach edge $pegEdges($iRemove) {
                    set weight $eWeight($edge)
                    if {$aRepeatsAdj($weight) > 1} {incr aRepeatsAdj($weight) -1}
                }
                set numRepeats 0 ; 
                foreach weight [array names aRepeatsAdj] {
                    set numRepeats [expr {$numRepeats + $aRepeatsAdj($weight) - 1}]
                }
                # Now, compute valueAdj (standard definition of ogr)
                set coordRank [B.coord.rank $coordAdj]
                if {$coordRank > $rankTarget} {
                    set valueAdj $numRepeats
                } else {
                    set valueAdj [expr {$numRepeats - $coordRank}]
                }
                incr aV(cntProbe)
                
                if {$withDetails} {
                    puts "\n.. bit=$iPos, remove peg($iRemove), i.e.\
                      \n remove edges $pegEdges($iRemove)"
                    puts $coordAdj\:$valueAdj...numRepeats=$numRepeats...
                }
                #!! aggregate coordBestList for random selection later
                if {$valueAdj <= $valueBest} {
                    if {$valueAdj < $valueBest} {set coordBestList {}}
                    set valueBest $valueAdj ; set coordBest $coordAdj
                    lappend coordBestList $coordBest
                }
            }
        }
    }
    #return
    #!! randomize the choice of coordBest from coordBestList 
    set idx [expr {int([llength $coordBestList]*rand())}]
    set coordBest [lindex $coordBestList $idx]
   
    if {$neighbSize > 0} {
        return "$coordBest $valueBest $neighbSize"
    } else {
        return "NA NA $neighbSize {} {}"
    }
#~dd
# % source ../xLib/all_tcl
# .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
#   
# % B.ogr.main 4 WT
# .. from B.ogr.init (for isInitOnly = 1)
# aV(L)                 = 5
# aV(cntProbe)          = 1
# aV(coordInit)         = 00010
# ...
# % array unset aCoordHash0
# 
# % B.ogr.fAdj_dn 01010
# Details from B.ogr.fAdj_dn 
# ** PASS 1 ** 
# TheRuler = 0,2,4,6 
# m = 4, n = 6, coordRank = 2,  numRepeats = 3, size_of_aRepeats = 3 
# coordPivot	valuePivot	coordRank 
# 01010	1	2
# peg(0) = 1
# peg(1) = 0
# peg(2) = 3
# peg(3) = 0
# peg(4) = 5
# peg(5) = 0
# peg(6) = 7
# pegEdges(0) = 0,2 0,4 0,6
# pegEdges(2) = 0,2 2,4 2,6
# pegEdges(4) = 0,4 2,4 4,6
# pegEdges(6) = 0,6 2,6 4,6
# aRepeats(2) = 3
# aRepeats(4) = 2
# aRepeats(6) = 1
# 
# ** PASS 2 ** 
# coordPiv=01010 , valuePiv=1
# 
# .. bit=1, remove peg(2), i.e. 
#  remove edges 0,2 2,4 2,6
# 00010:-1...numRepeats=0...
# 
# .. bit=3, remove peg(4), i.e. 
#  remove edges 0,4 2,4 4,6
# 01000:-1...numRepeats=0...
# 01000 -1 2
# 
# 
# % B.ogr.fAdj_dn 11010
# Details from B.ogr.fAdj_dn 
# ** PASS 1 ** 
# TheRuler = 0,1,2,4,6 
# m = 4, n = 6, coordRank = 2,  numRepeats = 4, size_of_aRepeats = 6 
# coordPivot	valuePivot	coordRank 
# 11010	4	3
# peg(0) = 1
# peg(1) = 2
# peg(2) = 3
# peg(3) = 0
# peg(4) = 5
# peg(5) = 0
# peg(6) = 7
# pegEdges(0) = 0,1 0,2 0,4 0,6
# pegEdges(1) = 0,1 1,2 1,4 1,6
# pegEdges(2) = 0,2 1,2 2,4 2,6
# pegEdges(4) = 0,4 1,4 2,4 4,6
# pegEdges(6) = 0,6 1,6 2,6 4,6
# aRepeats(1) = 2
# aRepeats(2) = 3
# aRepeats(3) = 1
# aRepeats(4) = 2
# aRepeats(5) = 1
# aRepeats(6) = 1
# 
# ** PASS 2 ** 
# coordPiv=11010 , valuePiv=4
# 
# .. bit=0, remove peg(1), i.e. 
#  remove edges 0,1 1,2 1,4 1,6
# 01010:1...numRepeats=3...
# 
# .. bit=1, remove peg(2), i.e. 
#  remove edges 0,2 1,2 2,4 2,6
# 10010:-2...numRepeats=0...
# 
# .. bit=3, remove peg(4), i.e. 
#  remove edges 0,4 1,4 2,4 4,6
# 11000:-1...numRepeats=1...
# 10010 -2 3
# % 
# Copyright: 
# Franc Brglez, Sun Aug 30 12:36:05 EDT 2015
#~dd
} ;# B.ogr.fAdj_dn


proc B.ogr.fAdj { {coordPiv 01010} {valuePiv 1} } {   
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.ogr.fAdj
set ABOUT \
" 
         $thisCmd coordPiv
Example: $thisCmd $coordPiv

NEEDS EDITS ...
The command  $thisCmd takes a binary coordinate such as 0101010
which has length L = 7 and rank r = 3. This command returns a subset of 
** adjacent coordinates **,  all with the Hamming distance of 1 from the 
input coordinate and with rank (r-1). The size of this subset is r.
For input coordinate of rank 0, this command returns an empty set.
"
    if {$coordPiv == "??"} { puts $ABOUT ; return }
    if {$coordPiv == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed

    set coordBest  NA ; set valueBest 2147483641 ; set valueProbedList {}
    set neighbSize 0  ; set coordBestList  {}    ; set coordProbedList {}
    
    set m          $aV(rulerMarks)
    set n          $aV(rulerLength)
    set L          $aV(nDim)
    set rankTarget $aV(rankTarget)
    
    if {$aV(writeVar) == 3} {
        set withDetails 1
    } else {
        set withDetails 0
    }
    set withDetails 0
### PASS 1: 
    # peg positions of the Golomb Ruler
    # processing lists is more efficient than processing strings!
    # processing arrays is more efficient than processing lists!
    set peg(0) 1 ; set peg($n) [expr {$n+1}]
    set i 1  
    foreach bit [split $coordPiv ""] {
        if {$bit} {
            set peg($i) [expr {$i+1}]
        } else {
            set peg($i) 0
        }
        incr i
    }
    #parray peg ; return
    
    # form the edge-weighted graph clique and 
    # count the number of repeated edge weights
    array unset pegEdges ; array unset aRepeats ; 
    array unset eWeight  ; array unset isInit
    set weightListPiv {}
    for {set i 0} {$i < $n} {incr i} {  
        for {set j [expr {$i+1}]} {$j <= $n} {incr j} { 
            if {$peg($i) > 0 && $peg($j) > 0} {
                set weight [expr {$peg($j) - $peg($i)}]
                lappend weightListPiv $weight ;# NEEDED under tableau for rank-up
                set eWeight($i,$j) $weight    ;# NEEDED under tableau for rank-dn
                lappend pegEdges($i) $i,$j
                lappend pegEdges($j) $i,$j
                if {[info exists isInit($weight)] } {
                    incr aRepeats($weight)
                } else {
                    set  isInit($weight)   1
                    set  aRepeats($weight) 1
                }
            }
        }
    }
    # store as numRepeatsPiv for this pivot
    set numRepeatsPiv 0 ; 
    foreach weight [array names aRepeats] {
        set numRepeatsPiv [expr {$numRepeatsPiv + $aRepeats($weight) - 1}]
    }
    # Now, compute valuePiv (standard definition of ogr)
    set coordRank [B.coord.rank $coordPiv]
    if {$coordRank > $rankTarget} {
        set valuePiv $numRepeatsPiv
    } else {
        set valuePiv [expr {$numRepeatsPiv - $coordRank}]
    }
    incr aV(cntProbe)

    if {$withDetails} {
        ##### to be cleaned-up LATER
        set details_init "Details from $thisCmd\
          \n** PASS 1 **\
          \nTheRuler = [B.ogr.ruler_from_bin $coordPiv]\
          \nm = $m, n = $n, coordRank = [expr {$m - 2}], \
          numRepeats = $numRepeatsPiv, weightListPivSize = [llength $weightListPiv]\
            \ncoordPivot\tvaluePivot\tcoordRank\
            \n$coordPiv\t$valuePiv\t[B.coord.rank $coordPiv]"
#           \ncoordNeighbors\tcoordRank\tvalueNeighbor\tcheckDiff"
        puts $details_init
        parray peg ;  parray pegEdges ; parray aRepeats  
    }
    #return
    
### PASS 2: 
    if {$withDetails} {
        puts "\n** PASS 2 **\
          \ncoordPiv=$coordPiv , valuePiv=$valuePiv"
    }
    for {set iPos 0} {$iPos < $L} {incr iPos} {  
         
        set bit [string index $coordPiv $iPos]
        if {!$bit} {
            # compute numRepeats for adjacent coordinates at rank 1-up
            # increase the rank of coordAdj by 1
            set coordAdj [string replace $coordPiv $iPos $iPos 1]
           
            ##!! To maintain a self-avoiding walk, coordinates from the walk
            ##!! should be excluded from the neighborhood of the current pivot.
            #parray aCoordHash0  
            if {![info exists aCoordHash0($coordAdj)]} {
                # add the peg and recalculate numRepeats
                set iAdj  [expr {$iPos+1}] ; incr neighbSize
                set edgeListAdj {}       ; set weightListAdj {}  ; 
                array unset weightAryAdj ; array unset weightAryAll
                
                # find weights for all edges for the added peg 
                for {set i 0} {$i <= $n} {incr i} {
                    if {$peg($i) > 0} {
                        if {$withDetails} {
                            if {$i < $iAdj} {
                                lappend edgeListAdj   $i,$iAdj
                            } else {
                                lappend edgeListAdj   $iAdj,$i
                            }
                        }
                        set weight [expr {abs($i - $iAdj)}]
                        lappend weightListAdj $weight
                    }
                }                
                # compute as numRepeatsAdj for this coordAdj
                set weightListAll [concat $weightListPiv $weightListAdj]
                foreach weight $weightListAll {set weightAryAll($weight) {}}
                set numRepeatsAdj [expr {[llength $weightListAll] - [array size weightAryAll]}]

                # Now, compute valueAdj
                set coordRank [B.coord.rank $coordAdj]
                if {$coordRank > $rankTarget} {
                    set valueAdj $numRepeatsAdj
                } else {
                    set valueAdj [expr {$numRepeatsAdj - $coordRank}]
                }
                incr aV(cntProbe)
                if {$withDetails} {
                    puts "\n.. add peg to position $iAdj\
                      \n   edgeListAdj=$edgeListAdj\
                      \n   weightListAdj=$weightListAdj\
                      \n   $coordAdj\:$valueAdj...numRepeatsAdj=$numRepeatsAdj...neighbSize=$neighbSize"
                }
                #!! aggregate coordBestList for random selection later
                if {$valueAdj <= $valueBest} {
                    if {$valueAdj < $valueBest} {set coordBestList {}}
                    set valueBest $valueAdj ; set coordBest $coordAdj
                    lappend coordBestList $coordBest
                }
            }
        }
        if {$bit} {
            # decrease the rank of coordAdj by 1
            set coordAdj [string replace $coordPiv $iPos $iPos 0]
            ##!! To maintain a self-avoiding walk, coordinates from the walk
            ##!! should be excluded from the neighborhood of the current pivot.
            #parray aCoordHash0  
            if {![info exists aCoordHash0($coordAdj)]} {
                # remove the peg and recalculate numRepeats
                set iRemove [expr {$iPos+1}] ; incr neighbSize
                array unset aRepeatsAdj ; array set aRepeatsAdj [array get aRepeats]

                foreach edge $pegEdges($iRemove) {
                    set weight $eWeight($edge)
                    if {$aRepeatsAdj($weight) > 1} {incr aRepeatsAdj($weight) -1}
                }
                set numRepeats 0 ; 
                foreach weight [array names aRepeatsAdj] {
                    set numRepeats [expr {$numRepeats + $aRepeatsAdj($weight) - 1}]
                }
                # Now, compute valueAdj (standard definition of ogr)
                set coordRank [B.coord.rank $coordAdj]
                if {$coordRank > $rankTarget} {
                    set valueAdj $numRepeats
                } else {
                    set valueAdj [expr {$numRepeats - $coordRank}]
                }
                incr aV(cntProbe)
                
                if {$withDetails} {
                    puts "\n.. bit=$iPos, remove peg($iRemove), i.e.\
                      \n remove edges $pegEdges($iRemove)"
                    puts $coordAdj\:$valueAdj...numRepeats=$numRepeats...
                }
                #!! aggregate coordBestList for random selection later
                if {$valueAdj <= $valueBest} {
                    if {$valueAdj < $valueBest} {set coordBestList {}}
                    set valueBest $valueAdj ; set coordBest $coordAdj
                    lappend coordBestList $coordBest
                }
            }
        }
    }
    #return
    #!! randomize the choice of coordBest from coordBestList 
    set idx [expr {int([llength $coordBestList]*rand())}]
    set coordBest [lindex $coordBestList $idx]
   
    if {$neighbSize > 0} {
        return "$coordBest $valueBest $neighbSize"
    } else {
        return "NA NA $neighbSize"
    }
#~dd
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xProj/B.ogr/xWork
# % source ../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# 
# % B.ogr.main 4 WT
# .. from B.ogr.init (for isInitOnly = 1)
# aV(L)                 = 5
# aV(cntProbe)          = 1
# aV(cntProbeLmt)       = 2147483647
# aV(cntRestart)        = 0
# aV(cntRestartLmt)     = 2147483647
# aV(commandLine)       = B.ogr.main 4 NA NA NA  FALSE wander 0 0
# aV(compiler)          = tcl-8.5.8
# aV(coordBest)         = 10000
# aV(coordInit)         = 10000
#  
# % array unset aCoordHash0
# 
# % B.ogr.fAdj 11010 NA
# Details from B.ogr.fAdj 
# ** PASS 1 ** 
# TheRuler = 0,1,2,4,6 
# m = 4, n = 6, coordRank = 2,  numRepeats = 4, weightListPivSize = 10 
# coordPivot	valuePivot	coordRank 
# 11010	4	3
# peg(0) = 1
# peg(1) = 2
# peg(2) = 3
# peg(3) = 0
# peg(4) = 5
# peg(5) = 0
# peg(6) = 7
# pegEdges(0) = 0,1 0,2 0,4 0,6
# pegEdges(1) = 0,1 1,2 1,4 1,6
# pegEdges(2) = 0,2 1,2 2,4 2,6
# pegEdges(4) = 0,4 1,4 2,4 4,6
# pegEdges(6) = 0,6 1,6 2,6 4,6
# aRepeats(1) = 2
# aRepeats(2) = 3
# aRepeats(3) = 1
# aRepeats(4) = 2
# aRepeats(5) = 1
# aRepeats(6) = 1
# 
# ** PASS 2 ** 
# coordPiv=11010 , valuePiv=4
# 
# .. bit=0, remove peg(1), i.e. 
#  remove edges 0,1 1,2 1,4 1,6
# 01010:1...numRepeats=3...
# 
# .. bit=1, remove peg(2), i.e. 
#  remove edges 0,2 1,2 2,4 2,6
# 10010:-2...numRepeats=0...
# 
# .. add peg to position 3 
#    edgeListAdj=0,3 1,3 2,3 3,4 3,6 
#    weightListAdj=3 2 1 1 3 
#    11110:9...numRepeatsAdj=9...neighbSize=3
# 
# .. bit=3, remove peg(4), i.e. 
#  remove edges 0,4 1,4 2,4 4,6
# 11000:-1...numRepeats=1...
# 
# .. add peg to position 5 
#    edgeListAdj=0,5 1,5 2,5 4,5 5,6 
#    weightListAdj=5 4 3 1 1 
#    11011:9...numRepeatsAdj=9...neighbSize=5
# 10010 -2 5
# % 
# Copyright: 
# Franc Brglez, Thu Aug 27 14:05:03 EDT 2015
#~dd 
} ;# B.ogr.fAdj


#------- keep here as a 80-character reference line to check text width -------#



proc B.ogr.fAdj_up { {coordPiv 01010} {valuePiv placeHolderOnly} } {   
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.ogr.fAdj_up
set ABOUT \
" 
         $thisCmd coordPiv
Example: $thisCmd $coordPiv

NEEDS EDITS ...
The command  $thisCmd takes a binary coordinate such as 0101010
which has length L = 7 and rank r = 3. This command returns a subset of 
** adjacent coordinates **,  all with the Hamming distance of 1 from the 
input coordinate and with rank (r-1). The size of this subset is r.
For input coordinate of rank 0, this command returns an empty set.
"
    if {$coordPiv == "??"} { puts $ABOUT ; return }
    if {$coordPiv == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
        
    set coordBest  NA ; set valueBest 2147483641 ; set valueProbedList {}
    set neighbSize 0  ; set coordBestList  {}    ; set coordProbedList {}
    
    set m          $aV(rulerMarks)
    set n          $aV(rulerLength)
    set L          $aV(nDim)
    set rankTarget $aV(rankTarget)
    
    if {$aV(writeVar) == 3} {
        set withDetails 1
    } else {
        set withDetails 0
    }
### PASS 1: 
    # peg positions of the Golomb Ruler
    # processing lists is more efficient than processing strings!
    # processing arrays is more efficient than processing lists!
    set peg(0) 1 ; set peg($n) [expr {$n+1}]
    set i 1  
    foreach bit [split $coordPiv ""] {
        if {$bit} {
            set peg($i) [expr {$i+1}]
        } else {
            set peg($i) 0
        }
        incr i
    }
    #parray peg ; return
    
    # form the edge-weighted graph clique and 
    # count the number of repeated edge weights
    set weightListPiv {}
    for {set i 0} {$i < $n} {incr i} {  
        for {set j [expr {$i+1}]} {$j <= $n} {incr j} { 
            if {$peg($i) > 0 && $peg($j) > 0} {
                set weight [expr {$peg($j) - $peg($i)}]
                lappend weightListPiv $weight
            }
        }
    }
    # store as numRepeatsPiv for this pivot
    foreach weight $weightListPiv {set weightAryPiv($weight) {}}
    set numRepeatsPiv [expr {[llength $weightListPiv] - [array size weightAryPiv]}]
    
    # Now, compute valuePiv (standard definition of ogr)
    set coordRank [B.coord.rank $coordPiv]
    if {$coordRank > $rankTarget} {
        set valuePiv $numRepeatsPiv
    } else {
        set valuePiv [expr {$numRepeatsPiv - $coordRank}]
    }
    incr aV(cntProbe)

    if {$withDetails} {
        ##### to be cleaned-up LATER
        set details_init "Details from $thisCmd\
          \n** PASS 1 **\
          \nTheRuler = [B.ogr.ruler_from_bin $coordPiv]\
          \nm = $m, n = $n, coordRank = [expr {$m - 2}], \
          numRepeats = $numRepeatsPiv, weightListPivSize = [llength $weightListPiv]\
            \ncoordPivot\tvaluePivot\tcoordRank\
            \n$coordPiv\t$valuePiv\t[B.coord.rank $coordPiv]"
#           \ncoordNeighbors\tcoordRank\tvalueNeighbor\tcheckDiff"
        puts $details_init
        parray peg ;#  parray eWeight ; parray aRepeats ; parray pegEdges
    }
    #return
    
### PASS 2: 
    # compute numRepeats for adjacent coordinates at rank 1-up
    if {$withDetails} {
        puts "\n** PASS 2 **\
          \ncoordPiv=$coordPiv , valuePiv=$valuePiv"
    }
    for {set iPos 0} {$iPos < $L} {incr iPos} {  
         
        set bit [string index $coordPiv $iPos]
        if {!$bit} {
            # increase the rank of coordAdj by 1
            set coordAdj [string replace $coordPiv $iPos $iPos 1]
           
            ##!! To maintain a self-avoiding walk, coordinates from the walk
            ##!! should be excluded from the neighborhood of the current pivot.
            #parray aCoordHash0  
            if {![info exists aCoordHash0($coordAdj)]} {
                # add the peg and recalculate numRepeats
                set iAdj  [expr {$iPos+1}] ; incr neighbSize
                set edgeListAdj {}       ; set weightListAdj {}  ; 
                array unset weightAryAdj ; array unset weightAryAll
                
                # find weights for all edges for the added peg 
                for {set i 0} {$i <= $n} {incr i} {
                    if {$peg($i) > 0} {
                        if {$withDetails} {
                            if {$i < $iAdj} {
                                lappend edgeListAdj   $i,$iAdj
                            } else {
                                lappend edgeListAdj   $iAdj,$i
                            }
                        }
                        set weight [expr {abs($i - $iAdj)}]
                        lappend weightListAdj $weight
                    }
                }                
                # compute as numRepeatsAdj for this coordAdj
                set weightListAll [concat $weightListPiv $weightListAdj]
                foreach weight $weightListAll {set weightAryAll($weight) {}}
                set numRepeatsAdj [expr {[llength $weightListAll] - [array size weightAryAll]}]

                # Now, compute valueAdj
                set coordRank [B.coord.rank $coordAdj]
                if {$coordRank > $rankTarget} {
                    set valueAdj $numRepeatsAdj
                } else {
                    set valueAdj [expr {$numRepeatsAdj - $coordRank}]
                }
                incr aV(cntProbe)
                if {$withDetails} {
                    puts "\n.. add peg to position $iAdj\
                      \n   edgeListAdj=$edgeListAdj\
                      \n   weightListAdj=$weightListAdj\
                      \n   $coordAdj\:$valueAdj...numRepeatsAdj=$numRepeatsAdj...neighbSize=$neighbSize"
                }
                #!! aggregate coordBestList for random selection later
                if {$valueAdj <= $valueBest} {
                    if {$valueAdj < $valueBest} {set coordBestList {}}
                    set valueBest $valueAdj ; set coordBest $coordAdj
                    lappend coordBestList $coordBest
                }
            }
        }
    }
    #return
    #!! randomize the choice of coordBest from coordBestList 
    set idx [expr {int([llength $coordBestList]*rand())}]
    set coordBest [lindex $coordBestList $idx]
   
    if {$neighbSize > 0} {
        return "$coordBest $valueBest $neighbSize"
    } else {
        return "NA NA $neighbSize"
    }
#~dd
# % source ../xLib/all_tcl
# .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
#   
# % B.ogr.main 4 1
# .. from B.ogr.init (for isInitOnly = 1)
# aV(L)                 = 5
# aV(cntProbe)          = 1
# aV(coordInit)         = 01000
# aV(valueInit)         = -1
# aV(valueTarget)       = -2
# ...
# % set aV(writeVar) 3
# 3
# % B.ogr.fAdj_up 10000
# Details from B.ogr.fAdj_up 
# ** PASS 1 ** 
# TheRuler = 0,1,6 
# m = 4, n = 6, coordRank = 2,  numRepeats = 0, weightListPivSize = 3 
# coordPivot	valuePivot	coordRank 
# 10000	-1	1
# peg(0) = 1
# peg(1) = 2
# peg(2) = 0
# peg(3) = 0
# peg(4) = 0
# peg(5) = 0
# peg(6) = 7
# 
# ** PASS 2 ** 
# coordPiv=10000 , valuePiv=-1
# 
# .. add peg to position 2 
#    edgeListAdj=0,2 1,2 2,6 
#    weightListAdj=2 1 4 
#    11000:-1...numRepeatsAdj=1...neighbSize=1
# 
# .. add peg to position 3 
#    edgeListAdj=0,3 1,3 3,6 
#    weightListAdj=3 2 3 
#    10100:-1...numRepeatsAdj=1...neighbSize=2
# 
# .. add peg to position 4 
#    edgeListAdj=0,4 1,4 4,6 
#    weightListAdj=4 3 2 
#    10010:-2...numRepeatsAdj=0...neighbSize=3
# 
# .. add peg to position 5 
#    edgeListAdj=0,5 1,5 5,6 
#    weightListAdj=5 4 1 
#    10001:0...numRepeatsAdj=2...neighbSize=4
# 10010 -2 4
# % set aV(writeVar) 0
# 0
# % B.ogr.fAdj_up 10000
# 10010 -2 4
# % B.ogr.fAdj_up 11000
# 11010 4 3
# % B.ogr.fAdj_up 11010
# 11011 9 2
# % 
#
# Copyright: 
# Franc Brglez, Sun Aug 30 19:38:37 EDT 2015
#~dd
} ;# B.ogr.fAdj_up




proc B.ogr.exhA {
    {rulerMarks 4}
    {rulerLength 6}
    {rankRange ""}
    {ABOUT ""} } {
    
    set thisCmd B.ogr.exhA
    # the known minimum length of the ruler
    #set lengthMin [B.ogr.minima $marks]
    
    # parameters for exhaustive evaluation
    set rankTarget   [expr {$rulerMarks - 2}]
    set L            [expr {$rulerLength - 1}] 
    set coordTotal   [expr {int(2**$L)}]
    set rankMax      $L
    if {$rankRange == ""} {
        set rankRange "0 $rankMax"
    } else {
        set rankRange [split $rankRange ,]
    }
    set rankL       [lindex $rankRange 0]
    set rankU       [lindex $rankRange 1]
    set hasseHeight [expr {$rankU - $rankL}]
    set workDir     [pwd]
    
    # generate a list of all binary coordinates
    set coordList {}
    for {set i 0} {$i < $coordTotal} {incr i} {
        set coord [B.coord.from_int $i $L]
        lappend coordList $coord
    }
    #puts coordList\n[join $coordList \n]
    
    # perform exhaustive enumeration  
    set valueBest +1e30 ; array unset hasseAry
    set isFeasibleCnt 0 ; set coordFeasibleList {}
    
    foreach coord [lsort $coordList] {
        set rank  [B.coord.rank $coord] 
        if {$rank >= $rankL && $rank <= $rankU} { 
            set value [B.ogr.f $coord $rankTarget]
	    if {$value < $valueBest} {set valueBest $value}
            lappend hasseAry($rank) $coord\:$value
            if {$value == 0} {
                lappend coordFeasibleAry($rank) $coord 
                lappend coordFeasibleList       $coord
                incr isFeasibleCnt
            }   
        }
    }
    puts "\n=============\nmarks\tnum_of_ogr (i.e. rulers with repeats = 0)"
    foreach rank [lsort -integer [array names coordFeasibleAry]] {
        puts [expr {$rank + 2}]\t[llength $coordFeasibleAry($rank)]
    }
    if {$L <= 6} {puts "" ;  parray hasseAry }
    set rankMax [expr {[array size hasseAry] - 1}]
    array unset bestAry
    puts "\ncoordRank   coordTotal" 
    set widthMax 0
    foreach rank [lsort -integer [array names hasseAry]] {
        set width [llength $hasseAry($rank)]
        if {$width > $widthMax} {set  widthMax $width}
        set listBest [lsearch -all -inline $hasseAry($rank) *:$valueBest]
        if {$listBest != {}} {set bestAry($rank) $listBest}
        #puts $rank\t$width\t[join $hasseAry($rank) " "]
        puts "$rank              $width"
    }
    puts "\nvalueBest = $valueBest"
    foreach rank [lsort -integer [array names bestAry]] {
        if {[info exists bestAry($rank)]} {
            puts "solutionBest(rank=$rank) = $bestAry($rank)"
        }
    }
     
    # this feature is needed for the follow-up tcl proc B.ogr.hasse
    if {$L <= 6} {
        puts "\n.. values returned by $thisCmd for  processing by B.ogr.hasse"
        return [list B $L $rankMax $widthMax  $coordList \
          [array get bestAry] [array get hasseAry]]
    } else {
        set tableLines "# created by \
          \n# $thisCmd $instanceDef $functionMode \
          \n# [join [clock format [clock seconds]]]\
          \n# 
          \nrank\tcoord:value\n"
        foreach rank [lsort -integer [array names hasseAry]] {
            append tableLines $rank\t$hasseAry($rank)\n
        }
        append tableFile $thisCmd - $rulerLength - hasseAry.txt
        file.write $tableFile $tableLines
        puts ".. created file \n$tableFile"
        return
    }
#     
# Copyright:
# Franc Brglez, Wed Aug  5 20:35:51 EDT 2015
#~dd 
} ;# B.ogr.exhA

proc B.ogr.hasse { {rulerMarks 4} {rulerLength 6} } {   
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.ogr.hasse
set ABOUT \
"...EDIT....This proc takes the name the instance defined within the sandbox B.ogr 
and the value of instanceInit (a binary string) associated with the name
of this instance, then invokes B.ogr.exhA to access data structures 
needed to create two files in this command: a file of vertices 
and a file of edges, annotated with x-y coordinates for plotting of Hasse 
graphs under R."
    if {$rulerLength == "??"} {puts $ABOUT ; return }
    if {$rulerLength == "?"}  {error "Valid query is '$thisCmd ??'"; return}
#-- end   ABOUT ---------------------------------------------------------------#
    
    set rList [B.ogr.exhA $rulerMarks $rulerLength] 
    #puts \nrList\n$rList ; return
    
    set coordType      [lindex $rList 0]
    set L              [lindex $rList 1] 
    set rankMax        [lindex $rList 2]
    set widthMax       [lindex $rList 3]
    set coordList      [lindex $rList 4]
    array set bestAry  [lindex $rList 5]
    array set hasseAry [lindex $rList 6] 
    #parray bestAry ; puts " " ; parray hasseAry ;# return
    
    # create vertex and edge files for Hasse graph    
    append fileVertex fg-B.ogr- $rulerLength -vertex.txt
    set tableVertex "\# \
      \n\#       file = $fileVertex \
      \n\# created on = [join [clock format [clock seconds] -gmt 0]]\
      \n\#         by = $thisCmd\
      \n\#\
      \ncoordX\tcoordY\tcoord\tvalue\n"
    
    set offset 1.0
    #set coordInit [lindex $coordList 0]
    for {set rank 0} {$rank <= $rankMax} {incr rank} {
        
        set  width [llength $hasseAry($rank)]
        set xFirst [expr {($widthMax - $width)/2. + $offset}]
        set idx 0
        foreach vertex $hasseAry($rank) {
            set tmp [split $vertex ":"]
            set coord [lindex $tmp 0] ; set value [lindex $tmp 1]
            set x [expr {$xFirst + $idx}] 
            set y $rank
            set vertexXY($coord) "$x $y"
            append tableVertex $x\t$y\t$coord\t$value\n
            incr idx
        }
    }  
    #parray vertexXY ;# return
    puts \ntableVertex\n$tableVertex
    file.write $fileVertex $tableVertex ; puts ".. created [file tail $fileVertex]"  
    
    # write edge data to file
    append fileEdge fg-B.ogr- $rulerLength -edge.txt
    set tableEdge "\# \
      \n\#       file = $fileEdge \
      \n\# created on = [join [clock format [clock seconds] -gmt 0]]\
      \n\#         by = $thisCmd\
      \n\#\
      \ncoordX0\tcoordY0\tcoordX1\tcoordY1\n"
    set coordInit [lindex $coordList 0]
    set nEdges 0 ; set coordTotal [llength $coordList]
    for {set iRow 0} {$iRow < $coordTotal} {incr iRow} {
    
        set cRow [lindex $coordList $iRow]
        for {set iCol $iRow} {$iCol < $coordTotal} {incr iCol} {
            if {$iRow != $iCol} {
                set cCol [lindex $coordList $iCol]
                set adjacency [B.coord.distance $cRow $cCol]
                if {$adjacency == 1} {
                    # edges coordinates  
                    incr nEdges
                    set head $vertexXY($cRow)
                    set tail $vertexXY($cCol)
                    append tableEdge [join $head \t]\t[join $tail \t]\n
                }
            }
        }
    }
    set lastLine "\# hasse_vertices=$coordTotal, hasse_edges=$nEdges\n"
    append tableEdge $lastLine
    if {$nEdges < 37} {puts \n$tableEdge }
    file.write $fileEdge $tableEdge ; puts ".. created [file tail $fileEdge]"
#~dd 
# B.ogr.hasse 6
# .. created fg-B.ogr-6-vertex.txt
# .. created fg-B.ogr-6-edge.txt
# %
# Copyright: 
# Franc Brglez, Mon May 25 18:38:58 EDT 2015
#~dd         
} ;# B.ogr.hasse




proc B.ogr.minima { {marks 4} } {
    
    set thisCmd B.ogr.minima
    # the optimal GR lengths (for marks = 1, 2, ..., 16 are from 
    # http://en.wikipedia.org/wiki/Golomb_ruler
    set lengthList {
        0 1 3 6 11 17 25 34 44 55 72 85 106 127 151 177
    }
    if {$marks > 16} {
        error "\nERROR from $thisCmd\
          \nThe maximum supported value marks=16, $marks exceeds this value.\
          \nSolution: update $thisCmd for large values of marks.\n"
    }    
    return [lindex $lengthList [expr {$marks - 1}]] ;# first non-zero length
                                                     # is for  marks=2
#~dd
# % B.ogr.minima 4
# 6
# % B.ogr.minima 16
# 177
# % B.ogr.minima 5
# 11
#
# Copyright: 
# Franc Brglez, Sat Aug 18 11:58:49 EDT 2012
#~dd
} ;# B.ogr.minima

proc B.ogr.init {} {
    
    set thisCmd B.ogr.init
    
#!! global variables MUST be listed HERE, before their values are defined!! 
    global     tcl:  tcl_interactive tcl_libPath tcl_library tcl_patchLevel \
      tcl_pkgPath tcl_platform tcl_version
    
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
   
    set aV(rulerLength) [B.ogr.minima $aV(rulerMarks)]
    set aV(rankTarget)  [expr {$aV(rulerMarks) - 2}]
    set aV(L)           [expr {$aV(rulerLength) -1}]
    set aV(nDim)        $aV(L) 
    set aV(instanceDef) "$aV(rulerMarks),$aV(rulerLength)"
    
    if {![string is integer  $aV(seedInit)]} {
        set aV(seedInit) [expr {int(1e4*rand())}]
    } 
    expr {srand($aV(seedInit))}
    
    if {![string is integer $aV(rankInit)]} {
        set aV(rankInit) [expr {$aV(rankTarget) - 1}]
    } else {
        set aV(rankInit) $aV(rankInit)
    }
    
    if {$aV(coordInit) == "NA"} {
        set aV(coordInit) [B.coord.rand_with_rank $aV(L) $aV(rankInit)]
    } else {
        set aV(coordInit)  $aV(coordInit)
    }
    set aCoordHash0($aV(coordInit)) {}
    

    set aV(valueInit)     [B.ogr.f $aV(coordInit) $aV(rankTarget)]
    set aV(coordBest)     $aV(coordInit)
    set aV(valueBest)     $aV(valueInit)
    set aV(valueTarget)  -$aV(rankTarget)
    set aV(valueTol)      0.0
    set aV(targetReached) 0
    set aV(isCensored)    1
    
    set aV(runtime)       0.0
    set aV(cntProbe)      1
    set aV(walkLength)    0  
    set aV(cntRestart)    0 
    set aV(cntProbeLmt)   2147483647
    set aV(cntRestartLmt) 2147483647
    set aV(walkLengthLmt) 2147483647
    set aV(walkSegmLmt)   NA
    set aV(walkSegmCoef)  NA 
    
    if {$aV(isSimple) == "NA"} {
        set aV(isSimple) TRUE 
    } else {
        set aV(isSimple) FALSE
    }
    if {![info exists aV(solverID)]}  {
        append aV(solverID)     B.ogr - $aV(solverMethod)
    }
    
    if {![info exists aV(solverVersion)]} { ;# initialized under *mainsolverVersion 
        # create a 14-digit GMT stamp as the solver version
        set aV(solverVersion)  [join [clock format [clock seconds] -gmt 1\
          -format "%Y %m %d %H %M %S"] ""]
    }
    set aV(timeStamp)       [join [clock format [clock seconds] -gmt 1\
      -format "%Y %m %d %H %M %S"] ""]
    set aV(dateLine) [join [clock format [clock seconds]]]
    set aV(hostID) {}
    append aV(hostID) $tcl_platform(user)  @ \
      [lindex [split [info hostname] .] 0] - $tcl_platform(os) - \
      $tcl_platform(osVersion) 
    set aV(compiler) tcl-${tcl_patchLevel}
    
    
    if {$aV(valueInit) <=  $aV(valueTarget)} {
        puts "\# BINGO: valueTarget has been reached or exceeded with coordInit"
        set aV(targetReached) 1
        set aV(isCensored)    0
        B.ogr.stdout      [set withWarning 1]
    } else {
        #puts "\FROM $thisCmd" ; parray aV ; puts \n
    }
    return  "$aV(targetReached) $aV(coordInit) $aV(valueInit)"
#~dd
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xProj/B.ogr/xLib
# (xLib) 92 % source ../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# %
# % B.ogr.init 4 
# FROM B.ogr.init
# aV(L)             = 5
# aV(cntProbe)      = 1
# aV(cntProbeLmt)   = 2147483647
# aV(cntRestart)    = 0
# aV(cntRestartLmt) = 2147483647
# aV(commandLine)   = NA
# aV(compiler)      = tcl-8.5.8
# aV(coordBest)     = 10001
# aV(coordInit)     = 10001
# aV(dateLine)      = Thu Aug 27 12:49:54 EDT 2015
# aV(hostID)        = brglez@triangle-Darwin-14.5.0
# aV(isCensored)    = 1
# aV(isSimple)      = FALSE
# aV(nDim)          = 5
# aV(rankInit)      = 2
# aV(rankTarget)    = 2
# aV(rulerLength)   = 6
# aV(rulerMarks)    = 4
# aV(runtime)       = 0.0
# aV(runtimeLmt)    = 5
# aV(seedInit)      = 5342
# aV(solverID)      = NA
# aV(solverMethod)  = NA
# aV(solverVersion) = 20150827163748
# aV(speedProbe)    = 10000000000
# aV(targetReached) = 0
# aV(timeStamp)     = 20150827164954
# aV(valueBest)     = 0
# aV(valueInit)     = 0
# aV(valueTarget)   = -2
# aV(valueTol)      = 0.0
# aV(walkLength)    = 0
# aV(walkLengthLmt) = 2147483647
# aV(walkSegmCoef)  = NA
# aV(walkSegmLmt)   = NA
# 0 10001 0
# % 
# % B.ogr.init 4
# 0 00101 -1    
# % 
# % B.ogr.init 4 4944
# # BINGO: valueTarget has been reached or exceeded with coordInit
# # FROM B.ogr.stdout: A SUMMARY OF NAME-VALUE PAIRS 
# # commandLine = NA 
# #    dateLine = Thu Aug 27 13:38:50 EDT 2015  
# #   timeStamp = 20150827173850  
# #
# instanceDef		4,6
# solverID		NA
# solverMethod		NA
# isSimple		TRUE
# coordInit		01001
# coordBest		01001
# rulerInit		0,2,5,6
# rulerBest		0,2,5,6
# nDim		5
# walkLengthLmt		2147483647
# walkLength		0
# cntRestartLmt		2147483647
# cntRestart		0
# cntProbeLmt		2147483647
# cntProbe		1
# runtimeLmt		5
# runtime		0.0
# speedProbe		10000000000
# hostID		brglez@triangle-Darwin-14.5.0
# compiler		tcl-8.5.8
# walkSegmLmt		NA
# walkSegmCoef		NA
# seedInit		4944
# valueInit		-2
# valueBest		-2
# valueTarget		-2
# valueTol		0.0
# targetReached		1
# isCensored		0
# 1 01001 -2
# % 
#
# Copyright: 
# Franc Brglez, Thu Aug 27 12:00:36 EDT 2015
#~dd
} ;# B.ogr.init

proc B.ogr.fAdj_simple { {coordPiv 01010} {valuePiv 1} } {   
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.ogr.fAdj_simple
set ABOUT \
" 
         $thisCmd coordPiv
Example: $thisCmd $coordPiv

NEEDS EDITS ...
The command  $thisCmd takes a binary coordinate such as 0101010
which has length L = 7 and rank r = 3. This command returns a subset of 
** adjacent coordinates **,  all with the Hamming distance of 1 from the 
input coordinate and with rank (r-1). The size of this subset is r.
For input coordinate of rank 0, this command returns an empty set.
"
    if {$coordPiv == "??"} { puts $ABOUT ; return }
    if {$coordPiv == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
        
    set coordBest  NA ; set valueBest 2147483641 ; set valueProbedList {}
    set neighbSize 0  ; set coordBestList  {}    ; set coordProbedList {}
    
    set L          $aV(L)
    set rankTarget $aV(rankTarget)
    
    if {$aV(writeVar) == 3} {
        set distance 0 ; 
        set rank [B.coord.rank $coordPiv]
        set rowLines "FROM: $thisCmd\
          \nProbing ALL distance=1 neighbors of the\ninitial pivot\
          coordinate = $coordPiv\
          \ncntProbe\tIdx\tcoordPivot\tvalPivot\tcoordAdj\tvalAdj\tdist\trank\
          \n~\t~\t$coordPiv\t$valuePiv\t~\t~\t$distance\t$rank\n"
    }
    for {set i 0} {$i < $L} {incr i} {  
        
        set bit [string index $coordPiv $i]
        if {$bit} {
            set coordAdj [string replace $coordPiv $i $i 0]
            #set mAdj     [expr {$mPiv - 1}]
        } else {
            set coordAdj [string replace $coordPiv $i $i 1]
            #set mAdj     [expr {$mPiv + 1}]
        }
        ##!! To maintain a self-avoiding walk, coordinates from the walk
        ##!! should be excluded from the neighborhood of the current pivot.
        #parray aCoordHash0  
        if {![info exists aCoordHash0($coordAdj)]} {
            incr neighbSize
            set valueAdj [B.ogr.f $coordAdj $rankTarget] ; incr aV(cntProbe)
            
            if {$aV(isWalkTables)} {
                lappend coordProbedList $coordAdj
                lappend valueProbedList $valueAdj
            }
            #!! aggregate coordBestList for random selection later
            if {$valueAdj <= $valueBest} {
                if {$valueAdj < $valueBest} {set coordBestList {}}
                set valueBest $valueAdj ; set coordBest $coordAdj
                lappend coordBestList $coordBest
            }
            if {$aV(writeVar) == 3} {
                set distance [B.coord.distance  $coordAdj  $coordPiv]
                set rank     [B.coord.rank $coordAdj]
                append rowLines $aV(cntProbe)\t$i\t$coordBest\t$valueBest\
                  \t$coordAdj\t$valueAdj\t$distance\t$rank\n
            }
        }
    }
    if {$aV(writeVar) == 3} {puts "$rowLines --neighbSize=$neighbSize"}
    
    #!! randomize the choice of coordBest from coordBestList 
    set idx [expr {int([llength $coordBestList]*rand())}]
    set coordBest [lindex $coordBestList $idx]
      
    if {$neighbSize > 0} {
        return "$coordBest $valueBest $neighbSize \
          [list $coordProbedList] [list $valueProbedList]"
    } else {
        return "NA NA $neighbSize {} {}"
    }
#~dd
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xProj/B.ogr/xWork
# % source ../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# %
# % B.ogr.init 4 1901 10000
# 0 10000 -1
# 
# % B.ogr.fAdj_simple 10000 -1
# FROM: B.ogr.fAdj_simple 
# Probing ALL distance=1 neighbors of the
# initial pivot coordinate = 10000 
# cntProbe	Idx	coordPivot	valPivot	coordAdj	valAdj	dist	rank 
# ~	~	10000	-1	~	~	0	1
# 1	0	00000	0	00000	0	1	0
# 1	1	11000	-1	11000	-1	1	2
# 1	2	10100	-1	10100	-1	1	2
# 1	3	10010	-2	10010	-2	1	2
# 1	4	10010	-2	10001	0	1	2
#  --neighbSize=5
# 10010 -2 5  {00000 11000 10100 10010 10001} {0 -1 -1 -2 0}
# % 
# 
# % B.ogr.init 4 1901 11000
# 0 11000 -1
# 
# % B.ogr.fAdj_simple 11000 -1
# FROM: B.ogr.fAdj_simple 
# Probing ALL distance=1 neighbors of the
# initial pivot coordinate = 11000 
# cntProbe	Idx	coordPivot	valPivot	coordAdj	valAdj	dist	rank 
# ~	~	11000	-1	~	~	0	2
# 1	0	01000	-1	01000	-1	1	1
# 1	1	10000	-1	10000	-1	1	1
# 1	2	10000	-1	11100	4	1	3
# 1	3	10000	-1	11010	4	1	3
# 1	4	10000	-1	11001	4	1	3
#  --neighbSize=5
# 01000 -1 5  {01000 10000 11100 11010 11001} {-1 -1 4 4 4}
# 
# % B.ogr.fAdj_simple 11000 -1
# FROM: B.ogr.fAdj_simple 
# Probing ALL distance=1 neighbors of the
# initial pivot coordinate = 11000 
# cntProbe	Idx	coordPivot	valPivot	coordAdj	valAdj	dist	rank 
# ~	~	11000	-1	~	~	0	2
# 1	0	01000	-1	01000	-1	1	1
# 1	1	10000	-1	10000	-1	1	1
# 1	2	10000	-1	11100	4	1	3
# 1	3	10000	-1	11010	4	1	3
# 1	4	10000	-1	11001	4	1	3
#  --neighbSize=5
# 10000 -1 5  {01000 10000 11100 11010 11001} {-1 -1 4 4 4}
# 
# % B.ogr.fAdj_simple 10000 -1
# FROM: B.ogr.fAdj_simple 
# Probing ALL distance=1 neighbors of the
# initial pivot coordinate = 10000 
# cntProbe	Idx	coordPivot	valPivot	coordAdj	valAdj	dist	rank 
# ~	~	10000	-1	~	~	0	1
# 1	0	00000	0	00000	0	1	0
# 1	2	10100	-1	10100	-1	1	2
# 1	3	10010	-2	10010	-2	1	2
# 1	4	10010	-2	10001	0	1	2
#  --neighbSize=4
# 10010 -2 4  {00000 10100 10010 10001} {0 -1 -2 0}
# % 
#
# Copyright: 
# Franc Brglez, Thu Aug 27 14:05:03 EDT 2015
#~dd 
} ;# B.ogr.fAdj_simple


proc B.ogr.stdout { {withWarning 1}
    {ABOUT "This procedure outputs results after a successful completion of
    a combinatorial solver. The output is directed to 'stdout' and includes
    a solution (a coordinate-value pair) and the observed performance values. 
    The format consists of a few comment lines, followed by tabbed  
    name-value pairs. The first pair is always 
                         instanceDef <value>"} } {

    set thisCmd B.ogr.stdout 
#!! global variables MUST be listed HERE, before their values are defined!! 
    global     info: all_info all_valu aV
    
    puts "# FROM $thisCmd: A SUMMARY OF NAME-VALUE PAIRS\
      \n# commandLine = $aV(commandLine)\
      \n#    dateLine = [join [clock format [clock seconds] -gmt 0]] \
      \n#   timeStamp = $aV(timeStamp) \
      \n#"
    
    set stdoutNames {instanceDef solverID solverMethod isSimple
        coordInit coordBest rulerInit rulerBest   nDim  
        walkLengthLmt walkLength  cntRestartLmt cntRestart   
        cntProbeLmt cntProbe runtimeLmt runtime speedProbe hostID 
        compiler walkSegmLmt walkSegmCoef seedInit  valueInit 
        valueBest  valueTarget valueTol targetReached isCensored
    } 
    set aV(speedProbe)  [expr {round($aV(cntProbe)/(1e-10 + $aV(runtime)))}]
    set aV(runtime)     [format.pretty $aV(runtime) 3]
    set aV(rulerInit)   [B.ogr.ruler_from_bin $aV(coordInit)]
    set aV(rulerBest)   [B.ogr.ruler_from_bin $aV(coordBest)]
    foreach name $stdoutNames {
        if {[info exists aV(${name})]} {
            puts "$name\t\t[eval subst {[set aV(${name})]}]"
        } else { 
            if {$withWarning} {
                puts "\# WARNING: no values exist for aV(${name})"
            }
        }
    }
#~dd 
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xProj/B.ogr/xWork
# % source ../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# % 
# 
# % B.ogr.init 4
# # BINGO: valueTarget has been reached or exceeded with coordInit
# # FROM B.ogr.stdout: A SUMMARY OF NAME-VALUE PAIRS 
# # commandLine = NA 
# #    dateLine = Thu Aug 27 14:37:54 EDT 2015  
# #   timeStamp = 20150827183754  
# #
# instanceDef		4,6
# solverID		NA
# solverMethod		NA
# isSimple		TRUE
# coordInit		01001
# coordBest		01001
# rulerInit		0,2,5,6
# rulerBest		0,2,5,6
# nDim		5
# walkLengthLmt		2147483647
# walkLength		0
# cntRestartLmt		2147483647
# cntRestart		0
# cntProbeLmt		2147483647
# cntProbe		1
# runtimeLmt		5
# runtime		0.0
# speedProbe		10000000000
# hostID		brglez@triangle-Darwin-14.5.0
# compiler		tcl-8.5.8
# walkSegmLmt		NA
# walkSegmCoef		NA
# seedInit		3744
# valueInit		-2
# valueBest		-2
# valueTarget		-2
# valueTol		0.0
# targetReached		1
# isCensored		0
# 1 01001 -2
# % 
# Copyright:
# Franc Brglez, Thu Aug 27 14:37:24 EDT 2015
#~dd
} ;# B.lightp.stdout


proc B.ogr.ruler_from_bin {
    {coord 10010} 
    {ABOUT "This proc takes a binary string S length L-1 of and returns
    an integer set of size M = weight(S) + 2. The first integer is always 0,
    the last integer if always L. Integer values between these two bounds
    are determined by the left-to-right positions of '1's in the binary string.
    This set of integers is also known as the Golomb Ruler."} } {
    
    # extract value of OGR marks and length from a binary coordinate
    set coordLength [string length $coord]
    set marks  [expr {[B.coord.weight $coord] + 2}]
    set length [expr {$coordLength + 1}]
    
    lappend ruler 0
    for {set i 0} {$i < $coordLength} {incr i} {
        set bit [string index $coord $i]
        if {$bit} {lappend ruler [expr {$i+1}]}
    }
    lappend ruler $length
    return [join $ruler ,]
#~dd  
# % B.ogr.ruler_from_bin 10010
# 0,1,4,6
# 
# % B.ogr.ruler_from_bin 000100001000001000000110
# 0,4,9,15,22,23,25  
# 
# Copyright: 
# Franc Brglez, Sat Aug 18 15:02:37 EDT 2012
#~dd  
} ;# B.ogr.ruler_from_bin

proc B.ogr.ruler_to_bin {
    {ruler 0,4,9,15,22,23,25} 
    {ABOUT "This proc takes a set of M sorted integers with first integer 
    valued at 0 and last integer valued at L. Such a set is also known as
    the Golomb Ruler 'M,L'. The proc returns an encoded representation
    of this set as a binary string of length L-1. The weight of this string
    (i.e. the number of 1's) is M-2, since the first and the last 
    mark are not explicitly encoded. Each integer value (except 0 and L) is
    marked as a '1' in the corresponding positon in the string."} } {
    
    # convert a golomb ruler to a binary string
    # ruler 0,4,9,15,22,23,25
    #      000100001000001000000110
    #     0         1         2
    #     01234567890123456789012345
    set rulerList [split $ruler ,]
    set L [lindex $rulerList end]
    foreach i $rulerList {set rulerAry($i) 1}

    set coord {}    
    foreach mark [lsort -integer [array names rulerAry]] {
        
        if {$mark == 0} {
            set markPrev 0
        } else {
            set diff [expr {$mark - $markPrev - 1}]
            set markPrev $mark
            #puts $mark...$diff
            if {$mark < $L} {
                append coord [string repeat 0 $diff]1
            } else {
                append coord [string repeat 0 $diff]
            }
            #puts coord=$coord
        }
    }
    return $coord
#~dd 
# % B.ogr.ruler_to_bin 0,1,4,6
# 10010
# % B.ogr.ruler_to_bin [join "0 1 4 9 11" ,] ;# canonic form, from Wikipedia
# 1001000010
# %
# % B.ogr.ruler_to_bin [join "0 2 7 8 11" ,] ;# canonic form, from Wikipedia
# 0100001100
# % 
# % B.ogr.ruler_to_bin [join "0 1 4 9 15 22 32 34" ,] ;# canonic form, from Wikipedia
# 100100001000001000000100000000010
# 
# Copyright: 
# Franc Brglez, Sat Aug 18 15:02:37 EDT 2012
#~dd  
} ;# B.ogr.ruler_to_bin

#------- keep here as a 80-character reference line to check text width -------#

proc fg-ogr-asymp   { 
    {isHeader 1} {rulerMarks 5} {labelList "ogrX0 ogrTw"}
    {sampleFile1  xPeriment-ogrX0-100-1901-triangle/xPer-ogr0-1901-5,11-100-1901-sample-stats.txt} 
    {sampleFile2  xPeriment-ogrTw-100-1901-triangle/xPer-B.ogrT-1901-5,11-100-1901-sample-stats.txt} } {
       
    set thisCmd fg-ogr-asymp 
    set ABOUT "The proc $thisCmd ....."
    
    # read the table *-sample.txt
    lappend colNames "rulerMarks"
    if {[llength $labelList] == 1} {
        set rList [file.read.tableInR $sampleFile1] 
        set comments        [lindex $rList 0]
        set columnLabels    [lindex $rList 1]
        array set tableAry1  [lindex $rList 2] ;# parray tableAry1  ;# return
        foreach name $tableAry1(statsVar) {
            lappend colNames ${name}_[lindex $labelList 0]
        }
    } else {
        set rList [file.read.tableInR $sampleFile1] 
        set comments        [lindex $rList 0]
        set columnLabels    [lindex $rList 1]
        array set tableAry1  [lindex $rList 2] ;# parray tableAry1  ;# return
        
        set rList [file.read.tableInR $sampleFile2] 
        set comments        [lindex $rList 0]
        set columnLabels    [lindex $rList 1]
        array set tableAry2  [lindex $rList 2] ;# parray tableAry2 

        foreach name $tableAry1(statsVar) {
            lappend colNames ${name}_[lindex $labelList 0]
        }
        foreach name $tableAry1(statsVar) {
            lappend colNames ${name}_[lindex $labelList 1]
        }
    }
    if {$isHeader} {
        set tableLines "# created by the command $thisCmd\
          \n# on [join [clock format [clock seconds] -gmt 0]] \
          \n# $thisCmd $isHeader $rulerMarks $labelList $sampleFile1 $sampleFile2\
          \n# \
          \n[join $colNames \t]\n"
        append tableLines $rulerMarks \t [join $tableAry1(mean) \t] \t [join $tableAry2(mean) \t] \n
        #puts $tableLines
    } else {
        set tableLines {}
        append tableLines $rulerMarks \t [join $tableAry1(mean) \t] \t [join $tableAry2(mean) \t] \n
    }
    puts $tableLines ;# return
    
    append tableFile $thisCmd - [join $labelList -].txt
    if {$isHeader} {
        file.write   $tableFile $tableLines
        puts ".. file $tableFile has been created"
    } else {  
        file.append $tableFile $tableLines
        puts ".. file $tableFile has been appended"
    }
    return
#~dd
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed/xProj/B.ogr/xResults
#  % source ../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# % 

# % source xPeriment-ogr-100-1901-triangle.tcl
# .. invoking file.read from file.read.tableInR
# .. invoking file.read from file.read.tableInR
# # created by the command B.ogr.table_asymp 
# # on Fri Aug 28 00:19:13 EDT 2015  
# # B.ogr.table_asymp 1 5 ogrX0 ogrTw xPeriment-ogrX0-100-1901-triangle/xPer-ogr0-1901-5,11-100-1901-sample-stats.txt xPeriment-ogrTw-100-1901-triangle/xPer-B.ogrT-1901-5,11-100-1901-sample-stats.txt 
# #  
# rulerMarks	runtime_ogrX0	cntProbe_ogrX0	walkLength_ogrX0	cntRestart_ogrX0	speedProbe_ogrX0	runtime_ogrTw	cntProbe_ogrTw	walkLength_ogrTw	cntRestart_ogrTw	speedProbe_ogrTw
# 5	0	42.44	4.88	0.03	NA	0.00162	50.23	5.37	0	30351.49
# 
# .. file B.ogr.table_asymp-ogrX0-ogrTw.txt has been created
# .. invoking file.read from file.read.tableInR
# .. invoking file.read from file.read.tableInR
# 6	0	253.83	18.23	0.08	NA	0.0071	201.35	13.36	0	27086.7
# 
# .. file B.ogr.table_asymp-ogrX0-ogrTw.txt has been appended
# .. invoking file.read from file.read.tableInR
# .. invoking file.read from file.read.tableInR
# 7	0	995.93	47.52	0.17	NA	0.04935	1111.54	48.52	0	22336.8
# 
# .. file B.ogr.table_asymp-ogrX0-ogrTw.txt has been appended
# .. invoking file.read from file.read.tableInR
# .. invoking file.read from file.read.tableInR
# 8	0.0245	51984.8	1956.1	18.68	NA	1.52759	27941.71	878.36	0	18274.82
# 
# .. file B.ogr.table_asymp-ogrX0-ogrTw.txt has been appended
# .. invoking file.read from file.read.tableInR
# .. invoking file.read from file.read.tableInR
# 9	0.1896	385139	12734.01	221.26	NA	8.99471	135785.6	3241.04	0	15084.55
# 
# .. file B.ogr.table_asymp-ogrX0-ogrTw.txt has been appended
# .. invoking file.read from file.read.tableInR
# .. invoking file.read from file.read.tableInR
# 10	0.9885	1629581	47406.88	842.11	NA	55.23293	686064.8	12970.38	0	12427.6
# 
# .. file B.ogr.table_asymp-ogrX0-ogrTw.txt has been appended
# .. invoking file.read from file.read.tableInR
# .. The command table.html created the file
# B.ogr.table_asymp-ogrX0-ogrTw.html
#  % 
# % 
# Copyright
# Franc Brglez, Fri Aug 28 00:26:56 EDT 2015
#~dd   
} ;# B.ogr.table_asymp
