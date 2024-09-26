#!/bin/bash
#
# https://github.com/j-isreal/bash-openvpn-install-grav
#
# Copyright (c) 2024 Jacob Eiler, Isreal Consulting, LLC. Read the License file.
#
# openvpn-create-next-client.sh
#
# Bash Script to create new VPN Client user
# using a file with the last serial number and add +1 to the client name
#
# VARIABLES ###################################################################################
# * NO trailing slashes '/' on path variables
#
client_zip_path='/var/www/cc.vpn.icllc.cc/html/clients'
client_htpasswd_path='/var/www/cc.vpn.icllc.cc/clients'
admin_email='webadmin@icllc.cc'
#
# change to openvpn/server and load latest number to var lastclient
# and then add 1 to the value in the file, and finally
# re-create the latest number file with new value
# ** THE FIRST serial will be the number below PLUS ONE (+1)
first_serial=101
#
cd /etc/openvpn/server/
#
# if the next-client.txt file doesn't exist, create it
# --> the first client will be 'clientNNN' if the file doesn't exist
#     UPDATE the first_serial variable above to control NNN
if [ ! -f /etc/openvpn/server/next-client.txt ]; then
    echo "$first_serial" >/etc/openvpn/server/next-client.txt
fi
# get the last number, add 1, update the next-client.txt file
lastclient=$(<next-client.txt)
nextclient=$((lastclient + 1))
echo $nextclient >/etc/openvpn/server/next-client.txt
# set the client name using the next serial from next-client.txt
client=client"$nextclient"
#
###############################################################################################

# do some basic checks to see if the script can be run - same dependencies as the full
# openvpn-install.sh script
echo

# Detect if OpenVPN has been installed or not first
if [[ ! -e /etc/openvpn/server/server.conf ]]; then
	echo "OpenVPN doesn't appear to be installed!"
    echo
    echo "Run the openvpn-install-mgmt.sh script as root first to install OpenVPN."
    echo
    exit
fi

# Detect Debian users running the script with "sh" instead of bash
if readlink /proc/$$/exe | grep -q "dash"; then
	echo 'This script needs to be run with "bash", not "sh".'
    echo
	exit
fi

# Detect environments where $PATH does not include the sbin directories
if ! grep -q sbin <<< "$PATH"; then
	echo '$PATH does not include sbin. Try using "su -" instead of "su".'
    echo
	exit
fi

# Make sure the script is run as root
if [[ "$EUID" -ne 0 ]]; then
	echo "This script needs to be run with root/superuser privileges."
    echo
	exit
fi

# Detect whether 7zip and pwgen are installed
	if ! hash 7z 2>/dev/null; then
		echo "7zip is required to use this installer with Grav functions."
		read -n1 -r -p "Press any key to install 7zip and continue..."
		apt-get update
		apt-get install -y 7zip
	fi
        if ! hash pwgen 2>/dev/null; then
		echo "pwgen is required to use this installer with Grav functions."
		read -n1 -r -p "Press any key to install pwgen and continue..."
		apt-get update
		apt-get install -y pwgen
	fi

# GET TO BUSINESS! 
clear
echo
echo "* Creating next serial client: $client ..."
echo
read -n1 -r -p "Press CTRL-C to quit, or any key to continue..."
echo
# first build the client cert and key, then create custom client .ovpn
cd /etc/openvpn/server/easy-rsa/
./easyrsa --batch --days=3650 build-client-full "$client" nopass &>/dev/null

# Generates the custom client .ovpn
# basically, the new_client function in the openvpn-install.sh script
#
{
cat /etc/openvpn/server/client-common.txt
echo "<ca>"
cat /etc/openvpn/server/easy-rsa/pki/ca.crt
echo "</ca>"
echo "<cert>"
sed -ne '/BEGIN CERTIFICATE/,$ p' /etc/openvpn/server/easy-rsa/pki/issued/"$client".crt
echo "</cert>"
echo "<key>"
cat /etc/openvpn/server/easy-rsa/pki/private/"$client".key
echo "</key>"
echo "<tls-crypt>"
sed -ne '/BEGIN OpenVPN Static key/,$ p' /etc/openvpn/server/tc.key
echo "</tls-crypt>"
} > ~/"$client".ovpn

echo " "
echo "  Client created!  Generating user account and password, zipping client .ovpn ..."

        # create random zip and htpasswd user password, compress and archive ovpn and copy to vpn client-config folder
        ZPASS=$(pwgen -s 12 1)
        # add the client password to a file - REMOVE THIS LINE for security or restrict permissions on file
	    echo "$client : $ZPASS" >> ~/client-zip-pwd.txt
        chmod o-r ~/client-zip-pwd.txt
        # create password-protected zip file containing ovpn file for download and copy to (Grav) web path
	    7z a ~/$client-sec.zip -p$ZPASS ~/$client.ovpn
        cp ~/$client-sec.zip $client_zip_path/

# send email to webadmin about new profile creation
        echo "<a href='https://www.icllc.cc/'><img src='https://cdn.icllc.one/logo-ic-md-text-trans.png' align='right'></a><br/><h3>New VPN Client Profile</h3><br/>A new VPN account profile has been created.<br/><br/><b>Client Username:</b> $client<br/><b>Profile Password:</b> $ZPASS<br/><br/>Visit the VPN Portal at <a href='https://cc.vpn.icllc.cc/clients/$client-sec.zip' target='_blank'>cc.vpn.icllc.cc</a> and login.  Then, your client profile will download.  You will need the above password to unzip the client profile (zipped .ovpn file) to import into the VPN software to connect.<br/><br/><b>For more information,</b> visit the <a href='https://vpn.icllc.cc/how-to' target='_blank'>VPN website for How-Tos</a>, or contact ICLLC Support at <a href='https://www.icllc.cc/support'>support.icllc.cc</a>.<br/><br/><hr/><font size='-2' color='gray'>&copy; 2024 <a href='https://www.icllc.cc/'>Isreal Consulting, LLC</a>.  All rights reserved.</font><br />" | mail -s "ICLLC VPN Profile Info" -a "From: webadmin@icllc.cc" -a "Content-type: text/html;"  $admin_email
        # create new client-config site user with client username and generated password
        # using htpasswd and then update the .htaccess file to include restrictions on the file
        echo $ZPASS > ~/temp_pass
        # add if exists code to create the htpasswd with '-c' option otherwise just add to it (no -c)
        cat ~/temp_pass | htpasswd -i -B $client_htpasswd_path/.htpasswd $client
        rm ~/temp_pass
        cd $client_zip_path/
        # add Apache Files directive for only this client/user and file to .htaccess file
        echo "<Files $client-sec.zip>" >> .htaccess
        echo "AuthType Basic" >> .htaccess
        echo "AuthName 'Authentication Required'" >> .htaccess
        echo "AuthUserFile $client_htpasswd_path/.htpasswd" >> .htaccess
        echo "Require user $client" >> .htaccess
        echo "</Files>" >> .htaccess
echo
echo "Finished!"
echo
echo "The client configuration is available in:" ~/"$client.ovpn"
echo "The client config file has been zipped, password-protected and copied to the web folder."
echo "A new web user has been created and a confirmation email has been sent to the admin email."
echo " "
echo "New clients can be added by running this script again."
echo "The new client will have the next serial number from the next-client.txt file."
echo " "
echo "* To remove or revoke clients, you must use the openvpn-install-mgmt.sh script! *"
echo
