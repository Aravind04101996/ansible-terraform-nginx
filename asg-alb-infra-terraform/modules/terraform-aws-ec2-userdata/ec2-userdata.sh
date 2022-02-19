#!/bin/bash

S3_BUCKET="${s3_bucket}" 
PLAYBOOK="${playbook}" 
VARS_FILE="${vars_file}" 

echo "Installing SSM Agent to connect to EC2 using Session Manager"
cd /tmp
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

echo "Installing Ansible"
sudo yum update -y
sudo amazon-linux-extras install ansible2 -y
ansible --version

echo "Installing Docker"
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

echo "waiting for docker installation to complete"
sleep 120s

echo "Installing Python Modules - Requests and Docker Modules"
sudo yum install pip -y
sudo pip install requests
sudo pip install docker

echo "waiting for ansible installation to complete"
sleep 120s

echo "Downloading Ansible Playbook from S3"
aws s3 cp s3://$${S3_BUCKET}/$${PLAYBOOK} /tmp/playbook.zip
sudo chmod 644 /tmp/playbook.zip
sudo yum install -y unzip
sudo unzip -o /tmp/playbook.zip
ansible-playbook /tmp/ansible-nginx-playbook/webserver_playbook.yml --extra-vars $${VARS_FILE}