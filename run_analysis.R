# Load library for the "rowSds" function
library("matrixStats")
library("reshape")

# Define folders, subfolders and file names
DFolder<-"/UCI HAR Dataset"
SFolders<-c("/test/","/train/")
SSFolder<-"Inertial Signals/"
DFiles<-c("body_acc_x_", "body_acc_y_", "body_acc_z_",
          "body_gyro_x_", "body_gyro_y_", "body_gyro_z_",
          "total_acc_x_", "total_acc_y_", "total_acc_z_")
mExt<-c("test.txt", "train.txt")

# Merge the training and test sets + prepare IDs and activities
for (i in 1:2) {
  header<-read.table(paste(getwd(), DFolder, SFolders[i],"subject_",mExt[i],sep=""))
  inDataH<-read.table(paste(getwd(), DFolder, SFolders[i],"y_",mExt[i],sep=""))
  for (j in 1:length(DFiles)) {
    headerN<-cbind(header,i,inDataH,j)
    if (j==1) {mHeader<-headerN}
    else {mHeader<-rbind(mHeader,headerN)}
    inData<-read.table(paste(getwd(), DFolder, SFolders[i],SSFolder,
                             DFiles[j],mExt[i],sep=""))
    if (j==1) {fData<-inData}
    else {fData<-rbind(fData,inData)}
  }
  if (i==1) {
    sfinal<-fData
    sfHeader<-mHeader
  }
  else {
    sfinal<-rbind(sfinal,fData)
    sfHeader<-rbind(sfHeader,mHeader)
  }
}
# Check dimensions and NAs
dim(sfinal)
dim(sfHeader)
sum(is.na(sfinal))
sum(is.na(sfHeader))
# Calculate means and SDs and merge with IDs and activities
mResults<-cbind(sfHeader,rowMeans(sfinal),rowSds(sfinal))
# Name columns
colnames(mResults)<-c("Subject_Number","Group","Activity","Variable", "ObsMean","ObsSD")
# Convert respective columns to factors
mResults[,2:4] <- data.frame(apply(mResults[,2:4], 2, as.factor))
# Assign labels to factors
levels(mResults$Group) <- c("Test", "Train")
aNames<-read.table(paste(getwd(), DFolder, "/","activity_labels.txt",sep=""))
levels(mResults$Activity) <- aNames[,2]
levels(mResults$Variable) <- substr(DFiles,1,nchar(DFiles)-1)

# Create independent data set with the average of each variable for each activity
mAggr<-aggregate(mResults$ObsMean,
                 list(mResults$Subject_Number, mResults$Activity,mResults$Variable), mean)
colnames(mAggr)<-c("Subject_Number","Activity","Variable", "GMean")

# Cast aggregated data set to get separate variables for each measurement
mAggr2<-cast(mAggr,Subject_Number+Activity~Variable)

# Cast original data set to get separate variables for each measurement
# First - for means
mResults2<-cast(mResults,Subject_Number+Activity~Variable,mean,value="ObsMean")
colnames(mResults2)<-paste("Mean_",names(mResults2),sep="")
# Then for SDs
mResults_<-cast(mResults,Subject_Number+Activity~Variable,mean,value="ObsSD")
colnames(mResults_)<-paste("SD_",names(mResults_),sep="")
# Merge Means and SDs variables
mResults2<-cbind(mResults2,mResults_[,3:11])
# Finalize variables names
names(mResults2)[1] <- "Subject_Number"
names(mResults2)[2] <- "Activity"

# Write results to .txt files
#write.table(mResults, "mResults.txt", sep="\t",row.names=FALSE)
#write.table(mResults2, "mResults2.txt", sep="\t",row.names=FALSE)
#write.table(mAggr, "mAggr.txt", sep="\t",row.names=FALSE)
write.table(mAggr2, "Tidy_Data.txt", sep="\t",row.names=FALSE)