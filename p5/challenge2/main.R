library(doParallel)
cl <- makeCluster(detectCores() - 1)
library(truncnorm)
clusterEvalQ(cl,library(truncnorm))
library(matrixStats)

data <- read.csv("zika.csv", header=TRUE, sep=",")

meanData <- mean(data$casos)
medianData <- median(data$casos)
sdData <- sd(data$casos)
clusterExport(cl, "meanData")
clusterExport(cl, "sdData")

experiment <- function(r){
  sample <- floor(rtruncnorm(68, a = 0, mean = meanData, sd = sdData))
  return(sample)
}

runs <- 500000
changes <- parSapply(cl, 1:runs, experiment)
stopCluster(cl)

means <- colMeans(changes[1: 34,], na.rm = T)
medians <- colMeans(changes[1: 34,], na.rm = T)
diffMeans <- abs(means - meanData)
diffMedians <- abs(medians - medianData)
print(which.min(diffMeans))
print(which.min(diffMedians))

colMeans <- which.min(diffMeans)
colMedians <- which.min(diffMedians)

png("datos.png", width=600, height=300, units="px")
plot(1:34, data$casos, ylab="Casos", xlab="Semana", xlim=c(1,68), ylim = c(0, max(data$casos)))
lines(1:68, changes[1:68, colMedians], col="blue")
lines(1:68, changes[1:68, colMeans], col="red")
graphics.off()
