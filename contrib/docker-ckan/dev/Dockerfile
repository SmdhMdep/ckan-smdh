FROM harbor.stfc.ac.uk/aep_ckan/ckan-smdh-base:latest


ENV APP_DIR=/srv/app
ENV SRC_EXTENSIONS_DIR=/srv/app/src_extensions

# Install packages needed by the dev requirements
RUN apk add --no-cache libffi-dev

# Install CKAN dev requirements
RUN pip3 install -r https://raw.githubusercontent.com/SmdhMdep/ckan-smdh/main/dev-requirements.txt

# Create folder for local extensions sources
RUN mkdir ${SRC_EXTENSIONS_DIR}

COPY ./contrib/docker-ckan/dev/setup/start_ckan_development.sh ${APP_DIR}

RUN chown ckan -R /srv/app

WORKDIR ${SRC_EXTENSIONS_DIR}

RUN git clone https://github.com/SmdhMdep/ckanext-sso.git \
    && git clone https://github.com/SmdhMdep/ckanext-saml2auth.git \
    && git clone https://github.com/SmdhMdep/ckanext-smdh.git \
    && git clone https://github.com/SmdhMdep/ckanext-privatedatasets.git \
    && git clone https://github.com/SmdhMdep/ckanext-usertracking.git \
    # && git clone https://github.com/SmdhMdep/ckanext-s3filestore.git \
    && git clone https://github.com/SmdhMdep/ckanext-taglist.git \
    && git clone https://github.com/SmdhMdep/ckanext-falkor.git \
    && git clone https://github.com/SmdhMdep/ckanext-restricted.git 
    
CMD ["/srv/app/start_ckan_development.sh"]
