#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"
USERID=$(id -u)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGS_FOLDER="/var/log/shell-script.logs"
LOGS_FILE=$(echo $0 | cut -d "." -f1)
lOGS_FILE_NAME="$LOGS_FOLDER/$LOGS_FILE-$TIMESTAMP.log"

SOURCR_DIR="/home/ec2-user/app-logs/"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "ERROR:: $B You must be root user to execute this script $N "
        exit 1
    fi
}
mkdir -p $LOGS_FOLDER
echo "Script started executing at:: $TIMESTAMP" &>>$lOGS_FILE_NAME



VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...... $R FAILURE $N "
        exit 1
    else
        echo -e "$2 ...... $G SUCCESS $N "
    fi
}


FILES_TO_DELETE=$(find $SOURCR_DIR -name "*.log" -mtime +14)
echo "Files to be deleted:: $FILES_TO_DELETE"

while read -r filepath
do 
    echo "Deleting file:: "$filepath
done <<< $FILES_TO_DELETE