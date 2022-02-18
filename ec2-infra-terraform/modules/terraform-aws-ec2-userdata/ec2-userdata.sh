#!/bin/bash

 #Install SSM agent on EC2
echo "Installing SSM Agent to connect to EC2 using Session Manager"
cd /tmp
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

echo "Installing Docker"
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

echo "Installed Python Modules - Requests and Docker Modules"
sudo pip3 install requests
sudo pip3 install docker