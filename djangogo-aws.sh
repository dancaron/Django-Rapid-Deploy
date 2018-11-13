#!/bin/sh
# Amazon Linux 2 EC2
# Assumes RDS and No Postgres
# CONFIGURE THE FOLLOWING SECTION
# --------------------------------------------
project_name="name"
project_ip="000.000.000.000"
project_domain="domain.com www.domain.com"
# --------------------------------------------
# USAGE:
# From root home directory
# sudo su - 
# Edit project_name, project_ip, and project_domain variables above 
# Then chmod +x djangogo.sh; ./djangogo.sh
# If you are on AWS, make sure to change your security groups to allow for traffic on port 80

# Install updates, nginx, python, pip and dependencies
echo "[DJANGOGO] UPDATING SYSTEM & INSTALLING DEPENDENCIES..."
sudo yum -y update
sudo amazon-linux-extras install nginx1.12
sudo yum install -y python3-pip python3 python3-setuptools
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py --user
export PATH=~/.local/bin:$PATH

# Install supervisor
pip install -U supervisor

# Create supervisor config file
mkdir -p /etc/supervisor/conf.d
echo_supervisord_conf > /etc/supervisor/supervisord.conf
cat << EOF >> /etc/supervisor/supervisord.conf
[include]
files = /etc/supervisor/conf.d/*.conf
EOF

# Create supervisor config file for systemd
cat << EOF >> /etc/systemd/system/supervisor.service
# supervisord service for systemd
[Unit]
Description=Supervisor daemon

[Service]
Type=forking
ExecStart=/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
ExecStop=/usr/bin/supervisorctl $OPTIONS shutdown
ExecReload=/usr/bin/supervisorctl -c /etc/supervisor/supervisord.conf $OPTIONS reload
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF

# Start supervisor from systemd
sudo systemctl enable supervisor
sudo systemctl start supervisor

# Create project user, venv, and setup django
echo "[DJANGOGO] CREATING PROJECT USER, VENV & SETUP DJANGO..."
sudo adduser $project_name
chmod 711 /home/$project_name

# Django setup as project user
sudo su $project_name<<EOF
cd /home/$project_name
python3 -m venv .
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

# Create gunicorn_start file
echo "[DJANGOGO] CONFIGURING GUNICORN..."
cd /home/$project_name/bin
cat << EOF >> gunicorn_start
#!/bin/bash
NAME="$project_name"
DIR=/home/$project_name/$project_name
USER=$project_name
GROUP=$project_name
WORKERS=3
BIND=unix:/home/$project_name/run/gunicorn.sock
DJANGO_SETTINGS_MODULE=project.settings
DJANGO_WSGI_MODULE=project.wsgi
LOG_LEVEL=error
cd \$DIR
source /home/$project_name/bin/activate
export DJANGO_SETTINGS_MODULE=\$DJANGO_SETTINGS_MODULE
export PYTHONPATH=\$DIR:\$PYTHONPATH
exec /home/$project_name/bin/gunicorn \${DJANGO_WSGI_MODULE}:application \\
  --name \$NAME \\
  --workers \$WORKERS \\
  --user=\$USER \\
  --group=\$GROUP \\
  --bind=\$BIND \\
  --log-level=\$LOG_LEVEL \\
  --log-file=-
EOF

# Set permissions on gunicorn_start file and create gunicorn logs
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

# Configure gunicorn on supervisor
echo "[DJANGOGO] CONFIGURING SUPERVISOR FOR GUNICORN..."
cat << EOF >> /etc/supervisor/conf.d/$project_name.conf
[program:$project_name]
command=/home/$project_name/bin/gunicorn_start
user=$project_name
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/home/$project_name/logs/gunicorn-error.log
EOF

# Restart Supervisor
echo "[DJANGOGO] RESTARTING SUPERVISOR..."
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl status $project_name
sudo supervisorctl restart $project_name

# Configure Nginx
echo "[DJANGOGO] CONFIGURING NGINX..."

# Create project_name.conf in /etc/nginx/conf.d
cat << EOF >> /etc/nginx/conf.d/$project_name.conf
upstream app_server {
    server unix:/home/$project_name/run/gunicorn.sock fail_timeout=0;
}

server {
    listen 80;

    # add here the ip address of your server
    # or a domain pointing to that ip (like example.com or www.example.com)
    server_name $project_ip $project_domain;

    keepalive_timeout 5;
    client_max_body_size 4G;

    access_log /home/$project_name/logs/nginx-access.log;
    error_log /home/$project_name/logs/nginx-error.log;

    location /static/ {
    alias /home/$project_name/$project_name/static/;
    }

    # checks for static file, if not found proxy to app
    location / {
      try_files \$uri @proxy_to_app;
    }

    location @proxy_to_app {
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header Host \$http_host;
      proxy_redirect off;
      proxy_pass http://app_server;
    }
}
EOF

# Restart nginx and you are good to go!
echo "[DJANGOGO] RESTARTING NGINX..."
sudo service nginx restart
echo "[DJANGOGO] COMPLETE!"
echo "[DJANGOGO] VISIT: http://$project_ip"