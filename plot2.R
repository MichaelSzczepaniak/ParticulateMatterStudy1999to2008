##
## Generates a stacked barplot of the total Baltimore city PM25 emissions by
## source type from 1999 through 2008.  For details see:
## https://github.com/MichaelSzczepaniak/ParticulateMatterStudy1999to2008
##
library(dplyr)
library(RColorBrewer)

## Summarize NEI data by year and type for Baltimore (fips = 24510)
getNeiSummary <- function(file = "summarySCC_PM25.rds", normalize = TRUE) {
    # save time if function has been executed already and NEI is in workspace
    if(!exists("NEI")) {
        NEI <- readRDS("summarySCC_PM25.rds")
    }
    neiByYear <- NULL
    if(normalize) {
        neiNormalized <- normalizeNEI(NEI)
        neiByYear <- group_by(neiNormalized, year, type)
    }
    else {
        neiByYear <- group_by(NEI, year, type)
    }
    neiByYear <- filter(neiByYear, fips == "24510")
    totalEmissions <- summarise(neiByYear,
                                TotalEmissions = sum(Emissions,
                                                     na.rm = TRUE))
    
    return(totalEmissions)
}

## Normalizes the records of the NEI dataframe by grabbing records with sources
## that are common across the years 1999, 2002, 2005, and 2008.
normalizeNEI <- function(nei) {
    nei1999 <- filter(nei, year == 1999)
    scc1999 <- unique(nei1999$SCC)
    nei2002 <- filter(nei, year == 2002)
    scc2002 <- unique(nei2002$SCC)
    nei2005 <- filter(nei, year == 2005)
    scc2005 <- unique(nei2005$SCC)
    nei2008 <- filter(nei, year == 2008)
    scc2008 <- unique(nei2008$SCC)
    sccCommon <- intersect(scc1999, scc2002)
    sccCommon <- intersect(sccCommon, scc2005)
    sccCommon <- intersect(sccCommon, scc2008)
    # sccCommon contains only the sources common to all 4 time periods
    normalizedNEI <- filter(nei, SCC %in% sccCommon)
    
    return(normalizedNEI)
}

## Creates a dataframe with values of zero for TotalEmissions
## used when filtering NEI returns no records for a given type
createZeroDf <- function(type) {
    dfZero <- data.frame(year = seq(1999, 2008, 3),
                         type = rep(type, 4),
                         TotalEmissions = c(0,0,0,0))
}

## Creates the matrix used to build the stack bars
## emission - the dataframe summarizing NEI by year, type, Total Emissions
getStackedBars <- function(emissions) {
    totEmPoint <- filter(emissions, type == "POINT")
    if(length(totEmPoint$type) == 0) {
        totEmPoint <- createZeroDf("POINT")
    }
    totEmNonPoint <- filter(emissions, type == "NONPOINT")
    if(length(totEmNonPoint$type) == 0) {
        totEmNonPoint <- createZeroDf("NONPOINT")
    }
    totEmOnRoad <- filter(emissions, type == "ON-ROAD")
    if(length(totEmOnRoad$type) == 0) {
        totEmOnRoad <- createZeroDf("ON-ROAD")
    }
    totEmNonRoad <- filter(emissions, type == "NON-ROAD")
    if(length(totEmNonRoad$type) == 0) {
        totEmNonRoad <- createZeroDf("NON-ROAD")
    }
    # build the matrix to be used for the stacked bar
    emByType <- select(totEmPoint, -type)
    emByType <- rename(emByType, pointEmissions = TotalEmissions)
    x <- totEmNonPoint$TotalEmissions
    emByType <- cbind(emByType, nonPointEmissions = x)
    x <- totEmOnRoad$TotalEmissions
    emByType <- cbind(emByType, onRoadEmissions = x)
    x <- totEmNonRoad$TotalEmissions
    emByType <- cbind(emByType, nonRoadEmissions = x)
    bars <- t(as.matrix(emByType))
    colnames(bars) <- bars[1, ]
    bars <- bars[c(2:5), ]
    
    return(bars)
}

## Creates 2 panel stacked bar plots: left plot is for all common sources,
## right plot is for all sources.  A single sequential color brewer pallette
## was used for both plots.
## file - output plot file: a png of width x height units (typically px)
## width - width of the output plot image in units of units (typically px)
## height - height of the output plot image in units of units (typically px)
## units - units for width and height: typically pixels (px)
## ymaxLeft - max value of the left plot y-axis
## ymaxRight - max value of the right plot y-axis
createPanelPlots2 <- function(file = "plot2.png", width = 720, height = 500,
                             units = "px", ymaxLeft = 4.0, ymaxRight = 4.0) {
    # create/write output png: 720 x 500 pixels
    png(file = file, width = width, height = height, units = units)
    par(mfrow = c(1, 2))
    # configure pieces for stacked bars for all sources panel
    totalEmissions <- getNeiSummary(normalize = FALSE)
    bars <- getStackedBars(totalEmissions)
    cnames <- c("POINT", "NONPOINT", "ON-ROAD", "NON-ROAD")
    barColors <- brewer.pal(4, "Accent")  # one of the SEQUENTIAL pallettes
    mainTitle <- paste0("Total Baltimore PM2.5 Emissions By Year & Type\n",
                        "(all sources)")
    barplot(bars/1000,
            names.arg = colnames(bars),
            ylab = "Emissions (1,000 tons PM25-PRI)",
            xlab = "Year",
            ylim = c(0, ymaxRight), xpd = FALSE,
            col = c(barColors[1], barColors[2], barColors[3], barColors[4]),
            main = mainTitle,
            legend = cnames)
    # configure pieces for stacked bars having sources common for each
    # reporting year
    totalEmissions <- getNeiSummary()
    bars <- getStackedBars(totalEmissions)
    # same names used as first panel plot
    # Uncomment next line if want different pallettes for each panel
    # barColors <- brewer.pal(4, "Dark2")
    mainTitle <- paste0("Total Baltimore PM2.5 Emissions By Year & Type: \n",
                        "Data only from sources common in each year. \n",
                        "  No common ON-ROAD sources in 2008.")
    barplot(bars/1000,
            names.arg = colnames(bars),
            ylab = "Emissions (1,000 tons PM25-PRI)",
            xlab = "Year",
            ylim = c(0, ymaxLeft), xpd = FALSE,
            col = c(barColors[1], barColors[2], barColors[3], barColors[4]),
            main = mainTitle,
            legend = cnames)
    dev.off()
}

createPanelPlots2()