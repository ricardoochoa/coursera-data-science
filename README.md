# Getting and Cleaning Data Course Project

Welcome to this beautiful repository, which contains my submission for the final project of the **Getting and Cleaning Data** course—part of the **Data Science Specialization** offered by **Johns Hopkins University** on Coursera. 

The goal of this project is to take raw, messy sensor data collected from smartphone accelerometers and convert it into a tidy, well-structured dataset ready for downstream analysis. 

---

## Repository Structure

```text
.
├── CodeBook.md          # Variable descriptions, data definitions, and summaries
├── data_raw/            # Local directory for extracted raw source data
│   └── UCI HAR Dataset/ # Extracted raw dataset files
│       ├── activity_labels.txt
│       ├── features_info.txt
│       ├── features.txt
│       ├── README.txt
│       ├── test/        # Test dataset (subject_test.txt, X_test.txt, y_test.txt)
│       └── train/       # Training dataset (subject_train.txt, X_train.txt, y_train.txt)
├── README.md            # Repository overview and execution workflow
├── run_analysis.R       # Complete R script for downloading, cleaning, and processing
└── tidy_dataset.txt     # Final generated tidy summary dataset (180 rows, 68 columns)

```

### File Highlights

* **`run_analysis.R`**: The main R script that handles the entire pipeline end-to-end (downloading raw data, renaming features, binding datasets, extracting target metrics, labeling activities, and saving the tidy summary).


* **`tidy_dataset.txt`**: The final output text file created by `run_analysis.R`. It contains subject and activity averages for all extracted mean and standard deviation metrics.


* **`CodeBook.md`**: Explains all variables in `tidy_dataset.txt`, including measurement definitions, units, and processing steps.


* **`data_raw/UCI HAR Dataset/`**: Contains the raw input files. Note that while raw time-series files exist inside the `Inertial Signals` subfolders, they are not directly used because pre-calculated summary features are already provided in `X_train.txt` and `X_test.txt`.



---

## Analysis Methodology (`run_analysis.R`)

The script follows a 6-step workflow to transform raw input files into a tidy deliverable:

### Step 1: Data Download and Setup

The script defines the source download URL, fetches the dataset zip archive, extracts its contents into `data_raw/`, and immediately deletes the downloaded `.zip` file to keep the workspace clean.

### Step 2: Feature Name Cleaning

Raw feature names in `features.txt` are full of abbreviations, hyphens, and parentheses (e.g., `tBodyAcc-mean()-X`). Using pattern matching (`gsub`), the script cleans these into descriptive names:

* Corrects duplicate typos (e.g., `BodyBody` $\rightarrow$ `Body`).


* Expands domain prefixes (`t` $\rightarrow$ `time_`, `f` $\rightarrow$ `frequency_`).


* Expands sensor names (`Acc` $\rightarrow$ `_accelerometer`, `Gyro` $\rightarrow$ `_gyroscope`, `Mag` $\rightarrow$ `_magnitude`, `Jerk` $\rightarrow$ `_jerk`).


* Removes special characters (`()`, `-`, `,`) and normalizes names to lower `snake_case`.


### Step 3: Dataset Assembly

The script reads `subject`, `y` (activity IDs), and `X` (feature values) for both training and testing datasets:

* Clean feature names are assigned directly as column headers on import.


* A `dataset` column is added (`"train"` or `"test"`) for data provenance.


* Columns are combined side-by-side (`cbind`), and then training and test partitions are stacked vertically (`rbind`) into a single data frame.

### Step 4: Extracting Target Measurements

Per assignment instructions, the script filters the combined dataset using regular expressions (`matches("_(mean|std)(_|$)")`) to keep only variables representing exact mean and standard deviation measurements. Weighted averages like `meanFreq()` and `angle()` vectors are excluded to maintain strict compliance with exact metric definitions.

### Step 5: Assigning Descriptive Activity Names

Numeric activity IDs (1–6) are converted into descriptive factor levels (`WALKING`, `WALKING_UPSTAIRS`, `WALKING_DOWNSTAIRS`, `SITTING`, `STANDING`, `LAYING`) imported from `activity_labels.txt`.

### Step 6: Tidy Dataset Aggregation

Finally, the script groups the dataset by `subject` and `activity`. It calculates the average of every numerical measurement across all observations using `summarise(across(...))`. The resulting 180-row dataset ($30 \text{ subjects} \times 6 \text{ activities}$) is written to `tidy_dataset.txt` using `write.table(..., row.name = FALSE)`.

