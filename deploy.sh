#!/bin/sh
# set -ex

APP_PATH='/opt/node/app'

echo "Start generation and deployment"
cd $APP_PATH

echo "Pulling source code..."
git pull origin master

echo "Generate and deploy..."
npm install
npm run compile

[ -z "$PM2_CONFIG_FILE" ] && PM2_CONFIG_FILE=pm2.json

[ -z "$APP_NAME" ] && APP_NAME=nodeapp
pm2 describe ${APP_NAME} > /dev/null
RUNNING=$?

if [ "$RUNNING" -ne 0 ]; then
    pm2 start ${PM2_CONFIG_FILE}
else
    # pm2 sendSignal SIGUSR2 ${APP_NAME}
    pm2 reload ${APP_NAME}
fi

echo "Deploy finished."
