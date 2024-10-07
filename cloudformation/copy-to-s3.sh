#!/bin/bash

# Define the export name used in the CloudFormation stack output
export_name="LoggerExtensionBucketName" # Adjust this if the actual export name differs

# Fetch the S3 bucket name using the defined export name
bucket_name=$(aws cloudformation list-exports --query "Exports[?Name=='$export_name'].Value" --output text)

# Check if the bucket name was retrieved
if [ -z "$bucket_name" ]; then
    echo "Failed to retrieve S3 bucket name from CloudFormation exports"
    exit 1
else
    echo "Using bucket name: $bucket_name"
fi

# Path to the Lambda layer zip file
file_path="./dist/extension.zip"

# Upload the zip file to the S3 bucket
aws s3 cp $file_path s3://$bucket_name/

echo "File uploaded successfully to $bucket_name"
