#!/bin/bash

# Required tools: yq for processing yml file, jq for processing json files, sed for post-processing
set -euo pipefail

# Load the sidecar container definition
sidecar_container=$(yq e -o=json nginx-sidecar.yml)

# Load the CloudFormation template generated by the "convert" command
cloudformation_template=$(docker compose -f docker-compose.yml -f docker-compose.prod.yml --env-file prod.env convert)

# Convert the CloudFormation template to JSON
cloudformation_json=$(yq e -o=json - <<< "$cloudformation_template")

# Inject the sidecar container into the CkanTaskDefinition
updated_json=$(echo "$cloudformation_json" | jq --argjson sidecar "$sidecar_container" '.Resources.CkanTaskDefinition.Properties.ContainerDefinitions += [$sidecar]')

# Change the port mapping for the ckan container from 80 to 5000 to keep the ALB 
updated_json=$(echo "$updated_json" | jq '(.Resources.CkanTaskDefinition.Properties.ContainerDefinitions[] | select(.Name == "ckan").PortMappings[] | select(.ContainerPort == 80).ContainerPort) |= 5000')

# Convert the updated JSON back to YAML
updated_template=$(yq e -P - <<< "$updated_json")

# Replace the timestamps with the original date formats
updated_template=$(echo "$updated_template" | sed -e 's/"2012-10-17T00:00:00Z"/2012-10-17/' -e 's/"2010-09-09T00:00:00Z"/2010-09-09/')

# Output the updated CloudFormation template
echo "$updated_template"
