##
## Generates a 1 x 2 panel plot of the PM25 motor vehicle emissions 
## normalized by 1999 Emissions levels for Baltimore city and Los Angeles
## county from 1999 to 2008.  For details see:
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

## Load function that normalizes the NEI dataframe by grabbing records with
## sources that are common across the years 1999, 2002, 2005, 2008.
## This function is not being called because when it is, all ON-ROAD sources
## get dropped due to these sources not existing in 2008.  I leave the code in
## because I believe it is the more correct way to do the analysis, but from
## the discussion boards, no one else seems to be doing it this way so I don't
## want to cause any confusion when peer review time comes around.
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

getNeiSummary <- function(file = "summarySCC_PM25.rds") {
    # save time if function has been executed already and NEI is in workspace
    if(!exists("NEI")) {
        NEI <- readRDS("summarySCC_PM25.rds")
    }
    NEI <- readRDS("summarySCC_PM25.rds")
    sourceClasses <- readRDS("Source_Classification_Code.rds")
    # get indices of motor vehicle sources as described above
    motorVehicleIndices <- grep("(mobile)(.*)(road)",
                                sourceClasses$EI.Sector, ignore.case=T)
    sccValues <- sourceClasses$SCC[motorVehicleIndices]
    # get the Baltimore and Los Angeles data and group them by year
    allMotor <- filter(NEI, SCC %in% sccValues)
    motorBalt <- filter(allMotor, fips == "24510")
    motorLA <- filter(allMotor, fips == "06037")
    motorBaltByYear <- group_by(motorBalt, year)
    motorLAByYear <- group_by(motorLA, year)
    # free some memory
    # rm(NEI)
    rm(allMotor)
    rm(motorBalt)
    rm(motorLA)
    # total the Baltimore emissions and add nomalized emissions column
    emissionsBalt <- summarise(motorBaltByYear,
                               Total_Emissions = sum(Emissions, na.rm = TRUE))
    emissionsBalt <- mutate(emissionsBalt, City = "Baltimore")
    emissionsBalt <- emissionsBalt[, c(1, 3, 2)]  # make Total_Emissions last col
    # add Baltimore normalized emissions column
    emissions1999 <- emissionsBalt$Total_Emissions[1]
#     emissionsBalt <- mutate(emissionsBalt,
#                             Normalized_Emissions = (Total_Emissions /emissions1999))
    emissionsBalt <- mutate(emissionsBalt,
                            Normalized_Emissions = (Total_Emissions))
    # total the Los Angeles emissions and add nomalized emissions column
    emissionsLA <- summarize(motorLAByYear,
                             Total_Emissions = sum(Emissions, na.rm = TRUE))
    emissionsLA <- mutate(emissionsLA, City = "Los Angeles")
    emissionsLA <- emissionsLA[, c(1, 3, 2)]  # make Total_Emissions last col
    # add normalized LA emissions column
    emissions1999 <- emissionsLA$Total_Emissions[1]
#     emissionsLA <- mutate(emissionsLA,
#                           Normalized_Emissions = (Total_Emissions /emissions1999))
    emissionsLA <- mutate(emissionsLA,
                          Normalized_Emissions = (Total_Emissions))
    # combine the Baltimore and LA data so we can plot them together
    emissionsCombined <- rbind(emissionsBalt, emissionsLA)
    emissionsCombined <- rename(emissionsCombined, Year = year)
    emissionsCombined <- arrange(emissionsCombined, desc(City), Year)
    emissionsCombined <- mutate(emissionsCombined, City = factor(City))
    
    return(emissionsCombined)
}

createPanelPlots6 <- function(file = "plot6.png", width = 720, height = 500,
                              units = "px") {
    emissionsCombined <- getNeiSummary()
    png(file = file, width = width, height = height, units = units)
    g <- ggplot(emissionsCombined,
                aes(x = Year, y = Normalized_Emissions, shape = City, group = City))
    plot <- g + geom_point(size = 4)
    #plot <- plot + geom_smooth(size=1, linetype=3, method="lm", se=FALSE)  # most folks in forum don't like this, so comment out
    # plot <- plot + facet_grid(. ~ City) + geom_line()
    plot <- plot + facet_wrap(~ City, nrow = 1, ncol = 2, scales = "free")
    plot <- plot + geom_line()
    plot <- plot + ggtitle(" Motor Vehicle Emissions 1999 to 2008: Baltimore vs. LA")
    plot <- plot + coord_cartesian(xlim=c(1998, 2009))
    plot <- plot + scale_x_continuous(breaks=seq(1999, 2008, 3))
    # plot <- plot + scale_y_continuous(breaks=c(seq(0.2, 1.2, 0.2)))
    plot <- plot + labs(y = expression(PM[2.5] * "Emissions (in tons)"))
    # make the fonts a bigger so everything is more readable
    plot <- plot + theme(text = element_text(size=16),
                         axis.text.x = element_text(angle=90, vjust=1))
    plot <- plot + theme(legend.position="none") #legend.justification=c(0.5,0.5),
#                          legend.position=c(0.5,0.5))
    
    print(plot)
    dev.off()
}

createPanelPlots6()