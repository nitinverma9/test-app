#!/bin/bash
sudo yum install -y httpd
echo "Hello from $(hostname -I)" > /var/www/html/index.html
sudo systemctl enable httpd.service
sudo systemctl start httpd.service