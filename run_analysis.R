## Getting and Cleaning Data Course Project
## Course Project by Ricardo Ochoa 

# Libraries
library(dplyr)
# ------------


# Step 1: Download the required data. 
# ------------

## Define the file URL, destination zip path, and extraction folder:
url <- "https://d396qusza40orc.cloudfront.net/"
origin_file <- "getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dest_file <- "data_raw.zip"
ex_dir <- "data_raw"

## Base directory (I will use this one in the next step)
data_dir <- "data_raw/UCI HAR Dataset"

## Download the zip file
download.file(url = paste0(url, origin_file), destfile = dest_file)

## Unzip the file into the specified directory
unzip(zipfile = dest_file, exdir = ex_dir)
list.files("data_raw", recursive = T)

## Since I have extracted the zip, I no longer need it. 
file.remove(dest_file)

## Just read the file. 
read.delim(file = "UCI HAR Dataset/test/Inertial Signals/body_acc_x_test.txt", 
           sep = " ")


# Step 2: Clean feature list names
# ------------

## Load the original feature list
features <- read.table(file.path(data_dir, "features.txt"), 
                       col.names = c("index", "feature_name"))

## Clean feature names using base R pattern replacement (gsub)
clean_names <- features$feature_name

## Fix known duplicate typos in raw feature names
clean_names <- gsub("BodyBody", "Body", clean_names)

## Expand starting prefix abbreviations (t = time, f = frequency)
clean_names <- gsub("^t", "time_", clean_names)
clean_names <- gsub("^f", "frequency_", clean_names)

## NOTE: Ok, ok. This is taking much longer than expected. 
## I will make a pause for lunch. (...) Lunch is over. 
## Back to work. 

## Expand sensor component names
clean_names <- gsub("Acc", "_accelerometer", clean_names)
clean_names <- gsub("Gyro", "_gyroscope", clean_names)
clean_names <- gsub("Mag", "_magnitude", clean_names)
clean_names <- gsub("Jerk", "_jerk", clean_names)

## Clean up specific target statistical functions
clean_names <- gsub("-mean\\(\\)", "_mean", clean_names)
clean_names <- gsub("-std\\(\\)", "_std", clean_names)
clean_names <- gsub("-meanFreq\\(\\)", "_mean_frequency", clean_names)

## Remove remaining parentheses, hyphens, and commas
clean_names <- gsub("[\\(\\),-]", "_", clean_names)

## Clean up any leftover consecutive underscores and trailing underscores
clean_names <- gsub("_+", "_", clean_names)
clean_names <- gsub("_$", "", clean_names)

## Standardize to lowercase
clean_names <- tolower(clean_names)

## Save cleaned vector back to metadata
features$clean_name <- clean_names

## Verify that the names are as nice as expected
features$clean_name


# Step 3: Prepare the data frame now that we have nice column names.
## NOTE: I made a promise to play Fornite with my son. I´ll male a pause. 
## Back to work. I should be the worst Fornite player ever. 
## R is an oasis of peace. No. Wait. Coffee. Nice. Ready. Back to work. 
# ------------

## Read activity labels
activity_labels <- read.table(file.path(data_dir, "activity_labels.txt"), 
                              col.names = c("activity_id", "activity_name"))

## Load Training data with cleaned column names
subject_train <- read.table(file.path(data_dir, "train/subject_train.txt"), 
                            col.names = "subject")
y_train       <- read.table(file.path(data_dir, "train/y_train.txt"), 
                            col.names = "activity_id")
X_train       <- read.table(file.path(data_dir, "train/X_train.txt"), 
                            col.names = features$clean_name)
train_data    <- cbind(subject_train, y_train, dataset = "train", X_train)

## Load Test data with cleaned column names
subject_test  <- read.table(file.path(data_dir, "test/subject_test.txt"), 
                            col.names = "subject")
y_test        <- read.table(file.path(data_dir, "test/y_test.txt"), 
                            col.names = "activity_id")
X_test        <- read.table(file.path(data_dir, "test/X_test.txt"), 
                            col.names = features$clean_name)
test_data     <- cbind(subject_test, y_test, dataset = "test", X_test)

## Merge datasets
merged_data <- rbind(train_data, test_data)


# Step 4: Select the columns we were instructed to keep and drop the rest. 
## NOTE: I was a bit confused here because I didn't know if I should
## have kept meanFreq. Should it count as a mean value? I will assume 
## it is not. Fingers crossed. 
# ------------

## Keeps subject, activity_id, dataset, and columns that represent exact 
# mean() and std() metrics.
extracted_data <- merged_data %>%
  select(
    subject,
    activity_id,
    dataset,
    matches("_(mean|std)(_|$)")
  )

## Verify the dimensions of the extracted dataset
dim(extracted_data)


# Step 5: Replace activity codes with activity names
# ------------

## Convert activity_id into a factor with descriptive activity names
extracted_data <- extracted_data %>%
  mutate(
    activity = factor(
      activity_id, 
      levels = activity_labels$activity_id, 
      labels = activity_labels$activity_name
    )
  ) %>%
  ## Relocate 'activity' column to the front and drop numeric 'activity_id'
  select(subject, activity, dataset, everything(), -activity_id)

## Save the preliminary dataset, just in case. 
write.table(extracted_data, file = "preliminary_dataset.txt", row.name = FALSE)

# Step 6: Group by subject and activity, compute the mean and save.
# ------------

## Group by subject and activity, then compute the mean of each metric
tidy_summary <- extracted_data %>%
  group_by(subject, activity) %>%
  summarise(
    across(where(is.numeric), \(x) mean(x, na.rm = TRUE)),
    .groups = "drop"
  )

## Take a quick look to the data frame to verify if everything makes sense
View(tidy_summary)

## Save the final tidy dataset as a text file for submission
write.table(tidy_summary, file = "tidy_dataset.txt", row.name = FALSE)


