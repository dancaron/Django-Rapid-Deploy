# djangogo
Spin up a production grade Django configuration on Ubuntu 16.04 LTS in minutes. 

Let's face it, deploying Django can be time consuming and frustrating. This script relieves that pain, delivering a ready to go Supervisor, Guincorn, Nginx, Django, Postgres stack. 

Step 1) Spin up a Linode or Digital Ocean Ubuntu 16.04 LTS instance.
Step 2) Login as root, paste djangogo.sh into your favorite server side editor.
Step 3) Edit the four configuration variables at the top of the script and save the file.
Step 4) Run the script as root with: "chmod +x djangogo.sh; ./djangogo.sh"
Step 5) Grab your favorite beverage, take a sip, browse to your IP address on completion.

Note: When Ubuntu software is being upgrade, you may be asked a few questions. The defaults will usually work just fine. I've seen this happen with Grub. Also, you will be asked to enter in a password during the user creation step.

Your django project will reside in:
/home/project_name/project_name/

To activate your virtualenv:
source /home/project_name/bin/activate

Tested on Linode and Digital Ocean.