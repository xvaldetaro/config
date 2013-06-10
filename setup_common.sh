#!/bin/bash
if [ "$CONFIG_DIR" == "" ]; then
	export CONFIG_DIR=$HOME/apps/config
	echo CONFIG_DIR not set, deafulting to $CONFIG_DIR
fi
if [ "$APPS_DIR" == "" ]; then
	export APPS_DIR=$HOME/apps
	echo APPS_DIR not set, deafulting to $APPS_DIR
fi
if [ "$REPOS_DIR" == "" ]; then
	export REPOS_DIR=$HOME/repos
	echo REPOS_DIR not set, deafulting to $REPOS_DIR
fi

if [ "$1" == "" ]; then
	echo no project name provided
	echo usage: ./setup_project_server.sh listen_port domain_name proj_name proxy_port 
	echo example: ./nginx_site_create.sh 80 example.com example 8001
	exit 0
fi

PROPER_USER=$USER
if [ "$USER" == "root" ]; then
	echo Running as root, settings PROPER_USER to $SUDO_USER
	PROPER_USER=$SUDO_USER
fi

PROJ_NAME=$1
APP_DIR=$APPS_DIR/$PROJ_NAME
PROJ_DIR=$APP_DIR/$PROJ_NAME

echo creating app folder structure
mkdir -p $APP_DIR

echo Now creating Git bare repository 

REPO_DIR=$REPOS_DIR/$PROJ_NAME.git
echo repo dir is: $REPO_DIR

echo creating repo dir folder
mkdir -p $REPO_DIR
chown -R $PROPER_USER $REPO_DIR

git init --bare $REPO_DIR

echo copying $CONFIG_DIR/templates/checkout-only-post-receive to $REPO_DIR/hooks
cp -f $CONFIG_DIR/templates/checkout-only-post-receive $REPO_DIR/hooks/post-receive
chmod 766 $REPO_DIR/hooks/post-receive

if [ "$USER" == "root" ]; then
	echo Since ran as root, setting proper owner now.
	chown -R $PROPER_USER $REPO_DIR
fi