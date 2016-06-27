library(dplyr); library(ggplot2)

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

graph.data <- NetExportsData

year.val = 2013
zero.and.ok.count <- nrow(graph.data %>% filter(trade.status == "Ok",trade.balance==0, year(report.date)==year.val))

graph.data <- 
  graph.data %>%
  select(country, trade.status, trade.balance, report.date) %>%
  mutate(trade.balance.log10 = ifelse(trade.balance == 0,0,log10(abs(trade.balance))), 
         trade.status = factor(x = trade.status, levels=c("Bad", "Ok", "Good", "Great")), 
         data.range.name = GetRangeName(trade.balance), 
         data.range.key = GetRangeKey(trade.balance),
         positive.or.negative = ifelse(trade.balance <=0,"Negative","Positive")
  ) %>%
  filter(!(trade.status == "Ok"& trade.balance==0)) %>%
  filter(year(report.date)==year.val)

# The code below is used to show the trade balance for each box plot
bad.tb.df <- graph.data %>% filter(trade.status == "Bad") %>% summarize(bal = sum(trade.balance))
bad.tb.val <- paste(as.character(round(bad.tb.df[1]/1000000000,0)),"B",sep = " ")

ok.tb.df <- graph.data %>% filter(trade.status == "Ok") %>% summarize(bal = sum(trade.balance))
ok.tb.val <- paste(as.character(round(ok.tb.df[1]/1000000000,0)),"B",sep = " ")

good.tb.df <- graph.data %>% filter(trade.status == "Good") %>% summarize(bal = sum(trade.balance))
good.tb.val <- paste(as.character(round(good.tb.df[1]/1000000000,0)),"B",sep = " ")

great.tb.df <- graph.data %>% filter(trade.status == "Great") %>% summarize(bal = sum(trade.balance))
great.tb.val <- paste(as.character(round(great.tb.df[1]/1000000000,0)),"B",sep = " ")

p <- ggplot(graph.data, aes(x=trade.status, y=trade.balance.log10,colour = positive.or.negative))
p <- p + geom_jitter(alpha=0.5,height=0) 
p <- p + geom_boxplot(alpha = 0.7) 
p <- p + theme(legend.position="none")
p <- p + annotate(geom="text", x="Ok", y=15, label=paste(zero.and.ok.count," ",ifelse(zero.and.ok.count==1,"country","countries")," had the same imports and exports amount", sep=""))
p <- p + annotate(geom="text", x="Bad", y=13, label=bad.tb.val)
p <- p + annotate(geom="text", x="Ok", y=13, label=ok.tb.val)
p <- p + annotate(geom="text", x="Good", y=13, label=good.tb.val)
p <- p + annotate(geom="text", x="Great", y=13, label=great.tb.val)
print(p)
