##
## Generates a barplot using the base R graphics system of the total US PM25
## emissions from 1999 through 2008.  For details see:
## https://github.com/MichaelSzczepaniak/ParticulateMatterStudy1999to2008
##
library(dplyr)

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

NEI <- readRDS("summarySCC_PM25.rds")
neiNormalized <- normalizeNEI(NEI)
neiByYear <- group_by(neiNormalized, year)
totalEmissions <- summarise(neiByYear,
                            TotalEmissions = sum(Emissions, na.rm = TRUE))
# create/write output png: 720 x 480 pixels
png(file = "plot1.png", width = 720, height = 480, units = "px")
barplot(totalEmissions$TotalEmissions/1000000,
        names.arg = totalEmissions$year,
        ylab = "Emissions (1,000,000 tons PM25-PRI)",
        xlab = "Year",
        ylim = c(2, 7), xpd = FALSE,
        col = "wheat1",
        main = "Total US PM25 Emissions By Year\n(from sources common to each year)")
dev.off()