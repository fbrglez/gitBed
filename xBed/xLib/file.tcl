#------- keep here as a 80-character reference line to check text width -------#

proc file.read {fileName} {
    # Author: Hemang Lavana, 1998
    if {![catch {set fileId [open $fileName r]} err]} {
        # Note: usage of "file size .." below, although not required,
        # improves speed considerably
        set data [read $fileId [file size $fileName]]
        close $fileId
    } else {
        puts "ERROR: $err"
        set data ""
    }
    return $data
} ;# file.read

proc file.write {fileName data} {
    # Writes data into a specified file
    # Author: Hemang Lavana, 1998
    if {![catch {set fileId [open $fileName w]} err]} {
        puts -nonewline $fileId $data
        close $fileId
    } else {
        puts "ERROR: $err"
    }
} ;# file.write

proc file.append {fileName data} {
    # Author: Hemang Lavana, 1998
    if {![catch {set fileId [open $fileName a]} err]} {
        puts -nonewline $fileId $data
        close $fileId
    } else {
        puts "ERROR: $err"
    }
} ;# file.append

proc file.read.lines {fileName {commentChar "\#"}} {
    # Author: Franc Brglez, 2010
    set fid [open $fileName r]
    while {! [eof $fid] } {
        set len [gets $fid line]
        switch -- $len {
            0 {
            # Skip blank lines
            continue
            }
            -1 {
            # EOF
            break
            }
        }
        if {[string index [lindex $line 0] 0] != $commentChar} {
            lappend lineList $line
        }
    }
    close $fid
    set lineRows {}
    foreach line $lineList {append lineRows $line\n}
    return $lineRows
} ;# file.read.lines

proc file.read.tableInR {
    {fileName ../../../xLib/util/table_test/util.table_test-sample.txt}
    {ABOUT "Reads a tabular file in R-format: returns commentLines,
    columnLabels, and dataAry indexed with column labels from the table"} } {

    set thisCmd file.read.tableInR
    if {![file exists $fileName]} {
        error "\nERROR .... file=\n$fileName\n could not be found"
    } else {
        puts ".. invoking file.read from $thisCmd"
    }
    set allRows [split [file.read $fileName] \n] ;# puts $allRows
    set cnt 0 ; set columnLabels {} ; set dataRows {} ; set dataRowCnt 0
    foreach row $allRows {
        set firstChar [string index $row 0]
        if {$firstChar != "\#" && $firstChar != " " && $firstChar != {}} {
            if {$cnt == 0} {
                set itemsHeader [llength $row]
                set columnLabels $row
                #puts columnLabels=$columnLabels
                incr cnt
            } else {
                set itemsData [llength $row]
                if {$itemsHeader != $itemsData} {
                    #error "\nERROR ... table has inconsistent entries\
                      \nitemsHeader=$itemsHeader, itemsData=$itemsData"
                }
                set i 0 
                foreach col $columnLabels {
                    lappend dataAry($col) [lindex $row $i]
                    incr i
                }
                append dataRows $row\n
            }
        } else {
            if {$firstChar != " " && $firstChar != {}} {
                append commentLines $row\n
            }
        }
    }
    if {[info exists commentLines]} {
        set commentLines [string trimright $commentLines "\n"]
    } else {
        set commentLines {}
    }
    #puts \ncommentLines\n$commentLines\n\ncolumnLabels\n$columnLabels\n$dataRows 
    #parray dataAry
    return [list $commentLines $columnLabels [array get dataAry] $dataRows]
#~dd
# % file.read.tableInR
#
# commentLines
# # fileName = file.read.tableInR.txt
# # created on Mon Aug 06 11:25:57 AM EDT 2012
# # commandLineExecuted =
# # xBed.xPeriment labs xPeriment.hpc lssMAts 71 NA NA NA 5000 0 16 1901 n1
# #
# # ... the tabbed columns below can be read by packages in 'R'
# #
#
# columnLabels
# instanceID    solverID    nAsymp  runtime cntProbe    seedFirst
# dataAry(cntProbe)   = 1.62E+06 8.00E+06 8.15E+06 6.54E+06 1.53E+06 8.58E+06
# dataAry(instanceID) = xPeriment-071-lssMAts-0-0-1901 xPeriment-071-lssMAts-0-1-883122666 xPeriment-071-lssMAts-0-2-265548367 xPeriment-071-lssMAts-0-3-184112969 xPeriment-071-lssMAts-0-4-852790363 xPeriment-071-lssMAts-0-5-747761917
# dataAry(nAsymp)     = 71 71 71 71 71 71
# dataAry(runtime)    = 0.3 1.4 1.4 1.1 0.3 1.4
# dataAry(seedFirst)  = 1901 883122666 265548367 184112969 852790363 747761917
# dataAry(solverID)   = lssMAts-1901 lssMAts-1901 lssMAts-1901 lssMAts-1901 lssMAts-1901 lssMAts-1901
#
# % array set tmp [lindex [file.read.tableInR] 1]
# .. invoking file.read from file.read.tableInR
# % parray tmp
# tmp(cntProbe)   = seedFirst
# tmp(instanceID) = solverID
# tmp(nAsymp)     = runtime
# 
# % array set tmp [lindex [file.read.tableInR] 2]
# .. invoking file.read from file.read.tableInR
# % parray tmp
# tmp(cntProbe)   = 1.62E+06 8.00E+06 8.15E+06 6.54E+06 1.53E+06 8.58E+06
# tmp(instanceID) = xPeriment-071-lssMAts-0-0-1901 xPeriment-071-lssMAts-0-1-883122666 xPeriment-071-lssMAts-0-2-265548367 xPeriment-071-lssMAts-0-3-184112969 xPeriment-071-lssMAts-0-4-852790363 xPeriment-071-lssMAts-0-5-747761917
# tmp(nAsymp)     = 71 71 71 71 71 71
# tmp(runtime)    = 0.3 1.4 1.4 1.1 0.3 1.4
# tmp(seedFirst)  = 1901 883122666 265548367 184112969 852790363 747761917
# tmp(solverID)   = lssMAts-1901 lssMAts-1901 lssMAts-1901 lssMAts-1901 lssMAts-1901 lssMAts-1901
# % 
# % puts [lindex [file.read.tableInR] 3]
# .. invoking file.read from file.read.tableInR
# xPeriment-071-lssMAts-0-0-1901	lssMAts-1901	71	0.3	1.62E+06	1901
# xPeriment-071-lssMAts-0-1-883122666	lssMAts-1901	71	1.4	8.00E+06	883122666
# xPeriment-071-lssMAts-0-2-265548367	lssMAts-1901	71	1.4	8.15E+06	265548367
# xPeriment-071-lssMAts-0-3-184112969	lssMAts-1901	71	1.1	6.54E+06	184112969
# xPeriment-071-lssMAts-0-4-852790363	lssMAts-1901	71	0.3	1.53E+06	852790363
# xPeriment-071-lssMAts-0-5-747761917	lssMAts-1901	71	1.4	8.58E+06	747761917
# %
# Copyright:
# Franc Brglez, Mon Aug  6 14:00:12 EDT 2012
#~dd
} ;# file.read.tableInR


proc file.read.tableInR_column { 
    {fileName B.solv-walks/gvc-sawCT-v-009-0014-truss-0017-1772472127-walk.txt}
    {columnName value}
    {ABOUT "..."}} {
        
    set thisCmd file.read.tableInR_column
    
    set rList [file.read.tableInR $fileName]
    set commentLines  [lindex $rList 0]
    set columnLabels  [lindex $rList 1]
    array set dataAry [lindex $rList 2]
    
    #parray dataAry
    set list4R "$columnName = c([join $dataAry($columnName) ,])"
    puts $list4R
    return $dataAry($columnName)
        
#~dd
# % file.read.tableInR_column B.solv-walks/gvc-sawCT-v-009-0014-truss-0017-1772472127-walk.txt  value
# .. invoking file.read from file.read.tableInR
# value = c(8,7,6,7,6,7,6,7,6,7,8,7,6,7,6,7,6,5)
# 8 7 6 7 6 7 6 7 6 7 8 7 6 7 6 7 6 5  
#     
# AUTHOR.DATE:
# Franc Brglez, Tue Dec 13 13:39:32 EST 2011
#~dd
} ;# 

proc file.insert.tableInR {
    {fileDir "xLib.00./tableInR./tmp51"}
    {firstColLabel "instanceID"}
    {addColPairs  "functionID labs.00 solverID 00.KL.100 nVar 51"}
    {outColLabels  "instanceID  functionID      solverID        nVar    valueBest
    solValueTarget      solStatus       timeSecs        cntProbe        cntRestart      coordBest"}
    {ABOUT "Reads a tabular file in R-format: returns commentLines
    and dataAry indexed with column labels from the table"} } {

    # get the list of files in target directory
    #set fileDir [file join [pwd] $fileDir]
    set fileList [glob -nocomplain [file join $fileDir *.txt]]
    puts fileDir\n$fileDir\nfileList\n$fileList ;# return
    foreach fileInp $fileList {
        puts fileInp=$fileInp
        set rList [file.read.tableInR $fileInp]
        set commentLines [lindex $rList 0]
        array set colAry [lindex $rList 1]
        #puts $commentLines ; parray colAry

        set nRows [llength $colAry($firstColLabel)]
        array set colPairs $addColPairs

        foreach label [array names colPairs] {
            set colAry($label) [string repeat "$colPairs($label) " $nRows]
        }
        #puts ..new.. ; parray colAry

        append commentLines \n \
          "\# The column pairs inserted are: $addColPairs \n\#\n"
        set rowLines $commentLines
        append rowLines [join $outColLabels \t]\n

        for {set row 0} {$row < $nRows} {incr row} {

            set rowLine ""
            foreach label $outColLabels {
                append rowLine [lindex $colAry($label) $row]\t
            }
            set rowLine [string trimright $rowLine "\t"]
            append rowLines $rowLine \n
        }
        #puts \n++++++++++rowLines\n$rowLines
        set fileOut [file rootname $fileInp]-ins.txt
        file.write $fileOut $rowLines
        puts ".. file $fileOut has been created"
    }
    return
#~dd
# % source xLib.00.tcl
# % file.insert.tableInR xLib.00./tableInR. instanceID "functionID labs.00 solverID KL02.1-1942n1 nVar 13" "instanceID functionID solverID nVar solStatus valueBest
#     timeSecs cntProbe cntRestart coordBest"
# .. file xLib.00./tableInR./n.013-labs.00-KL02.4-1942n1-0-ins.txt has been created
# .. file xLib.00./tableInR./n.013-labs.00-KL02.4-1942n1-1-ins.txt has been created
#
# % file.insert.tableInR xLib.00./tableInR. instanceID "functionID labs.00 solverID KL02.1-1942n1 nVar 27" "instanceID functionID solverID nVar solStatus valueBest
#     timeSecs cntProbe cntRestart coordBest"
# .. file xLib.00./tableInR./n.027-labs.00-KL02.4-1942n1-0-ins.txt has been created
# .. file xLib.00./tableInR./n.027-labs.00-KL02.4-1942n1-1-ins.txt has been created# %
#
# AUTHOR.DATE:
# Franc Brglez, Tue Dec 13 13:39:32 EST 2011
#~dd
} ;# file.insert.tableInR

proc file.read.tablePairs {
    {fileName "xLib.core./tablePairs.txt"}
    {ABOUT "Reads a tabular file of name-value pairs in R-format and returns
    dataAry indexed by name"} } {

    set allRows [split [file.read $fileName] \n]
    array unset dataAry
    foreach row $allRows {
        set firstChar [string index $row 0]
        if {$firstChar != "\#" && $firstChar != " " && $firstChar != {}} {
            set name [lindex $row 0]
            set value [lrange $row 1 end]
            set dataAry($name) $value
        }
    }
    return [array get dataAry]
#~dd
# % array set rAry [file.read.tablePairs xLib.core./tablePairs.txt]
# % parray rAry
# rAry(Id)             = NA
# rAry(args)           = {27 -T 37 -z 2 -stopping 0 -W 7 -S -id NA}
# rAry(cntProbeTot)    = 1490
# rAry(cntRestart)     = 10
# rAry(cntSteps)       = 246
# rAry(coordBest)      = 01111000100
# ...
#
# AUTHOR.DATE:
# Franc Brglez, Mon Mar 13 04:25:31 EDT 2012
#~dd
} ;# file.read.tablePairs