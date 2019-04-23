#!/bin/sh
set -ex

APP_PATH='/opt/node/app'

echo "Start generation and deployment"
cd $APP_PATH

echo "Pulling source code..."
git pull origin master

echo "Generate and deploy..."
# pm2 start pm2.json
# pm2 sendSignal SIGUSR2 pm2.json
[ -z $APP_NAME ] && APP_NAME=nodeapp
pm2 describe ${APP_NAME} > /dev/null
RUNNING=$?

if [ "${RUNNING}" -ne 0 ]; then
    pm2 start pm2.json
else
    pm2 sendSignal SIGUSR2 pm2.json
fi;

echo "Deploy finished."
