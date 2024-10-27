#!/bin/bash
if [ "${environment}" == "PROD" ]; then
    sleep 120
        
	# Define the S3 bucket variable
        s3Bucket="ymcareers-devops"

        # Define S3 bucket path to download splunk file
        FILE_NAME=$(aws ssm get-parameter --name "/splunk/uf-agent/amazon-linux/name" --region "us-east-1" --query "Parameter.Value" --output text)
        OBJECT_KEY="splunk/amazon-linux/$FILE_NAME"
        DOWNLOAD_PATH="/tmp/$FILE_NAME"
        # Download and install the package
        aws s3 cp s3://$s3Bucket/$OBJECT_KEY $DOWNLOAD_PATH
        sudo rpm -i $DOWNLOAD_PATH
        
        # Set up Splunk configuration
        echo "[user_info]" | sudo tee -a /opt/splunkforwarder/etc/system/local/user-seed.conf
        echo "USERNAME = admin" | sudo tee -a /opt/splunkforwarder/etc/system/local/user-seed.conf
        echo "PASSWORD = 9IEz9kb3RB" | sudo tee -a /opt/splunkforwarder/etc/system/local/user-seed.conf
        sudo /opt/splunkforwarder/bin/splunk enable boot-start -user root --accept-license --answer-yes --no-prompt
        sudo /opt/splunkforwarder/bin/splunk set deploy-poll 172.16.3.100:8089 -auth admin:9IEz9kb3RB
        sudo chown -R splunkfwd:splunkfwd /opt/splunkforwarder
        
        # Set up Splunk service
        aws s3 cp s3://$s3Bucket/splunk/amazon-linux/SplunkForwarder.service /etc/systemd/system/SplunkForwarder.service

    sudo systemctl daemon-reload
    sudo systemctl start SplunkForwarder
    sudo systemctl enable SplunkForwarder

    ### Optional Commands
    # sudo systemctl status SplunkForwarder
    # sudo /opt/splunkforwarder/bin/splunk start
    # sudo /opt/splunkforwarder/bin/splunk status
    # sudo /opt/splunkforwarder/bin/splunk stop
fi
