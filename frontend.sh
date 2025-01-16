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

dnf install nginx -y 
VALIDATE $? "Installing nginx"

systemctl enable nginx
VALIDATE $? "Enabling nginx"

systemctl start nginx
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Removing old version of code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "Downloading the code in /tmp/ folder"

cd /usr/share/nginx/html
VALIDATE $? "Moving to the html dir"

unzip /tmp/frontend.zip
VALIDATE $? "unzip the code"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copieng the configuration file "

systemctl restart nginx
VALIDATE $? "Restarting nginx"