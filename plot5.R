##
## Contructs a stacked bar plot of the Baltimore PM2.5 emissions by year and 
## Road type.  For details see:
## https://github.com/MichaelSzczepaniak/ParticulateMatterStudy1999to2008
##
## The criteria used for determine which records are considered
## "motor vehicle sources" is any record with an EI.Sector field value that
## contains the string "mobile" followed by the string "road" ignoring case.
##
library(dplyr)
library(ggplot2)
library(scales)
NEI <- readRDS("summarySCC_PM25.rds")
sourceClasses <- readRDS("Source_Classification_Code.rds")

motorVehicleIndices <- grep("(mobile)(.*)(road)",
                       sourceClasses$EI.Sector, ignore.case=T)
sccValues <- sourceClasses$SCC[motorVehicleIndices]
# get the motor vehicle emissions data for Baltimore
motorVehicleBalt <- filter(NEI, fips == "24510")
motorVehicleBalt <- filter(motorVehicleBalt, SCC %in% sccValues)
motorVehicleBalt <- group_by(motorVehicleBalt, year, type)
mvBaltSummary <- summarise(motorVehicleBalt,
                           Total_Emissions = sum(Emissions, na.rm = TRUE))
#mvBaltSummary <- mutate(mvBaltSummary, type = factor(type))
mvBaltSummary <- ungroup(mvBaltSummary)
mvBaltSummary <- arrange(mvBaltSummary, type)
mvBaltSummary <- rename(mvBaltSummary, Year = year)
mvBaltSummary <- rename(mvBaltSummary, Road_Type = type)
# generate the plot
png(file = "plot5.png", width = 720, height = 480, units = "px")
g <- ggplot(mvBaltSummary,
            aes(x = factor(Year), y = Total_Emissions, fill = Road_Type))
plot <- g + geom_bar(stat = "identity")
plot <- plot + ggtitle(expression("Baltimore " * PM[2.5] *
                                  " Motor Vehicle Emissions By Road Type"))
plot <- plot + labs(x = "Year")
plot <- plot + labs(y = expression(PM[2.5] * "Emissions (in tons)"))
plot <- plot + theme(text = element_text(size=20))
plot <- plot + theme(legend.justification=c(1,1), legend.position=c(1,1))
print(plot)
dev.off()