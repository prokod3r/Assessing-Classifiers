# install.packages("e1071")
library("e1071")

rm(list=ls(all = TRUE))

unit_round <- function(val) {
    return(round(val, digits=0))
}

count_err <- function(V1, V2) {
    cnt <- 0
    for(i in 1:length(V1)) {
        if ( (V1[i] == "0" && V2[i] == "2") ||
             (V1[i] == "1" && V2[i] == "1") ) {
            cat(sprintf("%d: %s vs %s\n", i, V1[i], V2[i]));
            cnt <- cnt+1; }
    }
    return(cnt)
}


credit_data_df <- read.csv("./Dataset/project-default-credit-card-clients.csv", sep = ";", header = TRUE)

# Checking to see if there is any missing data
sapply(credit_data_df, function(x) sum(is.na(x)))

Y <- "default.payment.next.month"
X <- "ID"

names <- names(credit_data_df)
use_names <- names(credit_data_df[!names %in% c(Y, X)])

f <- as.formula(paste(paste(Y, "~"),
                      paste(use_names, collapse=" + ")))


df[Y] <- factor(df[Y])
index <- 1:nrow(df)
testindex <- sample(index, trunc(length(index)/3))
testdata <- na.omit(df[testindex,])
traindata <- na.omit(df[-testindex,])

## Train SVM with e1071:
x <- subset(traindata, select = -Y)
y <- traindata$Y
model <- svm(x, y, type="C-classification", kernel="radial", cost=1000)
print(model)
summary(model)

## Test with test data
xte <- subset(testdata, select = -Y)
pred <- cbind(predict(model, xte))
## (same as:)
##pred <- fitted(model)

predres <- factor(pred)  ## pred in (1,2)
cmpdata <- data.frame(actual=testdata$Y, predicted=predres)

nerr <- cnterr(cmpdata$actual,cmpdata$predicted)
errprct <- round(nerr/length(cmpdata$actual)*100, digits=2)
cat(sprintf("Percent errors: %f\n", errprct))
