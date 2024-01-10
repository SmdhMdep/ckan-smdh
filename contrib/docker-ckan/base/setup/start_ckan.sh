#!/bin/bash

# This script is run by the ckan container to start CKAN

# Run the prerun script to init CKAN and create the default admin user
echo "Running prerun script"
python3 $APP_DIR/prerun_prod.py

echo "Override ckan.ini sqlalchemy.url default value"
ckan config-tool $CKAN_INI "sqlalchemy.url = $CKAN_SQLALCHEMY_URL"

echo "Override SQLAlchemy config"
ckan config-tool $CKAN_INI "sqlalchemy.pool_size = 10"
ckan config-tool $CKAN_INI "sqlalchemy.pool_timeout = 30"
ckan config-tool $CKAN_INI "sqlalchemy.max_overflow = 10"
ckan config-tool $CKAN_INI "sqlalchemy.pool_recycle = 1800"

echo "Override ckan.ini datastore settings"
ckan config-tool $CKAN_INI "ckan.datastore.write_url = $CKAN_DATASTORE_WRITE_URL"
ckan config-tool $CKAN_INI "ckan.datastore.read_url = $CKAN_DATASTORE_READ_URL"

echo "Setting up beaker to use the database instead of disk"
ckan config-tool $CKAN_INI "beaker.session.type = ext:database"
ckan config-tool $CKAN_INI "beaker.session.url = $CKAN_SQLALCHEMY_URL"

echo "Setting up session timeout"
ckan config-tool $CKAN_INI "who.timeout = $CKAN_SESSION_TIMEOUT"


# Run any startup scripts provided by images extending this one
if [[ -d "/docker-entrypoint.d" ]]
then
    for f in /docker-entrypoint.d/*; do
        case "$f" in
            *.sh)     echo "$0: Running init file $f"; . "$f" ;;
            *.py)     echo "$0: Running init file $f"; python3 "$f"; echo ;;
            *)        echo "$0: Ignoring $f (not an sh or py file)" ;;
        esac
        echo
    done
fi

# Set the common uwsgi options
UWSGI_OPTS="--plugins http,python \
            --socket /tmp/uwsgi.sock \
            --wsgi-file /srv/app/wsgi.py \
            --module wsgi:application \
            --uid 92 --gid 92 \
            --http 0.0.0.0:5000 \
            --master --enable-threads \
            --lazy-apps \
            -p 4 -L -b 32768 --vacuum \
            --harakiri $UWSGI_HARAKIRI"

echo "Enabling ckan tracking"
ckan config-tool $CKAN_INI "ckan.tracking_enabled = true"

# echo "Loading Datapusher+ settings into ckan.ini"
# ckan config-tool $CKAN_INI "ckan.datapusher.formats = csv xls xlsx xlsm xlsb tsv tab application/csv application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet ods application/vnd.oasis.opendocument.spreadsheet"

echo "Loading default views into ckan.ini"
ckan config-tool $CKAN_INI "ckan.views.default_views = image_view text_view datatables_view pdf_view"

echo "Loading FrontEnd settings into ckan.ini"
ckan config-tool $CKAN_INI "ckan.site_title = Asset Explorer"
ckan config-tool $CKAN_INI "ckan.site_logo = /base/images/Mdep_black_yellow_logo.svg"
# ckan config-tool $CKAN_INI "ckan.site_description = "
ckan config-tool $CKAN_INI "ckan.favicon = /base/images/mdep_favicon.ico"

echo "Loading Email settings into ckan.ini"
ckan config-tool $CKAN_INI "smtp.server = $CKAN_SMTP_SERVER"
ckan config-tool $CKAN_INI "smtp.starttls = $CKAN_SMTP_STARTTLS"
ckan config-tool $CKAN_INI "smtp.user = $CKAN_SMTP_USER"
ckan config-tool $CKAN_INI "smtp.password = $CKAN_SMTP_PASSWORD"
ckan config-tool $CKAN_INI "smtp.mail_from = $CKAN_SMTP_MAIL_FROM"
ckan config-tool $CKAN_INI "smtp.reply_to = $CKAN_SMTP_REPLY_TO"


echo "Loading SAML2 settings into ckan.ini"
ckan config-tool $CKAN_INI "ckanext.saml2auth.idp_metadata.location = remote"
ckan config-tool $CKAN_INI "ckanext.saml2auth.idp_metadata.remote_url = $CKANEXT__SAML2AUTH__IDP_METADATA__REMOTE_URL"
ckan config-tool $CKAN_INI "ckanext.saml2auth.user_firstname = $CKANEXT__SAML2AUTH__USER_FIRSTNAME"
ckan config-tool $CKAN_INI "ckanext.saml2auth.user_lastname = $CKANEXT__SAML2AUTH__USER_LASTNAME"
ckan config-tool $CKAN_INI "ckanext.saml2auth.user_fullname = $CKANEXT__SAML2AUTH__USER_FULLNAME"
ckan config-tool $CKAN_INI "ckanext.saml2auth.user_email = $CKANEXT__SAML2AUTH__USER_EMAIL"
ckan config-tool $CKAN_INI "ckanext.saml2auth.entity_id = $CKANEXT__SAML2AUTH__ENTITY_ID"
ckan config-tool $CKAN_INI "ckanext.saml2auth.want_assertions_signed = $CKANEXT__SAML2AUTH__WANT_ASSERTIONS_SIGNED"
ckan config-tool $CKAN_INI "ckanext.saml2auth.want_response_signed = $CKANEXT__SAML2AUTH__WANT_RESPONSE_SIGNED"
ckan config-tool $CKAN_INI "ckanext.saml2auth.want_assertions_or_response_signed = $CKANEXT__SAML2AUTH__WANT_ASSERTIONS_OR_RESPONSE_SIGNED"
ckan config-tool $CKAN_INI "ckanext.saml2auth.logout_expected_binding = $CKANEXT__SAML2AUTH__LOGOUT_EXPECTED_BINDING"
ckan config-tool $CKAN_INI "ckanext.saml2auth.enable_ckan_internal_login = $CKANEXT__SAML2AUTH__ENABLE_CKAN_INTERNAL_LOGIN"
ckan config-tool $CKAN_INI "ckanext.saml2auth.default_fallback_endpoint = home.index"

echo "Loading Private Datasets settinngs into ckan.ini"
ckan config-tool $CKAN_INI "ckan.privatedatasets.parser = $CKAN__PRIVATEDATASETS__PARSER"
# ckan config-tool $CKAN_INI "ckan.privatedatasets.show_acquire_url_on_create = $CKAN__PRIVATEDATASETS__SHOW_ACQUIRE_URL_ON_CREATE"
# ckan config-tool $CKAN_INI "ckan.privatedatasets.show_acquire_url_on_edit = $CKAN__PRIVATEDATASETS__SHOW_ACQUIRE_URL_ON_EDIT"

echo "Loading Datasci Sharing settings into ckan.ini"
ckan config-tool $CKAN_INI \
    "ckanext.datasci_sharing.iam_resources_prefix = $CKANEXT__DATASCI_SHARING__IAM_RESOURCES_PREFIX" \
    "ckanext.datasci_sharing.bucket_name = $CKANEXT__DATASCI_SHARING__BUCKET_NAME" \
    "ckanext.datasci_sharing.bucket_region = $CKAN_SMDH__AWS_STORAGE_BUCKET_REGION" \
    "ckanext.datasci_sharing.aws_account_id = $CKAN_SMDH__AWS_ACCOUNT_ID" \
    "ckanext.datasci_sharing.aws_access_key_id = $CKANEXT__DATASCI_SHARING__AWS_ACCESS_KEY_ID" \
    "ckanext.datasci_sharing.aws_secret_access_key = $CKANEXT__DATASCI_SHARING__AWS_SECRET_ACCESS_KEY"

echo "Loading Cloudstorage settings into ckan.ini"
ckan config-tool $CKAN_INI \
    "ckanext.cloudstorage.driver = $CKANEXT__CLOUDSTORAGE__DRIVER" \
    "ckanext.cloudstorage.driver_options = $CKANEXT__CLOUDSTORAGE__DRIVER_OPTIONS" \
    "ckanext.cloudstorage.container_name = $CKANEXT__CLOUDSTORAGE__CONTAINER_NAME" \
    "ckanext.cloudstorage.sync.queue_region = $CKANEXT__CLOUDSTORAGE__SYNC__QUEUE_REGION" \
    "ckanext.cloudstorage.sync.queue_url = $CKANEXT__CLOUDSTORAGE__SYNC__QUEUE_URL"

if [ $? -eq 0 ]
then
    # Start supervisord
    supervisord --configuration /etc/supervisord.conf
    # Start uwsgi
    if [[ "$WORKER_PROCESS" != "true" ]]
    then
        echo "STARTING CKAN SERVER..."
        uwsgi $UWSGI_OPTS
    else
        echo "STARTING CRON..."
        ./start_cron.sh
        echo "STARTING CKAN WORKER..."
        su ckan -c "/usr/bin/ckan -c $CKAN_INI jobs worker"
    fi
else
  echo "[prerun] failed...not starting CKAN."
fi
