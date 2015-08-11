## Contents  
- [Introduction](#id-intro)  
- [Description](#id-description)  
  - [Questions Framing the Inquiry](#id-questions-inquiry)
  - [Missing and Unique Values](#id-values)
  - [Structure and Summary](#id-str-summary)
- [Making Plots](#id-making-plots)  
- [References](#id-refs)

<div id='id-intro'/>
## Introduction
Fine particulate matter (PM2.5) is an ambient air pollutant for which there is strong evidence that it is harmful to human health. In the United States, the Environmental Protection Agency (EPA) is tasked with setting national ambient air quality standards for fine PM and for tracking the emissions of this pollutant into the atmosphere. Approximately every 3 years, the EPA releases its database on emissions of PM2.5. This database is known as the National Emissions Inventory (NEI). You can read more information about the NEI at the <a href="http://www.epa.gov/ttn/chief/eiinformation.html">EPA National Emissions Inventory website</a>. \[[1](#id-refs)\]

This project uses data from the <a href="http://www.epa.gov/ttn/chief/eiinformation.html">EPA National Emissions Inventory website</a>.
In particular, it uses data from the years 1999, 2002, 2005, and 2008.  A copy of this dataset is available in this repo at:  

* <b>Dataset</b>: <a href="https://github.com/MichaelSzczepaniak/ParticulateMatterStudy1999to2008/blob/master/exdata_data_NEI_data.zip">Electric power consumption</a> [30Mb]

<div id='id-description'/>
## Description
The purpose of this project is to get a general sense of of whether particulate matter emissions has improved or not between the years 1999 and 2008.
The following descriptions of the 6 variables in the dataset are as follows:

<ol>
<li><b>fips</b>: A five-digit number (represented as a string) indicating the U.S. county </li>
<li><b>SCC</b>: The name of the source as indicated by a digit string (see source code classification table) </li>
<li><b>Pollutant</b>: A string indicating the pollutant </li>
<li><b>Emissions</b>: Amount of PM2.5 emitted, in tons </li>
<li><b>type</b>: The type of source (point, non-point, on-road, or non-road) </li>
<li><b>year</b>: The year of emissions recorded </li>
</ol>

<div id='id-questions-inquiry'/>
### Questions Framing the Inquiry
<ol>
<li>Have <b>total</b> emissions from PM2.5 decreased in the United States from 1999 to 2008?
  <ul>
    <li>Using the base plotting system, a plot showing the total PM2.5 emissions from all sources for each of the years 1999, 2002, 2005, and 2008 was constructed as shown in <b><a href="#id-plot1">Plot 1</a></b> below.</li>
    <li><b><a href="#id-plot1">Plot 1</a></b> suggests that PM25 emissions have decreased every 3 years from 1999 to 2008.</li>
  </ul>
</li>
<li>Have total emissions from PM2.5 decreased in the Baltimore City, Maryland (fips == "24510") from 1999 to 2008? Use the base plotting system to make a plot answering this question.
  <ul>
    <li>A logical follow-up question would be if total emissions had not decreased, what source(s) prevented it?</li>
    <li>Using the base plotting system, a stacked bar chart showing PM2.5 emissions for Baltimore from all sources for each of the years 1999, 2002, 2005, and 2008 by source type was constructed as shown in <b><a href="#id-plot2">Plot 2</a></b> below.</li>
    <li>Total PM2.5 decreased in 3 of the 4 three-year time periods.  A rise in <b>POINT</b> emissions in 2005 caused the overall emissions for 2005 to increase from 2002 levels.  In spite of spike in 2005 emission levels, Baltimore PM2.5 emissions were lower in 2008 than they were in 1999, 2002, or 2005.</li>
  </ul>
</li>
<li>Of the four types of sources indicated by the type (point, nonpoint, onroad, nonroad) variable, which of these four sources have seen decreases in emissions from 1999 - 2008 for Baltimore City? Which have seen increases in emissions from 1999 - 2008? Use the <b>ggplot2</b> plotting system to make a plot answering this question.
<ul>
    <li>Using the <b>ggplot2</b> system, a multi-line chart showing PM2.5 emissions for Baltimore from all sources for each of the years 1999, 2002, 2005, and 2008 by source type was constructed as shown in <b><a href="#id-plot3">Plot 3</a></b> below.</li>
    <li>The POINT source increased from 1999 to 2002 and from 2002 to 2005 before declining below the 2005 level in 2008</li>
    <li>NON-ROAD, NONPOINT, and ON-ROAD sources declined from 1999 to 2002, were flat from 2002 to 2005 and then declined again from 2005 to 2008.</li>
  </ul>
</li>
<li>Across the United States, how have emissions from coal combustion-related sources changed from 1999 - 2008?
<ul>
    <li>The criteria used for determining which records are considered "coal combustion-related" is any records with an <b>EI.Sector</b> field value that starts with "fuel comb -" and ends with "- coal" ignoring case.
    </li>
    <li>Using the <b>ggplot2</b> system, a 1 x 2 panel plot showing PM2.5 emissions for both coal combustion-related and non-coal sources for each of the years 1999, 2002, 2005, and 2008 was constructed as shown in <b><a href="#id-plot4">Plot 4</a></b> below.</li>
    <li>Although coal combustion-related emissions rose slightly from 2002 to 2005, over the 1999 to 2008 period, they had fallen significantly.  Emissions from non-coal sources had fallen over each 3 year period between 1999 and 2008 as well.</li>
  </ul>
</li>
<li>How have emissions from motor vehicle sources changed from 1999 - 2008 in Baltimore City?
<ul>
    <li>The criteria used for determine which records are considered "motor vehicle sources" is any record with an <b>EI.Sector</b> field value that contains the string "mobile" followed by the string "road" ignoring case.</li>
    <li>Using the <b>ggplot2</b> system, a stacked bar chart showing PM2.5 emissions for both NON-ROAD and ON-ROAD types for each of the years 1999, 2002, 2005, and 2008 was constructed as shown in <b><a href="#id-plot5">Plot 5</a></b> below.</li>
    <li>The chart shows that the overall vehicle emissions has fallen in each of the periods between 1999 and 2008 and that most of this decline has been driven by the fall in ON-ROAD emissions</li>
  </ul>
</li>
<li>Compare emissions from motor vehicle sources in Baltimore City with emissions from motor vehicle sources in Los Angeles County, California (fips == "06037"). Which city has seen greater changes over time in motor vehicle emissions?
<ul>
    <li>The criteria used for determine which records are considered "motor vehicle sources" is any record with an <b>EI.Sector</b> field value that contains the string "mobile" followed by the string "road" ignoring case.</li>
    <li>Using the <b>ggplot2</b> system, a 1 x 2 panel plot showing PM2.5 emissions normalized to 1999 levels for both Baltimore city and Los Angeles county for each of the years 1999, 2002, 2005, and 2008 was constructed as shown in <b><a href="#id-plot6">Plot 6</a></b> below.</li>
    <li>Baltimore emissions declined durng each of the 3 year periods between 1999 and 2008.  Los Angeles county emissions increased from 1999 to 2002 and again from 2002 to 2005 before showing it first decrease from 2005 to 2008 to a level that was still above its 1999 level.</li>
  </ul>
</li>
</ol>

<div id='id-values'/>
### Missing and Unique Values
No values appear to missing from the data:
<pre>
NEI <- readRDS("summarySCC_PM25.rds")
any(is.na(NEI))
[1] FALSE
</pre>

There is only one type of pollutant in this data:
<pre>
> unique(NEI$Pollutant)
[1] "PM25-PRI"
</pre>

<div id='id-str-summary'/>
### Structure and Summary
<pre>
> str(NEI)
'data.frame':	6497651 obs. of  7 variables:
 $ fips         : chr  "09001" "09001" "09001" "09001" ...
 $ SCC          : chr  "10100401" "10100404" "10100501" "10200401" ...
 $ Pollutant    : chr  "PM25-PRI" "PM25-PRI" "PM25-PRI" "PM25-PRI" ...
 $ Emissions    : num  15.714 234.178 0.128 2.036 0.388 ...
 $ type         : chr  "POINT" "POINT" "POINT" "POINT" ...
 $ year         : int  1999 1999 1999 1999 1999 1999 1999 1999 1999 1999 ...
 $ normEmissions: num  2.43e-05 3.62e-04 1.98e-07 3.15e-06 6.00e-07 ...
</pre>

<pre>
> summary(NEI$Emissions)
    Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
     0.0      0.0      0.0      3.4      0.1     647000.0 
</pre>  
Huge spread as well as skew in the data.  Let's take a closer look:

<pre>
> quantile(NEI$Emissions, probs = seq(0, 1, 0.1))
          0%          10%          20%          30%          40%          50% 
0.000000e+00 2.647710e-05 2.557063e-04 1.047860e-03 3.490810e-03 1.000000e-02 
         60%          70%          80%          90%         100% 
2.000000e-02 5.990020e-02 1.600000e-01 7.036410e-01 6.469520e+05 
</pre>  
Over 90% of the **Emissions** values are < 1.

<pre>
</pre>

<div id='id-making-plots'/>
## Making Plots

The overall goal of this project is to explore the National Emissions Inventory database and see what it say about fine particulate matter pollution in the United states over the 10-year period 1999 - 2008. 


Each plot was construction and saved as a PNG file.
Separate R code files (plot1.R, plot2.R, etc.) were constructed corresponding to each plot, i.e. code in plot1.R constructs the plot1.png plot. The code file includes the  code for reading the data so that the plot can be fully reproduced.  The code also includes the functionality that creates the PNG files. Each .R file includes only the code for a single plot (i.e. plot1.R produces plot1.png, plot2.R produces plot2.png, etc.).  

Each PNG file prodused by the code is provided in this repository.  The six plots below attempt to answer the six questions listed above: 

<div id='id-plot1'/>
### Plot 1
![plot1.png](plot1.png)  

<div id='id-plot2'/>
### Plot 2
![plot2.png](plot2.png)  

<div id='id-plot3'/>
### Plot 3
![plot3.png](plot3.png)  

<div id='id-plot4'/>
### Plot 4
![plot4](plot4.png)  

<div id='id-plot5'/>
### Plot 5
![plot5](plot5.png)  

<div id='id-plot6'/>
### Plot 6
![plot6](plot6.png)  

<div id='id-refs'/>
## References
[1] Peng, R (2015). "Exploratory Data Analysis" course project at [https://class.coursera.org/exdata-031](https://class.coursera.org/exdata-031)

