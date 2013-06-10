#!/bin/bash
echo This script creates the app folder structure with scripts, git repo, nginx and upstart entries
if [ "$1" == "" ]; then
	echo no listen port provided
	echo usage: ./nginx_site_create.sh listen_port domain_name proj_dir proxy_port project_name
	echo example: ./nginx_site_create.sh 80 example.com /home/user/apps/example 8001 example
	exit 0
fi
if [ "$2" == "" ]; then
	echo no domain provided
	echo usage: ./nginx_site_create.sh listen_port domain_name proj_dir proxy_port project_name
	echo example: ./nginx_site_create.sh 80 example.com /home/user/apps/example 8001 example
	exit 0
fi
if [ "$3" == "" ]; then
	echo no project dir provided
	echo usage: ./nginx_site_create.sh listen_port domain_name proj_dir proxy_port project_name
	echo example: ./nginx_site_create.sh 80 example.com /home/user/apps/example 8001 example
	exit 0
fi
if [ "$4" == "" ]; then
	echo no proxy port provided
	echo usage: ./nginx_site_create.sh listen_port domain_name proj_dir proxy_port project_name
	echo example: ./nginx_site_create.sh 80 example.com /home/user/apps/example 8001 example
	exit 0
fi
if [ "$5" == "" ]; then
	echo no proj name provided
	echo usage: ./nginx_site_create.sh listen_port domain_name proj_dir proxy_port project_name
	echo example: ./nginx_site_create.sh 80 example.com /home/user/apps/example 8001 example
	exit 0
fi

PROPER_USER=$USER
if [ "$USER" == "root" ]; then
	echo Running as root, settings PROPER_USER to $SUDO_USER
	PROPER_USER=$SUDO_USER
fi

LISTEN_PORT=$1
DOMAIN=$2
PROJ_DIR=$3
APP_PORT=$4
PROJ_NAME=$5

echo creating app folder structure
./create_app_folder.sh $PROJ_DIR $PROJ_NAME $APP_PORT

echo Creating nginx sites-available and sites-enables entries
rm -f /etc/nginx/sites-available/$DOMAIN

sed -e "s@<listen_port>@"$LISTEN_PORT"@" \
-e "s@<domain_name>@"$DOMAIN"@" \
-e "s@<proj_dir>@"$PROJ_DIR"@" \
-e "s@<proxy_port>@"$APP_PORT"@" \
$CONFIG_DIR/templates/nginx_site \
>> /etc/nginx/sites-available/$DOMAIN

ln -f -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN

echo Successfully created nginx entries

echo Creating upstart customized entries
rm -f /etc/init/$DOMAIN.conf

sed -e "s@<user>@"$PROPER_USER"@" \
-e "s@<script>@"$PROJ_DIR"/launch_gunicorn@" \
-e "s@<params>@"$APP_PORT"@" \
$CONFIG_DIR/templates/upstart_process.conf \
>> /etc/init/$DOMAIN.conf

echo Successfully created upstart entries

echo Now creating Git bare repository 

REPO_DIR=$HOME/repos/$PROJ_NAME.git
echo repo dir is: $REPO_DIR

echo creating repo dir folder
mkdir -p $REPO_DIR

git init --bare $REPO_DIR

echo copying $CONFIG_DIR/templates/post-receive to $REPO_DIR/hooks
cp -f $CONFIG_DIR/templates/post-receive $REPO_DIR/hooks
chmod 766 $REPO_DIR/hooks/$2