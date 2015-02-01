#!/bin/bash
echo -e "---------------------------------------------------------------------------"
echo -e "|  ############ LETS START WITH SOME PRELIMINARY QUESTIONS! ############  |"
echo -e "---------------------------------------------------------------------------\n"

echo -e "---------------------------------------------------"
echo -e "|  TELL ME ABOUT YOU! (NAME/USERNAME/SERVERNAME)  |"
echo -e "---------------------------------------------------"

echo -e "What is your full name?\n\tFirst name: \c"
read firstname
echo -e "\tLast name: \c"
read lastname
name="$firstname $lastname"

echo -e "\nWhat username do you want to create: \c"
read username

echo -e "What name do you want to set for this server: \c"
read sitename

echo -e "\n------------------------------------"
echo -e "|  TIME TO SET UP SOME PASSWORDS!  |"
echo -e "------------------------------------"

echo -e "What password do you want to set for root: \c"
read -s rootpass 

echo -e "\nWhat password do you want to set for "$username": \c"
read -s userpass
echo -e "\n\n**************************************************************************************************"

echo -e "\n\n\n--------------------------------------------"
echo -e "|  ############ SERVER SETUP ############  |"
echo -e "--------------------------------------------"

echo -e "\n### Changing password for root ###\n"
echo root:$rootpass | /usr/sbin/chpasswd

echo -e "\n### Creating a new user ###\n"
groupadd "$username"
useradd -s /bin/bash -m "$username" -d /home/"$username" -g "$username"
echo "$username":"$userpass" | /usr/sbin/chpasswd

echo -e "\n### Installing LEMP stack ###\n"
echo -e "\n---adding nginx repo---\n"
apt-add-repository ppa:nginx/stable -y
apt-get install nginx -y > /dev/null 2>&1
echo -e "done..."
echo -e "\n---setting up percona to be installed---\n"
apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
echo "deb http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list
echo "deb-src http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list
echo -e "done..."
echo -e "\n---updating package list---\n"
apt-get update -y > /dev/null 2>&1
echo -e "done..."
echo -e "\n---upgrading distro---\n"
apt-get dist-upgrade -y > /dev/null 2>&1
echo -e "done..."
echo -e "\n---installing percona---\n"
echo "percona-server-server-5.5 percona-server-server/root_password password $rootpass" | debconf-set-selections
echo "percona-server-server-5.5 percona-server-server/root_password_again password $rootpass" | debconf-set-selections
apt-get install percona-server-server-5.5 percona-server-client-5.5 -y > /dev/null 2>&1
echo -e "done..."
echo -e "\n---installing php5---\n"
apt-get install php5-fpm -y > /dev/null 2>&1
echo -e "done..."
echo -e "\n---installing phpmyadmin---\n"
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $rootpass" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $rootpass" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $rootpass" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect lighttpd" | debconf-set-selections
apt-get install phpmyadmin -y > /dev/null 2>&1
echo -e "done..."
echo -e "\n---installing drush---\n"
apt-get install drush -y
echo -e "done..."
echo -e "\n---installing/enabling extra php modules---\n"
apt-get install php5-cli -y
apt-get install php5-mcrypt -y
apt-get install php5-curl -y
php5enmod mcrypt
apt-get install php5-gd -y
echo -e "done..."

echo -e "\n\n"

echo -e "\n### Create filesystem ###\n"
echo -e "\n---creating server directory---\n"
mkdir /home/"$username"/"$sitename".com
chown -R "$username":"$useranme" /home/"$username"/"$sitename".com
echo -e "done..."
echo -e "\n---getting drupal---\n"
wget http://ftp.drupal.org/files/projects/drupal-7.34.tar.gz -P /home/"$username"/"$sitename".com/
echo -e "done..."
echo -e "\n---extracing drupal---\n"
tar -xvzf /home/"$username"/"$sitename".com/drupal-7.34.tar.gz -C /home/"$username"/"$sitename".com/ > /dev/null 2>&1
echo -e "done..."
echo -e "\n---configuring drupal file structure---\n"
rm /home/"$username"/"$sitename".com/drupal-7.34.tar.gz
mv /home/"$username"/"$sitename".com/drupal-7.34 /home/"$username"/"$sitename".com/httpdocs
chown -R "$username":"$username" /home/"$username"/"$sitename".com/httpdocs
echo -e "done..."
echo -e "/n---configuring nginx---\n"
sed -i 's/www-data/'"$username"'/g' /etc/nginx/nginx.conf
rm /etc/nginx/sites-enabled/default
rsync -azPK -e "ssh -p 2222" suhaib@96.88.40.226:/home/suhaib/backups/nginx_conf/sample_se.com /etc/nginx/sites-enabled/
mv /etc/nginx/sites-enabled/sample_se.com /etc/nginx/sites-enabled/"$sitename".com
sed -i 's/uitoux/'"$username"'/g' /etc/nginx/sites-enabled/"$sitename".com
sed -i 's/'"$username"'.com/'"$sitename"'.com/g' /etc/nginx/sites-enabled/"$sitename".com
echo -e "done..."
echo -e "\n---configuring php5---\n"
sed -i 's/www-data/'"$username"'/g' /etc/php5/fpm/pool.d/www.conf
sed -i 's/www-data/'"$username"'/g' /etc/php5/fpm/php-fpm.conf
echo -e "done..."
echo -e "\n---cleaning up drupal---\n"
su "$username" -c 'ln -s /usr/share/phpmyadmin /home/'"$username"'/'"$sitename"'/httpdocs'
su "$username" -c 'mv /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/default /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/'"$sitename"'.com'
su "$username" -c 'ln -s /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/'"$sitename"'.com /home/'"$username"'/'"$sitename"'.com/httpdocs/sites/default'
echo -e "done..."

echo -e "\n\n"

echo -e "\n### Restart all services ###\n"
service nginx restart
service php5-fpm restart
echo -e "done..."

echo -e "\n\n"

echo -e "\n### Restarting Server ###\n"
reboot