#!/bin/sh

### Install Dependencies
sudo yum update -y

### SSM Agent Install
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
 
### Install AWS CLI
sudo yum install -y unzip
sudo yum remove -y awscli
cd /home/ec2-user/
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sudo ln -s /usr/local/bin/aws /usr/bin/aws
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
aws --version
 
### Install CloudWatch Agent package
sudo yum install -y amazon-cloudwatch-agent
sudo su
aws ssm get-parameter --name "/cwagent/amazonlinux/configuration" --query "Parameter.Value" --output text --region us-east-1 > /opt/aws/amazon-cloudwatch-agent/bin/config.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
sudo systemctl restart amazon-cloudwatch-agent
sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl status amazon-cloudwatch-agent
