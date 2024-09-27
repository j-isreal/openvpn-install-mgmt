# Sample Client Website

This is a sample of the /var/www/sample.clientsite.com sample client site.

Copy this archive into the web root of your web server and configure.

The ```html``` folder is the webroot for your website.  Make sure you have a domain name pointed to your webserver and that this is defined as the webroot.

It is also <em>highly recommended</em> to use an SSL certificate to secure your website.  Otherwise, passwords will be sent in clear-text and could be compromised.

The ```clients``` folder is where the ```.htpasswd``` file is hosted and is intentionally **outside** the webroot for security reasons.
