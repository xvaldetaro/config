#!/bin/bash
if [ "$CONFIG_DIR" == "" ]; then
	export CONFIG_DIR=$HOME/apps/config
	echo CONFIG_DIR not set, deafulting to $CONFIG_DIR
fi
if [ "$APPS_DIR" == "" ]; then
	export APPS_DIR=$HOME/apps
	echo APPS_DIR not set, deafulting to $APPS_DIR
fi

if [ "$1" == "" ]; then
	echo no project name
	exit 0
fi
APP_PORT=$2
if [ "$2" == "" ]; then
	echo No app port provided, using 8000
	APP_PORT=8000
fi

PROPER_USER=$USER
if [ "$USER" == "root" ]; then
	echo Running as root, settings PROPER_USER to $SUDO_USER
	PROPER_USER=$SUDO_USER
fi

PROJ_NAME=$1
APP_DIR=$APPS_DIR/$PROJ_NAME
PROJ_DIR=$APP_DIR/$PROJ_NAME

echo App folder structure Creating now...
mkdir -p $PROJ_DIR
mkdir $APP_DIR/logs
mkdir $APP_DIR/globals

echo creating virtualenv...
virtualenv --distribute $APP_DIR/venv
echo linking virtualenv activate script

ln -f -s $APP_DIR/venv/bin/activate $PROJ_DIR/activate_venv
ln -f -s $APP_DIR/globals/prod.sh $PROJ_DIR/load_prod_env
ln -f -s $APP_DIR/globals/local.sh $PROJ_DIR/load_local_env

echo Copying customized scripts...

sed -e "s@<proj_name>@"$PROJ_NAME"@" \
-e "s@<app_port>@"$APP_PORT"@" \
-e "s@<log_dir>@"$APP_DIR/logs"@" \
-e "s@<user>@"$PROPER_USER"@" \
$CONFIG_DIR/templates/gunicorn_prod.py >> \
$PROJ_DIR/gunicorn_prod.py

sed -e "s@<proj_name>@"$PROJ_NAME"@" \
-e "s@<app_port>@"$APP_PORT"@" \
-e "s@<log_dir>@"$APP_DIR/logs"@" \
-e "s@<user>@"$PROPER_USER"@" \
$CONFIG_DIR/templates/gunicorn_local.py >> \
$PROJ_DIR/gunicorn_local.py

sed -e "s@<proj_name>@"$PROJ_NAME"@" \
-e "s@<proj_dir>@"$PROJ_DIR"@" \
-e "s@<app_dir>@"$APP_DIR"@" \
-e "s@<venv_file>@"$APP_DIR/venv/bin/activate"@" \
$CONFIG_DIR/templates/launch_gunicorn.sh >> \
$PROJ_DIR/launch_gunicorn.sh

chmod 755 $PROJ_DIR/launch_gunicorn.sh

sed -e "s@<proj_name>@"$PROJ_NAME"@" \
$CONFIG_DIR/templates/cleardb.sh >> \
$PROJ_DIR/cleardb.sh

chmod -R 755 $PROJ_DIR

echo Successfully created the app folder structure with scripts

if [ "$USER" == "root" ]; then
	echo Since ran as root, setting proper owner now.
	chown -R $PROPER_USER $APP_DIR
fi