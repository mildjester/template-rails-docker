#!/bin/bash
set -eu

# move script directory
CUR_UID=`id -u`
SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd ${SCRIPT_DIR}

# generate app directory
if [ -e myapp ]; then
    docker-compose run web chown -R ${CUR_UID}:${CUR_UID} /myapp
    rm -rf myapp
fi
mkdir myapp
cp Gemfile* myapp/.

# build rails app
docker-compose run web rails new . --force --database=postgresql --skip-bundle
docker-compose run web chown -R ${CUR_UID}:${CUR_UID} /myapp
docker-compose build
cp database.yml myapp/config/database.yml
docker-compose up -d
docker-compose run web rake db:create

# open page
if which xdg-open > /dev/null; then
    xdg-open 'http://localhost:3000'
elif which gnome-open > /dev/null; then
    gnome-open 'http://localhost:3000'
fi
