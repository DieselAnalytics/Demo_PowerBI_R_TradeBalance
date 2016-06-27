# Power BI and R Demo (Using R and Power BI to Analyze the United States Trade Balance with Other Countries)


## Abstract
Power BI is a self-service business intelligence tool that is gaining popularity. In late 2015, Microsoft added the ability to use R scripts as a data source and the ability to use R scripts to create custom visualizations. In this repo I have an example of using R in Power BI both as a data source and as a way to create a custom visualization.

I used yearly trade balance data by country that was obtained from census.gov to build a Power BI dashboard. A R script was used to combine the data from the yearly trade balance files into one dataset that was loaded into Power BI Desktop. I used the stringr, dplyr, tidyr, and lubridate packages to create the script. Typically Power Query is used for that task but the complexity and variety of the data format of each file made it easier to do the task in R.

I also created a custom boxplot visualization using a R script that used the ggplot2 and dplyr packages. The boxplot visualization that I created using R was more advanced then what I could have done using the custom Power BI boxplot. The Power BI's version was not design to accomodate the additional layers and annotations that I added to the boxplot chart I created using R. R's ggplot2 package makes it much easier to add things like extra layers and annotations.

##### R Script
I included the R files that contains the R script that was used to create the data source and the R script that was used to create the boxplot visualization. I wrote the scripts in R Studio. When I got the scripts functional I copied and pasted them into Power BI Desktop. The name of the file used to import the data into Power BI is "DataMungingScript.R" and the name of the file used to create the boxplot visualization is "Boxplot.R".

##### Power BI File
I included a copy of the *.pbix file that contains the visualization. The name of the *.pbix file is "Demo_TradeBalance.pbix". It includes the Power Query scripts, DAX code, embeded R Scripts, and visualizations. 

##### Data Sources
I used trade balance files from the census.gov. Each report contained trade balance data for the given year at the country level for the time period between 2000 and 2014. Please note that the format of those files are not consistent across the years. The files are located in the "Data" folder.


## Extra information

#### R
- Make sure you have stringr, dplyr, ggplot2, lubridate, and tidyr packages loaded in your environment. All of the packages are on CRAN so they can be installed using the "install.packages" command.
- Make sure you have a nice IDE to play with the R scripts if you want to test them for yourself. I recommend you use R Studio.

#### Power BI
- Make sure you go through the instructions provided to setup Power BI to be able to use R as a data source and R to create custom visualizations. Information on how to do so can be found [here](https://powerbi.microsoft.com/en-us/documentation/powerbi-desktop-r-visuals/).
- Download the "chicklet slicer" and "scroller" custom visualizations for Power BI. Those visualizations can be found [here](https://app.powerbi.com/visuals/).
- For information on how to import custom visuals from the Power BI visual gallery go [here](https://app.powerbi.com/visuals/info#use).

### Data Transformations
- I chose to use R to do the data transformations instead of Power Query because of the level of unstructuredness in the data. I found it much easier to do it in R versus Power Query.
- I used a regular expression to replace 1 or many white spaces with a "|" to delimit the columns that contained the trade balance, exports, and imports data. I used the str_split coupled with the unlist function to parse the trade balance, exports, and imports columns.
- The files came in one of two formats. One of the formats had the trade balance, exports, and imports information in separate rows. After the trade balance, exports, and imports information was combined into one data set I used the spread verb from the tidyr package to unpivot that data.

#### Dashboard Explanation
- The dashboard gives a snap shot of what's going on in a given year with the trade balance.
- The dashboard's title is dynamic and the trade balance value and the number of countries included changes based on the the time period selected.
- The "Top 5 Most Impactful Countries" chart shows the 5 most impactful countries regardless of if the impact is positive or negative
- "The "Countries with the Biggest Yearly Changes" chart shows the top 5 countries that had the 5 biggest absolute change from the previous year
- The "scroller" on the bottom of the screen displays a list of the countries in alphabetical order with their US trade balance for the time period selected.
- The boxplot chart shows a boxplot of trade balances by trade status category. Because of the big variance of trade balances I used the log10 of the absolute trade balance value (what a mouthful!!! Lol). So if country A has a trade balance of 100 and country B has a trade balance of -100 both of their converted values would be 2. Here is additional information about the boxplot:
  - **Bad** = The country has no imports or exports, the ratio exports/imports is less than 1, or the country has no exports but has imports
  - **Ok** = The country's exports/imports ratio is between 1 and 1.1
  - **Good** =  The country has exports but no imports or the country's exports/imports ratio is between 1.1 and 2
  - **Great** = The country's exports/imports ratio is greater then 2
  - The contribution of the trade balance for each category is shown on top of the boxplot for that category.

## Considerations
Many of the R features in Power BI are in preview and some of the features do not work on PowerBI.com. I was told by personnel at Microsoft in April 2016 at the Data Insight Summit that all of the R features that are currently in Power BI should be in GA soon. I was also told that they will provide a iist of packages that will work on PowerBI.com.

## Closing Remarks
This is the start of a project that I plan on improving. The subject of this project originated from one of the 2016 Republican debates in which the trade deficit was mentioned. I wondered what the true situation was, how the situation was trending over time, and what countries had the biggest impacts. So to answer my questions I started this project and I want to share my findings and my work with the community. 

I am apolitical. I have no affinity to neither of the current political parties in the United States but I still follow politics to stay current. Some of the topics that are debated by politicians interest me and this is one of them.
