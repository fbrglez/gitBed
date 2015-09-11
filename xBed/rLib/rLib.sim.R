#2345 ** keep here as a 80-character reference line to check text width ** 67890

#   File: rLib.sim.R
# Author: Franc Brglez  
#   Date: Mon Mar 24 21:03:01 EDT 2014

#source("rLib.sim.R")
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
#source("rLib.sim.R")

sim.asymptotic2 = function(
    xAsymp   = c(13, 21, 27, 41, 43, 45, 51),
    refMean1 = c(1377,4515,11000,87863,118229,159089,387603),
    refMean2 = c(1070,4601,13737,176373,253977,365726,1092053),
    refMean3 = c(819,4580,16648,338267,520119,799735,2907207),
    coefVar  = 1.0, sampleSize = 10, seed = 1215,
    xRange   = c(10, 60), yRange=c(1, 1e8),
    plotScatter = T,
    ABOUT = "..."
    )
{
    if (seed < 1000) {
        set.seed(seed)
        cat("  sampleSize = ", sampleSize, "  seed = ", seed, "\n")
    } else {
        cat("  sampleSize = ", sampleSize, "  seed = ", "RANDOM", "\n")
    }
    if (coefVar < 1) {
        isNormal = TRUE ; distribution = paste(sep="", "NORMAL, coefVar =", coefVar)
        cat("distribution = ", distribution, "\n")
    } else {
        isNormal = FALSE ; distribution = paste(sep="", "EXPONENTIAL, coefVar =", coefVar)
        cat("distribution = ", distribution, "\n")
    }
        cat("\n*** mu-values from which we generate data for asymptotic model ***
        > x  = c(13, 21, 27, 41, 43, 45, 51)
        [1] 13 21 27 41 43 45 51
         > y1 = 200*1.160^x
         [1] '1377'   '4515'   '11000'  '87863'  '118229' '159089' '387603'
         > y2 = 100*1.200^x
         [1] '1070'    '4601'    '13737'   '176373'  '253977'  '365726'  '1092053'
         > y3 =  50*1.240^x
         [1] '819'     '4580'    '16648'   '338267'  '520119'  '799735'  '2907207'
         \n")

    refSigma1    = NULL ; refSigma2  = NULL ; refSigma3  = NULL
    sampleMean1  = NULL ; sampleSD1 = NULL ; sampleSE1 = NULL
    sampleMean2  = NULL ; sampleSD2 = NULL ; sampleSE2 = NULL
    sampleMean3  = NULL ; sampleSD3 = NULL ; sampleSE3 = NULL
    xList        = NULL ;
    yList1     = NULL ; yList2     = NULL    ; yList3     = NULL

    nAsymp = length(xAsymp)
	for (i in 1:nAsymp) {

		if (isNormal) {
			Mu1 = refMean1[i] ; Sigma1 = coefVar*Mu1
			Mu2 = refMean2[i] ; Sigma2 = coefVar*Mu2
			Mu3 = refMean3[i] ; Sigma3 = coefVar*Mu3
			refSigma1 = c(refSigma1, Sigma1) ; refSigma2 = c(refSigma2, Sigma2)
			refSigma3 = c(refSigma3, Sigma3)
			variates1 = rnorm(sampleSize, Mu1, Sigma1)
			variates2 = rnorm(sampleSize, Mu2, Sigma2)
			variates3 = rnorm(sampleSize, Mu3, Sigma2)
		} else {
			Mu1 = refMean1[i] ; Sigma1 = Mu1
			Mu2 = refMean2[i] ; Sigma2 = Mu2
			Mu3 = refMean3[i] ; Sigma3 = Mu3
			refSigma1 = c(refSigma1, Sigma1) ; refSigma2 = c(refSigma2, Sigma2)
			refSigma3 = c(refSigma3, Sigma3)
			variates1 = rexp(sampleSize, 1/Mu1)
			variates2 = rexp(sampleSize, 1/Mu2)
			variates3 = rexp(sampleSize, 1/Mu3)
		}
		for (j in (1:sampleSize)) {xList = c(xList, xAsymp[i])}
		yList1 = c(yList1, variates1)
		yList2 = c(yList2, variates2)
		yList3 = c(yList3, variates3)

		sampleMean1 = c(sampleMean1, mean(variates1))
		sampleSD1   = c(sampleSD1,   sd(variates1))
		sampleSE1   = c(sampleSE1,   sd(variates1)/(sqrt(sampleSize)))
		sampleMean2 = c(sampleMean2, mean(variates2))
		sampleSD2   = c(sampleSD2,   sd(variates2))
		sampleSE2   = c(sampleSE2,   sd(variates2)/(sqrt(sampleSize)))
		sampleMean3 = c(sampleMean3, mean(variates3))
		sampleSD3   = c(sampleSD3,   sd(variates3))
		sampleSE3   = c(sampleSE3,   sd(variates3)/(sqrt(sampleSize)))
	}

	#print(head(cbind(xList, yList1, yList2, yList3)))
	#cat("....", "\n","....", "\n")
	#print(tail(cbind(xList, yList1, yList2, yList3)))
	#cat("....", "\n","....", "\n")


	sampleGroupSize = length(xList)

    cat("\n****************************\nLINEAR REGRESSION MODEL \n")
    cat("seed = ", seed, " sampleSize = ", sampleSize, " sampleGroupSize = ", sampleGroupSize, "\n")
    model1 = lm(log10(yList1) ~ xList) ;# print(model1)
    print(coef(summary(model1)))
    model2 = lm(log10(yList2) ~ xList) ;# print(model2)
    print(coef(summary(model2)))
    model3 = lm(log10(yList3) ~ xList) ;# print(model3)
    print(coef(summary(model3)))

    a1 = 10^coef(model1)[1]
    b1 = 2^(coef(model1)[2]/log10(2))
    a2 = 10^coef(model2)[1]
    b2 = 2^(coef(model2)[2]/log10(2))
    a3 = 10^coef(model3)[1]
    b3 = 2^(coef(model3)[2]/log10(2))
    cat("model1(x) = ", formatC(a1, digits=2, format="f"), "* (",
                        formatC(b1, digits=4, format="f"), ")^x","\n")
    cat("model2(x) = ", formatC(a2, digits=2, format="f"), "* (",
                        formatC(b2, digits=4, format="f"), ")^x","\n")
    cat("model3(x) = ", formatC(a3, digits=2, format="f"), "* (",
                        formatC(b3, digits=4, format="f"), ")^x","\n")


    cat("\n****************************\nNON-LINEAR REGRESSION MODEL \n")
    cat("seed = ", seed, " sampleSize = ", sampleSize, " sampleGroupSize = ", sampleGroupSize, "\n")
    model1 = nls(log10(yList1) ~  log10(a1) + xList*(log10(b1)), start = c(a1=10, b1=1.5))
    print(coef(summary(model1)))
        model2 = nls(log10(yList2) ~  log10(a2) + xList*(log10(b2)), start = c(a2=10, b2=1.5))
    print(coef(summary(model2)))
        model3 = nls(log10(yList3) ~  log10(a3) + xList*(log10(b3)), start = c(a3=10, b3=1.5))
    print(coef(summary(model3)))
    return()
} ;# sim.asymptotic2

sim.asymptotic.sampleMean = function(
    xAsymp   = c(13, 21, 27, 41, 43, 45, 51),
    refMean1 = c(1377,4515,11000,87863,118229,159089,387603),
    refMean2 = c(1070,4601,13737,176373,253977,365726,1092053),
    refMean3 = c(819,4580,16648,338267,520119,799735,2907207),
    coefVar  = 1.0, sampleSize = 10, seed = 1215,
    xRange   = c(10, 60), yRange=c(1, 1e8),
    plotScatter = T,
    ABOUT = "..."
    )
{
    if (seed < 1000) {
        set.seed(seed)
        cat("  sampleSize = ", sampleSize, "  seed = ", seed, "\n")
    } else {
        cat("  sampleSize = ", sampleSize, "  seed = ", "RANDOM", "\n")
    }
    if (coefVar < 1) {
        isNormal = TRUE ; distribution = paste(sep="", "NORMAL, coefVar =", coefVar)
        cat("distribution = ", distribution, "\n")
    } else {
        isNormal = FALSE ; distribution = paste(sep="", "EXPONENTIAL, coefVar =", coefVar)
        cat("distribution = ", distribution, "\n")
    }
    refSigma1     = NULL ; refSigma2  = NULL ; refSigma3  = NULL
    sampleMean1  = NULL ; sampleSD1 = NULL ; sampleSE1 = NULL
    sampleMean2  = NULL ; sampleSD2 = NULL ; sampleSE2 = NULL
    sampleMean3  = NULL ; sampleSD3 = NULL ; sampleSE3 = NULL
    xList         = NULL ;
    yList1     = NULL ; yList2     = NULL    ; yList3     = NULL

    nAsymp = length(xAsymp)
	for (i in 1:nAsymp) {

		if (isNormal) {
				Mu1 = refMean1[i] ; Sigma1 = coefVar*Mu1
				Mu2 = refMean2[i] ; Sigma2 = coefVar*Mu2
				Mu3 = refMean3[i] ; Sigma3 = coefVar*Mu3
				refSigma1 = c(refSigma1, Sigma1) ; refSigma2 = c(refSigma2, Sigma2)
				refSigma3 = c(refSigma3, Sigma3)
				variates1 = rnorm(sampleSize, Mu1, Sigma1)
				variates2 = rnorm(sampleSize, Mu2, Sigma2)
				variates3 = rnorm(sampleSize, Mu3, Sigma2)
		} else {
				Mu1 = refMean1[i] ; Sigma1 = Mu1
				Mu2 = refMean2[i] ; Sigma2 = Mu2
				Mu3 = refMean3[i] ; Sigma3 = Mu3
				refSigma1 = c(refSigma1, Sigma1) ; refSigma2 = c(refSigma2, Sigma2)
				refSigma3 = c(refSigma3, Sigma3)
				variates1 = rexp(sampleSize, 1/Mu1)
				variates2 = rexp(sampleSize, 1/Mu2)
				variates3 = rexp(sampleSize, 1/Mu3)
		}
		for (j in (1:sampleSize)) {xList = c(xList, xAsymp[i])}
		yList1 = c(yList1, variates1)
		yList2 = c(yList2, variates2)
		yList3 = c(yList3, variates3)

		sampleMean1 = c(sampleMean1, mean(variates1))
		sampleSD1   = c(sampleSD1,   sd(variates1))
		sampleSE1   = c(sampleSE1,   sd(variates1)/(sqrt(sampleSize)))
		sampleMean2 = c(sampleMean2, mean(variates2))
		sampleSD2   = c(sampleSD2,   sd(variates2))
		sampleSE2   = c(sampleSE2,   sd(variates2)/(sqrt(sampleSize)))
		sampleMean3 = c(sampleMean3, mean(variates3))
		sampleSD3   = c(sampleSD3,   sd(variates3))
		sampleSE3   = c(sampleSE3,   sd(variates3)/(sqrt(sampleSize)))
	}
	
	sampleSize = length(xList)
	cat("sampleSize = ", length(xList), "\n")
	print(head(cbind(xList, yList1, yList2, yList3)))
	cat("....", "\n","....", "\n")
	print(tail(cbind(xList, yList1, yList2, yList3)))
	cat("....", "\n","....", "\n")
	
	print(xAsymp)
	print(sampleMean1)
	print(sampleMean2)
	print(cbind(xAsymp, refMean1, sampleMean1, refMean2, sampleMean2, refMean3, 
	           sampleMean3))
	
	#return()

	model1 = lm(log10(yList1) ~ xAsymp) ;# print(model1)
	model2 = lm(log10(yList2) ~ xAsymp) ;# print(model2)
	model3 = lm(log10(yList3) ~ xAsymp) ;# print(model3)
	
		plot(xAsymp, sampleMean1, col="black",  pch=1, cex=2.9,
			 xlim = xRange, ylim = yRange, log="y",
			 xlab = "Asymptotic x-values", ylab = "Combined yLists")
		abline(model1, col="black")
		abline(model2, col="red")
		return()

    a1 = 10^coef(model1)[1]
    b1 = 2^(coef(model1)[2]/log10(2))
    a2 = 10^coef(model2)[1]
    b2 = 2^(coef(model2)[2]/log10(2))
    a3 = 10^coef(model3)[1]
    b3 = 2^(coef(model3)[2]/log10(2))

    modelMean1 = a1*b1^xAsymp
    modelMean2 = a2*b2^xAsymp
    modelMean3 = a3*b3^xAsymp

    #par(op)
    if (plotScatter) {
		#plot(xList, yList1, type="p", col=1, xlim = xRange, ylim = yRange, log="y",
		#    xlab = "Combined xLists", ylab = "Combined sample")
		#points(xList, yList2, type="p", col=5)
		plot(xList, yList1, col="black",  pch=1, cex=1.1, xlim = xRange, ylim = yRange, log="y",
			 xlab = "Asymptotic x-values", ylab = "Combined sample")
		points(xList, yList2, col="red",  pch=5, cex=1.1,)
		abline(model1, col="black")
		abline(model2, col="red")
	} else {
		plot(xAsymp, sampleMean1, col="black",  pch=1, cex=2.9,
			 xlim = xRange, ylim = yRange, log="y",
			 xlab = "Asymptotic x-values", ylab = "Combined yLists")
		abline(model1, col="black")
		abline(model2, col="red")
	}
    points(xAsymp, sampleMean2, col="red",  pch=5, cex=2.9)

    points(xAsymp, modelMean1, col="black",  pch=20, cex=2.9)
    points(xAsymp, modelMean2, col="red",    pch=18, cex=2.5)

    points(xAsymp, refMean1, col="black",    pch=4, cex=1.1)
    points(xAsymp, refMean2, col="red",      pch=8, cex=2.1)

    #--Add legend:
        legend("topleft", inset=0.02, pch = c(1, 20, 4, 5, 18, 8), cex=1.2,
			col = c(
					"black", # sampleMean1
					"black", # modelMean1
					"black", # refMean1
					"red",   # sampleMean2
					"red",   # modelMean2
					"red"    # refMean2
					),
			legend = c("sampleMean1", "modelMean1 (f1)", "refMean1",
					   "sampleMean2", "modelMean2 (f2)", "refMean2" ))
        textLines = paste(sep="",
            "f1(x) = ", formatC(a1, digits=2, format="f"), "*(",
                        formatC(b1, digits=4, format="f"), ")^x","\n",
         "f2(x) = ", formatC(a2, digits=2, format="f"), "*(",
                        formatC(b2, digits=4, format="f"), ")^x","\n",
            "The distribution is \n",
            distribution, "\n",
            "sampleSize = ", sampleSize, "\n",
            "seedInit = ", seed)
    text(50, 35, textLines , cex = 1.0)

    cat("\n")
	print(rbind(xAsymp,
	refMean1, refSigma1, refMean2, refSigma2, refMean3, refSigma3,
	modelMean1, modelMean2, modelMean3,
	sampleMean1, sampleSD1, sampleSE1,
	sampleMean2, sampleSD2, sampleSE2,
	sampleMean3, sampleSD3, sampleSE3))
	cat("\n")
    cat("model1(x) = ", formatC(a1, digits=2, format="f"), "* (",
                        formatC(b1, digits=4, format="f"), ")^x","\n")
    print(coef(summary(model1)))
    cat("model2(x) = ", formatC(a2, digits=2, format="f"), "* (",
                        formatC(b2, digits=4, format="f"), ")^x","\n")
    cat("model3(x) = ", formatC(a3, digits=2, format="f"), "* (",
                        formatC(b3, digits=4, format="f"), ")^x","\n")

     ##------ create a file of all variates
    fileAsymptotic = paste(sep="", "asymptotic_simulation_merged_", sampleSize, ".txt")
    instanceID = paste(sep="", "i", 1:sampleSize)
    solverID  = "solverA"
    nAsymp  = xList
    runtime = formatC(yList1,digits=2, format="f")
    cntProbe = formatC(10*yList1,digits=0, format="f")

	results  = data.frame(cbind(instanceID, solverID), nAsymp,
									   runtime, cntProbe)
	write.table(results, file=fileAsymptotic,
							quote=F, sep="\t", append = F,
							col.names=T, row.names=F)
    solverID  = "solverB"
    nAsymp  = xList
    runtime = formatC(yList2,digits=2, format="f")
    cntProbe = formatC(10*yList2,digits=0, format="f")

	results  = data.frame(cbind(instanceID, solverID), nAsymp,
									   runtime, cntProbe)

	write.table(results, file=fileAsymptotic,
							quote=F, sep="\t", append = T,
							col.names=F, row.names=F)

	solverID  = "solverC"
    nAsymp  = xList
    runtime = formatC(yList3,digits=2, format="f")
    cntProbe = formatC(10*yList3,digits=0, format="f")

	results  = data.frame(cbind(instanceID, solverID), nAsymp,
									   runtime, cntProbe)

	write.table(results, file=fileAsymptotic,
							quote=F, sep="\t", append = T,
							col.names=F, row.names=F)

} ;# sim.asymptotic.sampleMean

sim.asymptotic.ensembleMean = function(
    xAsymp   = c(13, 21, 27, 41, 43, 45, 51),
    refMean1 = c(1377,4515,11000,87863,118229,159089,387603),
    refMean2 = c(1070,4601,13737,176373,253977,365726,1092053),
    refMean3 = c(819,4580,16648,338267,520119,799735,2907207),
    coefVar  = 1.0, sampleSize = 10, seed = 1215,
    xRange   = c(10, 60), yRange=c(1, 1e8),
    plotScatter = T,
    ABOUT = "..."
    )
{
    if (seed < 1000) {
        set.seed(seed)
        cat("  sampleSize = ", sampleSize, "  seed = ", seed, "\n")
    } else {
        cat("  sampleSize = ", sampleSize, "  seed = ", "RANDOM", "\n")
    }
    if (coefVar < 1) {
        isNormal = TRUE ; distribution = paste(sep="", "NORMAL, coefVar =", coefVar)
        cat("distribution = ", distribution, "\n")
    } else {
        isNormal = FALSE ; distribution = paste(sep="", "EXPONENTIAL, coefVar =", coefVar)
        cat("distribution = ", distribution, "\n")
    }
    refSigma1     = NULL ; refSigma2  = NULL ; refSigma3  = NULL
    sampleMean1  = NULL ; sampleSD1 = NULL ; sampleSE1 = NULL
    sampleMean2  = NULL ; sampleSD2 = NULL ; sampleSE2 = NULL
    sampleMean3  = NULL ; sampleSD3 = NULL ; sampleSE3 = NULL
    xList         = NULL ;
    yList1     = NULL ; yList2     = NULL    ; yList3     = NULL

    nAsymp = length(xAsymp)
	for (i in 1:nAsymp) {

		if (isNormal) {
				Mu1 = refMean1[i] ; Sigma1 = coefVar*Mu1
				Mu2 = refMean2[i] ; Sigma2 = coefVar*Mu2
				Mu3 = refMean3[i] ; Sigma3 = coefVar*Mu3
				refSigma1 = c(refSigma1, Sigma1) ; refSigma2 = c(refSigma2, Sigma2)
				refSigma3 = c(refSigma3, Sigma3)
				variates1 = rnorm(sampleSize, Mu1, Sigma1)
				variates2 = rnorm(sampleSize, Mu2, Sigma2)
				variates3 = rnorm(sampleSize, Mu3, Sigma2)
		} else {
				Mu1 = refMean1[i] ; Sigma1 = Mu1
				Mu2 = refMean2[i] ; Sigma2 = Mu2
				Mu3 = refMean3[i] ; Sigma3 = Mu3
				refSigma1 = c(refSigma1, Sigma1) ; refSigma2 = c(refSigma2, Sigma2)
				refSigma3 = c(refSigma3, Sigma3)
				variates1 = rexp(sampleSize, 1/Mu1)
				variates2 = rexp(sampleSize, 1/Mu2)
				variates3 = rexp(sampleSize, 1/Mu3)
		}
		for (j in (1:sampleSize)) {xList = c(xList, xAsymp[i])}
		yList1 = c(yList1, variates1)
		yList2 = c(yList2, variates2)
		yList3 = c(yList3, variates3)

		sampleMean1 = c(sampleMean1, mean(variates1))
		sampleSD1   = c(sampleSD1,   sd(variates1))
		sampleSE1   = c(sampleSE1,   sd(variates1)/(sqrt(sampleSize)))
		sampleMean2 = c(sampleMean2, mean(variates2))
		sampleSD2   = c(sampleSD2,   sd(variates2))
		sampleSE2   = c(sampleSE2,   sd(variates2)/(sqrt(sampleSize)))
		sampleMean3 = c(sampleMean3, mean(variates3))
		sampleSD3   = c(sampleSD3,   sd(variates3))
		sampleSE3   = c(sampleSE3,   sd(variates3)/(sqrt(sampleSize)))
	}
	sampleSize = length(xList)
	cat("sampleSize = ", length(xList), "\n")
	print(head(cbind(xList, yList1, yList2, yList3)))
	cat("....", "\n","....", "\n")
	print(tail(cbind(xList, yList1, yList2, yList3)))
	cat("....", "\n","....", "\n")

	model1 = lm(log10(yList1) ~ xList) ;# print(model1)
	model2 = lm(log10(yList2) ~ xList) ;# print(model2)
	model3 = lm(log10(yList3) ~ xList) ;# print(model3)

    a1 = 10^coef(model1)[1]
    b1 = 2^(coef(model1)[2]/log10(2))
    a2 = 10^coef(model2)[1]
    b2 = 2^(coef(model2)[2]/log10(2))
    a3 = 10^coef(model3)[1]
    b3 = 2^(coef(model3)[2]/log10(2))

    modelMean1 = a1*b1^xAsymp
    modelMean2 = a2*b2^xAsymp
    modelMean3 = a3*b3^xAsymp

    #par(op)
    if (plotScatter) {
		#plot(xList, yList1, type="p", col=1, xlim = xRange, ylim = yRange, log="y",
		#    xlab = "Combined xLists", ylab = "Combined sample")
		#points(xList, yList2, type="p", col=5)
		plot(xList, yList1, col="black",  pch=1, cex=1.1, xlim = xRange, ylim = yRange, log="y",
			 xlab = "Asymptotic x-values", ylab = "Combined sample")
		points(xList, yList2, col="red",  pch=5, cex=1.1,)
		abline(model1, col="black")
		abline(model2, col="red")
	} else {
		plot(xAsymp, sampleMean1, col="black",  pch=1, cex=2.9,
			 xlim = xRange, ylim = yRange, log="y",
			 xlab = "Asymptotic x-values", ylab = "Combined yLists")
		abline(model1, col="black")
		abline(model2, col="red")
	}
    points(xAsymp, sampleMean2, col="red",  pch=5, cex=2.9)

    points(xAsymp, modelMean1, col="black",  pch=20, cex=2.9)
    points(xAsymp, modelMean2, col="red",    pch=18, cex=2.5)

    points(xAsymp, refMean1, col="black",    pch=4, cex=1.1)
    points(xAsymp, refMean2, col="red",      pch=8, cex=2.1)

    #--Add legend:
        legend("topleft", inset=0.02, pch = c(1, 20, 4, 5, 18, 8), cex=1.2,
			col = c(
					"black", # sampleMean1
					"black", # modelMean1
					"black", # refMean1
					"red",   # sampleMean2
					"red",   # modelMean2
					"red"    # refMean2
					),
			legend = c("sampleMean1", "modelMean1 (f1)", "refMean1",
					   "sampleMean2", "modelMean2 (f2)", "refMean2" ))
        textLines = paste(sep="",
            "f1(x) = ", formatC(a1, digits=2, format="f"), "*(",
                        formatC(b1, digits=4, format="f"), ")^x","\n",
         "f2(x) = ", formatC(a2, digits=2, format="f"), "*(",
                        formatC(b2, digits=4, format="f"), ")^x","\n",
            "The distribution is \n",
            distribution, "\n",
            "sampleSize = ", sampleSize, "\n",
            "seedInit = ", seed)
    text(50, 35, textLines , cex = 1.0)

    cat("\n")
	print(rbind(xAsymp,
	refMean1, refSigma1, refMean2, refSigma2, refMean3, refSigma3,
	modelMean1, modelMean2, modelMean3,
	sampleMean1, sampleSD1, sampleSE1,
	sampleMean2, sampleSD2, sampleSE2,
	sampleMean3, sampleSD3, sampleSE3))
	cat("\n")
    cat("model1(x) = ", formatC(a1, digits=2, format="f"), "* (",
                        formatC(b1, digits=4, format="f"), ")^x","\n")
    print(coef(summary(model1)))
    cat("model2(x) = ", formatC(a2, digits=2, format="f"), "* (",
                        formatC(b2, digits=4, format="f"), ")^x","\n")
    cat("model3(x) = ", formatC(a3, digits=2, format="f"), "* (",
                        formatC(b3, digits=4, format="f"), ")^x","\n")

     ##------ create a file of all variates
    fileAsymptotic = paste(sep="", "asymptotic_simulation_merged_", sampleSize, ".txt")
    instanceID = paste(sep="", "i", 1:sampleSize)
    solverID  = "solverA"
    nAsymp  = xList
    runtime = formatC(yList1,digits=2, format="f")
    cntProbe = formatC(10*yList1,digits=0, format="f")

	results  = data.frame(cbind(instanceID, solverID), nAsymp,
									   runtime, cntProbe)
	write.table(results, file=fileAsymptotic,
							quote=F, sep="\t", append = F,
							col.names=T, row.names=F)
    solverID  = "solverB"
    nAsymp  = xList
    runtime = formatC(yList2,digits=2, format="f")
    cntProbe = formatC(10*yList2,digits=0, format="f")

	results  = data.frame(cbind(instanceID, solverID), nAsymp,
									   runtime, cntProbe)

	write.table(results, file=fileAsymptotic,
							quote=F, sep="\t", append = T,
							col.names=F, row.names=F)

	solverID  = "solverC"
    nAsymp  = xList
    runtime = formatC(yList3,digits=2, format="f")
    cntProbe = formatC(10*yList3,digits=0, format="f")

	results  = data.frame(cbind(instanceID, solverID), nAsymp,
									   runtime, cntProbe)

	write.table(results, file=fileAsymptotic,
							quote=F, sep="\t", append = T,
							col.names=F, row.names=F)

} ;# sim.asymptotic.ensembleMean