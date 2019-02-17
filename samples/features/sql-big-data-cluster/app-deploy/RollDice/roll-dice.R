#####################################################
#####################################################
##
## Roll dice demo
## 
##
#####################################################
#####################################################
#install.packages("TeachingDemos")

rollEm <- function(numDice = 2) 
{
list.of.packages <- c("TeachingDemos")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
  library(TeachingDemos)
  
  r<-dice(ndice = numDice)
  return(as.data.frame(r))
}

result<-rollEm(x)

