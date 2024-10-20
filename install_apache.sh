#!/bin/bash

yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello World from $(hostname -f)" > /var/www/html/index.html
yum install -y docker
systemctl start docker
docker run --name webapp -d -it -p 8080:8080 deepak2717/devopswithdeepak-docker-webapp-demo:v2.0
