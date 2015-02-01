#!/bin/bash
echo -e "what username do you want to create: \c"
read user
username=$user

echo -e "what name do you want to set for this server: \c"
read site
sitename=$site

echo -e "what password do you want to set for root: \c"
read rootpassword
rootpass=$rootpassword

echo -e "\nwhat password do you want to set for "$username": \c"
read userpassword
userpass=$userpassword

echo -e "\n\n\n"

echo -e "changing password for root..."
echo root:"$rootpass" | /usr/sbin/chpasswd

echo -e "creating new group for "$username"..."
groupadd "$username"
echo -e "creating user "$username"..."
useradd -s /bin/bash -m "$username" -d /home/"$username" -g "$username"
echo "$username":"$userpass" | /usr/sbin/chpasswd

echo -e "adding nginx repo..."
apt-add-repository ppa:nginx/stable -y
echo -e "installing nginx..."
apt-get install nginx -y
echo -e "installing key for percona..."
apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
echo -e "adding repo to sources list"...
echo "deb http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list
echo "deb-src http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list
echo -e "updating package list..."
apt-get update -y
echo -e "upgrading distro..."
apt-get dist-upgrade -y
echo -e "setting preconfigured inputs for percona..."
echo "percona-server-server-5.5 percona-server-server/root_password password $rootpass" | debconf-set-selections
echo "percona-server-server-5.5 percona-server-server/root_password_again password $rootpass" | debconf-set-selections
echo -e "installing percona..."
apt-get install percona-server-server-5.5 percona-server-client-5.5 -y
echo -e "installing php5..."
apt-get install php5-fpm -y
echo -e "setting preconfigured inputs for phpmyadmin..."
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $rootpass" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $rootpass" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $rootpass" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect lighttpd" | debconf-set-selections
echo -e "installing phpmyadmin..."
apt-get install phpmyadmin -y
echo -e "installing drush..."
apt-get install drush -y
echo -e "installing php5 cli..."
apt-get install php5-cli -y
echo -e "installing php5 mcrypt..."
apt-get install php5-mcrypt -y
echo -e "enabling mcrypt..."
php5enmod mcrypt
echo -e "installing php5 curl..."
apt-get install php5-curl -y
echo -e "installing php5 gd..."
apt-get install php5-gd -y

echo -e "\n\n"

echo -e "\n### Create filesystem ###\n"
echo -e "creating "$sitename".com directory..."
mkdir /home/"$username"/"$sitename".com
echo -e "owning "$sitename".com directory..."
chown -R "$username":"$useranme" /home/"$username"/"$sitename".com
echo -e "retrieving drupal..."
wget http://ftp.drupal.org/files/projects/drupal-7.34.tar.gz -P /home/"$username"/"$sitename".com/
echo -e "extracing drupal..."
tar -xvzf /home/"$username"/"$sitename".com/drupal-7.34.tar.gz -C /home/"$username"/"$sitename".com/
echo -e "removing drupal tar file..."
rm /home/"$username"/"$sitename".com/drupal-7.34.tar.gz
echo -e "renaming drupal file to httpdocs..."
mv /home/"$username"/"$sitename".com/drupal-7.34 /home/"$username"/"$sitename".com/httpdocs
echo -e "owning httpdocs..."
chown -R "$username":"$username" /home/"$username"/"$sitename".com/httpdocs
echo -e "configuring nginx.conf..."
sed -i 's/www-data/'"$username"'/g' /etc/nginx/nginx.conf
echo -e "removing default sites-enabled..."
rm /etc/nginx/sites-enabled/default
echo -e "adding own sites-enabled file..."
rsync -azPK -e "ssh -p 2222" suhaib@96.88.40.226:/home/suhaib/backups/nginx_conf/sample_se.com /etc/nginx/sites-enabled/
echo -e "renaming the sites-enabled file to "$sitename".com..."
mv /etc/nginx/sites-enabled/sample_se.com /etc/nginx/sites-enabled/"$sitename".com
echo -e "configuring "$sitename.com" file..."
sed -i 's/uitoux/'"$username"'/g' /etc/nginx/sites-enabled/"$sitename".com
sed -i 's/'"$username"'.com/'"$sitename"'.com/g' /etc/nginx/sites-enabled/"$sitename".com
echo -e "configuring php5..."
sed -i 's/www-data/'"$username"'/g' /etc/php5/fpm/pool.d/www.conf
sed -i 's/www-data/'"$username"'/g' /etc/php5/fpm/php-fpm.conf
echo -e "creating link to phpmyadmin in httpdocs..."
su "$username" -c 'ln -s /usr/share/phpmyadmin /home/'"$username"'/'"$sitename"'/httpdocs'
echo -e "rename default in sites folder to "$sitename".com..."
su "$username" -c 'mv /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/default /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/'"$sitename"'.com'
echo -e "create symbolic link of "$sitename".com and call it default..."
su "$username" -c 'ln -s /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/'"$sitename"'.com /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/default'

echo -e "\n\n"

echo -e "restarting nginx..."
service nginx restart
echo -e "restarting php5..."
service php5-fpm restart

echo -e "\n\n"

echo -e "restarting server, please stand by..."
reboot