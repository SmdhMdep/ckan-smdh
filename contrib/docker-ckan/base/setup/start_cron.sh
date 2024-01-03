#!/bin/bash

crontab_file=$(mktemp)

# add your cron jobs below
cat <<EOF > $crontab_file
# min   hour    day     month   weekday command
*       *       *       *       *       ckan -c $CKAN_INI cloudstorage sync
0       *       *       *       *       ckan -c $CKAN_INI tracking update
0       *       *       *       *       ckan -c $CKAN_INI search-index rebuild

EOF

echo "updating crontab file"

crontab -l | cat - "$crontab_file" | crontab -

crontab -l

echo "starting cron service configuration"

cat cron_service.conf >> /etc/supervisord.conf

supervisorctl -c /etc/supervisord.conf reload
