##
## Constructs a stacked bar plot of the Baltimore PM2.5 emissions by year and 
## Road type.  For details see:
## https://github.com/MichaelSzczepaniak/ParticulateMatterStudy1999to2008
##
## The criteria used for determine which records are considered
## "motor vehicle sources" is any record with an EI.Sector field value that
## contains the string "mobile" followed by the string "road" ignoring case.
##
## Sources should be subsetted to only include those that are common in each
## of the measurement years (1999, 2002, 2005, and 2008). Subsetting was not
## done here in order to allow the ON-ROAD measurement to show up in the plot
## as advised in this forum thread:
## https://class.coursera.org/exdata-031/forum/thread?thread_id=132
##
library(dplyr)
library(ggplot2)
library(scales)

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

## Summarizes NEI data by year and motor vehicle related sources for Baltimore
## (fips = 24510).  A two-level factor indicating whether all sources are used
## or if only sources common to the reporting years (1999, 2002, 2005, 2008)
## were used.
getNeiSummary <- function(file = "summarySCC_PM25.rds") {
    # save time if function has been executed already and NEI is in workspace
    if(!exists("NEI")) {
        NEI <- readRDS("summarySCC_PM25.rds")
    }
    NEI <- readRDS("summarySCC_PM25.rds")
    sourceClasses <- readRDS("Source_Classification_Code.rds")
    
    motorVehicleIndices <- grep("(mobile)(.*)(road)",
                                sourceClasses$EI.Sector, ignore.case=T)
    sccValues <- sourceClasses$SCC[motorVehicleIndices]
    # get the motor vehicle emissions data for Baltimore ALL SOURCES
    motorVehicleBaltAll <- filter(NEI, fips == "24510")
    motorVehicleBaltAll <- filter(motorVehicleBaltAll, SCC %in% sccValues)
    motorVehicleBaltAll <- group_by(motorVehicleBaltAll, year, type)
    mvBaltSummaryAll <- summarise(motorVehicleBalt,
                                 Total_Emissions = sum(Emissions, na.rm = TRUE))
    
    # get the motor vehicle emissions data for Baltimore ONLY COMMON SOURCES
    motorVehicleBaltCommon <- filter(normalizeNEI(NEI), fips == "24510")
    motorVehicleBaltCommon <- filter(motorVehicleBaltCommon, SCC %in% sccValues)
    motorVehicleBaltCommon <- group_by(motorVehicleBaltCommon, year, type)
    mvBaltSummaryCommon <- summarise(motorVehicleBaltCommon,
                                 Total_Emissions = sum(Emissions, na.rm = TRUE))
    # no "ON-ROAD" so fill with zeros
    temp <- data.frame(year=seq(1999, 2008, by=3),
                       type=rep("ON-ROAD", 4), Total_Emissions=rep(0,4))
    mvBaltSummaryCommon <- rbind(mvBaltSummaryCommon, temp)
    mvBaltSummaryCommon <- arrange(mvBaltSummaryCommon, year, type)
    
    mvBaltSummary <- rbind(mvBaltSummaryAll, mvBaltSummaryCommon)
    # create factor for all and common sources and append column
    dataSource <- factor(c(rep("All Sources", nrow(mvBaltSummaryAll)),
                           rep("Only Common Sources",
                               nrow(mvBaltSummaryCommon))))
    mvBaltSummary$Data.Source <- dataSource
    
    # Need to ungroup before reordering with arrange per:
    # http://stackoverflow.com/questions/27207963/arrange-not-working-on-grouped-dataframe
    mvBaltSummary <- ungroup(mvBaltSummary)
    mvBaltSummary <- arrange(mvBaltSummary, type)
    mvBaltSummary <- rename(mvBaltSummary, Year = year)
    mvBaltSummary <- rename(mvBaltSummary, Road_Type = type)
    
    return(mvBaltSummary)
}

## Creates 2 facet/panel bar plots
createPanelPlots5 <- function(file = "plot5.png", width = 720, height = 500,
                              units = "px") {
    mvBaltSummary <- getNeiSummary()
    png(file = file, width = width, height = height, units = units)
    g <- ggplot(mvBaltSummary,
                aes(x = factor(Year), y = Total_Emissions, fill = Road_Type))
    plot <- g + geom_bar(stat = "identity")
    plot <- plot + facet_wrap(~ Data.Source, nrow = 1, ncol = 2,
                              scales = "free")
    plot <- plot + ggtitle(expression("Baltimore " * PM[2.5] *
                                      " Motor Vehicle Emissions By Road Type " *
                                          "and Sources"))
    plot <- plot + labs(x = "Year")
    plot <- plot + labs(y = expression(PM[2.5] * "Emissions (in tons)"))
    plot <- plot + theme(text = element_text(size=12))
    plot <- plot + theme(legend.position=c(0.5, 0.47))
    plot <- plot + theme(text = element_text(size=14))
    print(plot)
    dev.off()
}

createPanelPlots5()