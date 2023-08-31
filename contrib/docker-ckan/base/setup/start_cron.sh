#!/bin/bash

crontab_file=$(mktemp)

# add your cron jobs below
cat <<EOF > $crontab_file
# min   hour    day     month   weekday command
*       *       *       *       *       ckan -c $CKAN_INI cloudstorage sync

EOF

echo "updating crontab file"

crontab -l | cat - "$crontab_file" | crontab -

crontab -l

echo "starting cron service configuration"

cat cron_service.conf >> /etc/supervisord.conf

supervisorctl -c /etc/supervisord.conf reload
