#!/bin/sh
# Ubuntu 16.04 LTS
# CONFIGURE THE FOLLOWING SECTION 
# --------------------------------------------
project_name="name"
project_password="password"
project_ip="000.000.000.000"
project_domain="domain.com www.domain.com"
# --------------------------------------------
# NOTE: project_password serves as the password for the system
# user account that is created.
# Usage (as root): "chmod +x djangogo.sh; ./djangogo.sh"
# After code updates run: supervisorctl restart project_name

# Install Dependencies
echo "[DJANGOGO] UPDATING SYSTEM & INSTALLING DEPENDENCIES..."
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential libpq-dev python-dev
sudo apt-get -y install postgresql postgresql-contrib
sudo apt-get -y install nginx
sudo apt-get -y install supervisor
sudo systemctl enable supervisor
sudo systemctl start supervisor
sudo apt-get -y install python-virtualenv git

# Create Postgres
echo "[DJANGOGO] SETTING UP POSTGRES..."
database_prefix=$project_name
database_suffix="_prod"
database_name=$database_prefix$database_suffix
su postgres<<EOF
cd ~
createuser $project_name
createdb $database_name --owner $project_name
psql -c "ALTER USER $project_name WITH PASSWORD '$project_password'"
EOF
cd /root

# Add project user / add user to sudo file
echo "[DJANGOGO] CREATING USER & DJANGO PROJECT..."
adduser $project_name
gpasswd -a $project_name sudo
su $project_name<<EOF
cd /home/$project_name
virtualenv -p python3 .
source bin/activate
pip install Django
django-admin startproject project
mv project $project_name
cd $project_name
cd project
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['$project_ip']/" settings.py
cd ..
django-admin startapp main
pip install gunicorn
EOF
echo "[DJANGOGO] CONFIGURING GUNICORN..."
cd /home/$project_name
touch bin/gunicorn_start
cd bin
echo '#!/bin/bash' >> gunicorn_start
echo 'NAME="'$project_name'"' >> gunicorn_start
echo 'DIR=/home/'$project_name'/'$project_name >> gunicorn_start
echo 'USER='$project_name >> gunicorn_start
echo 'GROUP='$project_name >> gunicorn_start
echo 'WORKERS=3' >> gunicorn_start
echo 'BIND=unix:/home/'$project_name'/run/gunicorn.sock' >> gunicorn_start
echo 'DJANGO_SETTINGS_MODULE=project.settings' >> gunicorn_start
echo 'DJANGO_WSGI_MODULE=project.wsgi' >> gunicorn_start
echo 'LOG_LEVEL=error' >> gunicorn_start
echo 'cd $DIR' >> gunicorn_start
echo 'source /home/'$project_name'/bin/activate' >> gunicorn_start
echo 'export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE' >> gunicorn_start
echo 'export PYTHONPATH=$DIR:$PYTHONPATH' >> gunicorn_start
echo 'exec /home/'$project_name'/bin/gunicorn ${DJANGO_WSGI_MODULE}:application \' >> gunicorn_start
echo '  --name $NAME \' >> gunicorn_start
echo '  --workers $WORKERS \' >> gunicorn_start
echo '  --user=$USER \' >> gunicorn_start
echo '  --group=$GROUP \' >> gunicorn_start
echo '  --bind=$BIND \' >> gunicorn_start
echo '  --log-level=$LOG_LEVEL \' >> gunicorn_start
echo '  --log-file=-' >> gunicorn_start
chmod u+x gunicorn_start
chown $project_name gunicorn_start
chgrp $project_name gunicorn_start
cd /home/$project_name
mkdir run
chown $project_name run
chgrp $project_name run
mkdir logs
chown $project_name logs
chgrp $project_name logs
touch logs/gunicorn-error.log
chown $project_name logs/gunicorn-error.log
chgrp $project_name logs/gunicorn-error.log

# Configure Supervisor for Gunicorn
echo "[DJANGOGO] CONFIGURING SUPERVISOR FOR GUNICORN..."
touch /etc/supervisor/conf.d/$project_name.conf
cd /etc/supervisor/conf.d
echo '[program:'$project_name']' >> $project_name.conf
echo 'command=/home/'$project_name'/bin/gunicorn_start' >> $project_name.conf
echo 'user='$project_name >> $project_name.conf
echo 'autostart=true' >> $project_name.conf
echo 'autorestart=true' >> $project_name.conf
echo 'redirect_stderr=true' >> $project_name.conf
echo 'stdout_logfile=/home/'$project_name'/logs/gunicorn-error.log' >> $project_name.conf

# Restart Supervisor
echo "[DJANGOGO] RESTARTING SUPERVISOR..."
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl status $project_name
sudo supervisorctl restart $project_name

# Configure Nginx
echo "[DJANGOGO] CONFIGURING NGINX..."
touch /etc/nginx/sites-available/$project_name
cd /etc/nginx/sites-available

echo 'upstream app_server {' >> $project_name
echo '    server unix:/home/'$project_name'/run/gunicorn.sock fail_timeout=0;' >> $project_name
echo '}' >> $project_name
echo '' >> $project_name
echo 'server {' >> $project_name
echo '    listen 80;' >> $project_name
echo '' >> $project_name
echo '    # add here the ip address of your server' >> $project_name
echo '    # or a domain pointing to that ip (like example.com or www.example.com)' >> $project_name
echo '    server_name '$project_ip' '$project_domain';' >> $project_name
echo '' >> $project_name
echo '    keepalive_timeout 5;' >> $project_name
echo '    client_max_body_size 4G;' >> $project_name
echo '' >> $project_name
echo '    access_log /home/'$project_name'/logs/nginx-access.log;' >> $project_name
echo '    error_log /home/'$project_name'/logs/nginx-error.log;' >> $project_name
echo '' >> $project_name
echo '    location /static/ {' >> $project_name
echo '    alias /home/'$project_name'/'$project_name'/static/;' >> $project_name
echo '    }' >> $project_name
echo '' >> $project_name
echo '    # checks for static file, if not found proxy to app' >> $project_name
echo '    location / {' >> $project_name
echo '      try_files $uri @proxy_to_app;' >> $project_name
echo '    }' >> $project_name
echo '' >> $project_name
echo '    location @proxy_to_app {' >> $project_name
echo '      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;' >> $project_name
echo '      proxy_set_header Host $http_host;' >> $project_name
echo '      proxy_redirect off;' >> $project_name
echo '      proxy_pass http://app_server;' >> $project_name
echo '    }' >> $project_name
echo '}' >> $project_name

# Create symlinks and restart Nginx
sudo ln -s /etc/nginx/sites-available/$project_name /etc/nginx/sites-enabled/$project_name
sudo rm /etc/nginx/sites-enabled/default
echo "[DJANGOGO] RESTARTING NGINX..."
sudo service nginx restart
echo "[DJANGOGO] COMPLETE!"
echo "[DJANGOGO] VISIT: http://$project_ip"