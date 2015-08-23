##
## Generates a multi-line chart of the Baltimore city PM25 emissions for each
## source type from 1999 through 2008.  For details see:
## https://github.com/MichaelSzczepaniak/ParticulateMatterStudy1999to2008
##
## Sources should be subsetted to only include those sources that are common in
## each of the measurement years (1999, 2002, 2005, and 2008).  Because
## there were no common ON-ROAD sources for 2008, a two panel plot was
## created with all sources on the left as advised in this forum thread:
## https://class.coursera.org/exdata-031/forum/thread?thread_id=132
## and with just common sources on the right.
library(dplyr)
library(ggplot2)

## Summarizes NEI data by year and type for Baltimore (fips = 24510).
## A two-level factor indicating whether all sources are used or if only
## sources common to the reporting years (1999, 2002, 2005, 2008) were used.
getNeiSummary <- function(file = "summarySCC_PM25.rds") {
    # save time if function has been executed already and NEI is in workspace
    if(!exists("NEI")) {
        NEI <- readRDS("summarySCC_PM25.rds")
    }
    # create summary from all sources first
    neiByYearAndTypeAll <- group_by(NEI, year, type)
    neiByYearAndTypeAll <- filter(neiByYearAndTypeAll, fips == "24510")
    totalEmissionsAllSources <- summarise(neiByYearAndTypeAll,
                                TotalEmissions = sum(Emissions, na.rm = TRUE))
    
    neiCommon <- normalizeNEI(NEI)
    neiByYearAndTypeCommon <- group_by(neiCommon, year, type)
    neiByYearAndTypeCommon <- filter(neiByYearAndTypeCommon, fips == "24510")
    totalEmissionsCommonSources <- summarise(neiByYearAndTypeCommon,
                                TotalEmissions = sum(Emissions, na.rm = TRUE))
    # put the all source summary together with the common source summary
    totalEmissions <- rbind(totalEmissionsAllSources,
                            totalEmissionsCommonSources)
    # create factor for all and common sources and append column
    dataSource <- factor(c(rep("All Sources", nrow(totalEmissionsAllSources)),
                           rep("Only Common Sources",
                               nrow(totalEmissionsCommonSources))))
    totalEmissions$Data.Source <- dataSource
    
    # convert type to factor so ggplot2 creates a line for each
    totalEmissions <- mutate(totalEmissions, type = factor(type))
    # rename x axis source so ggplot2 uses its name for the label
    totalEmissions <- rename(totalEmissions, Year = year)
    totalEmissions <- rename(totalEmissions, Source.Type = type)
    
    return(totalEmissions)
}

## creates two facet/panel line plots of Baltimore emissions
createPanelPlots3 <- function(file = "plot3.png", width = 720, height = 500,
                              units = "px") {
    mainTitle <- paste0("Baltimore City PM2.5 Emissions By Year and Source Type\n",
                        "(All sources included to ensure data from all 4 types",
                        " are illustrated.)")
    png(file = file, width = width, height = height, units = units)
    totalEmissions <- getNeiSummary()
    
    g <- ggplot(totalEmissions, aes(x=Year, y=TotalEmissions,
                                    shape=Source.Type, group=Source.Type))
    plot <- g + geom_point(size = 4)
    plot <- plot + facet_grid(. ~ Data.Source) + geom_line()
    plot <- plot + theme(legend.position=c(0.5,0.45))
    plot <- plot + scale_x_continuous(breaks=c(1999, 2002, 2005, 2008))
    mainTitle <- paste("Baltimore City PM2.5 Emissions By Year and Source Type",
                       "\nfor all sources and only those sources common to",
                       "each reporting year")
    plot <- plot + ggtitle(mainTitle)
    print(plot)
    dev.off()
}

createPanelPlots3()