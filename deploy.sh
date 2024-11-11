#!/bin/bash

# File: deploy.sh

# Clear the list of Lambda Layers ARN in README.md
README_FILE="README.md"
REGION_FILE="regions.txt"
LAYER_NAME="lambda-logger-extension"

# Clear the section in README.md
sed -i '/## List of Lambda Layers ARN/,$d' $README_FILE
echo -e "## List of Lambda Layers ARN\n" >> $README_FILE

# Get all AWS regions
all_regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# Read the regions from regions.txt into an array
mapfile -t valid_regions < $REGION_FILE

# Loop through all AWS regions and check if they are in the valid regions list
for region in $all_regions; do
  if [[ " ${valid_regions[@]} " =~ " $region " ]]; then
    echo "Deploying to region: $region"
    AWS_REGION=$region npm run deploy

    # Fetch the ARN of the deployed layer
    layer_arn=$(aws lambda list-layer-versions --layer-name $LAYER_NAME --region $region --query "LayerVersions[0].LayerVersionArn" --output text)

    # Append the ARN to README.md
    if [ -n "$layer_arn" ]; then
      echo "- $region: \`$layer_arn\`" >> $README_FILE
    else
      echo "Failed to get ARN for region: $region"
    fi
  else
    echo "Skipping region: $region"
  fi
done

echo "Deployment complete and README.md updated."
