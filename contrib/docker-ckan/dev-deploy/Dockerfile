ARG INTERNAL_REG

FROM ${INTERNAL_REG}/mdepckan/ckan-dev:latest


# Set up environment variables
ENV APP_DIR=/srv/app
ENV TZ=UTC
RUN echo ${TZ} > /etc/timezone
ENV CKAN_STORAGE_WEBASSETS_PATH=${CKAN_STORAGE_PATH}/webassets


RUN mkdir -p ${CKAN_STORAGE_WEBASSETS_PATH}/.webassets-cache && \
    chown -R ckan:ckan ${CKAN_STORAGE_WEBASSETS_PATH}
# Make sure both files are not exactly the same
RUN if ! [ /usr/share/zoneinfo/${TZ} -ef /etc/localtime ]; then \
        cp /usr/share/zoneinfo/${TZ} /etc/localtime ;\
    fi ;

# Install any extensions needed by your CKAN instance
# - Make sure to add the plugins to CKAN__PLUGINS in the .env file
# - Also make sure all extra configuration options are added to the CKAN config file (ckan.ini)
#   This can be done by creating an overriding start_ckan_dev_development.sh file:
#   (https://github.com/ckan/ckan-docker-base/blob/main/ckan-2.9/dev/setup/start_ckan_development.sh) ie: updating the 'ckan config-tool' lines
#   For more on config-tool please see https://docs.ckan.org/en/latest/maintaining/cli.html#config-tool-tool-for-editing-options-in-a-ckan-config-file
#   or using Crudini (https://github.com/pixelb/crudini) 
#


# Clone the extension(s) your are writing for your own project in the `src` folder
# to get them mounted in this image at runtime

# Apply any patches needed to CKAN core or any of the built extensions (not the
# runtime mounted ones)

### SSO ###
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-sso.git@main#egg=ckanext-sso' && \ 
   pip3 install -r ${APP_DIR}/src/ckanext-sso/requirements.txt && \
   pip3 install -r ${APP_DIR}/src/ckanext-sso/dev-requirements.txt
## SAML2AUTH ###
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-saml2auth.git@main#egg=ckanext-saml2auth' && \
    pip3 install -r ${APP_DIR}/src/ckanext-saml2auth/dev-requirements.txt

## PRIVATE DATA SETS ###
RUN  pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-privatedatasets.git@main#egg=ckanext-privatedatasets'

## USERTRACKING ###
RUN  pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-usertracking.git@main#egg=ckanext-usertracking' && \
    pip3 install -r ${APP_DIR}/src/ckanext-usertracking/requirements.txt && \
    pip3 install -r ${APP_DIR}/src/ckanext-usertracking/dev-requirements.txt

## SMDH ###
RUN  pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-smdh.git@main#egg=ckanext-smdh' && \
    pip3 install -r ${APP_DIR}/src/ckanext-smdh/requirements.txt

## FALKOR ###
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-falkor.git@main#egg=ckanext-falkor' && \
    pip3 install -r ${APP_DIR}/src/ckanext-falkor/requirements.txt && \
    pip3 install -r ${APP_DIR}/src/ckanext-falkor/dev-requirements.txt

## S3FILESTORE ###
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-s3filestore.git@main#egg=ckanext-s3filestore' && \
    pip3 install -r ${APP_DIR}/src/ckanext-s3filestore/requirements.txt && \
    pip3 install -r ${APP_DIR}/src/ckanext-s3filestore/dev-requirements.txt

## TAGLIST ###
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-taglist.git@main#egg=ckanext-taglist' && \
    pip3 install -r ${APP_DIR}/src/ckanext-taglist/requirements.txt && \
    pip3 install -r ${APP_DIR}/src/ckanext-taglist/dev-requirements.txt

## GRANULAR VISIBILITY ##
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-granularvisibility.git@main#egg=ckanext-granularvisibility' && \
    pip3 install -r ${APP_DIR}/src/ckanext-granularvisibility/dev-requirements.txt

## GENERAL PUBLIC ##
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-generalpublic.git@main#egg=ckanext-generalpublic' && \
    pip3 install -r ${APP_DIR}/src/ckanext-generalpublic/requirements.txt && \
    pip3 install -r ${APP_DIR}/src/ckanext-generalpublic/dev-requirements.txt

## CKANEXT-PDFVIEW ##
RUN pip3 install -e 'git+https://github.com/ckan/ckanext-pdfview.git@master#egg=ckanext-pdfview' && \
    pip3 install -r ${APP_DIR}/src/ckanext-pdfview/dev-requirements.txt

COPY patches ${APP_DIR}/patches

RUN for d in $APP_DIR/patches/*; do \
        if [ -d $d ]; then \
            for f in `ls $d/*.patch | sort -g`; do \
                cd $SRC_DIR/`basename "$d"` && echo "$0: Applying patch $f to $SRC_DIR/`basename $d`"; patch -p1 < "$f" ; \
            done ; \
        fi ; \
    done

