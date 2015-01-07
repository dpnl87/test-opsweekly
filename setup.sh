#!/bin/bash

yum update -y
yum install -y vim httpd centos-release-SCL
yum install -y php54 php54-php php54-php-mysqlnd mysql mysql-server
service mysqld start

mysql -u root -e "create database opsweekly";
cat /vagrant/opsweekly.sql | mysql -u root opsweekly

rm -f /etc/httpd/conf.d/welcome.conf

cat <<EOF > /vagrant/phplib/config.php
<?php

\$mysql_user = "root";
\$mysql_pass = "";

\$email_from_domain = "inuits.eu";

function getUsername() {
  // Use the PHP_AUTH_USER header which contains the username when Basic auth is used.
  return $_SERVER['PHP_AUTH_USER'];
}

\$teams = array(
"192.168.33.10" => array(
"root_url" => "/",
"display_name" => "Ops",
"database" => "opsweekly",
),
);


\$search_results_per_page = 25;
\$error_log_file = "/var/log/httpd/opsweekly_debug.log";
\$dev_fqdn = "/(\w+).vms.mycompany.com/";
\$prod_fqdn = "192.168.33.10";
EOF

cat <<EOF > /etc/httpd/conf.d/opsweekly.conf
<VirtualHost *:80>
ServerName opsweekly.dev

DocumentRoot /vagrant

# Other directives here
<Directory "/vagrant">
Options Indexes FollowSymLinks
</Directory>
</VirtualHost>
EOF

service httpd start
