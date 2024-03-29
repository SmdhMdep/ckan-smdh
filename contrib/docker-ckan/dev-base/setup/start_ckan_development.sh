#!/bin/bash

# Run the prerun script to init CKAN and create the default admin user
echo "Running prerun script"
python3 $APP_DIR/prerun.py

echo "Override ckan.ini sqlalchemy.url default value"
ckan config-tool $CKAN_INI "sqlalchemy.url = $CKAN_SQLALCHEMY_URL"

echo "Override ckan.ini datastore settings"
ckan config-tool $CKAN_INI "ckan.datastore.write_url = $CKAN_DATASTORE_WRITE_URL"
ckan config-tool $CKAN_INI "ckan.datastore.read_url = $CKAN_DATASTORE_READ_URL"

# Install any local extensions in the src_extensions volume
echo "Looking for local extensions to install..."
echo "Extension dir contents:"
ls -la $SRC_EXTENSIONS_DIR
for i in $SRC_EXTENSIONS_DIR/*
do
    if [ -d $i ];
    then

        if [ -f $i/pip-requirements.txt ];
        then
            pip install -r $i/pip-requirements.txt
            echo "Found requirements file in $i"
        fi
        if [ -f $i/requirements.txt ];
        then
            pip install -r $i/requirements.txt
            echo "Found requirements file in $i"
        fi
        if [ -f $i/dev-requirements.txt ];
        then
            pip install -r $i/dev-requirements.txt
            echo "Found dev-requirements file in $i"
        fi
        if [ -f $i/setup.py ];
        then
            cd $i
            python3 $i/setup.py develop
            echo "Found setup.py file in $i"
            cd $APP_DIR
        fi

        # Point `use` in test.ini to location of `test-core.ini`
        if [ -f $i/test.ini ];
        then
            echo "Updating \`test.ini\` reference to \`test-core.ini\` for plugin $i"
            ckan config-tool $i/test.ini "use = config:../../src/ckan/test-core.ini"
        fi
    fi
done

# Set debug to true
echo "Enabling debug mode"
ckan config-tool $CKAN_INI -s DEFAULT "debug = true"

echo "Setting up beaker to use the database instead of disk"
ckan config-tool $CKAN_INI "beaker.session.type = ext:database"
ckan config-tool $CKAN_INI "beaker.session.url = $CKAN_SQLALCHEMY_URL"

echo "Setting up session timeout"
ckan config-tool $CKAN_INI "who.timeout = $CKAN_SESSION_TIMEOUT"

# Update the plugins setting in the ini file with the values defined in the env var
echo "Loading the following plugins: $CKAN__PLUGINS"
ckan config-tool $CKAN_INI "ckan.plugins = $CKAN__PLUGINS"

# echo "Loading Datapusher+ settings into ckan.ini"
# ckan config-tool $CKAN_INI "ckan.datapusher.formats = csv xls xlsx xlsm xlsb tsv tab application/csv application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet ods application/vnd.oasis.opendocument.spreadsheet"

echo "Loading default views into ckan.ini"
ckan config-tool $CKAN_INI "ckan.views.default_views = image_view text_view recline_view pdf_view"

# Update test-core.ini DB, SOLR & Redis settings
echo "Loading test settings into test-core.ini"
ckan config-tool $SRC_DIR/ckan/test-core.ini \
    "sqlalchemy.url = $TEST_CKAN_SQLALCHEMY_URL" \
    "ckan.datastore.write_url = $TEST_CKAN_DATASTORE_WRITE_URL" \
    "ckan.datastore.read_url = $TEST_CKAN_DATASTORE_READ_URL" \
    "solr_url = $TEST_CKAN_SOLR_URL" \
    "ckan.redis.url = $TEST_CKAN_REDIS_URL"

echo "Enabling ckan tracking"
ckan config-tool $CKAN_INI "ckan.tracking_enabled = true"


echo "Loading FrontEnd settings into ckan.ini"
ckan config-tool $CKAN_INI "ckan.site_title = Asset Explorer"
ckan config-tool $CKAN_INI "ckan.site_logo = /base/images/Mdep_black_yellow_logo.svg"
# ckan config-tool $CKAN_INI "ckan.site_description = "
ckan config-tool $CKAN_INI "ckan.favicon = /base/images/mdep-favicon.ico"

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

# Start supervisord
supervisord --configuration /etc/supervisord.conf

# Start the development server as the ckan user with automatic reload
if [[ "$WORKER_PROCESS" != "true" ]]
then
    echo "STARTING CKAN SERVER..."
    su ckan -c "/usr/bin/ckan -c $CKAN_INI run -H 0.0.0.0"
else
    echo "STARTING CRON..."
    ./start_cron.sh
    echo "STARTING CKAN WORKER..."
    su ckan -c "/usr/bin/ckan -c $CKAN_INI jobs worker"
fi
