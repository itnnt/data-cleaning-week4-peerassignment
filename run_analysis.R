library(dplyr)

####################################
## Download and unzip the dataset ##
####################################
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
filename <- paste(getwd(), "FUCI_Dataset.zip", sep = '/')

if (!file.exists(filename)){
     download.file(fileURL, filename)
}  
if (!file.exists("UCI HAR Dataset")) { 
     unzip(filename) 
}

#####################
## Load train data ##
#####################
X_train <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE) %>% tbl_df
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE) %>% tbl_df
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE) %>% tbl_df


####################
## Load test data ##
####################
X_test <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE) %>% tbl_df
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE) %>% tbl_df 
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE) %>% tbl_df

##################################################################
## Merges the training and the test sets to create one data set ##
##################################################################
all_subjects <- rbind(subject_train, subject_test)
all_activities <- rbind(y_train, y_test)
all_features <- rbind(X_train, X_test)
 
## Set names to variables
names(all_subjects) <- c("subject")
names(all_activities) <- c("activity")

featuresNames <- read.table("UCI HAR Dataset/features.txt", header = FALSE)
names(all_features) <- featuresNames$V2

sa <- cbind(all_subjects, all_activities) 
data <- cbind(sa, all_features)

#############################################################################################
## Extracts only the measurements on the mean and standard deviation for each measurement. ##
#############################################################################################
needed_feature_indexes <- grep("mean\\(\\)|std\\(\\)", featuresNames$V2)
needed_feature_indexes <- c('subject', 'activity', as.character(featuresNames$V2[needed_feature_indexes]))
data <- subset(data, select = needed_feature_indexes)

############################################################################
## Uses descriptive activity names to name the activities in the data set ##
############################################################################
names(data) <- factor(gsub("[()]", "", names(data)))
names(data) <- factor(gsub("[-|,]", "_", names(data)))

####################################################################################################
## From the data set in step 4, creates a second, 
## independent tidy data set with the average of each variable for each activity and each subject.
####################################################################################################
data2<-aggregate(. ~subject + activity, data, mean) %>% tbl_df
write.table(data2, "tidy_data.txt", row.names = FALSE, quote = FALSE)

# Read descriptive activity names from “activity_labels.txt”
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE) 
activityLabels <- activityLabels[order(activityLabels$V1, activityLabels$V2),]


# Prouduce Codebook
library(knitr)
writeLines(c("# This codebook summarizes the data fields in tidy_data.txt", '', '## Fieldnames', names(data2), '',"## Activities labels", paste(activityLabels$V1, as.character(activityLabels$V2), sep = ":") ), "codebook.Rmd")
knit2html("codebook.Rmd")


writeLines(c(
     'Getting and Cleaning Data Course Project',
     '1.Merges the training and the test sets to create one data set.',
     '2.Extracts only the measurements on the mean and standard deviation for each measurement.',
     '3.Uses descriptive activity names to name the activities in the data set',
     '4.Appropriately labels the data set with descriptive variable names.',
     '5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.'
), "readme.Rmd")
knit2html("readme.Rmd")
