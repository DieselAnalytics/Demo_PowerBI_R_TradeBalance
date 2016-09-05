# Instructions
# 1. Create a folder named "Data" in your working directory
# 2. Copy and Paste the files from the "Data" folder in this repository

library(ggplot2)
library(readr)
suppressPackageStartupMessages(library(dplyr))

NetExportsData <- read_csv("./Data/2014_NetExportsData.csv")

#Info used later on for annotations
zero.and.ok.count <- nrow(NetExportsData %>% filter(trade.status == "Ok",trade.balance==0))
none.count <- nrow(NetExportsData %>% filter(trade.status == "None"))

#Graph Data
graph.data <- 
  NetExportsData %>%
  select(trade.status, trade.balance) %>%
  mutate(trade.balance.log10 = ifelse(trade.balance == 0,0,log10(abs(trade.balance))), 
         trade.status = factor(x = trade.status, levels=c("Bad", "Ok", "Good", "Great")), 
         positive.or.negative = ifelse(trade.balance <=0,"Negative","Positive")
  ) %>%
  filter(!(trade.status == "Ok"& trade.balance==0))

# More info that will be used for annotations
bad.tb.df <- graph.data %>% filter(trade.status == "Bad") %>% summarize(bal = sum(trade.balance))
bad.tb.count <- paste(nrow(graph.data %>% filter(trade.status == "Bad")), "countries",sep=" ")
bad.tb.val <- ifelse(abs(bad.tb.df[1])>=10^9, paste(round(bad.tb.df[1]/10^9,0),"B",sep = " "), paste(round(bad.tb.df[1]/10^6,0),"M",sep = " ")) 

ok.tb.df <- graph.data %>% filter(trade.status == "Ok") %>% summarize(bal = sum(trade.balance))
ok.tb.count <- paste(nrow(graph.data %>% filter(trade.status == "Ok")), "countries",sep=" ")
ok.tb.val <- ifelse(abs(ok.tb.df[1])>=10^9, paste(round(ok.tb.df[1]/10^9,0),"B",sep = " "), paste(round(ok.tb.df[1]/10^6,0),"M",sep = " ")) 

good.tb.df <- graph.data %>% filter(trade.status == "Good") %>% summarize(bal = sum(trade.balance))
good.tb.count <- paste(nrow(graph.data %>% filter(trade.status == "Good")), "countries",sep=" ")
good.tb.val <- ifelse(abs(good.tb.df[1])>=10^9, paste(round(good.tb.df[1]/10^9,0),"B",sep = " "), paste(round(good.tb.df[1]/10^6,0),"M",sep = " ")) 

great.tb.df <- graph.data %>% filter(trade.status == "Great") %>% summarize(bal = sum(trade.balance))
great.tb.count <- paste(nrow(graph.data %>% filter(trade.status == "Great")), "countries",sep=" ")
great.tb.val <- ifelse(abs(great.tb.df[1])>=10^9, paste(round(great.tb.df[1]/10^9,0),"B",sep = " "), paste(round(great.tb.df[1]/10^6,0),"M",sep = " ")) 

chart.title.first.sentence = paste("In CY 2014, ", zero.and.ok.count," ",ifelse(zero.and.ok.count==1,"country","countries")," had the same imports and exports amount", sep="")
chart.title.second.sentence = paste(none.count," ",ifelse(none.count==1,"country","countries")," had no imports and exports.", sep="")
chart.title <- paste(chart.title.first.sentence, chart.title.second.sentence, sep=" and ")

#Creating a Box Plot and Whiskers chart using ggplot2
p <- ggplot(graph.data, aes(x=trade.status, y=trade.balance.log10,colour = positive.or.negative))
p <- p + ggtitle(chart.title)
p <- p + geom_boxplot(alpha = 0.5) 
p <- p + geom_jitter(height = 0, width = 0.9) 
p <- p + theme(legend.position="none")
p <- p + annotate(geom="text", x="Bad", y=13, label=bad.tb.val)
p <- p + annotate(geom="text", x="Bad", y=13.35, label=bad.tb.count)
p <- p + annotate(geom="text", x="Ok", y=13, label=ok.tb.val)
p <- p + annotate(geom="text", x="Ok", y=13.35, label=ok.tb.count)
p <- p + annotate(geom="text", x="Good", y=13, label=good.tb.val)
p <- p + annotate(geom="text", x="Good", y=13.35, label=good.tb.count)
p <- p + annotate(geom="text", x="Great", y=13, label=great.tb.val)
p <- p + annotate(geom="text", x="Great", y=13.35, label=great.tb.count)
print(p)
