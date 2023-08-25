#!/bin/bash

log() {
    echo "$(date -u -Iseconds) $1 $2" >&2
}

count=$(rq info --url "$CKAN_REDIS_URL" --only-workers --raw | wc -l)

if [[ "$count" > 0 ]]
then
    log INFO "$count workers are running"
    exit 0
else
    log ERROR "no workers are running"
    exit 1
fi
