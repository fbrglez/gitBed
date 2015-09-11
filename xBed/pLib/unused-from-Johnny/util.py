import pprint

def table_info_variables( fileName="../../../xBed/pLib/util_data/B.lightp.info_variables.txt" ):
    ABOUT = (
        "This proc takes a file *info_variables.txt and returns two "
        "dictionaries: all_info and all_valu. Both are indexed with the same "
        "variable names; the dict all_info associates with default values, "
        "and the dict all_valu associates with brief variable descriptions. "
        "Both arrays are needed to\n(1) generate a response to user's query "
        "about the command line\n(2) initialize all variables under the "
        "procedure *init"
        )

    thisProc = "table_info_variables"

    rList = []
    with open(fileName) as f:
        for line in f:
            firstChar = line[0]
            if firstChar != "#" and len(line) > 0:
                rList.append(line.split())

    all_info = {}
    all_valu = {}
    for line in rList:
        if line:
            varName = line[0]
            varDefault = line[1]
            varInfo = " ".join(line[2:])

            if varName in all_info:
                all_info[varName].append(varInfo)
            else:
                all_info[varName] = [varInfo]
            all_valu[varName] = varDefault

    return (all_info, all_valu)

def prettyPrint(object):
    ABOUT = (
             "This proc pretty prints a dictionary."
             )
        
    thisProc = "prettyPrint"
             
    pp = pprint.PrettyPrinter(indent=4)
    pp.pprint(object)

def customPrint(front = "", middle = "", dict = {}):
    ABOUT = (
             "This proc custom prints a dictionary with a given front, middle, and dictionary"
             "Ex. customPrint(\"Key \", \" = \", dictionary)"
             )
        
    thisProc = "customPrint"
    
    for key in sorted(dict):
        print front + str(key) + middle, dict[key]

if __name__ == "__main__":
    table_info_variables("B.lightp.info_variables.txt")
