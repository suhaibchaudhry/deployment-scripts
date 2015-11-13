#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
echo -e "what username do you want to create: \c"
read user
username="$user"

echo -e "what is the domain name (e.g. uitoux.com): \c"
read site
sitename="$site"

echo -e "setting site root directory..."
rootdir="/home/$username/$sitename/httpdocs"

echo -e "what password do you want to set for root: \c"
read -s rootpassword
rootpass="$rootpassword"

echo -e "\nwhat password do you want to set for "$username": \c"
read -s userpassword
userpass="$userpassword"

echo -e "which drupal:"
echo -e "1) commerce"
echo -e "2) d7"
read version

echo -e "what password do you want to set for root in the database: \c"
read -s dbrootpassword
dbrootpass="$dbrootpassword"

echo -e "drupal username: \c"
read drupaluser

echo -e "drupal password: \c"
read drupalpass

echo -e "db name: \c"
read dbname

echo -e "db username: \c"
read dbuser

echo -e "db password: \c"
read dbpass

echo -e "changing password for root... \c"
#echo root:"$rootpass" | /usr/sbin/chpasswd
echo -e "$rootpass\n$rootpass" | passwd root > /dev/null 2>&1
passwd -u root > /dev/null 2>&1
echo -e "done!"

echo -e "creating new group for "$username"... \c"
groupadd "$username"
echo -e "done!"
echo -e "creating user "$username"... \c"
useradd -s /bin/bash -m "$username" -d /home/"$username" -g "$username"
echo -e "done!"
#echo "$username":"$userpass" | /usr/sbin/chpasswd
echo -e "$userpass\n$userpass" | passwd $username > /dev/null 2>&1

echo -e "adding nginx repo... \c"
apt-add-repository ppa:nginx/stable -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "updating package list... \c"
apt-get update -ysuo > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "upgrading packages... \c"
apt-get upgrade -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "upgrading distro... \c"
apt-get dist-upgrade -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "removing unutilized packages... \c"
apt-get autoremove -y > /dev/null 2> /home/"$username"/errors.log
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
echo -e "upgrading packages... \c"
apt-get upgrade -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "upgrading distro... \c"
apt-get dist-upgrade -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "removing unutilized packages... \c"
apt-get autoremove -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing debconf utils... \c"
apt-get install debconf-utils -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "setting preconfigured inputs for percona... \c"
debconf-set-selections <<< "percona-server-server-5.5 percona-server-server/root_password password $dbrootpass" > /dev/null 2> /home/"$username"/errors.log
debconf-set-selections <<< "percona-server-server-5.5 percona-server-server/root_password_again password $dbrootpass" > /dev/null 2> /home/"$username"/errors.log
echo "percona-server-server-5.5 percona-server-server/root_password password $dbrootpass" | debconf-set-selections
echo "percona-server-server-5.5 percona-server-server/root_password_again password $dbrootpass" | debconf-set-selections
echo -e "done!"
echo -e "installing percona... \c"
apt-get install -y percona-server-server-5.5 percona-server-client-5.5 > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "change root password for percona... \c"
echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$dbrootpass');" | mysql -uroot > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing php5... \c"
apt-get install php5-fpm -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "setting preconfigured inputs for phpmyadmin... \c"
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true" > /dev/null 2> /home/"$username"/errors.log
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $dbrootpass" > /dev/null 2> /home/"$username"/errors.log
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $dbrootpass" > /dev/null 2> /home/"$username"/errors.log
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $dbrootpass" > /dev/null 2> /home/"$username"/errors.log
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect lighttpd" > /dev/null 2> /home/"$username"/errors.log
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

echo -e "creating MYSQL database..."
mysql --user="root" --password="$dbrootpass" -e "CREATE DATABASE $dbname" > /dev/null 2> /home/"$username"/errors.log
echo -e "creating MYSQL user for specified database..."
mysql --user="root" --password="$dbrootpass" -e "GRANT USAGE ON *.* TO '$dbuser'@localhost IDENTIFIED BY '$dbpass'" > /dev/null 2> /home/"$username"/errors.log
echo -e "granting privelages for user on database..."
mysql --user="root" --password="$dbrootpass" -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@localhost" > /dev/null 2> /home/"$username"/errors.log
echo -e "flushing privelages to reset users/databases..."
mysql --user="root" --password="$dbrootpass" -e "FLUSH PRIVILEGES" > /dev/null 2> /home/"$username"/errors.log

echo -e "\n\n"

echo -e "creating "$sitename" directory... \c"
mkdir /home/"$username"/"$sitename"
echo -e "done!"
echo -e "owning "$sitename" directory... \c"
chown -R "$username":"$username" /home/"$username"/"$sitename"
echo -e "done!"
case $version in
  '1')
    echo -e "downloading commerce kickstart..."
    drush dl commerce_kickstart --destination="/home/$username/$sitename/" > /dev/null 2> /home/"$username"/errors.log
		echo -e "done!"
    echo -e "changing folder name to httpdocs..."
    mv /home/"$username"/"$sitename"/commerce* /home/"$username"/"$sitename"/httpdocs > /dev/null 2> /home/"$username"/errors.log
		echo -e "done!"
    ;;
  '2')
    echo -e "downloading drupal 7 core..."
    drush dl drupal-7 --destination="/home/$username/$sitename/" > /dev/null 2> /home/"$username"/errors.log
		echo -e "done!"
    echo -e "changing folder name to httpdocs..."
    mv /home/"$username"/"$sitename"/drupal* /home/"$username"/"$sitename"/httpdocs > /dev/null 2> /home/"$username"/errors.log
		echo -e "done!"
    ;;
  *)
    echo "1 for commerce or 2 for d7: "
    ;;
esac
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
cp -f nginx_template /etc/nginx/sites-enabled/
echo -e "done!"
echo -e "renaming the sites-enabled file to "$sitename"... \c"
cp -f /etc/nginx/sites-enabled/nginx_template /etc/nginx/sites-enabled/"$sitename"
echo -e "done!"
echo -e "configuring "$sitename" file... \c"
sed -i 's/$site_domain/'"$sitename"'/g' /etc/nginx/sites-enabled/"$sitename"
sed -i 's#$site_root#'"$rootdir"'#g' /etc/nginx/sites-enabled/"$sitename"
echo -e "done!"
echo -e "configuring php5... \c"
sed -i 's/www-data/'"$username"'/g' /etc/php5/fpm/pool.d/www.conf
sed -i 's/www-data/'"$username"'/g' /etc/php5/fpm/php-fpm.conf
echo -e "done!"
echo -e "creating link to phpmyadmin in httpdocs... \c"
su "$username" -c 'ln -s /usr/share/phpmyadmin /home/'"$username"'/'"$sitename"'/httpdocs'
echo -e "done!"
echo -e "rename default in sites folder to "$sitename"... \c"
su "$username" -c 'mv /home/'"$username"'/'"$sitename"'/httpdocs/sites/default /home/'"$username"'/'"$sitename"'/httpdocs/sites/'"$sitename"''
echo -e "done!"
echo -e "create symbolic link of "$sitename" and call it default... \c"
su "$username" -c 'ln -s /home/'"$username"'/'"$sitename"'/httpdocs/sites/'"$sitename"' /home/'"$username"'/'"$sitename"'/httpdocs/sites/default'
echo -e "done!"

echo -e "\n\n"

echo -e "updating package list... \c"
apt-get update -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "upgrading packages... \c"
apt-get upgrade -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "upgrading distro... \c"
apt-get dist-upgrade -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "removing unutilized packages... \c"
apt-get autoremove -y > /dev/null 2> /home/"$username"/errors.log
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
