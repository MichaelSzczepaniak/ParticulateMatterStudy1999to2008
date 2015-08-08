library(dplyr)
library(RColorBrewer)
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
emByType <- select(totEmPoint, -type)
emByType <- rename(emByType, pointEmissions = TotalEmissions)
x <- totEmNonPoint$TotalEmissions
emByType <- cbind(emByType, nonPointEmissions = x)
x <- totEmOnRoad$TotalEmissions
emByType <- cbind(emByType, onRoadEmissions = x)
x <- totEmNonRoad$TotalEmissions
emByType <- cbind(emByType, nonRoadEmissions = x)
bars <- t(as.matrix(emByType))
colnames(bars) <- bars[1, ]
bars <- bars[c(2:5), ]
cnames <- c("POINT", "NONPOINT", "ON-ROAD", "NON-ROAD") #names(emByType)[2:5]
# create/write output png. Use size is 480 x 480 pixels, but be explicit
png(file = "plot2.png", width = 720, height = 480, units = "px")
barColors <- brewer.pal(4, "Dark2")
barplot(bars/1000,
        names.arg = emByType$year,
        ylab = "Emissions (thousand tons PM25-PRI)",
        xlab = "Year",
        ylim = c(0, 3.5), xpd = FALSE,
        col = c(barColors[1], barColors[2], barColors[3], barColors[4]),
        main = "Baltimore PM2.5 Emissions (thousands of tons) By Year and Type",
        legend = cnames)
dev.off()