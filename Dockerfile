FROM node:11-alpine

LABEL Maintainer="Ansley Leung" \
      Description="Auto generate and deploy node app use git repository webhook" \
      License="MIT License" \
      Version="11.15"

ENV TZ=Asia/Shanghai
RUN set -ex && \
    apk add --no-cache tzdata ca-certificates curl openssl git openssh && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    rm -rf /tmp/* /var/cache/apk/*


# pm2
RUN set -ex && \
    npm install pm2 -g && \
    mkdir -p /opt/node /opt/node/app /opt/node/webhook /var/lib/webhook


# deploy webhook plugins
RUN set -ex && \
    cd /opt/node/webhook && \
    npm install github-webhook-handler && \
	npm install gogs-webhook-handler && \
    npm install node-gitlab-webhook


WORKDIR /opt/node/app

# webhook & deploy files
COPY ./index.js /var/lib/webhook/index.js
COPY ./gogs.js /var/lib/webhook/gogs.js

COPY ./deploy.sh /var/lib/webhook/deploy.sh
COPY ./entrypoint.sh /entrypoint.sh

# ssh
# COPY ./id_rsa /root/.ssh/id_rsa
# RUN set -ex && \
#     mkdir -p /root/.ssh/ && \
#     chmod 700 /root/.ssh/ && \
#     chmod 600 /root/.ssh/id_rsa && \
#     echo "StrictHostKeyChecking no" > /root/.ssh/config && \
#     chmod 600 /root/.ssh/config


RUN set -ex && \
    chmod +x /var/lib/webhook/deploy.sh /entrypoint.sh


# Expose Ports
EXPOSE 80
EXPOSE 5000

ENTRYPOINT ["/entrypoint.sh"]
