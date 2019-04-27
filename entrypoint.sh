#!/bin/sh

# GITHUB: github repository address
# GITLAB: Gitlab repository address
# GOGS: Gitlab repository address
# WEBHOOK_SECRET: git repository webhook secret
# APP_NAME: node app name

set -ex

#SSH
if [ -d "/root/.ssh/" ]; then
	chmod 700 /root/.ssh/
	chmod -R 600 /root/.ssh/*
fi

# Deploy
if [ ! -f "/opt/node/webhook/deploy.sh" ]; then
	cp /var/lib/webhook/deploy.sh /opt/node/webhook
fi

if [ ! -f "/opt/node/webhook/index.js" ]; then
	cp /var/lib/webhook/index.js /opt/node/webhook/index.js
	cp /var/lib/webhook/gogs.js /opt/node/webhook/gogs.js

	[ -z $WEBHOOK_SECRET ] && WEBHOOK_SECRET=123456
	sed -i "s/WEBHOOK_SECRET/$WEBHOOK_SECRET/" /opt/node/webhook/index.js

	# Github webhook
	if [ ! -z $GITHUB ]; then
		# npm install github-webhook-handler
		sed -i "s/WEBHOOK-HANDLER/github-webhook-handler/" /opt/node/webhook/index.js

		rm -rf /opt/node/app && mkdir -p /opt/node
		cd /opt/node && git clone $GITHUB ./app

		cd /opt/node/webhook
		pm2 start index.js --name webhook

		/opt/node/webhook/deploy.sh
	fi

	# Gitlab webhook
	if [ ! -z $GITLAB ]; then
		# npm install node-gitlab-webhook
		sed -i "s/WEBHOOK-HANDLER/node-gitlab-webhook/" /opt/node/webhook/index.js

		rm -rf /opt/node/app && mkdir -p /opt/node
		cd /opt/node && git clone $GITLAB ./app

		cd /opt/node/webhook
		pm2 start index.js --name webhook

		/opt/node/webhook/deploy.sh
	fi

	# Gogs webhook
	if [ ! -z $GOGS ]; then
		# npm install gogs-webhook-handler
		sed -i "s/WEBHOOK-HANDLER/gogs-webhook-handler/" /opt/node/webhook/gogs.js

		rm -rf /opt/node/app && mkdir -p /opt/node
		cd /opt/node && git clone $GOGS ./app

		cd /opt/node/webhook
		pm2 start gogs.js --name webhook

		/opt/node/webhook/deploy.sh
	fi
else
	cd /opt/node/webhook
	pm2 start index.js --name webhook
fi
