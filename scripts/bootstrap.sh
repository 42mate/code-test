#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='12345678'
PROJECTFOLDER='blogmate'

# create project folder
echo "Crear directorio raíz del proyecto"
sudo mkdir -p "/var/www/html/${PROJECTFOLDER}"

# update / upgrade
sudo apt-get update
sudo apt-get -y upgrade

# install apache 2 and php 5
echo "Instalar Apache 2"
sudo apt-get install -y python-software-properties
sudo apt-get install -y apache2
echo "Instalar PHP 5 y extensiones"
sudo apt-get install -y php5 libapache2-mod-php5 php5-mcrypt
sudo php5enmod mcrypt

# install mysql and give password to installer
# export DEBIAN_FRONTEND="noninteractive"
echo "Configurar credenciales de MySQL Server"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
echo "Instalar MySQL Server"
sudo apt-get install -y mysql-server
sudo apt-get install -y php5-mysql

# install phpmyadmin and give password(s) to installer
echo "Configurar credenciales de PHPMyAdmin"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
echo "Instalar PHPMyAdmin"
sudo apt-get -y install phpmyadmin

echo "Crear archivo vhost para el proyecto"
# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/html/${PROJECTFOLDER}/web"
    <Directory "/var/www/html/${PROJECTFOLDER}/web">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

# enable mod_rewrite
echo "Activar mod_rewrite"
sudo a2enmod rewrite

# restart apache
echo "Reiniciar Apache 2"
service apache2 restart

# install curl
echo "Instalar curl"
sudo apt-get install -y curl

# install git
echo "Instalar Git"
sudo apt-get -y install git

# install Composer
echo "Instalar Composer"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
php -r "unlink('composer-setup.php');"
