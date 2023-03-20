#!/bin/sh

# This script is run as a NON-ESSENTIAL sidecar to Ckan, to check if CKAN is healthy
# and exit with a non-zero exit code if it is not and 0 if it is, so that it can be used as a condition 
# to control the start of other sidecar containers (Nginx in this case)

CKAN_URL="http://localhost:5000/api/3/action/status_show"
RETRIES=30
DELAY=5

# Wait for the CKAN application to be healthy
for i in $(seq 1 $RETRIES); do
  response=$(wget -qO- --timeout=2 "$CKAN_URL" 2>/dev/null)

  if echo "$response" | grep -q '"success": true'; then
    echo "CKAN is healthy"
    exit 0
  else
    echo "CKAN is not healthy (attempt $i of $RETRIES)"
    sleep $DELAY
  fi
done

# If reached here, CKAN is still not healthy
echo "CKAN failed to become healthy after $(($RETRIES * $DELAY)) seconds"
exit 1
