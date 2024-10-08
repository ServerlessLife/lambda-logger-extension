#!/bin/bash

# Path to the Lambda layer zip file
file_path="./dist/extension.zip"

# Compute MD5 hash of the file content
hash_value=$(md5sum $file_path | awk '{ print $1 }')

# Create a new filename by appending the hash value
new_file_name="extension-${hash_value}.zip"

# Copy the file to a new name to include the hash
cp $file_path "./dist/$new_file_name"

# Retrieve the bucket name using CloudFormation export
export_name="LoggerExtensionBucketName"
bucket_name=$(aws cloudformation list-exports --query "Exports[?Name=='$export_name'].Value" --output text)

# Check if the bucket name was retrieved
if [ -z "$bucket_name" ]; then
    echo "Failed to retrieve S3 bucket name from CloudFormation exports"
    exit 1
else
    echo "Using bucket name: $bucket_name"
fi

# Upload the new zip file to the S3 bucket
aws s3 cp "./dist/$new_file_name" s3://$bucket_name/

echo "File $new_file_name uploaded successfully to $bucket_name"

aws cloudformation deploy --stack-name lambda-logger-extension --template-file cloudformation/layer.yaml  --parameter-overrides S3Key=extension-${hash_value}.zip \