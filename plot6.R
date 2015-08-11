##
## Generates a 1 x 2 panel plot of the PM25 motor vehicle emissions 
## normalized by 1999 Emissions levels for Baltimore city and Los Angeles
## county from 1999 to 2008.  For details see:
## https://github.com/MichaelSzczepaniak/ParticulateMatterStudy1999to2008
##
## The criteria used for determine which records are considered
## "motor vehicle sources" is any record with an EI.Sector field value that
## contains the string "mobile" followed by the string "road" ignoring case.
##
library(dplyr)
library(ggplot2)
#library(grid)
NEI <- readRDS("summarySCC_PM25.rds")
sourceClasses <- readRDS("Source_Classification_Code.rds")
# get indices of motor vehicle sources as described above
motorVehicleIndices <- grep("(mobile)(.*)(road)",
                            sourceClasses$EI.Sector, ignore.case=T)
sccValues <- sourceClasses$SCC[motorVehicleIndices]
# get the Baltimore and Los Angeles data and group them by year
allMotor <- filter(NEI, SCC %in% sccValues)
motorBalt <- filter(allMotor, fips == "24510")
motorLA <- filter(allMotor, fips == "06037")
motorBaltByYear <- group_by(motorBalt, year)
motorLAByYear <- group_by(motorLA, year)
# free some memory
rm(NEI)
rm(allMotor)
rm(motorBalt)
rm(motorLA)
# total the Baltimore emissions and add nomalized emissions column
emissionsBalt <- summarise(motorBaltByYear,
                           Total_Emissions = sum(Emissions, na.rm = TRUE))
emissionsBalt <- mutate(emissionsBalt, City = "Baltimore")
emissionsBalt <- emissionsBalt[, c(1, 3, 2)]  # make Total_Emissions last col
# add Baltimore normalized emissions column
emissions1999 <- emissionsBalt$Total_Emissions[1]
emissionsBalt <- mutate(emissionsBalt,
                        Normalized_Emissions = (Total_Emissions /emissions1999))
# total the Los Angeles emissions and add nomalized emissions column
emissionsLA <- summarize(motorLAByYear,
                         Total_Emissions = sum(Emissions, na.rm = TRUE))
emissionsLA <- mutate(emissionsLA, City = "Los Angeles")
emissionsLA <- emissionsLA[, c(1, 3, 2)]  # make Total_Emissions last col
# add normalized LA emissions column
emissions1999 <- emissionsLA$Total_Emissions[1]
emissionsLA <- mutate(emissionsLA,
                      Normalized_Emissions = (Total_Emissions /emissions1999))
# combine the Baltimore and LA data so we can plot them together
emissionsCombined <- rbind(emissionsBalt, emissionsLA)
emissionsCombined <- rename(emissionsCombined, Year = year)
emissionsCombined <- arrange(emissionsCombined, desc(City), Year)
emissionsCombined <- mutate(emissionsCombined, City = factor(City))
# generate the plot
png(file = "plot6.png", width = 720, height = 480, units = "px")
g <- ggplot(emissionsCombined, aes(x = Year, y = (Normalized_Emissions)))
plot <- g + geom_point(size = 4)
plot <- plot + facet_grid(. ~ City) + geom_line()
plot <- plot + ggtitle(expression(PM[2.5] * " Emissions Normalized to 1999:" *
                                  " Baltimore vs. Los Angeles"))
plot <- plot + coord_cartesian(xlim=c(1998, 2009))
plot <- plot + scale_x_continuous(breaks=seq(1999, 2008, 3))
plot <- plot +scale_y_continuous(breaks=c(seq(0.2, 1.2, 0.2)))
plot <- plot + labs(y = expression(PM[2.5] *
                                   " Emissions(year) / Emissions(year = 1999))"))
# make the fonts a bigger so everything is more readable
plot <- plot + theme(text = element_text(size=16),
                     axis.text.x = element_text(angle=90, vjust=1))
# Add 1999 information as free text annotations.  This was not trivial to do.
# This post really helped: https://trinkerrstuff.wordpress.com/2012/09/01/
# Trick is to build up a dataframe (dat in this case) to pass to geom_text.
# This dataframe must contain the following information:
# 1. Coordinates to plot the text
# 2. The faceted variable levels
# 3. The labels to be supplied
len <- length(levels(emissionsCombined$City)) # number of facets
# 2. The faceted variable levels. NOTE: Factor columns (e.g. City) must match
#                                       the factor columns of the original data
vars <- data.frame(City = c("Baltimore", "Los Angeles"))
# 1. Coordinates to plot the text. The x and y params are the coordinates.
# 3. The labels to be supplied. The labs vector supplies the text.
dat <- data.frame(x = c(2004, 2003.5), y = c(1.1, 0.9), vars,
                  labs=c("Baltimore Emissions(1999) = 409.97 tons",
                         "Los Angeles Emissions(1999) = 6428.13 tons"))
plot <- plot + geom_text(aes(x, y, label=labs, group=NULL),
                         size = 5, data = dat)
print(plot)
dev.off()