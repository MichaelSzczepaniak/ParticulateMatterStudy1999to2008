library(dplyr)
##
NEI <- readRDS("summarySCC_PM25.rds")
# create/write output png. Use size is 480 x 480 pixels, but be explicit
png(file = "plot2.png", width = 480, height = 480, units = "px")
neiBaltimore <- filter(NEI, fips == "24510")
neiBaltimoreByYear <- group_by(neiBaltimore, year)
totalEmissions <- summarise(neiBaltimoreByYear,
                            TotalEmissions = sum(Emissions, na.rm = TRUE))
barplot(totalEmissions$TotalEmissions/1000,
        names.arg = totalEmissions$year,
        ylab = "Emissions (thousand tons PM25-PRI)",
        xlab = "Year",
        ylim = c(1.5, 3.5), xpd = FALSE,
        col = "wheat3",
        main = "Baltimore PM25 Emissions (thousands of tons) By Year and Type")
dev.off()