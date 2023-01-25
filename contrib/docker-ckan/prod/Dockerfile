ARG INTERNAL_REG

FROM ${INTERNAL_REG}/mdepckan/ckan-base:latest
#FROM ckan/ckan-base:2.9.7

# Set up environment variables
ENV APP_DIR=/srv/app
ENV TZ=UTC
RUN echo ${TZ} > /etc/timezone

# Make sure both files are not exactly the same
RUN if ! [ /usr/share/zoneinfo/${TZ} -ef /etc/localtime ]; then \
        cp /usr/share/zoneinfo/${TZ} /etc/localtime ;\
    fi ;
RUN apk add --no-cache tzdata \
        xmlsec1 \
        rustc

### SSO ###
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-sso.git@main#egg=ckanext-sso' && \ 
   pip3 install -r ${APP_DIR}/src/ckanext-sso/requirements.txt
#    pip3 install -U requests[security]
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

## FALKOR ###
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-falkor.git@main#egg=ckanext-falkor' && \
    pip3 install -r ${APP_DIR}/src/ckanext-falkor/requirements.txt

## S3FILESTORE ###
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-s3filestore.git@main#egg=ckanext-s3filestore' && \
    pip3 install -r ${APP_DIR}/src/ckanext-s3filestore/requirements.txt

## TAGLIST ###
RUN pip3 install -e 'git+https://github.com/SmdhMdep/ckanext-taglist.git@main#egg=ckanext-taglist' && \
    pip3 install -r ${APP_DIR}/src/ckanext-taglist/requirements.txt