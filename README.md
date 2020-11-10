# Djangogo 1.2
Spin up a production grade Django deployment without breaking a sweat!

Let's face it, deploying Django can be time consuming and frustrating. No one likes nginx 502 Bad Gateway errors. These scripts relieve that pain, delivering a ready to go Supervisor, Guincorn, Nginx, Django, Postgres stack. After running the script, you will have a fully functioning Django installation running on Nginx and empty Django project. Now includes certbot by default.

Successfully tested on Ubuntu 20.10

### How to Deploy Django on Amazon Web Services, Digital Ocean, or Linode

1. Spin up an instance of your choosen distribution.
2. Login as root, paste djangogo.sh into your favorite server side editor.
3. Edit the configuration variables at the top of the script and save the file.
4. Run the script as root with: "chmod +x djangogo.sh; ./djangogo.sh"
5. Grab your favorite beverage, take a sip, browse to your IP address on completion. Note that on AWS, you will need to update your security policy to allow incoming traffic to port 80 on the instance.

### Notes
When software is being upgraded, you may be asked a few questions. The defaults will usually work just fine. I've seen this happen with Grub. Also, you may be asked to enter in a password and during the user account creation step. 

### Relevant Paths

Your django project will reside in:
`/home/project_name/project_name/`

To activate your virtualenv:
`source /home/project_name/bin/activate`

### Typical Workflow to Update Your Application

~~~~

cd ~project_name
source bin/activate
cd project_name
git pull origin master
python manage.py migrate
python manage.py collectstatic
sudo supervisorctl restart project_name
~~~~

### TODO

* Bash command line arguments to make postgres (and other things) optional
* Package with python and submit to pypi

### MIT License Copyright (c) 2020 Dan Caron

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