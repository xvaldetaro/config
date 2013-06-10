#!/bin/bash
if [ "$1" == "" ]; then
	echo Error, must specify MODE to launch_gunicorn.sh
	exit 0
fi
LAUNCH_MODE=$1
source <venv_file>
source <globals_dir>/$LAUNCH_MODE.sh

cd <proj_dir>
gunicorn -c <proj_dir>/gunicorn_$LAUNCH_MODE.py <proj_name>.wsgi
