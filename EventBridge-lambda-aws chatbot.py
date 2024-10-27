# setup EventBridge with lambda to invoke aws chatbot to send notification to team channel whenever anythings happened in the SG 
import json
import urllib3
import os
import boto3  # Ensure boto3 is imported

http = urllib3.PoolManager()

def main(event):
    print("EVENT")
    print(event)
    
    # Fetch environment variables
    ctevent = event["detail"]["eventName"]
    AwsRegion = event["detail"]["awsRegion"]
    User = event["detail"]["userIdentity"]["arn"].split('/')[-1]
    MFA = event["detail"]["userIdentity"]["sessionContext"]["attributes"]["mfaAuthenticated"]
    eventTime = event["detail"]["eventTime"]
    SourceIp = event["detail"]["sourceIPAddress"]
    
    facts = [
        {"name": "Event", "value": ctevent},
        {"name": "Region", "value": AwsRegion},
        {"name": "User", "value": User},
        {"name": "MFA", "value": MFA},
        {"name": "Time", "value": eventTime},
        {"name": "SourceIp", "value": SourceIp}
    ]
    
    if ctevent == "CreateSecurityGroup":
        SecGroup_ID = event["detail"]["responseElements"]["groupId"]
        facts.append({"name": "Security Group ID", "value": SecGroup_ID})
   
    elif ctevent in ["AuthorizeSecurityGroupIngress", "RevokeSecurityGroupIngress"]:
        SecGroup_ID = event["detail"]["requestParameters"]["groupId"]
        IpPermissions = event["detail"]["requestParameters"]["ipPermissions"]["items"]
        strIpPermissions = json.dumps(IpPermissions, indent=2)  # Pretty print
        facts.append({"name": "Security Group ID", "value": SecGroup_ID}) 
        facts.append({"name": "IpPermissions", "value": strIpPermissions})

    elif ctevent == "DeleteSecurityGroup":
        SecGroup_ID = event["detail"]["requestParameters"]["groupId"]
        facts.append({"name": "Security Group ID", "value": SecGroup_ID})

    notification = {
        "@type": "MessageCard",
        "@context": "https://schema.org/extensions",
        "summary": "SecurityGroup Notification",
        "themeColor": "0078D7",
        "title": ctevent,
        "sections": [
            {
                "facts": facts,
            }
        ]
    }

    client = boto3.client('chatbot')
    try:
        response = client.send_message(
            chatChannelArn="arn:aws:chatbot::694139255278:chat-configuration/microsoft-teams-channel/TEST-SG-CHANGE-ALERT",  # Use environment variable
            message=json.dumps(notification)
        )
        print({
            "message": notification, 
            "status_code": response['ResponseMetadata']['HTTPStatusCode'], 
            "response": response
        })
    except Exception as e:
        print(f"Error sending message: {e}")
    
    return

def lambda_handler(event, context):
    main(event)
    return
