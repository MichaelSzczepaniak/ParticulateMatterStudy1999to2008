##
## Generates a multi-line chart of the Baltimore city PM25 emissions for each
## source type from 1999 through 2008.  For details see:
## https://github.com/MichaelSzczepaniak/ParticulateMatterStudy1999to2008
##
## Sources should be subsetted to only include those sources that are common in
## each of the measurement years (1999, 2002, 2005, and 2008).  In order to
## because there were no common ON-ROAD sources for 2008, a two panel plot was
## created with all sources on the left as advised in this forum thread:
## https://class.coursera.org/exdata-031/forum/thread?thread_id=132
## and with just common sources on the right.
library(dplyr)
library(ggplot2)

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
    neiBaltimore <- filter(neiByYear, fips == "24510")
    totalEmissions <- summarise(neiBaltimore,
                                TotalEmissions = sum(Emissions, na.rm = TRUE))
    # convert type to factor so ggplot2 creates a line for each
    totalEmissions <- mutate(totalEmissions, type = factor(type))
    # rename x axis source so ggplot2 uses its name for the label
    totalEmissions <- rename(totalEmissions, Year = year)
    totalEmissions <- rename(totalEmissions, Source = type)
    
    return(totalEmissions)
}

createPanelPlots3 <- function(file = "plot3.png", width = 720, height = 500,
                              units = "px") {
    mainTitle <- paste0("Baltimore City PM2.5 Emissions By Year and Source Type\n",
                        "(All sources included to ensure data from all 4 types",
                        " are illustrated.)")
    png(file = "plot3.png", width = 720, height = 480, units = "px")
    totalEmissions <- getNeiSummary(normalize = FALSE)
    plot <- qplot(Year, TotalEmissions, data = totalEmissions,
                  main = mainTitle,
                  color = Source, geom = c("point", "line"),
                  ylab = "PM 2.5 Emissions (tons)")
    plot <- plot + scale_x_continuous(breaks=c(1999, 2002, 2005, 2008))
    print(plot)
    dev.off()
}

createPanelPlots3()