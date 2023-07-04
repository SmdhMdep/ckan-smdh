#!/bin/bash

# This script is run by the ckan container to start CKAN

# Run the prerun script to init CKAN and create the default admin user
echo "Running prerun script"
sudo -u ckan -EH python3 $APP_DIR/prerun_prod.py

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
ckan config-tool $CKAN_INI "ckan.views.default_views = image_view text_view recline_view pdf_view"

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

if [ $? -eq 0 ]
then
    # Start supervisord
    supervisord --configuration /etc/supervisord.conf &
    # Start uwsgi
    echo "STARTING CKAN..."
    sudo -u ckan -EH uwsgi $UWSGI_OPTS
else
  echo "[prerun] failed...not starting CKAN."
fi
