#!/bin/bash
echo -e "setting default username:..."
username="uitoux"

echo -e "what is the domain name (e.g. uitoux.com): \c"
read site
sitename="$site"

echo -e "setting site root directory..."
rootdir="/home/$username/$sitename/httpdocs"

echo -e "what password do you want to set for root: \c"
read -s rootpassword
rootpass="$rootpassword"

echo -e "\n\n\n"

echo -e "changing password for root... \c"
echo root:"$rootpass" | /usr/sbin/chpasswd
echo -e "done!"

echo -e "\n\n"

echo -e "adding nginx repo... \c"
apt-add-repository ppa:nginx/stable -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "updating/upgrading package list and distro... \c"
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove -y > /dev/null 2> /home/"$username"/errors.log
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
echo -e "updating/upgrading package list and distro... \c"
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing debconf utils... \c"
apt-get install debconf-utils -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "setting preconfigured inputs for (( i = 0; i < 10; i++ )); do
	#statements
done percona... \c"
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
echo -e "enabling mcrypt... \c"
php5enmod mcrypt > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing php5 curl... \c"
apt-get install php5-curl -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"

echo -e "\n\n"

echo -e "creating "$sitename" directory... \c"
mkdir /home/"$username"/"$sitename"
echo -e "done!"
echo -e "owning "$sitename" directory... \c"
chown -R "$username":"$useranme" /home/"$username"/"$sitename"
echo -e "done!"
echo -e "retrieving drupal... \c"
wget http://ftp.drupal.org/files/projects/drupal-7.34.tar.gz -P /home/"$username"/"$sitename"/ > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "extracing drupal... \c"
tar -xvzf /home/"$username"/"$sitename"/drupal-7.34.tar.gz -C /home/"$username"/"$sitename"/ > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "removing drupal tar file... \c"
rm /home/"$username"/"$sitename"/drupal-7.34.tar.gz
echo -e "done!"
echo -e "renaming drupal file to httpdocs... \c"
mv /home/"$username"/"$sitename"/drupal-7.34 /home/"$username"/"$sitename"/httpdocs
echo -e "done!"
echo -e "owning httpdocs... \c"
chown -R "$username":"$username" /home/"$username"/"$sitename"/httpdocs
echo -e "done!"
echo -e "configuring nginx.conf... \c"
sed -i 's/www-data/'"$username"'/g' /etc/nginx/nginx.conf
echo -e "done!"
echo -e "removing default sites-enabled... \c"
rm /etc/nginx/sites-enabled/default
echo -e "done!"
echo -e "adding own sites-enabled file... \c"
mv nginx_template /etc/nginx/sites-enabled/
echo -e "done!"
echo -e "renaming the sites-enabled file to "$sitename"... \c"
mv /etc/nginx/sites-enabled/nginx_template /etc/nginx/sites-enabled/"$sitename"
echo -e "done!"
echo -e "configuring "$sitename" file... \c"
sed -i 's/$site_domain/'"$sitename"'/g' /etc/nginx/sites-enabled/"$sitename"
sed -i 's/$site_root/'"$rootdir"'/g' /etc/nginx/sites-enabled/"$sitename"
echo -e "done!"
echo -e "configuring php5... \c"
sed -i 's/www-data/'"$username"'/g' /etc/php5/fpm/pool.d/www.conf
sed -i 's/www-data/'"$username"'/g' /etc/php5/fpm/php-fpm.conf
echo -e "done!"
echo -e "creating link to phpmyadmin in httpdocs... \c"
su "$username" -c 'ln -s /usr/share/phpmyadmin /home/'"$username"'/'"$sitename"'/httpdocs'
echo -e "done!"
echo -e "rename default in sites folder to "$sitename"... \c"
su "$username" -c 'mv /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/default /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/'"$sitename"'.com'
echo -e "done!"
echo -e "create symbolic link of "$sitename" and call it default... \c"
su "$username" -c 'ln -s /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/'"$sitename"'.com /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/default'
echo -e "done!"

echo -e "\n\n"

echo -e "updating/upgrading package list and distro... \c"
apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove -y > /dev/null 2> /home/"$username"/errors.log
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
