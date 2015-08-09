##
## For some strange reason this code runs fine if it run using:
##         source("plot3.R", echo = TRUE, print.eval = TRUE)
## However, if it is run using just:
##         source("plot3.R")
## it generates a blank png file on my system that is the specified size
## (720 x 480 pixels)
##
library(dplyr)
library(ggplot2)
NEI <- readRDS("summarySCC_PM25.rds")

neiBaltimore <- filter(NEI, fips == "24510")
neiBaltimoreByYearByType <- group_by(neiBaltimore, year, type)
totalEmissions <- summarise(neiBaltimoreByYearByType,
                            TotalEmissions = sum(Emissions, na.rm = TRUE))
totalEmissions <- rename(totalEmissions, Source_Type = type)
totalEmissions <- rename(totalEmissions, Year = year)
png(file = "plot3.png", width = 720, height = 480, units = "px")
plot <- qplot(Year, TotalEmissions, data = totalEmissions,
        main = "Baltimore City PM2.5 Emissions By Year and Source Type",
        color = Source_Type, geom = c("point", "line"),
        ylab = "PM 2.5 Emissions (tons)")
print(plot)  # see slide 8/15 of week 2
dev.off()