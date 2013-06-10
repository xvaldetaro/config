#!/bin/bash
sudo apt-get install -y python
sudo apt-get install -y curl
curl -O http://python-distribute.org/distribute_setup.py
sudo python distribute_setup.py
rm distribute_setup.py
rm -f distribute-*.tar.gz
sudo easy_install pip
sudo pip install virtualenv
