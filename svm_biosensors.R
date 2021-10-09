library(caret)
library(ggplot2)
library(dplyr)
setwd("D:/")
trainData=read.csv("Train.csv")

set.seed(100)
rows <- sample(nrow(trainData))
trainData <- trainData[rows, ]

x = trainData[, 1:6]
y = trainData$Method

# See the structure of the new dataset
str(trainData)

ggpairs(trainData, ggplot2::aes(colour = Method, alpha = 0.4))

# One-Hot Encoding
# Creating dummy variables is converting a categorical variable to as many binary variables as here are categories.
dummies_model <- dummyVars(Method ~ ., data=trainData)

# Create the dummy variables using predict. The Y variable (Purchase) will not be present in trainData_mat.
trainData_mat <- predict(dummies_model, newdata = trainData)

# Convert to dataframe
trainData <- data.frame(trainData_mat)

# See the structure of the new dataset
str(trainData)

# Preprocess data => value between 0-1
preProcess_range_model <- preProcess(trainData, method='range')
trainData <- predict(preProcess_range_model, newdata = trainData)

# Append the Y variable
trainData$Method <- y

# Check value in each column
apply(trainData[, 1:8], 2, FUN=function(x){c('min'=min(x), 'max'=max(x))})

#Box Plot
featurePlot(x = trainData[, 1:8], 
            y = trainData$Method, 
            plot = "box",
            strip=strip.custom(par.strip.text=list(cex=.7)),
            scales = list(x = list(relation="free"), 
                          y = list(relation="free")))


summary(trainData$Method)

#MODEL PREDICTION
testData=read.csv("Test.csv")
testData2 <- predict(dummies_model, testData)
testData3 <- predict(preProcess_range_model, testData2)
testData3 <- as.data.frame(testData3)

# Define the training control
control <- trainControl(method="repeatedcv", number=10, repeats=3, savePredictions = "final",classProbs = T,summaryFunction=multiClassSummary)

# Range for C parameter
grid <- expand.grid(C = c(2^-5,2^-3,2^-2,2^-1,2^0,2^1,2^2,2^3,2^5))

set.seed(100)
# Train the model using SVM and predict on the training data itself
svmLinear <- train(Method ~ ., data=trainData, tuneGrid =grid
                   ,method='svmLinear', trControl = control)
svmLinear
plot(svmLinear)

# Predict on testData for Linear SVM
predicted <- predict(svmLinear, testData3)
head(predicted)
confusionMatrix(reference = testData$Method, data = predicted, mode='everything')

#NON-LINEAR KERNEL
# Range for polynomial kernel
grid_poly <- expand.grid(C = c(2^-5,2^-3,2^-2,2^-1,2^0,2^1,2^2,2^3,2^5),
                         degree=c(2,3,4), scale=1)

set.seed(100)
# Train the model using SVM and predict on the training data itself.
svmPoly <- train(Method ~ ., data=trainData, method='svmPoly',tuneGrid =grid_poly, trControl = control)
svmPoly
plot(svmPoly)

# Predict on testData for Polynomial SVM
predictedP <- predict(svmPoly, testData3)
head(predictedP)
confusionMatrix(reference = testData$Method, data = predictedP, mode='everything')

# Range for RBF kernel
grid_rbf <- expand.grid(sigma = c(2^-5,2^-3,2^-2,2^-1,2^0,2^1,2^2,2^3,2^5),
                        C = c(2^-5,2^-3,2^-2,2^-1,2^0,2^1,2^2,2^3,2^5))

set.seed(100)
# Train the model using SVM and predict on the training data itself.
svmRadial<- train(Method ~ ., data=trainData, method='svmRadial',tuneGrid = grid_rbf, trControl = control)
svmRadial
plot(svmRadial)

# Predict on testData for Radial SVM
predictedR <- predict(svmRadial, testData3)
head(predictedR)
confusionMatrix(reference = testData$Method, data = predictedR, mode='everything')

