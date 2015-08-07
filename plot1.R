library(dplyr)
##
NEI <- readRDS("summarySCC_PM25.rds")
# create/write output png. Use size is 480 x 480 pixels, but be explicit
png(file = "plot1.png", width = 480, height = 480, units = "px")
neiByYear <- group_by(NEI, year)
totalEmissions <- summarise(neiByYear,
                            TotalEmissions = sum(Emissions, na.rm = TRUE))
barplot(totalEmissions$TotalEmissions/1000000,
        names.arg = totalEmissions$year,
        ylab = "Emissions (million tons PM25-PRI)",
        xlab = "Year",
        ylim = c(3, 8), xpd = FALSE,
        col = "wheat1",
        main = "Total PM25 Emissions (millions of tons) By Year")
dev.off()