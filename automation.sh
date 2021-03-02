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
