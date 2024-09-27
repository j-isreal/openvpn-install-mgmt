# Sample Client Site

This is the client .ovpn zip files download folder.

The ```.htaccess``` file controls the access to the files in this folder.

The files are created and copied here when you use the scripts to create OpenVPN clients/users and are deleted when you revoke client/users using the script.

```
<Files file.zip>
AuthType Basic
AuthName 'Authentication Required'
AuthUserFile /var/www/sample.clientsite.com/clients/.htpasswd
Require user client111
</Files>
```
The ```Files``` directive tells the web server which file and what user has access and is <em>automatically</em> updated - there is no action necessary from you.

The sample file ```file.zip``` is protected with the username client111 and the same password.

The ```index.php``` file just redirects the user somewhere else since this is a protected folder.

