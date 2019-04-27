#!/bin/sh

# GITHUB: github repository address
# GITLAB: Gitlab repository address
# GOGS: Gitlab repository address
# WEBHOOK_SECRET: git repository webhook secret
# APP_NAME: node app name
# PM2_CONFIG_FILE: pm2 config file name

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

	[ -z "$WEBHOOK_SECRET" ] && WEBHOOK_SECRET=123456
	sed -i "s/WEBHOOK_SECRET/$WEBHOOK_SECRET/" /opt/node/webhook/index.js

	# # pm2-webshell
	# # https://github.com/pm2-hive/pm2-webshell
	# cd /opt/node/webhook/
	# pm2 install pm2-webshell
	# pm2 conf pm2-webshell:username pm2admin
	# pm2 conf pm2-webshell:password pm2AdminP0ssW0rd

	# Github webhook
	if [ ! -z "$GITHUB" ]; then
		# npm install github-webhook-handler
		sed -i "s/WEBHOOK-HANDLER/github-webhook-handler/" /opt/node/webhook/index.js

		rm -rf /opt/node/app && mkdir -p /opt/node/
		cd /opt/node/ && git clone $GITHUB /opt/node/app
	fi

	# Gitlab webhook
	if [ ! -z "$GITLAB" ]; then
		# npm install node-gitlab-webhook
		sed -i "s/WEBHOOK-HANDLER/node-gitlab-webhook/" /opt/node/webhook/index.js

		rm -rf /opt/node/app && mkdir -p /opt/node/
		cd /opt/node/ && git clone $GITLAB ./app
	fi

	# Gogs webhook
	if [ ! -z "$GOGS" ]; then
		# npm install gogs-webhook-handler
		sed -i "s/WEBHOOK-HANDLER/gogs-webhook-handler/" /opt/node/webhook/gogs.js

		rm -rf /opt/node/app && mkdir -p /opt/node/
		cd /opt/node/ && git clone $GOGS ./app
	fi
fi


# Start webhook
cd /opt/node/webhook
if [ -z "$GOGS" ]; then
	pm2 start index.js --name webhook
else
	pm2 start gogs.js --name webhook
fi

# Start app
# [ -z "$PM2_CONFIG_FILE" ] && PM2_CONFIG_FILE=pm2.json
# pm2 start ${PM2_CONFIG_FILE}
/opt/node/webhook/deploy.sh


# # pm2 monitor to keep container running
pm2 monit


# # Tail log file to keep container running
# [ -z "$TAILLOG" ] && export TAILLOG=/var/log/*.log
# tail -f $TAILLOG

# exec "$@"
