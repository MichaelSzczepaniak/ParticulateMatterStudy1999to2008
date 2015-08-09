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
png(file = "plot3.png", width = 720, height = 480, units = "px")
plot <- qplot(year, TotalEmissions, data = totalEmissions,
        main = "Baltimore City PM2.5 Emissions By Year and Type",
        color = type, geom = c("point", "line"),
        xlab = "Year", ylab = "PM 2.5 Emissions (tons)")
print(plot)
dev.off()