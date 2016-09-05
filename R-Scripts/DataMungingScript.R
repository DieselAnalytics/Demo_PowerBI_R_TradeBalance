# Setup Instructions
# 1. Create a "Data" folder in your working directory
# 2. Place all of the yearly trade balance files that are located in the "Data" folder on github into the folder

#Necessary packages
suppressPackageStartupMessages(library(dplyr));
suppressPackageStartupMessages(library(lubridate))
library(stringr);
library(tidyr);

#Function used to transform the "Type A" files
Transformation.Type.A <- function(file.name){  

  report.year.value = substring(file.name,1,4)
  rawdata <- readLines(paste("./Data/",file.name,sep=""))
  
  InData = FALSE # This variable tells the program if it is in the part of the text that contains the data we what to extract
  i <- 1
  j <- 1
  k <- 1
  
  group.counter = 0

  # Vectors that will be used to create the data frame
  group.name = character()
  country = character()
  stat.value = character()
  rank = character()
  report.year = character()
  
  for (row in rawdata){
    
    if (grepl("Area:", row, perl=TRUE)) break
    
    if (nchar(row)>=64) {
      
      country.name.end.pos = 36
      
      if (grepl("Afghanistan", row, perl=TRUE)) {
        InData = TRUE
        group.counter = group.counter + 1
      }
      
      country.name <- str_trim(substring(row,1,country.name.end.pos))
      
      if (InData == TRUE & nchar(country.name) > 0) {
        tb.stats <- character() #Creates a empty character vector that will be used to hold the data that will be splitted
        tb.stats.pw <- str_sub(row, country.name.end.pos + 1) # Gets the part of the string that will be splitted
        tb.stats.pw <- gsub("\\s+", "|", tb.stats.pw, perl = TRUE) # Replaces a string of one or more consecutive white spaces with a pipe ("|") symbol
        first.pos <- ifelse(substring(tb.stats.pw,1,1)=="|",2,1)  # Gets the first non-pipe position
        tb.stats.pw <- str_sub(tb.stats.pw, first.pos) # Return the string minus the first position being a pipe
        tb.stats <-unlist(strsplit(tb.stats.pw, split="|", fixed=TRUE)) # Delimits the string based on pipe and return the output to a character vector
        
        group.name[i] <- if (group.counter == 1) {
          "trade.balance"
        } else if (group.counter == 2) {
          "exports"
        } else if (group.counter == 3) {
          "imports"
        } else {
          "Out of Bounds"
		}

		#populates the vectors
        country[i] = country.name
        stat.value[i] = tb.stats[1]
        #rank[i] = tb.stats[2] (Not outputting the rank value)
        report.year[i] = report.year.value

        if (grepl("Unidentified", country.name, perl=TRUE)) InData = FALSE
        
        i <- i + 1
        
      }
    }  
  }

  ds <- 
  data.frame(group.name, country, stat.value, report.year) %>% # Creates a data frame using the vectors that were passed to it as fields
  spread(group.name, stat.value) %>% # Unpivots the group.name field and uses the stat.value field for the data
  select(country, trade.balance, exports, imports, report.year) # Returns the columns passed to it
      
  return(ds)
  
}


#Function used to transform the "Type B" files
Transformation.Type.B <- function(file.name){  

    report.year.value = substring(file.name,1,4)
    rawdata <- readLines(paste("./Data/",file.name,sep=""))
  
	# Creates the vectors that will be useed to create the data frame.
	country = character()
    trade.balance = character()
    exports = character()
    imports = character()
    report.year = character()
  
    i <- 1
    InData = FALSE # This variable is used to determine if the program is in the portion of the file that contains the data we want to extract
  
    for (row in rawdata){
        if (grepl("Afghanistan", row, perl=TRUE)) {InData = TRUE}
    
        country.name.end.pos <- 
            if(report.year.value %in% c("2008","2009","2013","2014")) 
                35
            else if (report.year.value %in% c("2011")) 
                32
            else
                30
    
        country.name <- str_trim(substring(row,1,country.name.end.pos))
    
        if (InData == TRUE & nchar(country.name) > 0) {
      
            tb.stats <- character() #Creates a empty character vector that will be used to hold the data that will be splitted
            tb.stats.pw <- str_sub(row, country.name.end.pos + 1) # Gets the part of the string that will be splitted
            tb.stats.pw <- gsub("\\s+", "|", tb.stats.pw, perl = TRUE) # Replaces a string of one or more consecutive white spaces with a pipe ("|") symbol
            first.pos <- ifelse(substring(tb.stats.pw,1,1)=="|",2,1) # Gets the first non-pipe position
            tb.stats.pw <- str_sub(tb.stats.pw, first.pos) # Return the string minus the first position being a pipe
            tb.stats <-unlist(strsplit(tb.stats.pw, split="|", fixed=TRUE)) # Delimits the string based on pipe and return the output to a character vector

			# Populates the vectors
            country[i] = country.name
            trade.balance[i] = tb.stats[1]
            exports[i] = tb.stats[3]
            imports[i] = tb.stats[5]
            report.year[i] = report.year.value
      
            if (grepl("Unidentified", country.name, perl=TRUE)) break
      
            i <- i + 1
            
        }
        
  }
  
  df.transform.b <- data.frame(country, trade.balance, exports, imports, report.year)
  return(df.transform.b)
  
}  

#Region Infomation
country.list <- read.csv(file = "./Data/CountryList.csv")

#Data file Format vectors
Transform.A <- c("2000_exh13tl.txt", "2001_exh13tl.txt", "2002_exh13tl.txt", "2003_exh13tl.txt")
Transform.B <- c("2004_exh13tl", "2005_exh13tl", "2006_exh13tl", "2007_exh13tl", "2008_exh13tl", "2009_exh13tl", "2010_exh13tl", "2011_exh13tl","2012_exh13cy", "2013_exh13cy", "2014_exh13cy")

#Creates an empty "NetExportsData" data frame
country = character(0)
trade.balance = character(0)
exports = character(0)
imports = character(0)
report.year = character(0)

NetExportsData <- data.frame(country, trade.balance, exports, imports, report.year)

#Creates list of files in the current directory
files <- list.files("./Data")

#Determine which functioin to use to 
for (file in files)
  if (file %in% Transform.A) {
    NetExportsData <- rbind(NetExportsData, Transformation.Type.A(file))
  } else if (file %in% Transform.B) {
    NetExportsData <- rbind(NetExportsData, Transformation.Type.B(file))
  }

#Change the data types of some of the fields
NetExportsData <-
  NetExportsData %>%
  mutate(
    exports = suppressWarnings(as.numeric(str_replace(exports,",",""))) * 1000000,
    imports = suppressWarnings(as.numeric(str_replace(imports,",",""))) * 1000000,
    report.date = ymd(paste(as.numeric(as.character(report.year)), "12", "31", sep = ""))
  )

#Removes rows that has NAs in all of the metric fields
NetExportsData <-
  NetExportsData %>%
  mutate(FilterField = ifelse(is.na(trade.balance) & is.na(imports) & is.na(exports), 1, 0)) %>%
  filter(FilterField == 0) %>%
  select(country, trade.balance, exports, imports, report.date)

#Replace all NA's with zeroes for calculation reason.
NetExportsData[is.na(NetExportsData)] <- 0

#Add region data
suppressWarnings(NetExportsData <- left_join(NetExportsData, country.list, by = "country"))

#Add export.leverage.index field
NetExportsData <-
  NetExportsData %>%
  mutate(trade.status =
                    ifelse(exports == 0 & imports != 0, "Bad",
                    ifelse(exports != 0 & imports == 0, "Good",
                    ifelse(exports != 0 & imports != 0 & exports/imports < 1, "Bad",
                    ifelse(exports != 0 & imports != 0 & (exports/imports >= 1 & exports/imports <= 1.1), "Ok",
                    ifelse(exports != 0 & imports != 0 & (exports/imports > 1.1 & exports/imports <= 2), "Good",
                    ifelse(exports != 0 & imports != 0 & exports/imports > 2, "Great",
                    ifelse(exports == 0 & imports == 0, "None", NA))))))) #I think if we are not doing anything with a country it should be considered bad
  )

# Recalculates trade.balance
NetExportsData <- NetExportsData %>% mutate(trade.balance = exports - imports)

#######################################################################################################################
# Creates the Date Dimension table

# Sets the start and end dates
start.date = "20000101"
end.date = "20141231"

# Creates a sequence of dates based on the start.date and end.date
Dates <- seq(ymd(start.date), ymd(end.date), by="days") #

FiscalYearEndMonth = 6

# Builds the Date Dimension table
DateTable <- 
  data.frame(Dates) %>% 
  mutate("DateKey" = format(Dates, "%Y%m%d")
         ,"Month Name" = format(Dates, "%b")
         ,"Weekday Name" = wday(Dates, label = TRUE)
         ,"Weekday Key" = wday(Dates)
         ,"Year" = year(Dates)
         ,"Fiscal Year" = Year + ifelse(month(Dates) > FiscalYearEndMonth,1,0)
         ,"Month Key" = month(Dates)
         ,"Month Day" = mday(Dates)
         ,"Iso Year" = isoyear(Dates)
         ,"Week" = week(Dates)
         ,"Iso Week" = isoweek(Dates)
         ,"Quarter" = quarter(Dates)
         ,"Quarter Day" = qday(Dates)
         ,"Year Day" = yday(Dates)
         ,"Weekend" = ifelse(wday(Dates) %in% c(1,7),TRUE,FALSE)
  ) %>%
  select(`DateKey`,`Dates`,`Year`,`Fiscal Year`,`Iso Year`,`Year Day`,`Quarter`,`Quarter Day`,`Month Name`,`Month Key`,
         `Month Day`,`Week`,`Iso Week`,`Weekday Name`,`Weekday Key`,`Weekend`
  )

obects.to.remove <- c("country","country.list","Dates","end.date","exports","file","files","FiscalYearEndMonth","imports","report.year", "start.date","trade.balance","Transform.A","Transform.B")
rm(list=obects.to.remove)
rm(obects.to.remove)
