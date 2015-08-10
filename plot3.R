##
## Generates a multi-line chart of the Baltimore city PM25 emissions for each
## source type from 1999 through 2008.  For details see:
## https://github.com/MichaelSzczepaniak/ParticulateMatterStudy1999to2008
##
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
        main = "Baltimore City PM2.5 Emissions By Year and Source Type",
        color = Source_Type, geom = c("point", "line"),
        ylab = "PM 2.5 Emissions (tons)")
print(plot)  # see "No Plot Yet!" page 124 of 216 of
             # ExploratoryDataAnalysisAll.pdf (consolidate lecture slides)
dev.off()