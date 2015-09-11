#2345 ** keep here as a 80-character reference line to check text width ** 67890

#   File: rLib.hasse.R
# Author: Franc Brglez  
#   Date: Thu Jan 22 16:07:41 EST 2015

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

plot.hasse = function(
    #fileDir      = "rLib/plot.hasse",
    fileDir      = ".",
    fileBase     = "P.lop.hasse-i-4-test-18",
    fileBaseWalk = "NONE",
    plotEdges    = TRUE,  plotTitle = FALSE, coordTextSize=1.05,
    coordType    = "P" , coordSize = 4, isLegend = FALSE,
    titleLine    = "",
    titleSub     = "",
    timeStamp    = "",
    ABOUT = "... reads a vertex file and an edge file of a complete/partial Hasse graph 
    and creates a projection onto the xy-plane of all vertices and edges in the file. 
    If fileBaseWalk is specified, this function also reads a *-walk.txt file and plots
    the walk. The walk file may be created manually or by a solver."
)
{
	thisFunction="plot.hasse"
	cat(sep="",  ".. entering R-function '", thisFunction, "'\n")
    # read the vertex file
	fileName = paste(sep="", fileDir, "/", fileBase, "-vertex.txt") 
	print(fileName)
	V = read.table(fileName, header=TRUE, sep = "\t", colClasses="character")
	#print(V)
    xVertex = as.double(V$coordX) ; yVertex = as.integer(V$coordY)
    xMax = max(xVertex) ;# maximum width of Hasse graph
    coordVertex   = V$coord       ; valueVertex = V$value
    nVertex = length(coordVertex) ; 
    
	# read the edge file
	fileName = paste(sep="", fileDir, "/", fileBase, "-edge.txt") 
	print(fileName)
	E = read.table(fileName, header=TRUE, sep = "\t", colClasses="character")
    #print(E)
	xEdge0 = as.double(E$coordX0) ; yEdge0 = as.integer(E$coordY0)
	xEdge1 = as.double(E$coordX1) ; yEdge1 = as.integer(E$coordY1)    
    nEdge = length(xEdge0) ; rankMax = max(yEdge1)
    #return()
    
    # initialize vertex labels (blank labels are induced when coordTextSize=0.)
    labels = NULL ; labelsWithBlank = NULL
    for (i in 1:length(coordVertex)) {
        if (is.na(valueVertex[i])) {valueVertex[i] = ""}
        labels = c(labels, paste(coordVertex[i],":",valueVertex[i], "\n\n", sep=""))
        #labels = c(labels, paste(valueVertex[i], "\n\n", sep=""))
    }
    for (i in 1:length(str)) {
        labelsWithBlank = c(labelsWithBlank, paste(coordVertex[i],"","   ", "\n", sep=""))
    }
    #--Define title and axis labels:
    if (titleSub == "") {
        titleSub = paste("This image created in R by", thisFunction)
    }
    if (fileBaseWalk == "") {
		title = paste(sep="", "fileBase = ", fileBase, "\n(", titleSub, ")")
	} else {
	    title = paste(sep="", "fileBase = ", fileBaseWalk, "-walk", "\n(", titleSub, ")")
	}
	
    xLabel = paste(sep="",  "Hasse graph parameters: maximum width = ", max(xVertex),
    		", maximum rank = ", max(yVertex) - min(yVertex), 
    		"; \n vertices = ", nVertex, ", edges = ", nEdge)
    # plot all vertices, given vertex XY coordinates
    op = par(mar=c(5,4,4,1.1) +0.2, lab=c(5, 5, 7)) ;# controlling minimum margins
    #xVertex = c(xVertex) ;  yVertex = c(yVertex) ; 
    eps = 0.2

    #NOTE: we cannot enter titleSub as "variable", it must be "hardwired",
    # e.g. title = paste(sep="", "fileBase = '", fileBase, "'", "\n(", titleSub, ")")
    yLabel  = paste("Rank values of vertices relative to the bottom vertex")
    if (plotTitle) {
		plot(x=c(1-eps,max(xVertex)+eps), y=c(min(yVertex)-eps,max(yVertex)+eps), cex=0.0,
			main=title, xlab=xLabel, ylab=yLabel, axes = FALSE)
	} else {
		plot(x=c(1-eps,max(xVertex)+eps), y=c(min(yVertex)-eps,max(yVertex)+eps), cex=0.0,
			xlab=xLabel, ylab=yLabel, axes = FALSE)
	}
    points(xVertex, yVertex,  pch=16, col = "red", cex=1.75)
    axis(1, at=seq(0           , max(xVertex), 1)) ; 
    axis(2, at=seq(min(yVertex), max(yVertex), 1))
    #axis(2, at=seq(2,4))
    #title(main=title)
    #box()
    par(op)
      
    # plot all edges, given vertex XY coordinates
    if (plotEdges) {
		# draw all graph edges between the vertices
		# choose lwd = 2 or 3 when needed (line width)
		for (i in 1:length(xEdge0)) {
			segments(xEdge0[i], yEdge0[i], xEdge1[i], yEdge1[i], col = 'pink', lwd = 1)
			#cat(xEdge0[i], yEdge0[i], xEdge1[i], yEdge1[i] ,"\n")
		}
	}
	     
    # draw the labels above each vertex in existing plot
    if (coordTextSize > 0.0) {
        # cex controls textsize: cex=0.75 allows spacing for coord:value=01010:27
        # use cex=0.75 as reasonable value, try 1.05 also
        #coordTextSize = 1.05
        text(xVertex, yVertex, labels, cex=coordTextSize)
    } else {
        labelTmp = NULL
        labelTmp = c(labelTmp, paste(coordVertex[1],":",valueVertex[1], "\n", sep=""))
        labelTmp = c(labelTmp, paste(coordVertex[length(coordVertex)],":",
                    valueVertex[length(coordVertex)], "\n", sep=""))
        # draw the labels above each vertex in existing plot
        # cex controls textsize: cex=0.75 allows spacing for coord;value=01010;27
        # use cex=0.75 as reasonable value, try 1.05 also
        #coordTextSize = 1.05
        xTmp = c(xVertex[1], xVertex[length(xVertex)])
        yTmp = c(yVertex[1], yVertex[length(yVertex)])
        text(xTmp, yTmp, labelTmp, cex=coordTextSize)
    }

	
    # read the walk file (conditionally)
    if (fileBaseWalk != "") {
        fileName = paste(sep="", fileDir, "/", fileBaseWalk, "-walk.txt") 
	    print(fileName)
	    Mwalk = read.table(fileName, header=TRUE, sep = "\t", colClasses="character")
	    print(Mwalk)
	    walkStep  = as.integer(Mwalk$step)
	    walkSegm = as.integer(Mwalk$segment)
	    walkCoord = Mwalk$coord
	    walkValue = as.double(Mwalk$value)
	    #filePdf  = paste(sep="", fileDir, "/", fileBaseWalk, "-walkHG.pdf")
    }
    print(coordVertex)
    
    #stop("stopping execution of code in this file: ", thisFile)

	# *.pdf is not possible until R-issue with dev.copy2pdf is resolved!!
	#dev.copy2pdf(file=filePdf)
	#dev.off()  ;# uncomment to supress an automatic display of pdf file
	#msg = cat(sep="", "** file ", filePdf, " has been created **", "\n")
	#return(msg)

    if (fileBaseWalk == "") {
    	dev.copy2pdf(file=filePdf)
	    #dev.off()  ;# uncomment to supress an automatic display of pdf file
		cat(sep="",  ".... exiting  R-function '", thisFunction, "'\n")
		return()
    }
	# draw directed edges induced by edges in the walk file
    jj = 1 ; walkLength = length(walkCoord) - 1
	for (step in 1:walkLength) {
		jj = step + 1
		isTransition = FALSE
		if ((walkSegm[jj] - walkSegm[jj-1]) ==  1) {isTransition = TRUE} 
        if (walkSegm[jj] <= 4) {
			if (walkSegm[jj] == 0)  {color = "blue"   ; lty=1 ; linewidth = 1.75}
			if (walkSegm[jj] == 1)  {color = "red"    ; lty=2 ; linewidth = 2.25}
			if (walkSegm[jj] == 2)  {color = "green"  ; lty=1 ; linewidth = 2.25}
			if (walkSegm[jj] == 3)  {color = "brown"  ; lty=2 ; linewidth = 2.25}
			if (walkSegm[jj] == 4)  {color = "black"  ; lty=1 ; linewidth = 2.25}
		} else {
			if ((walkSegm[jj] %% 2) == 1) {
				{color = "red"   ; lty=1 ; linewidth = 2.25}
			} else {
				{color = "blue"  ; lty=2 ; linewidth = 2.25}
			}
		}
		i0 = which(coordVertex == walkCoord[jj-1])
		i1 = which(coordVertex == walkCoord[jj])
		if (!isTransition) {
			arrows(xVertex[i0], yVertex[i0],  xVertex[i1], yVertex[i1], col=color, 
			length=0.15, angle=15, code =2, lty=lty, lwd=linewidth)
			label = paste(step-1,"\n\n\n\n", sep="")
			text(xVertex[i0], yVertex[i0], label, cex=1.1)
		}
	}
	if (isLegend) {
		#--Add legend:
		legendList = NULL
		legendList  = c(legendList, "Walk Segments")
		legendList  = c(legendList, "Segm 0 = solid blue")
		legendList  = c(legendList, "Segm 1 = dotted red")
		legendList  = c(legendList, "Segm 2 = solid green")
		legendList  = c(legendList, "Segm ? = etc...")
		legend("bottomright", legend = legendList[1:5], ncol = 1, bty = "n")
	}

	#dev.copy2pdf(file=filePdf)
	#dev.off()  ;# uncomment to supress an automatic display of pdf file
	cat(sep="",  ".. exiting  R-function '", thisFunction, "'\n")
	return()
}

plot.walkXY = function(
    coordType     = "B",
    fileDir       = ".",
    fileBaseWalk  = "i-32-0080-B.hasse-05-0,5-labsS-13-HG",
    coordTextSize = 0.75, plotWalk = TRUE, plotLegend = TRUE, plotTitle = FALSE,
    titleLine="",
    titleSub="",
    timeStamp = "",
    ABOUT = "... reads a walk file with extension -walkXY.txt, creates a hasseGraph
    projection in the xy-plane and then plots the walk only on vertices defined in
    the walk file."
)
{
	thisFunction="plot.walkXY"
    # timeStamp may occasionally extend some of the labels or filenames
    dateLine = paste(date())
    if (timeStamp != "") {
        timeStamp   = paste(strsplit(paste(format(Sys.time(), "%Y %m %d %H %M %S")),
                " ")[[1]], collapse="")
    }
    cat(sep="",  ".. entering R-function '", thisFunction, "'\n")

    # read the walk file
    fileName = paste(sep="", fileBaseWalk, "-walkXY.txt")
    filePath = paste(sep="", fileDir, "/", fileName)
    T = read.table(filePath, header=TRUE, sep = "\t", colClasses="character")
    print(T)
    step   = as.integer(T$step)  ; segment  = as.integer(T$segment)
    coordVertex   = T$coord             ; valueVertex   = as.double(T$value)
    xVertex   = as.double(T$coordX) ; yVertex   = as.double(T$coordY)

    print(segment) ; print(step) ; print(coordVertex) ; print(valueVertex) ; print(xVertex) ; print(yVertex)
    walkLength = length(coordVertex) - 1
    # get dice face labels for each vertex (coord;value pairs)
    cat(coordVertex,"\n", valueVertex,"\n")
    labels = NULL ; labelsWithBlank = NULL
    for (i in 1:length(coordVertex)) {
        labels = c(labels, paste(coordVertex[i],":",valueVertex[i], "\n", sep=""))
    }
    for (i in 1:length(str)) {
        labelsWithBlank = c(labelsWithBlank, paste(coordVertex[i],"","   ", "\n", sep=""))
    }

    # plot all vertices, given vertex XY coordinates
    op = par(mar=c(5,4,4,1.1) +0.2) ;# controlling minimum margins
    xVertex = c(xVertex) ;  yVertex = c(yVertex) ; eps = 0.2

   #NOTE: we cannot enter titleSub as "variable", it must be "hardwired",
    # e.g. title = paste(sep="", "fileBase = '", fileBase, "'", "\n(", titleSub, ")")
    #--Define title and axis labels:
    if (titleSub == "") {
        titleSub = paste("This image created in R by", thisFunction)
    }
    if (titleLine == "" && titleSub == "") {
		title = paste(sep="", "fileBase = ", fileBaseWalk, "-walkXY",
		"\n(", titleSub, ")")
	} 
    xLabel = paste(sep="", "A grid projection of vertices and vertex labels, selected dynamically
    during the walk, from the underlying Hasse graph")
        
    yLabel  = paste("Hasse rank distance from the initial coordinate (the bottom vertex)")
    if (plotTitle) {
        plot(x=c(0-eps,max(xVertex)+eps), y=c(0-eps,max(yVertex)+eps), cex=0.0,
             main=title, xlab=xLabel, ylab=yLabel )
    } else {
        plot(x=c(0-eps,max(xVertex)+eps), y=c(0-eps,max(yVertex)+eps), cex=0.0,
             xlab=xLabel, ylab=yLabel )
    }
    points(xVertex, yVertex,  pch=16, col = "red", cex=1.75)
    #axis(1, at=seq(0, max(xVertex), 1)) ; axis(2, at=seq(0, max(yVertex), 2))
    #title(main=title)
    #box()
    par(op)

    if (coordTextSize > 0.0) {
        # draw labels above each vertex in existing plot
        # cex controls textsize: cex=0.75 allows spacing for coord;value=01010;27
        # use cex=0.75 as reasonable value, try 1.05 also
        #coordTextSize = 1.05
        text(xVertex, yVertex, labels, cex=coordTextSize)

    } else {
        # draw abels above only above the the top and the bottom vertex
        labelTmp = NULL
        labelTmp = c(labelTmp, paste(coordVertex[1],":",valueVertex[1], "\n", sep=""))
        labelTmp = c(labelTmp, paste(coordVertex[length(coordVertex)],":",valueVertex[length(coordVertex)],
        "\n", sep=""))
        # draw the labels above each vertex in existing plot
        # cex controls textsize: cex=0.75 allows spacing for coord;value=01010;27
        # use cex=0.75 as reasonable value, try 1.05 also
        coordTextSize = 1.05
        xTmp = c(xVertex[1], xVertex[length(xVertex)])
        yTmp = c(yVertex[1], yVertex[length(yVertex)])
        text(xTmp, yTmp, labelTmp, cex=coordTextSize)
    }
    #return()
    if (plotWalk == FALSE) {
		cat(sep="",  ".. exiting  R-function '", thisFunction, "'\n")
		return()
    }
	# draw directed edges induced by edges in the walk file
    jj = 1
	for (step in 1:walkLength) {
		jj = step + 1
        if (segment[jj] <= 4) {
			if (segment[jj] == 0)  {color = "blue"   ; lty=1 ; linewidth = 1.75}
			if (segment[jj] == 1)  {color = "red"    ; lty=2 ; linewidth = 2.25}
			if (segment[jj] == 2)  {color = "green"  ; lty=1 ; linewidth = 2.25}
			if (segment[jj] == 3)  {color = "brown"  ; lty=2 ; linewidth = 2.25}
			if (segment[jj] == 4)  {color = "black"  ; lty=1 ; linewidth = 2.25}
		} else {
			if ((segment[jj] %% 2) == 1) {
				{color = "red"   ; lty=1 ; linewidth = 2.25}
			} else {
				{color = "blue"  ; lty=2 ; linewidth = 2.25}
			}
		}
		i0 = which(coordVertex == coordVertex[jj-1])
		i1 = which(coordVertex == coordVertex[jj])
		arrows(xVertex[i0], yVertex[i0],  xVertex[i1], yVertex[i1], col=color, length=0.15,
		angle=15, code =2, lty=lty, lwd=linewidth)
	}
    #--Add legend:
    if (plotLegend == TRUE) {
        legendList = NULL
		legendList  = c(legendList, "segment 0 = solid blue")
		legendList  = c(legendList, "segment 1 = dotted red")
		legendList  = c(legendList, "segment 2 = solid green")
		legendList  = c(legendList, "segment 3 = dotted brown")
		legendList  = c(legendList, "segment 4 = solid black")
		legendList  = c(legendList, "segment 5 = solid red")
		legendList  = c(legendList, "segment 6 = dotted blue")
		legendList  = c(legendList, "segment 7 = solid red")
		legendList  = c(legendList, "segment 8 = dotted blue")
		legendList  = c(legendList, "segment 9 = etc...")
		legend("bottomright", legend = legendList[1:10], ncol = 1, bty = "n")
	}
    #--Add text:
    ##walkLength = 27 ;# reported with lssMAts
    #text( 2, 1.5 , paste("coordType = B\ncoordDim = 11\ngraphVertices = 2^11\nwalkLength =", 
    #                      walkLength), cex = 1.1)

	# *.pdf is not possible until R-issue with dev.copy2pdf is resolved!!
	#dev.copy2pdf(file=filePdf)
	#dev.off()  ;# uncomment to supress an automatic display of pdf file
	#msg = cat(sep="", "** file ", filePdf, " has been created **", "\n")
	#return(msg)

	filePdf  = paste(sep="", fileDir, "/", fileBaseWalk, "-walkXY.pdf")
	dev.copy2pdf(file=filePdf)
	#dev.off()  ;# uncomment to supress an automatic display of pdf file
	cat(sep="",  ".. exiting  R-function '", thisFunction, "'\n")
	return()

} ;# plot.walkXY

# ext2#2345 ** keep here as a 80-character reference line to check text width ** 67890

#   File: r.hasse.R
# Author: Franc Brglez  
#   Date: Tue Apr 22 21:39:30 EDT 2014

#source("r.hasse.R")

# remove ALL objects
# rm(list = ls())

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



plot_hasse = function(
    coordType    = "B",
    fileDir      = "dice_test/hasse_archived",
    fileBase     = "n=013-B-2_labsS_hamilton-10000",
    fileBaseWalk = "n=013-B-2_labsS_hansel_13,bestFirstPivot-10000",
    plotEdges    = TRUE,  plotTitle = TRUE, coordTextSize=0.75,
    titleLine    = "",
    titleSub     = "",
    timeStamp    = "",
    ABOUT = "... reads a vertex file and an edge file of a complete Hasse graph and
    creates a projection onto the xy-plane of **all** vertices and edges. Optionally, if
    fileBaseWalk is specified, this function also reads a *-walk.txt file created by a
    solver and plots the walk."
)
{
	thisFunction="plot_hasse"
    # timeStamp may occasionally extend some of the labels or filenames
    dateLine = paste(date())
    if (timeStamp != "") {
        timeStamp   = paste(strsplit(paste(format(Sys.time(), "%Y %m %d %H %M %S")),
                " ")[[1]], collapse="")
    }
    cat(sep="",  ".. entering R-function '", thisFunction, "'\n")

    # read the vertex file
    fileVertex = paste(sep="", fileDir, "/", fileBase, "-vertex.txt") ;# print(fileVertex)
    Mvertex = read.table(fileVertex, header=TRUE, sep = "\t", colClasses="character")
    xVertex = as.double(Mvertex$coordX) ; yVertex = as.integer(Mvertex$coordY)
    coordVertex   = Mvertex$coord       ; valueVertex = as.double(Mvertex$value)
    tripletVertex = Mvertex$landscapeTriplet
    #l (coordVertex,"\n",valueVertex,"\n", triplet,"\n")

	# read the edge file
	fileEdge = paste(sep="", fileDir, "/", fileBase, "-edge.txt")
	Medge = read.table(fileEdge, header=TRUE, sep = "\t", colClasses="character")
	#print(Medge)
	xEdge0 = as.double(Medge$coordX0) ; yEdge0 = as.integer(Medge$coordY0)
	xEdge1 = as.double(Medge$coordX1) ; yEdge1 = as.integer(Medge$coordY1)

    # read the walk file (conditionally)
    if (fileBaseWalk != "") {
		fileWalk = paste(sep="", fileDir, "/", fileBaseWalk, "-walk.txt")
	    Mwalk = read.table(fileWalk, header=TRUE, sep = "\t", colClasses="character")
	    print(Mwalk)
	    walkStep  = as.integer(Mwalk$step)
	    walkSegm = as.integer(Mwalk$Segm)
	    walkCoord = Mwalk$coord
	    walkValue = as.double(Mwalk$value)
	    filePdf  = paste(sep="", fileDir, "/", fileBaseWalk, "-walkHG.pdf")
    } else {
        filePdf  = paste(sep="", fileDir, "/", fileBase, "-hasse.pdf")
    }
    # initialize vertex labels (blank labels are induced when coordTextSize=0.)
    labels = NULL ; labelsWithBlank = NULL
    for (i in 1:length(coordVertex)) {
        #labels = c(labels, paste(coordVertex[i],":",valueVertex[i],
        #          "\n\n", tripletVertex[i], sep=""))
        labels = c(labels, paste(coordVertex[i],":",valueVertex[i], "\n\n", sep=""))
    }
    for (i in 1:length(str)) {
        labelsWithBlank = c(labelsWithBlank, paste(coordVertex[i],"","   ", "\n", sep=""))
    }
    #--Define title and axis labels:
    if (titleSub == "") {
        titleSub = paste("This image created in R by", thisFunction)
    }
    if (fileBaseWalk == "") {
		title = paste(sep="", "fileBase = ", fileBase, "\n(", titleSub, ")")
	} else {
	    title = paste(sep="", "fileBase = ", fileBaseWalk, "-walk", "\n(", titleSub, ")")
	}
    # plot all vertices, given vertex XY coordinates
    op = par(mar=c(5,4,4,1.1) +0.2) ;# controlling minimum margins
    xVertex = c(xVertex) ;  yVertex = c(yVertex) ; eps = 0.2

    #NOTE: we cannot enter titleSub as "variable", it must be "hardwired",
    # e.g. title = paste(sep="", "fileBase = '", fileBase, "'", "\n(", titleSub, ")")
    yLabel  = paste("Hasse rank distance from the initial coordinate (the bottom vertex)")
    if (plotTitle) {
		plot(x=c(1-eps,max(xVertex)+eps), y=c(0-eps,max(yVertex)+eps), cex=0.0,
			main=title, xlab=xLabel, ylab=yLabel)
	} else {
		plot(x=c(1-eps,max(xVertex)+eps), y=c(0-eps,max(yVertex)+eps), cex=0.0,
			xlab=xLabel, ylab=yLabel)
	}
    points(xVertex, yVertex,  pch=16, col = "red", cex=1.75)
    #axis(1, at=seq(0, max(xVertex), 1)) ; axis(2, at=seq(0, max(yVertex), 2))
    #title(main=title)
    #box()
    par(op)

    # draw the labels above each vertex in existing plot
    if (coordTextSize > 0.0) {
        # cex controls textsize: cex=0.75 allows spacing for coord:value=01010:27
        # use cex=0.75 as reasonable value, try 1.05 also
        #coordTextSize = 1.05
        text(xVertex, yVertex, labels, cex=coordTextSize)
    } else {
        labelTmp = NULL
        labelTmp = c(labelTmp, paste(coordVertex[1],":",valueVertex[1], "\n", sep=""))
        labelTmp = c(labelTmp, paste(coordVertex[length(coordVertex)],":",
                    valueVertex[length(coordVertex)], "\n", sep=""))
        # draw the labels above each vertex in existing plot
        # cex controls textsize: cex=0.75 allows spacing for coord;value=01010;27
        # use cex=0.75 as reasonable value, try 1.05 also
        coordTextSize = 1.05
        xTmp = c(xVertex[1], xVertex[length(xVertex)])
        yTmp = c(yVertex[1], yVertex[length(yVertex)])
        text(xTmp, yTmp, labelTmp, cex=coordTextSize)
    }
    # plot all edges, given vertex XY coordinates
    if (plotEdges) {
		# draw all graph edges between the vertices
		# choose lwd = 2 or 3 when needed (line width)
		for (i in 1:length(xEdge0)) {
			segments(xEdge0[i], yEdge0[i], xEdge1[i], yEdge1[i], col = 'pink', lwd = 1)
			#cat(xEdge0[i], yEdge0[i], xEdge1[i], yEdge1[i] ,"\n")
		}
	}
	# *.pdf is not possible until R-issue with dev.copy2pdf is resolved!!
	#dev.copy2pdf(file=filePdf)
	#dev.off()  ;# uncomment to supress an automatic display of pdf file
	#msg = cat(sep="", "** file ", filePdf, " has been created **", "\n")
	#return(msg)

    if (fileBaseWalk == "") {
    	dev.copy2pdf(file=filePdf)
	    #dev.off()  ;# uncomment to supress an automatic display of pdf file
		cat(sep="",  ".... exiting  R-function '", thisFunction, "'\n")
		return()
    }
	# draw directed edges induced by edges in the walk file
    jj = 1 ; walkLength = length(walkCoord) - 1
	for (step in 1:walkLength) {
		jj = step + 1
		isTransition = FALSE
		if ((walkSegm[jj] - walkSegm[jj-1]) ==  1) {isTransition = TRUE} 
        if (walkSegm[jj] <= 4) {
			if (walkSegm[jj] == 0)  {color = "blue"   ; lty=1 ; linewidth = 1.75}
			if (walkSegm[jj] == 1)  {color = "red"    ; lty=2 ; linewidth = 2.25}
			if (walkSegm[jj] == 2)  {color = "green"  ; lty=1 ; linewidth = 2.25}
			if (walkSegm[jj] == 3)  {color = "brown"  ; lty=2 ; linewidth = 2.25}
			if (walkSegm[jj] == 4)  {color = "black"  ; lty=1 ; linewidth = 2.25}
		} else {
			if ((walkSegm[jj] %% 2) == 1) {
				{color = "red"   ; lty=1 ; linewidth = 2.25}
			} else {
				{color = "blue"  ; lty=2 ; linewidth = 2.25}
			}
		}
		i0 = which(coordVertex == walkCoord[jj-1])
		i1 = which(coordVertex == walkCoord[jj])
		#cat(step,jj-1,jj,walkSegm[jj],isTransition,i0,i1,"\n")
		if (!isTransition) {
			arrows(xVertex[i0], yVertex[i0],  xVertex[i1], yVertex[i1], col=color, 
			length=0.15, angle=15, code =2, lty=lty, lwd=linewidth)
		}
	}
    #--Add legend:
    legendList = NULL
    legendList  = c(legendList, "Walk Segments")
    legendList  = c(legendList, "Segm 0 = solid blue")
    legendList  = c(legendList, "Segm 1 = dotted red")
    legendList  = c(legendList, "Segm 2 = solid green")
    legendList  = c(legendList, "Segm ? = etc...")
    legend("bottomright", legend = legendList[1:5], ncol = 1, bty = "n")

	dev.copy2pdf(file=filePdf)
	#dev.off()  ;# uncomment to supress an automatic display of pdf file
	cat(sep="",  ".. exiting  R-function '", thisFunction, "'\n")
	return()

} ;# plot_hasse

plot_walkXY = function(
    coordType     = "B",
    fileDir       = "dice_test/hasse",
    fileBaseWalk  = "n=013-B-2_labsS_hansel_13,bestFirstPivot-10000",
    coordTextSize = 0.75, plotWalk = TRUE, plotLegend = TRUE, plotTitle = TRUE,
    titleLine="",
    titleSub="",
    timeStamp = "",
    ABOUT = "... reads a walk file with extension -walkXY.txt, creates a hasseGraph
    projection in the xy-plane and then plots the walk only on vertices defined in
    the walk file."
)
{
	thisFunction="plot_walkXY"
    # timeStamp may occasionally extend some of the labels or filenames
    dateLine = paste(date())
    if (timeStamp != "") {
        timeStamp   = paste(strsplit(paste(format(Sys.time(), "%Y %m %d %H %M %S")),
                " ")[[1]], collapse="")
    }
    cat(sep="",  ".. entering R-function '", thisFunction, "'\n")

    # read the walk file
    fileName = paste(sep="", fileBaseWalk, "-walkXY.txt")
    filePath = paste(sep="", fileDir, "/", fileName)
    T = read.table(filePath, header=TRUE, sep = "\t", colClasses="character")
    print(T)
    step   = as.integer(T$step)  ; segment  = as.integer(T$segment)
    coordVertex   = T$coord             ; valueVertex   = as.double(T$value)
    xVertex   = as.double(T$coordX) ; yVertex   = as.double(T$coordY)

    print(segment) ; print(step) ; print(coordVertex) ; print(valueVertex) ; print(xVertex) ; print(yVertex)
    walkLength = length(coordVertex) - 1
    # get dice face labels for each vertex (coord;value pairs)
    cat(coordVertex,"\n", valueVertex,"\n")
    labels = NULL ; labelsWithBlank = NULL
    for (i in 1:length(coordVertex)) {
        labels = c(labels, paste(coordVertex[i],":",valueVertex[i], "\n", sep=""))
    }
    for (i in 1:length(str)) {
        labelsWithBlank = c(labelsWithBlank, paste(coordVertex[i],"","   ", "\n", sep=""))
    }

    # plot all vertices, given vertex XY coordinates
    op = par(mar=c(5,4,4,1.1) +0.2) ;# controlling minimum margins
    xVertex = c(xVertex) ;  yVertex = c(yVertex) ; eps = 0.2

   #NOTE: we cannot enter titleSub as "variable", it must be "hardwired",
    # e.g. title = paste(sep="", "fileBase = '", fileBase, "'", "\n(", titleSub, ")")
    #--Define title and axis labels:
    if (titleSub == "") {
        titleSub = paste("This image created in R by", thisFunction)
    }
    if (titleLine == "" && titleSub == "") {
		title = paste(sep="", "fileBase = ", fileBaseWalk, "-walkXY",
		"\n(", titleSub, ")")
	} 
    xLabel = paste(sep="", "A grid projection of vertices and vertex labels, selected dynamically
    during the walk, from the underlying Hasse graph (coordType = ", coordType,")")
        
    yLabel  = paste("Hasse rank distance from the initial coordinate (the bottom vertex)")
    if (plotTitle) {
        plot(x=c(0-eps,max(xVertex)+eps), y=c(0-eps,max(yVertex)+eps), cex=0.0,
             main=title, xlab=xLabel, ylab=yLabel )
    } else {
        plot(x=c(0-eps,max(xVertex)+eps), y=c(0-eps,max(yVertex)+eps), cex=0.0,
             xlab=xLabel, ylab=yLabel )
    }
    points(xVertex, yVertex,  pch=16, col = "red", cex=1.75)
    #axis(1, at=seq(0, max(xVertex), 1)) ; axis(2, at=seq(0, max(yVertex), 2))
    #title(main=title)
    #box()
    par(op)

    if (coordTextSize > 0.0) {
        # draw labels above each vertex in existing plot
        # cex controls textsize: cex=0.75 allows spacing for coord;value=01010;27
        # use cex=0.75 as reasonable value, try 1.05 also
        #coordTextSize = 1.05
        text(xVertex, yVertex, labels, cex=coordTextSize)

    } else {
        # draw abels above only above the the top and the bottom vertex
        labelTmp = NULL
        labelTmp = c(labelTmp, paste(coordVertex[1],":",valueVertex[1], "\n", sep=""))
        labelTmp = c(labelTmp, paste(coordVertex[length(coordVertex)],":",valueVertex[length(coordVertex)],
        "\n", sep=""))
        # draw the labels above each vertex in existing plot
        # cex controls textsize: cex=0.75 allows spacing for coord;value=01010;27
        # use cex=0.75 as reasonable value, try 1.05 also
        coordTextSize = 1.05
        xTmp = c(xVertex[1], xVertex[length(xVertex)])
        yTmp = c(yVertex[1], yVertex[length(yVertex)])
        text(xTmp, yTmp, labelTmp, cex=coordTextSize)
    }
    #return()
    if (plotWalk == FALSE) {
		cat(sep="",  ".. exiting  R-function '", thisFunction, "'\n")
		return()
    }
	# draw directed edges induced by edges in the walk file
    jj = 1
	for (step in 1:walkLength) {
		jj = step + 1
        if (segment[jj] <= 4) {
			if (segment[jj] == 0)  {color = "blue"   ; lty=1 ; linewidth = 1.75}
			if (segment[jj] == 1)  {color = "red"    ; lty=2 ; linewidth = 2.25}
			if (segment[jj] == 2)  {color = "green"  ; lty=1 ; linewidth = 2.25}
			if (segment[jj] == 3)  {color = "brown"  ; lty=2 ; linewidth = 2.25}
			if (segment[jj] == 4)  {color = "black"  ; lty=1 ; linewidth = 2.25}
		} else {
			if ((segment[jj] %% 2) == 1) {
				{color = "red"   ; lty=1 ; linewidth = 2.25}
			} else {
				{color = "blue"  ; lty=2 ; linewidth = 2.25}
			}
		}
		i0 = which(coordVertex == coordVertex[jj-1])
		i1 = which(coordVertex == coordVertex[jj])
		arrows(xVertex[i0], yVertex[i0],  xVertex[i1], yVertex[i1], col=color, length=0.15,
		angle=15, code =2, lty=lty, lwd=linewidth)
	}
    #--Add legend:
    if (plotLegend == TRUE) {
        legendList = NULL
		legendList  = c(legendList, "segment 0 = solid blue")
		legendList  = c(legendList, "segment 1 = dotted red")
		legendList  = c(legendList, "segment 2 = solid green")
		legendList  = c(legendList, "segment 3 = dotted brown")
		legendList  = c(legendList, "segment 4 = solid black")
		legendList  = c(legendList, "segment 5 = solid red")
		legendList  = c(legendList, "segment 6 = dotted blue")
		legendList  = c(legendList, "segment 7 = solid red")
		legendList  = c(legendList, "segment 8 = dotted blue")
		legendList  = c(legendList, "segment 9 = etc...")
		legend("bottomright", legend = legendList[1:10], ncol = 1, bty = "n")
	}
    #--Add text:
    ##walkLength = 27 ;# reported with lssMAts
    #text( 2, 1.5 , paste("coordType = B\ncoordDim = 11\ngraphVertices = 2^11\nwalkLength =", 
    #                      walkLength), cex = 1.1)

	# *.pdf is not possible until R-issue with dev.copy2pdf is resolved!!
	#dev.copy2pdf(file=filePdf)
	#dev.off()  ;# uncomment to supress an automatic display of pdf file
	#msg = cat(sep="", "** file ", filePdf, " has been created **", "\n")
	#return(msg)

	filePdf  = paste(sep="", fileDir, "/", fileBaseWalk, "-walkXY.pdf")
	dev.copy2pdf(file=filePdf)
	#dev.off()  ;# uncomment to supress an automatic display of pdf file
	cat(sep="",  ".. exiting  R-function '", thisFunction, "'\n")
	return()

} ;# plot_walkXY

plot_hasse_graph = function(
    fileDir = "_hasse_graph_4R_tmp",
    fileBase = "labs-13-21-01111",
    plotType = "hasse",
    solverMethod = "",
    seedBottom = NA,
    titleSub= "",
    coordType = "B", functionName = "labs",functionFactors="",
    coordTextSize = 0.75,
    pdf_plotFile = "",
    timeStamp = "",
    ABOUT = "... later"
)
{
    # plot_hasse_graph(fileBase= "test07_v-005-B-index_11110", plotType = "_walk", solverMethod="xKL")
    #--colors:
    #col=c("black", "red", "blue", "brown", "black",
    #    "violet", "green", "orange", "black")
    # pie(rep(1,8), col=col) ;# to view these colors
    # colors() ;# for full list of colors

    #-- symbols
    # example("pch") ;# ... click through for more details
    #pch = c(10, 18, 17, 20, 19, 16, 7, 8, 9, 15, 11, 12, 13, 14)
    #cexS = 1.5
    #cex = c(cexS, cexS, cexS, cexS, cexS, cexS, cexS, cexS, cexS,
    #    cexS, cexS, cexS, cexS)
    # alternate choices
    #pch = c(10, 12, 8, 4, 5, 16, 7, 6, 9, 15, 11, 18, 13, 14)

    thisFunction="plot_hasse_graph"
    # timeStamp may occasionally extend some of the labels or filenames
    dateLine = paste(date())
    if (timeStamp != "") {
        timeStamp   = paste(strsplit(paste(format(Sys.time(), "%Y %m %d %H %M %S")),
                " ")[[1]], collapse="")
    }
    cat(sep="",  ".. entering R-function '", thisFunction, "'\n")
    # read the vertex file
    fileTable = paste(sep="", fileDir, "/", fileBase, "_vertex.txt")
    T = read.table(fileTable, header=TRUE, sep = "\t", colClasses="character")

    # get x-y coordinates for each vertex
    xAll = as.double(T$x) ; yAll = as.integer(T$y)
    #print(xAll) ; print(yAll) ; print(max(yAll))

    # get dice face labels for each vertex
    str = T$coord ; val = as.double(T$value) ; labels = NULL
    labelsWithBlank = NULL
    for (i in 1:length(str)) {
        labels = c(labels, paste(str[i],";",val[i], "\n", sep=""))
    }
    for (i in 1:length(str)) {
        labelsWithBlank = c(labelsWithBlank, paste(str[i],";","   ", "\n", sep=""))
    }

    #--Define title and axis labels:
    if (titleSub == "") {
        titleSub = paste("coordType=", coordType, ", functionName=", functionName)
    }
    title = paste(sep="", thisFunction, " of '", fileBase, "'",
        "\n(", titleSub, ")")
    #### old titleLine below
#     bottomFace = paste(str[1], ";", val[1], sep="")
#     if (titleLine == "") {
#         titleLine = paste(sep="", "coordType=", coordType, ", functionName=", functionName,
#         ", bottomFace=", bottomFace)
#     }
#     if(solverMethod == "") {
#         title = paste(sep="", thisFunction, " of '", fileBase, "'",
#         "\n(", titleLine, ")")
#     } else {
#         title = paste(sep="", solverMethod, " walk in '", fileBase, "'",
#             ", seedBottom=", seedBottom, "\n(", titleLine, ")")
#     }
    if (coordType == "B") {
        ylab  = paste("Hasse rank distance from the bottom face of the dice")
        xlab  = paste("vertices and labels are ordered L -> R by function values","\n",
                      "(for coordType=B, vertex distribution at each rank is binomial)")
    }
    if  (coordType == "P") {
        ylab  = paste("Hasse rank distance from the bottom face of the dice")
        xlab  = paste("vertices and labels are ordered L -> R by function values","\n",
                      "(for coordType=P, vertex distribution at each rank is Mahonian)")
    }
    if (coordType == "H2") {
        ylab  = paste("Hasse rank distance from the bottom face of the dice")
        xlab  = paste("vertices and labels are ordered L -> R by function values","\n",
                      "(The vertex distribution at each Hasse rank distance is a product of binomial and Mahonian distributions)")
        #xlab  = paste("vertices and labels are ordered L -> R by function values","\n",
        #            "(here, vertex distribution at each rank is a product of binomial and Mahonian)")
    }
    # plot all vertices, given file coordinates
    op = par(mar=c(5,4,4,1.1) +0.2) ;# controlling minimum margins
    xAll = c(xAll) ;  yAll = c(yAll) ; eps = 0.2

    #NOTE: cannot enter titleSub as "variable", it must be "hardwired",
    #      e.g. sub ="some text"
    plot(x=c(1-eps,max(xAll)+eps), y=c(0,max(yAll)), cex=0.0,
        main=title, xlab=xlab, ylab=ylab)

    #plot(xAll, yAll, type="n", pch=16, col = "pink", cex=1.75,
    #    main=title, sub=titleSub, xlab=xlab, ylab=ylab)

    points(xAll, yAll,  pch=16, col = "red", cex=1.75)
    #axis(1, at=seq(0, max(xAll), 1))
    #axis(2, at=seq(0, max(yAll), 2))
    #title(main=title)
    #box()
    par(op)

    # read the edgeList file
    fileTable = paste(sep="", fileDir,  "/", fileBase, "_edge.txt")
    Te = read.table(fileTable, header=TRUE, sep = "\t", colClasses="character")
    #print(Te)
    x0 = as.double(Te$x0) ; y0 = as.integer(Te$y0)
    x1 = as.double(Te$x1) ; y1 = as.integer(Te$y1)
    # draw all graph edges between the nodes
    # choose lwd = 2 or 3 when needed (line width)
    for (i in 1:length(x0)) {
        segments(x0[i], y0[i], x1[i], y1[i], col = "pink", lwd = 1)
    }

    if (plotType == "hasse") {
        # draw the labels above each vertex in existing plot
        # cex controls textsize: cex=0.75 allows spacing for coord;value=01010;27
        # use cex=0.75 as reasonable value, try 1.05 also
        #coordTextSize = 1.05
        text(xAll, yAll, labels, cex=coordTextSize)

        # _hasse.pdf is not possible until R-issue with dev.copy2pdf is
        # resolved!!
        #file_pdf = paste(sep="", fileDir, "/", fileBase, "_hasse.pdf")
        file_pdf = paste(sep="", fileDir, "/", fileBase, "_", plotType, ".pdf")
        dev.copy2pdf(file=file_pdf)
        #dev.off()  ;# uncomment to supress an automatic display of pdf file
        #msg = cat(sep="", "** file ", file_pdf, " has been created **",
        #        "\n", ".. exiting the function", thisFunction, "\n")
        #return(msg)
    }
    if (plotType == "hasseBlank") {
        # draw the labels above each vertex in existing plot
        # cex controls textsize: cex=0.75 allows spacing for coord;value=01010;27
        # use cex=0.75 as reasonable value, try 1.05 also
        #coordTextSize = 1.05
        text(xAll, yAll, labelsWithBlank, cex=coordTextSize)

        # _hasse.pdf is not possible until R-issue with dev.copy2pdf is
        # resolved!!
        #file_pdf = paste(sep="", fileDir, "/", fileBase, "_hasse.pdf")
        file_pdf = paste(sep="", fileDir, "/", fileBase, "_", plotType, ".pdf")
        dev.copy2pdf(file=file_pdf)
        #dev.off()  ;# uncomment to supress an automatic display of pdf file
        #msg = cat(sep="", "** file ", file_pdf, " has been created **",
        #        "\n", ".. exiting the function", thisFunction, "\n")
        #return(msg)
    }
    cat(sep="",  ".. exiting  R-function '", thisFunction, "'\n")

    if (plotType == "walk_hamilton") {
         # draw the directed edges induced by edges in the walk file
        fileTable = paste(sep="", fileDir, "/", fileBase,
            "_", solverMethod, plotType, ".txt")
        Tw = read.table(fileTable, header=TRUE, sep = "\t", colClasses="character")
        #print(Tw)
        y0w = as.integer(Tw$y0)
        x0w = as.double(Tw$x0)
        y1w = as.integer(Tw$y1)
        x1w = as.double(Tw$x1)

        for (i in 1:length(y0w)) {
            arrows(x0w[i], y0w[i], x1w[i], y1w[i], col = "blue",
                   length = 0.15, angle = 15, code = 2, lwd = 1.5)
       }
       file_pdf = paste(sep="", fileDir, "/", fileBase,  "_", plotType, ".pdf")
       dev.copy2pdf(file=file_pdf)
       #dev.off()  ;# uncomment to supress an automatic display of pdf file
   }
   if (regexpr("walk", plotType) && solverMethod != "") {
       plotLabel = paste(sep="", "_", seedBottom, "_", plotType, "_", solverMethod)

       probeTable = paste(sep="", fileDir, "/", fileBase,
           "_", seedBottom, "_probe_", solverMethod, ".txt")
       Tw = read.table(probeTable, header=TRUE, sep = "\t", colClasses="character")
       #print(Tw)

       # get the "probed" x-y coordinates for each vertex
       xAll = as.double(Tw$x) ; yAll = as.integer(Tw$y) ; chProbe = as.double(Tw$segment)
       #print(xAll) ; print(yAll) ; print(chProbe)


       # create "lists" for xSegm and ySegm
       # code below is simplistic and hardwired -- consider a re-write later
       xSegm1 = NULL ; ySegm1 = NULL
       xSegm2 = NULL ; ySegm2 = NULL
       xSegm3 = NULL ; ySegm3 = NULL
       for (i in 1:length(yAll)) {
           x = xAll[i] ; y = yAll[i]
           if (chProbe[i] == -1)  {break}
           if (chProbe[i] == 0)  {
               xSegm1 = c(xSegm1, x)
               ySegm1 = c(ySegm1, y)
           }
           if (chProbe[i] == 1)  {
               xSegm2 = c(xSegm2, x)
               ySegm2 = c(ySegm2, y)
           }
           if (chProbe[i] == 2)  {
               xSegm3 = c(xSegm3, x)
               ySegm3 = c(ySegm3, y)
           }
       }
       #print(xSegm1) ; print(ySegm1) ; print(xSegm2) ; print(ySegm2)
       if (exists("xSegm1"))  {
           pch=17 ; col = "blue"  ; cex=1.75
           points(xSegm1, ySegm1,  pch=pch, col = col, cex=cex)
       }
       if (exists("xSegm2"))  {
           pch=18 ; col = "black" ; cex=1.75
           points(xSegm2, ySegm2,  pch=pch, col = col, cex=cex)
       }
       #return()

       # draw the directed edges induced by edges in the walk file
       fileTable = paste(sep="", fileDir, "/", fileBase, plotLabel, ".txt")
       Tw = read.table(fileTable, header=TRUE, sep = "\t", colClasses="character")
       #print(Tw)
       y0w = as.integer(Tw$y0)
       x0w = as.double(Tw$x0)
       y1w = as.integer(Tw$y1)
       x1w = as.double(Tw$x1)
       segment = as.double(Tw$segment)

       for (i in 1:length(y0w)) {
           if (segment[i] == -1) {color = "white"  ; lty=1 ; linewidth = 0.0}
           if (segment[i] == 0)  {color = "blue"   ; lty=1 ; linewidth = 1.75}
           if (segment[i] == 1)  {color = "black"  ; lty=2 ; linewidth = 2.25}
           arrows(x0w[i], y0w[i], x1w[i], y1w[i], col = color,
               length = 0.15, angle = 15, code = 2, lty=lty, lwd = linewidth)
       }
       if (pdf_plotFile == "") {
           file_pdf = paste(sep="", fileDir, "/", fileBase,  plotLabel, ".pdf")
       } else {
           file_pdf == pdf_plotFile
       }
       dev.copy2pdf(file=file_pdf)
       #dev.off()  ;# uncomment to supress an automatic display of pdf file
   }
} ;# plot_hasse_graph
