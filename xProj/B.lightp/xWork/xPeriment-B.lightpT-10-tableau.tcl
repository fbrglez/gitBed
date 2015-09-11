# xPeriment configuration file:  xPeriment-config-P.lopT-test1.tcl
# ------------------------------------------------------------------
# these variables can be entered in any order
set xP(solverDir)      ../xBin/

set xP(solverOptions)  {
    -runtimeLmt 3600 -seedInit 1901 
}
set xP(sampleSize)   10

set xP(sampleColumns) {
    instanceID instanceDim hostID sandboxID solverName 
    valueTarget valueBest targetReached isCensored runtimeLmt runtime 
    cntProbe walkLength cntRestart speedProbe coordBest
}

set xP(stdoutNames) {
    instanceDef solverID coordInit coordBest nDim  
    walkLengthLmt walkLength  cntRestartLmt cntRestart   
    cntProbeLmt cntProbe runtimeLmt runtime runtimeRead speed hostID 
    isSimple neighbDist solverMethod 
    walkSegmLmt walkSegmCoef walkIntervalLmt walkIntervalCoef 
    walkRepeatsLmt seedInit  valueInit 
    valueBest  valueTarget valueTol targetReached isCensored
} 


set xP(instanceDefList) {
    i-9-z-0
    i-12-z-0
    i-16-z-0
}

set xP(instanceDefListFull) {
    i-9-z-0
    i-12-z-0
    i-16-z-0
    i-20-z-0
    i-25-z-0
    i-30-z-0
    i-36-z-0
    i-42-z-0
    i-49-z-0
    i-56-z-0
    i-64-z-0
    i-49-z-0
    i-56-z-0
    i-64-z-0
    i-72-z-0
    i-81-z-0
    i-90-z-0
    i-100-z-0
}