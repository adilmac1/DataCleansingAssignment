library(reshape)
library(data.table)

##Get current working directory
path <- getwd()

##Get labels and features
labels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
targetFeatures <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[targetFeatures, featureNames]

##Strip off the brackets in the measurement names
measurements <- gsub('[()]', '', measurements)

##Get training data X
trainingX <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, targetFeatures, with = FALSE]

##Set measurement names
data.table::setnames(trainingX, colnames(trainingX), measurements)

##Get training activities
trainingActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("ActivityName"))

##Get training subjects
trainingSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))

##Combine data with acitivies and subjects
trainingData <- cbind(trainingSubjects, trainingActivities, trainingX)


##Get test data X
testX <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, targetFeatures, with = FALSE]

##Set measurement names
data.table::setnames(testX, colnames(testX), measurements)

##Get test activities
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                            , col.names = c("ActivityName"))

##Get test subjects
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                          , col.names = c("SubjectNum"))

##Combine data with acitivies and subjects
testData <- cbind(testSubjects, testActivities, testX)

##Combine training data and test data
combined <- rbind(trainingData, testData)

##Replace ActivityName number with ActivityName names
combined[["ActivityName"]] <- factor(combined[, ActivityName]
                                 , levels = labels[["classLabels"]]
                                 , labels = labels[["activityName"]])
##Make subject number factors
combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])

##Calculate the average of each acvitiby and each subject
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "ActivityName"))
combined <- reshape2::dcast(data = combined, SubjectNum + ActivityName ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combined, file = "tidyDataSet.txt", quote = FALSE, row.name=FALSE)