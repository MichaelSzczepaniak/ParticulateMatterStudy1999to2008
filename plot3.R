library(dplyr)
library(ggplot2)
##
NEI <- readRDS("summarySCC_PM25.rds")

neiBaltimore <- filter(NEI, fips == "24510")
neiBaltimoreByYearByType <- group_by(neiBaltimore, year, type)
totalEmissions <- summarise(neiBaltimoreByYearByType,
                            TotalEmissions = sum(Emissions, na.rm = TRUE))
totEmPoint <- filter(totalEmissions, type == "POINT")
totEmNonPoint <- filter(totalEmissions, type == "NONPOINT")
totEmOnRoad <- filter(totalEmissions, type == "ON-ROAD")
totEmNonRoad <- filter(totalEmissions, type == "NON-ROAD")
png(file = "plot3.png", width = 720, height = 480, units = "px")
qplot(year, TotalEmissions, data = totalEmissions,
      main = "Baltimore City PM2.5 Emissions By Year and Type",
      xlab = "Year",
      ylab = "Emissions (tons)",
      color = type, geom = c("point", "line"))
dev.off()