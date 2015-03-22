#This script contains the steps to preform the requirements for Course projects
#1.downloading data file to workspace directory
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile="./dataset.zip",method="curl")

#2.unzip dataset to workspace directory
unzip("./dataset.zip")

#3.reading training data and test data 
#Reading the train data, the observation labels (activity label) and the id for the subject based on Readme file explanation of files
trainData<-read.table("./UCI HAR Dataset/train/X_train.txt")
str(traindata)
trainDataLabels<-read.table("./UCI HAR Dataset/train/y_train.txt")
names(trainDataLabels)<-"Activity"
str(trainDataLabels)
trainDataSubjects<-read.table("./UCI HAR Dataset/train/subject_train.txt")
str(trainDataSubjects)
names(trainDataSubjects)<-"SubjectID"

#We will do the same for the test data
testData<-read.table("./UCI HAR Dataset/test/X_test.txt")
str(testData)
testDataLabels<-read.table("./UCI HAR Dataset/test/y_test.txt")
str(testDataLabels)
names(testDataLabels)<-"Activity"
testDataSubjects<-read.table("./UCI HAR Dataset/test/subject_test.txt")
str(testDataSubjects)
names(testDataSubjects)<-"SubjectID"

#4.reading the columns name from features.txt file
colnamesData<-read.table("./UCI HAR Dataset/features.txt",header=FALSE,strip.white=TRUE,colClasses=c(rep("NULL",1),rep("factor",1)))
colnames<-unlist(colnamesData)


#5.setting the column names on the train and test data
names(trainData)<-colnames
names(testData)<-colnames

#We will column bind the three tables so that each observation has the features value, the activity label and the subject id
allTrainData<-cbind(trainData,trainDataLabels,trainDataSubjects)
#We will column bind the three tables so that each observation has the features value, the activity label and the subject id
allTestData<-cbind(testData,testDataLabels,testDataSubjects)



#6. Mereging the train and test data together using rbind() (Requirement 1)
allData<-rbind(allTrainData,allTestData)
str(allData) #the number of obeservation should be equal to sum of observation in train and test data
valid_column_names <- make.names(names=names(allData), unique=TRUE, allow_ = TRUE)
names(allData) <- valid_column_names #this is to remove any duplication in column name as I encountered this problem and found this fix on stackoverflow


#7. Selecting the measurements on the mean and standard deviation for each measurement (Requirement 2)
library(dplyr)
meanAndStdDevData<-select(allData,contains("mean"),contains("std"),contains("Activity"),contains("SubjectID"))
str(meanAndStdDevData) #should be same number of observation as allData but with less variables/columns

#8.Reading names of activity from file and replacing each activity id with its name(Requirement 3)
activitynames<-read.table("./UCI HAR Dataset/activity_labels.txt")
#Replacting the activity number by its name
allData<-mutate(allData,Activity=activitynames[Activity,2])

#9. Renaming column names with descriptive names (Requirment 4)
# Replacing Acc with Accelerometer
# Replacing Gyro with Gyroscope 
# Replcaing Mag with Magnitude
# Replcaing fBody with FFTFrequencyBody
names(allData)<-gsub("Acc","Accelerometer",names(allData))
names(allData)<-gsub("Gyro","Gyroscope",names(allData))
names(allData)<-gsub("Mag","Magnitude",names(allData))
names(allData)<-gsub("fBody","FFTFrequency",names(allData))

#10. Creating tidy data by grouping with Subject Name and Activity and getting mean of each variable for that grouping(Requirement 5)
groupSubjectAndActivity<-group_by(allData,SubjectID,Activity)
tidyData<-summarise_each(groupSubjectAndActivity,funs(mean))
#Viewing tidy data
View(tidyData)
#writing tidy data to file
write.csv(tidyData,"./tidyData.csv")