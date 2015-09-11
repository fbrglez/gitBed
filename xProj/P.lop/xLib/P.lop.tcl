# Copyright:
# Franc Brglez, Wed Jan 21 21:58:27 EST 2015
#
#------- keep here as a 80-character reference line to check text width -------#


proc P.lop.saw {{Query "NA"}} {  
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.saw ; set sandbox P.lop ; set initProc P.lop.init 
set pivotProcSimple P.lop.saw_pivot_simple ; set pivotProc P.lop.saw_pivot
set ABOUT \
"Procedure $thisCmd takes, as **global** associative arrays, data structures 
initialized by $initProc under the sandbox $sandbox. It then constructs  
a segment of a self-avoiding walk (SAW). Under the command-line option 
-isSimple, the walk proceeds under the control of $pivotProcSimple, 
while by default the walk is controlled by a significantly more efficient 
procedure $pivotProc. Under various termination conditions, the walk 
stops and updates the **global** associative arrays; it also explicitly
returns triplet of values, including the 0|1|2 status of targetReached: 
      'targetReached coordBest valueBest'
"
    if {$Query == "??"} { puts $ABOUT ; return }
    if {$Query == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
#!! global variable names MUST be listed HERE
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
    
    # relevant primary input variables (remaining constant)
    set functionID      $aV(functionID)
    set runtimeLmt      $aV(runtimeLmt) 
    set cntProbeLmt     $aV(cntProbeLmt) 
    set walkLengthLmt   $aV(walkLengthLmt)
    set walkSegmLmt     $aV(walkSegmLmt)
    set valueTarget     $aV(valueTarget) 

    if {$aV(isSimple)} {
        set procPivotNext  P.lop.saw_pivot_simple
    } else {
        set procPivotNext  P.lop.saw_pivot
    } 
    puts "\# FROM: $thisCmd, starting to probe for pivotBest via $procPivotNext**"
    # auxiliary variables (changing dynamically)
    set aV(coordBest) $aV(coordInit)  ; set aV(valueBest) $aV(valueInit)
    set    coord      $aV(coordInit)  ; set    value      $aV(valueInit)
    set    step       0               
    
    while {1} {      
        #!! #** timing starts ***  
        set microSecs [lindex [time {
            
            # \nstep=$step...coordPivot=$coord
            # PROBE the neighborhood of the current pivot
            set bestNeighb [$procPivotNext  $coord  $value]
                
            # SELECT the next pivot from bestNeighb
            set coordNext      [lindex $bestNeighb 0] 
            set valueNext      [lindex $bestNeighb 1]
            set neighbSize     [lindex $bestNeighb 2]
            # this hash array is critical to maintaining a SAW segment!!
            set aCoordHash0([join $coordNext ,]) {}  
            
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
                set rankPr [P.coord.rank $coordPr]
                set aWalkProbed([format "%05d" $step],$cntNeighb) \
                  "$step $aV(cntRestart)\
                  [join $coordPr ,] $valuePr $rankPr $isPivot $cntNeighb NA"  
            }
            set isPivot 1 ; set neghbSize $cntNeighb
            set rank      [P.coord.rank $coord]
            set aWalkProbed([format "%05d" $step],0) "$step $aV(cntRestart)\
              [join $coord ,] $value $rank $isPivot $cntNeighb \
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
                set isPivot 1 ; set neghbSize $cntNeighb
                set rank [P.coord.rank $aV(coordBest)]
                set aWalkProbed([format "%05d" $step],0) "$step $aV(cntRestart)\
                  [join $aV(coordBest) ,] $aV(valueBest) $rank $isPivot $cntNeighb \
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
    if {$aV(valueBest) == $valueTarget} {
        set aV(targetReached) 1
    } elseif {$aV(valueBest) < $valueTarget} {
        set aV(targetReached) 2
    } else {
        set aV(targetReached) 0
    }
    return  $aV(targetReached)
#~dd
# % P.lop.main ../xBenchm/lop/tiny/pal-13.lop -seedInit 32
# 
# instanceDef           ../xBenchm/lop/tiny/pal-13.lop
# solverID              NA
# coordInit             3,4,10,2,5,1,12,7,13,11,8,9,6
# coordBest             8,3,12,9,1,10,4,13,7,2,11,5,6
# nDim          13
# walkLengthLmt         2147483647
# walkLength            968
# cntRestartLmt         2147483647
# cntRestart            0
# cntProbeLmt           2147483647
# cntProbe              11026
# runtimeLmt            30
# runtime               0.16181299999999987
# runtimeRead           0.000603
# speed         68140
# hostID                brglez@triangle-2-Darwin-14.3.0
# isSimple              FALSE
# neighbDist            1
# solverMethod          saw
# walkSegmLmt           NA
# walkSegmCoef          NA
# walkIntervalLmt               NA
# walkIntervalCoef              NA
# walkRepeatsLmt                NA
# seedInit              32
# valueInit             -37
# valueBest             -55
# valueTarget           -55.0
# valueTol              0.0
# targetReached         1
# isCensored            0
# 
# % P.lop.main ../xBenchm/lop/tiny/pal-13.lop -seedInit 32 -isSimple
# 
# instanceDef           ../xBenchm/lop/tiny/pal-13.lop
# solverID              NA
# coordInit             3,4,10,2,5,1,12,7,13,11,8,9,6
# coordBest             8,3,12,9,1,10,4,13,7,2,11,5,6
# nDim          13
# walkLengthLmt         2147483647
# walkLength            968
# cntRestartLmt         2147483647
# cntRestart            0
# cntProbeLmt           2147483647
# cntProbe              10058
# runtimeLmt            30
# runtime               0.4044799999999999
# runtimeRead           0.000614
# speed         24866
# hostID                brglez@triangle-2-Darwin-14.3.0
# isSimple              TRUE
# neighbDist            1
# solverMethod          saw
# walkSegmLmt           NA
# walkSegmCoef          NA
# walkIntervalLmt               NA
# walkIntervalCoef              NA
# walkRepeatsLmt                NA
# seedInit              32
# valueInit             -37
# valueBest             -55
# valueTarget           -55.0
# valueTol              0.0
# targetReached         1
# isCensored            0
# % 
    
    
} ;# P.lop.saw


proc P.lop.main { instanceDef args } {
    
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.main 
set ABOUT \
"
Proc $thisCmd takes a variable number of arguments: 'instanceDef' as the
required argument and a number of optional arguments (in any order).
To output the command line description of $thisCmd, invoke the command

  P.lop.info 1

To read the instance and output the initialized data structures **only**, 
invoke the command

  P.lop.main <instanceDef> -isInitOnly \[none-or-any-other-options\]
  
To read the instance and output results returned by the solver,
invoke the command

  P.lop.main <instanceDef> \[none-or-any-options\]

To output the command line documentation of the encapsulated/executable 
version of $thisCmd

  ../xBin/P.lopT
"
    if {$instanceDef == "??"} { puts $ABOUT ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
    
#!! (1) Phase 1: query about commandLine **OR** initialize all variables
    if {$instanceDef == 1} {
        # read solver domain table and return query about commandLine
        P.lop.info [set isQuery 1] $all_info(infoVariablesFile) 
        return
        
    } else {
        # proceed with variable initialization
    if {[llength $args] == 0} {set args ""}
    if {[llength $args] == 1} {set args [lindex $args 0]}
        set rList [P.lop.init $instanceDef $args]
    }
    if {[llength $rList] == 0} { 
        # Here, valueTarget > 0, i.e. valueTarget has been reached with 
        # coordInit and stdout response has been generated within P.lop.init
        return
    } elseif {$aV(isInitOnly)} {
        puts "# [string repeat - 78]\
          \n# .. completed initialization of all variables under P.lop.init,\
          \n#    exiting the solver since option -isInitOnly has been asserted.\
          \n# [string repeat - 78]"
        puts "targetReached coordInit valueInit = $rList\n"
        parray aV          ; puts \n ; parray aStruc      ; puts \n 
        parray aCoordHash0 ; puts \n ; parray aWalkProbed ; puts \n        
        return
    } else {
        puts "# [string repeat - 78]\
          \n# .. completed initialization of all variables under P.lop.init\
          \n# .. returning values of targetReached coordInit valueInit (below)\
          \n# $rList"
    } 

#!! (2) Phase 2: proceed with the combinatorial search ---
# NOTE: only P.lop.saw is stable currently    

    if {$aV(solverMethod) == "saw"} {
        set aV(solverID) P.lop.saw 
    } else {
        error "\nERROR from $thisCmd:\
          \nsolverMethod = $aV(solverMethod) is not implemented\n"
    }
    # here we invoke the selected solver
    puts "#    Proceeding with the search under solverID = $aV(solverID)\
      \n# [string repeat - 78]"
    $aV(solverID) 
    
#!! return results in a standardized name-valueString format
    # (instanceDef is the first keyword name)
    set aV(coordInit) [join $aV(coordInit) ,] 
    set aV(coordBest) [join $aV(coordBest) ,] 
    P.lop.stdout      [set withWarning 1] 
    
    if {$aV(isWalkTables)} {
        walk.tables \
          $aV(solverID) [file tail [file rootname $aV(instanceDef)]]\
          $aV(seedInit) $aV(walkLength) [array get aWalkProbed]
    }
    return
#~dd 
# % P.lop.main ../xBenchm/lop/tiny/pal-11.lop -seedInit 1 -isWalkTables
# # ** from: P.lop.init:
# # instanceDef=../xBenchm/lop/tiny/pal-11.lop 
# # argsOptions=-seedInit 1 -isWalkTables
# 
# # ------------------------------------------------------------------------------ 
# # .. completed initialization of all variables under P.lop.init.
# #    Proceeding with the search under solverID = P.lop.saw 
# # ------------------------------------------------------------------------------
# 
# # FROM: P.lop.saw, searching for pivotBest via P.lop.saw_pivot_simple**
# # 
# # FROM P.lop.stdout: A SUMMARY OF NAME-VALUE PAIRS 
# # commandLine = P.lop.main  ../xBenchm/lop/tiny/pal-11.lop -seedInit 1 -isWalkTables 
# #    dateLine = Tue Apr 21 16:18:52 EDT 2015  
# #   timeStamp = 20150421201852  
# #
# instanceDef       ../xBenchm/lop/tiny/pal-11.lop
# solverID      P.lop.saw
# coordInit     2,9,7,8,6,5,10,3,11,4,1
# coordBest     2,7,5,8,6,9,10,11,3,1,4
# nDim      11
# walkLengthLmt     2147483647
# walkLength        12
# cntRestartLmt     2147483647
# cntRestart        0
# cntProbeLmt       2147483647
# cntProbe      109
# runtimeLmt        30
# runtime       0.00733
# runtimeRead       0.000651
# speed     14870
# hostID        brglez@triangle-2-Darwin-14.3.0
# isSimple      1
# neighbDist        1
# solverMethod      saw
# walkSegmLmt       NA
# walkSegmCoef      NA
# walkIntervalLmt       NA
# walkIntervalCoef      NA
# walkRepeatsLmt        NA
# seedInit      1
# valueInit     -29
# valueBest     -35
# valueTarget       -35.0
# valueTol      0.0
# targetReached     1
# isCensored        0
# .. file fg-P.lop.saw-pal-11-walk-DownUp-1-12-probed.txt has been created
# .. file fg-P.lop.saw-pal-11-walk-DownUp-1-12.txt has been created
# .. file fg-P.lop.saw-pal-11-walk-DownOnly-1-12.txt has been created
# % 
# Copyright:
# Franc Brglez, Tue Apr 21 16:19:47 EDT 2015
#~dd    
} ;# P.lop.main

proc P.lop.init { instanceDef args } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.init ; set mainProc P.lop.main
set ABOUT \
"
Procedure $thisCmd takes a variable number of arguments: 
'instanceDef' as the required argument and optional arguments in any order. 
It then  decodes values of optional arguments  and initializes all variables 
under global arrays. $thisCmd is invoked by $mainProc; for details about 
the command-line structure, query '$mainProc ??'. 

Procedure $thisCmd implicitly returns initialized global array as well as 
explicit values of 

    'targetReached  coordInit valueInit'.
"
    if {$instanceDef == "??"} { puts $ABOUT ; return }
    if {$instanceDef == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
#!! global variables MUST be listed HERE, before their values are defined!! 
    global     tcl:  tcl_interactive tcl_libPath tcl_library tcl_patchLevel \
      tcl_pkgPath tcl_platform tcl_version
    
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
    
    # NOTE: args is a reserved-name variable ... save its values HERE
    set argsOptions $args
    
    # read the solver domain table
    set rList [ P.lop.info [set isQuery 0] $all_info(infoVariablesFile) ]
    array set all_info  [lindex $rList 0] 
    array set all_valu  [lindex $rList 1]

#!! (0A) Phase 0A: initialize all NEW global arrays
    foreach name [lindex $all_info(globalArrays) 0] {
        # NOTE: array all_info have been initialized ALREADY!!
        if {$name != "all_info" && $name != "all_valu"} {
            eval "array unset $name" ;# puts "unsetting array $name"
        }
    }
    # the check on llength of argsOptions when invoked under bash!!
    if {[llength $argsOptions] == 1} {set argsOptions [lindex $argsOptions 0]}
    puts "\# ** from: $thisCmd:\n\# instanceDef=$instanceDef\
      \n\# argsOptions=$argsOptions"
    
#!! (0B) Phase 0B: extract variable groups from array all_valu (created by proc P.lop.info)  
    foreach name [array names all_valu] {
        
        set val $all_valu($name)
        
        if {$val  == "required"} {
            lappend namesRequired $name 
        } elseif {$val  == "internal"} {
            lappend namesInternal $name
            set aV($name) NA            ;# this initialization is important here
        } elseif {$val  == "FALSE"} {
            lappend namesOptionalBool $name
            if {![info exists aV($name)]} {set aV($name) $val}
        } else {
            lappend namesOptional $name
            if {![info exists aV($name)]} {set aV($name) $val}
        }
    }
    #puts ".. after initializing aV from all_value array" ; parray aV
    
#!! (1) Phase 1: initialize the REQUIRED commandLine variables the global array aV, 
    #            including variables derived from instanceDef and infoSolutionsFile
    #
    set aV(instanceDef) $instanceDef ;# here, instanceDef is a filePath
    #!! #** timing starts *** 
    set microSecs [lindex [time {
        # read the instance file
        if {![file exists $aV(instanceDef)]} {
            error "\nERROR from $thisCmd:\
              \n.. there is no file $aV(instanceDef)\n"
        }
        set rList          [P.lop.file_read $aV(instanceDef)] ;# puts [join $aInstance \n]
        set aV(nDim)       [lindex $rList 0]
        array set aStruc   [lindex $rList 1] ;# array storing instance as a matrix
        set aV(varList)    [lindex $rList 2]
        set aV(density)    [lindex $rList 3]
        set aV(coordRef)   $aV(varList)
        set aV(instanceID) [file rootname [file tail $aV(instanceDef)]]
        
        # read infoSolutionsFile for this instance  
        set infoSolutionsDir [file dirname [file dirname $aV(instanceDef)]]
        append infoSolutionsFile $all_info(sandboxName) .info_solutions  .txt
        set infoSolutionsFile [file join $all_info(sandboxPath) xBenchm lop \
          $infoSolutionsFile]
        set aV(infoSolutionsFile) $infoSolutionsFile
        if {![file exists $infoSolutionsFile]} {
            error "\nERROR from $thisCmd:\nfile $infoSolutionsFile is missing!\n"
        }
        set rList [split [file.read $infoSolutionsFile] \n]
        foreach line $rList {
            set firstChar [string index $line 0] 
            if {$firstChar != "#" && [llength $line] > 0} {lappend rList $line}
        }   
        set isFound 0
        foreach line $rList {
            set varName    [lindex $line 0]
            if {$varName == $aV(instanceID)} {
                set aV(valueTarget) [lindex $line 1] ; set aV(isProven) [lindex $line 2]
                set isFound 1
            } 
            if {$isFound} {break}
        }
        if {!$isFound} {
            error "\nERROR from $thisCmd:\
              \n.. instance $aV(instanceID) has not found in file\
              \n    $infoSolutionsFile\n"
        }
    } 1 ] 0 ] 
    #!! #** timing ends ***   
    set aV(runtimeRead) [expr {$microSecs/1e6}] 
    set aV(infoSolutionsFile) $infoSolutionsFile
    set aV(commandName) ${all_info(sandboxName)}.main
    set aV(commandLine) "$aV(commandName)  $instanceDef $argsOptions"
    # adjust valueTarget read from infoSolutionsFile
    set aV(valueTarget) [expr {$aV(valueTarget)*(1 - $aV(valueTol))}]
    #puts ".. after reading instanceDef and infoSolutionsFile" ; parray aV 
    
#!! (2A) Phase 2A: initialize the OPTIONAL commandLine variables
    if {$argsOptions != {}} {
        set tmpList $argsOptions
        while {$tmpList != {}} {
            set name [string trimleft [lindex $tmpList 0] "-"]
            if {[lsearch -exact $namesOptional     $name ] < 0 &&
                [lsearch -exact $namesOptionalBool $name ] < 0} {
                error "\nERROR from $thisCmd:\
                  \n.. option name $name is not either of two lists below:\n\
                  \n[lsort $namesOptional]\
                  \n\nnor\n\
                  \n[lsort $namesOptionalBool]\n"
            }
            if {[lsearch -exact $namesOptionalBool $name] >= 0} {
                # we have name of a boolean variable
                set aV($name) "TRUE"
                set tmpList [lrange $tmpList 1 end]
            } else {
                # we have a name-value pair
                set aV($name)  [lindex $tmpList 1]
                set tmpList    [lrange $tmpList 2 end]
            }
        }
    }
    
#!! (2B) Phase 2B: continue to initialize the OPTIONAL commandLine variables
    # aV(seedInit) must be initialized FIRST (needed for other initializations)
    if {$aV(seedInit) == "NA"} {
        # initialize the RNG  with a random seed
        set aV(seedInit) [expr {int(1e9*rand())}] ; expr {srand($aV(seedInit))} 
    } elseif {[string is integer $aV(seedInit)]} {
        # initialize the RNG  with a user-selected seed
        expr {srand($aV(seedInit))}
    } else { 
        error "ERROR from $thisCmd:\
          \n.. only -seedInit NA or -seedInit <int> are valid assignments,\
          not -seedInit $V(seedInit)\n"
    }
    if {$aV(coordInit) == "NA"} {
        # generate a random permutation coordinate
        set aV(coordInit) [P.coord.rand $aV(nDim)]
        set aV(rankInit)  [P.coord.rank $aV(coordInit)]
    } else {
        # throw an error if the user-supplied coordInit is not a permutation of correct length
        set aV(coordInit) [split $aV(coordInit) ,]
        set coordTmp [lsort -integer -unique $aV(coordInit)]
        if {[lindex $coordTmp end] != $aV(nDim)} {
            error "\nERROR from $thisCmd:\
              \nThe permutation coordinate is of length [string length $coordTmp],\
              \nnot the expected length $aV(nDim)\n"
        }
        set aV(rankInit) [P.coord.rank $aV(coordInit)]
    }
    #puts ".. after reading instanceDef and infoSolutionsFile" ; parray aV 
    
    # REVIEW LATER .... ABOUT walkIntervalLmt && walkIntervalCoef
    if {0} {
    if {      $aV(walkIntervalLmt) == "NA"  && $aV(walkIntervalCoef) == "NA"} {
        # this is a valid default, no further action required
        
    } elseif {$aV(walkIntervalLmt) == "NA"  && [string is double $aV(walkIntervalCoef)]} {
        # walkIntervalCoef is defined by user-defined walkIntervalCoef
        if {$aV(walkIntervalCoef) > 0.} {
            set aV(walkIntervalLmt) [expr {int($aV(walkIntervalCoef)*$aV(nDim))}]  
        } else {
            error "\nERROR from $thisCmd:\
              \nThe walkIntervalCoef can only be assigned a value of NA \
              or a positive number > 0, not $aV(walkIntervalCoef) \n"
        }
        
    } elseif {[string is double $aV(walkIntervalLmt)]  && $aV(walkIntervalCoef) == "NA"} {
        # walkIntervalLmt is defined by user-defined walkIntervalLmt
        if {$aV(walkIntervalLmt) > 0} {
            set aV(walkIntervalLmt) [expr {int($aV(walkIntervalLmt))}]  
        } else {
            error "\nERROR from $thisCmd:\
              \nThe walkIntervalLmt can only be assigned a value of NA \
              or a positive number > 0, not $aV(walkIntervalLmt) \n"
        }
    } else {
        error "\nERROR from $thisCmd:\
          \nThe walkIntervalLmt AND walkIntervalCoef and only be assigned pairwise values of\
          \n(NA NA) (default), (NA double), or (integer, NA)\
          \nand not ($aV(walkIntervalLmt) $aV(walkIntervalCoef))\n"
    }}
    
    # REVIEW LATER .... ABOUT walkSegmLmt && walkSegmCoef
    if {      $aV(walkSegmLmt) == "NA"  && $aV(walkSegmCoef) == "NA"} {
        # this is a valid default, no further action required
        
    } elseif {$aV(walkSegmLmt) == "NA"  && [string is double $aV(walkSegmCoef)]} {
        # walkSegmCoef is defined by user-defined walkSegmCoef
        if {$aV(walkSegmCoef) > 0.} {
            set aV(walkSegmLmt) [expr {int($aV(walkSegmCoef)*$aV(nDim))}]  
        } else {
            error "\nERROR from $thisCmd:\
              \nThe walkSegmCoef can only be assigned a value of NA \
              or a positive number > 0, not $aV(walkSegmCoef) \n"
        }
        
    } elseif {[string is double $aV(walkSegmLmt)]  && $aV(walkSegmCoef) == "NA"} {
        # walkSegmLmt is defined by user-defined walkSegmLmt
        if {$aV(walkSegmLmt) > 0} {
            set aV(walkSegmLmt) [expr {int($aV(walkSegmLmt))}]  
        } else {
            error "\nERROR from $thisCmd:\
              \nThe walkSegmLmt can only be assigned a value of NA \
              or a positive number > 0, not $aV(walkSegmLmt) \n"
        }
    } else {
        error "\nERROR from $thisCmd:\
          \nThe walkSegmLmt AND walkSegmCoef and only be assigned pairwise values of\
          \n(NA NA) (default), (NA double), or (integer, NA)\n"
    }

#!! (3A) Phase 3A: directly initialize the remaining INTERNAL variables
    # under array aV    
    set aV(coordType)         P
    set aV(functionDomain)    P.lop
    set aV(functionID)        lop


    # define aV(solverID)       
#     if {$aV(solverMethod) == "ant" && $aV(isSimple)} {
#         set aV(solverID) ant_saw_simple    ;# self-avoding "ant walk" under "-isSimple" option
#     } elseif {$aV(solverMethod) == "bee" } {
#         set aV(solverID) ant_saw           ;# self-avoding "ant walk"
#     } elseif {$aV(solverMethod) == "bee" } {
#         set aV(solverID) bee_saw           ;# self-avoding "bee walk"
#     } elseif {$aV(solverMethod) == "rw" && !$aV(notSAW) } {
#         set aV(solverID) rw_saw            ;# random walk under self-avoidance
#     } elseif {$aV(solverMethod) == "rw" && $aV(notSAW)} {
#         set aV(solverID) rw                ;# random walk 
#     } elseif {$aV(solverMethod) == "sa" && !$aV(notSAW) } {
#         set aV(solverID) sa_saw            ;# simulated annealing walk under self-avoidance
#     } elseif {$aV(solverMethod) == "rw" && $aV(notSAW)} {
#         set aV(solverID) sa                ;# simulated annealing walk 
#     }
    
    if {$aV(solverVersion) == "NA"} {           ;# initialized under *mainsolverVersion 
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
    
    # find aV(valueInit), i.e. do the first-time probe for function value  
    #!! #** timing starts *** 
    set microSecs [lindex [time {
        set aV(valueInit) [P.lop.f $aV(coordInit)]
    } 1 ] 0 ] 
    #!! #** timing ends ***
    # initialize associated variables after the first probe
    set aV(runtime)    [expr {$microSecs/1e6}]
    set aV(cntProbe)   1 ; set aV(neighbSize) $aV(nDim)
    set aV(cntStep)    0
    set aV(coordPivot) $aV(coordInit)  ; set  aV(valuePivot) $aV(valueInit)
    set aV(coordBest)  $aV(coordInit)  ; set  aV(valueBest)  $aV(valueInit)
    set aCoordHash0([join $aV(coordInit) ,]) {}
    
#!! (4) Phase 4: check if valueTarget has been reached; 
    #   return to *.main if targetReached > 0   
    if {$aV(valueInit) == $aV(valueTarget)} {
        set aV(targetReached) 1
    } elseif {$aV(valueInit) < $aV(valueTarget)} {
        set aV(targetReached) 2
    } else {
        set aV(targetReached) 0
    }

#!! (5) Phase 5: complete initializations of array 'aV' before making the first step

    # NOTE: aHashNeighb is ALWAYS unset before each step/jump under the bee-walk
    #####set aHashNeighb([join $aV(coordInit) ,]) {} 
    # BUT, under saw_ant or saw_bee, aHashWalk is NOT unset until memory issues arise
    #set aHashWalk([join $aV(coordInit) ,]) {} 
    set aV(isCensored)  0  ; set aV(cntRestart) 0 
    #set aV(isTrapped)  0                            ;# LATER
    #set aV(walkRepeats) 0  ; set aV(walkInterval) 0 ;# LATER
    set aV(walkLength)  $aV(cntStep)
    # this size is specific for P-coordinates!!
    set aV(neighbSize)  [expr {$aV(nDim) - 1}]
    #if {$aV(neighbDist) == 1} {
    #   # this size is specific for P-coordinates!!
    #   set aV(neighbSize)  [expr {$aV(nDim) - 1}]
    #} else {
    #   set aV(neighbSize)  "dynamic"
    #}
 
#!! (6) Phase 6: initialize special arrays that may be 
    #            selected with arguments from the commandLine
    if {$aV(isWalkTables)} {
        set aV(isSimple) 1
        set isPivot 1
        set aV(rankPivot) [P.coord.rank $aV(coordPivot)]
        set aWalkProbed([format "%05d" $aV(walkLength)],0) "$aV(walkLength) $aV(cntRestart)\
          [join $aV(coordPivot) ,] $aV(valuePivot) $aV(rankPivot) $isPivot $aV(neighbSize) \
          $aV(cntProbe)"
    } else {
        set aWalkProbed([format "%05d" $aV(walkLength)],0) {}
    }    
    
#!! (7) Phase 7: verify all that ALL variables under array aV have been described 
    # in the solverDomain table all_info(infoVariablesFile)
    set errorItems {} ; set errorLines {}
    foreach name [array names aV]  {
        
        if {[lsearch -exact  [array names all_valu] $name ] < 0} {
            append errorLines "$name -- this variable is missing from \
              the solver domain table in file $all_info(infoVariablesFile)\n" 
            lappend errorItems $name
        }
    }
    if {$errorItems !={}} {
        puts "\n WARNING from $thisCmd\n$errorLines"
        puts "Missing variables (in alphabetical order)\n[join [lsort $errorItems] \n]"
    }
      
#!! (8) Phase 8: check whether coordInit induced the value with targetReached > 1
    if {$aV(targetReached) > 0} {
        # return results in a standardized name-valueString format
        # (instanceDef is the first keyword name)
        set aV(coordInit) [join $aV(coordInit) ,] 
        set aV(coordBest) [join $aV(coordBest) ,]
        puts "\# BINGO: valueTarget has been reached or exceeded with coordInit"
        P.lop.stdout      [set withWarning 1] 
        return
    }
    
#!! (9) Phase 9: write to stdout under various values of writeVar
    if {$aV(writeVar) == 1 } {
        puts "\n** Final values of initialized variables (array aV) **" ; parray aV 
        puts "\n** Values associated with instance array aStruc **" ; parray aStruc 
        puts "\n** as reported on [join [clock format [clock seconds] -gmt 0]], returning\
          \ntargetReached\tvalueInit\tcoordInit"
    }
    return "$aV(targetReached) [list $aV(coordInit)] $aV(valueInit)" 
    
#!! this code is no longer needed, may be useful elsewhere
#     # extract the argument list values (i.e. extract the commandLine)
#     set argsNames [info args $thisCmd]  
#     foreach arg $argsNames {
#         set argVal [eval subst {[set $arg]}] ; lappend argsValues $argVal
#     }
#     set aV(commandLineNames)  [list [lrange $argsNames  0 end-1]]
#     set aV(commandLineValues) [list [lrange $argsValues 0 end-1]]
    
#~dd  
# % P.lop.init ../xBenchm/lop/tiny/i-4-test-18.lop 
# # ** from: P.lop.init:
# # instanceDef=../xBenchm/lop/tiny/i-4-test-18.lop 
# # argsOptions=
# 0 {1 3 2 4} -9
# 
# % P.lop.init ../xBenchm/lop/tiny/i-4-test-18.lop
# # ** from: P.lop.init:
# # instanceDef=../xBenchm/lop/tiny/i-4-test-18.lop 
# # argsOptions=
# 0 {2 4 3 1} -17
# 
# % P.lop.init ../xBenchm/lop/tiny/i-4-test-18.lop
# # ** from: P.lop.init:
# # instanceDef=../xBenchm/lop/tiny/i-4-test-18.lop 
# # argsOptions=
# 0 {2 3 1 4} -11
# 
# % P.lop.init ../xBenchm/lop/tiny/i-4-test-18.lop -coordInit 3,2,4,1
# # ** from: P.lop.init:
# # instanceDef=../xBenchm/lop/tiny/i-4-test-18.lop 
# # argsOptions=-coordInit 3,2,4,1
# # BINGO: valueTarget has been reached or exceeded with coordInit
# # 
# # FROM P.lop.stdout: A SUMMARY OF NAME-VALUE PAIRS 
# # commandLine = P.lop.main  ../xBenchm/lop/tiny/i-4-test-18.lop -coordInit 3,2,4,1 
# #    dateLine = Mon May 18 12:34:34 EDT 2015  
# #   timeStamp = 20150518163434  
# #
# instanceDef		../xBenchm/lop/tiny/i-4-test-18.lop
# solverID		    NA
# coordInit		    3,2,4,1
# coordBest		    3,2,4,1
# nDim		        4
# walkLengthLmt		2147483647
# walkLength		0
# cntRestartLmt		2147483647
# cntRestart		0
# cntProbeLmt		2147483647
# cntProbe		    1
# runtimeLmt		30
# runtime		    2e-5
# runtimeRead		0.000456
# hostID		    brglez@triangle-2-Darwin-14.3.0
# isSimple		    FALSE
# solverMethod		saw
# walkSegmLmt		NA
# walkSegmCoef		NA
# seedInit		    409444908
# valueInit		    -18
# valueBest		    -18
# valueTarget		-18.0
# valueTol		    0.0
# targetReached		1
# isCensored		0
# %
# Copyright:
# Franc Brglez, Thu Apr 02 21:09:57 EDT 2015
#~dd   
} ;# P.lop.init




proc P.lop.hasse { {instanceDef  ../xBenchm/lop/tiny/i-4-test-18.lop} } {   
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.hasse
set ABOUT \
"This proc takes the path of an instance file associated with the sandbox P.lop 
and then invokes P.lop.exhA which reads the file and parameters and data 
structures needed to create two files in this procedure: a file of vertices 
and a file of edges, annotated with x-y coordinates for plotting of Hasse 
graphs under R."
    if {$instanceDef == "??"} { puts $ABOUT ; return }
    if {$instanceDef == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
        
    set rList [P.lop.exhA $instanceDef] ;# puts \nrList\n$rList
    
    set coordType      [lindex $rList 0]
    set L              [lindex $rList 1] 
    set rankMax        [lindex $rList 2]
    set widthMax       [lindex $rList 3]
    set coordList      [lindex $rList 4]
    array set bestAry  [lindex $rList 5]
    array set hasseAry [lindex $rList 6] 
    #parray bestAry ; puts " " ; parray hasseAry ; return
    
    # create vertex and edge files for Hasse graph    
    append fileVertex fg-P.lop- [file tail [file rootname $instanceDef]]-vertex.txt
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
    append fileEdge fg-P.lop- [file tail [file rootname $instanceDef]]-edge.txt
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
                set adjacency [P.coord.distance [split $cRow ,] [split $cCol ,]]
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
        
} ;# P.lop.hasse


proc P.lop.exhA { {instanceDef  ../xBenchm/lop/tiny/i-4-test-18.lop} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.exhA
set ABOUT \
"This proc reads an instance file associated with the sandbox P.lop and a file 
of all coordinates (here, permutations) induced by the dimension defined by 
this instance. It then performs an exhaustive evaluation for function values 
defined by the instance and returns the list of coordinate:value pairs as
solutions with the function value minima. A rank value (in context of the 
underlying Hasse graph) is also associated with each coordinate. For coordinate
lengths of size <= 5, the procedure returns the exhaustive solution set
and a data structure that can be passed on to a follow-up tcl procedure which
creates a file of vertices and a file of edges annotated with x-y coordinates
for plotting of Hasse graphs under R."
    if {$instanceDef == "??"} { puts $ABOUT ; return }
    if {$instanceDef == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    global instance: aStruc
    array unset aV ;  array unset aStruc               
    
    #-- read the instance
    puts ".. the matrix read from file $instanceDef\n[file.read $instanceDef]"
    set aInstance     [P.lop.file_read $instanceDef] ;# puts [join $aInstance \n]
    set aV(nDim)      [lindex $aInstance 0]
    array set aStruc  [lindex $aInstance 1]
    set aV(varList)   [lindex $aInstance 2]
    set aV(density)   [lindex $aInstance 3] ;# parray aStruc
    
    # read an exhaustive list of coordinates
    for {set i 1} {$i <= $aV(nDim)} {incr i} {lappend coordRef $i}
    append permFile ../../../../gitBed//xBenchm/perm/ perm.0$aV(nDim) .txt
    set coordList [file.read $permFile]
    puts ".. [llength $coordList] permutations read from file $permFile"
    #puts coordList\n$coordList ; return
    
    # find also whether the instance name designates a 0-valued matrix
    set lastChar [lindex [split [file tail [file rootname $instanceDef]] - ] end]
    if {$lastChar == "X"} {
        set aV(valueTarget) -1  ;# used in P.lop.f
    } else {
       set aV(valueTarget) NA
    }    
    set valueMin +1e30 ; array unset hasseAry
    foreach item $coordList {
        # here, item represents comma-separated coordinate
        set coord [split $item ,]
        set value [P.lop.f $coord]
        set rank  [P.coord.rank  $coord]
        lappend hasseAry($rank) [join $coord ,]\:$value
        if {$value < $valueMin} {set valueMin $value}
    }
    set rankMax [expr {[array size hasseAry] - 1}]
    array unset bestAry
    puts rank\t\size\tcoord_value_pairs
    set widthMax 0
    foreach rank [lsort -integer [array names hasseAry]] {
        set width [llength $hasseAry($rank)]
        if {$width > $widthMax} {set  widthMax $width}
        set listBest [lsearch -all -inline $hasseAry($rank) *:$valueMin]
        if {$listBest != {}} {set bestAry($rank) $listBest}
        puts $rank\t$width\t[join $hasseAry($rank) " "]
        #puts $rank\t$width
    }
    puts \nvalueBest=$valueMin
    foreach rank [lsort -integer [array names bestAry]] {
        if {[info exists bestAry($rank)]} {puts "bestAry($rank)\t= $bestAry($rank)"}
    }
    # this feature is needed for the follow-up tcl proc $P.lop.hasse
    if {$aV(nDim) <= 5} {
        puts "\n.. these values are returned for processing by P.lop.hasse"
        return [list P $aV(nDim) $rankMax $widthMax $coordList \
          [array get bestAry] [array get hasseAry]]
    } else {
        return
    }
#~dd
# % P.lop.exhA ../xBenchm/lop/tiny/i-4-test-13.lop
# .. the matrix read from file $../xBenchm/lop/tiny/i-4-test-13.lop
# 4
#   0  0  0  5  
#   1  0  2  0  
#   4  1  0  1    
#   3  2  1  0
# .. 24 permutations read from file ../../../../gitBed//xBenchm/perm/perm.04.txt
# valueBest=-13
# bestAry(2)	= 2,3,1,4:-13
# bestAry(3)	= 3,1,4,2:-13
# bestAry(5)	= 4,2,3,1:-13
# .. these values are returned for processing by P.lop.hasse
# P 4 6 6 {1,2,3,4
# 1,2,4,3
# 1,3,2,4
# ...
# ...
# 3 {1,4,3,2:-9 2,3,4,1:-11 2,4,1,3:-7 3,1,4,2:-13 3,2,1,4:-12 4,1,2,3:-8}}
# 
# % P.lop.exhA ../xBenchm/lop/tiny/i-4-test-X.lop
# .. the matrix read from file $../xBenchm/lop/tiny/i-4-test-X.lop
# 4
#   0  0  0  0
#   0  0  0  0  
#   0  0  0  0    
#   0  0  0  0
# .. 24 permutations read from file ../../../../gitBed//xBenchm/perm/perm.04.txt
# valueBest=0
# bestAry(0)	= 1,2,3,4:0
# bestAry(1)	= 1,2,4,3:0 1,3,2,4:0 2,1,3,4:0
# bestAry(2)	= 1,3,4,2:0 1,4,2,3:0 2,1,4,3:0 2,3,1,4:0 3,1,2,4:0
# bestAry(3)	= 1,4,3,2:0 2,3,4,1:0 2,4,1,3:0 3,1,4,2:0 3,2,1,4:0 4,1,2,3:0
# bestAry(4)	= 2,4,3,1:0 3,2,4,1:0 3,4,1,2:0 4,1,3,2:0 4,2,1,3:0
# bestAry(5)	= 3,4,2,1:0 4,2,3,1:0 4,3,1,2:0
# bestAry(6)	= 4,3,2,1:0
# .. these values are returned for processing by P.lop.hasse
# P 4 6 6 {1,2,3,4
# 1,2,4,3
# 1,3,2,4
# ...
# ...
# } {4 {2,4,3,1:0 3,2,4,1:0 3,4,1,2:0 4,1,3,2:0 4,2,1,3:0} 0 1,2,3,4:0 5 {3,4,2,1:0 4,2,3,1:0 4,3,1,2:0} 1 {1,2,4,3:0 1,3,2,4:0 2,1,3,4:0} 6 4,3,2,1:0 2 {1,3,4,2:0 1,4,2,3:0 2,1,4,3:0 2,3,1,4:0 3,1,2,4:0} 3 {1,4,3,2:0 2,3,4,1:0 2,4,1,3:0 3,1,4,2:0 3,2,1,4:0 4,1,2,3:0}} {4 {2,4,3,1:0 3,2,4,1:0 3,4,1,2:0 4,1,3,2:0 4,2,1,3:0} 0 1,2,3,4:0 5 {3,4,2,1:0 4,2,3,1:0 4,3,1,2:0} 1 {1,2,4,3:0 1,3,2,4:0 2,1,3,4:0} 6 4,3,2,1:0 2 {1,3,4,2:0 1,4,2,3:0 2,1,4,3:0 2,3,1,4:0 3,1,2,4:0} 3 {1,4,3,2:0 2,3,4,1:0 2,4,1,3:0 3,1,4,2:0 3,2,1,4:0 4,1,2,3:0}}
# % 
# Copyright: 
# Franc Brglez, Tue Jan 20 04:35:15 EST 2015
#~dd       
} ;# P.lop.exhA
    
#------- keep here as a 80-character reference line to check text width -------#

proc P.lop.exhB { {instanceDef ../xBenchm/lop/tiny/i-4-test-18.lop} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.exhB ; set sandbox P.lop
set ABOUT \
"
Example:         P.lop.exhB  ../xBenchm/lop/tiny/i-4-test-18.lop (under tclsh)
         ../xBin/P.lop.exhBT ../xBenchm/lop/tiny/i-4-test-18.lop (under bash)
         
The command $thisCmd takes an instance file (instanceDef) compatible with   
the sandbox $sandbox. The sandbox is defined by (1), permutation coordinates 
of length L (class P) and (2), the objective function associated with the 
instance (subclass lop). A total of (L!) permutation coordinates are generated 
iteratively, by repeated re-use of the associative array aCoordHash0, 
proceeding from all coordinates at rank k to all coordinates at rank k+1. 
The value of k is in the range  \[0, L*(L-1)/2\], where L*(L-1)/2 is the
height of the labeled Hasse graph. The label of each vertex in this graph is 
the pair 'coordinate:value', where 'value' is returned by the objective 
function evaluating the instance. The exhaustive evaluation provides insights 
about the min/max landscape of the instance and also features comprehensive 
instrumentation to measure the computational cost and the efficiency of 
the methods.

For a stdout query, use one of these these commands:
          P.lop.exhB  ??  (after sourcing the file all_tcl under tclsh)
  ../xBin/P.lop.exhBT     (immediately executable under bash) 

"
    if {$instanceDef == "??"} { puts $ABOUT ; return }
    if {$instanceDef == "?"}  { error "Valid query is '$thisCmd ??'" ;return }
#-- end   ABOUT ---------------------------------------------------------------#

    global tcl_platform tcl_patchLevel
    global     info: all_info all_valu aV
    global instance: aStruc
    array unset aV ; array unset aStruc
    
    #-- read the instance
    puts [file.read $instanceDef]
    set aInstance     [P.lop.file_read $instanceDef] ;# puts [join $aInstance \n]
    set aV(nDim)      [lindex $aInstance 0] ;# parray aV
    array set aStruc  [lindex $aInstance 1] ;# parray aStruc
    set aV(varList)   [lindex $aInstance 2]
    set aV(density)   [lindex $aInstance 3]

    set aV(valueTarget) NA ;# NEEDED so P.Lop can proceed ...
    # since we are dealing with permutation coordinates
    set L $aV(nDim) ; set Lm1 [expr {$L - 1}]
    set rankMax [expr {$L*($L - 1)/2}]
    
    # define coordinate:value pair with rank=0
    set coordRef $aV(varList)
    set coordList0 [list $coordRef] ; set value [P.lop.f  $coordRef]    
    set valueBest 1e30 
    lappend bestAry($value) 000\_[join $coordRef ,]\:$value
    set coordDistrib(000) 1 ; set sizeTot 1
 
    # For each rank, unset aCoordHash0 before aggregating coordList1
    # then probe P.lop.f for function value
    array unset aCoordHash0 ; set coordList1 {} 
    set runtimeCoord 0.0 ; set runtimeProbe 0.0 ; 
    if {$L <= 5} {lappend hasseVertices(0,1) [join $coordRef ,]\:$value} 
    
    # at each rank, generate all unique coordinates and probe for function values
    for {set rank 1} {$rank <= $rankMax} {incr rank} {
        
        #!! #** timing starts for coordList *** 
        # given coordList0, compute coordList1, up to rankMax
        set microSecs [lindex [time {
        foreach coord $coordList0 {
           
            set elm_i [lindex $coord 0]
            for {set i 0} {$i < $Lm1} {incr i} {
                set ip1 [expr {$i + 1}] ; set swapL $coord 
                # swap elements at i & ip1
                set elm_ip1 [lindex $coord $ip1]
                lset swapL $i $elm_ip1 ;# puts ---swapL-i,elm_ip1=$swapL
                if {$ip1 <= $Lm1} {           
                    lset swapL $ip1 $elm_i ;# puts +++swapL-ip1,elm_i=$swapL\n
                    set coordAdj $swapL
                    set elm_i [lindex $coord $ip1]
                }
                set inversion [P.coord.rank $coordAdj]
                #puts ip1...coordAdj=$ip1...$coordAdj...inversion=$inversion
                if {$inversion == $rank && ![info exists aCoordHash0([join $coordAdj ,])]} {
                    set aCoordHash0([join $coordAdj ,]) {}
                    lappend coordList1 $coordAdj ; incr sizeTot ; incr sizeRank
                }
            }
        }
        } 1 ] 0 ] 
        #!! #** timing ends for coordList ***         
        # RECORD runtimeCoord for current rank
        set runtimeCoord [expr {$runtimeCoord + ($microSecs/1e6)}]
        
        # now, probe each coordinate at current rank for function value 
        #!! #** timing starts ***  
        set microSecs [lindex [time {
        foreach coord $coordList1 {
            set value [P.lop.f $coord]
            if {$L <= 6} {
                lappend hasseVertices($rank,$sizeRank) [join $coord ,]\:$value
            }
            if {$value < $valueBest} {
                lappend bestAry($value) [format "%03d" $rank]\_[join $coord ,]\:$value
            }
        }
        } 1 ] 0 ] 
        #!! #** timing ends *** 
        # RECORD runtimeProbe for current rank
        set runtimeProbe [expr {$runtimeProbe + ($microSecs/1e6)}]
        
        # reinitialize parameters to generate coordinates at the next rank
        set coordDistrib([format "%03d" $rank]) $sizeRank
        set coordList0  $coordList1 ; set coordList1 {} ; set sizeRank 0
        array unset aCoordHash0
    } ;# for {set rank 1} {$rank <= $rankMax} {incr rank}
    if {$L <= 4} {parray hasseVertices }
    
    # find valueBest solutions
    set valueMin [lindex [lsort -integer [array names bestAry]] 0]
    puts "\nThere are [llength $bestAry($valueMin)] valueBest=$valueMin solutions:\
      \nrank\tsolution"
    foreach item [lsort $bestAry($valueMin)] {
        set rank     [lindex [split $item _] 0]
        set solution [lindex [split $item _] 1]
        puts $rank\t$solution
    }
    append hostID $tcl_platform(user)  @ \
      [lindex [split [info hostname] .] 0] - $tcl_platform(os) - \
      $tcl_platform(osVersion)
    puts "\
      \ninstanceDef = $instanceDef\
      \nThere are [llength $bestAry($valueMin)] valueBest=$valueMin solutions\
      \n     rankMax = $rankMax\
      \n coordLength = $L\
      \n coordTotal  = $sizeTot\
      \nruntimeCoord = [format "%6.4f" $runtimeCoord]\
      \nruntimeProbe = [format "%6.4f" $runtimeProbe]\
      \nruntimeRatio = [format "%6.4f" [expr {$runtimeCoord/$runtimeProbe}]]\
      \n      hostID = $hostID\
      \n    compiler = tcl-${tcl_patchLevel}\
      \n    dateLine = [join [clock format [clock seconds] -gmt 0]]\
      \n     thisCmd = $thisCmd\
      \n"
    parray coordDistrib
    return
#~dd
# % source ../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# % P.lop.exhB ../xBenchm/lop/tiny/i-4-test-18.lop
# 4
#   0  0  1  0
#   0  0  2  3  
#   6  5  0  0    
#   4  0  2  0
# 
# There are 1 valueBest=-18 solutions: 
# rank	solution
# 004	3,2,4,1:-18
#  
# instanceDef = ../xBenchm/lop/tiny/i-4-test-18.lop 
# There are 1 valueBest=-18 solutions 
#      rankMax = 6 
#  coordLength = 4 
#  coordTotal  = 24 
# runtimeCoord = 0.0013 
# runtimeProbe = 0.0006 
# runtimeRatio = 2.2862 
#       hostID = brglez@belair-Darwin-14.3.0 
#     compiler = tcl-8.5.8 
#     dateLine = Sun May 24 12:35:31 EDT 2015 
#     thisCmd = P.lop.exhB 
# 
# coordDistrib(000) = 1
# coordDistrib(001) = 3
# coordDistrib(002) = 5
# coordDistrib(003) = 6
# coordDistrib(004) = 5
# coordDistrib(005) = 3
# coordDistrib(006) = 1
# % 
# Copyright: 
# Franc Brglez, Tue Jan 20 21:41:21 EST 2015
#~dd    
} ;# P.lop.exhB

    
#------- keep here as a 80-character reference line to check text width -------#

proc P.lop.file_read { {instanceDef ../xBenchm/lop/tiny/i-5-book-247.lop} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.file_read  ; set sandbox P.lop
set ABOUT \
"Procedure $thisCmd takes the path of an instance file compatible with  
the sandbox $sandbox, reads the file contents and returns parameter values   
and data structures expected by the combinatorial solver under this sandbox."
    if {$instanceDef == "??"} { puts $ABOUT ; return }
    if {$instanceDef == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    set rList [split [file.read $instanceDef] \n]
    
    set nDim [lindex $rList 0] ; set i 0 ; set nItems 0
    foreach line [lrange $rList 1 end] {
        if {$line != {}} {
            #puts $line
            incr i
            for {set j 0} {$j < $nDim} {incr j} {
                set val [lindex $line $j]
                set Ary($i,[expr {$j+1}]) $val
                if {$val != 0.}  {incr nItems}
            }
        }
    }
    #parray Ary
    for {set i 1} {$i <= $nDim} {incr i} {lappend  varList $i}
    set density [expr { double($nItems)/($nDim*$nDim - $nDim)}]
    return [list $nDim [array get Ary] $varList $density]
#~dd   
# % P.lop.file_read ../xBenchm/lop/tiny/i-5-book-247.lop
#   0 16 11 15  7
#  21  0 14 15  9
#  26 23  0 26 12  
#  22 22 11  0 13
#  30 28 25 24  0
# Ary(1,1) = 0
# Ary(1,2) = 16
# Ary(1,3) = 11
# Ary(1,4) = 15
# Ary(1,5) = 7
# Ary(2,1) = 21
# Ary(2,2) = 0
# Ary(2,3) = 14
# Ary(2,4) = 15
# Ary(2,5) = 9
# Ary(3,1) = 26
# Ary(3,2) = 23
# Ary(3,3) = 0
# Ary(3,4) = 26
# Ary(3,5) = 12
# Ary(4,1) = 22
# Ary(4,2) = 22
# Ary(4,3) = 11
# Ary(4,4) = 0
# Ary(4,5) = 13
# Ary(5,1) = 30
# Ary(5,2) = 28
# Ary(5,3) = 25
# Ary(5,4) = 24
# Ary(5,5) = 0
# 5 {1,3 11 2,2 0 3,1 26 4,1 22 1,4 15 2,3 14 3,2 23 5,1 30 4,2 22 3,3 0 1,5 7 2,4 
# 15 5,2 28 4,3 11 3,4 26 2,5 9 5,3 25 4,4 0 3,5 12 5,4 24 4,5 13 5,5 0 1,1 0 1,2 
# 16 2,1 21} {1 2 3 4 5} 1.0
# % 
# Copyright: 
# Franc Brglez, Wed Jul 23 16:53:16 EDT 2014
#~dd 
} ;# P.lop.file_read 

proc P.lop.file_write {
    {coordPerm "5 3 4 2 1"}
    {instanceDef ../xBenchm/lop/tiny/i-5-book-247.lop} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.file_write
set ABOUT \
"This proc takes a permutation coordinate and the path of an instance file 
associated with the sandbox P.lop, reads the file contents and returns 
an isomorph instance file created by permuting rows and columns of the
original instance file."
    if {$coordPerm == "??"} { puts $ABOUT ; return }
    if {$coordPerm == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    set rList [split [file.read $instanceDef] \n] ;# puts [join $rList \n]
    
    set nDim [lindex $rList 0] ; set i 0
    foreach line [lrange $rList 1 end] {
        if {$line != {}} {
            #puts $line
            incr i
            for {set j 0} {$j < $nDim} {incr j} {
                set Ary($i,[expr {$j+1}]) [lindex $line $j]
            }
        }
    }
    #parray Ary
    
    for {set i 1} {$i <= $nDim} {incr i} {
        set iP [lindex $coordPerm [expr {$i-1}]]
        for {set j 1} {$j <= $nDim} {incr j} {
            set jP [lindex $coordPerm [expr {$j-1}]]
            #puts $i,$iP...$j,$jP
            set pAry($i,$j) $Ary($iP,$jP)
        }
    } 
    #parray pAry ;# return
    
    set rowLines $nDim\n
    for {set i 1} {$i <= $nDim} {incr i} {
        set row {}
        for {set j 1} {$j <= $nDim} {incr j} {
            append row  " $pAry($i,$j)"
        }
        append rowLines $row\n
    }
    #puts rowLines\n$rowLines
    set filePerm [file rootname $instanceDef]-[join $coordPerm ,].lop
    file.write $filePerm $rowLines
    puts ".. created file [file tail  $filePerm]"
#~dd   
# % exec cat ../xBenchm/lop/tiny/i-5-book-247.lop
# 5
#   0 16 11 15  7
#  21  0 14 15  9
#  26 23  0 26 12  
#  22 22 11  0 13
#  30 28 25 24  0
# 
# % P.lop.file_write "5 3 4 2 1" ../xBenchm/lop/tiny/i-5-book-247.lop
# .. created file i-5-book-247-5,3,4,2,1.lop
# % 
# % exec cat ../xBenchm/lop/tiny/i-5-book-247-5,3,4,2,1.lop
# 5
#  0 25 24 28 30
#  12 0 26 23 26
#  13 11 0 22 22
#  9 14 15 0 21
#  7 11 15 16 0
# 
# % 
# Copyright: 
# Franc Brglez, Wed Jul 23 16:53:16 EDT 2014
#~dd 
} ;# P.lop.file_write

proc P.lop.f { {coord "1 2 3 4 5"} } {  
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.f
set ABOUT \
"This procedure takes a permutation coordinate (passed as an argument) and  
the parameters from the instance file associated with the sandbox P.lop 
(passed in a global array aStruc). It computes and returns the instance 
function value, given this coordinate."
    if {$coord == "??"} { puts $ABOUT ; return }
    if {$coord == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    global     info: all_info all_valu aV
    global instance: aStruc
    
    set L $aV(nDim) ; set Lm1 [expr {$L - 1}]
    
    # here we handle a very special case, induced by P.lop.exhA
    if {$aV(valueTarget) == -1} {
        set sumTot 0
        return $sumTot  ;# induces SAWs that may create a trapped pivot 
                        ;# in Hasse graphs 
    } 
    # store the permuted coordinate in an array
    for {set i 1} {$i <= $L} {incr i} {set aPerm($i) [lindex $coord $i-1]}
    set value 0  
    for {set i 1} {$i < $L} {incr i} {
        set iP   $aPerm($i)   
        set ip1 [expr {$i + 1}] ; set sum 0   
        for {set j $ip1} {$j <= $L} {incr j} {
            set jP $aPerm($j)
            set sum [expr {$sum + $aStruc($iP,$jP)}]
        }
        set value [expr {$value + $sum}]  
    }
    set value -$value ;# should negative, to induce minimization!
    return  $value    ;# a value to search for valueBest <= valueTarget
# ~dd
# % P.lop.exhA ../xBenchm/lop/tiny/i-4-test-13.lop
# .. the matrix read from file $../xBenchm/lop/tiny/i-4-test-13.lop
# 4
#   0  0  0  5  
#   1  0  2  0  
#   4  1  0  1    
#   3  2  1  0
# .. 24 permutations read from file ../../../../gitBed//xBenchm/perm/perm.04.txt
# valueBest=-13
# bestAry(2)	= 2,3,1,4:-13
# bestAry(3)	= 3,1,4,2:-13
# bestAry(5)	= 4,2,3,1:-13
# .. these values are returned for processing by P.lop.hasse
# P 4 6 6 {1,2,3,4
# 1,2,4,3
# 1,3,2,4
# ...
# ...
# 3 {1,4,3,2:-9 2,3,4,1:-11 2,4,1,3:-7 3,1,4,2:-13 3,2,1,4:-12 4,1,2,3:-8}}
# 
# % P.lop.exhA ../xBenchm/lop/tiny/i-4-test-X.lop
# .. the matrix read from file $../xBenchm/lop/tiny/i-4-test-X.lop
# 4
#   0  0  0  0
#   0  0  0  0  
#   0  0  0  0    
#   0  0  0  0
# .. 24 permutations read from file ../../../../gitBed//xBenchm/perm/perm.04.txt
# valueBest=0
# bestAry(0)	= 1,2,3,4:0
# bestAry(1)	= 1,2,4,3:0 1,3,2,4:0 2,1,3,4:0
# bestAry(2)	= 1,3,4,2:0 1,4,2,3:0 2,1,4,3:0 2,3,1,4:0 3,1,2,4:0
# bestAry(3)	= 1,4,3,2:0 2,3,4,1:0 2,4,1,3:0 3,1,4,2:0 3,2,1,4:0 4,1,2,3:0
# bestAry(4)	= 2,4,3,1:0 3,2,4,1:0 3,4,1,2:0 4,1,3,2:0 4,2,1,3:0
# bestAry(5)	= 3,4,2,1:0 4,2,3,1:0 4,3,1,2:0
# bestAry(6)	= 4,3,2,1:0
# .. these values are returned for processing by P.lop.hasse
# P 4 6 6 {1,2,3,4
# 1,2,4,3
# 1,3,2,4
# ...
# ...
# } {4 {2,4,3,1:0 3,2,4,1:0 3,4,1,2:0 4,1,3,2:0 4,2,1,3:0} 0 1,2,3,4:0 5 {3,4,2,1:0 4,2,3,1:0 4,3,1,2:0} 1 {1,2,4,3:0 1,3,2,4:0 2,1,3,4:0} 6 4,3,2,1:0 2 {1,3,4,2:0 1,4,2,3:0 2,1,4,3:0 2,3,1,4:0 3,1,2,4:0} 3 {1,4,3,2:0 2,3,4,1:0 2,4,1,3:0 3,1,4,2:0 3,2,1,4:0 4,1,2,3:0}} {4 {2,4,3,1:0 3,2,4,1:0 3,4,1,2:0 4,1,3,2:0 4,2,1,3:0} 0 1,2,3,4:0 5 {3,4,2,1:0 4,2,3,1:0 4,3,1,2:0} 1 {1,2,4,3:0 1,3,2,4:0 2,1,3,4:0} 6 4,3,2,1:0 2 {1,3,4,2:0 1,4,2,3:0 2,1,4,3:0 2,3,1,4:0 3,1,2,4:0} 3 {1,4,3,2:0 2,3,4,1:0 2,4,1,3:0 3,1,4,2:0 3,2,1,4:0 4,1,2,3:0}}
# % 
# Copyright: 
# Franc Brglez, Tue Jan 20 04:35:15 EST 2015
#~dd   
} ;# proc P.lop.f

#------- keep here as a 80-character reference line to check text width -------#

proc P.lop.fAdj { {coordPiv    "5 3 2 1 4"} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.fAdj 
set ABOUT \
"This procedure takes a pivot coordinate and returns **a COMPLETE set of  
adjacent function values**  for the 'linear ordering problem' (lop).
We use a tableau formulation to **efficiently** probe the function not only
with the pivot coordinate but also with **all** of L-1 adjacent coordinates.
Values associated with adjacent coordinates are returned in an associated 
array aValueAdj; it can be searched efficiently for coordBest and valueBest 
before deciding on the pivotBest for the next step under the rules of 
the self-avoiding walk.
"
    if {$coordPiv == "??"} { puts $ABOUT ; return }
    if {$coordPiv == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#

    global     info: all_info all_valu aV
    global instance: aStruc
    
### PASS 1: given coordinate 'coordPiv', get sumP(i), valuePiv, coordAdj
    set L $aV(nDim) ; set Lm1 [expr {$L - 1}]
    
    # store the permuted coordinate in an array
    for {set i 1} {$i <= $L} {incr i} {set aPerm($i) [lindex $coordPiv $i-1]}
    
    set valuePiv 0  
    for {set i 1} {$i < $L} {incr i} {
        set iP   $aPerm($i)   
        set ip1 [expr {$i + 1}] ; set sum 0   
        for {set j $ip1} {$j <= $L} {incr j} {
            set jP $aPerm($j)
            set sum [expr {$sum + $aStruc($iP,$jP)}]
        }
        set sumP($iP) $sum                     ;# REQUIRED array for PASS 2
        set valuePiv [expr {$valuePiv + $sum}] ;# REQUIRED value for PASS 2
    }
    set valuePiv -$valuePiv ;# should negative, to induce minimization!
    set sumP($aPerm($L)) 0 ;# this value is by definition, MUST be inserted!!
    incr aV(cntProbe)
    #puts valuePiv=$valuePiv ; parray aPerm ; parray sumP ;# parray aStruc ; return

### PASS 2: get valueAdj for each adjacent coordinate 
    array unset aCoordAdj ; array unset aValueAdj ;# only aValueAdj is returned
    
    # initialize the first elm_i to be swapped
    # ... the 'swapping code' is the SAME CODE as for P.coord.neighborhood
    set elm_i $aPerm(1) ; set jP $elm_i
    for {set i 1} {$i < $L} {incr i} {
        set ip1 [expr {$i + 1}] 
        # swap elements at i & ip1 
        set elm_ip1 $aPerm($ip1) 
        set iP $elm_ip1 ; set jP $elm_i ;# ADDED for PASS 2
        set swapL $coordPiv
        lset swapL $i-1 $elm_ip1     ;# puts \n---swapL-i,elm_ip1=$swapL
        if {$ip1 <= $L} {           
            lset swapL $ip1-1 $elm_i ;# puts +++swapL-ip1,elm_i=$swapL
            set coordAdj $swapL      ;# puts coordPiv=$coordPiv\ncoordAdj=$coordAdj
            set elm_i $aPerm($ip1)   
        }
        #puts "adjP($iP)=[lrange $coordAdj $i   end]\
          \nadjP($jP)=[lrange $coordAdj $i+1 end]"

        set dif1 $sumP($iP) ;# sumP($iP) > 0 
        foreach k  [lrange $coordAdj $i end] {
            #puts iP,k=$iP,$k-dif1=[expr {$sum + $aStruc($iP,$k)}] 
            set dif1 [expr {$dif1 - $aStruc($iP,$k)}]
        }
        set dif2 $sumP($jP) ;# sumP($jP) > 0 
        foreach k  [lrange $coordAdj $i end] {
            #puts jP,k=$jP,$k-dif2=[expr {$dif2 + $aStruc($jP,$k)}] 
            set dif2 [expr {$dif2 - $aStruc($jP,$k)}]
        }
        set valueAdj [expr {$valuePiv + $dif1 + $dif2}] 
        # put under comments this entire block of code after sufficient testing
#         if {1} {
#             set valueAdjSimple [P.lop.f $coordAdj]
#             set dif [expr {$valueAdj - $valueAdjSimple}]
#             if {$dif != 0} {
#                 puts "ERROR from $thisCmd: wrong valueAdj computed:\
#                   v=$v...$coordAdj,$valueAdj,valueAdjSimple=$valueAdjSimple,dif=$dif"
#             }
#         }
        set aCoordAdj([join $coordAdj ,]) $valueAdj     ;# needed for test printout-only 
        lappend aValueAdj($valueAdj) [join $coordAdj ,] ;# returned as a list-of-pairs         
    }
    incr  aV(cntProbe)
    if {$aV(writeVar) == 3} {
        puts "FROM: $thisCmd\
          \nreturning the pivot coordinate:value pair AND ALL ADJACENT\
          \ncoordinate:value pairs, computed via the tableau method,\
          cntProbe= $aV(cntProbe)\
          \n-----\tcoord\tvalue\t-adj-value-from-P.lop.f\
          \npivot\t[join $coordPiv ,]\t$valuePiv\t[P.lop.f $coordPiv]"
        foreach coord [array names aCoordAdj] {
            puts -adj-\t$coord\t$aCoordAdj($coord)\t[P.lop.f [split $coord ,]]
        }
    }
    return [list $valuePiv [array get aValueAdj]]
#~dd  
# % P.lop.init ../xBenchm/lop/tiny/i-5-book2-51.lop -coordInit 5,3,2,1,4 -writeVar 3
# 0 {5 3 2 1 4} -46
# %
# % P.lop.fAdj {5 3 2 1 4} -46
# aPerm(1) = 5
# aPerm(2) = 3
# aPerm(3) = 2
# aPerm(4) = 1
# aPerm(5) = 4
# sumTot=46
# sumP(1) = 5
# sumP(2) = 6
# sumP(3) = 15
# sumP(4) = 0
# sumP(5) = 20
# 
# ---swapL-i,elm_ip1=3 3 2 1 4
# +++swapL-ip1,elm_i=3 5 2 1 4
# coordPiv=5 3 2 1 4
# coordAdj=3 5 2 1 4
# adjP(3)=5 2 1 4 
# adjP(5)=2 1 4
# iP,k=3,5-dif1=7
# iP,k=3,2-dif1=8
# iP,k=3,1-dif1=11
# iP,k=3,4-dif1=11
# jP,k=5,5-dif2=20
# jP,k=5,2-dif2=28
# jP,k=5,1-dif2=15
# jP,k=5,4-dif2=13
# 
# ---swapL-i,elm_ip1=5 2 2 1 4
# +++swapL-ip1,elm_i=5 2 3 1 4
# coordPiv=5 3 2 1 4
# coordAdj=5 2 3 1 4
# adjP(2)=3 1 4 
# adjP(3)=1 4
# iP,k=2,3-dif1=9
# iP,k=2,1-dif1=6
# iP,k=2,4-dif1=10
# jP,k=3,3-dif2=15
# jP,k=3,1-dif2=21
# jP,k=3,4-dif2=15
# 
# ---swapL-i,elm_ip1=5 3 1 1 4
# +++swapL-ip1,elm_i=5 3 1 2 4
# coordPiv=5 3 2 1 4
# coordAdj=5 3 1 2 4
# adjP(1)=2 4 
# adjP(2)=4
# iP,k=1,2-dif1=11
# iP,k=1,4-dif1=10
# jP,k=2,2-dif2=6
# jP,k=2,4-dif2=11
# 
# ---swapL-i,elm_ip1=5 3 2 4 4
# +++swapL-ip1,elm_i=5 3 2 4 1
# coordPiv=5 3 2 1 4
# coordAdj=5 3 2 4 1
# adjP(4)=1 
# adjP(1)=
# iP,k=4,1-dif1=7
# jP,k=1,1-dif2=5
# FROM: P.lop.fAdj 
# returning the pivot coordinate:value pair AND ALL ADJACENT 
# coordinate:value pairs, computed via the tableau method, cntProbe= 3 
# -----	coord	value	-adj-value-from-P.lop.f 
# pivot	5,3,2,1,4	-46	-46
# -adj-	5,3,2,4,1	-43	-43
# -adj-	5,3,1,2,4	-51	-51
# -adj-	5,2,3,1,4	-47	-47
# -adj-	3,5,2,1,4	-43	-43
# -47 5,2,3,1,4 -43 {3,5,2,1,4 5,3,2,4,1} -51 5,3,1,2,4
# % 
    
# % P.lop.init ../xBenchm/lop/tiny/i-10-test1-67.lop -coordInit 1,2,3,4,5,6,7,8,9,10 -isSimple -writeVar 3
# 0 {1 2 3 4 5 6 7 8 9 10} -49
#     
# % P.lop.fAdj {1 2 3 4 5 6 7 8 9 10} -49
# FROM: P.lop.fAdj 
# returning the pivot coordinate:value pair AND ALL ADJACENT 
# coordinate:value pairs, computed via the tableau method, cntProbe= 9 
# -----	coord	value	-adj-value-from-P.lop.f 
# pivot	1,2,3,4,5,6,7,8,9,10	-49	-49
# -adj-	1,2,3,4,5,6,7,8,10,9	-48	-48
# -adj-	1,2,3,4,5,6,7,9,8,10	-49	-49
# -adj-	1,2,3,4,5,6,8,7,9,10	-50	-50
# -adj-	1,2,3,4,5,7,6,8,9,10	-51	-51
# -adj-	1,2,3,4,6,5,7,8,9,10	-45	-45
# -adj-	1,2,3,5,4,6,7,8,9,10	-47	-47
# -adj-	1,2,4,3,5,6,7,8,9,10	-49	-49
# -adj-	1,3,2,4,5,6,7,8,9,10	-51	-51
# -adj-	2,1,3,4,5,6,7,8,9,10	-53	-53
# %
# % P.lop.fAdj [P.coord.rand 10]
# FROM: P.lop.fAdj 
# returning the pivot coordinate:value pair AND ALL ADJACENT 
# coordinate:value pairs, computed via the tableau method, cntProbe= 16 
# -----	coord	value	-adj-value-from-P.lop.f 
# pivot	3,1,2,5,10,9,6,4,7,8	-46	-46
# -adj-	3,1,2,5,10,9,6,4,8,7	-47	-47
# -adj-	3,1,2,5,10,9,6,7,4,8	-46	-46
# -adj-	3,1,2,5,10,9,4,6,7,8	-46	-46
# -adj-	3,1,2,5,10,6,9,4,7,8	-44	-44
# -adj-	3,1,2,5,9,10,6,4,7,8	-47	-47
# -adj-	3,1,2,10,5,9,6,4,7,8	-46	-46
# -adj-	3,1,5,2,10,9,6,4,7,8	-46	-46
# -adj-	3,2,1,5,10,9,6,4,7,8	-50	-50
# -adj-	1,3,2,5,10,9,6,4,7,8	-46	-46
#     
# % P.lop.init ../xBenchm/lop/tiny/pal-19-107.lop -isSimple -writeVar 3
# 0 {14 19 17 1 7 3 12 16 13 5 18 4 10 8 15 2 6 9 11} -91
# 
# % P.lop.fAdj  {14 19 17 1 7 3 12 16 13 5 18 4 10 8 15 2 6 9 11}
# FROM: P.lop.fAdj 
# returning the pivot coordinate:value pair AND ALL ADJACENT 
# coordinate:value pairs, computed via the tableau method, cntProbe= 3 
# -----	coord	value	-adj-value-from-P.lop.f 
# pivot	14,19,17,1,7,3,12,16,13,5,18,4,10,8,15,2,6,9,11	-91	-91
# -adj-	14,19,17,1,7,3,12,16,13,5,18,4,10,8,15,2,9,6,11	-92	-92
# -adj-	14,19,17,1,7,3,12,16,13,5,18,4,10,8,15,6,2,9,11	-90	-90
# -adj-	14,19,17,1,7,3,12,16,13,5,18,4,10,8,2,15,6,9,11	-90	-90
# -adj-	14,19,17,1,7,3,12,16,13,5,18,4,10,15,8,2,6,9,11	-90	-90
# -adj-	14,19,17,1,7,3,12,16,13,5,18,4,8,10,15,2,6,9,11	-90	-90
# -adj-	14,17,19,1,7,3,12,16,13,5,18,4,10,8,15,2,6,9,11	-90	-90
# -adj-	14,19,17,7,1,3,12,16,13,5,18,4,10,8,15,2,6,9,11	-90	-90
# -adj-	14,19,17,1,3,7,12,16,13,5,18,4,10,8,15,2,6,9,11	-92	-92
# -adj-	14,19,17,1,7,3,16,12,13,5,18,4,10,8,15,2,6,9,11	-90	-90
# -adj-	14,19,17,1,7,3,12,16,13,5,4,18,10,8,15,2,6,9,11	-90	-90
# -adj-	14,19,17,1,7,3,12,16,13,5,18,10,4,8,15,2,6,9,11	-90	-90
# -adj-	14,19,17,1,7,3,12,16,13,5,18,4,10,8,15,2,6,11,9	-92	-92
# -adj-	19,14,17,1,7,3,12,16,13,5,18,4,10,8,15,2,6,9,11	-90	-90
# -adj-	14,19,1,17,7,3,12,16,13,5,18,4,10,8,15,2,6,9,11	-92	-92
# -adj-	14,19,17,1,7,12,3,16,13,5,18,4,10,8,15,2,6,9,11	-90	-90
# -adj-	14,19,17,1,7,3,12,13,16,5,18,4,10,8,15,2,6,9,11	-90	-90
# -adj-	14,19,17,1,7,3,12,16,5,13,18,4,10,8,15,2,6,9,11	-90	-90
# -adj-	14,19,17,1,7,3,12,16,13,18,5,4,10,8,15,2,6,9,11	-92	-92
# 
# % P.lop.fAdj [P.coord.rand 19]
# FROM: P.lop.fAdj 
# returning the pivot coordinate:value pair AND ALL ADJACENT 
# coordinate:value pairs, computed via the tableau method, cntProbe= 5 
# -----	coord	value	-adj-value-from-P.lop.f 
# pivot	15,12,6,9,7,2,4,1,10,19,13,8,18,17,3,14,11,16,5	-85	-85
# -adj-	15,12,6,9,7,2,4,1,10,19,13,8,18,17,3,14,11,5,16	-86	-86
# -adj-	15,12,6,9,7,2,4,1,10,19,13,8,18,17,3,14,16,11,5	-84	-84
# -adj-	15,12,6,9,7,2,4,1,10,19,13,8,18,17,3,11,14,16,5	-84	-84
# -adj-	15,12,6,9,7,2,4,1,10,19,13,8,18,17,14,3,11,16,5	-84	-84
# -adj-	15,12,6,9,7,2,4,1,10,19,13,8,18,3,17,14,11,16,5	-84	-84
# -adj-	15,12,6,9,7,2,4,1,10,19,13,8,17,18,3,14,11,16,5	-86	-86
# -adj-	12,15,6,9,7,2,4,1,10,19,13,8,18,17,3,14,11,16,5	-84	-84
# -adj-	15,12,6,9,7,2,4,10,1,19,13,8,18,17,3,14,11,16,5	-84	-84
# -adj-	15,12,6,9,7,2,4,1,19,10,13,8,18,17,3,14,11,16,5	-84	-84
# -adj-	15,6,12,9,7,2,4,1,10,19,13,8,18,17,3,14,11,16,5	-86	-86
# -adj-	15,12,9,6,7,2,4,1,10,19,13,8,18,17,3,14,11,16,5	-86	-86
# -adj-	15,12,6,7,9,2,4,1,10,19,13,8,18,17,3,14,11,16,5	-84	-84
# -adj-	15,12,6,9,2,7,4,1,10,19,13,8,18,17,3,14,11,16,5	-86	-86
# -adj-	15,12,6,9,7,4,2,1,10,19,13,8,18,17,3,14,11,16,5	-86	-86
# -adj-	15,12,6,9,7,2,1,4,10,19,13,8,18,17,3,14,11,16,5	-84	-84
# -adj-	15,12,6,9,7,2,4,1,10,13,19,8,18,17,3,14,11,16,5	-86	-86
# -adj-	15,12,6,9,7,2,4,1,10,19,8,13,18,17,3,14,11,16,5	-86	-86
# -adj-	15,12,6,9,7,2,4,1,10,19,13,18,8,17,3,14,11,16,5	-86	-86
# Copyright: 
# Franc Brglez, Tue May 19 16:17:33 EDT 2015
#~dd 
} ;# proc P.lop.fAdj

#------- keep here as a 80-character reference line to check text width -------#

proc P.lop.saw_pivot_simple  { {coordPiv "5 3 2 1 4"}  {valuePiv -46} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.saw_pivot_simple
set ABOUT \
"This procedure takes a pivot coordinate/value,  probes
the distance=1 neighborhood of a 'lop' (a linear ordering problem),
subject to the constraints of a SAW (self-avoiding walk) -- i.e. 
the best coord/value it returns has not been yet been selected
as the pivot for the next step. Neighborhood size of 0 signifies that 
the next step of a SAW is blocked. 
  This implementation is 'simple', i.e. for each pivot coordinate 
of length L, there are up to L-1 explicit probes of the function P.lop.f."
    if {$coordPiv == "??"} { puts $ABOUT ; return }
    if {$coordPiv == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
    
    set coordBest  NA ; set valueBest 2147483641 ; set valueProbedList {}
    set neighbSize 0  ; set coordBestList  {}    ; set coordProbedList {}
    
    # create all distance=1 adjacencies of coordP
    set L $aV(nDim) ; set Lm1 [expr {$L - 1}]
    set swapList {} ; array unset coordAdj
    
    # first elm_i to be swapped
    set elm_i [lindex $coordPiv 0]
    for {set i 0} {$i < $Lm1} {incr i} {
        
        set ip1 [expr {$i + 1}] ; set swapL $coordPiv
        # swap elements at i & ip1
        set elm_ip1 [lindex $coordPiv $ip1]
        lset swapL $i $elm_ip1        ;# puts \n---swapL-i,elm_ip1=$swapL
        if {$ip1 <= $Lm1} {
            lset swapL $ip1 $elm_i    ;# puts +++swapL-ip1,elm_i=$swapL
            set coordAdj($ip1) $swapL ;# parray coordAdj
            set elm_i [lindex $coordPiv $ip1]
        }
    }
    if {$aV(writeVar) == 3} {
        set rank [P.coord.distance $coordPiv  $aV(coordRef)]
        set rowLines "FROM: $thisCmd\
          \nProbing ALL distance=1 neighbors of the\ninitial pivot\
          coordinate = [join $coordPiv ,]\
           \npair\tcoord\tf\tfBest\trank\tcntNeighb\tcntProbe\
          \n--\t[join $coordPiv ,]\t$valuePiv\t$valuePiv\t$rank\
          \t0\t$aV(cntProbe)\n"
    }
    #parray coordAdj ;  return
    # find all free adjacent coordinates (distance=1 neighborhood)
    ##!! To maintain a self-avoiding walk, all coordinates in the walk
    ##!! should be excluded from the neighborhood of the current pivot.
    for {set i 0} {$i < $Lm1} {incr i} {
        set ip1 [expr {$i + 1}] 
        set coordA $coordAdj($ip1) 
        # check the hash table for presence of coordA
        if {![info exists aCoordHash0([join $coordA ,])]} {
            incr neighbSize
            set valueA [P.lop.f $coordA]
            incr aV(cntProbe)
            if {$aV(isWalkTables)} {
                lappend coordProbedList $coordA
                lappend valueProbedList $valueA
            }
            #!! aggregate coordBestList for random selection later
            if {$valueA <= $valueBest} {
                if {$valueA < $valueBest} {set coordBestList {}}
                set valueBest $valueA ; set coordBest $coordA
                set aAdjacent($valueA) $coordA
                lappend coordBestList [join $coordBest ,]
            }
            if {$aV(writeVar) == 3} {
                set iP     [lindex $coordA $i]
                set iP1    [lindex $coordA $ip1]
                set pair "$iP,$iP1"
                set rank [P.coord.distance $coordA  $aV(coordRef)]
                append rowLines $pair\t[join $coordA ,]\t$valueA\t$valueBest\t$rank\
                  \t$neighbSize\t$aV(cntProbe)\n
            }
        }
    }
    if {$aV(writeVar) == 3} {puts "$rowLines --neighbSize=$neighbSize"}
    
    #!! randomize the choice of coordBest from coordBestList 
    set idx [expr {int([llength $coordBestList]*rand())}]
    set coordBest [split [lindex $coordBestList $idx] ,]
      
    if {$neighbSize > 0} {
        return "[list $coordBest] $valueBest $neighbSize \
          [list $coordProbedList] [list $valueProbedList]"
    } else {
        return "NA NA $neighbSize {} {}"
    }   
#~dd  
# % P.lop.init ../xBenchm/lop/tiny/i-5-book2.lop -isInitOnly -writeVar 3 -coordInit 5,3,2,1,4
# # ** from: P.lop.init:
# # instanceDef=../xBenchm/lop/tiny/i-5-book2.lop 
# # argsOptions=-isInitOnly -writeVar 3 -coordInit 5,3,2,1,4
# 0 -46 {5 3 2 1 4}
# 
# % P.lop.saw_pivot_simple {5 3 2 1 4} -46
# 
# FROM: P.lop.saw_pivot_simple 
# Probing ALL distance=1 neighbors of the
# initial pivot coordinate = 5,3,2,1,4 
# pair  coord   f       fBest   rank    cntNeighb       cntProbe 
# --    5,3,2,1,4       -46     -46     7       0       1
# 3,5   3,5,2,1,4       -43     -43     6       1       2
# 2,3   5,2,3,1,4       -47     -47     6       2       3
# 1,2   5,3,1,2,4       -51     -51     6       3       4
# 4,1   5,3,2,4,1       -43     -51     8       4       5
# 
# {5 3 1 2 4} -51 4  {} {}
# % 
# 
# % P.lop.init ../xBenchm/lop/tiny/pal-11.lop -writeVar 3 -seedInit 1913
# ** from: P.lop.init:
# instanceDef=../xBenchm/lop/tiny/pal-11.lop 
# argsOptions=-writeVar 3 -seedInit 1913
# 0 -28 {7 6 2 5 11 4 10 9 8 3 1}
# 
# % P.lop.saw_pivot_simple {7 6 2 5 11 4 10 9 8 3 1} -28
# 
# FROM: P.lop.saw_pivot_simple 
# Probing ALL distance=1 neighbors of the
# initial pivot coordinate = 7,6,2,5,11,4,10,9,8,3,1 
# pair  coord   f       fBest   rank    cntNeighb       cntProbe 
# --    7,6,2,5,11,4,10,9,8,3,1 -28     -28     33      0       1
# 6,7   6,7,2,5,11,4,10,9,8,3,1 -29     -29     32      1       2
# 2,6   7,2,6,5,11,4,10,9,8,3,1 -29     -29     32      2       3
# 5,2   7,6,5,2,11,4,10,9,8,3,1 -27     -29     34      3       4
# 11,5  7,6,2,11,5,4,10,9,8,3,1 -29     -29     34      4       5
# 4,11  7,6,2,5,4,11,10,9,8,3,1 -27     -29     32      5       6
# 10,4  7,6,2,5,11,10,4,9,8,3,1 -29     -29     34      6       7
# 9,10  7,6,2,5,11,4,9,10,8,3,1 -29     -29     32      7       8
# 8,9   7,6,2,5,11,4,10,8,9,3,1 -29     -29     32      8       9
# 3,8   7,6,2,5,11,4,10,9,3,8,1 -29     -29     32      9       10
# 1,3   7,6,2,5,11,4,10,9,8,1,3 -27     -29     32      10      11
# 
# {7 6 2 5 11 4 9 10 8 3 1} -29 10  {} {}
# % 
# Copyright: 
# Franc Brglez, Mon Dec 15 13:29:22 EST 2014
#~dd 
} ;# proc P.lop.saw_pivot_simple





#------- keep here as a 80-character reference line to check text width -------#

proc P.lop.saw_pivot  { {coordPiv "5 3 2 1 4"} {valuePiv NA} } {       
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.saw_pivot 
set ABOUT \
"This procedure takes a pivot coordinate and first invokes the procedure 
P.lop.fAdj -- an efficient and effective tableau-based procedure that returns 
ALL pairs of the adjacent coordinates with their values. Next, the procedure
selects the best pivot coordinate for the next step, subject to the
constraints of a SAW (self-avoiding walk) which effectively reduces the size
of the adjacent coordinates that are free as candiates. A neighborhood size 
of 0 signifies that the procedure is returning a 'trapped pivot'.
"
    if {$coordPiv == "??"} { puts $ABOUT ; return }
    if {$coordPiv == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#

    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
    
    set coordBest NA      ; set valueBest 2147483641 ; set valueProbedList {}
    set coordBestList  {} ; set neighbSize 0         ; set coordProbedList {}
    
    # get the pivot value and the entire pivot neighborhood
    set rList [P.lop.fAdj $coordPiv]
    set valuePiv        [lindex $rList 0]
    array set aValueAdj [lindex $rList 1]
    if {$aV(writeVar) == 3} {
        puts "pivotPair = [join $coordPiv ,]\:$valuePiv"
        parray aValueAdj
        parray aCoordHash0
        #return
    }
    # here, valueBest is the minimum integer argument of aValueAdj 
    set valueOrderedList [lsort -integer [array names aValueAdj]]
    #puts valueOrderedList=$valueOrderedList
    
    set isBestFound 0 ; set neighbSize $aV(neighbSize)
    foreach value $valueOrderedList {
        #!! choose coord randomly if more than 1 in $aValueAdj($value)
        #!! LATER: we may do this more efficiently by selecting randomly
        #          an index from [0 [length $aValueAdj($value)]) 
        foreach coord [list.shuffle10 $aValueAdj($value)] {
            #puts coordCurr=$coord,$value...neighbSize=$neighbSize
            if {![info exists aCoordHash0($coord)]} {
                #puts ".. found coodBest:valueBest as the next pivot"
                set coordBest $coord ; set valueBest $value
                set isBestFound 1
            }
            if {$isBestFound} {
                break
            } else {
                incr neighbSize -1
            }
        }
        if {$isBestFound} {break}
    }
    #puts coordBest=$coordBest,$valueBest...neighbSize=$neighbSize 
    return [list [split $coordBest ,] $valueBest $neighbSize]

#~dd  
# % P.lop.main ../xBenchm/lop/tiny/i-5-book2.lop -valueTarget -51 -writeVar 3 -coordInit 1,2,3,4,5
# # ** from: P.lop.init:
# # instanceDef=../../../xBenchm/lop/tiny/i-5-book2.lop 
# # argsOptions=-valueTarget -51 -writeVar 3 -coordInit 1,2,3,4,5
# 
# FROM: P.lop.saw_pivot.ant 
# Probing ALL distance=1 neighbors of the
# initial pivot coordinate = 1,2,3,4,5 
# pair  coord   f       fBest   rank    cntNeighb       cntProbe 
# --    1,2,3,4,5       -32     -32     0       0       2
# 2,1   2,1,3,4,5       -27     -27     5       1       3
# 3,2   1,3,2,4,5       -31     -31     5       2       4
# 4,3   1,2,4,3,5       -27     -31     5       3       5
# 5,4   1,2,3,5,4       -33     -33     4       4       6
# 
# FROM: P.lop.saw_pivot.ant (best next pivot)
# rList=1 2 3 5 4 -33 4  {} {}
# % 
# % P.lop.main ../xBenchm/lop/tiny/i-5-book2.lop -valueTarget -51 -writeVar 3 -coordInit 5,3,2,1,4
# # ** from: P.lop.init:
# # instanceDef=../../../xBenchm/lop/tiny/i-5-book2.lop 
# # argsOptions=-valueTarget -51 -writeVar 3 -coordInit 5,3,2,1,4
# 
# FROM: P.lop.saw_pivot_simple
# Probing ALL distance=1 neighbors of the
# initial pivot coordinate = 5,3,2,1,4 
# pair  coord   f       fBest   rank    cntNeighb       cntProbe 
# --    5,3,2,1,4       -46     -46     7       0       2
# 3,5   3,5,2,1,4       -43     -43     7       1       3
# 2,3   5,2,3,1,4       -47     -47     6       2       4
# 1,2   5,3,1,2,4       -51     -51     6       3       5
# 4,1   5,3,2,4,1       -43     -51     8       4       6
# 
# FROM: P.lop.saw_pivot_simple (best next pivot)
# rList=5,3,1,2,4 -51 4  {} {}
# % 
# Copyright: 
# Franc Brglez, Mon Dec 15 13:29:22 EST 2014
#~dd 
} ;# proc P.lop.saw_pivot


proc P.lop.stdout { {withWarning 1}
    {ABOUT "This procedure outputs results after a successful completion of
    a combinatorial solver. The output is directed to 'stdout' and includes
    a solution (a coordinate-value pair) and the observed performance values. 
    The format consists of a few comment lines, followed by tabbed  
    name-value pairs. The first pair is always 
                         instanceDef <value>
    This procedure is universal under any  function of coordType=P (permutation)!"} } {

    set thisCmd P.lop.stdout 
#!! global variables MUST be listed HERE, before their values are defined!! 
    global     info: all_info all_valu aV
    
    puts "# FROM $thisCmd: A SUMMARY OF NAME-VALUE PAIRS\
      \n# commandLine = $aV(commandLine)\
      \n#    dateLine = [join [clock format [clock seconds] -gmt 0]] \
      \n#   timeStamp = $aV(timeStamp) \
      \n#"
  
    set stdoutNames {instanceDef solverID coordInit coordBest nDim  
        walkLengthLmt walkLength  cntRestartLmt cntRestart   
        cntProbeLmt cntProbe runtimeLmt runtime runtimeRead speedProbe hostID 
        isSimple  solverMethod 
        compiler walkSegmLmt walkSegmCoef  seedInit  valueInit 
        valueBest  valueTarget valueTol targetReached isCensored
    }
    set aV(speedProbe)  [expr {round($aV(cntProbe)/(1e-10 + $aV(runtime)))}]
    set aV(runtime)     [format.pretty $aV(runtime) 3]
    set aV(runtimeRead) [format.pretty $aV(runtimeRead) 3]
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
# %  
    
# Copyright:
# Franc Brglez, Mon Nov 03 14:16:15 EST 2014
#~dd
} ;# P.lop.stdout

#------- keep here as a 80-character reference line to check text width -------#
proc P.lop.info {
    {isQuery 0}
    {infoVariablesFile ../xLib/P.lop.info_variables.txt}} {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd P.lop.info           
set ABOUT \
"
This proc takes a variable 'isQuery' and the hard-wired path to file
infoVariablesFile *info_variables.txt.  

  if isQuery == 0    then $thisCmd ONLY reads infoVariablesFile and 
                     initializes global arrays 'all_info' and 'all_valu'
              
  if isQuery == 1    then $thisCmd initializes the global arrays
                     'all_info' and 'all_valu' and then outputs to stdout  
                     the complete information about the command line for 
                     P.lop.main. The information about the command line 
                     is auto-generated within $thisCmd from the
                     tabulated data which is read from infoVariablesFile 
                     defined above.
                   
   if isQuery == ??  then $thisCmd responds to stdout with information 
                     about all three case of valid arguments. 

            P.lop.main ??   (under tclsh)
       or
            ../xBin/P.lopT  (under bash)
"
    if {$isQuery == "??"} { 
        puts $ABOUT ; return 
    } 
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    
    # read the  *.info_variables.txt for this solver domain  
    set rList           [table.info_variables $infoVariablesFile]
    array set all_info  [lindex $rList 0]
    array set all_valu  [lindex $rList 1]
    
    if {$isQuery == 0} {
         return
    } elseif {$isQuery != 1} {
        error "\nERROR from $thisCmd: incorrect argument value!\
          \nFor more information, use the command  P.lop.info ??\n"
    }
    # the preferred order (for user query) of optional commandLine argument names 
    set optInfoList {
        runtimeLmt cntProbeLmt cntRestartLmt walkLengthLmt seedInit coordInit   
        valueTol  walkSegmLmt walkSegmCoef 
        isSimple isWalkTables writeVar
    }
    
### Now, respond to a query from the user 
    puts "
USAGE: 
under TkCon shell (which sources ../xLib/all_tcl):
   P.lop.main <instanceDef> \[optional_arguments\]
   
under bash, invoking the 'tcl executable P.lopT' which sources libraries directly
  ../xBin/P.lopT <instanceDef> \[optional_arguments\]
  
under bash, invoking the 'python executable P.lopP' which sources libraries directly
  ../xBin/P.lopP <instanceDef> \[optional_arguments\]
  
under bash, invoking the 'compiled C++ code as as a binary P.lopX' 
  ../xBin/P.lopX  <instanceDef> \[optional_arguments\]
  
EXAMPLES:
  P.lop.main     ../xBenchm/lop/tiny/i-4-test-13.lop -isInitOnly
  P.lop.main     ../xBenchm/lop/tiny/i-4-test-13.lop  
  ../xBin/P.lopT ../xBenchm/lop/tiny/i-4-test-13.lop -runtimeLmt 5 -seedInit 1789
  ../xBin/P.lopP ../xBenchm/lop/tiny/i-4-test-13.lop -coordInit 1,2,3,4,5 -runtimeLmt 5 
  ../xBin/P.lopX ../xBenchm/lop/tiny/i-4-test-13.lop -coordInit 5,3,2,1,4 -seedInit 1914 
   
DESCRIPTION:  
P.lop.main, P.lopT, P.lopP, or P.lopX take one REQUIRED argument

    instanceDef  (here a filePath with an extension .lop or NO extension)
    
and a number of OPTIONAL arguments in any order. The most significant parameter,
extracted from the instanceDef is
    nDim ... coordinate size, 
             i.e. the number of variables (columns in the square matrix)
Here is a complete list of pairs 'name defaultValue', with short 
in-line descriptions:
"
    # create nameList and valueList with 
    foreach name $optInfoList {
        
        set value $all_valu($name)
        # create nameList and valuList paddded with blank spaces
        set     nameList {}    ; set     valueList {}
        lappend nameList $name ; lappend valueList $value
        for {set i 1} {$i < [llength $all_info($name)]} {incr i} {
            lappend nameList  [string repeat " " [string length $name]]
            lappend valueList [string repeat " " [string length $value]]
        }
        
        foreach nam $nameList val $valueList descr $all_info($name) {  
            set cnt       [expr {17 - [string length $nam]}]
            set space1    [string repeat " " $cnt]
            set cnt       [expr {12 - [string length $val]}]
            set space2    [string repeat " " $cnt]
            if {[llength $nam] > 0} {
                # prefix name with -
                set nam1 -$nam
            } else {
                set nam1 " $nam"
            }
            puts "  $nam1$space1$val$space2  $descr"
        }
    }
    puts "\nDETAILS:
This solver reads an instance of the 'linear ordering problem' in a matrix format
and returns a column/row ordering that minimizes the negative sum of matrix
elements above the diagonal. The example below shows an instance of such a matrix
with sum = -8 under its 'natural order', and an instance under an optimal 
permutation of 3,1,4,2 with a sum of -13. For this matrix, there are two more 
such optimal permutations: 2,3,1,4 and 4,2,3,1.
                 
natural order   under permutation
  1,2,3,4          3,1,4,2
  sum = -8         sum = -13
------------     ------------
4                4 
  0 0 0 5          0 4 1 1
  1 0 2 0          0 0 5 0
  4 1 0 1          1 3 0 2   
  3 2 1 0          2 1 0 0
"
    return
    
#~dd     
# % P.lop.main ?
# 
# USAGE: 
# under TkCon shell (which has sourced ../xLib/all_tcl):
#    P.lop.main instanceDef [optional_arguments]
#    
# under bash, invoking the 'tcl executable P.lopT' which sources libraries directly
#   ../xBin/P.lopT instanceDef [optional_arguments]
#   
# under bash, invoking the 'python executable P.lopP' which sources libraries directly
#   ../xBin/P.lopP instanceDef [optional_arguments]
#   
#   under bash, invoking the 'compiled C++ code as as a binary P.lopX' 
#   ../xBin/P.lopX  instanceDef [optional_arguments]
#   
# EXAMPLES:
#   P.lop.main     ../xBenchm/lop/tiny/i-5-book2.lop -isInitOnly
#   P.lop.main     ../xBenchm/lop/tiny/i-5-book2.lop -valueTarget -51 
#   ../xBin/P.lopT ../xBenchm/lop/tiny/i-5-book2.lop -valueTarget -51 -runtimeLmt 5 -seedInit 1789
#   ../xBin/P.lopP ../xBenchm/lop/tiny/i-5-book2.lop -valueTarget -51 -coordInit 1,2,3,4,5 -runtimeLmt 5 
#   ../xBin/P.lopX ../xBenchm/lop/tiny/i-5-book2.lop -valueTarget -51 -coordInit 5,3,2,1,4 -seedInit 1914 
#    
# DESCRIPTION:  
# P.lop.main, P.lopT, P.lopP, or P.lopX take one REQUIRED argument
# 
#     instanceDef  (here a filePath with an extension .lop or NO extension)
#     
# and a number of OPTIONAL arguments in any order. The most significant parameter,
# extracted from the instanceDef is
#     nDim ... coordinate size, 
#              i.e. the number of variables (columns in the square matrix)
# Here is a complete list of pairs 'name defaultValue', with short 
# in-line descriptions:
# 
#   -runtimeLmt       30            Stop if the solver runtime exceeds these many seconds.
#   -cntProbeLmt      2147483647    Stop if the solver reaches this value.
#   -cntRestartLmt    2147483647    Stop if the solver reaches this value.
#   -walkLengthLmt    2147483647    Stop if the solver reaches this value.
#   -seedInit         NA            If NA, a random positive integer is created to initialize a
#                                   random number generator.
#   -coordInit        NA            If NA, a random permutation coordinate is generated internally
#                                   as a string of size nDim Ñ unless initial coordinate is entered by the user.
#   -valueInit        internal      A value returned by objective function, given coordInit.
#   -valueTarget      internal      Objective function target value -- solver stops on reaching this value.
#   -valueTol         0.0           A coefficient to adjust valueTarget = valueTarget*(1 + valueTol).
#   -neighbDist       1             By default, neighbDist = 1 probes the pivot neighborhood at
#                                   distance of 1 only -- the maximum distance <= nDim*(nDim-1)/2.
#   -walkSegmLmt      NA            Inactive unless assigned an integer or if walkSegmCoef is assigned a real value.
#   -walkSegmCoef     NA            A coefficient that determines walkSegmLmt as walkSegmCoef*nDim.
#   -walkIntervalLmt  NA            Inactive unless assigned an integer or if walkIntervalCoef
#                                   is assigned a real value.
#   -walkIntervalCoef NA            A coefficient that determines walkIntervalLmt as walkIntervalCoef*nDim.
#   -walkRepeatsLmt   NA            Inactive unless assigned an integer. If an integer, the walk is
#                                   monitored for repeats of valueBest. If walkRepeats > walkRepeatsLmt,
#                                   the self-avoiding walk branches from another coordinate with valueBest.
#   -isSimple         FALSE         If asserted, simpler-to-code but less efficient procedures are invoked.
#   -writeVar         0             An integer variable to control levels of stdout:
#                                   If 0, do stdout with minimum lines of text.
#                                   If 1, do stdout of all variable values initialized under procedure *.init.
#                                   If 2, do stdout of cntRestart trace.
#                                   If 3, do stdout of distance=1 neighborhood probing and pivot selection.
#                                   If 4, do stdout of valueBest-only during the walk.
#                                   If 5, do stdout of up/down values during the walk.
#                                   If 6, do stdout of up/down values during the walk that includes all
#                                   'probed neighborhood values' at each step.
# 
# DETAILS:
# This solver reads an instance of the 'linear ordering problem' in a matrix format
# and returns a column/row ordering that minimizes the negative sum of matrix
# elements above the diagonal. The example below shows an instance of such a matrix
# with sum = -8 under its 'natural order', and an instance under an optimal 
# permutation of 3,1,4,2 with a sum of -13. For this matrix, there are two more 
# such optimal permutations: 2,3,1,4 and 4,2,3,1.
#                  
# natural order   under permutation
#   1,2,3,4          3,1,4,2
#   sum = -8         sum = -13
# ------------     ------------
# 4                4 
#   0 0 0 5          0 4 1 1
#   1 0 2 0          0 0 5 0
#   4 1 0 1          1 3 0 2   
#   3 2 1 0          2 1 0 0
# %     
# Copyright:
# Franc Brglez, Tue Mar 10 14:56:13 EDT 2015
#~dd 
} ;# P.lop.info

#------- keep here as a 80-character reference line to check text width -------#

proc P.lop.table_asymp_ranks { 
    {isHeader 1} {instanceSize 13} {instanceClass pal}
    {sampleFile  ../../../xBed/xLib/util_data/xPer-P.lopT-config2-pal-13-100-1901-sample.txt} } {
       
    set thisCmd P.lop.table_asymp_ranks
    set ABOUT "The proc $thisCmd ....."
    
    # read the table *-sample.txt
    set rList [file.read.tableInR $sampleFile] 
    set comments        [lindex $rList 0]
    set columnLabels    [lindex $rList 1]
    array set tableAry  [lindex $rList 2] ;# parray tableAry  ;# return
    
    set coordAll  $tableAry(coordBest)
    set sizeAll   [llength $coordAll]
    
    set coordUniq [lsort -uniq $coordAll]
    set sizeUniq  [llength $coordUniq]
    
    append tableFile $thisCmd - $instanceClass.txt
    set L $instanceSize
    set rankMax [expr {$L*($L - 1)/2}]
    set rankMid [expr {int($L*($L - 1)/4.)}]
    
    
    if {$isHeader} {
	set tableHeader "# created by the command $thisCmd\
	  \n# on [join [clock format [clock seconds] -gmt 0]] \
	  \n# $thisCmd $isHeader $instanceSize $instanceClass $sampleFile\
	  \n# \
	  \ninstanceSize\trank\trankMid\trankMax\
	  \tsizeAl\tsizeUniq\tcoordBest
	  \n# coordSizeAll = $sizeAll, coordSizeUniq = $sizeUniq\n"
	set tableLines $tableHeader
    } else {
	set tableLines "# coordSizeAll = $sizeAll, coordSizeUniq = $sizeUniq\n"
    }
    foreach coord $coordUniq {
	set rank [P.coord.rank [split $coord ,]]
	append tableLines $instanceSize\t$rank\t$rankMid\t$rankMax\
	  \t$sizeAll\t$sizeUniq\t$coord\n
    }
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
# /Users/brglez/Sites/~SYNC/gitBed/xProj/P.lop/xResults/VCL-pal
# 
# % source ../../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# (VCL-pal) 315 % source xPeriment-P.lopP-100-tableau-ranks-pal.tcl
# .. invoking file.read from file.read.tableInR
# .. file P.lop.table_asymp_ranks-pal.txt has been created
# .. invoking file.read from file.read.tableInR
# .. file P.lop.table_asymp_ranks-pal.txt has been appended
# .. invoking file.read from file.read.tableInR
# .. file P.lop.table_asymp_ranks-pal.txt has been appended
# .. invoking file.read from file.read.tableInR
# .. file P.lop.table_asymp_ranks-pal.txt has been appended
# 
# % source ../../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# 
# % source xPeriment-P.lopP-100-tableau-ranks-pal.tcl
# .. invoking file.read from file.read.tableInR
# .. file P.lop.table_asymp_ranks-pal.txt has been created
# .. invoking file.read from file.read.tableInR
# .. file P.lop.table_asymp_ranks-pal.txt has been appended
# .. invoking file.read from file.read.tableInR
# .. file P.lop.table_asymp_ranks-pal.txt has been appended
# .. invoking file.read from file.read.tableInR
# .. file P.lop.table_asymp_ranks-pal.txt has been appended
# .. invoking file.read from file.read.tableInR
# .. The command table.html created the file
# P.lop.table_asymp_ranks-pal.html
# % 
# Copyright
# Franc Brglez, Sun Aug  2 10:12:14 EDT 2015
#~dd   
} ;# P.lop.table_asymp_ranks


