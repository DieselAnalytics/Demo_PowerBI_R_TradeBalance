suppressWarnings(suppressPackageStartupMessages(library(dplyr)))
suppressWarnings(suppressPackageStartupMessages(library(ggplot2)))

GetRangeKey <- function(x){
  ifelse(x<= -90000000000,1,
  ifelse(x > -90000000000 &  x <=-56666666667,2,
  ifelse(x > -56666666667 &  x <=-23333333333,3,
  ifelse(x > -23333333333 &  x <=10000000000,4,
  ifelse(x > 10000000000,5, NA)))))
}

GetRangeName <- function(x){
  ifelse(x<= -90000000000,"<-90B",
  ifelse(x > -90000000000 &  x <=-56666666667,"-90B to ~-57B",
  ifelse(x > -56666666667 &  x <=-23333333333,"~-57B to ~-23B",
  ifelse(x > -23333333333 &  x <=10000000000,"~-23B to 10B",
  ifelse(x > 10000000000,">10B", NA)))))
}

graph.data <- 
  NetExportsData %>%
  select(trade.status, trade.balance) %>%
  mutate(trade.balance.log10 = ifelse(trade.balance == 0,0,log10(abs(trade.balance))), trade.status = factor(x = trade.status, levels=c("Bad", "Ok", "Good", "Great")), data.range.name = GetRangeName(trade.balance), data.range.key = GetRangeKey(trade.balance))

bad.tb.df <- graph.data %>% filter(trade.status == "Bad") %>% summarize(bal = sum(trade.balance))
bad.tb.val <- paste(as.character(round(bad.tb.df[1]/1000000000,0)),"B",sep = " ")

ok.tb.df <- graph.data %>% filter(trade.status == "Ok") %>% summarize(bal = sum(trade.balance))
ok.tb.val <- paste(as.character(round(ok.tb.df[1]/1000000000,0)),"B",sep = " ")

good.tb.df <- graph.data %>% filter(trade.status == "Good") %>% summarize(bal = sum(trade.balance))
good.tb.val <- paste(as.character(round(good.tb.df[1]/1000000000,0)),"B",sep = " ")

great.tb.df <- graph.data %>% filter(trade.status == "Great") %>% summarize(bal = sum(trade.balance))
great.tb.val <- paste(as.character(round(great.tb.df[1]/1000000000,0)),"B",sep = " ")

p <- ggplot(graph.data, aes(trade.status, trade.balance.log10))
p <- p + geom_jitter(alpha = 0.2, height = 1) + geom_boxplot(alpha = 0.7)
p <- p + annotate(geom="text", x="Ok", y=15, label="Trade Balances by Category are Listed Below")
p <- p + annotate(geom="text", x="Bad", y=13, label=bad.tb.val)
p <- p + annotate(geom="text", x="Ok", y=13, label=ok.tb.val)
p <- p + annotate(geom="text", x="Good", y=13, label=good.tb.val)
p <- p + annotate(geom="text", x="Great", y=13, label=great.tb.val)
p
