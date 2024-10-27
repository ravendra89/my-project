#!/bin/bash

# Fetch the list of S3 buckets
buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text)

# Iterate over each bucket
for bucket in $buckets; do
    echo "Checking bucket: $bucket"

    # Fetch the bucket ACL and policy status
    acl=$(aws s3api get-bucket-acl --bucket "$bucket" 2>/dev/null)
    policy_status=$(aws s3api get-bucket-policy-status --bucket "$bucket" 2>/dev/null)

    # Check if bucket ACL or policy indicates public access
    if echo "$acl" | grep -q "AllUsers" || echo "$policy_status" | grep -q '"IsPublic": true'; then
        echo "Bucket $bucket is PUBLIC"
    else
        echo "Bucket $bucket is PRIVATE"
    fi
done
