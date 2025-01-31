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


dnf install mysql-server -y &>>$lOGS_FILE_NAME
VALIDATE $?  "installing mysql-server"

systemctl start mysqld  &>>$lOGS_FILE_NAME
VALIDATE $? "Enabling mysql-server"

systemctl start mysqld  &>>$lOGS_FILE_NAME
VALIDATE $? "Starting mysql-server"

mysql -h mysql.lakshman.site -u root -pExpenseApp@1 -e 'show databases;' &>>$lOGS_FILE_NAME
if [$? -ne 0]
then
    echo -e "mysql password not setup, $B setting up ..WAIT!!! $N " &>>$lOGS_FILE_NAME

    mysql_secure_installation --set-root-pass ExpenseApp@1  
    VALIDATE $? "Setting root password"
 else   
    echo -e "Mysql password $Y ..ALREADY SETUP ..SKIPPING $N "
fi
