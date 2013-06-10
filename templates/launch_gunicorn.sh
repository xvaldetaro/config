#!/bin/bash
PROPER_USER=$USER
if [ "$USER" == "root" ]; then
	echo Running as root, settings PROPER_USER to $SUDO_USER
	PROPER_USER=$SUDO_USER
fi
set -e
NUM_WORKERS=3

LOG_FILE=logs/<proj_name>.log
source activate_venv
source load_prod_env.sh

gunicorn -b 127.0.0.1:<app_port> \
-w $NUM_WORKERS --user=$PROPER_USER --log-level=$LOG_LEVEL --log-file=$LOG_FILE <proj_name>
