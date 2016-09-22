library(dplyr)

fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
filename <- paste(getwd(), "FUCI_Dataset.zip", sep = '/')

## Download and unzip the dataset:
if (!file.exists(filename)){
     download.file(fileURL, filename)
}  
if (!file.exists("UCI HAR Dataset")) { 
     unzip(filename) 
}

## Load needed feature names 
all_features <- tbl_df(read.table("UCI HAR Dataset/features.txt")) 
all_features$V2 <- factor(gsub("[()]", "", all_features$V2))
all_features$V2 <- factor(gsub("[-|,]", "_", all_features$V2))
needed_feature_indexes <- grep(".*[M|m][E|e][A|a][N|n].*|.*[S|s][T|t][D|d].*", all_features$V2)

activity_names <- tbl_df(read.table("UCI HAR Dataset/activity_labels.txt"))  


## Load train data
X_train <- tbl_df(read.table("UCI HAR Dataset/train/X_train.txt", stringsAsFactors = FALSE)[,needed_feature_indexes])
colnames(X_train) <- all_features$V2[needed_feature_indexes]

y_train <- read.table("UCI HAR Dataset/train/y_train.txt") %>% merge(activity_names) %>% tbl_df %>% select(V2)
colnames(y_train) <- c("Activity")

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt") %>% tbl_df
colnames(subject_train) <- c("Subject")

train <- cbind(subject_train, y_train, X_train) %>% tbl_df

## Load test data
X_test <- read.table("UCI HAR Dataset/test/X_test.txt", stringsAsFactors = FALSE)[,needed_feature_indexes] %>% tbl_df
colnames(X_test) <- all_features$V2[needed_feature_indexes]

y_test <- read.table("UCI HAR Dataset/test/y_test.txt") %>% merge(activity_names) %>% tbl_df %>% select(V2)
colnames(y_test) <- c("Activity")

subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt") %>% tbl_df
colnames(subject_test) <- c("Subject")

test <- cbind(subject_test, y_test, X_test) %>% tbl_df

## Merges the training and the test sets to create one data set
all_data <- rbind(train, test)
write.table(all_data, "tidy_all_data.txt", row.names = FALSE, quote = FALSE)

by_activity_subject <- group_by(all_data, Activity, Subject)
allData.mean <- dcast(all_data, subject + activity ~ variable, mean)

##https://rstudio-pubs-static.s3.amazonaws.com/37290_8e5a126a3a044b95881ae8df530da583.html

