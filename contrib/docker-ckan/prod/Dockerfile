ARG INTERNAL_REG

FROM ${INTERNAL_REG}/mdepckan/ckan-base:latest

# Set up environment variables
ENV APP_DIR=/srv/app
ENV TZ=UTC
RUN echo ${TZ} > /etc/timezone

# Make sure both files are not exactly the same
RUN if ! [ /usr/share/zoneinfo/${TZ} -ef /etc/localtime ]; then \
        cp /usr/share/zoneinfo/${TZ} /etc/localtime ;\
    fi ;

### SSO ###
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-sso.git@main#egg=ckanext-sso' && \ 
   pip3 install -r ${APP_DIR}/src/ckanext-sso/requirements.txt

## SAML2AUTH ###
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-saml2auth.git@main#egg=ckanext-saml2auth'

## PRIVATE DATA SETS ###
RUN  pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-privatedatasets.git@main#egg=ckanext-privatedatasets'

## USERTRACKING ###
RUN  pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-usertracking.git@main#egg=ckanext-usertracking' && \
    pip3 install -r ${APP_DIR}/src/ckanext-usertracking/requirements.txt

## SMDH ###
RUN  pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-smdh.git@main#egg=ckanext-smdh' && \
    pip3 install -r ${APP_DIR}/src/ckanext-smdh/requirements.txt

## TAGLIST ###
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-taglist.git@main#egg=ckanext-taglist' && \
    pip3 install -r ${APP_DIR}/src/ckanext-taglist/requirements.txt

## GRANULAR VISIBILITY ##
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-granularvisibility.git@main#egg=ckanext-granularvisibility'

## GENERAL PUBLIC ##
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-generalpublic.git@main#egg=ckanext-generalpublic' && \
    pip3 install -r ${APP_DIR}/src/ckanext-generalpublic/requirements.txt

## CKANEXT-PDFVIEW ##
RUN pip3 install -e 'git+https://github.com/ckan/ckanext-pdfview.git@master#egg=ckanext-pdfview'

## CLOUDSTORAGE ##
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-cloudstorage.git@master#egg=ckanext-cloudstorage' && \
    pip3 install -r ${APP_DIR}/src/ckanext-cloudstorage/requirements.txt

## DATASCI SHARING ##
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-datasci-sharing.git@main#egg=ckanext-datasci-sharing' && \
    pip3 install -r ${APP_DIR}/src/ckanext-datasci-sharing/requirements.txt

## DATASET FORM CHAIN ##
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-datasetformchain.git@main#egg=ckanext-datasetformchain' && \
    pip3 install -r ${APP_DIR}/src/ckanext-datasetformchain/requirements.txt

# Copy the healthcheck script
COPY contrib/docker-ckan/prod/health_check.sh ${APP_DIR}/health_check.sh
RUN chmod +x ${APP_DIR}/health_check.sh
