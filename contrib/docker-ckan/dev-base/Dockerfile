ARG INTERNAL_REG

FROM ${INTERNAL_REG}/mdepckan/ckan-base:latest


ENV APP_DIR=/srv/app
ENV SRC_EXTENSIONS_DIR=/srv/app/src_extensions

# Install packages needed by the dev requirements
RUN apk add --no-cache libffi-dev

# Install CKAN dev requirements
RUN pip3 install -r https://raw.githubusercontent.com/SmdhMdep/ckan-smdh/main/dev-requirements.txt

# Create folder for local extensions sources
RUN mkdir ${SRC_EXTENSIONS_DIR}

COPY ./contrib/docker-ckan/dev-base/setup/start_ckan_development.sh ${APP_DIR}

RUN chown ckan -R /srv/app \
    && chmod +x ${APP_DIR}/start_ckan_development.sh
CMD ["/srv/app/start_ckan_development.sh"]
