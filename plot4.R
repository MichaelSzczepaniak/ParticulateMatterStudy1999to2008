##
## Generates a 1 x 2 panel plot of the coal and non-coal PM25 emissions
## from 1999 through 2008.  For details see:
## https://github.com/MichaelSzczepaniak/ParticulateMatterStudy1999to2008
##
## The criteria used for determining which records are considered "coal
## combustion-related" is any records with an EI.Sector field value that
## starts with "fuel comb -" and ends with "- coal" as described in this post:
##
## https://class.coursera.org/exdata-031/forum/thread?thread_id=60&utm_medium=email&utm_source=other&utm_campaign=notifications.auto.sEvfXj7QEeWn8yIAC45P7Q#comment-169
##
library(dplyr)
library(ggplot2)
library(scales)
NEI <- readRDS("summarySCC_PM25.rds")
sourceClasses <- readRDS("Source_Classification_Code.rds")
# get indices of coal combustion-related sources as described above
coalCombIndices <- grep("^fuel comb -(.*)- coal$",
                        sourceClasses$EI.Sector, ignore.case=T)
sccValues <- sourceClasses$SCC[coalCombIndices]
# get the coal and non-coal data and group them by year
neiCoalComb <- filter(NEI, SCC %in% sccValues)
neiNonCoal <- filter(NEI, !(SCC %in% sccValues))
neiCoalCombByYear <- group_by(neiCoalComb, year)
neiNonCoalByYear <- group_by(neiNonCoal, year)
# total the coal and non-coal emissions
emissionsCoal <- summarise(neiCoalCombByYear,
                           Total_Emissions = sum(Emissions, na.rm = TRUE))
emissionsCoal <- mutate(emissionsCoal, Source = "Coal Combustion Sources")
emissionsCoal <- emissionsCoal[, c(1, 3, 2)]
emissionsCoal <- mutate(emissionsCoal, Total_Emissions = Total_Emissions)
emissionsNonCoal <- summarize(neiNonCoalByYear,
                              Total_Emissions = sum(Emissions, na.rm = TRUE))
emissionsNonCoal <- mutate(emissionsNonCoal,
                           Source = "Non-Coal Sources")
emissionsNonCoal <- emissionsNonCoal[, c(1, 3, 2)]
# combine the coal and non-coal data so we can plot them together
emissionsCombined <- rbind(emissionsCoal, emissionsNonCoal)
emissionsCombined <- rename(emissionsCombined, Year = year)
emissionsCombined <- arrange(emissionsCombined, desc(Source), Year)
emissionsCombined <- mutate(emissionsCombined, Source = factor(Source))
# generate the plot
png(file = "plot4.png", width = 720, height = 480, units = "px")
g <- ggplot(emissionsCombined, aes(x = Year, y = (Total_Emissions)))
plot <- g + geom_point(size = 4)
plot <- plot + facet_grid(. ~ Source) + geom_line()
plot <- plot + ggtitle(expression("Total US " * PM[2.5] *
                                  " Emissions: Coal vs. Non-Coal Sources"))
plot <- plot + coord_cartesian(xlim=c(1998, 2009))
plot <- plot + scale_x_continuous(breaks=seq(1999, 2008, 3))
# use log10 scale on y so we can better see how both groups trend
plot <- plot + coord_trans(y="log10")
plot <- plot + labs(y = expression(PM[2.5] * "Emissions (in tons)"))
# make the fonts a bigger so everything is more readable
plot <- plot + theme(text = element_text(size=20),
                     axis.text.x = element_text(angle=90, vjust=1))
print(plot)  # see "No Plot Yet!" page 124 of 216 of
# ExploratoryDataAnalysisAll.pdf (consolidate lecture slides)
dev.off()