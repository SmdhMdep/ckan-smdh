#!/bin/sh

sudo -u ckan -EH ckan -c $CKAN_INI run -H 0.0.0.0 &

echo "RUNNING 'ckan tracking update' at $(date)"
ckan tracking update
echo "COMPLETED 'ckan tracking update' at $(date)"

echo "RUNNING 'ckan search-index rebuild' at $(date)"
ckan search-index rebuild
echo "COMPLETED 'ckan search-index rebuild' at $(date)"

