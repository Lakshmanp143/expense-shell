#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"
USERID=$(id -u)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGS_FOLDER="/var/log/expense-logs"
LOGS_FILE=$(echo $0 | cut -d "." -f1)
lOGS_FILE_NAME="$LOGS_FOLDER/$LOGS_FILE-$TIMESTAMP.log"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "ERROR:: $B You must be root user to execute this script $N "
        exit 1
    fi
}
mkdir -p $LOGS_FOLDER
echo "Script started executing at:: $TIMESTAMP" &>>$lOGS_FILE_NAME

CHECK_ROOT
 
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...... $R FAILURE $N "
        exit 1
    else
        echo -e "$2 ...... $G SUCCESS $N "
    fi
}

dnf module disable nodejs -y  &>>$lOGS_FILE_NAME
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:20 -y  &>>$lOGS_FILE_NAME
VALIDATE $? "Ebabling nodejs:20 version"

dnf install nodejs -y  &>>$lOGS_FILE_NAME
VALIDATE $? "Installing nogejs:20 version"

id expense  &>>$lOGS_FILE_NAME
if [ $? -ne 0 ]
then
    useradd expense  &>>$lOGS_FILE_NAME
    VALIDATE $? "Adding user expense"
else 
    echo -e "User expense already exist $Y SKIPPING $N "
fi

mkdir -p /app  &>>$lOGS_FILE_NAME
VALIDATE $? "Creating /app/ directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>>$lOGS_FILE_NAME
VALIDATE $? "Downloading the code in tmp folder"

cd /app
rm -rm /app/*

unzip /tmp/backend.zip  &>>$lOGS_FILE_NAME
VALIDATE $? "unzip the code"

npm install  &>>$lOGS_FILE_NAME
VALIDATE $? "Installing dependies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service  &>>$lOGS_FILE_NAME
VALIDATE $? "Copieng the backend.servive file"

dnf install mysql -y  &>>$lOGS_FILE_NAME
VALIDATE $? "Installing mysql client"

mysql -h mysql.lakshman.site -uroot -pExpenseApp@1 < /app/schema/backend.sql  &>>$lOGS_FILE_NAME
VALIDATE $? "Adding schema"

systemctl daemon-reload  &>>$lOGS_FILE_NAME
VALIDATE $? "Daemon reload"

systemctl enable backend  &>>$lOGS_FILE_NAME
VALIDATE $? "Enabling backend"

systemctl restart backend  &>>$lOGS_FILE_NAME
VALIDATE $? "Starting backend"