library(caret)
library(ggplot2)
library(GGally)
library(iml) #feature interaction
library(dplyr) #select and piping
setwd("D:")
trainData=read.csv("TrainD.csv")

set.seed(100)
# Randomly order the dataset
rows <- sample(nrow(trainData))
trainData <- trainData[rows, ]

# Store X and Y for later use.
x = trainData[, 1:6]
y = trainData$Method

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

# Preprocess data=> value between 0-1
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


# Define the training control
control <- trainControl(method="repeatedcv", number=10, repeats=3, savePredictions = "final",classProbs = T,summaryFunction=multiClassSummary)

# Range for C parameter
grid <- expand.grid(C = c(2^-5,2^-3,2^-2,2^-1,2^0,2^1,2^2,2^3,2^5,2^10))

# Set the seed for reproducibility
set.seed(100)

# Train the model using SVM and predict on the training data itself
svmLinear= train(Method ~ ., data=trainData, method='svmLinear', tuneGrid = grid, trControl = control)
fitted <- predict(svmLinear)
svmLinear
plot(svmLinear)

#MODEL PREDICTION
# Step 1: Import test data
testData=read.csv("TestD.csv")

# Step 2: Create one-hot encodings (dummy variables)
testData2 <- predict(dummies_model, testData)

# Step 3: Transform the features to range between 0 and 1
testData3 <- predict(preProcess_range_model, testData2)

# Predict on testData for Linear SVM
predicted <- predict(svmLinear, testData3)
head(predicted)
confusionMatrix(reference = testData$Method, data = predicted, mode='everything')

# Interaction between features
features <- trainData %>% select(-Method) %>% as.data.frame()
response <- trainData$Method
predictor <- Predictor$new(model = svmLinear, data = features, y = response)

Interaction$new(predictor)$plot()
Interaction$new(predictor, feature = "Ipc")$plot()
Interaction$new(predictor, feature = "Ep")$plot()

#NON-LINEAR KERNEL
# Range for non-linear kernel
grid_NL <- expand.grid(sigma = c(2^-15,2^-10,2^-5,2^-3,2^-2,2^-1,2^0,2^1,2^2,2^3,2^5),
                       C = c(2^-5,2^-3,2^-2,2^-1,2^0,2^1,2^2,2^3,2^5,2^10))

# Set the seed for reproducibility
set.seed(100)

# Train the model using SVM and predict on the training data itself.
svmRadial= train(Method ~ ., data=trainData, method='svmRadial',tuneGrid = grid_NL, trControl = control)
fitted <- predict(svmRadial)
svmRadial
plot(svmRadial)

# Predict on testData for Radial SVM
predictedR <- predict(svmRadial, testData3)
head(predictedR)
confusionMatrix(reference = testData$Method, data = predictedR, mode='everything')


predictor2 <- Predictor$new(model = svmRadial, data = features, y = response)
Interaction$new(predictor2)$plot()
Interaction$new(predictor2, feature = "Ipc")$plot()
Interaction$new(predictor2, feature = "Ep")$plot()