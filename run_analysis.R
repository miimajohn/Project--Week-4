library(reshape2)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
        download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
        unzip(filename) 
}

# Load activity types and metrics
activity_type <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_type[,2] <- as.character(activity_type[,2])
metrics <- read.table("UCI HAR Dataset/features.txt")
metrics[,2] <- as.character(metrics[,2])

# Extract only the data on mean and standard deviation
metricsWanted <- grep(".*mean.*|.*std.*", metrics[,2])
metricsWanted.names <- metrics[metricsWanted,2]
metricsWanted.names = gsub('-mean', 'Mean', metricsWanted.names)
metricsWanted.names = gsub('-std', 'Std', metricsWanted.names)
metricsWanted.names <- gsub('[-()]', '', metricsWanted.names)


# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[metricsWanted]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[metricsWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", metricsWanted.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activity_type[,1], labels = activity_type[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
