Getting-and-Cleaning-Data
=========================

Steps taken are:

* Load library for the "rowSds" function
* Define folders, subfolders and file names
* Merge the training and test sets + prepare IDs and activities
* Check dimensions and NAs
* Calculate means and SDs and merge with IDs and activities
* Name columns
* Convert respective columns to factors
* Assign labels to factors
* Create independent data set with the average of each variable for each activity
* Cast aggregated data set to get separate variables for each measurement
* Cast original data set to get separate variables for each measurement
* First - for means
* Then for SDs
* Merge Means and SDs variables
* Finalize variables names
