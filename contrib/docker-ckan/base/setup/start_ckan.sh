#!/bin/bash

# Run the prerun script to init CKAN and create the default admin user
sudo -u ckan -EH python3 prerun.py

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
            -p 2 -L -b 32768 --vacuum \
            --harakiri $UWSGI_HARAKIRI"


echo "Loading API settings into ckan.ini"
ckan config-tool $CKAN_INI "api_token.jwt.encode.secret = $CKAN___API__TOKEN__JWT__ENCODE__SECRET"
ckan config-tool $CKAN_INI "api_token.jwt.decode.secret = $CKAN___API__TOKEN__JWT__DECODE__SECRET"
ckan config-tool $CKAN_INI "api_token.jwt.algorithm = $CKAN___API_TOKEN__JWT__ALGORITHM"


echo "Loading FrontEnd settings into ckan.ini"
ckan config-tool $CKAN_INI "ckan.site_title = MDEP AEP"
ckan config-tool $CKAN_INI "ckan.site_logo = /base/images/ckan-logo.png"
# ckan config-tool $CKAN_INI "ckan.site_description = "
ckan config-tool $CKAN_INI "ckan.favicon = /base/images/ckan.ico"

echo "Loading Email settings into ckan.ini"
ckan config-tool $CKAN_INI "smtp.server = $CKAN___SMTP__SERVER"
ckan config-tool $CKAN_INI "smtp.starttls = $CKAN___SMTP__STARTTLS"
ckan config-tool $CKAN_INI "smtp.user = $CKAN___SMTP__USER"
ckan config-tool $CKAN_INI "smtp.password = $CKAN___SMTP__PASSWORD"
ckan config-tool $CKAN_INI "smtp.mail_from = $CKAN___SMTP__MAIL_FROM"
ckan config-tool $CKAN_INI "smtp.reply_to = $CKAN___SMTP__REPLY_TO"

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
ckan con

echo "Loading Private Datasets settinngs into ckan.ini"
ckan config-tool $CKAN_INI "ckan.privatedatasets.parser = $CKAN__PRIVATEDATASETS__PARSER"
# ckan config-tool $CKAN_INI "ckan.privatedatasets.show_acquire_url_on_create = $CKAN__PRIVATEDATASETS__SHOW_ACQUIRE_URL_ON_CREATE"
# ckan config-tool $CKAN_INI "ckan.privatedatasets.show_acquire_url_on_edit = $CKAN__PRIVATEDATASETS__SHOW_ACQUIRE_URL_ON_EDIT"

if [ $? -eq 0 ]
then
    # Start supervisord
    supervisord --configuration /etc/supervisord.conf &
    # Start uwsgi
    sudo -u ckan -EH uwsgi $UWSGI_OPTS
else
  echo "[prerun] failed...not starting CKAN."
fi