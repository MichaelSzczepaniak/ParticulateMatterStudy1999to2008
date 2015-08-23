##
## Generates a barplot using the base R graphics system of the total US PM25
## emissions from 1999 through 2008.  For details see:
## https://github.com/MichaelSzczepaniak/ParticulateMatterStudy1999to2008
##
library(dplyr)

## Builds the summary of total emissions by year
getNeiSummary <- function(file = "summarySCC_PM25.rds", normalize = TRUE) {
    # save time if function has been executed already and NEI is in workspace
    if(!exists("NEI")) {
        NEI <- readRDS("summarySCC_PM25.rds")
    }
    neiByYear <- NULL
    totalEmissions <- NULL
    if(normalize) {
        neiNormalized <- normalizeNEI(NEI)
        neiByYear <- group_by(neiNormalized, year)
    }
    else {
        neiByYear <- group_by(NEI, year)
    }
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

## Creates the two panel barplots of the US emission totals: left plot is from
## sources that are common to all 4 time period, right plot is from all sources
## file - output plot file: a png of width x height units (typically px)
## width - width of the output plot image in units of units (typically px)
## height - height of the output plot image in units of units (typically px)
## units - units for width and height: typically pixels (px)
## ymaxLeft - max value of the left plot y-axis
## ymaxRight - max value of the right plot y-axis
createPanelPlots1 <- function(file = "plot1.png", width = 720, height = 480,
                             units = "px", ymaxLeft = 8, ymaxRight = 8) {
    # create/write output png: 720 x 480 pixels
    png(file = file, width = width, height = height, units = units)
    par(mfrow = c(1, 2))
    # add plot which uses all sources
    totalEmissions <- getNeiSummary(normalize = FALSE)
    barplot(totalEmissions$TotalEmissions/1000000,
            names.arg = totalEmissions$year,
            ylab = "Emissions (1,000,000 tons PM25-PRI)",
            xlab = "Year",
            ylim = c(2, ymaxRight), xpd = FALSE,
            col = "wheat3",
            main = "Total US PM2.5 Emissions By Year\n(all sources)")
    # add plot which only uses common sources
    totalEmissions <- getNeiSummary()
    barplot(totalEmissions$TotalEmissions/1000000,
            names.arg = totalEmissions$year,
            ylab = "Emissions (1,000,000 tons PM25-PRI)",
            xlab = "Year",
            ylim = c(2, ymaxLeft), xpd = FALSE,
            col = "wheat1",
            main = "Total US PM2.5 Emissions By Year\n(from sources common to each year)")

    dev.off()
}

createPanelPlots1()
