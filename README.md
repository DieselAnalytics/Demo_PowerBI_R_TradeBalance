# Power BI and R Demo (Using R and Power BI to Analyze the Trade Balance at the Country Level)

### Abstract
Power BI is a self-service business intelligence tool that is gaining popularity. Microsoft added the ability to use R scripts as a data source and the ability to use R to create custom visualizations. In this repo I have an example of using R in Power BI both as a data source and as a way to create a custom visualization.


### Resources

##### R Script
I included the R file that contains the R script that was used to create the data source. I wrote the script in R Studio. When I got the script functional I copied and pasted it in Power BI Desktop. The name of the file is "DataMungingScript.R"

##### Power BI File
I included a copy of the *.pbix file that was used in the presentation. The name of the *.pbix file is "Demo_TradeBalance.pbix". It includes the Power Query scripts, DAX code, and visualizations. 

##### Data Sources
I used trade balance files from the census. Each report contained trade balance data for the given year at the country level for the years from 2000 to 2014. The files are located in the "Data" folder.


### Instructions 

##### How to setup R and use R to create a custom visualization
Click [here](https://powerbi.microsoft.com/en-us/documentation/powerbi-desktop-r-visuals/) to get instructions on how to set up your environment.


##### How to add a R Script as a data source to Power BI
1.  Create and test your script using a R IDE (I recommend R Studio)
2.  Make sure that the data sources that you want to import are made into a dataframe in your R Script
3.  Launch Power BI Desktop
4.  Click "Get Data" > More > Other > "R Script" 
5.  Click the "Connect" button on the lower right
6.  Go to R Studio (or whatever IDE you are using) and copy your R Script
7.  Paste your R script in the text box
8.  Click the "Ok" button


### Notes
mentioned that this feature is in preview
