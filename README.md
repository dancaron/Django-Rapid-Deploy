# Djangogo 1.0
Spin up a production grade Django configuration on Ubuntu 16.04 LTS in minutes. 

Let's face it, deploying Django can be time consuming and frustrating. This script relieves that pain, delivering a ready to go Supervisor, Guincorn, Nginx, Django, Postgres stack. 

### Steps to Deploy Django on Digital Ocean or Linode using Djangogo

1. Spin up a Linode or Digital Ocean Ubuntu 16.04 LTS instance.
2. Login as root, paste djangogo.sh into your favorite server side editor.
3. Edit the four configuration variables at the top of the script and save the file.
4. Run the script as root with: "chmod +x djangogo.sh; ./djangogo.sh"
5. Grab your favorite beverage, take a sip, browse to your IP address on completion.

### Notes
When Ubuntu software is being upgraded, you may be asked a few questions. The defaults will usually work just fine. I've seen this happen with Grub. Also, you will be asked to enter in a password during the user creation step. Your settings.py will still use sqlite, to use Postgres edit:

settings.py
~~~~
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'project_name_prod',
        'USER': 'project_name',
        'PASSWORD': 'project_password',
        'HOST': 'localhost',
        'PORT': '',
    }
}
~~~~

### Paths

Your django project will reside in:
`/home/project_name/project_name/`

To activate your virtualenv:
`source /home/project_name/bin/activate`

### Typical workflow to update your application

~~~~
ssh username@000.000.000.000

source bin/activate
cd project_name
git pull origin master
python manage.py collectstatic
python manage.py migrate
sudo supervisorctl restart project_name
exit
~~~~

### MIT License Copyright (c) 2017 Dan Caron

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