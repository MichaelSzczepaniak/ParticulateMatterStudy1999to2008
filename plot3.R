##
## Generates a multi-line chart of the Baltimore city PM25 emissions for each
## source type from 1999 through 2008.  For details see:
## https://github.com/MichaelSzczepaniak/ParticulateMatterStudy1999to2008
##
## Sources should be subsetted to only include those that are common in each
## of the measurement years (1999, 2002, 2005, and 2008). Subsetting was not
## done here in order to allow the ON-ROAD measurement to show up in the plot
## as advised in this forum thread:
## https://class.coursera.org/exdata-031/forum/thread?thread_id=132
library(dplyr)
library(ggplot2)
NEI <- readRDS("summarySCC_PM25.rds")

neiBaltimore <- filter(NEI, fips == "24510")
neiBaltimoreByYearByType <- group_by(neiBaltimore, year, type)
totalEmissions <- summarise(neiBaltimoreByYearByType,
                            TotalEmissions = sum(Emissions, na.rm = TRUE))
totalEmissions <- mutate(totalEmissions, type = factor(type))
totalEmissions <- rename(totalEmissions, Source_Type = type)
totalEmissions <- rename(totalEmissions, Year = year)
png(file = "plot3.png", width = 720, height = 480, units = "px")
plot <- qplot(Year, TotalEmissions, data = totalEmissions,
        main = "Baltimore City PM2.5 Emissions By Year and Source Type\n(All sources included to ensure data from all 4 types are illustrated.)",
        color = Source_Type, geom = c("point", "line"),
        ylab = "PM 2.5 Emissions (tons)")
plot <- plot + scale_x_continuous(breaks=c(1999, 2002, 2005, 2008))
print(plot)
dev.off()