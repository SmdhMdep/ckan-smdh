#!/bin/bash

# Required tools: yq for processing yml file, jq for processing json files, sed for post-processing
set -euo pipefail

# Load the sidecar containers definition
nginx_sidecar_container=$(yq e -o=json nginx-sidecar.yml)
healthcheck_sidecar_container=$(yq e -o=json healthcheck-sidecar.yml)

# Load the CloudFormation template generated by the "convert" command
cloudformation_template=$(docker compose -f docker-compose.yml -f docker-compose.prod.yml --env-file .env convert)

# Convert the CloudFormation template to JSON
cloudformation_json=$(yq e -o=json - <<< "$cloudformation_template")

# Inject the sidecar containers into the CkanTaskDefinition
updated_json=$(echo "$cloudformation_json" | jq --argjson sidecar "$nginx_sidecar_container" '.Resources.CkanTaskDefinition.Properties.ContainerDefinitions += [$sidecar]')
updated_json=$(echo "$updated_json" | jq --argjson sidecar "$healthcheck_sidecar_container" '.Resources.CkanTaskDefinition.Properties.ContainerDefinitions += [$sidecar]')

# Change the port mapping for the ckan container from 80 to 5000
updated_json=$(echo "$updated_json" | jq '(.Resources.CkanTaskDefinition.Properties.ContainerDefinitions[] | select(.Name == "ckan").PortMappings[] | select(.ContainerPort == 80).ContainerPort) |= 5000')

# Delete the host port from the ckan container port mapping so that only port 80 (for Nginx) is exposed
updated_json=$(echo "$updated_json" | jq 'del(.Resources.CkanTaskDefinition.Properties.ContainerDefinitions[] | select(.Name == "ckan").PortMappings[] | select(.ContainerPort == 5000).HostPort)')

# Change the load balancer container name from ckan to nginx so that the ALB refers to the Nginx container
updated_json=$(echo "$updated_json" | jq '(.Resources.CkanService.Properties.LoadBalancers[] | select(.ContainerName == "ckan").ContainerName) = "nginx"')


# Convert the updated JSON back to YAML
updated_template=$(yq e -P - <<< "$updated_json")

# Replace the timestamps with the original date formats
updated_template=$(echo "$updated_template" | sed -e 's/"2012-10-17T00:00:00Z"/2012-10-17/' -e 's/"2010-09-09T00:00:00Z"/2010-09-09/')

# Add the two lines at the beginning of the updated template and indent the rest of the content under x-aws-cloudformation;
# The reason for this is that we are going to use the whole generated CloudFormation template as a value for the x-aws-cloudformation,
# i.e., tricking compose-cli into thinking that the whole updated template is a an overlay of the original template, so we can feed it to the
# docker compose UP command
updated_template=$(cat <<- EOM
x-aws-loadbalancer: "MDEP-dev-ALB"
x-aws-cloudformation:
$(echo "$updated_template" | sed 's/^/  /')
EOM
)

# Output the updated CloudFormation template
echo "$updated_template" > cf_temp.yml
