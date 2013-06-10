sudo -u postgres dropdb <proj_name>
sudo -u postgres createdb <proj_name>
python manage.py syncdb
