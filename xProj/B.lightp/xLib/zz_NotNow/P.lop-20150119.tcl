# Copyright:
# Franc Brglez, Fri Jan  4 06:52:09 EST 2013
#
#------- keep here as a 80-character reference line to check text width -------#

proc P.lop.info {{isQuery 1}} {
    
    set thisProc P.lop.info    
    global cmdLine: reqAry optAry optAryNames optAryNamesNA optAryNamesBool optAryList
    
    # assign required argument names
    set reqAry(instanceDef) {}
    
    # assign optional argument names, defaults, and descriptions
    set optAry(runtimeLmt,30)            "stop if runtime exceeds these many seconds."
    set optAry(cntProbeLmt,2147483647)   "stop if this value is reached."
    set optAry(cntRestartLmt,2147483647) "stop if this value is reached." 
    set optAry(walkLengthLmt,2147483647) "stop if this value is reached."  
    set optAry(valueTarget,1)            "stop if the adjusted valueTarget, 
                                 where valueTarget*(1+valueTol), is reached.
                                 Usually, valueTarget is the best known value."
    set optAry(valueTol,0.0)             "coefficient to adjust valueTarget defined above."
    set optAry(seedInit,NA)              "If NA, a random positive integer is generated."
    set optAry(coordInit,NA)             "if NA, a random permutation coordinate is generated.
                                 If 0,    a coordinate 1,2,3,...,nDim of length nDim is generated.
                                 If nDim*(nDim-1)/2, a coordinate nDim,...3,2,1 of length nDim is generated.
                                 If 0 < r < nDim*(nDim-1)/2, a random permutation coordinate of length nDim
                                 with rank 'r' is generated."
    set optAry(walkHashMax,1)            "total number of coordinate hash tables to activate."
    set optAry(walkSegmLmt,NA)           "inactive unless assigned an integer or if walkSegmCoef 
                                 is assigned a real value"
    set optAry(walkSegmCoef,NA)          "a coefficient that determines walkSegmLmt as wsCoef*nDim"
    set optAry(walkIntervalLmt,NA)       "inactive unless assigned an integer or if walkIntervalCoef   
                                 is assigned a real value" 
    set optAry(walkIntervalCoef,NA)      "a coefficient that determines walkIntervalLmt as wiCoef*nDim"
    set optAry(walkRepeatsLmt,NA)        "inactive unless assigned an integer. If an integer, the walk is
                                 monitored for repeats of valueBest. If walkRepeats > walkRepeatsLmt,  
                                 the self-avoiding walk branches from another coordinate with valueBest."
    set optAry(writeVar,0)               "an integer variable to control levels of output.
                                 If 0, do stdout at the minimum size required.
                                 If 1, include stdout of all variable values inialized under P.lop.init.
                                 If 2, include stdout of cntRestart trace.
                                 If 3, include stdout of distance=1 neighborhood probing and pivot selection.
                                 If 4, include stdout of valueBest-only during the walk.
                                 If 5, include stdout of up/down values during the walk.
                                 If 6, include stdout of up/down values during the walk 
                                       that includes all 'probed neighborhood values' at each step.
                                 "
    set optAry(isSimple,FALSE)          "if asserted, simpler-to-code but less efficient procedures
                                 are invoked"
    set optAry(notStdout,FALSE)          "if asserted, results are not reported to stdout" 
    set optAry(isP.lopT,FALSE)           "if asserted, results generated in bash by command P.lopT, T=tcl" 
    
    # extract names names of all optional variables:
    set optAryNames {} ; set optAryNamesNA {} ; set optAryNamesBool {}
    foreach item [array names optAry] {
        set itemList [split $item ,]
        set name [lindex $itemList 0] ; set valDefault  [lindex $itemList 1]
        lappend  optAryNames $name
        if {$valDefault == "NA"} {
            lappend optAryNamesNA $name
        }
        if {$valDefault == "FALSE"} {
            lappend optAryNamesBool $name
        }
    }
    # this is the preferred of variable names in optAryNames for user query
    set optAryList {
        runtimeLmt cntProbeLmt cntRestartLmt walkLengthLmt valueTarget valueTol  
        seedInit coordInit walkHashMax walkSegmLmt walkSegmCoef 
        walkIntervalLmt walkIntervalCoef walkRepeatsLmt writeVar isSimple notStdout
        isP.lopT
    }
    # check that NO names from optAryNames have been missed when creating optAryList
    set namesMissing {}
    foreach name $optAryNames {
        if {[lsearch -exact $optAryList $name ] < 0} {
            lappend namesMissing $name
        } 
    }
    if {$namesMissing != {}} {
        error "\nERROR from $thisProc:\
          \n.. these optional variable names from 'optAryNames' should be \
          incuded in the list 'optAryList':\n$namesMissing\n"
    }
    #puts "optAryNames\n$optAryNames\noptAryNamesNA\n$optAryNamesNA\
      \noptAryNamesBool\n$optAryNamesBool" ; return
    if {!$isQuery} {return}
    
    # else respond to a query from the user 
    set thisProg B.coverT
    puts "
USAGE: 
  ../xBin/$thisProg instanceFile \[optional_arguments\]
  
EXAMPLES:
  ../xBin/P.lopT ../../../xBenchm/lop/tiny/i-5-book2.lop -valueTarget -51 -runtimeLmt 5 -seedInit 1901
  ../xBin/P.lopT ../../../xBenchm/lop/tiny/i-5-book2.lop -valueTarget -51 -coordInit 1,2,3,4,5 -runtimeLmt 5 -seedInit 1901
  ../xBin/P.lopT ../../../xBenchm/lop/tiny/i-5-book2.lop -valueTarget -51 -coordInit 5,3,2,1,4 -seedInit 1901 
   
DESCRIPTION:  
$thisProg takes one required argument

    instanceFile  (with extension .lop or NO extension)
    
and a number of optional arguments in any order. The most significant parameter,
extracted from instanceFile is
    nDim ... the number of variables (columns in the square matrix)
Here is a complete list of  pairs 'name defaultValue', with short 
in-line descriptions:
"
    set optAryItems [array names optAry]
    foreach item $optAryList {
        
        set nameValue [lsearch -inline $optAryItems $item,*]
        set name      [lindex [split $nameValue ,] 0]
        set value     [lindex [split $nameValue ,] 1]
        set cnt       [expr {17 - [string length $name]}]
        set space1    [string repeat " " $cnt]
        set cnt       [expr {12 - [string length $value]}]
        set space2    [string repeat " " $cnt]
        puts "  --$name$space1$value$space2... $optAry($nameValue)"
    }
    puts "\nDETAILS:
See ....
....
....
"
} ;# P.lop.info

proc P.lop.init { instanceDef argsOptions } {

    set thisProc P.lop.init
#!! global variables MUST be listed HERE, before their values are defined!! 
    global cmdLine: reqAry optAry optAryNames optAryNamesNA optAryNamesBool optAryList
    global     tcl:    tcl_interactive tcl_libPath tcl_library tcl_patchLevel \
      tcl_pkgPath tcl_platform tcl_version
    global  arrays: aPI aV aWalkBest aWalk aWalkProbed aLits aStruc \
      aCoordHash0 aCoordHash1 aCoordHash2 aCoordHash3 aValueBest aAdjacent

    array unset aPI         ; array unset aV          ; array unset aValueBest         
    array unset aWalkBest   ; array unset aWalk       ; array unset aWalkProbed
    array unset aCoordHash0 ; array unset aCoordHash1 ; array unset aCoordHash2 
    array unset aCoordHash3 ; array unset aInstance   ; array unset aStruc 
    
    # the check on llength of argsOptions is when invoked under bash!!
    if {[llength $argsOptions] == 1} {set argsOptions [lindex $argsOptions 0]}
    puts "\# ** from: $thisProc:\n\# instanceDef=$instanceDef\
      \n\# argsOptions=$argsOptions"
   
#!! assign constant values under aPI
    set aPI(coordType)    P
    set aPI(functionBase) lop
    set aPI(commandName)  $aPI(coordType).aPI(functionBase).main 
    set numAllContstants 3
    
#!! assign the required arguments
    set aPI(instanceDef)  $instanceDef
 
#!! assign default values of all optional arguments
    foreach item [array names optAry] {
        set itemList [split $item ,]
        set name [lindex $itemList 0] ; set valDefault  [lindex $itemList 1]
        set aPI($name) $valDefault
    }
#!! overwrite the default values with values from the commandLine:
    #set listSize [llength $argsOptions]
    if {$argsOptions != {}} {
        set tmpList $argsOptions
        while {$tmpList != {}} {
            set name [string trimleft [lindex $tmpList 0] "-"]
            if {[lsearch -exact $optAryNames $name ] < 0} {
                error "\nERROR from $thisProc:\
                  \n.. option name $name not in this list\
                  \n.. [lsort $optAryNames]\n"
            }
            if {[lsearch -exact $optAryNamesBool $name] >= 0} {
                # we have name of a boolean variable
                set aPI($name) "TRUE"
                set tmpList [lreplace $tmpList 0 0]
            } else {
                # we have a name-value pair
                set aPI($name) [lindex $tmpList 1]
                set tmpList    [lreplace $tmpList 0 1]
            }
        }
    }
    set nCheck [expr {$numAllContstants + [array size reqAry] + [array size optAry]}]
    if {[array size aPI] != $nCheck} {
        error "\nERROR from $thisProc:\
          \nsize of reqAry+optAry ($nCheck) is not matched to\
          \nsize of aPI ([array size aPI])\n"
    }
    set aPI(commandLine) "$aPI(commandName)  $instanceDef $argsOptions"
    set aPI(commandLineOptionNames) $optAryList
    if {$aPI(writeVar) == 1} {
        puts "\n** TRACE FROM $thisProc **\
          \n** ALL commandLine variable names ** with either default or user-assigned values" 
        parray aPI 
    }

#!! extend aPI with variables decoded from aPI(instanceDef)
    # for this sandbox, read the instanceDef file 
    #!! #** timing starts *** 
    set microSecs [lindex [time {
    set aPI(instanceFile) $aPI(instanceDef)

    #-- read the instance
    #puts [file.read $aPI(instanceFile)]
    set aInstance    [P.lop.file.read $aPI(instanceFile)] ;# puts [join $aInstance \n]
    set aPI(nDim)     [lindex $aInstance 0]
    array set aStruc  [lindex $aInstance 1]
    set aPI(varList)  [lindex $aInstance 2]
    set aPI(density)  [lindex $aInstance 3]
    set aPI(coordRef) [join $aPI(varList) ,]
    #parray aStruc ; return
    } 1 ] 0 ] 
    #!! #** timing ends ***   
    set aV(runtimeRead) [expr {$microSecs/1e6}] 

#!! overwrite, if needed, values for variables where default aPI($name) == "NA"
    # ABOUT seedInit
    if {$aPI(seedInit) == "NA"} {
        # initialize the RNG  with a random seed
        set seedInit [expr {int(1e9*rand())}]
        set init [expr {srand($seedInit)}] 
        set aPI(seedInit) $seedInit
    } elseif {[string is integer $aPI(seedInit)]} {
        # initialize the RNG  with a user-selected seed
        set init [expr {srand($aPI(seedInit))}]
    } else { 
        error "ERROR from $thisProc:\
          \n.. only -seedInit NA or -seedInit <int> are valid assignments,\
          not -seedInit $aPI(seedInit)\n"
    } 
    # ABOUT coordInit
    if {$aPI(coordInit) == "NA"} {
        # generate a random permutation coordinate
        set aPI(coordInit) [P.coord.rand $aPI(nDim)]
        set aPI(rankInit)  [P.coord.distance $aPI(coordInit)  $aPI(coordRef)]
    } elseif {[string is integer $aPI(coordInit)] && $aPI(coordInit) == 0} {
        # generate a permutation coordinate with rank 0
        set aPI(coordInit)  $aPI(coordRef)
        set aPI(rankInit) [P.coord.distance $aPI(coordInit)  $aPI(coordRef)]
    } elseif {[string is integer $aPI(coordInit)] && $aPI(coordInit) == [expr {$aPI(nDim)*($aPI(nDim) - 1)/2}]} {
        # generate a permutation coordinate with rank nDim(nDim - 1)/2
        set aPI(coordInit)  [join [lsort -integer -decreasing [split  $aPI(coordRef) ,]] ,]
        set aPI(rankInit) [P.coord.distance $aPI(coordInit)  $aPI(coordRef)]
    } elseif {[string is integer $aPI(coordInit)] && $aPI(coordInit) <  [expr {$aPI(nDim)*($aPI(nDim) - 1)/2}]} {
        # generate a permutation coordinate with rank > 0 && rank < nDim(nDim - 1)/2
        error "\nERROR from $thisProc:\
          \nFeature to generate a random permutation with rank < nDim(nDim - 1)/2 not yet implemented\n"
        set aPI(rankInit) [P.coord.distance $aPI(coordInit)  $aPI(coordRef)]
    } else {
        # throw an error if the user-supplied coordInit is not a permutation of correct length
        set coordTmp [lsort -integer -unique [split $aPI(coordInit) ,]]
        if {[lindex $coordTmp end] != $aPI(nDim)} {
            error "\nERROR from $thisProc:\
              \nThe permutation coordinate is of length [string length $coordTmp],\
              \nnot the expected length $aPI(nDim)\n"
        }
        set aPI(rankInit) [P.coord.distance $aPI(coordInit)  $aPI(coordRef)]
    }
    #parray aPI ; return
    
    # ABOUT walkSegmLmt && walkSegmCoef
    if {      $aPI(walkSegmLmt) == "NA"  && $aPI(walkSegmCoef) == "NA"} {
        # this is a valid default, no further action required
        
    } elseif {$aPI(walkSegmLmt) == "NA"  && [string is double $aPI(walkSegmCoef)]} {
        # walkSegmCoef is defined by user-defined walkSegmCoef
        if {$aPI(walkSegmCoef) > 0.} {
            set aPI(walkSegmLmt) [expr {int($aPI(walkSegmCoef)*$aPI(nDim))}]  
        } else {
            error "\nERROR from $thisProc:\
              \nThe walkSegmCoef can only be assigned a value of NA \
              or a positive number > 0, not $aPI(walkSegmCoef) \n"
        }
        
    } elseif {[string is double $aPI(walkSegmLmt)]  && $aPI(walkSegmCoef) == "NA"} {
        # walkSegmLmt is defined by user-defined walkSegmLmt
        if {$aPI(walkSegmLmt) > 0} {
            set aPI(walkSegmLmt) [expr {int($aPI(walkSegmLmt))}]  
        } else {
            error "\nERROR from $thisProc:\
              \nThe walkSegmLmt can only be assigned a value of NA \
              or a positive number > 0, not $aPI(walkSegmLmt) \n"
        }
    } else {
        error "\nERROR from $thisProc:\
          \nThe walkSegmLmt AND walkSegmCoef and only be assigned pairwise values of\
          \n(NA NA) (default), (NA double), or (integer, NA)\n"
    }
    # ABOUT walkIntervalLmt && walkIntervalCoef
    if {      $aPI(walkIntervalLmt) == "NA"  && $aPI(walkIntervalCoef) == "NA"} {
        # this is a valid default, no further action required
        
    } elseif {$aPI(walkIntervalLmt) == "NA"  && [string is double $aPI(walkIntervalCoef)]} {
        # walkIntervalCoef is defined by user-defined walkIntervalCoef
        if {$aPI(walkIntervalCoef) > 0.} {
            set aPI(walkIntervalLmt) [expr {int($aPI(walkIntervalCoef)*$aPI(nDim))}]  
        } else {
            error "\nERROR from $thisProc:\
              \nThe walkIntervalCoef can only be assigned a value of NA \
              or a positive number > 0, not $aPI(walkIntervalCoef) \n"
        }
        
    } elseif {[string is double $aPI(walkIntervalLmt)]  && $aPI(walkIntervalCoef) == "NA"} {
        # walkIntervalLmt is defined by user-defined walkIntervalLmt
        if {$aPI(walkIntervalLmt) > 0} {
            set aPI(walkIntervalLmt) [expr {int($aPI(walkIntervalLmt))}]  
        } else {
            error "\nERROR from $thisProc:\
              \nThe walkIntervalLmt can only be assigned a value of NA \
              or a positive number > 0, not $aPI(walkIntervalLmt) \n"
        }
    } else {
        error "\nERROR from $thisProc:\
          \nThe walkIntervalLmt AND walkIntervalCoef and only be assigned pairwise values of\
          \n(NA NA) (default), (NA double), or (integer, NA)\
          \nand not ($aPI(walkIntervalLmt) $aPI(walkIntervalCoef))\n"
    }
    #puts \nafter..walkIntervalLmt... ; parray aPI ; return
    
      
#!! additional name-values for aPI and, if needed, redefined (e.g. valueTarget)
    set aPI(valueMin)      $aPI(valueTarget)
    set aPI(valueTarget)   [expr {$aPI(valueMin)*(1 + $aPI(valueTol))}]
    set aV(valueTarget)    $aPI(valueTarget) 
    set aPI(coordType)     P
    set aPI(functionBase)  lop 
    set aPI(dateLine)      [join [clock format [clock seconds] -gmt 0]]
    set aPI(timeStamp)     [join [clock format [clock seconds] -gmt 0\
      -format "%Y %m %d %H %M %S"] ""]
    append aPI(hostID) $tcl_platform(user)  @ \
      [lindex [split [info hostname] .] 0] - $tcl_platform(os) - \
      $tcl_platform(osVersion)   
    set aPI(walkMethod) wander

#!! find aPI(valueInit), i.e. do the first-time probe for function value 
    #!! #** timing starts *** 
    set microSecs [lindex [time {
        #set rList [$aPI(coordType).$aPI(functionBase).f $aPI(coordInit)]
        set rList [P.lop.f $aPI(coordInit)]
        #puts rList=$rList ; return
    } 1 ] 0 ] 
    #!! #** timing ends ***
    
#!! initialize variables in array 'aV' after the first probe for function value
    set aV(runtime)         [expr {$microSecs/1e6}]
    set aV(coordInit)       $aPI(coordInit)       
    set aV(valueInit)       [lindex $rList 0] 
    set aV(coordPivot)      $aV(coordInit)  ; set  aV(valuePivot) $aV(valueInit) 
        
#!! check if targetValue has been reached; return to *.main if targetReached > 0   
    if {$aV(valueInit) == $aV(valueTarget)} {
        set aV(targetReached) 1
    } elseif {$aV(valueInit) < $aV(valueTarget)} {
        set aV(targetReached) 2
    } else {
        set aV(targetReached) 0
    }
    if {$aV(targetReached) > 0} {
        puts "\# BINGO, targetReached=$aV(targetReached) for seed = $aPI(seedInit), \
          \n\#  coordInit = $aV(coordInit), valueInit = $aV(valueInit) "
        return "$aV(coordInit) $aV(valueInit) $aV(targetReached)"
    }
    
#!! proceed with initializations of array 'aV' before making the first step
    set aV(hashID)      0
    set aCoordHash0($aV(coordInit)) {} ; set aV(cntProbe)  1
    set aV(isCensored)  0  ; set aV(isBlocked)  0 
    set aV(walkLength)  0  ; set aV(cntRestart) 0      
    set aV(walkRepeats) 0  ; set aV(walkInterval) 0    
    set aValueBest($aV(valueInit)) 0,0,$aV(coordInit)
    set aV(neighbSize)  $aPI(nDim)
    
#!! initialize each of the walk arrays that may be selected on commandLine
    set aWalkBest($aV(valueInit)) 0,0,$aV(coordInit),0,0
    
    set aWalk($aV(walkLength)) "$aV(walkLength) $aV(cntRestart)\
          $aV(coordPivot) $aV(valuePivot) $aV(neighbSize) \
          $aV(cntProbe) $aV(targetReached)"
        
    set aWalkProbed($aV(walkLength),0) "$aV(walkLength) $aV(cntRestart)\
      $aV(coordPivot) $aV(valuePivot) $aV(neighbSize)\
      $aV(cntProbe) 1" 

#!! this code is no longer needed, may be useful elsewhere
#     # extract the argument list values (i.e. extract the commandLine)
#     set argsNames [info args $thisProc]  
#     foreach arg $argsNames {
#         set argVal [eval subst {[set $arg]}] ; lappend argsValues $argVal
#     }
#     set aPI(commandLineNames)  [list [lrange $argsNames  0 end-1]]
#     set aPI(commandLineValues) [list [lrange $argsValues 0 end-1]]
    if {$aPI(writeVar) == 1 } {
        puts "\n** Final values of initialized primary input variables (array aPI) **" ; parray aPI 
        puts "\n** Final values of initialized auxiliary variables (array aV) **" ; parray aV 
        puts "\n** as reported on $aPI(dateLine), returning\
          \ncoordInit\tvalueInit\ttargetReached"
    }
#!! return "values" line
    return "$aV(coordInit) $aV(valueInit) $aV(targetReached)" 
    
#~dd 
# Sun Nov 02 15:11:05 EST 2014
# (xWork) 69 % P.lop.main ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU -seedInit NA -coordInit NA 
# 10001 5 0
# (xWork) 70 % P.lop.main ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU -seedInit NA -coordInit NA
# 10010 2 0
# (xWork) 70 % P.lop.main ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU -seedInit 1901 -coordInit NA
# 00110 2 0
# (xWork) 71 % P.lop.main ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU -seedInit 1901 -coordInit NA
# 00110 2 0
# (xWork) 71 % P.lop.main ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU -seedInit 1901 -coordInit 0
# 00000 9 0
# (xWork) 72 % P.lop.main ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU -seedInit 1901 -coordInit 1
# 00100 4 0
# (xWork) 73 % P.lop.main ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU -seedInit 1901 -coordInit 3
# 01101 3 0
# (xWork) 74 % P.lop.main ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU -seedInit 1901 -coordInit 3
# 01101 3 0
# (xWork) 74 % P.lop.main ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU -seedInit NA -coordInit 3
# 10101 6 0
# (xWork) 75 % P.lop.main ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU -seedInit NA -coordInit 3
# 00111 3 0
# (xWork) 75 % 
# (xWork) 56 % P.lop.main ../../../xBenchm/coverUnate/steinerU/i-015-00035-steinerU.cnfU -coordInit 9 -valueTarget 9
# 001010011111101 44 0
# (xWork) 56 % P.lop.main ../../../xBenchm/coverUnate/steinerU/i-015-00035-steinerU.cnfU -coordInit 001101011011011 -valueTarget 9
# # BINGO, targetReached=1 for seed = 331833855,  
# #  coordInit = 001101011011011, valueInit = 9 
# 001101011011011 9 1
# (xWork) 57 % 
#
# (xWork) 50 % P.lop.main ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU -writeVar 1 -walkIntervalLmt 222 -walkIntervalCoef NA
# from P.lop.main
# instanceDef=../xBenchm/coverUnate/tiny/i-5-03-li.cnfU
# argvOptions=-writeVar 1 -walkIntervalLmt 222 -walkIntervalCoef NA
# 
# ** TRACE FROM P.lop.init ** 
# ** ALL commandLine variable names ** with either default or user-assigned values
# aPI(cntProbeLmt)      = 2147483647
# aPI(cntRepeatLmt)     = 2147483647
# aPI(cntRestartLmt)    = 2147483647
# aPI(commandLine)      = P.lop.main ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU -writeVar 1 -walkIntervalLmt 222 -walkIntervalCoef NA
# aPI(commandName)      = P.lop.main
# aPI(coordInit)        = NA
# aPI(instanceDef)      = ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU
# aPI(isSimple)        = 0
# aPI(notStdout)        = 0
# aPI(rankMove)         = 2
# aPI(runtimeLmt)       = 30
# aPI(seedInit)         = NA
# aPI(valueTarget)      = 1
# aPI(valueTol)         = 0.0
# aPI(walkHashMax)      = 1
# aPI(walkIntervalCoef) = NA
# aPI(walkIntervalLmt)  = 222
# aPI(walkLengthLmt)    = 2147483647
# aPI(walkMethod)       = sawU
# aPI(walkSegmCoef)     = NA
# aPI(walkSegmLmt)      = NA
# aPI(writeVar)         = 1
# 
# ** Final values of initialized primary input variables (array aPI) **
# aPI(cntProbeLmt)      = 2147483647
# aPI(cntRepeatLmt)     = 2147483647
# aPI(cntRestartLmt)    = 2147483647
# aPI(commandLine)      = P.lop.main ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU -writeVar 1 -walkIntervalLmt 222 -walkIntervalCoef NA
# aPI(commandName)      = P.lop.main
# aPI(coordInit)        = 00110
# aPI(coordType)        = B
# aPI(dateLine)        = Sun Nov 02 15:11:14 EST 2014
# aPI(functionBase)     = coverU
# aPI(functionExt)      = U
# aPI(hostID)           = brglez@triangle-Darwin-13.4.0
# aPI(instanceDef)      = ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU
# aPI(instanceFile)     = ../xBenchm/coverUnate/tiny/i-5-03-li.cnfU
# aPI(isSimple)        = 0
# aPI(nClauses)         = 3
# aPI(nDim)             = 5
# aPI(notStdout)        = 0
# aPI(rankMove)         = 2
# aPI(runtimeLmt)       = 30
# aPI(seedInit)         = 487367564
# aPI(timeStamp)        = 20141102151114
# aPI(valueInit)        = 2 0 1
# aPI(valueMin)         = 1
# aPI(valueTarget)      = 1.0
# aPI(valueTol)         = 0.0
# aPI(varList)          = 1 2 3 4 5
# aPI(walkHashMax)      = 1
# aPI(walkIntervalCoef) = NA
# aPI(walkIntervalLmt)  = 222
# aPI(walkLengthLmt)    = 2147483647
# aPI(walkMethod)       = sawU
# aPI(walkSegmCoef)     = NA
# aPI(walkSegmLmt)      = NA
# aPI(weightList)       = 1 1 1 1 1
# aPI(writeVar)         = 1
# 
# ** Final values of initialized auxiliary variables (array aV) **
# aV(cntNotCoverInit)  = 0
# aV(cntNotCoverPivot) = 0
# aV(cntProbe)         = 1
# aV(cntRestart)       = 0
# aV(coordInit)        = 00110
# aV(coordPivot)       = 00110
# aV(hashID)           = 0
# aV(isBlocked)        = 0
# aV(isCensored)       = 0
# aV(isFeasibleInit)   = 1
# aV(neighbSize)       = 5
# aV(rankMove)         = 2
# aV(runtime)          = 0.000357
# aV(runtimeRead)      = 0.000407
# aV(targetReached)    = 0
# aV(valueInit)        = 2
# aV(valuePivot)       = 2
# aV(valueTarget)      = 1.0
# aV(walkInterval)     = 0
# aV(walkLength)       = 0
# aV(walkRepeats)      = 0
# 
# ** as reported on Sun Nov 02 15:11:14 EST 2014, returning 
# coordInit valueInit   targetReached
# 00110 2 0
# (xWork) 51 % 
# % 
# Copyright:
# Franc Brglez, Sun Nov 02 15:11:05 EST 2014
#~dd   
} ;# P.lop.init

#------- keep here as a 80-character reference line to check text width -------#

proc P.lop.main { instanceDef args } {
    
    # P.lop.main ../../../xBenchm/lop/tiny/i-5-book2.lop -valueTarget -51 -coordInit 1,2,3,4,5
    # P.lop.main ../../../xBenchm/lop/tiny/i-5-book2.lop -valueTarget -51 -writeVar 3 -coordInit 5,3,2,1,4
    # P.lop.main ../../../xBenchm/lop/tiny/N-pal11.lop -valueTarget -1000 -writeVar 3 -seedInit 1901
    set thisProc P.lop.main 
    global arrays:  aPI aV
    set aPI(thisVersion) 20150115
    #puts "from $thisProc\ninstanceDef=$instanceDef\nargvOptions=$args"  
#!! get default values for all optional variables  
    P.lop.info [set isQuery 0]
     
#!! parse the command line and initialize all parameters for this solver
    set rList [P.lop.init $instanceDef $args] 
    #parray aPI ; puts \n***rList=$rList ; return
    set targetReached [lindex $rList 2]
    if {$targetReached > 0} {
        set aV(coordBest) $aV(coordInit) ; set aV(valueBest) $aV(valueInit) 
        P.lop.stdout [set withWarning 0]
        return
    }
    if {$aPI(isSimple)} {
        set pivotNext P.lop.saw.pivot.simple
    } else {
        set pivotNext P.lop.saw.pivot
    }
    set aPI(pivotNext) $pivotNext
    if {$aPI(writeVar) == 3} {
        set rList [$pivotNext $aV(coordInit) $aV(valueInit)]
        puts "FROM: $pivotNext (best next pivot)\nrList=$rList"
    }
    #return
    
#!! proceed with the combinatorial search
    set cntRestart 0 ; set coordInitList $aV(coordInit) ; set aV(cntRestartUniq) 0
    set aV(cntRestart) $cntRestart
    puts "\# FROM $thisProc: initialized for restart=$cntRestart\
      \n\# coordInit=$aV(coordInit), valueInit=$aV(valueInit)"

    while {$cntRestart < $aPI(cntRestartLmt)} {
        
        set rList [$aPI(coordType).$aPI(functionBase).saw]
        puts rList\n$rList
        if {$aV(targetReached) > 0} {
            break
        } else {
            incr cntRestart ; set aV(cntRestart) $cntRestart
            # proceed with a new SAW segment by making a jump to either a new 
            # random coordInit or, by random choice, repeating an existing pivot.
            # As long as this and subsequent pivots still have "free" neighbors, 
            # a new SAW segment can continue to the the next "best pivot".
            # NOTE: hashTable is NOT re-initialized with this restart!!
            set aV(coordInit) [$aPI(coordType).coord.rand $aPI(nDim)]
            # find new valueInit
            set rList [$aPI(coordType).$aPI(functionBase).f $aV(coordInit)]
            set aV(valueInit)       [lindex $rList 0] 
        }
        # keep track of coordInitList
        lappend coordInitList $aV(coordInit)
        #puts coordInitList=$coordInitList 
        # compare valueInit to valueTarget
        if {$aV(valueInit) == $aV(valueTarget)} {
            set aV(targetReached) 1
        } elseif {$aV(valueInit) < $aV(valueTarget)} {
            set aV(targetReached) 2
        } else {
            set aV(targetReached) 0
        }
        if {$aV(targetReached) > 0} {
            break
        } else {
            if {$aPI(writeVar) == 2} {
                puts "\# FROM $thisProc: initialized for restart=$cntRestart\
                  \n\# coordInit=$aV(coordInit), valueInit=$aV(valueInit)"
            }
        }
        if {$aV(runtime) > $aPI(runtimeLmt)}  {break}
    }
    set aV(cntRestartUniq) [llength [lsort -uniq $coordInitList]]
    
#!! return results in a standardized name-value format
    # (instanceDef is the first keyword name)
    P.lop.stdout [set withWarning 1]   
    return
} ;# P.lop.main



proc P.lop.exhA {
    {instanceFile  ../xBenchm/lop/tiny/i-5-book2.lop}
    {hasseBaseName NA}
    {ABOUT "...."} } {
        
    set thisProc P.lop.exhA
    global  arrays: aPI aV aWalkBest aWalk aWalkProbed aLits aStruc \
      aCoordHash0 aCoordHash1 aCoordHash2 aCoordHash3 aValueBest aAdjacent

    array unset aPI         ; array unset aV          ; array unset aValueBest         
    array unset aWalkBest   ; array unset aWalk       ; array unset aWalkProbed
    array unset aCoordHash0 ; array unset aCoordHash1 ; array unset aCoordHash2 
    array unset aCoordHash3 ; array unset aInstance   ; array unset aStruc   
    
    #-- read the instance
    puts [file.read $instanceFile]
    set aInstance    [P.lop.file.read $instanceFile] ;# puts [join $aInstance \n]
    set aPI(nDim)     [lindex $aInstance 0]
    array set aStruc  [lindex $aInstance 1]
    set aPI(varList)  [lindex $aInstance 2]
    set aPI(density)  [lindex $aInstance 3]
    #parray aStruc
    
    # read an exhaustive list of coordinates
    for {set i 1} {$i <= $aPI(nDim)} {incr i} {lappend coordRef $i}
    append permFile ../../../xBenchm/perm/ perm.0$aPI(nDim) .txt
    set coordList [file.read $permFile]
    puts ".. [llength $coordList] permutations read from file $permFile\n"
    #puts coordList\n$coordList ; return

    set valueMin +1e30 ; array unset hasseAry
    foreach item $coordList {
        
	set coord [split $item ,]
        set value [P.lop.f $coord]
        set rank  [P.coord.distance  $coord $coordRef]
        lappend hasseAry($rank) [join $coord ,]\:$value
        if {$value < $valueMin} {set valueMin $value}
    }
    array unset bestAry
    puts rank\t\size\tcoord_value_pairs
    foreach rank [lsort -integer [array names hasseAry]] {
        set listBest [lsearch -all -inline $hasseAry($rank) *:$valueMin]
        if {$listBest != {}} {set bestAry($rank) $listBest}
        puts $rank\t[llength $hasseAry($rank)]\t[join $hasseAry($rank) " "]
    }
    puts \nvalueBest=$valueMin
    foreach rank [lsort -integer [array names bestAry]] {
        if {[info exists bestAry($rank)]} {puts "bestAry($rank)\t= $bestAry($rank)"}
    }        
# Copyright: 
# Franc Brglez, Wed Jul 23 16:53:16 EDT 2014
#~dd     
    
} ;# P.lop.exhA
    
    

proc P.lop.file.read {
    {fileName ../xBenchm/tiny/i-5-book.txt}
    {ABOUT "This procedure returns an instance of 'lop'
    (a linear ordering problem)"} } {
     
    set thisProc P.lop.file.read 
    set rList [split [file.read $fileName] \n]
    
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
# % P.lop.file.read
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
# 5 {1,3 11 2,2 0 3,1 26 4,1 22 1,4 15 2,3 14 3,2 23 5,1 30 4,2 22 3,3 0 1,5 7 
# 2,4 15 5,2 28 4,3 11 3,4 26 2,5 9 5,3 25 4,4 0 3,5 12 5,4 24 4,5 13 5,5 0 
# 1,1 0 1,2 16 2,1 21}
# % 
# Copyright: 
# Franc Brglez, Wed Jul 23 16:53:16 EDT 2014
#~dd 
} ;# P.lop.file.read 

proc P.lop.file.write {
    {coordPerm 5,3,4,2,1}
    {fileName ../xBenchm/tiny/i-5-book.txt}
    {ABOUT "This procedure writes a permuted instance of 'lop'
    (a linear ordering problem)"} } {
     
    set thisProc P.lop.file.write 
    set rList [split [file.read $fileName] \n] ;# puts [join $rList \n]
    
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
    
    set coordPerm [split $coordPerm ,] 
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
            set jP [lindex $coordPerm [expr {$j-1}]]
            append row  " $pAry($i,$j)"
            set pAry($i,$j) $Ary($iP,$jP)
        }
        append rowLines $row\n
    }
    #puts rowLines\n$rowLines
    set filePerm [file rootname $fileName]-[join $coordPerm ,].lop
    file.write $filePerm $rowLines
    puts ".. created file [file tail  $filePerm]"
#~dd     
# % P.lop.file.write 5,3,4,2,1 ../xBenchm/lop/tiny/i-5-book.lop
# 5
#   0 16 11 15  7
#  21  0 14 15  9
#  26 23  0 26 12  
#  22 22 11  0 13
#  30 28 25 24  0
# 
# rowLines
# 5
#  0 25 24 28 30
#  12 0 26 23 26
#  13 11 0 22 22
#  9 14 15 0 21
#  7 11 15 16 0
# % 
# Copyright: 
# Franc Brglez, Wed Jul 23 16:53:16 EDT 2014
#~dd 
} ;# P.lop.file.write

proc P.lop.f {
    {coord "1 2 3 4 5"}
    {ABOUT "This procedure returns a function value for an instance of 'lop'
    (a linear ordering problem)"} } {
     
    set thisProc P.lop.f
    global  arrays: aPI aV aWalkBest aWalk aWalkProbed aLits aStruc \
      aCoordHash0 aCoordHash1 aCoordHash2 aCoordHash3 aValueBest aAdjacent
    
    # example file xBenchm/lop/tiny/i-5-book.txt from pages 2, 3 in 
    # Lib-OPUS-lop-2011-Springer-Reinelt-book.pdf
    # under nominal order 1,2,3,4,5: sumU = 138
    # under optimum order 5,3,4,2,1: sumU = 247
#     set nDim 5 ;# set coord 5,3,4,2,1 ;# an optimum ordering
#     array set aStruc {
#         1,3 11 2,2 0 3,1 26 4,1 22 1,4 15 2,3 14 3,2 23 5,1 30 4,2 22 3,3 0 1,5 7 
#         2,4 15 5,2 28 4,3 11 3,4 26 2,5 9 5,3 25 4,4 0 3,5 12 5,4 24 4,5 13 5,5 0 
#         1,1 0 1,2 16 2,1 21 
#     }
    
    set L $aPI(nDim) ; set Lm1 [expr {$L - 1}]
    set sumTot 0 ;# puts \n*coord=$coord*
    for {set i 0} {$i < $Lm1} {incr i} {
        set iP [lindex $coord $i]
        set ip1 [expr {$i+1}]
        set sumRow 0
        for {set j $ip1} {$j < $L} {incr j} {
            set jP [lindex $coord $j]
            #puts iP,jP=$iP,$jP,-$aStruc($iP,$jP)
            set sumRow [expr {($sumRow - $aStruc($iP,$jP))}]
        }
        #puts row=$iP,sumRow=$sumRow
        set sumTot [expr {$sumTot + $sumRow}]
    }
    #puts sumTot=$sumTot\n
    return  $sumTot
#~dd
# % P.lop.main ../../../xBenchm/lop/tiny/i-5-book2.lop -valueTarget -51 -writeVar 3 -coordInit 1,2,3,4,5
# # ** from: P.lop.init:
# # instanceDef=../../../xBenchm/lop/tiny/i-5-book2.lop 
# # argsOptions=-valueTarget -51 -writeVar 3 -coordInit 1,2,3,4,5
#
# FROM: P.lop.saw.pivot.simple
# Probing ALL distance=1 neighbors of the
# initial pivot coordinate = 1,2,3,4,5 
# pair  coord        f   fBest   rank  cntNeighb   cntProbe 
# --    1,2,3,4,5   -32   -32     0      0            1
# 1     2,1,3,4,5   -27   -27     1      1            2
# 2     1,3,2,4,5   -31   -31     1      2            3
# 3     1,2,4,3,5   -27   -31     1      3            4
# 4     1,2,3,5,4   -33   -33     1      4            5
# 
# FROM: P.lop.saw.pivot.simple (best next pivot)
# rList=1,2,3,5,4 -33 4  {} {}
# 
# % P.lop.f 1,2,3,5,4
# -33
# % P.lop.f 1,2,3,4,5
# -32
# % P.lop.f 2,1,3,4,5
# -27
# % P.lop.f 1,3,2,4,5
# -31
# % P.lop.f 1,2,4,3,5	
# -27
# % P.lop.f 1,2,3,5,4
# -33
# % 
# Copyright: 
# Franc Brglez, Wed Jul 23 16:53:16 EDT 2014
#~dd 
} ;# proc P.lop.f

proc P.lop.saw.pivot.simple  { {coordPiv 5,3,2,1,4} {valuePiv -46}
    {ABOUT "This procedure takes a pivot coordinate/value,  probes
    the distance=1 neighborhood of a 'lop' (a linear ordering problem),
    subject to the constraints of SAW (self-avoiding walk) -- i.e. 
    the best coord/value it returns has not been yet been selected
    as the pivot for the next step. Neighborhood size of 0 signifies that 
    the next step of SAW is blocked. 
       This implementation is 'simple', i.e. for each pivot coordinate 
    of length L, there are up to L-1 explicit probes of the function P.lop.f"} } {
        

    set thisProc P.lop.saw.pivot.simple
    global  arrays: aPI aV aWalkBest aWalk aWalkProbed aLits aStruc \
      aCoordHash0 aCoordHash1 aCoordHash2 aCoordHash3 aValueBest aAdjacent 
    
    set coordBest NA      ; set valueBest 2147483641 ; set valueProbedList {}
    set coordBestList  {} ; set neighbSize 0         ; set coordProbedList {}
        
    # create all distance=1 adjacencies of coordP
    set L $aPI(nDim) ; set Lm1 [expr {$L - 1}]
    set coordList [split $coordPiv ,] ; set swapList {}
    
    set valuePiv 0 ;  array unset coordAdj
    for {set i 0} {$i < $Lm1} {incr i} {
 
        set ip1 [expr {$i + 1}] ; set swapL $coordList  
        # swap elements at i & ip1
        set elm_ip1 [lindex $coordList $ip1]
        lset swapL $i $elm_ip1 ;# puts ---swapL-i,elm_ip1=$swapL
        if {$ip1 <= $Lm1} {           
            lset swapL $ip1 $elm_i ;# puts +++swapL-ip1,elm_i=$swapL\n
            set coordAdj($ip1) $swapL
            set elm_i [lindex $coordList $ip1]
        }
    }
    if {$aPI(writeVar) == 3} {
        set rank [P.coord.distance $coordPiv  $aPI(coordRef)]
        set rowLines "\nFROM: $thisProc\
          \nProbing ALL distance=1 neighbors of the\ninitial pivot\
          coordinate = $coordPiv\
           \npair\tcoord\tf\tfBest\trank\tcntNeighb\tcntProbe\
          \n--\t$coordPiv\t$valuePiv\t$valuePiv\t$rank\
          \t0\t$aV(cntProbe)\n"
    }
    #parray coordAdj ; return
    # find all admissible adjacent coordinates (distance=1 neighborhood)
    ##!! To maintain a self-avoiding walk, all coordinates in the walk
    ##!! should be excluded from the neighborhood of the current pivot.
    for {set i 0} {$i < $Lm1} {incr i} {
        set ip1 [expr {$i + 1}] 
        set coordA $coordAdj($ip1) 
        # check the hash table for presence of coordA
        if {![info exists aPivotCoord([join $coordA ,])]} {
            incr neighbSize 
            set valueA [P.lop.f [join $coordA ,]]
            incr aV(cntProbe)
            if {$aPI(writeVar) == 6} {
                lappend coordProbedList [join $coordA ,]
                lappend valueProbedList $valueA
            }
            #!! aggregate coordBestList for random selection later
            if {$valueA <= $valueBest} {
                if {$valueA < $valueBest} {set coordBestList {}}
                set valueBest $valueA ; set coordBest [join $coordA ,]
                set aAdjacent($valueA) [join $coordA ,]
                lappend coordBestList $coordBest
            }
            if {$aPI(writeVar) == 3} {
                set iP     [lindex $coordA $i]
                set iP1    [lindex $coordA $ip1]
                set pair "$iP,$iP1"
                set rank [P.coord.distance [join $coordA ,]  $aPI(coordRef)]
                append rowLines $pair\t[join $coordA ,]\t$valueA\t$valueBest\t$rank\
                  \t$neighbSize\t$aV(cntProbe)\n
            }
        }
    }
    if {$aPI(writeVar) == 3} {puts $rowLines}
    
    #!! randomize the choice of coordBest from coordBestList 
    set idx [expr {int([llength $coordBestList]*rand())}]
    set coordBest [lindex $coordBestList $idx]
    return "$coordBest $valueBest $neighbSize \
      [list $coordProbedList] [list $valueProbedList]"
    
#~dd  
# % P.lop.main ../../../xBenchm/lop/tiny/i-5-book2.lop -valueTarget -51 -writeVar 3 -coordInit 5,3,2,1,4
# # ** from: P.lop.init:
# # instanceDef=../../../xBenchm/lop/tiny/i-5-book2.lop 
# # argsOptions=-valueTarget -51 -writeVar 3 -coordInit 5,3,2,1,4
# 
# Probing ALL distance=1 neighbors of the
# initial pivot coordinate = 5,3,2,1,4 
# pair	coord	f	fBest	rank	cntNeighb	cntProbe 
# --	5,3,2,1,4	-46	-46	7 	0	1
# 1	3,5,2,1,4	-43	-43	6	1	2
# 2	5,2,3,1,4	-47	-47	6	2	3
# 3	5,3,1,2,4	-51	-51	6	3	4
# 4	5,3,2,4,1	-43	-51	8	4	5
# 
# FROM: P.lop.saw.pivot.simple
# rList=5,3,1,2,4 -51 4  {} {}
# % 
# 
# % P.lop.main ../../../xBenchm/lop/tiny/N-pal11.lop -valueTarget -1000 -writeVar 3 -seedInit 1913
# # ** from: P.lop.init:
# # instanceDef=../../../xBenchm/lop/tiny/N-pal11.lop 
# # argsOptions=-valueTarget -1000 -writeVar 3 -seedInit 1913
# 
# Probing ALL distance=1 neighbors of the
# initial pivot coordinate = 7,6,2,5,11,4,10,9,8,3,1 
# pair	coord	f	fBest	rank	cntNeighb	cntProbe 
# --	7,6,2,5,11,4,10,9,8,3,1	-28	-28	33 	0	1
# 1	6,7,2,5,11,4,10,9,8,3,1	-29	-29	32	1	2
# 2	7,2,6,5,11,4,10,9,8,3,1	-29	-29	32	2	3
# 3	7,6,5,2,11,4,10,9,8,3,1	-27	-29	34	3	4
# 4	7,6,2,11,5,4,10,9,8,3,1	-29	-29	34	4	5
# 5	7,6,2,5,4,11,10,9,8,3,1	-27	-29	32	5	6
# 6	7,6,2,5,11,10,4,9,8,3,1	-29	-29	34	6	7
# 7	7,6,2,5,11,4,9,10,8,3,1	-29	-29	32	7	8
# 8	7,6,2,5,11,4,10,8,9,3,1	-29	-29	32	8	9
# 9	7,6,2,5,11,4,10,9,3,8,1	-29	-29	32	9	10
# 10	7,6,2,5,11,4,10,9,8,1,3	-27	-29	32	10	11
# 
# FROM: P.lop.saw.pivot.simple
# rList=7,6,2,5,11,4,9,10,8,3,1 -29 10  {} {}
# % 
# Copyright: 
# Franc Brglez, Mon Dec 15 13:29:22 EST 2014
#~dd 
} ;# proc P.lop.saw.pivot.simple

#------- keep here as a 80-character reference line to check text width -------#

proc P.lop.saw.pivot  { {coordPiv 5,3,1,4,2}
    {ABOUT "This procedure takes a pivot coordinate/value,  probes
    the distance=1 neighborhood of a 'lop' (a linear ordering problem),
    subject to the constraints of SAW (self-avoiding walk) -- i.e. 
    the best coord/value it returns has not been yet been selected
    as the pivot for the next step. Neighborhood size of 0 signifies that 
    the next step of SAW is blocked. 
       This implementation is 'FAST', i.e. for each pivot coordinate of length L,  
    there are up to L-1 FAST tableau-based probes of each pivot coordinate"} } {
        

    set thisProc P.lop.saw.pivot
    global  arrays: aPI aV aWalkBest aWalk aWalkProbed aLits aStruc \
      aCoordHash0 aCoordHash1 aCoordHash2 aCoordHash3 aValueBest aAdjacent 
    
    set coordBest NA      ; set valueBest 2147483641 ; set valueProbedList {}
    set coordBestList  {} ; set neighbSize 0         ; set coordProbedList {}
    
### PASS 1: given coordinate 'coordPiv', get sumP(i), valuePiv, coordAdj
    set L $aPI(nDim) ; set Lm1 [expr {$L - 1}]
    set coordList [split $coordPiv ,]  
    set elm_i [lindex $coordList 0]
    set valuePiv 0 ;  array unset coordAdj
    for {set i 0} {$i <= $Lm1} {incr i} {

        # compute the pivot value (valPiv)
        set ip1 [expr {$i + 1}] 
        set iP [lindex $coordList $i] 
        set sumP($iP) 0 ;# CRITICAL array for PASS 2
        for {set j $ip1} {$j < $L} {incr j} {
            set jP [lindex $coordList $j]
            #puts iP,jP=$iP,$jP,-$aStruc($iP,$jP)
            set sumP($iP) [expr {($sumP($iP) - $aStruc($iP,$jP))}]
        }
        #puts iP,sumP=$iP,$sumP($iP)
        set valuePiv [expr {$valuePiv+ $sumP($iP)}]
        
        # initialize for a coordAdj (to be used in Phase 2)
        set swapL $coordList
        # swap elements at i & ip1 
        set elm_ip1 [lindex $coordList $ip1]
        lset swapL $i $elm_ip1 ;# puts ---swapL-i,elm_ip1=$swapL
        if {$ip1 <= $Lm1} {           
            lset swapL $ip1 $elm_i ;# puts +++swapL-ip1,elm_i=$swapL\n
            set coordAdj($ip1) $swapL
            set elm_i [lindex $coordList $ip1]
        }
    }
    incr aV(cntProbe)
    #parray sumP ; puts valuePiv=$valuePiv\n ; parray coordAdj
    if {$aPI(writeVar) == 3} {
        set rank [P.coord.distance $coordPiv  $aPI(coordRef)]
        set rowLines "\nFROM: $thisProc\
          \nProbing ALL distance=1 neighbors of the\ninitial pivot\
          coordinate = $coordPiv\
           \npair\tcoord\tf\tfBest\trank\tcntNeighb\tcntProbe\
          \n--\t$coordPiv\t$valuePiv\t$valuePiv\t$rank\
          \t0\t$aV(cntProbe)\n"
    }
### PASS 2: get valueA for each admissible adjacent coordinate 
    # find all admissible adjacent coordinates (distance=1 neighborhood)
    ##!! To maintain a self-avoiding walk, all coordinates in the walk
    ##!! should be excluded from the neighborhood of the current pivot.
    for {set i 0} {$i < $Lm1} {incr i} {
        set ip1 [expr {$i + 1}] 
        set coordA $coordAdj($ip1) 
        # check the hash table for presence of coordA
        if {![info exists aPivotCoord([join $coordA ,])]} {
            incr neighbSize 
            set iP     [lindex $coordA $i]
            set dif_ij [expr {-$sumP($iP)}]
            set iP1    [lindex $coordA $ip1]
            set dif_ji [expr {-$sumP($iP1)}]
            
            for {set j $ip1} {$j < $L} {incr j} {
                set ij     [lindex $coordAdj($ip1) $j]
                set dif_ij [expr {$dif_ij - $aStruc($iP,$ij)}]
                set ji     [lindex $coordAdj($ip1) $j]
                set dif_ji [expr {$dif_ji - $aStruc($iP1,$ji)}]
            }
            #puts \nip1=$ip1\ndif_ij=$dif_ij\ndif_ji=$dif_ji
            set valueA [expr {$valuePiv + $dif_ij + $dif_ji}]
            incr       aV(cntProbe)
            
            #!! aggregate coordBestList for random selection later
            if {$valueA <= $valueBest} {
                if {$valueA < $valueBest} {set coordBestList {}}
                set valueBest $valueA ; set coordBest $coordA
                lappend coordBestList [join $coordBest ,]
            }
            if {$aPI(writeVar) == 3} {
                set pair "$iP,$iP1"
                set rank [P.coord.distance [join $coordA ,]  $aPI(coordRef))]
                append rowLines $pair\t[join $coordA ,]\t$valueA\t$valueBest\t$rank\
                  \t$neighbSize\t$aV(cntProbe)\n
            }
        }
    }
    if {$aPI(writeVar) == 3} {puts $rowLines}
    
    #!! randomize the choice of coordBest from coordBestList 
    set idx [expr {int([llength $coordBestList]*rand())}]
    set coordBest [lindex $coordBestList $idx]
    return "$coordBest $valueBest $neighbSize \
      [list $coordProbedList] [list $valueProbedList]"
#~dd  
# % P.lop.main ../xBenchm/lop/tiny/i-5-book2.lop -valueTarget -51 -writeVar 3 -coordInit 1,2,3,4,5
# # ** from: P.lop.init:
# # instanceDef=../../../xBenchm/lop/tiny/i-5-book2.lop 
# # argsOptions=-valueTarget -51 -writeVar 3 -coordInit 1,2,3,4,5
# 
# FROM: P.lop.saw.pivot 
# Probing ALL distance=1 neighbors of the
# initial pivot coordinate = 1,2,3,4,5 
# pair	coord	f	fBest	rank	cntNeighb	cntProbe 
# --	1,2,3,4,5	-32	-32	0 	0	2
# 2,1	2,1,3,4,5	-27	-27	5	1	3
# 3,2	1,3,2,4,5	-31	-31	5	2	4
# 4,3	1,2,4,3,5	-27	-31	5	3	5
# 5,4	1,2,3,5,4	-33	-33	4	4	6
# 
# FROM: P.lop.saw.pivot (best next pivot)
# rList=1 2 3 5 4 -33 4  {} {}
# % 
# % P.lop.main ../xBenchm/lop/tiny/i-5-book2.lop -valueTarget -51 -writeVar 3 -coordInit 5,3,2,1,4
# # ** from: P.lop.init:
# # instanceDef=../../../xBenchm/lop/tiny/i-5-book2.lop 
# # argsOptions=-valueTarget -51 -writeVar 3 -coordInit 5,3,2,1,4
# 
# FROM: P.lop.saw.pivot.simple
# Probing ALL distance=1 neighbors of the
# initial pivot coordinate = 5,3,2,1,4 
# pair	coord	f	fBest	rank	cntNeighb	cntProbe 
# --	5,3,2,1,4	-46	-46	7 	0	2
# 3,5	3,5,2,1,4	-43	-43	7	1	3
# 2,3	5,2,3,1,4	-47	-47	6	2	4
# 1,2	5,3,1,2,4	-51	-51	6	3	5
# 4,1	5,3,2,4,1	-43	-51	8	4	6
# 
# FROM: P.lop.saw.pivot.simple (best next pivot)
# rList=5,3,1,2,4 -51 4  {} {}
# % 
# Copyright: 
# Franc Brglez, Mon Dec 15 13:29:22 EST 2014
#~dd 
} ;# proc P.lop.saw.pivot


proc P.lop.stdout { {withWarning 1}
    {ABOUT "This procedure outputs results after a successful completion of
    a combinatorial solver. The output is directed to 'stdout' and includes
    a olution (a coordinate-value pair) and the observed performance values. 
    The format consists of a few comment lines, followed by tabbed  
    name-value pairs. This procedure is universal under any  function of 
    coordType=B (binary)!"} } {

    set thisProc P.lop.stdout 
#!! global variables MUST be listed HERE, before their values are defined!! 
    global arrays:  aPI aV 
    
    puts "\# \n\# FROM $thisProc: A SUMMARY OF NAME-VALUE PAIRS\
      \n\# commandLine = $aPI(commandLine)\
      \n\#    dateLine = $aPI(dateLine) \
      \n\#   timeStamp = $aPI(timeStamp) \
      \n\#"
    
    set stdoutNames {instanceDef coordInit coordBest nDim walkMethod isSimple
        walkLengthLmt walkLength  cntRestartLmt cntRestart cntRestartUniq  
        cntProbeLmt cntProbe runtimeLmt runtime runtimeRead speed walkHashMax 
        walkSegmLmt walkSegmCoef walkIntervalLmt walkIntervalCoef walkRepeatsLmt
        seedInit  valueInit 
        valueBest  valueTarget targetReached isCensored
    } 
    array unset aPI(coordInit) ; array unset aPI(valueInit) 
    foreach name $stdoutNames {
        if {[info exists aV(${name})]} {
            puts "$name\t\t[eval subst {[set aV(${name})]}]"
        } else {
            if {[info exists aPI(${name})]} {
                puts "$name\t\t[eval subst {[set aPI(${name})]}]"
            } else { 
                if {$withWarning} {
                    puts "\# WARNING: no values exist for neither aV(${name}) \
                      nor aPI(${name})"
                }
            }
        }
    }
#~dd 
# %  
    
# Copyright:
# Franc Brglez, Mon Nov 03 14:16:15 EST 2014
#~dd
} ;# P.lop.stdout
