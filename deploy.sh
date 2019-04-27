#!/bin/sh
# set -ex

APP_PATH='/opt/node/app'

echo "Start generation and deployment"
cd $APP_PATH

echo "Pulling source code..."
git pull origin master

echo "Generate and deploy..."
[ -z $PM2_CONFIG_FILE ] && PM2_CONFIG_FILE=pm2.json
# pm2 start pm2.json
# pm2 sendSignal SIGUSR2 pm2.json

[ -z $APP_NAME ] && APP_NAME=nodeapp
pm2 describe ${APP_NAME} > /dev/null
RUNNING=$?

if [ "${RUNNING}" -ne 0 ]; then
    pm2 start ${PM2_CONFIG_FILE}
else
    pm2 sendSignal SIGUSR2 ${PM2_CONFIG_FILE}
fi

echo "Deploy finished."
