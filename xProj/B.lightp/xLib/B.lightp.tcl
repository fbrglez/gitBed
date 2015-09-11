# Copyright:
# Franc Brglez, Wed Jan 21 21:58:27 EST 2015
#------- keep here as a 80-character reference line to check text width -------#

proc B.lightp.main { instanceDef args } {   
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.lightp.main 
set ABOUT \
"
Proc $thisCmd takes a variable number of arguments: 'instanceDef' as the
required argument and a number of optional arguments (in any order).
To output the command line description of $thisCmd, invoke the command

 B.lightp.info 1

To read the instance and output the initialized data structures **only**, 
invoke the command

 B.lightp.main <instanceDef> -isInitOnly \[none-or-any-other-options\]
  
To read the instance and output results returned by the solver,
invoke the command

 B.lightp.main <instanceDef> \[none-or-any-options\]

To output the command line documentation of the encapsulated/executable 
version of $thisCmd

  ../xBin/B.lightpT
"
    if {$instanceDef == "??"} { puts $ABOUT ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
    
#!! (1) Phase 1: query about commandLine **OR** initialize all variables
    if {$instanceDef == "1"} {
        # read solver domain table and return query about commandLine
        B.lightp.info [set isQuery 1] $all_info(infoVariablesFile) 
        return
        
    } else {
        # proceed with variable initialization
    if {[llength $args] == 0} {set args ""}
    if {[llength $args] == 1} {set args [lindex $args 0]}
        set rList [B.lightp.init $instanceDef $args]
    }
    if {[llength $rList] == 0} { 
        # valueTarget > 0, valueTarget has been reached with coordInit
        # and stdout response has been generated within B.lightp.init
        return
    } elseif {$aV(isInitOnly)} {
        puts "# [string repeat - 75]\
          \n# .. completed initialization of all variables under P.lop.init,\
          \n#    exiting the solver since option -isInitOnly has been asserted.\
          \n# [string repeat - 75]"
        puts "targetReached coordInit valueInit = $rList\n"
        parray aV          ; puts \n ; parray aStruc      ; puts \n 
        parray aCoordHash0 ; puts \n ; parray aWalkProbed ; puts \n        
        return
    } elseif {[llength $rList] > 0} {
        puts "# [string repeat - 75]\
          \n# .. completed initialization of all variables under B.lightp.init."
    } 

#!! (2) Phase 2: proceed with the combinatorial search ---
# NOTE: onlyB.lightp.saw is stable currently    

    if {$aV(solverMethod) == "saw"} {
        set aV(solverID) B.lightpT ;# for python version, use  B.lightpP
        # invoke the selected solver
        puts "# .. proceeding with the search under solverID = $aV(solverID)\
          \n# [string repeat - 75]"
        B.lightp.saw 
    } else {
        error "\nERROR from $thisCmd:\
          \nsolverMethod = $aV(solverMethod) is not implemented\n"
    }
#!! return results in a standardized name-valueString format
    # (instanceDef is the first keyword name) 
    B.lightp.stdout      [set withWarning 1] 
    
    if {$aV(isWalkTables)} {
        walk.tables \
          $aV(solverID) [file tail [file rootname $aV(instanceDef)]]\
          $aV(seedInit) $aV(walkLength) [array get aWalkProbed]
    }
    return
#~dd 
# % B.lightp.main ?
# 
# USAGE: 
# under TkCon shell (which has sourced ../xLib/all_tcl):
#    B.lightp.main instanceDef [optional_arguments]
#    
# under bash, invoking the 'tcl executable B.lightpT' which sources libraries directly
#   ../xBin/B.lightpT instanceDef [optional_arguments]
#   
# under bash, invoking the 'python executable B.lightpP' which sources libraries directly
#   ../xBin/B.lightpP instanceDef [optional_arguments]
#   
#   under bash, invoking the 'compiled C++ code as as a binary B.lightpX' 
#   ../xBin/B.lightpX  instanceDef [optional_arguments]
#   
# EXAMPLES:
#   B.lightp.main     ../xBenchm/lightp/i-6-a-0.txt -isInitOnly
#   B.lightp.main     ../xBenchm/lightp/i-6-a-0.txt -seedInit 1215  
#   ../xBin/B.lightpT ../xBenchm/lightp/i-6-a-0.txt -seedInit 1215 -coordInit 010110
#   ../xBin/B.lightpP ../xBenchm/lightp/i-6-a-0.txt -seedInit 1215 -coordInit 010110  
#   ../xBin/B.lightpX ../xBenchm/lightp/i-6-a-0.txt -seedInit 1215 -runtimeLmt 5  
#    
# DESCRIPTION:  
# B.lightp.main, B.lightpT, B.lightpP, or B.lightpX take one REQUIRED argument
# 
#     instanceDef  (a filePath with an extension .txt)
#     
# and a number of OPTIONAL arguments in any order. 
# 
# Here is a complete list of 'name defaultValue' options, with short 
# in-line descriptions for each option:
# 
#   -runtimeLmt       30            Stop if the solver runtime exceeds these many seconds.
#   -cntProbeLmt      2147483647    Stop if the solver reaches this value.
#   -cntRestartLmt    2147483647    Stop if the solver reaches this value.
#   -walkLengthLmt    2147483647    Stop if the solver reaches this value.
#   -seedInit         NA            If NA, a random positive integer is created to initialize a
#                                   random number generator.
#   -coordInit        NA            If NA, a random binary coordinate is generated internally as a binary string
#                                   of size nDim Ñ unless the initial coordinate is entered by the user.
#   -valueTol         0.0           A coefficient to adjust valueTarget = valueTarget*(1 + valueTol) where
#                                   valueTarget is read from the standardized file B.lightp.info_solutions.txt.
#   -walkSegmLmt      NA            Inactive unless assigned an integer or if walkSegmCoef is assigned a real value.
#   -walkSegmCoef     NA            A coefficient that determines walkSegmLmt as walkSegmCoef*nDim.
#   -isSimple         FALSE         If asserted, simpler-to-code but less efficient procedures are invoked.
#   -isInitOnly       FALSE         If asserted, only the procedure *.init is invoked, solver exits afterwards.
#   -isWalkTables     FALSE         Walk tables are generated if both isWalkTables AND isSimple are asserted.
#   -writeVar         0             An integer variable to control levels of stdout:
#                                   If 0, do stdout with minimum lines of text.
#                                   If 1, do stdout of all variable values initialized under procedure *.init.
#                                   If 2, do stdout of cntRestart trace.
#                                   If 3, do stdout of distance=1 neighborhood probing and pivot selection.
# 
# DETAILS:
# This solver reads from a file an instance of the 'light-out puzzle problem' 
# defined by a binary string which can be of length 4=2*2, 6=2*3, 9=3*3,
# 12=3*4, 16=4*4, 20=4*5, 25=5*5, 30=5*6, 36=6*6, 42=6*7, etc. This string
# represents lights that are 'on' in a rectangular matrix of size L=M*N.
# The solver returns a binary solution string of length L that minimizes 
# the number of lights that could be turned off for the given instance. 
# For the instance shown below, there exist a single solution only!
#                  
# instanceDef      solutionBest
#  001001011         001101001
# lights-on= 4     lights-on= 0
# ------------     ------------                
#   0 0 1            0 0 0
#   0 0 1            0 0 0 
#   0 1 1            0 0 0
# 
# % 
#     
# % B.lightp.main i-16-a-0 -isSimple -seedInit 1901 -isWalkTables
# # ** from: B.lightp.init:
# # instanceDef=i-16-a-0 
# # argsOptions=-isSimple -seedInit 1901 -isWalkTables
# 
# # ------------------------------------------------------------------------------ 
# # .. completed initialization of all variables under B.lightp.init.
# #    Proceeding with the search under solverID = B.lightp.saw_simpleT 
# # ------------------------------------------------------------------------------
# 
# # FROM: B.lightp.saw, searching for pivotBest via B.lightp.saw_pivot_simple**
# # 
# # FROM B.lightp.stdout: A SUMMARY OF NAME-VALUE PAIRS 
# # commandLine = B.lightp.main  i-16-a-0 -isSimple -seedInit 1901 -isWalkTables 
# #    dateLine = Fri May 08 12:17:16 EDT 2015  
# #   timeStamp = 20150508161716  
# #
# instanceDef		i-16-a-0
# instanceInit		1100100000000000
# solverID		B.lightp.saw_simpleT
# coordInit		1100100011001101
# coordBest		1000000000000000
# nDim		16
# walkLengthLmt		2147483647
# walkLength		9
# cntRestartLmt		2147483647
# cntRestart		0
# cntProbeLmt		2147483647
# cntProbe		137
# runtimeLmt		30
# runtime		0.03947
# runtimeRead		0.000872
# speedProbe		3470
# hostID		brglez@sitta-Darwin-14.3.0
# isSimple		1
# solverMethod		saw
# walkSegmLmt		NA
# walkSegmCoef		NA
# seedInit		1901
# valueInit		9
# valueBest		0
# valueTarget		0.0
# valueTol		0.0
# targetReached		1
# isCensored		0
# .. file fg-B.lightp.saw_simpleT-i-16-a-0-walk-DownUp-1901-9-probed.txt has been created
# .. file fg-B.lightp.saw_simpleT-i-16-a-0-walk-DownUp-1901-9.txt has been created
# .. file fg-B.lightp.saw_simpleT-i-16-a-0-walk-DownOnly-1901-9.txt has been created
#
# % B.lightp.main i-16-a-0 -isSimple -seedInit 1902 -isWalkTables
# # ** from: B.lightp.init:
# # instanceDef=i-16-a-0 
# # argsOptions=-isSimple -seedInit 1902 -isWalkTables
# 
# # ------------------------------------------------------------------------------ 
# # .. completed initialization of all variables under B.lightp.init.
# #    Proceeding with the search under solverID = B.lightp.saw_simpleT 
# # ------------------------------------------------------------------------------
# 
# # FROM: B.lightp.saw, searching for pivotBest via B.lightp.saw_pivot_simple**
# # 
# # FROM B.lightp.stdout: A SUMMARY OF NAME-VALUE PAIRS 
# # commandLine = B.lightp.main  i-16-a-0 -isSimple -seedInit 1902 -isWalkTables 
# #    dateLine = Fri May 08 12:17:52 EDT 2015  
# #   timeStamp = 20150508161752  
# #
# instanceDef		i-16-a-0
# instanceInit		1100100000000000
# solverID		B.lightp.saw_simpleT
# coordInit		1111000100001011
# coordBest		1101110101000011
# nDim		16
# walkLengthLmt		2147483647
# walkLength		15
# cntRestartLmt		2147483647
# cntRestart		0
# cntProbeLmt		2147483647
# cntProbe		226
# runtimeLmt		30
# runtime		0.07499299999999999
# runtimeRead		0.000673
# speedProbe		3013
# hostID		brglez@sitta-Darwin-14.3.0
# isSimple		1
# solverMethod		saw
# walkSegmLmt		NA
# walkSegmCoef		NA
# seedInit		1902
# valueInit		7
# valueBest		0
# valueTarget		0.0
# valueTol		0.0
# targetReached		1
# isCensored		0
# .. file fg-B.lightp.saw_simpleT-i-16-a-0-walk-DownUp-1902-15-probed.txt has been created
# .. file fg-B.lightp.saw_simpleT-i-16-a-0-walk-DownUp-1902-15.txt has been created
# .. file fg-B.lightp.saw_simpleT-i-16-a-0-walk-DownOnly-1902-15.txt has been created
# % 
# Copyright:
# Franc Brglez, Tue Apr 21 16:19:47 EDT 2015
#~dd    
} ;# B.lightp.main

proc B.lightp.info {
    {isQuery 0}
    {infoVariablesFile ../xLib/B.lightp.info_variables.txt}} {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.lightp.info           
set ABOUT \
"
This proc takes a variable 'isQuery' and the hard-wired path to file
infoVariablesFile *info_variables.txt.  

  if isQuery == 0    then $thisCmd ONLY reads infoVariablesFile and 
                     initializes global arrays 'all_info' and 'all_valu'
              
  if isQuery == 1    then $thisCmd initializes the global arrays
                     'all_info' and 'all_valu' and then outputs to stdout  
                     the complete information about the command line for 
                     B.lightp.main. The information about the command line 
                     is auto-generated within $thisCmd from the
                     tabulated data which is read from infoVariablesFile 
                     defined above.
                   
   if isQuery == ??  then $thisCmd responds to stdout with information 
                     about all three case of valid arguments. 

            B.lightp.main ??   (under tclsh)
       or
            ../xBin/B.lightpT  (under bash)
"
    if {$isQuery == "??"} { puts $ABOUT ; return }
    if {$isQuery == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    
    # read the  *.info_variables.txt for this solver domain  
    set rList           [table.info_variables $infoVariablesFile]
    array set all_info  [lindex $rList 0]
    array set all_valu  [lindex $rList 1]
    
    if {!$isQuery} {return}

    # the preferred order (for user query) of optional commandLine argument names 
    set optInfoList {
        runtimeLmt cntProbeLmt cntRestartLmt walkLengthLmt seedInit coordInit   
        valueTol walkSegmLmt walkSegmCoef 
        isSimple isInitOnly isWalkTables writeVar
    }
    
### Now, respond to a query from the user 
    puts "
USAGE: 
under TkCon shell (which has sourced ../xLib/all_tcl):
   B.lightp.main instanceDef \[optional_arguments\]
   
under bash, invoking the 'tcl executable B.lightpT' which sources libraries directly
  ../xBin/B.lightpT instanceDef \[optional_arguments\]
  
under bash, invoking the 'python executable B.lightpP' which sources libraries directly
  ../xBin/B.lightpP instanceDef \[optional_arguments\]
  
  under bash, invoking the 'compiled C++ code as as a binary B.lightpX' 
  ../xBin/B.lightpX  instanceDef \[optional_arguments\]
  
EXAMPLES:
  B.lightp.main     i-9-a-0  -isInitOnly
  B.lightp.main     i-9-a-0  -seedInit 1215  
  ../xBin/B.lightpT i-9-a-0  -seedInit 1215  -coordInit 101100101 -isSimple
  ../xBin/B.lightpP i-9-a-0  -seedInit 1215  -coordInit 101100101  
  ../xBin/B.lightpT i-25-a-0 -seedInit 1215  -runtimeLmt 5 -isSimple 
  ../xBin/B.lightpT i-25-a-0 -seedInit 1215  -runtimeLmt 5  
  
DESCRIPTION:  
B.lightp.main, B.lightpT, B.lightpP, or B.lightpX take one REQUIRED argument

    instanceDef  (an instance name recognized under B.lightp/xBenchm)
    
and a number of OPTIONAL arguments in any order. 

Here is a complete list of 'name defaultValue' options, with short 
in-line descriptions for each option:
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
This solver reads from an instance name of the 'lights-out puzzle 
problem' associated with a binary string which can be of length 4=2*2, 
6=2*3, 9=3*3, 12=3*4, 16=4*4, 20=4*5, 25=5*5, 30=5*6, 36=6*6, 42=6*7, etc. 
This string represents lights that are 'on' in a rectangular matrix of 
size L=M*N. The solver returns a solution as a coordinate:value pair:
the coordinate is a binary string of length L, and the minimum
value is 0 for most instances; for some instances, the minimum
value is 1. 

For the instance shown below, there exist a single solution only!
                 
instanceInit     solutionBest
 001001011         001101001
lights-on= 4     lights-on= 0
------------     ------------                
  0 0 1            0 0 0
  0 0 1            0 0 0 
  0 1 1            0 0 0
"
    return
    
#~dd     
# % B.lightp.info ??
# Procedure B.lightp.info reads contents of *info_variables.txt and generates 
# a stdout reponse to user's query such as 
#         B.lightp.main ??   (under tclsh)
#     or
#         ../xBin/B.lightpT (under bash)
# 
#         
# % B.lightp.main ??
# Procedure B.lightp.main takes a variable number of arguments: 
# instanceDef as required argument and args (a reserved-name variable).
# It outputs either (1) a response to a command line query (see below) or a
# summary of initialized variable only, and (2) completes variable
# initialization and invokes the solver under the default or user-specified 
# argument values. 
# For a stdout of command line details, query with command shown below: 
#         B.lightp.main ?   (under tclsh, SINGLE '?')
#     or
#         ../xBin/B.lightpT (under bash)
# 
# 
# % B.lightp.main ?
# 
# USAGE: 
# under TkCon shell (which has sourced ../xLib/all_tcl):
#    B.lightp.main instanceDef [optional_arguments]
#    
# under bash, invoking the 'tcl executable B.lightpT' which sources libraries directly
#   ../xBin/B.lightpT instanceDef [optional_arguments]
#   
# under bash, invoking the 'python executable B.lightpP' which sources libraries directly
#   ../xBin/B.lightpP instanceDef [optional_arguments]
#   
#   under bash, invoking the 'compiled C++ code as as a binary B.lightpX' 
#   ../xBin/B.lightpX  instanceDef [optional_arguments]
#   
# EXAMPLES:
#   B.lightp.main     ../xBenchm/lightp/i-6-a-0.txt -isInitOnly
#   B.lightp.main     ../xBenchm/lightp/i-6-a-0.txt -seedInit 1215  
#   ../xBin/B.lightpT ../xBenchm/lightp/i-6-a-0.txt -seedInit 1215 -coordInit 010110
#   ../xBin/B.lightpP ../xBenchm/lightp/i-6-a-0.txt -seedInit 1215 -coordInit 010110  
#   ../xBin/B.lightpX ../xBenchm/lightp/i-6-a-0.txt -seedInit 1215 -runtimeLmt 5  
#    
# DESCRIPTION:  
# B.lightp.main, B.lightpT, B.lightpP, or B.lightpX take one REQUIRED argument
# 
#     instanceDef  (a filePath with an extension .txt)
#     
# and a number of OPTIONAL arguments in any order. 
# 
# Here is a complete list of 'name defaultValue' options, with short 
# in-line descriptions for each option:
# 
#   -runtimeLmt       30            Stop if the solver runtime exceeds these many seconds.
#   -cntProbeLmt      2147483647    Stop if the solver reaches this value.
#   -cntRestartLmt    2147483647    Stop if the solver reaches this value.
#   -walkLengthLmt    2147483647    Stop if the solver reaches this value.
#   -seedInit         NA            If NA, a random positive integer is created to initialize a
#                                   random number generator.
#   -coordInit        NA            If NA, a random binary coordinate is generated internally as a binary string
#                                   of size nDim Ñ unless the initial coordinate is entered by the user.
#   -valueTol         0.0           A coefficient to adjust valueTarget = valueTarget*(1 + valueTol) where
#                                   valueTarget is read from the standardized file B.lightp.info_solutions.txt.
#   -walkSegmLmt      NA            Inactive unless assigned an integer or if walkSegmCoef is assigned a real value.
#   -walkSegmCoef     NA            A coefficient that determines walkSegmLmt as walkSegmCoef*nDim.
#   -isSimple         FALSE         If asserted, simpler-to-code but less efficient procedures are invoked.
#   -isInitOnly       FALSE         If asserted, only the procedure *.init is invoked, solver exits afterwards.
#   -isWalkTables     FALSE         Walk tables are generated if both isWalkTables AND isSimple are asserted.
#   -writeVar         0             An integer variable to control levels of stdout:
#                                   If 0, do stdout with minimum lines of text.
#                                   If 1, do stdout of all variable values initialized under procedure *.init.
#                                   If 2, do stdout of cntRestart trace.
#                                   If 3, do stdout of distance=1 neighborhood probing and pivot selection.
# 
# DETAILS:
# This solver reads from a file an instance of the 'lights-out puzzle problem' 
# defined by a binary string which can be of length 4=2*2, 6=2*3, 9=3*3,
# 12=3*4, 16=4*4, 20=4*5, 25=5*5, 30=5*6, 36=6*6, 42=6*7, etc. This string
# represents lights that are 'on' in a rectangular matrix of size L=M*N.
# The solver returns a binary solution string of length L that minimizes 
# the number of lights that could be turned off for the given instance. 
# For the instance shown below, there exist a single solution only!
#                  
# instanceInit     solutionBest
#  001001011         001101001
# lights-on= 4     lights-on= 0
# ------------     ------------                
#   0 0 1            0 0 0
#   0 0 1            0 0 0 
#   0 1 1            0 0 0
# 
# % 
# Copyright:
# Franc Brglez, Thu May  7 14:01:59 EDT 2015
#~dd 
} ;# B.lightp.info

#------- keep here as a 80-character reference line to check text width -------#

proc B.lightp.init { instanceDef args } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.lightp.init ; set mainProc B.lightp.main
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
    set rList [ B.lightp.info [set isQuery 0] $all_info(infoVariablesFile) ]
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
    puts "\# FROM: $thisCmd:\n\# instanceDef=$instanceDef\
      \n\# argsOptions=$argsOptions"
    
#!! (0B) Phase 0B: extract variable groups from array all_valu (created by proc B.lightp.info)  
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
    #            including variables derived from instanceDef in the infoSolutionsFile
    #
    set aV(instanceDef) $instanceDef ;# here, instanceDef is the name of the instance
    #!! #** timing starts *** 
    set microSecs [lindex [time {
       
        # read infoSolutionsFile for this instance  
        append infoSolutionsFile $all_info(sandboxName) .info_solutions  .txt
        set infoSolutionsFile [file join $all_info(sandboxPath) xBenchm lightp \
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
            if {$varName == $aV(instanceDef)} {
                set aV(instanceInit) [lindex $line 1] 
                set aV(valueTarget)  [lindex $line 2] ; set aV(isProven) [lindex $line 3]
                
                set aV(nDim) [string length $aV(instanceInit)]
                set aV(instanceDim) $aV(nDim) 
                set aV(coordRef) [string repeat 0  $aV(nDim)]
                set aV(varList) {}
                for {set i 1} {$i <= $aV(nDim)} {incr i} {lappend aV(varList) $i}
                set isFound 1
            } 
            if {$isFound} {break}
        }
        if {!$isFound} {
            error "\nERROR from $thisCmd:\
              \n.. instance $aV(instanceDef) has not found in file\
              \n    $infoSolutionsFile\n"
        }
    } 1 ] 0 ] 
    #!! #** timing ends ***
    #parray aV ; return
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
        # generate a random binary coordinate
        set aV(coordInit) [B.coord.rand $aV(nDim)]
        set aV(rankInit)  [B.coord.rank $aV(coordInit)]
    } else {
        # throw an error if the user-supplied coordInit is not of correct length
        if {[string length $aV(coordInit)] != $aV(nDim)} {
            error "\nERROR from $thisCmd:\
              \nThe binary coordinate is of length [string length $aV(coordInit)],\
              \nnot the expected length $aV(nDim)\n"
        }
        set aV(rankInit) [B.coord.rank $aV(coordInit)]
    }
    #puts ".. after reading instanceDef and infoSolutionsFile" ; parray aV ; return
    
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
    }} ;# if {0}
    
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
    set aV(coordType)         B
    set aV(functionDomain)    B.lightp
    set aV(functionID)        lightp

    # define aV(solverID)
#     if {$aV(solverMethod) == "ant" && $aV(isSimple)} {
#         set aV(solverID) ant_saw_simple    ;# self-avoding "ant walk" under "-isSimple" option
#     } elseif {$aV(solverMethod) == "ant" } {
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
    # but first, initialize all matrix patterns
    set rList [B.lightp.patterns $aV(instanceInit)]
    set aV(M) [lindex $rList 0] ;# num-of-rows
    set aV(N) [lindex $rList 1] ;# num-of-columns
    array set aStruc [lindex $rList 2] ;# parray aStruc ; return
    #!! #** timing starts *** 
    set microSecs [lindex [time {
        set aV(valueInit) [B.lightp.f $aV(coordInit)]
    } 1 ] 0 ] 
    #!! #** timing ends ***
    # initialize associated variables after the first probe
    set aV(runtime)    [expr {$microSecs/1e6}]
    set aV(cntProbe)   1
    set aV(cntStep)    0 ; set aV(neighbSize) $aV(nDim) 
    set aV(coordPivot) $aV(coordInit)  ; set  aV(valuePivot) $aV(valueInit)
    set aV(coordBest)  $aV(coordInit)  ; set  aV(valueBest)  $aV(valueInit)
    set aCoordHash0($aV(coordInit)) {}
    
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
    #set aHashWalk($aV(coordInit)) {} 
    set aV(isCensored)  0  ; set aV(cntRestart) 0 
    #set aV(isTrapped)  0                            ;# LATER
    #set aV(walkRepeats) 0  ; set aV(walkInterval) 0 ;# LATER
    set aV(walkLength)  $aV(cntStep)
 
#!! (6) Phase 6: initialize special arrays that may be 
    #            selected with arguments from the commandLine
    if {$aV(isWalkTables)} {
        set aV(isSimple) TRUE
        set isPivot 1
        set aV(rankPivot) [B.coord.rank $aV(coordPivot)]
        set aWalkProbed([format "%05d" $aV(walkLength)],0) "$aV(walkLength) $aV(cntRestart)\
          $aV(coordPivot) $aV(valuePivot) $aV(rankPivot) $isPivot $aV(neighbSize) \
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
        B.lightp.stdout      [set withWarning 1] 
        return
    }
    
#!! (9) Phase 9: write to stdout under various values of writeVar
    if {$aV(writeVar) == 1 } {
        puts "\n** Final values of initialized variables (array aV) **" ; parray aV 
        puts "\n** Values associated with instance array aStruc **" ; parray aStruc 
        puts "\n** as reported on [join [clock format [clock seconds] -gmt 0]], returning\
          \ntargetReached\tvalueInit\tcoordInit"
    }
    
    return "$aV(targetReached) $aV(coordInit) $aV(valueInit)" 
    
#!! this code is no longer needed, may be useful elsewhere
#     # extract the argument list values (i.e. extract the commandLine)
#     set argsNames [info args $thisCmd]  
#     foreach arg $argsNames {
#         set argVal [eval subst {[set $arg]}] ; lappend argsValues $argVal
#     }
#     set aV(commandLineNames)  [list [lrange $argsNames  0 end-1]]
#     set aV(commandLineValues) [list [lrange $argsValues 0 end-1]]
    
#~dd  
# # # INITIAL version with WARNINGS
# # % B.lightp.init i-6-a-0
# # # ** from: B.lightp.init:
# # # instanceDef=i-6-a-0 
# # # argsOptions=
# # 
# #  WARNING from B.lightp.init
# # M -- this variable is missing from  the solver domain table in file /Users/brglez/Sites/~SYNC/gitPublic/xProj499-Sp15/B.lightp/xLib/B.lightp.info_variables.txt
# # N -- this variable is missing from  the solver domain table in file /Users/brglez/Sites/~SYNC/gitPublic/xProj499-Sp15/B.lightp/xLib/B.lightp.info_variables.txt
# # instanceInit -- this variable is missing from  the solver domain table in file /Users/brglez/Sites/~SYNC/gitPublic/xProj499-Sp15/B.lightp/xLib/B.lightp.info_variables.txt
# # 
# # Missing variables (in alphabetical order)
# # M
# # N
# # instanceInit
# # 0 3 1110100
# # % 

# ## FINAL VERSION
# % B.lightp.init i-6-a-0
# # ** from: B.lightp.init:
# # instanceDef=i-6-a-0 
# # argsOptions=
# 0 3 1101100
# % 

# % B.lightp.init i-6-a-0 -coordInit 100000
# # ** from: B.lightp.init:
# # instanceDef=i-6-a-0 
# # argsOptions=-coordInit 100000
# # BINGO: valueTarget has been reached or exceeded with coordInit
# # 
# # FROM B.lightp.stdout: A SUMMARY OF NAME-VALUE PAIRS 
# # commandLine = B.lightp.main  i-6-a-0 -coordInit 100000 
# #    dateLine = Fri May 08 11:20:22 EDT 2015  
# #   timeStamp = 20150508152022  
# #
# instanceDef		i-6-a-0
# instanceInit		110100
# solverID		B.lightp.sawT
# coordInit		100000
# coordBest		100000
# nDim		6
# walkLengthLmt		2147483647
# walkLength		0
# cntRestartLmt		2147483647
# cntRestart		0
# cntProbeLmt		2147483647
# cntProbe		1
# runtimeLmt		30
# runtime		0.000267
# runtimeRead		0.000817
# speedProbe		3745
# hostID		brglez@sitta-Darwin-14.3.0
# isSimple		FALSE
# solverMethod		saw
# walkSegmLmt		NA
# walkSegmCoef		NA
# seedInit		757463797
# valueInit		0
# valueBest		0
# valueTarget		0.0
# valueTol		0.0
# targetReached		1
# isCensored		0
# %
# Copyright:
# Franc Brglez, Fri May  8 11:22:07 EDT 2015
#~dd   
} ;# B.lightp.init

#------- keep here as a 80-character reference line to check text width -------#

proc B.lightp.saw {{ABOUT ""}} {
    #-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.lightp.saw
set ABOUT \
  "Procedure $thisCmd takes global array values initialized under B.lightp.init
 and constructs a segment of a self-avoiding walk (SAW). Either B.lightp.saw_pivot_simple 
 or the significantly more efficient procedure B.lightp.saw_pivot.ant is invoked.
 More to come ...."
    if {$ABOUT == "??"} { puts $ABOUT ; return }
    if {$ABOUT == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
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
        set procPivotNext  B.lightp.saw_pivot_simple
    } else {
        set procPivotNext  B.lightp.saw_pivot
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
        set aV(targetReached) 1
    } elseif {$aV(valueBest) < $aV(valueTarget)} {
        set aV(targetReached) 2
    } else {
        set aV(targetReached) 0
    }
    #parray aV
    return  $aV(targetReached)
#~dd
# % B.lightp.main i-16-a-0 -isSimple -seedInit 1901
# # ** from: B.lightp.init:
# # instanceDef=i-16-a-0 
# # argsOptions=-isSimple -seedInit 1901
# 
# # ------------------------------------------------------------------------------ 
# # .. completed initialization of all variables under B.lightp.init.
# #    Proceeding with the search under solverID = B.lightp.saw_simpleT 
# # ------------------------------------------------------------------------------
# 
# # FROM: B.lightp.saw, searching for pivotBest via B.lightp.saw_pivot_simple**
# # 
# # FROM B.lightp.stdout: A SUMMARY OF NAME-VALUE PAIRS 
# # commandLine = B.lightp.main  i-16-a-0 -isSimple -seedInit 1901 
# #    dateLine = Fri May 08 12:07:32 EDT 2015  
# #   timeStamp = 20150508160732  
# #
# instanceDef		i-16-a-0
# instanceInit		1100100000000000
# solverID		B.lightp.saw_simpleT
# coordInit		1100100011001101
# coordBest		1000000000000000
# nDim		16
# walkLengthLmt		2147483647
# walkLength		9
# cntRestartLmt		2147483647
# cntRestart		0
# cntProbeLmt		2147483647
# cntProbe		137
# runtimeLmt		30
# runtime		0.03829400000000001
# runtimeRead		0.000681
# speedProbe		3577
# hostID		brglez@sitta-Darwin-14.3.0
# isSimple		TRUE
# solverMethod		saw
# walkSegmLmt		NA
# walkSegmCoef		NA
# seedInit		1901
# valueInit		9
# valueBest		0
# valueTarget		0.0
# valueTol		0.0
# targetReached		1
# isCensored		0
# 
# % B.lightp.main i-16-a-0 -isSimple -seedInit 1902
# # ** from: B.lightp.init:
# # instanceDef=i-16-a-0 
# # argsOptions=-isSimple -seedInit 1902
# 
# # ------------------------------------------------------------------------------ 
# # .. completed initialization of all variables under B.lightp.init.
# #    Proceeding with the search under solverID = B.lightp.saw_simpleT 
# # ------------------------------------------------------------------------------
# 
# # FROM: B.lightp.saw, searching for pivotBest via B.lightp.saw_pivot_simple**
# # 
# # FROM B.lightp.stdout: A SUMMARY OF NAME-VALUE PAIRS 
# # commandLine = B.lightp.main  i-16-a-0 -isSimple -seedInit 1902 
# #    dateLine = Fri May 08 12:07:48 EDT 2015  
# #   timeStamp = 20150508160748  
# #
# instanceDef		i-16-a-0
# instanceInit		1100100000000000
# solverID		B.lightp.saw_simpleT
# coordInit		1111000100001011
# coordBest		1101110101000011
# nDim		16
# walkLengthLmt		2147483647
# walkLength		15
# cntRestartLmt		2147483647
# cntRestart		0
# cntProbeLmt		2147483647
# cntProbe		226
# runtimeLmt		30
# runtime		0.07475100000000001
# runtimeRead		0.000676
# speedProbe		3023
# hostID		brglez@sitta-Darwin-14.3.0
# isSimple		TRUE
# solverMethod		saw
# walkSegmLmt		NA
# walkSegmCoef		NA
# seedInit		1902
# valueInit		7
# valueBest		0
# valueTarget		0.0
# valueTol		0.0
# targetReached		1
# isCensored		0
# % 
# Copyright:
# Franc Brglez, Tue Apr 21 16:19:47 EDT 2015
#~dd 
} ;# proc B.lightp.saw


#------- keep here as a 80-character reference line to check text width -------#

proc B.lightp.stdout { {withWarning 1}
    {ABOUT "This procedure outputs results after a successful completion of
    a combinatorial solver. The output is directed to 'stdout' and includes
    a solution (a coordinate-value pair) and the observed performance values. 
    The format consists of a few comment lines, followed by tabbed  
    name-value pairs. The first pair is always 
                         instanceDef <value>
    This procedure is universal under any  function of coordType=P (permutation)!"} } {

    set thisCmd B.lightp.stdout 
#!! global variables MUST be listed HERE, before their values are defined!! 
    global     info: all_info all_valu aV
    
    puts "# FROM $thisCmd: A SUMMARY OF NAME-VALUE PAIRS\
      \n# commandLine = $aV(commandLine)\
      \n#    dateLine = [join [clock format [clock seconds] -gmt 0]] \
      \n#   timeStamp = $aV(timeStamp) \
      \n#"
    
    set stdoutNames {instanceDef instanceInit solverID solverMethod isSimple
        coordInit coordBest nDim  
        walkLengthLmt walkLength  cntRestartLmt cntRestart   
        cntProbeLmt cntProbe runtimeLmt runtime runtimeRead speedProbe hostID 
        compiler walkSegmLmt walkSegmCoef seedInit  valueInit 
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
} ;# B.lightp.stdout


proc B.lightp.saw_pivot_simple  { {coordPiv "111101"} {valuePiv 3} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.lightp.saw_pivot_simple
set ABOUT \
"This procedure takes a pivot coordinate/value,  probes
the distance=1 neighborhood of a 'light-out puzzle' (lightp),
subject to the constraints of a SAW (self-avoiding walk) -- i.e. 
the best coord/value it returns has not been yet been selected
as the pivot for the next step. Neighborhood size of 0 signifies that 
the next step of a SAW is blocked. 
  This implementation is 'simple', i.e. for each pivot coordinate 
of length L, there are up to L explicit probes of the function B.lightp.f."
    if {$coordPiv == "??"} { puts $ABOUT ; return }
    if {$coordPiv == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
        
    set coordBest  NA ; set valueBest 2147483641 ; set valueProbedList {}
    set neighbSize 0  ; set coordBestList  {}    ; set coordProbedList {}
    
    # We take coordPivot and flip the bit from left-to-right,
    # while also extracting neighbor with local valueBest.
    # NOTE: To maintain a self-avoiding walk, the neighborhood 
    # is defined only for coordinates not already used in the walk.  
        
    if {$aV(writeVar) == 3} {
        set distance 0 ; 
        set rank [B.coord.rank $coordPiv]
        set rowLines "FROM: $thisCmd\
          \nProbing ALL distance=1 neighbors of the\ninitial pivot\
          coordinate = $coordPiv\
          \ncntProbe\tIdx\tcoordPivot\tvalPivot\tcoordAdj\tvalAdj\tdist\trank\
          \n~\t~\t$coordPiv\t$valuePiv\t~\t~\t$distance\t$rank\n"
    } 
    foreach var $aV(varList) {  
        set i [expr {$var - 1}]
        set bit [string index $coordPiv $i]
        if {$bit} {
            set coordAdj [string replace $coordPiv $i $i 0]
        } else {
            set coordAdj [string replace $coordPiv $i $i 1]
        }
        ##!! To maintain a self-avoiding walk, coordinates from the walk
        ##!! should be excluded from the neighborhood of the current pivot.
        #parray aCoordHash0  
        if {![info exists aCoordHash0($coordAdj)]} {
            incr neighbSize
            set rList [B.lightp.f $coordAdj]
            set valueAdj [lindex $rList 0] 
            incr aV(cntProbe)
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
                  \t$coordAdj\t[join $rList ,]\t$distance\t$rank\n
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
# % source ../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# 
# % B.lightp.init i-6-a-0 -coordInit 100001 -writeVar 3
# # ** from: B.lightp.init:
# # instanceDef=i-6-a-0 
# # argsOptions=-coordInit 100001 -writeVar 3
# 0 100001 3
# 
# % B.lightp.saw_pivot_simple 100001 3
# A trace from B.lightp.saw_pivot_simple: 
# Evaluating neighbors of coordPivot=100001 
# cntProbe	Idx	coordPivot	valPivot	coordAdj	valAdj	dist	rank 
# ~	~	100001	3	~	~	0	2
# 2	0	000001	6	000001	6	1	1
# 3	1	110001	3	110001	3	1	3
# 4	2	101001	2	101001	2	1	3
# 5	3	101001	2	100101	4	1	3
# 6	4	101001	2	100011	3	1	3
# 7	5	100000	0	100000	0	1	1
# 100000 0 6 {} {}
# 
# % B.lightp.init i-6-a-0 -coordInit 000001 -writeVar 3
# # ** from: B.lightp.init:
# # instanceDef=i-6-a-0 
# # argsOptions=-coordInit 000001 -writeVar 3
# 0 000001 6
# 
# % B.lightp.saw_pivot_simple 000001 6
# 
# A trace from B.lightp.saw_pivot_simple: 
# Evaluating neighbors of coordPivot=000001 
# cntProbe	Idx	coordPivot	valPivot	coordAdj	valAdj	dist	rank 
# ~	~	000001	6	~	~	0	1
# 2	0	100001	3	100001	3	1	2
# 3	1	010001	2	010001	2	1	2
# 4	2	010001	2	001001	3	1	2
# 5	3	010001	2	000101	3	1	2
# 6	4	000011	2	000011	2	1	2
# 7	5	000011	2	000000	3	1	0
# 010001 2 6 {} {}
# % 
# Copyright:
# Franc Brglez, Fri May  8 11:50:56 EDT 2015
#~dd
} ;# proc B.lightp.saw_pivot_simple

#------- keep here as a 80-character reference line to check text width -------#


proc B.lightp.saw_pivot { {coordPiv "101010"} {valuePiv NA} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.lightp.saw_pivot 
set ABOUT \
"This procedure takes a pivot coordinate and first invokes the procedure
B.lightp.fAdj -- an efficient and effective tableau-based procedure that 
returns  ALL pairs of the adjacent coordinates with their values. Next, 
the procedure selects the best pivot coordinate for the next step, subject 
to the constraints of a SAW (self-avoiding walk) which effectively reduces 
the size of the adjacent coordinates that are free as candiates. 
A neighborhood size of 0 signifies that the procedure is returning a 
'trapped pivot'.
"
    if {$coordPiv == "??"} { puts $ABOUT ; return }
    if {$coordPiv == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    global instance: aStruc
    global   solver: aCoordHash0 aWalkProbed
    
    set M    $aV(M) ; set N    $aV(N) ; set L    $aV(nDim)

    # get the pivot value and the entire pivot neighborhood
    set rList [B.lightp.fAdj $coordPiv]
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
    return [list $coordBest $valueBest $neighbSize]
    
#~dd
# %B.exhA 2,2 1215
# hasseAry(0) = 0000:1
# hasseAry(1) = 0001:4 0010:2 0100:2 1000:2
# hasseAry(2) = 0011:1 0101:1 0110:3 1001:1 1010:3 1100:3
# hasseAry(3) = 0111:2 1011:2 1101:2 1110:0
# hasseAry(4) = 1111:3
# valueBest = 0
# solutionBest(rank=3) = 1110:0
#  seedInit = 1215 induces 
# coordInit = 1000
# 
# %B.saw_pivot_simple 1100 3
# A trace fromB.saw_pivot_simple: 
# Evaluating neighbors of coordPiv=111101 
# cntProbe  Idx  coordPiv  valPiv  coordAdj  valAdj  dist  rank 
# --	    --	   1100      3        --       --     0     2  
# 1	        0	   0100      2       0100      2      1     1  
# 2	        1	   1000      2       1000      2      1     1   
# 3	        2	   1110      0       1110      0      1     3   
# 4	        3	   1110      0       1101      2      1     3  
# 
# 
# 
# %B.exhA 2,2 1789
# hasseAry(0) = 0000:2
# hasseAry(1) = 0001:1 0010:3 0100:3 1000:1
# hasseAry(2) = 0011:2 0101:2 0110:0 1001:4 1010:2 1100:2
# hasseAry(3) = 0111:3 1011:1 1101:1 1110:3
# hasseAry(4) = 1111:2
# valueBest = 0
# solutionBest(rank=2) = 0110:0
#  seedInit = 1789 induces 
# coordInit = 0110
# 
# %B.saw_pivot_simple 0111 3
# A trace fromB.saw_pivot_simple: 
# Evaluating neighbors of coordPiv=111101 
# cntProbe  Idx  coordPiv  valPiv  coordAdj  valAdj  dist  rank 
# --	    --	   0111      3        --       --     0     3  
# 1	        0	   1111      2       1111      2      1     4  
# 2	        1	   0011      2       0011      2      1     2   
# 3	        2	   0101      0       0101      2      1     2   
# 4	        3	   0101      0       0101      0      1     2  
#  
# 
# 
# %B.exhA 2,3 1215
# hasseAry(0) = 000000:1
# hasseAry(1) = 000001:4 000010:5 000100:2 001000:4 010000:3 100000:2
# hasseAry(2) = 000011:4 000101:3 000110:2 001001:3 001010:4 001100:5 010001:2 010010:3 
#               010100:4 011000:2 100001:5 100010:2 100100:3 101000:3 110000:4
# hasseAry(3) = 000111:3 001011:3 001101:2 001110:1 010011:2 010101:5 010110:4 011001:1 
#               011010:2 011100:3 100011:1 100101:4 100110:3 101001:2 101010:3 101100:4 
#               110001:3 110010:4 110100:1 111000:5
# hasseAry(4) = 001111:2 010111:1 011011:5 011101:4 011110:3 100111:4 101011:2 101101:1 
#               101110:4 110011:3 110101:2 110110:5 111001:4 111010:1 111100:2
# hasseAry(5) = 011111:4 101111:5 110111:2 111011:4 111101:3 111110:2
# hasseAry(6) = 111111:3
# valueBest = 1
# solutionBest(rank=0) = 000000:1
# solutionBest(rank=3) = 001110:1 011001:1 100011:1 110100:1
# solutionBest(rank=4) = 010111:1 101101:1 111010:1
#  seedInit = 1215 induces 
# coordInit = 100000
# 
# %B.saw_pivot_simple 101111 5 
# A trace fromB.saw_pivot_simple: 
# Evaluating neighbors of coordPiv=111101 
# cntProbe  Idx  coordPiv  valPiv  coordAdj  valAdj  dist  rank 
# --	   --	 101111      5        --       --     0     5   
# 1 	   0	 001111      2     001111      2      1     4   
# 2	       1	 001111      2     111111      3      1     6   
# 3	       2	 001111      2     100111      4      1     4   
# 4	       3	 101011      2     101011      2      1     4   
# 5	       4	 101111      1     101111      1      1     4   
# 6	       5	 101111      1     101110      4      1     4  
# 
# 
# %B.exhA 2,3 7314
# hasseAry(0) = 000000:3
# hasseAry(1) = 000001:2 000010:3 000100:2 001000:4 010000:3 100000:4
# hasseAry(2) = 000011:2 000101:3 000110:6 001001:3 001010:0 001100:3 010001:6 010010:3 
#               010100:2 011000:4 100001:3 100010:4 100100:3 101000:3 110000:0
# hasseAry(3) = 000111:3 001011:3 001101:4 001110:3 010011:2 010101:3 010110:2 011001:3 
#               011010:4 011100:3 100011:3 100101:4 100110:3 101001:2 101010:3 101100:2 
#               110001:3 110010:4 110100:3 111000:3
# hasseAry(4) = 001111:4 010111:3 011011:3 011101:0 011110:3 100111:0 101011:6 101101:3 
#               101110:2 110011:3 110101:4 110110:3 111001:2 111010:3 111100:6
# hasseAry(5) = 011111:4 101111:3 110111:4 111011:2 111101:3 111110:2
# hasseAry(6) = 111111:3
# valueBest = 0
# solutionBest(rank=2) = 001010:0 110000:0
# solutionBest(rank=4) = 011101:0 100111:0
#  seedInit = 7314 induces 
# coordInit = 001100
# 
# %B.saw_pivot_simple 111101 3
# A trace fromB.saw_pivot_simple: 
# Evaluating neighbors of coordPiv=111101 
# cntProbe  Idx  coordPiv  valPiv  coordAdj  valAdj  dist  rank 
# --	   --	    011111      4        --       --     0     5       
# 1	       0	    111111      3     111111      3      1     6   
# 2	       1	    111111      3     001111      4      1     4   
# 3	       2	    010111      3     010111      3      1     4   
# 4	       3	    011011      3     011011      3      1     4   
# 5	       4	    011101      0     011101      0      1     4   
# 6	       5	    011101      0     011110      3      1     4   
# % 
# Copyright:
# Franc Brglez, Mon Oct 20 12:56:09 EDT 2014
#~dd
} ;# B.lightp.saw_pivot

#------- keep here as a 80-character reference line to check text width -------#

#------- keep here as a 80-character reference line to check text width -------#
    
proc B.lightp.patterns { {instanceInit 110100} {isDebug 0} } {
        
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.lightp.patterns ; set sandbox B.lightp
set ABOUT \
"
USAGE:    $thisCmd instanceInit isDebug=0

EXAMPLE:  $thisCmd  110100  
          $thisCmd  110100  1
                
The command $thisCmd takes a binary coordinate 'instanceInit' of length L  
which defines the initial configuration of the 'lights-out puzzle' under 
the sandbox $sandbox.  The command initializes and returns the associate
array mP(i,j,k) that not only represents the initial state of the puzzle
but also the well-defined patterns of L binary matrices that represent 
non-trivial constraints defined for this puzzle. 
For details, see the interactive 'Lights Out Puzzle Solver' under
http://www.ueda.info.waseda.ac.jp/~n-kato/lightsout/

For a stdout query, use one of these these commands:
            $thisCmd  ??  (under a tcl shell or a python shell) 
"
    if {$instanceInit == "??"} { puts $ABOUT ; return }
    if {$instanceInit == "?"}  { error "Valid query is '$thisCmd ??'" ;return }
#-- end   ABOUT ---------------------------------------------------------------# 
    
    # compute the number of rows (M) and columns (N) in each of L matrices
    set L [string length $instanceInit]
    set M [expr {int( floor( sqrt($L)  ))}]
    set N [expr {int(  ceil( sqrt($L)  ))}]

################################################################################
# NOTE:  in order to standardize the asymptotic performance experiments
#         of this solver a decision has been made to to hardwire the value
#         of instanceInit to a string of all 1's:
    
    set instanceInit [string repeat 1 $L]
    
# This value of instanceInit represents a puzzle with **all** lights on,
# which is just one of posssible initial states puzzle can assume before
# an attempt is made to solve it. However, while not all puzzles are solvable
# from any initial state, any puzzle with the initial state of *all** lights on 
# is **always** solvable (a proof exists in the literature).
################################################################################
    
    # In our schema below, the L matrices are indexed by k=(0, 1, 2, ..., L-1)
    # and arranged in M*N grid
    #
    #        k=0[---]          k=1[---]          k=2[---] .....       k=N-1[---]
    #  ...  
    #  ...
    #  k=M*(N-1)[---]  k=M*(N-1)+1[---]  k=M*(N-1)+2[---] ..... k=(M*N - 1)[---]
    #
    if {$L != [expr {$M * $N}]} {
        error "\nERROR from $thisCmd:\
          \n.. value of L=$L does not factor correctly into  M*N=[expr {$M * $N}]\
          \n.. values of L that would factor correctly are indicated below\
          \n   4 6 9 12 16 20 25 30 36 42 49 56 64 72 ....\n"
    } 
    # use instanceInit to initialize mP($i,$j,-1): 
    # i.e. the 0-1 matrix selected by random choice or by the user. 
    for {set i 1} {$i <= $M} {incr i} {
        for {set j 1} {$j <= $N} {incr j} {
            set k [expr {($i - 1)*$N + ($j - 1)}] ;# puts $i,$j,$k
            set mP($i,$j,-1) [string index $instanceInit $k]
        }
    }
    #puts instanceInit=$instanceInit ; parray mP ; return
    ######## SPECIAL CASE for B.lightp.exhA and B.lightp.f ##############
    if {[B.coord.rank $instanceInit] == 0} {
        # we have a special case that should induce a constant value of 0
        # when B.lightp.f is invoked! ** NO NEED FOR THIS In PYTHON **
        set fValue 0
        return [list $M $N [array get mP] $fValue]
    }
    #parray mP ; return
    
    # initialize to value of 0 each of L matrices
    for {set k 0} {$k < $L} {incr k} {
        for {set i 1} {$i <= $M} {incr i} {
            for {set j 1} {$j <= $N} {incr j} {
                set mP($i,$j,$k) 0
            }
        }
    }
    set kkMax [expr {$L*$L}] 
    # initialize the counter variables
    set k -1 ; set mRow 0   

    # assign values of 1 at locations specified for each of L matrices 
    for {set kk 0} {$kk < $kkMax} {incr kk} {
        
        if {!($kk % $L)} {
            incr k
            set i 0 ;# initialize the row counter for each of L matrices
        }
        # increment the row counter for each of L matrices
        if {!($kk % $N)} {incr i} 
        #puts row=$i,col=$j,k=$k,[expr {$k%$N}]
        
        # increment the column counter for each of L matrices
        set j [expr {1 + ($kk % $N)}] 
 
        # periodically, increment the row counter for each group of N matrices
        if {!($kk % ($L*$N))} {incr mRow} 
        
        if {$mRow == 1} {
            #puts mRow=$mRow...row=$i,col=$j,k=$k
            # case for the left-most matrix of the top row 
            if {"$i,$j,$k" == "1,1,0"} {
                set mP(1,1,$k) 1 ; set mP(1,2,$k) 1 ; set mP(2,1,$k) 1
            }
            # case for the right-most matrix of the top row 
            if {"$i,$j,$k" == "1,$N,[expr {$N-1}]"} {
                set mP(1,$N,$k) 1 ; set mP(1,[expr {$N-1}],$k) 1 ; set mP(2,$N,$k) 1
            } 
            # case for matrices in the middle of the top row 
            for {set col 2} {$col <= [expr {$N-1}]} {incr col} {
                if {"$i,$j,$k" == "1,$col,[expr {$col - 1}]"} {
                    set mP($i,$j,$k) 1 ; set mP($i,[expr {$j-1}],$k) 1 ; set mP($i,[expr {$j+1}],$k) 1 
                    set mP([expr {$i+1}],$j,$k) 1
                }
            }
        } 
        if {$mRow == $M} {
            #puts mRow=$mRow...row=$i,col=$j,k=$k
            # case for the left-most matrix of the bottom row 
            if {"$i,$j,$k" == "$M,1,[expr {$L-$N}]"} {
                set mP($M,1,$k) 1 ; set mP($M,2,$k) 1 ; set mP([expr {$M-1}],1,$k) 1
            }
            # case for the right-most matrix of the bottom row 
            if {"$i,$j,$k" == "$M,$N,[expr {$L-1}]"} {
                set mP($M,$N,$k) 1 ; set mP($M,[expr {$N-1}],$k) 1 ; set mP([expr {$M-1}],$N,$k) 1
            }
            # case for matrices in the middle of the bottom row 
            for {set col 2} {$col <= [expr {$N-1}]} {incr col} {
                if {"$i,$j,$k" == "$M,$col,[expr {$L-$N + $col - 1}]"} {
                    set mP($i,$j,$k) 1 ; set mP($i,[expr {$j-1}],$k) 1 ; set mP($i,[expr {$j+1}],$k) 1 
                    set mP([expr {$i-1}],$j,$k) 1
                }
            }
        } 
        if {$mRow != 1 && $mRow != $M} {
            # case for group of middle matrices in the left-most column
            for {set row 2} {$row <= [expr {$M-1}]} {incr row} {
                if {"$i,$j,$k" == "$row,1,[expr {$N*($row - 1)}]"} {
                    set mP($i,$j,$k) 1 ; set mP([expr {$i+1}],$j,$k) 1 ; set mP([expr {$i-1}],$j,$k) 1 
                    set mP($i,[expr {$j+1}],$k) 1
                }
            }            
            # case for group of middle matrices in the right-most column
            for {set row 2} {$row <= [expr {$M-1}]} {incr row} {
                if {"$i,$j,$k" == "$row,$N,[expr {$N*$row - 1}]"} {
                    set mP($i,$j,$k) 1 ; set mP([expr {$i+1}],$j,$k) 1 ; set mP([expr {$i-1}],$j,$k) 1 
                    set mP($i,[expr {$j-1}],$k) 1
                }
            }            
            # case for group of middle matrices between lef/right columns and top/bottom rows
            for {set row 2} {$row <= [expr {$M-1}]} {incr row} {
                for {set col 2} {$col <= [expr {$N-1}]} {incr col} {
                    if {"$i,$j,$k" == "$row,$col,[expr {$N*($row - 1) + $col - 1}]"} {
                        set mP($i,$j,$k) 1 ; set mP([expr {$i+1}],$j,$k) 1 ; set mP([expr {$i-1}],$j,$k) 1 
                        set mP($i,[expr {$j-1}],$k) 1 ; set mP($i,[expr {$j+1}],$k) 1
                    }
                }
            }           
        }
    }
    if {$isDebug} {
        for {set k 0} {$k < $L} {incr k} {
            puts \nk=$k
            for {set i 1} {$i <= $M} {incr i} {
                set row {}
                for {set j 1} {$j <= $N} {incr j} {
                    lappend row $mP($i,$j,$k) 
                }
                puts $row
            }
        }
    }
    return [list $M $N [array get mP]]
#~dd
# % pwd
# /Users/brglez/Sites/~SYNC/gitBed-init/xProj/B.lightp/xLib
# % source ../xLib/all_tcl
# # .. sourced all tcl libraries defined under the sandbox (see the file all_tcl)
# 
# % B.lightp.patterns 1101001010
# 
# ERROR from B.lightp.patterns: 
# .. value of L=10 does not factor correctly into  M*N=12 
# .. values of L that would factor correctly are indicated below 
#    4 6 9 12 16 20 25 30 36 42 49 56 64 72 ....
# 
# 
# % B.lightp.patterns 110100
# 2 3 {2,1,5 0 1,2,5 0 2,2,4 1 1,3,4 0 2,3,3 0 2,2,5 1 1,3,5 1 2,3,4 1 2,3,5 1 1,1,0 1 1,2,0 1 2,1,0 1 1,1,1 1 1,1,2 0 1,3,0 0 2,2,0 0 1,2,1 1 2,1,1 0 1,1,3 1 2,1,2 0 1,2,2 1 2,3,0 0 1,3,1 1 2,2,1 1 1,1,4 0 2,1,3 1 1,2,3 0 2,2,2 0 1,3,2 1 2,3,1 0 1,1,5 0 2,1,4 1 1,2,4 1 2,2,3 1 1,3,3 0 2,3,2 1}
# 
# % B.lightp.patterns 110100 1
# 
# k=0
# 1 1 0
# 1 0 0
# 
# k=1
# 1 1 1
# 0 1 0
# 
# k=2
# 0 1 1
# 0 0 1
# 
# k=3
# 1 0 0
# 1 1 0
# 
# k=4
# 0 1 0
# 1 1 1
# 
# k=5
# 0 0 1
# 0 1 1
# 2 3 {2,1,5 0 1,2,5 0 2,2,4 1 1,3,4 0 2,3,3 0 2,2,5 1 1,3,5 1 2,3,4 1 2,3,5 1 1,1,0 1 1,2,0 1 2,1,0 1 1,1,1 1 
# 1,1,2 0 1,3,0 0 2,2,0 0 1,2,1 1 2,1,1 0 1,1,3 1 2,1,2 0 1,2,2 1 2,3,0 0 1,3,1 1 2,2,1 1 1,1,4 0 2,1,3 1 
# 1,2,3 0 2,2,2 0 1,3,2 1 2,3,1 0 1,1,5 0 2,1,4 1 1,2,4 1 2,2,3 1 1,3,3 0 2,3,2 1}
# 
# % B.lightp.patterns 11111111110000000000 1
# 
# k=0
# 1 1 0 0 0
# 1 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# 
# k=1
# 1 1 1 0 0
# 0 1 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# 
# k=2
# 0 1 1 1 0
# 0 0 1 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# 
# k=3
# 0 0 1 1 1
# 0 0 0 1 0
# 0 0 0 0 0
# 0 0 0 0 0
# 
# k=4
# 0 0 0 1 1
# 0 0 0 0 1
# 0 0 0 0 0
# 0 0 0 0 0
# 
# k=5
# 1 0 0 0 0
# 1 1 0 0 0
# 1 0 0 0 0
# 0 0 0 0 0
# 
# k=6
# 0 1 0 0 0
# 1 1 1 0 0
# 0 1 0 0 0
# 0 0 0 0 0
# 
# k=7
# 0 0 1 0 0
# 0 1 1 1 0
# 0 0 1 0 0
# 0 0 0 0 0
# 
# k=8
# 0 0 0 1 0
# 0 0 1 1 1
# 0 0 0 1 0
# 0 0 0 0 0
# 
# k=9
# 0 0 0 0 1
# 0 0 0 1 1
# 0 0 0 0 1
# 0 0 0 0 0
# 
# k=10
# 0 0 0 0 0
# 1 0 0 0 0
# 1 1 0 0 0
# 1 0 0 0 0
# 
# k=11
# 0 0 0 0 0
# 0 1 0 0 0
# 1 1 1 0 0
# 0 1 0 0 0
# 
# k=12
# 0 0 0 0 0
# 0 0 1 0 0
# 0 1 1 1 0
# 0 0 1 0 0
# 
# k=13
# 0 0 0 0 0
# 0 0 0 1 0
# 0 0 1 1 1
# 0 0 0 1 0
# 
# k=14
# 0 0 0 0 0
# 0 0 0 0 1
# 0 0 0 1 1
# 0 0 0 0 1
# 
# k=15
# 0 0 0 0 0
# 0 0 0 0 0
# 1 0 0 0 0
# 1 1 0 0 0
# 
# k=16
# 0 0 0 0 0
# 0 0 0 0 0
# 0 1 0 0 0
# 1 1 1 0 0
# 
# k=17
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 1 0 0
# 0 1 1 1 0
# 
# k=18
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 1 0
# 0 0 1 1 1
# 
# k=19
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 1
# 0 0 0 1 1 
#
# Copyright: 
# Franc Brglez, Thu Jul  2 13:37:42 EDT 2015
#~dd     
} ;# B.lightp.patterns

#------- keep here as a 80-character reference line to check text width -------#


proc B.lightp.patterns_OLD {
    {instanceInit 110100} 
    {ABOUT "This proc takes ... ."} } {
        
    set thisCmd B.lightp.patterns_OLD
    
    #-- expand the instanceInit
    #! L is 2*2, 2*3=6 or 3*3=9 or 3*4=12 or 4*4=16 or 4*5=20 or 5*5=25  ....!#
    set L [string length $instanceInit]
    if {$L == 4} {
        set M 2 ; set N 2  ;# ;# num-of-rows, num-of-columns
    } elseif {$L == 6} {
        set M 2 ; set N 3
    } elseif {$L == 9} {
        set M 3 ; set N 3
    } elseif {$L == 12} {
        set M 3 ; set N 4
    } elseif {$L == 16} {
        set M 4 ; set N 4
    } elseif {$L == 20} {
        set M 4 ; set N 5
    } elseif {$L == 25} {
        set M 5 ; set N 5
    } else {
        error "\nERROR from $thisCmd:\
          instanceInit=$instanceInit is not supported; binary strings\
          must of of length 4, or 6, or 9, or 12, or 16, or 25.\n"
    }
    # use instanceInit to initialize mP($i,$j,-1): 
    # i.e. the 0-1 matrix selected by random choice or by the user. 
    for {set i 1} {$i <= $M} {incr i} {
        for {set j 1} {$j <= $N} {incr j} {
            set k [expr {($i - 1)*$N + ($j - 1)}] ;# puts $i,$j,$k
            set mP($i,$j,-1) [string index $instanceInit $k]
        }
    }
    ######## SPECIAL CASE for B.lightp.exhA and B.lightp.f ##############
    if {[B.coord.rank $instanceInit] == 0} {
        # we have a special case that should induce a constant value of 0
        # when B.lightp.f is invoked! ** NO NEED FOR THIS In PYTHON **
        set fValue 0
        return [list $M $N [array get mP] $fValue]
    }
    #parray mP ; return
    
    if {$L == 4} {
    for {set k 0} {$k < $L} {incr k} {
        for {set i 1} {$i <= $M} {incr i} {
            for {set j 1} {$j <= $N} {incr j} {
                set mP($i,$j,$k) 0
            }
        }
        if {$k == 0} {
            set mP(1,1,$k) 1 ; set mP(1,2,$k) 1 ; set mP(2,1,$k) 1 
        } elseif {$k == 1} {
            set mP(1,1,$k) 1 ; set mP(1,2,$k) 1 ; set mP(2,2,$k) 1 
        #
        } elseif {$k == 2} {
            set mP(1,1,$k) 1 ; set mP(2,1,$k) 1 ; set mP(2,2,$k) 1   
        } elseif {$k == 3} {
            set mP(1,2,$k) 1 ; set mP(2,1,$k) 1 ; set mP(2,2,$k) 1    
        }
        #puts k=$k
        for {set i 1} {$i <= $M} {incr i} {
            set row {}
            for {set j 1} {$j <= $N} {incr j} {
                lappend row $mP($i,$j,$k) 
            }
            #puts $row
        }
    }}
    
    if {$L == 6} {
    for {set k 0} {$k < $L} {incr k} {
        for {set i 1} {$i <= $M} {incr i} {
            for {set j 1} {$j <= $N} {incr j} {
                set mP($i,$j,$k) 0
            }
        }
        if {$k == 0} {
            set mP(1,1,$k) 1 ; set mP(1,2,$k) 1 ; set mP(2,1,$k) 1 
        } elseif {$k == 1} {
            set mP(1,1,$k) 1 ; set mP(1,2,$k) 1 ; set mP(1,3,$k) 1 ; set mP(2,2,$k) 1 
        } elseif {$k == 2} {
            set mP(1,2,$k) 1 ; set mP(1,3,$k) 1 ; set mP(2,3,$k) 1 
        #   
        } elseif {$k == 3} {
            set mP(1,1,$k) 1 ; set mP(2,1,$k) 1 ; set mP(2,2,$k) 1   
        } elseif {$k == 4} {
            set mP(1,2,$k) 1 ; set mP(2,1,$k) 1 ; set mP(2,2,$k) 1 ; set mP(2,3,$k) 1  
        } elseif {$k == 5} {
            set mP(1,3,$k) 1 ; set mP(2,2,$k) 1 ; set mP(2,3,$k) 1 
        #
        }
        #puts k=$k 
        for {set i 1} {$i <= $M} {incr i} {
            set row {}
            for {set j 1} {$j <= $N} {incr j} {
                lappend row $mP($i,$j,$k) 
            }
            #puts $row
        }
    }}
    
    if {$L == 9} {
    for {set k 0} {$k < $L} {incr k} {
        for {set i 1} {$i <= $M} {incr i} {
            for {set j 1} {$j <= $N} {incr j} {
                set mP($i,$j,$k) 0
            }
        }
        if {$k == 0} {
            set mP(1,1,$k) 1 ; set mP(1,2,$k) 1 ; set mP(2,1,$k) 1 
        } elseif {$k == 1} {
            set mP(1,1,$k) 1 ; set mP(1,2,$k) 1 ; set mP(1,3,$k) 1 ; set mP(2,2,$k) 1 
        } elseif {$k == 2} {
            set mP(1,2,$k) 1 ; set mP(1,3,$k) 1 ; set mP(2,3,$k) 1 
        #  
        } elseif {$k == 3} {
            set mP(1,1,$k) 1 ; set mP(2,1,$k) 1 ; set mP(2,2,$k) 1 ; set mP(3,1,$k) 1 
        } elseif {$k == 4} {
            set mP(1,2,$k) 1 ; set mP(2,1,$k) 1 ; set mP(2,2,$k) 1 ; set mP(2,3,$k) 1 ; set mP(3,2,$k) 1 
        } elseif {$k == 5} {
            set mP(1,3,$k) 1 ; set mP(2,2,$k) 1 ; set mP(2,3,$k) 1 ; set mP(3,3,$k) 1 
        #   
        } elseif {$k == 6} {
            set mP(2,1,$k) 1 ; set mP(3,1,$k) 1 ; set mP(3,2,$k) 1  
        } elseif {$k == 7} {
            set mP(2,2,$k) 1 ; set mP(3,1,$k) 1 ; set mP(3,2,$k) 1 ; set mP(3,3,$k) 1 
        } elseif {$k == 8} {
            set mP(2,3,$k) 1 ; set mP(3,2,$k) 1 ; set mP(3,3,$k) 1  
        }
        #puts k=$k 
        for {set i 1} {$i <= $M} {incr i} {
            set row {}
            for {set j 1} {$j <= $N} {incr j} {
                lappend row $mP($i,$j,$k) 
            }
            #puts $row
        }
    }}
    
    if {$L == 12} {
    for {set k 0} {$k < $L} {incr k} {
        for {set i 1} {$i <= $M} {incr i} {
            for {set j 1} {$j <= $N} {incr j} {
                set mP($i,$j,$k) 0
            }
        }
        if {$k == 0} {
            set mP(1,1,$k) 1 ; set mP(1,2,$k) 1 ; set mP(2,1,$k) 1 
        } elseif {$k == 1} {
            set mP(1,1,$k) 1 ; set mP(1,2,$k) 1 ; set mP(1,3,$k) 1 ; set mP(2,2,$k) 1 
        } elseif {$k == 2} {
            set mP(1,2,$k) 1 ; set mP(1,3,$k) 1 ; set mP(1,4,$k) 1 ; set mP(2,3,$k) 1 
        } elseif {$k == 3} {
            set mP(1,3,$k) 1 ; set mP(1,4,$k) 1 ; set mP(2,4,$k) 1
        #   
        } elseif {$k == 4} {
            set mP(1,1,$k) 1 ; set mP(2,1,$k) 1 ; set mP(2,2,$k) 1 ; set mP(3,1,$k) 1    
        } elseif {$k == 5} {
            set mP(1,2,$k) 1 ; set mP(2,1,$k) 1 ; set mP(2,2,$k) 1 ; set mP(2,3,$k) 1 ; set mP(3,2,$k) 1  
        } elseif {$k == 6} {
            set mP(1,3,$k) 1 ; set mP(2,2,$k) 1 ; set mP(2,3,$k) 1 ; set mP(2,4,$k) 1 ; set mP(3,3,$k) 1
        } elseif {$k == 7} {
            set mP(1,4,$k) 1 ; set mP(2,3,$k) 1 ; set mP(2,4,$k) 1 ; set mP(3,4,$k) 1 
        #   
        } elseif {$k == 8} {
            set mP(2,1,$k) 1 ; set mP(3,1,$k) 1 ; set mP(3,2,$k) 1 
        } elseif {$k == 9} {
            set mP(2,2,$k) 1 ; set mP(3,1,$k) 1 ; set mP(3,2,$k) 1 ; set mP(3,3,$k) 1   
        } elseif {$k == 10} {
            set mP(2,3,$k) 1 ; set mP(3,2,$k) 1 ; set mP(3,3,$k) 1 ; set mP(3,4,$k) 1  
        } elseif {$k == 11} {
            set mP(2,4,$k) 1 ; set mP(3,3,$k) 1 ; set mP(3,4,$k) 1  
        }
        #puts k=$k 
        for {set i 1} {$i <= $M} {incr i} {
            set row {}
            for {set j 1} {$j <= $N} {incr j} {
                lappend row $mP($i,$j,$k) 
            }
            #puts $row
        }
    }}  
    
    if {$L == 16} {
    for {set k 0} {$k < $L} {incr k} {
        for {set i 1} {$i <= $M} {incr i} {
            for {set j 1} {$j <= $N} {incr j} {
                set mP($i,$j,$k) 0
            }
        }
        if {$k == 0} {
            set mP(1,1,$k) 1 ; set mP(1,2,$k) 1 ; set mP(2,1,$k) 1 
        } elseif {$k == 1} {
            set mP(1,1,$k) 1 ; set mP(1,2,$k) 1 ; set mP(1,3,$k) 1 ; set mP(2,2,$k) 1 
        } elseif {$k == 2} {
            set mP(1,2,$k) 1 ; set mP(1,3,$k) 1 ; set mP(1,4,$k) 1 ; set mP(2,3,$k) 1 
        } elseif {$k == 3} {
            set mP(1,3,$k) 1 ; set mP(1,4,$k) 1 ; set mP(2,4,$k) 1
        #   
        } elseif {$k == 4} {
            set mP(1,1,$k) 1 ; set mP(2,1,$k) 1 ; set mP(2,2,$k) 1 ; set mP(3,1,$k) 1    
        } elseif {$k == 5} {
            set mP(1,2,$k) 1 ; set mP(2,1,$k) 1 ; set mP(2,2,$k) 1 ; set mP(2,3,$k) 1 ; set mP(3,2,$k) 1  
        } elseif {$k == 6} {
            set mP(1,3,$k) 1 ; set mP(2,2,$k) 1 ; set mP(2,3,$k) 1 ; set mP(2,4,$k) 1 ; set mP(3,3,$k) 1
        } elseif {$k == 7} {
            set mP(1,4,$k) 1 ; set mP(2,3,$k) 1 ; set mP(2,4,$k) 1 ; set mP(3,4,$k) 1 
        #   
        } elseif {$k == 8} {
            set mP(2,1,$k) 1 ; set mP(3,1,$k) 1 ; set mP(3,2,$k) 1 ; set mP(4,1,$k) 1    
        } elseif {$k == 9} {
            set mP(2,2,$k) 1 ; set mP(3,1,$k) 1 ; set mP(3,2,$k) 1 ; set mP(3,3,$k) 1 ; set mP(4,2,$k) 1  
        } elseif {$k == 10} {
            set mP(2,3,$k) 1 ; set mP(3,2,$k) 1 ; set mP(3,3,$k) 1 ; set mP(3,4,$k) 1 ; set mP(4,3,$k) 1
        } elseif {$k == 11} {
            set mP(2,4,$k) 1 ; set mP(3,3,$k) 1 ; set mP(3,4,$k) 1 ; set mP(4,4,$k) 1 
        #   
        } elseif {$k == 12} {
            set mP(3,1,$k) 1 ; set mP(4,1,$k) 1 ; set mP(4,2,$k) 1 
        } elseif {$k == 13} {
            set mP(3,2,$k) 1 ; set mP(4,1,$k) 1 ; set mP(4,2,$k) 1 ; set mP(4,3,$k) 1   
        } elseif {$k == 14} {
            set mP(3,3,$k) 1 ; set mP(4,2,$k) 1 ; set mP(4,3,$k) 1 ; set mP(4,4,$k) 1  
        } elseif {$k == 15} {
            set mP(3,4,$k) 1 ; set mP(4,3,$k) 1 ; set mP(4,4,$k) 1  
        }
        #puts \nk=$k 
        for {set i 1} {$i <= $M} {incr i} {
            set row {}
            for {set j 1} {$j <= $N} {incr j} {
                lappend row $mP($i,$j,$k) 
            }
            #puts $row
        }
    }}  
    
    if {$L == 20} {
    for {set k 0} {$k < $L} {incr k} {
        for {set i 1} {$i <= $M} {incr i} {
            for {set j 1} {$j <= $N} {incr j} {
                set mP($i,$j,$k) 0
            }
        }
        if {$k == 0} {
            set mP(1,1,$k) 1 ; set mP(1,2,$k) 1 ; set mP(2,1,$k) 1 
        } elseif {$k == 1} {
            set mP(1,1,$k) 1 ; set mP(1,2,$k) 1 ; set mP(1,3,$k) 1 ; set mP(2,2,$k) 1 
        } elseif {$k == 2} {
            set mP(1,2,$k) 1 ; set mP(1,3,$k) 1 ; set mP(1,4,$k) 1 ; set mP(2,3,$k) 1 
        } elseif {$k == 3} {
            set mP(1,3,$k) 1 ; set mP(1,4,$k) 1 ; set mP(1,5,$k) 1 ; set mP(2,4,$k) 1 
        } elseif {$k == 4} {
            set mP(1,4,$k) 1 ; set mP(1,5,$k) 1 ; set mP(2,5,$k) 1
        #   
        } elseif {$k == 5} {
            set mP(1,1,$k) 1 ; set mP(2,1,$k) 1 ; set mP(2,2,$k) 1 ; set mP(3,1,$k) 1    
        } elseif {$k == 6} {
            set mP(1,2,$k) 1 ; set mP(2,1,$k) 1 ; set mP(2,2,$k) 1 ; set mP(2,3,$k) 1 ; set mP(3,2,$k) 1  
        } elseif {$k == 7} {
            set mP(1,3,$k) 1 ; set mP(2,2,$k) 1 ; set mP(2,3,$k) 1 ; set mP(2,4,$k) 1 ; set mP(3,3,$k) 1
        } elseif {$k == 8} {
            set mP(1,4,$k) 1 ; set mP(2,3,$k) 1 ; set mP(2,4,$k) 1 ; set mP(2,5,$k) 1 ; set mP(3,4,$k) 1
        } elseif {$k == 9} {
            set mP(1,5,$k) 1 ; set mP(2,4,$k) 1 ; set mP(2,5,$k) 1 ; set mP(3,5,$k) 1 
        #   
        } elseif {$k == 10} {
            set mP(2,1,$k) 1 ; set mP(3,1,$k) 1 ; set mP(3,2,$k) 1 ; set mP(4,1,$k) 1    
        } elseif {$k == 11} {
            set mP(2,2,$k) 1 ; set mP(3,1,$k) 1 ; set mP(3,2,$k) 1 ; set mP(3,3,$k) 1 ; set mP(4,2,$k) 1  
        } elseif {$k == 12} {
            set mP(2,3,$k) 1 ; set mP(3,2,$k) 1 ; set mP(3,3,$k) 1 ; set mP(3,4,$k) 1 ; set mP(4,3,$k) 1
        } elseif {$k == 13} {
            set mP(2,4,$k) 1 ; set mP(3,3,$k) 1 ; set mP(3,4,$k) 1 ; set mP(3,5,$k) 1 ; set mP(4,4,$k) 1
        } elseif {$k == 14} {
            set mP(2,5,$k) 1 ; set mP(3,4,$k) 1 ; set mP(3,5,$k) 1 ; set mP(4,5,$k) 1 
        #   
        } elseif {$k == 15} {
            set mP(3,1,$k) 1 ; set mP(4,1,$k) 1 ; set mP(4,2,$k) 1 
        } elseif {$k == 16} {
            set mP(3,2,$k) 1 ; set mP(4,1,$k) 1 ; set mP(4,2,$k) 1 ; set mP(4,3,$k) 1   
        } elseif {$k == 17} {
            set mP(3,3,$k) 1 ; set mP(4,2,$k) 1 ; set mP(4,3,$k) 1 ; set mP(4,4,$k) 1  
        } elseif {$k == 18} {
            set mP(3,4,$k) 1 ; set mP(4,3,$k) 1 ; set mP(4,4,$k) 1 ; set mP(4,5,$k) 1 
        } elseif {$k == 19} {
            set mP(3,5,$k) 1 ; set mP(4,4,$k) 1 ; set mP(4,5,$k) 1  
        }
        #puts k=$k 
        for {set i 1} {$i <= $M} {incr i} {
            set row {}
            for {set j 1} {$j <= $N} {incr j} {
                lappend row $mP($i,$j,$k) 
            }
            #puts $row
        }
    }} 
    
    if {$L == 25} {
    for {set k 0} {$k < $L} {incr k} {
        for {set i 1} {$i <= $M} {incr i} {
            for {set j 1} {$j <= $N} {incr j} {
                set mP($i,$j,$k) 0
            }
        }
        if {$k == 0} {
            set mP(1,1,$k) 1 ; set mP(1,2,$k) 1 ; set mP(2,1,$k) 1 
        } elseif {$k == 1} {
            set mP(1,1,$k) 1 ; set mP(1,2,$k) 1 ; set mP(1,3,$k) 1 ; set mP(2,2,$k) 1 
        } elseif {$k == 2} {
            set mP(1,2,$k) 1 ; set mP(1,3,$k) 1 ; set mP(1,4,$k) 1 ; set mP(2,3,$k) 1 
        } elseif {$k == 3} {
            set mP(1,3,$k) 1 ; set mP(1,4,$k) 1 ; set mP(1,5,$k) 1 ; set mP(2,4,$k) 1 
        } elseif {$k == 4} {
            set mP(1,4,$k) 1 ; set mP(1,5,$k) 1 ; set mP(2,5,$k) 1
        #   
        } elseif {$k == 5} {
            set mP(1,1,$k) 1 ; set mP(2,1,$k) 1 ; set mP(2,2,$k) 1 ; set mP(3,1,$k) 1    
        } elseif {$k == 6} {
            set mP(1,2,$k) 1 ; set mP(2,1,$k) 1 ; set mP(2,2,$k) 1 ; set mP(2,3,$k) 1 ; set mP(3,2,$k) 1  
        } elseif {$k == 7} {
            set mP(1,3,$k) 1 ; set mP(2,2,$k) 1 ; set mP(2,3,$k) 1 ; set mP(2,4,$k) 1 ; set mP(3,3,$k) 1
        } elseif {$k == 8} {
            set mP(1,4,$k) 1 ; set mP(2,3,$k) 1 ; set mP(2,4,$k) 1 ; set mP(2,5,$k) 1 ; set mP(3,4,$k) 1
        } elseif {$k == 9} {
            set mP(1,5,$k) 1 ; set mP(2,4,$k) 1 ; set mP(2,5,$k) 1 ; set mP(3,5,$k) 1 
        #   
        } elseif {$k == 10} {
            set mP(2,1,$k) 1 ; set mP(3,1,$k) 1 ; set mP(3,2,$k) 1 ; set mP(4,1,$k) 1    
        } elseif {$k == 11} {
            set mP(2,2,$k) 1 ; set mP(3,1,$k) 1 ; set mP(3,2,$k) 1 ; set mP(3,3,$k) 1 ; set mP(4,2,$k) 1  
        } elseif {$k == 12} {
            set mP(2,3,$k) 1 ; set mP(3,2,$k) 1 ; set mP(3,3,$k) 1 ; set mP(3,4,$k) 1 ; set mP(4,3,$k) 1
        } elseif {$k == 13} {
            set mP(2,4,$k) 1 ; set mP(3,3,$k) 1 ; set mP(3,4,$k) 1 ; set mP(3,5,$k) 1 ; set mP(4,4,$k) 1
        } elseif {$k == 14} {
            set mP(2,5,$k) 1 ; set mP(3,4,$k) 1 ; set mP(3,5,$k) 1 ; set mP(4,5,$k) 1
        #   
        } elseif {$k == 15} {
            set mP(3,1,$k) 1 ; set mP(4,1,$k) 1 ; set mP(4,2,$k) 1 ; set mP(5,1,$k) 1    
        } elseif {$k == 16} {
            set mP(3,2,$k) 1 ; set mP(4,1,$k) 1 ; set mP(4,2,$k) 1 ; set mP(4,3,$k) 1 ; set mP(5,2,$k) 1  
        } elseif {$k == 17} {
            set mP(3,3,$k) 1 ; set mP(4,2,$k) 1 ; set mP(4,3,$k) 1 ; set mP(4,4,$k) 1 ; set mP(5,3,$k) 1
        } elseif {$k == 18} {
            set mP(3,4,$k) 1 ; set mP(4,3,$k) 1 ; set mP(4,4,$k) 1 ; set mP(4,5,$k) 1 ; set mP(5,4,$k) 1
        } elseif {$k == 19} {
            set mP(3,5,$k) 1 ; set mP(4,4,$k) 1 ; set mP(4,5,$k) 1 ; set mP(5,5,$k) 1 
        #   
        } elseif {$k == 20} {
            set mP(4,1,$k) 1 ; set mP(5,1,$k) 1 ; set mP(5,2,$k) 1 
        } elseif {$k == 21} {
            set mP(4,2,$k) 1 ; set mP(5,1,$k) 1 ; set mP(5,2,$k) 1 ; set mP(5,3,$k) 1   
        } elseif {$k == 22} {
            set mP(4,3,$k) 1 ; set mP(5,2,$k) 1 ; set mP(5,3,$k) 1 ; set mP(5,4,$k) 1  
        } elseif {$k == 23} {
            set mP(4,4,$k) 1 ; set mP(5,3,$k) 1 ; set mP(5,4,$k) 1 ; set mP(5,5,$k) 1 
        } elseif {$k == 24} {
            set mP(4,5,$k) 1 ; set mP(5,4,$k) 1 ; set mP(5,5,$k) 1  
        }
        #puts k=$k 
        for {set i 1} {$i <= $M} {incr i} {
            set row {}
            for {set j 1} {$j <= $N} {incr j} {
                lappend row $mP($i,$j,$k) 
            }
            #puts $row
        }
    }} 
    return [list $M $N [array get mP]]
#~dd 
# % B.lightp.patterns 1000
# k=0
# 1 1
# 1 0
# k=1
# 1 1
# 0 1
# k=2
# 1 0
# 1 1
# k=3
# 0 1
# 1 1
# 
# % B.lightp.patterns 100000
# k=0
# 1 1 0
# 1 0 0
# k=1
# 1 1 1
# 0 1 0
# k=2
# 0 1 1
# 0 0 1
# k=3
# 1 0 0
# 1 1 0
# k=4
# 0 1 0
# 1 1 1
# k=5
# 0 0 1
# 0 1 1
# 
# % B.lightp.patterns 100000000
# k=0
# 1 1 0
# 1 0 0
# 0 0 0
# k=1
# 1 1 1
# 0 1 0
# 0 0 0
# k=2
# 0 1 1
# 0 0 1
# 0 0 0
# k=3
# 1 0 0
# 1 1 0
# 1 0 0
# k=4
# 0 1 0
# 1 1 1
# 0 1 0
# k=5
# 0 0 1
# 0 1 1
# 0 0 1
# k=6
# 0 0 0
# 1 0 0
# 1 1 0
# k=7
# 0 0 0
# 0 1 0
# 1 1 1
# k=8
# 0 0 0
# 0 0 1
# 0 1 1
# %  
    
# % B.lightp.patterns 10000000000000000000
# k=0
# 1 1 0 0 0
# 1 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# k=1
# 1 1 1 0 0
# 0 1 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# k=2
# 0 1 1 1 0
# 0 0 1 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# k=3
# 0 0 1 1 1
# 0 0 0 1 0
# 0 0 0 0 0
# 0 0 0 0 0
# k=4
# 0 0 0 1 1
# 0 0 0 0 1
# 0 0 0 0 0
# 0 0 0 0 0
# k=5
# 1 0 0 0 0
# 1 1 0 0 0
# 1 0 0 0 0
# 0 0 0 0 0
# k=6
# 0 1 0 0 0
# 1 1 1 0 0
# 0 1 0 0 0
# 0 0 0 0 0
# k=7
# 0 0 1 0 0
# 0 1 1 1 0
# 0 0 1 0 0
# 0 0 0 0 0
# k=8
# 0 0 0 1 0
# 0 0 1 1 1
# 0 0 0 1 0
# 0 0 0 0 0
# k=9
# 0 0 0 0 1
# 0 0 0 1 1
# 0 0 0 0 1
# 0 0 0 0 0
# k=10
# 0 0 0 0 0
# 1 0 0 0 0
# 1 1 0 0 0
# 1 0 0 0 0
# k=11
# 0 0 0 0 0
# 0 1 0 0 0
# 1 1 1 0 0
# 0 1 0 0 0
# k=12
# 0 0 0 0 0
# 0 0 1 0 0
# 0 1 1 1 0
# 0 0 1 0 0
# k=13
# 0 0 0 0 0
# 0 0 0 1 0
# 0 0 1 1 1
# 0 0 0 1 0
# k=14
# 0 0 0 0 0
# 0 0 0 0 1
# 0 0 0 1 1
# 0 0 0 0 1
# k=15
# 0 0 0 0 0
# 0 0 0 0 0
# 1 0 0 0 0
# 1 1 0 0 0
# k=16
# 0 0 0 0 0
# 0 0 0 0 0
# 0 1 0 0 0
# 1 1 1 0 0
# k=17
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 1 0 0
# 0 1 1 1 0
# k=18
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 1 0
# 0 0 1 1 1
# k=19
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 1
# 0 0 0 1 1
# % 

# % B.lightp.patterns 1000000000000000000000000
# k=0
# 1 1 0 0 0
# 1 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# k=1
# 1 1 1 0 0
# 0 1 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# k=2
# 0 1 1 1 0
# 0 0 1 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# k=3
# 0 0 1 1 1
# 0 0 0 1 0
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# k=4
# 0 0 0 1 1
# 0 0 0 0 1
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# k=5
# 1 0 0 0 0
# 1 1 0 0 0
# 1 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# k=6
# 0 1 0 0 0
# 1 1 1 0 0
# 0 1 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# k=7
# 0 0 1 0 0
# 0 1 1 1 0
# 0 0 1 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# k=8
# 0 0 0 1 0
# 0 0 1 1 1
# 0 0 0 1 0
# 0 0 0 0 0
# 0 0 0 0 0
# k=9
# 0 0 0 0 1
# 0 0 0 1 1
# 0 0 0 0 1
# 0 0 0 0 0
# 0 0 0 0 0
# k=10
# 0 0 0 0 0
# 1 0 0 0 0
# 1 1 0 0 0
# 1 0 0 0 0
# 0 0 0 0 0
# k=11
# 0 0 0 0 0
# 0 1 0 0 0
# 1 1 1 0 0
# 0 1 0 0 0
# 0 0 0 0 0
# k=12
# 0 0 0 0 0
# 0 0 1 0 0
# 0 1 1 1 0
# 0 0 1 0 0
# 0 0 0 0 0
# k=13
# 0 0 0 0 0
# 0 0 0 1 0
# 0 0 1 1 1
# 0 0 0 1 0
# 0 0 0 0 0
# k=14
# 0 0 0 0 0
# 0 0 0 0 1
# 0 0 0 1 1
# 0 0 0 0 1
# 0 0 0 0 0
# k=15
# 0 0 0 0 0
# 0 0 0 0 0
# 1 0 0 0 0
# 1 1 0 0 0
# 1 0 0 0 0
# k=16
# 0 0 0 0 0
# 0 0 0 0 0
# 0 1 0 0 0
# 1 1 1 0 0
# 0 1 0 0 0
# k=17
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 1 0 0
# 0 1 1 1 0
# 0 0 1 0 0
# k=18
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 1 0
# 0 0 1 1 1
# 0 0 0 1 0
# k=19
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 1
# 0 0 0 1 1
# 0 0 0 0 1
# k=20
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# 1 0 0 0 0
# 1 1 0 0 0
# k=21
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# 0 1 0 0 0
# 1 1 1 0 0
# k=22
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 1 0 0
# 0 1 1 1 0
# k=23
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 1 0
# 0 0 1 1 1
# k=24
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 0
# 0 0 0 0 1
# 0 0 0 1 1
# %
# Copyright: 
# Franc Brglez, Wed Feb  4 19:28:30 EST 2015
#~dd  
} ;# B.lightp.patterns_OLD


#------- keep here as a 80-character reference line to check text width -------#

proc B.lightp.f { {coord  101010} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.lightp.f
set ABOUT \
"This procedure takes a binary coordinate (passed as an argument) and the 
data structure created by procedure  B.lightp.patterns (a matrix passed
in a global array aStruc). It computes and returns the instance function 
value, given this coordinate."
    if {$coord == "??"} { puts $ABOUT ; return }
    if {$coord == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    global instance: aStruc    
    
    set isTestOnly 0 ;# set this value to 1 to print test values
    # here we handle a very special case, induced by B.lightp.exhA
    if {$aV(valueTarget) == -1} {
        set fVal 0
        return $fVal  ;# to extend the SAW into A HAMILTONIAN WALK (if possible)!
    }
    set M    $aV(M) ;# num-of-rows
    set N    $aV(N) ;# num-of-columns
    set L    $aV(nDim)
        
    # initialize matrix mInit and mAdd
    array unset mInit ; array unset mAdd
    for {set i 1} {$i <= $M} {incr i} {
        for {set j 1} {$j <= $N} {incr j} {
            set mInit($i,$j) $aStruc($i,$j,-1)
            set mAdd($i,$j)  0
        }
    }
    # optionally, print the initial matrix
    if {$isTestOnly} {
        puts  "================\
          \n.. the initial matrix, constructed from instanceInit = $aV(instanceInit)"
        for {set i 1} {$i <= $M} {incr i} {
            set row {}
            for {set j 1} {$j <= $N} {incr j} {lappend row $mInit($i,$j)}
            puts $row
        }
    }
    # compute the mod-2 sum of all asserted matrix patterns
    for {set k  0} {$k < $L} {incr k} {
        set isAsserted [string index $coord $k]
        if {$isAsserted} {
            # perform mod-2 matrix addition     
            for {set i 1} {$i <= $M} {incr i} {
                for {set j 1} {$j <= $N} {incr j} {
                    set mAdd($i,$j) [expr {($mAdd($i,$j) + \
                      $aStruc($i,$j,$k)) % 2}]
                }
            }
            #puts k=$k
            for {set i 1} {$i <= $M} {incr i} {
                set row {}
                for {set j 1} {$j <= $N} {incr j} {lappend row $mAdd($i,$j)}
                #puts $row
            }
        }
    }
    # optionally, print the mod-2 addition matrix
    if {$isTestOnly} {
        puts ".. completed mod-2 sums of the puzzle's matrices,\
          \n.. asserted by coord = $coord"
        for {set i 1} {$i <= $M} {incr i} {
            set row {}
            for {set j 1} {$j <= $N} {incr j} {lappend row $mAdd($i,$j)}
            puts $row
        }
        puts ================
    }
    # the function value is the sum of all 1's in the matrix!
    set fVal 0
    for {set i 1} {$i <= $M} {incr i} {
        for {set j 1} {$j <= $N} {incr j} {
            set val  [expr {($mInit($i,$j) +  $mAdd($i,$j)) % 2}]
            set fVal [expr {$fVal + $val}]
        }
    }
    #puts "coord_value_pair = $coord\:$fVal"
    return $fVal ;# value to search for valueBest <= valueTarget
# ~dd
# Here, we use B.lightp.exhA to repeatedly invoke B.lightp.f 
# and thus verify the values returned by B.lightp.f for the exhaustive 
# set of binary coordinates.
# 
# % B.lightp.exhA 0110
# hasseAry(0) = 0000:2
# hasseAry(1) = 0001:1 0010:3 0100:3 1000:1
# hasseAry(2) = 0011:2 0101:2 0110:0 1001:4 1010:2 1100:2
# hasseAry(3) = 0111:3 1011:1 1101:1 1110:3
# hasseAry(4) = 1111:2
# coordRank   coordTotal
# 0              1
# 1              4
# 2              6
# 3              4
# 4              1
# valueBest = 0
# solutionBest(rank=2) = 0110:0
# instanceInit = 0110
# .. values returned by B.lightp.exhA for  processing by B.lightp.hasse
# B 4 4 6 {0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 
# 1100 1101 1110 1111} {2 0110:0} {4 1111:2 0 0000:2 1 {0001:1 0010:3 0100:3 1000:1} 
# 2 {0011:2 0101:2 0110:0 1001:4 1010:2 1100:2} 3 {0111:3 1011:1 1101:1 1110:3}}
# % 
#+++++++++++++++++++++++++++++++++++++++++++++++++
# Here are some of the older, more detailed tests:
#+++++++++++++++++++++++++++++++++++++++++++++++++
# % B.lightp.exhA 0110 1
# .. initialized global arrays aV and aStruc
# aV(nDim)           = 4
# aV(M)           = 2
# aV(N)           = 2
# aV(instanceInit) = 0110
# aV(varList)     = 1 2 3 4
# aV(writeVar)    = 3
# .. proceed with individual tests of B.lightp.f B.lightp.fAdj, etc.
# 
# % B.lightp.f 0110 1
# ================ 
# .. the initial matrix, constructed from instanceInit = 0110
# 0 1
# 1 0
# .. completed mod-2 sums of the puzzle's matrices, 
# .. asserted by coord = 0110
# 0 1
# 1 0
# ================
# 0
# 
# 
# % B.lightp.exhA 100000 1
# .. initialized global arrays aV and aStruc
# aV(nDim)           = 6
# aV(M)           = 2
# aV(N)           = 3
# aV(instanceInit) = 100000
# aV(varList)     = 1 2 3 4 5 6
# aV(writeVar)    = 3
# .. proceed with individual tests of B.lightp.f B.lightp.fAdj, etc.
# 
# % B.lightp.f 101101 1
# ================ 
# .. the initial matrix, constructed from instanceInit = 100000
# 1 0 0
# 0 0 0
# .. completed mod-2 sums of the puzzle's matrices, 
# .. asserted by coord = 101101
# 0 0 0
# 0 0 0
# ================
# 1
# 
# % B.lightp.exhA 110100 1
# .. initialized global arrays aV and aStruc
# aV(nDim)           = 6
# aV(M)           = 2
# aV(N)           = 3
# aV(instanceInit) = 110100
# aV(varList)     = 1 2 3 4 5 6
# aV(writeVar)    = 3
# .. proceed with individual tests of B.lightp.f B.lightp.fAdj, etc.
# 
# % B.lightp.f 110111 1
# ================ 
# .. the initial matrix, constructed from instanceInit = 110100
# 1 1 0
# 1 0 0
# .. completed mod-2 sums of the puzzle's matrices, 
# .. asserted by coord = 110111
# 1 1 0
# 1 0 0
# ================
# 0
# 

# % B.lightp.exhA 101000000 1
# .. initialized global arrays aV and aStruc
# aV(nDim)           = 9
# aV(M)           = 3
# aV(N)           = 3
# aV(instanceInit) = 101000000
# aV(varList)     = 1 2 3 4 5 6 7 8 9
# aV(writeVar)    = 3
# .. proceed with individual tests of B.lightp.f B.lightp.fAdj, etc.
# 
# % B.lightp.f 000101101 1
# ================ 
# .. the initial matrix, constructed from instanceInit = 101000000
# 1 0 1
# 0 0 0
# 0 0 0
# .. completed mod-2 sums of the puzzle's matrices, 
# .. asserted by coord = 000101101
# 1 0 1
# 0 0 0
# 0 0 0
# ================
# 0
# % 
# Copyright: 
# Franc Brglez, Thu Feb 12 21:06:30 EST 2015
#~dd   
} ;# proc B.lightp.f

proc B.lightp.fAdj { {coordPiv  101010} } {  
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.lightp.fAdj
set ABOUT \
"This procedure takes a pivot coordinate and returns **a COMPLETE set of  
adjacent function values**  for the 'light-out puzzle problem' (lightp).
We use a tableau formulation to **efficiently** probe the function not only
with the pivot coordinate but also with **all** of L=M*N adjacent coordinates.
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

    set M    $aV(M)  ;# num-of-rows
    set N    $aV(N)  ;# num-of-columns
    set L    $aV(nDim)
       
### PASS 1: given coordinate 'coordPiv' and aStruc($i,$j,$k), 
###         get mTot($i,$j) and fVal    
    # initialize matrix mInit and mAdd (FOR MORE COMMENTS, see also B.lightp.f)
    array unset mInit ; array unset mAdd
    for {set i 1} {$i <= $M} {incr i} {
        for {set j 1} {$j <= $N} {incr j} {
            set mInit($i,$j) $aStruc($i,$j,-1)
            set mAdd($i,$j)  0
        }
    }
    # compute the mod-2 addition matrix of all asserted matrix patterns
    for {set k  0} {$k < $L} {incr k} {
        set isAsserted [string index $coordPiv $k]
        if {$isAsserted} {
            # perform mod-2 matrix addition     
            for {set i 1} {$i <= $M} {incr i} {
                for {set j 1} {$j <= $N} {incr j} {
                    set mAdd($i,$j) [expr {($mAdd($i,$j) + $aStruc($i,$j,$k)) % 2}]
                }
            }
            #puts k=$k
            for {set i 1} {$i <= $M} {incr i} {
                set row {}
                for {set j 1} {$j <= $N} {incr j} {lappend row $mAdd($i,$j)}
                #puts $row
            }
        }
    }
    # compute the mod-2 sum matrix of initial/addition matrices
    # the function value is the sum of all 1's in the matrix!
    set valuePiv 0
    for {set i 1} {$i <= $M} {incr i} {
        for {set j 1} {$j <= $N} {incr j} {
            set mTot($i,$j)  [expr {($mInit($i,$j) +  \
              $mAdd($i,$j)) % 2}]
            set valuePiv [expr {$valuePiv + $mTot($i,$j)}]
        }
    }
    incr aV(cntProbe)
    
### PASS 2: given aStruc($i,$j,$k) and mTot($i,$j), 
###         get all coordAdj and valueAdj
    array unset aCoordAdj ; array unset aValueAdj
    for {set k  0} {$k < $L} {incr k} {
        set bit [string index $coordPiv $k]
        if {$bit} {
            set coordAdj [string replace $coordPiv $k $k 0]
        } else {
            set coordAdj [string replace $coordPiv $k $k 1]
        }
        set valueAdj 0
        for {set i 1} {$i <= $M} {incr i} {
            for {set j 1} {$j <= $N} {incr j} {
                set mAdj($i,$j)  [expr {($mTot($i,$j) + \
                  $aStruc($i,$j,$k)) % 2}]
                set valueAdj [expr {$valueAdj + $mAdj($i,$j)}]
            }
        } 
        set aCoordAdj($coordAdj) $valueAdj
        lappend aValueAdj($valueAdj) $coordAdj
    }
    incr  aV(cntProbe)
    if {$aV(writeVar) == 3} {
        puts "FROM: $thisCmd\
          \nreturning the pivot coordinate:value pair AND ALL ADJACENT\
          \ncoordinate:value pairs, computed via the tableau method,\
          cntProbe= $aV(cntProbe)\
          \n-----\tcoord\tvalue\
          \npivot\t$coordPiv\t$valuePiv"
        foreach coord [array names aCoordAdj] {
            puts -adj-\t$coord\t$aCoordAdj($coord)
        }
    }
    return [list $valuePiv [array get aValueAdj] ]
# ~dd
# % B.lightp.init i-6-a-0 -coordInit 100001 -writeVar 3
# # ** from: B.lightp.init:
# # instanceDef=i-6-a-0 
# # argsOptions=-coordInit 100001 -writeVar 3
# 0 100001 3
# 
# % B.lightp.saw_pivot_simple 100001 0
# A trace from B.lightp.saw_pivot_simple: 
# Evaluating neighbors of coordPivot=100001 
# cntProbe	Idx	coordPivot	valPivot	coordAdj	valAdj	dist	rank 
# ~	~	100001	0	~	~	0	2
# 2	0	000001	6	000001	6	1	1
# 3	1	110001	3	110001	3	1	3
# 4	2	101001	2	101001	2	1	3
# 5	3	101001	2	100101	4	1	3
# 6	4	101001	2	100011	3	1	3
# 7	5	100000	0	100000	0	1	1
# 100000 0 6 {} {}
# 
# ## we get identical results, just more efficiently with  B.lightp.fAdj
# % B.lightp.fAdj 100001 1
# pivotPair = 100001:3
# aCoordAdj(000001) = 6
# aCoordAdj(100000) = 0
# aCoordAdj(100011) = 3
# aCoordAdj(100101) = 4
# aCoordAdj(101001) = 2
# aCoordAdj(110001) = 3
# aValueAdj(0) = 100000
# aValueAdj(2) = 101001
# aValueAdj(3) = 110001 100011
# aValueAdj(4) = 100101
# aValueAdj(6) = 000001
# % 
# Copyright:
# Franc Brglez, Fri May  8 13:36:06 EDT 2015
#~dd
} ;# proc B.lightp.fAdj

#------- keep here as a 80-character reference line to check text width -------#

proc B.lightp.hasse { {instanceDef i-4-z-0} } {      
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.lightp.hasse ; set sandboxName B.lightp
set ABOUT \
"This proc takes the name the instance defined within the sandbox B.lightp 
and the value of instanceInit (a binary string) associated with the name
of this instance, then invokes B.lightp.exhA to access data structures 
needed to create two files in this procedure: a file of vertices 
and a file of edges, annotated with x-y coordinates for plotting of Hasse 
graphs under R."
    if {$instanceDef == "??"} {puts $ABOUT ; return }
    if {$instanceDef == "?"}  {error "Valid query is '$thisCmd ??'"; return}
#-- end   ABOUT ---------------------------------------------------------------#
    
    # read infoSolutionsFile for this instance  
    append infoSolutionsFile $sandboxName .info_solutions  .txt
    set infoSolutionsFile [file join ../xBenchm lightp \
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
	if {$varName == $instanceDef} {
	    set aV(instanceInit) [lindex $line 1] 
	    set aV(valueTarget)  [lindex $line 2] ; set aV(isProven) [lindex $line 3]
	    
	    set aV(nDim) [string length $aV(instanceInit)]
	    set aV(instanceDim) $aV(nDim) 
	    set aV(coordRef) [string repeat 0  $aV(nDim)]
	    set aV(varList) {}
	    for {set i 1} {$i <= $aV(nDim)} {incr i} {lappend aV(varList) $i}
	    set isFound 1
	} 
	if {$isFound} {break}
    }
    if {!$isFound} {
	error "\nERROR from $thisCmd:\
	  \n.. instance $aV(instanceDef) has not found in file\
	  \n    $infoSolutionsFile\n"
    }
    set aV(instanceInit) 111111
    set rList [B.lightp.exhA $aV(instanceInit)] ; puts \nrList\n$rList ;# return
    
    set coordType      [lindex $rList 0]
    set L              [lindex $rList 1] 
    set rankMax        [lindex $rList 2]
    set widthMax       [lindex $rList 3]
    set coordList      [lindex $rList 4]
    array set bestAry  [lindex $rList 5]
    array set hasseAry [lindex $rList 6] 
    #parray bestAry ; puts " " ; parray hasseAry ;# return
    
    # create vertex and edge files for Hasse graph    
    append fileVertex fg-B.lightp- [file tail [file rootname $instanceDef]]-vertex.txt
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
    append fileEdge fg-B.lightp- [file tail [file rootname $instanceDef]]-edge.txt
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
# Copyright: 
# Franc Brglez, Thu May  7 15:51:36 EDT 2015
#~dd        
} ;# B.lightp.hasse

proc B.lightp.exhA { {instanceInit 110100} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.lightp.exhA ; set sandbox B.lightp
set ABOUT \
"
USAGE:    $thisCmd instanceInit 

EXAMPLE:  $thisCmd  110100  
     
The command $thisCmd takes a binary coordinate 'instanceInit' of length L    
which defines the initial configuration of the 'lights-out puzzle' under 
the sandbox $sandbox. A simple procedure generates a ranked list of
2^L binary coordinates to perform an  exhaustive evaluation of the 
'light-out puzzle' instance as defined by instanceInit; it also returns the 
minimum value solutions as a list of coordinate:value pairs. The rank of each 
coordinate is associated with the Hasse graph representation of the puzzle
instance. For coordinates of lengths L <= 6, the procedure also returns
a data structure for the follow-up tcl command B.lightp.hasse which creates 
files of vertices and edges for plotting, under R, of SAWs (self-avoiding 
walks) in Hasse graphs. For a special case with instanceInit = 000....000 
(all zeros in the binary string), the self-avoiding walk may demonstrate 
a walk terminated due to a 'trapped pivot'.
"
    if {$instanceInit == "??"} { puts $ABOUT ; return }
    if {$instanceInit == "?"}  { error "Valid query is '$thisCmd ??'" ; return }
#-- end   ABOUT ---------------------------------------------------------------#
    
    global     info: all_info all_valu aV
    global instance: aStruc
    array unset aV ; array unset aStruc
    
    #-- initialize all matrix patterns
    set L     [string length $instanceInit]
    set rList [B.lightp.patterns $instanceInit]
    set M     [lindex $rList 0] ;# num-of-rows
    set N     [lindex $rList 1] ;# num-of-columns
    array set aStruc [lindex $rList 2] ;# parray aStruc ; return
    
    set aV(M) $M ; set aV(N) $N ; set aV(nDim) $L 
    
    set aV(valueTarget) 0.
    
        
    ##!< initialize aV also to support testing of 
    ##!< B.lightp.f, B.lightp.saw_pivot_simple, and B.lightp.saw_pivot
    set aV(writeVar)    3
    set aV(instanceInit) $instanceInit
    set aV(varList)     {}
    for {set i 1} {$i <= $L} {incr i} {lappend aV(varList) $i}
    #parray aV ; return
    ##!> 
    # generate an exhaustive list of coordinates (use *.exhB when L > 9)
    for {set i 0} {$i < [expr {2**$L}]} {incr i} {
        lappend coordList [B.coord.from_int $i $L]
    }
    #puts coordList\n[join $coordList \n] 
    
    # perform exhaustive enumeration  
    set valueMin +1e30 ; array unset hasseAry
    foreach coord $coordList {
        set value [B.lightp.f $coord]
        set rank  [B.coord.rank  $coord]
        lappend hasseAry($rank) [join $coord ,]\:$value
        if {$value < $valueMin} {set valueMin $value}
    }
    if {$L <= 6} {puts \n ; parray hasseAry ; puts \n}
    set rankMax [expr {[array size hasseAry] - 1}]
    array unset bestAry
    puts "coordRank   coordTotal" 
    set widthMax 0
    foreach rank [lsort -integer [array names hasseAry]] {
        set width [llength $hasseAry($rank)]
        if {$width > $widthMax} {set  widthMax $width}
        set listBest [lsearch -all -inline $hasseAry($rank) *:$valueMin]
        if {$listBest != {}} {set bestAry($rank) $listBest}
        #puts $rank\t$width\t[join $hasseAry($rank) " "]
        puts "$rank              $width"
    }
    puts "\nvalueBest = $valueMin"
    foreach rank [lsort -integer [array names bestAry]] {
        if {[info exists bestAry($rank)]} {
            puts "solutionBest(rank=$rank) = $bestAry($rank)"
        }
    }
    puts "instanceInit = $instanceInit"
    # this feature is needed for the follow-up tcl proc $P.lop.hasse
    if {$aV(nDim) <= 6} {
        puts "\n.. values returned by $thisCmd for  processing by B.lightp.hasse"
        return [list B $aV(nDim) $rankMax $widthMax $coordList \
          [array get bestAry] [array get hasseAry]]
    } else {
        return
    }
# ~dd
# % B.lightp.exhA 0110
# hasseAry(0) = 0000:2
# hasseAry(1) = 0001:1 0010:3 0100:3 1000:1
# hasseAry(2) = 0011:2 0101:2 0110:0 1001:4 1010:2 1100:2
# hasseAry(3) = 0111:3 1011:1 1101:1 1110:3
# hasseAry(4) = 1111:2
# coordRank   coordTotal
# 0              1
# 1              4
# 2              6
# 3              4
# 4              1
# valueBest = 0
# solutionBest(rank=2) = 0110:0
# instanceInit = 0110
# .. values returned by B.lightp.exhA for  processing by B.lightp.hasse
# B 4 4 6 {0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101 1110 1111} {2 0110:0} {4 1111:2 0 0000:2 1 {0001:1 0010:3 0100:3 1000:1} 2 {0011:2 0101:2 0110:0 1001:4 1010:2 1100:2} 3 {0111:3 1011:1 1101:1 1110:3}}
# % 
# 
# % B.lightp.exhA 0000
# hasseAry(0) = 0000:0
# hasseAry(1) = 0001:0 0010:0 0100:0 1000:0
# hasseAry(2) = 0011:0 0101:0 0110:0 1001:0 1010:0 1100:0
# hasseAry(3) = 0111:0 1011:0 1101:0 1110:0
# hasseAry(4) = 1111:0
# coordRank   coordTotal
# 0              1
# 1              4
# 2              6
# 3              4
# 4              1
# valueBest = 0
# solutionBest(rank=0) = 0000:0
# solutionBest(rank=1) = 0001:0 0010:0 0100:0 1000:0
# solutionBest(rank=2) = 0011:0 0101:0 0110:0 1001:0 1010:0 1100:0
# solutionBest(rank=3) = 0111:0 1011:0 1101:0 1110:0
# solutionBest(rank=4) = 1111:0
# instanceInit = 0000
# .. values returned by B.lightp.exhA for  processing by B.lightp.hasse
# B 4 4 6 {0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101 1110 1111} {4 1111:0 0 0000:0 1 {0001:0 0010:0 0100:0 1000:0} 2 {0011:0 0101:0 0110:0 1001:0 1010:0 1100:0} 3 {0111:0 1011:0 1101:0 1110:0}} {4 1111:0 0 0000:0 1 {0001:0 0010:0 0100:0 1000:0} 2 {0011:0 0101:0 0110:0 1001:0 1010:0 1100:0} 3 {0111:0 1011:0 1101:0 1110:0}}
# % 
# 
# 
# #!! instanceInit=100000 induces 8 solutionBest !!
# % B.lightp.exhA 100000
# hasseAry(0) = 000000:1
# hasseAry(1) = 000001:4 000010:5 000100:2 001000:4 010000:3 100000:2
# hasseAry(2) = 000011:4 000101:3 000110:2 001001:3 001010:4 001100:5 010001:2 010010:3 010100:4 011000:2 100001:5 100010:2 100100:3 101000:3 110000:4
# hasseAry(3) = 000111:3 001011:3 001101:2 001110:1 010011:2 010101:5 010110:4 011001:1 011010:2 011100:3 100011:1 100101:4 100110:3 101001:2 101010:3 101100:4 110001:3 110010:4 110100:1 111000:5
# hasseAry(4) = 001111:2 010111:1 011011:5 011101:4 011110:3 100111:4 101011:2 101101:1 101110:4 110011:3 110101:2 110110:5 111001:4 111010:1 111100:2
# hasseAry(5) = 011111:4 101111:5 110111:2 111011:4 111101:3 111110:2
# hasseAry(6) = 111111:3
# coordRank   coordTotal
# 0              1
# 1              6
# 2              15
# 3              20
# 4              15
# 5              6
# 6              1
# valueBest = 1
# solutionBest(rank=0) = 000000:1
# solutionBest(rank=3) = 001110:1 011001:1 100011:1 110100:1
# solutionBest(rank=4) = 010111:1 101101:1 111010:1
# instanceInit = 100000
# 
# 
# #!! instanceInit=110100 induces 4 solutionBest !!
# % B.lightp.exhA 110100
# hasseAry(0) = 000000:3
# hasseAry(1) = 000001:6 000010:3 000100:2 001000:4 010000:3 100000:0
# hasseAry(2) = 000011:2 000101:3 000110:2 001001:3 001010:4 001100:3 010001:2 010010:3 010100:2 011000:4 100001:3 100010:4 100100:3 101000:3 110000:4
# hasseAry(3) = 000111:3 001011:3 001101:0 001110:3 010011:2 010101:3 010110:6 011001:3 011010:0 011100:3 100011:3 100101:4 100110:3 101001:2 101010:3 101100:6 110001:3 110010:4 110100:3 111000:3
# hasseAry(4) = 001111:4 010111:3 011011:3 011101:4 011110:3 100111:4 101011:2 101101:3 101110:2 110011:3 110101:4 110110:3 111001:2 111010:3 111100:2
# hasseAry(5) = 011111:4 101111:3 110111:0 111011:6 111101:3 111110:2
# hasseAry(6) = 111111:3
# coordRank   coordTotal
# 0              1
# 1              6
# 2              15
# 3              20
# 4              15
# 5              6
# 6              1
# valueBest = 0
# solutionBest(rank=1) = 100000:0
# solutionBest(rank=3) = 001101:0 011010:0 
# solutionBest(rank=5) = 110111:0
# instanceInit = 110100 
# 
# % B.lightp.exhA 010010010
# coordRank   coordTotal
# 0              1
# 1              9
# 2              36
# 3              84
# 4              126
# 5              126
# 6              84
# 7              36
# 8              9
# 9              1
# valueBest = 0
# solutionBest(rank=7) = 101111101:0
# instanceInit = 010010010
    
# % B.lightp.exhA 000111000
# coordRank   coordTotal
# 0              1
# 1              9
# 2              36
# 3              84
# 4              126
# 5              126
# 6              84
# 7              36
# 8              9
# 9              1
# valueBest = 0
# solutionBest(rank=7) = 111010111:0
# instanceInit = 000111000
# %
# Copyright: 
# Franc Brglez, Thu May  7 15:51:36 EDT 2015
#~dd      
} ;# proc B.lightp.exhA
    
#------- keep here as a 80-character reference line to check text width -------#

proc B.lightp.exhB { {instanceInit 001001011} } {
#-- begin ABOUT ---------------------------------------------------------------#
set thisCmd B.lightp.exhB ; set sandbox B.lightp
set ABOUT \
"
USAGE:           B.lightp.exhB  instanceInit 

EXAMPLE:         B.lightp.exhB  001001011 (under tclsh **OR** python shell) 
         ../xBin/B.lightp.exhBT 001001011 (tcl    executable under bash)
         ../xBin/B.lightp.exhBP 001001011 (python executable under bash)
         
The command $thisCmd takes a binary coordinate 'instanceInit' of length L  
which defines the initial configuration of lights-out in the puzzle under 
the sandbox $sandbox.  An iterative procedure generates a ranked list of
2^L binary coordinates to perform an  exhaustive evaluation of the 
'light-out puzzle' instance as defined by instanceInit. The principle behind
the iterative coordinate generation is re-use of the associative array
aCoordHash0. Given this array, the generation proceeds from 
all coordinates at rank k to all coordinates at rank k+1. The value of k is 
in the range \[0, L\]. The exhaustive evaluation includes comprehensive 
instrumentation to measure the computational cost and the efficiency of the 
procedure.

For a stdout query, use one of these these commands:
            B.lightp.exhB  ??  (sourced under tclsh)
    ../xBin/B.lightp.exhBT     (executable under bash)  
"
    if {$instanceInit == "??"} { puts $ABOUT ; return }
    if {$instanceInit == "?"}  { error "Valid query is '$thisCmd ??'" ;return }
#-- end   ABOUT ---------------------------------------------------------------#

    global tcl_platform tcl_patchLevel
    global     info: all_info all_valu aV
    global instance: aStruc
    array unset aV ; array unset aStruc
    
    #-- initialize all matrix patterns
    set L     [string length $instanceInit]
    set rList [B.lightp.patterns $instanceInit]
    set M     [lindex $rList 0] ;# num-of-rows
    set N     [lindex $rList 1] ;# num-of-columns
    array set aStruc [lindex $rList 2] ;# parray aStruc ; return

    set aV(M) $M ; set aV(N) $N ; set aV(nDim) $L 
    set aV(valueTarget) 0 ;# NEEDED so B.lightp can proceed ...
    # since we are dealing with binary coordinates
    set rankMax $L
    
    # define coordinate:value pair with rank=0
    set coordRef [string repeat 0 $L]
    set coordList0 [list $coordRef] ; set value [B.lightp.f  $coordRef]    
    set valueBest 1e30 
    lappend bestAry($value) 000\_[join $coordRef ,]\:$value
    set coordDistrib(000) 1 ; set sizeTot 1
    
    # For each rank, unset aCoordHash0 before aggregating coordList1
    # then probe B.lightp.f for function value
    array unset aCoordHash0 ; set coordList1 {} 
    set runtimeCoord 0.0 ; set runtimeProbe 0.0 ; 
    if {$L <= 5} {lappend hasseVertices(0,1) [join $coordRef ,]\:$value} 
    
    # at each rank, generate all unique coordinates and probe for function values
    for {set rank 1} {$rank <= $rankMax} {incr rank} {
         
        #!! #** timing starts for coordList *** 
        # given coordList0, compute coordList1, up to rankMax
        set microSecs [lindex [time {
        foreach coord $coordList0 {
            
            for {set i 0} {$i < $L} {incr i} {
                set bit [string index $coord $i]
               if {$bit} {
                    set coordAdj [string replace $coord $i $i 0]
                } else {
                    set coordAdj [string replace $coord $i $i 1]
                } 
                set weight [B.coord.rank $coordAdj]
                if {$weight == $rank && ![info exists aCoordHash0($coordAdj)]} {
                    set aCoordHash0($coordAdj) {}
                    lappend coordList1 $coordAdj ; incr sizeTot ; incr sizeRank   
                }
            }
        }
        } 1 ] 0 ] 
        #!! #** timing ends *** 
        # RECORD runtimeCoord for current rank
        set runtimeCoord [expr {$runtimeCoord + ($microSecs/1e6)}]
        
        # now, probe each coordinate at current rank for function value 
        #!! #** timing starts ***  
        set microSecs [lindex [time {
        foreach coord $coordList1 {
            set value [B.lightp.f $coord]
            if {$L <= 5} {
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
        
    } ;# for {set rank 1} {$rank <= $L} {incr rank}
    
    # find valueBest solutions
    set valueMin [lindex [lsort -integer [array names bestAry]] 0]
    puts "\nThere are [llength $bestAry($valueMin)] valueBest=$valueMin \
      solutions for instanceInit=$instanceInit\
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
      \ninstanceInit = $instanceInit, M = $M (rows), N = $N (columns)\
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
      \n    thisCmd = $thisCmd\
      \n"
    parray coordDistrib
    return
#~dd
# % B.lightp.exhB 1000
# 
# There are 1 valueBest=0  solutions for instanceInit=1000 
# rank	solution
# 003	1110:0
#  
# instanceInit = 1000, M = 2 (rows), N = 2 (columns) 
# There are 1 valueBest=0 solutions 
#      rankMax = 4 
#  coordLength = 4 
#  coordTotal  = 16 
# runtimeCoord = 0.0013 
# runtimeProbe = 0.0012 
# runtimeRatio = 1.0616 
#       hostID = brglez@belair-Darwin-14.3.0 
#     compiler = tcl-8.5.8 
#     dateLine = Sun May 24 11:16:57 EDT 2015 
#     thisCmd = B.lightp.exhB 
# 
# coordDistrib(000) = 1
# coordDistrib(001) = 4
# coordDistrib(002) = 6
# coordDistrib(003) = 4
# coordDistrib(004) = 1
# % 
# 
# % B.lightp.exhB 110100
# 
# There are 4 valueBest=0  solutions for instanceInit=110100 
# rank	solution
# 001	100000:0
# 003	001101:0
# 003	011010:0
# 005	110111:0
#  
# instanceInit = 110100, M = 2 (rows), N = 3 (columns) 
# There are 4 valueBest=0 solutions 
#      rankMax = 6 
#  coordLength = 6 
#  coordTotal  = 64 
# runtimeCoord = 0.0046 
# runtimeProbe = 0.0039 
# runtimeRatio = 1.1634 
#       hostID = brglez@belair-Darwin-14.3.0 
#     compiler = tcl-8.5.8 
#     dateLine = Sun May 24 11:07:32 EDT 2015 
#     thisCmd = B.lightp.exhB 
# 
# coordDistrib(000) = 1
# coordDistrib(001) = 6
# coordDistrib(002) = 15
# coordDistrib(003) = 20
# coordDistrib(004) = 15
# coordDistrib(005) = 6
# coordDistrib(006) = 1
# %
# Copyright: 
# Franc Brglez, Sun May 24 11:12:09 EDT 2015
#~dd
} ;# proc B.lightp.exhB

#------- keep here as a 80-character reference line to check text width -------#

