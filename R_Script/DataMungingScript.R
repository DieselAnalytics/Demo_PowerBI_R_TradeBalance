library(dplyr); library(stringr); library(tidyr); library(lubridate)

#Sets the working directory
setwd("D:/OneDrive - Diesel Analytics/Talks/SQLSaturday_WhyRYouNotUsingRInPowerBI")

#Function used to transform the "Type A" files
Transformation.Type.A <- function(file.name){  

  report.year.value = substring(file.name,1,4)
  rawdata <- readLines(paste("./Data/",file.name,sep=""))
  
  InData = FALSE
  i <- 1
  j <- 1
  k <- 1
  
  group.counter = 0
  
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
        tb.stats <- character() #Creates a empty character vector
        tb.stats.pw <- str_sub(row, country.name.end.pos + 1) #Gets the part of the string that i want to split in the character
        tb.stats.pw <- gsub("\\s+", "|", tb.stats.pw, perl = TRUE) #Replaces a string of one or more consecutive white spaces with a pipe ("|") symbol
        first.pos <- ifelse(substring(tb.stats.pw,1,1)=="|",2,1) 
        tb.stats.pw <- str_sub(tb.stats.pw, first.pos)
        tb.stats <-unlist(strsplit(tb.stats.pw, split="|", fixed=TRUE))
        
        group.name[i] <- if (group.counter == 1) {
          "trade.balance"
        } else if (group.counter == 2) {
          "exports"
        } else if (group.counter == 3) {
          "imports"
        } else {
          "Out of Bounds"
        }
        country[i] = country.name
        stat.value[i] = tb.stats[1]
        rank[i] = tb.stats[2]
        report.year[i] = report.year.value
        
        if (grepl("Unidentified", country.name, perl=TRUE)) InData = FALSE
        
        i <- i + 1
        
      }
    }  
  }
  
  ds <- data.frame(group.name, country, stat.value, report.year)
  ds <- ds %>% spread(group.name, stat.value) %>% select(country, trade.balance, exports, imports, report.year)
  return(ds)
  #ds <- ds %>% spread(group.name, stat.value) %>% select(country, trade.balance, exports, imports)
  
}

#Function used to transform the "Type B" files
Transformation.Type.B <- function(file.name){  

    report.year.value = substring(file.name,1,4)
    rawdata <- readLines(paste("./Data/",file.name,sep=""))
  
    country = character()
    trade.balance = character()
    trade.balance.rank = character()
    exports = character()
    exports.rank = character()
    imports = character()
    imports.rank = character()
    report.year = character()
  
    i <- 1
    InData = FALSE
  
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
      
            tb.stats <- character() #Creates a empty character vector
            tb.stats.pw <- str_sub(row,country.name.end.pos + 1) #Gets the part of the string that i want to split in the character
            tb.stats.pw <- gsub("\\s+", "|", tb.stats.pw, perl = TRUE) #Replaces a string of one or more consecutive white spaces with a pipe ("|") symbol
            first.pos <- ifelse(substring(tb.stats.pw,1,1)=="|",2,1) 
            tb.stats.pw <- str_sub(tb.stats.pw, first.pos)
            tb.stats <-unlist(strsplit(tb.stats.pw, split="|", fixed=TRUE))
      
            country[i] = country.name
            trade.balance[i] = tb.stats[1]
            trade.balance.rank[i] = tb.stats[2]
            exports[i] = tb.stats[3]
            exports.rank[i] = tb.stats[4]
            imports[i] = tb.stats[5]
            imports.rank[i] = tb.stats[6]
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
trade.balance.rank = character(0)
exports = character(0)
exports.rank = character(0)
imports = character(0)
imports.rank = character(0)
report.year = character(0)

NetExportsData <- data.frame(country, trade.balance, trade.balance.rank, exports, exports.rank, imports, imports.rank, report.year)

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
                    ifelse(exports == 0 & imports == 0, "Bad", NA))))))) #I think if we are not doing anything with a country it should be considered bad
  )

# #Recalculates trade.balance
NetExportsData <- NetExportsData %>% mutate(trade.balance = exports - imports)

start.date = "20000101"
end.date = "20141231"

Dates <- seq(ymd(start.date), ymd(end.date), by="days") #
FiscalYearEndMonth = 6

DateTable <- data.frame(Dates)

DateTable <- DateTable %>%
  mutate("DateKey" = format(Dates, "%Y%m%d")
         ,"Year" = year(Dates)
         ,"Fiscal Year" = Year + ifelse(month(Dates) > FiscalYearEndMonth,1,0)
         ,"Iso Year" = isoyear(Dates)
         ,"Year Day" = yday(Dates)
         ,"Quarter Name" = paste("Q",quarter(Dates),sep="")
         ,"Quarter Key" = quarter(Dates)
         ,"Quarter Day" = qday(Dates)
         ,"Month Name" = format(Dates, "%b")
         ,"Month Key" = month(Dates)
         ,"Month Day" = mday(Dates)
         ,"Week" = week(Dates)
         ,"Iso Week" = isoweek(Dates)
         ,"Weekday Name" = wday(Dates, label = TRUE)
         ,"Weekday Key" = wday(Dates)
         ,"Weekend" = ifelse(wday(Dates) %in% c(1,7),TRUE,FALSE)
  )

obects.to.remove <- c("country","country.list","Dates","end.date","exports","exports.rank","file","files","FiscalYearEndMonth","imports","imports.rank","report.year", "start.date","trade.balance","trade.balance.rank","Transform.A","Transform.B")
rm(list=obects.to.remove)
rm(obects.to.remove)
