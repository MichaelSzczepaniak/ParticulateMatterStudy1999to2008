##
## Generates a stacked barplot of the total Baltimore city PM25 emissions by
## source type from 1999 through 2008.  For details see:
## https://github.com/MichaelSzczepaniak/ParticulateMatterStudy1999to2008
##
library(dplyr)
library(RColorBrewer)

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

NEI <- readRDS("summarySCC_PM25.rds")
normalizeNEI <- normalizeNEI(NEI)
neiBaltimore <- filter(normalizeNEI, fips == "24510")
neiBaltimoreByYearByType <- group_by(neiBaltimore, year, type)
totalEmissions <- summarise(neiBaltimoreByYearByType,
                            TotalEmissions = sum(Emissions, na.rm = TRUE))
totEmPoint <- filter(totalEmissions, type == "POINT")
if(length(totEmPoint$type) == 0) {
    totEmPoint <- createZeroDf("POINT")
}
totEmNonPoint <- filter(totalEmissions, type == "NONPOINT")
if(length(totEmNonPoint$type) == 0) {
    totEmNonPoint <- createZeroDf("NONPOINT")
}
totEmOnRoad <- filter(totalEmissions, type == "ON-ROAD")
if(length(totEmOnRoad$type) == 0) {
    totEmOnRoad <- createZeroDf("ON-ROAD")
}
totEmNonRoad <- filter(totalEmissions, type == "NON-ROAD")
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
cnames <- c("POINT", "NONPOINT", "ON-ROAD", "NON-ROAD")
# create/write output png: 720 x 480 pixels
png(file = "plot2.png", width = 720, height = 480, units = "px")
barColors <- brewer.pal(4, "Dark2")  # one of the SEQUENTIAL pallettes
mainTitle <- paste0("Total Baltimore PM2.5 Emissions By Year and Type: \n",
                    "Data only from sources common in each year. ",
                    "Note: No common ON-ROAD sources in 2008.")
barplot(bars/1000,
        names.arg = emByType$year,
        ylab = "Emissions (1,000 tons PM25-PRI)",
        xlab = "Year",
        ylim = c(0, 3.0), xpd = FALSE,
        col = c(barColors[1], barColors[2], barColors[3], barColors[4]),
        main = mainTitle,
        legend = cnames)
dev.off()