#!/bin/bash
echo -e "what username do you want to create: \c"
read user
username="$user"

echo -e "what is the domain name (e.g. uitoux.com): \c"
read site
sitename="$site".com

echo -e "what password do you want to set for root: \c"
read -s rootpassword
rootpass="$rootpassword"

echo -e "\nwhat password do you want to set for "$username": \c"
read -s userpassword
userpass="$userpassword"

echo -e "\n\n\n"

echo -e "changing password for root... \c"
echo root:"$rootpass" | /usr/sbin/chpasswd
echo -e "done!"

echo -e "creating new group for "$username"... \c"
groupadd "$username"
echo -e "done!"
echo -e "creating user "$username"... \c"
useradd -s /bin/bash -m "$username" -d /home/"$username" -g "$username"
echo -e "done!"
echo "$username":"$userpass" | /usr/sbin/chpasswd

echo -e "\n\n"

echo -e "adding nginx repo... \c"
apt-add-repository ppa:nginx/stable -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing nginx... \c"
apt-get install nginx -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing key for percona... \c"
apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A  > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "adding repo to sources list... \c"
echo "deb http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list
echo "deb-src http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list
echo -e "done!"
echo -e "updating package list... \c"
apt-get update -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "upgrading distro... \c"
apt-get dist-upgrade -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "setting preconfigured inputs for percona... \c"
echo "percona-server-server-5.5 percona-server-server/root_password password $rootpass" | debconf-set-selections
echo "percona-server-server-5.5 percona-server-server/root_password_again password $rootpass" | debconf-set-selections
echo -e "done!"
echo -e "installing percona... \c"
apt-get install percona-server-server-5.5 percona-server-client-5.5 -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing php5... \c"
apt-get install php5-fpm -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "setting preconfigured inputs for phpmyadmin... \c"
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $rootpass" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $rootpass" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $rootpass" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect lighttpd" | debconf-set-selections
echo -e "done!"
echo -e "installing phpmyadmin... \c"
apt-get install phpmyadmin -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing drush... \c"
apt-get install drush -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing php5 cli... \c"
apt-get install php5-cli -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing php5 mcrypt... \c"
apt-get install php5-mcrypt -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "enabling mcrypt... \c"
php5enmod mcrypt > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing php5 curl... \c"
apt-get install php5-curl -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing php5 gd... \c"
apt-get install php5-gd -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"

echo -e "\n\n"

echo -e "creating "$sitename".com directory... \c"
mkdir /home/"$username"/"$sitename".com
echo -e "done!"
echo -e "owning "$sitename".com directory... \c"
chown -R "$username":"$useranme" /home/"$username"/"$sitename".com
echo -e "done!"
echo -e "retrieving drupal... \c"
wget http://ftp.drupal.org/files/projects/drupal-7.34.tar.gz -P /home/"$username"/"$sitename".com/ > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "extracing drupal... \c"
tar -xvzf /home/"$username"/"$sitename".com/drupal-7.34.tar.gz -C /home/"$username"/"$sitename".com/ > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "removing drupal tar file... \c"
rm /home/"$username"/"$sitename".com/drupal-7.34.tar.gz
echo -e "done!"
echo -e "renaming drupal file to httpdocs... \c"
mv /home/"$username"/"$sitename".com/drupal-7.34 /home/"$username"/"$sitename".com/httpdocs
echo -e "done!"
echo -e "owning httpdocs... \c"
chown -R "$username":"$username" /home/"$username"/"$sitename".com/httpdocs
echo -e "done!"
echo -e "configuring nginx.conf... \c"
sed -i 's/www-data/'"$username"'/g' /etc/nginx/nginx.conf
echo -e "done!"
echo -e "removing default sites-enabled... \c"
rm /etc/nginx/sites-enabled/default
echo -e "done!"
echo -e "adding own sites-enabled file... \c"
mv sample_se.com /etc/nginx/sites-enabled/
echo -e "done!"
echo -e "renaming the sites-enabled file to "$sitename".com... \c"
mv /etc/nginx/sites-enabled/sample_se.com /etc/nginx/sites-enabled/"$sitename".com
echo -e "done!"
echo -e "configuring "$sitename.com" file... \c"
sed -i 's/uitoux/'"$username"'/g' /etc/nginx/sites-enabled/"$sitename".com
sed -i 's/'"$username"'.com/'"$sitename"'.com/g' /etc/nginx/sites-enabled/"$sitename".com
echo -e "done!"
echo -e "configuring php5... \c"
sed -i 's/www-data/'"$username"'/g' /etc/php5/fpm/pool.d/www.conf
sed -i 's/www-data/'"$username"'/g' /etc/php5/fpm/php-fpm.conf
echo -e "done!"
echo -e "creating link to phpmyadmin in httpdocs... \c"
su "$username" -c 'ln -s /usr/share/phpmyadmin /home/'"$username"'/'"$sitename"'/httpdocs'
echo -e "done!"
echo -e "rename default in sites folder to "$sitename".com... \c"
su "$username" -c 'mv /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/default /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/'"$sitename"'.com'
echo -e "done!"
echo -e "create symbolic link of "$sitename".com and call it default... \c"
su "$username" -c 'ln -s /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/'"$sitename"'.com /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/default'
echo -e "done!"

echo -e "\n\n"

echo -e "restarting nginx... \c"
service nginx restart > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "restarting php5... \c"
service php5-fpm restart > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"

echo -e "\n\n"

echo -e "restarting server, please stand by..."
reboot