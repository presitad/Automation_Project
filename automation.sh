#!/usr/bin/env bash
apt update -y
dpkg --get-selections | grep apache > /dev/null 2>&1
if [ $? != 0 ]
then
        apt install apache2 -y
fi
service apache2 status | grep "active (running)" > /dev/null 2>&1
if [ $? != 0 ]
then
        service apache2 restart > /dev/null
fi
timestamp=$(date '+%d%m%Y-%H%M%S')
myname=presita
s3_bucket=upgrad-presitadharme
tar -cvf  /tmp/${myname}-httpd-logs-${timestamp}.tar  /var/log/apache2/access.log /var/log/apache2/error.log
apt install awscli -y
aws s3 \
        cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
        s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
        
IFS='
'
execute=`find /tmp -mmin -1 -type f -exec ls -lh {} +`
cat /var/www/html/inventory.html
if [ $? != 0 ]
then
        echo -e "Log Type  \tDate Created  \t Type \t Size" >>  /var/www/html/inventory.html
    execute=`ls -lh /tmp/*-httpd-logs*.tar`
fi

trs=""
for line in $execute;
do
    Size=`echo $line| awk '{print $5}'`
    file=`echo $line| awk -F/ '{ print $3}'`
    LogType=`echo  $file | awk -F- '{ print $2"-"$3}'`
    time=`echo $file | awk -F- '{print $NF}'|awk -F. '{print $1}'`
    date=`echo  $file | awk -F- '{ print $4}'`
    DateCreated=`echo $date"-"$time`
    Type=`echo  $file | awk -F. '{print $2}'`

    echo -e "$LogType  \t$DateCreated  \t$Type \t$Size" >>  /var/www/html/inventory.html
done
cat /etc/cron.d/automation  > /dev/null 2>&1
if [ $? != 0 ]
then
        echo "0 0 * * *  root /root/Automation_Project/automation.sh" >>  /etc/cron.d/automation
fi
