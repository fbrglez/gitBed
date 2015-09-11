#2345 ** keep here as a 80-character reference line to check text width ** 67890

#   File: rLib.graph.R
# Author: Franc Brglez  
#   Date: Thu Jul  9 10:26:06 EDT 2015

# remove ALL objects
# rm(list = ls())
# thisFile = "rLib.hasse.R"
#source("rLib.hasse.R")

# to display all functions under set/mark file button in AlphaX
#  (1) pull-down S+/R (2) select "Mark R file as Source"

NOTES = function()
# Placeholder for NOTES (collapsible in BBedit)
{
# WARNING when reading column names in R-table:
#     e.g. colName=c("nDim", "meanV", "semV", "sampleSize", "group.1"),
#     here, the name with a period such as "group.1" will throw an error
#
# > file = ""
# > header = paste(sep="", "# line1 etc1","\n","# line2 etc etc")
# > y =c(1:21)
# > write(header, "")
# # line1 etc1
# # line2 etc etc
# > write(y, "", ncolumns= 7, sep="\t", append=T)
# 1 2   3   4   5   6   7
# 8 9   10  11  12  13  14
# 15    16  17  18  19  20  21
# >
}

plot.graph = function(
    fileDir      = "rLib.graph",
    #fileDir      = ".",
    fileBase     = "i-10-0015-Peterson-C",
    #fileBase     = "i-4-05-wheel",
    plotEdges    = TRUE,  plotTitle = FALSE, coordTextSize=1.05,
    titleLine    = "",
    titleSub     = "",
    timeStamp    = "",
    ABOUT = "... reads an edge file of a graph, places all vertices onto a unit circle 
    and draws edges between vertices.  See also
    https://en.wikibooks.org/wiki/R_Programming/Text_Processing"
)
{
	thisFunction="plot.graph"
	cat(sep="",  ".. entering R-function '", thisFunction, "'\n")
    # read the edge file
	fileName = paste(sep="", fileDir, "/", fileBase, ".edge") 
	print(fileName)
	#allLines = read.table(fileName, header=TRUE, sep = "\t", colClasses="character")
    #print(allLines)
    textLines = scan(fileName, character(0), sep = "\n") # separate each word and line
    print(textLines)

    eList = NULL
    tt <- as.Token_Tokenizer(wordpunct_tokenizer)
    for (i in 1:length(textLines) ) {
        #print(i) ; print(textLines[i]) ;# print(tt(textLines[i]))
        tokens = tt(textLines[i])
        if (length(tokens) > 1) { ;# NEEDED TO AVOID INVALID CODE
        	key  = tokens[1] 
        	if (key == "e") {
        		u = as.integer(tokens[2])
        		v = as.integer(tokens[3])
        		eList = c(eList, c(u, v))
        	}
        	if (key == "p") {
        		nVertex = as.integer(tokens[3])
        		nEdge   = as.integer(tokens[4])
        	}
        }
    }
    print(eList)
    vList = NULL ; vLabels = NULL 
    for (i in 1: nVertex) {
    	vList   = c(nVertex, i)
        vLabels = c(vLabels, paste(i, sep=""))
    }
    #vList = sort(unique(eList))
    if (length(vList) != nVertex) {
    	#print("ERROR ...") ;# complement graph can have unconnected vertices
    	#return()
    }
    if (length(eList) != 2*nEdge) {
    	print("ERROR ...")
    	return()
    }  
    #NOTE: we cannot enter titleSub as "variable", it must be "hardwired",
    # e.g. title = paste(sep="", "fileBase = '", fileBase, "'", "\n(", titleSub, ")")
    yLabel  = paste("Rank values of vertices relative to the bottom vertex")
    if (plotTitle) {
		plot(x=0, y=0, cex=0.0,
			main=title, xlab="", ylab="", axes = FALSE)
	} else {
		plot(x=0, y=0, cex=0.0,
			xlab="", ylab="", axes = FALSE)
	}
    # prepare coordinates to place vertices and edges
    alpha = (2*pi/nVertex)*seq(0,nVertex-1)
	x = -cos(alpha) ; print(x)
	y =  sin(alpha) ; print(y)

	# draw all graph edges between the vertices
	# choose lwd = 2 or 3 when needed (line width)
	for (i in 1:(length(eList)/2)) {
	    u = eList[2*i - 1] ; v = eList[2*i]
		segments(x[u], y[u], x[v], y[v] , col = 'pink', lwd = 2)
		cat("e=", i, "\n") ; cat(u, v, "\n") ; cat(x[u], y[u], x[v], y[v] , "\n")
	}
	# place vertices	
	points(x, y,  pch=21, col = "black", bg="white", cex=3.5)	
	
    # use cex=0.75 as reasonable value, try 1.05 also
    #coordTextSize = 1.05
    text(x, y, vLabels, cex=coordTextSize)
        
    #return()    	 

} ;# plot.graph

