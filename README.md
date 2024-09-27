# bash-openvpn-install-mgmt
**ICLLC VPN Status:** [![Better Stack Badge](https://uptime.betterstack.com/status-badges/v1/monitor/1khhf.svg)](https://status.icllc.cc)

**BASH scripts to install/remove OpenVPN and manage clients, while creating users in Apache site and providing client ovpn files for download as password-protected zip files**

1. openvpn-install-mgmt.sh
2. openvpn-create-next-client.sh
3. sample.clientsite.com.zip

**openvpn-install-mgmt.sh** script installs/removes OpenVPN server on linux machine, manages users, and has added functionality:
- sends email to administrator with VPN user password and download link
- creates password-protected zip archive with .ovpn file for download
- copies .zip file into Apache site profile folder
- creates Apache htpasswd user with same client name and random password so user can download .ovpn file

**openvpn-create-next-client.sh** script automates the process of creating serialized clients:
- uses a file to track serial number of last client
- creates new client as client<i>nnn</i>
- does everything as above ```openvpn-install-mgmt.sh``` script, creating password-protected zip and Apache web user, and confirmation email

**sample.clientsite.com.zip** archive of sample client website:
- unzip to web server, see README.md in archive for instructions

<br />

**Dependencies:** These scripts require:
  - ```wget``` program used for downloading resources
  - ```pwgen``` program creates a random password for Grav login and zip file
  - ```mail``` command sends email notification for new accounts (from mailutils or postfix)
  - ```7zip``` command zips the .ovpn file with the random password created
  - ```htpasswd``` program to create web users and passwords
  - a running Apache (or Nginx) website to store client .ovpn zip files for client download

<br />

## Configure the script variables
In order for the scripts to run properly, you must set the variables at the top of both the files.

```
# VARIABLES ###################################################################################
# * NO trailing slashes '/' on path variables
#
client_zip_path='/var/www/clientsite/html/clients'
client_htpasswd_path='/var/www/clientsite/clients'
client_site_url='https://www.clientsite.com/clients'
admin_email='webadmin@yourdomain.com'
#
...
# ** THE FIRST serial will be the number below PLUS ONE (+1)
first_serial=101
###############################################################################################
```
You can specify the latest easy-rsa URL, or leave as-is.  For more info, see [OpenVPN Easy-RSA](#easy-rsa).  This variable is not necessary in the ```openvpn-create-next-client.sh``` script.

Be sure to configure the ```client_zip_path``` to where you want the password-protected zip files copied, somewhere in your website.  Use the full path, beginning with a '/' without ending with a '/'.  

Configure ```client_htpasswd_path``` (beginning with a '/' and without ending with a '/') and ```client_site_url```.  **Be sure** the ```client_htpasswd_path``` is **outside** the publicly-accessible website.

Configure the ```admin_email``` (where notifications are emailed) to the appropriate value.  

In the ```openvpn-create-next-client.sh``` script, set the ```first_serial``` variable to your first serial number if the <i>next-client.txt</i> file doesn't exist in /etc/openvpn/server/ yet (the file is only created when you run the ```openvpn-create-next-client.sh``` script).  The first serial used will be the ```first_serial``` value <em>plus one</em>.

<br/>

## Configure Linux mail program with Postfix relay
This script uses the linux ```mail``` command to send notifications.  Install <i>mailutils</i> or <i>postfix</i> in linux.

You must configure Postfix, or setup Postfix relay for mail notification to work.
- check this link: https://www.cyberciti.biz/faq/how-to-configure-postfix-relayhost-smarthost-to-send-email-using-an-external-smptd/

Otherwise, comment out the line with the mail command in the ```new_client``` function in the main script and the create-next script.

<br />

## Run website for .ovpn download
This script uses ```htpasswd``` to create users and post the client .ovpn zip file for download to a special web folder with a login and password.

You must be running an Apache or Nginx website for this to work.  Set the variables at the top of the script to specify the client zip files path and htpasswd file path.

On Ubuntu or Debian, make sure ```htpasswd``` is installed:
```
apt install apache2-utils
```

It is helpful for users to have instructions on how to download and install OpenVPN clients - you can use the same website or a different website.

**Sample FAQ website:** https://vpn.icllc.cc/

### Password Encryption
These scripts use ```pwgen``` to create random passwords for the web user and zip file password.  The password is the same for the web user and the zip file.

Passwords are sent in <em>plain text</em> to the admin email and can be forwarded to the user.  Keep in mind, this is not the most secure way of sending the user/client their password.

These scripts use Bcrypt encryption in the ```htpasswd``` command (-B option).  Bcrypt is considered to be very secure.

<br /><br />

### OpenVPN and Easy-RSA
OpenVPN: 
- https://openvpn.net/community-downloads/
- https://github.com/OpenVPN/openvpn

<a id="easy-rsa"></a>OpenVPN Easy-RSA:
- https://github.com/OpenVPN/easy-rsa

<br /><br />

### Credits

Original OpenVPN Install script: https://github.com/Nyr/openvpn-install

Send mail HTML: https://unix.stackexchange.com/questions/15405/how-do-i-send-html-email-using-linux-mail-command

Configure mail: 
- https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-22-04
- https://www.cyberciti.biz/faq/how-to-configure-postfix-relayhost-smarthost-to-send-email-using-an-external-smptd/

<br/><br />

 ### Visit this project on my website
 Project Website: https://www.jinet.us/dev/dev-projects/openvpn-server-and-website-for-clients/

 <br />

 Copyright &copy; 2023-2024 Jacob Eiler, Isreal Consulting, LLC.  All rights reserved.


