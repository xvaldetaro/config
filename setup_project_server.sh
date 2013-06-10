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

echo This script creates the app folder structure with scripts, git repo, nginx and upstart entries
if [ "$1" == "" ]; then
	echo no listen port provided
	echo usage: ./setup_project_server.sh listen_port domain_name proj_name proxy_port 
	echo example: ./nginx_site_create.sh 80 example.com example 8001
	exit 0
fi
if [ "$2" == "" ]; then
	echo no domain provided
	echo usage: ./setup_project_server.sh listen_port domain_name proj_name proxy_port 
	echo example: ./nginx_site_create.sh 80 example.com example 8001
	exit 0
fi
if [ "$3" == "" ]; then
	echo no project name provided
	echo usage: ./setup_project_server.sh listen_port domain_name proj_name proxy_port 
	echo example: ./nginx_site_create.sh 80 example.com example 8001
	exit 0
fi
if [ "$4" == "" ]; then
	echo no proxy port provided
	echo usage: ./setup_project_server.sh listen_port domain_name proj_name proxy_port 
	echo example: ./nginx_site_create.sh 80 example.com example 8001
	exit 0
fi

PROPER_USER=$USER
if [ "$USER" == "root" ]; then
	echo Running as root, settings PROPER_USER to $SUDO_USER
	PROPER_USER=$SUDO_USER
fi

LISTEN_PORT=$1
DOMAIN=$2
PROJ_NAME=$3
APP_PORT=$4
APP_DIR=$APPS_DIR/$PROJ_NAME
PROJ_DIR=$APP_DIR/$PROJ_NAME

echo creating app folder structure
./create_app_folder.sh $PROJ_NAME $APP_PORT

echo Creating nginx sites-available and sites-enables entries
sudo rm -f /etc/nginx/sites-available/$DOMAIN

sudo sed -e "s@<listen_port>@"$LISTEN_PORT"@" \
-e "s@<domain_name>@"$DOMAIN"@" \
-e "s@<app_dir>@"$APP_DIR"@" \
-e "s@<proxy_port>@"$APP_PORT"@" \
$CONFIG_DIR/templates/nginx_site \
>> /etc/nginx/sites-available/$DOMAIN

sudo ln -f -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN

echo Successfully created nginx entries

echo Creating upstart customized entries
sudo rm -f /etc/init/$DOMAIN.conf

sudo sed -e "s@<user>@"$PROPER_USER"@" \
-e "s@<script>@"$PROJ_DIR"/launch_gunicorn.sh@" \
-e "s@<params>@prod@" \
$CONFIG_DIR/templates/upstart_process.conf \
>> /etc/init/$DOMAIN.conf

echo Successfully created upstart entries

echo Now creating Git bare repository 

REPO_DIR=$REPOS_DIR/$PROJ_NAME.git
echo repo dir is: $REPO_DIR

echo creating repo dir folder
mkdir -p $REPO_DIR

git init --bare $REPO_DIR

echo copying $CONFIG_DIR/templates/post-receive to $REPO_DIR/hooks
cp -f $CONFIG_DIR/templates/post-receive $REPO_DIR/hooks
chmod 766 $REPO_DIR/hooks/post-receive

if [ "$USER" == "root" ]; then
	echo Since ran as root, setting proper owner now.
	chown -R $PROPER_USER $REPO_DIR
fi