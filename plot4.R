##
## Generates a 1 x 2 panel plot of the coal and non-coal PM25 emissions
## from 1999 through 2008.  For details see:
## https://github.com/MichaelSzczepaniak/ParticulateMatterStudy1999to2008
##
## The criteria used for determining which records are considered "coal
## combustion-related" is any records with an EI.Sector field value that
## starts with "fuel comb -" and ends with "- coal" as described in this post:
##
## https://class.coursera.org/exdata-031/forum/thread?thread_id=60&utm_medium=email&utm_source=other&utm_campaign=notifications.auto.sEvfXj7QEeWn8yIAC45P7Q#comment-169
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

## Summarize NEI by coal and non-coal sources by year.  Lots of posts on the 
## discussion boards on this.  See comment at top of file outlining the
## approach taken here.
getNeiSummary <- function(file = "summarySCC_PM25.rds") {
    # save time if function has been executed already and NEI is in workspace
    if(!exists("NEI")) {
        NEI <- readRDS("summarySCC_PM25.rds")
    }
    sourceClasses <- readRDS("Source_Classification_Code.rds")
    # get indices of coal combustion-related sources as described above
    coalCombIndices <- grep("^fuel comb -(.*)- coal$",
                            sourceClasses$EI.Sector, ignore.case=T)
    # NOTE TO REVIEW: I read all the posts re: lignite and considered adding it
    # to the coal indices but, this only added 2 add'l indices: 9061, 9062 and
    # upon inspection of these entries, it wasn't clear to me that these were a
    # result combustion so I decided to leave it out.
    sccValues <- sourceClasses$SCC[coalCombIndices]
    # get the coal and non-coal data and group them by year
    neiCoalComb <- filter(NEI, SCC %in% sccValues)
    neiNonCoal <- filter(NEI, !(SCC %in% sccValues))
    neiCoalCombByYear <- group_by(neiCoalComb, year)
    neiNonCoalByYear <- group_by(neiNonCoal, year)
    # total the coal and non-coal emissions
    emissionsCoal <- summarise(neiCoalCombByYear,
                               Total_Emissions = sum(Emissions, na.rm = TRUE))
    emissionsCoal <- mutate(emissionsCoal, Source = "Coal Combustion Sources")
    emissionsCoal <- emissionsCoal[, c(1, 3, 2)]
    emissionsNonCoal <- summarize(neiNonCoalByYear,
                                  Total_Emissions = sum(Emissions, na.rm = TRUE))
    emissionsNonCoal <- mutate(emissionsNonCoal,
                               Source = "Non-Coal Sources")
    emissionsNonCoal <- emissionsNonCoal[, c(1, 3, 2)]
    # combine the coal and non-coal data so we can plot them together
    emissionsCombined <- rbind(emissionsCoal, emissionsNonCoal)
    emissionsCombined <- rename(emissionsCombined, Year = year)
    emissionsCombined <- arrange(emissionsCombined, desc(Source), Year)
    emissionsCombined <- mutate(emissionsCombined, Source = factor(Source))
    
    return(emissionsCombined)
}

## Creates a 2 panel/facet plot of emissions from coal and non-coal sources
## by year. Note that y-axis scales are different in each plot/panel.
createPanelPlots4 <- function(file = "plot4.png", width = 720, height = 500,
                              units = "px") {
    emissionsCombined <- getNeiSummary()
    png(file = file, width = width, height = height, units = units)
    g <- ggplot(emissionsCombined, aes(x = Year, y = (Total_Emissions/1000000),
                                       shape = Source, group = Source))
    plot <- g + geom_point(size = 4)
    plot <- plot + facet_wrap(~ Source, nrow = 1, ncol = 2, scales = "free")
    plot <- plot + geom_line()
    plot <- plot + ggtitle(expression("Total US " * PM[2.5] *
                                          " Emissions From Coal & Non-Coal Sources" *
                                          " Common in each Year"))
    plot <- plot + coord_cartesian(xlim=c(1998, 2009))
    plot <- plot + scale_x_continuous(breaks=seq(1999, 2008, 3))
    # uncomment next 2 lines to use log10 scale on y-axis
    #plot <- plot + coord_trans(y="log10")
    #plot <- plot + labs(y = expression(PM[2.5] * "Emissions (in tons)"))
    # use normal y-axis scaling but account for taking log10 of the y-values
    plot <- plot + labs(y = " Emissions (in million of tons)")
    # make the fonts a bigger so everything is more readable
    plot <- plot + theme(text = element_text(size=14),
                         axis.text.x = element_text(angle=90, vjust=1))
    plot <- plot + theme(legend.position=c(0.8, 0.8))
    print(plot)
    dev.off()
}




createPanelPlots4()