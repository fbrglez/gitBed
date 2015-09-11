# xPeriment configuration file:  xPeriment-config-P.lopT-test1.tcl
# ------------------------------------------------------------------
# these variables can be entered in any order
set xP(solverDir)      ../xBin/

set xP(solverOptions)  {
    -runtimeLmt 3600 -seedInit 1901
}
set xP(sampleSize)   20

set xP(methods)     MS

set xP(sampleColumns) {
    instanceID instanceDim hostID sandboxID solverName 
    valueTarget valueBest targetReached isCensored runtimeLmt runtime 
    cntProbe walkLength cntRestart speedProbe coordBest
}

set xP(stdoutNames) {
    instanceDef solverID hostID seedInit 
    coordInit coordBest nDim  
    walkLengthLmt walkLength  cntRestartLmt cntRestart   
    cntProbeLmt cntProbe runtimeLmt runtime speed  
    valueInit 
    valueBest  valueTarget targetReached isCensored
} 

# 5 6 7 8 9 10 11 12 13 14
set xP(instanceDefList) {
   5 6 7 
}
