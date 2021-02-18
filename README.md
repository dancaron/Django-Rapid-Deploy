# Django Rapid Deploy
Version 1.3. Successfully tested on Ubuntu 20.10

Spin up a production grade Django environment without breaking a sweat!

Let's face it, setting up a production Django stack can be time consuming. No one likes nginx 502 Bad Gateway errors. This script relieves that pain, delivering a ready to go Supervisor, Guincorn, Nginx, Django, Postgres stack. After running the script, you'll have a fully functioning Django environment. All it requires is a few configuration variables set at the top of the script. Latest version now includes certbot by default.


### How to Setup Your Django Environment Using Django Rapid Deploy

1. Spin up an instance of Ubuntu, on Linode, Google Cloud, AWS, or Digital Ocean.
2. Login as root, clone or paste djangogo.sh into your favorite server side editor.
3. Edit the configuration variables at the top of the script and save the file:

```
project_name="name"
project_password="password"
project_ip="000.000.000.000"
project_domain="domain.com www.domain.com"
```

4. Run the script as root with: `chmod +x djangogo.sh; ./djangogo.sh`
5. Grab your favorite beverage, take a sip, browse to your IP address on completion.


Your django app & project will reside in:
`/home/project_name/project_name/`

Witin `/home/project_name` there are the following folders:
```
bin
etc
project_name
include  
lib  
lib64  
logs  
pyvenv.cfg  
run  
share
```
These folders are mostly from the virtual environment.

To activate your virtualenv:
`source /home/project_name/bin/activate`

### Typical Workflow to Update Your Application

```
ssh root@yourserver.com
su project_name
cd ~project_name
source bin/activate
cd project_name
git pull origin master
python manage.py makemigrations
python manage.py migrate
python manage.py collectstatic
sudo supervisorctl restart project_name
```


### Notes
When software is being upgraded, you may be asked a few questions. The defaults will work just fine. I've seen this happen with Grub. Also, you may be asked to enter in a password and during the user account creation step. If you want to install an SSL certificate, you'll need to point your domain to your IP then run ```sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com```


### MIT License Copyright (c) 2021 Dan Caron

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.