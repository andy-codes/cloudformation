#!/bin/bash

aws s3 cp s3://

yum -y update && yum -y install httpd && service httpd restart

cd /var/www/html/ && echo 'Test' > index.html