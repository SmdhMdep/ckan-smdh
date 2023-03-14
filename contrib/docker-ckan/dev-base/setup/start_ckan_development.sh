#!/bin/bash

# Run the prerun script to init CKAN and create the default admin user
sudo -u ckan -EH python3 $APP_DIR/prerun.py
echo "Running prerun script"
sudo -u ckan -EH python3 $APP_DIR/prerun.py

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
ckan config-tool $CKAN_INI "ckan.site_title = MDEP AEP"
ckan config-tool $CKAN_INI "ckan.site_logo = /base/images/ckan-logo.png"
# ckan config-tool $CKAN_INI "ckan.site_description = "
ckan config-tool $CKAN_INI "ckan.favicon = /base/images/ckan.ico"

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

echo "Loading S3Filestore settings into ckan.ini"
ckan config-tool $CKAN_INI "ckanext.s3filestore.aws_bucket_name = $CKANEXT__S3FILESTORE__AWS_BUCKET_NAME"
ckan config-tool $CKAN_INI "ckanext.s3filestore.region_name = $CKANEXT__S3FILESTORE__REGION_NAME"
ckan config-tool $CKAN_INI "ckanext.s3filestore.signature_version = $CKANEXT__S3FILESTORE__SIGNATURE_VERSION"
ckan config-tool $CKAN_INI "ckanext.s3filestore.aws_access_key_id = $CKANEXT__S3FILESTORE__AWS_ACCESS_KEY_ID"
ckan config-tool $CKAN_INI "ckanext.s3filestore.aws_secret_access_key = $CKANEXT__S3FILESTORE__AWS_SECRET_ACCESS_KEY"
ckan config-tool $CKAN_INI "ckanext.s3filestore.filesystem_download_fallback = $CKANEXT__S3FILESTORE__FILESYSTEM_DOWNLOAD_FALLBACK"
ckan config-tool $CKAN_INI "ckanext.s3filestore.signed_url_expiry = $CKANEXT__S3FILESTORE__SIGNED_URL_EXPIRY"
ckan config-tool $CKAN_INI "ckanext.s3filestore.signed_url_cache_window = $CKANEXT__S3FILESTORE__SIGNED_URL_CACHE_WINDOW"
ckan config-tool $CKAN_INI "ckanext.s3filestore.public_cache_window = $CKANEXT__S3FILESTORE__PUBLIC_URL_CACE_WINDOW"

echo "Loading Private Datasets settinngs into ckan.ini"
ckan config-tool $CKAN_INI "ckan.privatedatasets.parser = $CKAN__PRIVATEDATASETS__PARSER"
# ckan config-tool $CKAN_INI "ckan.privatedatasets.show_acquire_url_on_create = $CKAN__PRIVATEDATASETS__SHOW_ACQUIRE_URL_ON_CREATE"
# ckan config-tool $CKAN_INI "ckan.privatedatasets.show_acquire_url_on_edit = $CKAN__PRIVATEDATASETS__SHOW_ACQUIRE_URL_ON_EDIT"

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
supervisord --configuration /etc/supervisord.conf &

# Start the development server with automatic reload
sudo -u ckan -EH ckan -c $CKAN_INI run -H 0.0.0.0