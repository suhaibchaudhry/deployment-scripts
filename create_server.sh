#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

export DEBIAN_FRONTEND=noninteractive
echo -e "what username do you want to create: \c"
read user
username="$user"

echo -e "what is the domain name (e.g. uitoux): \c"
read site
sitename="$site.com"

echo -e "setting site root directory... \c"
rootdir="/home/$username/$sitename/httpdocs"
echo -e "done!"

echo -e "what password do you want to set for root: \c"
read -s rootpassword
rootpass="$rootpassword"

echo -e "\ndo you want to install memcached on the server (y/n): \c"
read memcached

echo -e "do you want to install sass on the server (y/n): \c"
read sass_compass

echo -e "what password do you want to set for "$username": \c"
read -s userpassword
userpass="$userpassword"

echo -e "which drupal:"
echo -e "1) commerce"
echo -e "2) d7"
read version

echo -e "what password do you want to set for root in the database: \c"
read -s dbrootpassword
dbrootpass="$dbrootpassword"

echo -e "\ndrupal username: \c"
read drupaluser

echo -e "drupal password: \c"
read -s drupalpass

echo -e "\ndb name: \c"
read dbname

echo -e "db username: \c"
read dbuser

echo -e "db password: \c"
read -s dbpass

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
echo -e "installing nginx... \c"
apt-get install nginx -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
#echo -e "installing key for percona... \c"
#apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A  > /dev/null 2> /home/"$username"/errors.log
#echo -e "done!"
#echo -e "adding repo to sources list... \c"
#echo "deb http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list
#echo "deb-src http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list
#echo -e "done!"
echo -e "fetching percona... \c"
wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing percona... \c"
dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb > /dev/null 2> /home/"$username"/errors.log
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
echo -e "installing php... \c"
apt-get install php-fpm -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "setting preconfigured inputs for phpmyadmin... \c"
debconf-set-selections <<< "phpmyadmin phpmyadmin/setup-password password $dbrootpass" > /dev/null 2> /home/"$username"/errors.log
debconf-set-selections <<< "phpmyadmin phpmyadmin/password-confirm password $dbrootpass" > /dev/null 2> /home/"$username"/errors.log
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
phpenmod mcrypt > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing php5 curl... \c"
apt-get install php-curl -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"

echo -e "creating MYSQL database... \c"
mysql --user="root" --password="$dbrootpass" -e "CREATE DATABASE $dbname" > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "creating MYSQL user for specified database... \c"
mysql --user="root" --password="$dbrootpass" -e "GRANT USAGE ON *.* TO '$dbuser'@localhost IDENTIFIED BY '$dbpass'" > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "granting privelages for user on database... \c"
mysql --user="root" --password="$dbrootpass" -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@localhost" > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "flushing privelages to reset users/databases... \c"
mysql --user="root" --password="$dbrootpass" -e "FLUSH PRIVILEGES" > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"

echo -e "creating "$sitename" directory... \c"
mkdir /home/"$username"/"$sitename"
echo -e "done!"
echo -e "owning "$sitename" directory... \c"
chown -R "$username":"$username" /home/"$username"/"$sitename"
echo -e "done!"

case $version in
  '1')
    echo -e "downloading commerce kickstart... \c"
    drush dl commerce_kickstart --destination="/home/$username/$sitename/" > /dev/null 2> /home/"$username"/errors.log
		echo -e "done!"
    echo -e "changing folder name to httpdocs... \c"
    mv /home/"$username"/"$sitename"/commerce* /home/"$username"/"$sitename"/httpdocs > /dev/null 2> /home/"$username"/errors.log
		echo -e "done!"
    ;;
  '2')
    echo -e "downloading drupal 7 core... \c"
    drush dl drupal-7 --destination="/home/$username/$sitename/" > /dev/null 2> /home/"$username"/errors.log
		echo -e "done!"
    echo -e "changing folder name to httpdocs... \c"
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
echo -e "initialize git repo... \c"
su "$username" -c 'git init /home/'"$username"'/'"$sitename"'/httpdocs' > /dev/null 2> /home/"$username"/errors.log
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
echo -e "removing nginx template file... \c"
rm /etc/nginx/sites-enabled/nginx_template
echo -e "done!"
echo -e "configuring "$sitename" file... \c"
sed -i 's/$site_domain/'"$sitename"'/g' /etc/nginx/sites-enabled/"$sitename"
sed -i 's#$site_root#'"$rootdir"'#g' /etc/nginx/sites-enabled/"$sitename"
echo -e "done!"
echo -e "configuring php... \c"
sed -i 's/www-data/'"$username"'/g' /etc/php/7.0/fpm/pool.d/www.conf
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

echo -e "removing all files/folders inside all/themes... \c"
rm -rf /home/"$username"/"$sitename"/httpdocs/sites/all/themes/* > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "getting ui to ux base theme... \c"
git clone https://suhaib_uitoux:underwater908@bitbucket.org/uitouxteam/ui-to-ux-theme-kit.git /home/"$username"/"$sitename"/httpdocs/sites/all/themes/ > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"

echo -e "changing directory to run drush... \c"
cd /home/"$username"/"$sitename"/httpdocs/sites/"$sitename" > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "running drush to install site... \c"
drush site-install standard --account-name="$drupaluser" --account-pass="$drupalpass" --db-url=mysql://"$dbuser":"$dbpass"@localhost/"$dbname" -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "changing permissions for site folder... \c"
chmod +w /home/"$username"/"$sitename"/httpdocs/sites/"$sitename" > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "creating themes directory... \c"
mkdir /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "copying over uitoux base theme... \c"
cp -R /home/"$username"/"$sitename"/httpdocs/sites/all/themes/uitoux_theme /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "changing uitoux base theme name to suit subtheme... \c"
mv /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/uitoux_theme /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site" > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "renaming info file within subtheme... \c"
rename -v 's/uitoux_theme/'"$site"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/*.* > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"

cp "$DIR"/templates/js_template.js /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/js/"$site"_custom.js

sed -i 's/THEMENAME/'"$sitename"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/js/"$site"_custom.js

echo -e "changing all uitoux occurrances to match sitename... \c"

sed -i 's/.*jquery_browser.*//g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/"$site".info
sed -i 's/.*omega_formalize.*//g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/"$site".info

rm  /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/preprocess/*.inc

sed -i 's/uitoux_theme/'"$site"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/"$site".info
sed -i 's/omega_kickstart/uitoux_theme/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/"$site".info > /dev/null 2> /home/"$username"/errors.log
sed -i 's/UI To UX/'"$site"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/"$site".info > /dev/null 2> /home/"$username"/errors.log
sed -i 's/UI To UX Theme/'"$site"' Theme/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/"$site".info*** > /dev/null 2> /home/"$username"/errors.log
sed -i 's/UI To UX Base Theme/'"$site"' Theme/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/"$site".info > /dev/null 2> /home/"$username"/errors.log
sed -i 's/UI To UX Theme/'"$site"' Theme/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/"$site".info > /dev/null 2> /home/"$username"/errors.log
sed -i 's/package = '"$site"'/package = UI To UX/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/"$site".info > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "changing all files within subdirectory to match sitename... \c"
rename -v 's/uitoux-theme/'"$site"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/css/*.* > /dev/null 2> /home/"$username"/errors.log
rename -v 's/uitoux_theme/'"$site"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/css/*.* > /dev/null 2> /home/"$username"/errors.log
rename -v 's/uitoux-theme/'"$site"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/scss/*.* > /dev/null 2> /home/"$username"/errors.log
rename -v 's/uitoux_theme/'"$site"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/scss/*.* > /dev/null 2> /home/"$username"/errors.log
rename -v 's/uitoux_theme/'"$site"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/js/*.* > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "removing default.settings.php file... \c"
rm /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/default.settings.php > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "replacing template.php with empty template.php... \c"
rm /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/template.php > /dev/null 2> /home/"$username"/errors.log
touch /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/template.php > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "setting up new theme for first time use... \c"
cd /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/ > /dev/null 2> /home/"$username"/errors.log
drush pm-enable uitoux_theme -y > /dev/null 2> /home/"$username"/errors.log
drush pm-enable "$site" -y > /dev/null 2> /home/"$username"/errors.log
drush vset theme_default "$site" > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing libraries module... \c"
cd /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/ > /dev/null 2> /home/"$username"/errors.log
su "$username" -c 'drush dl libraries -y' > /dev/null 2> /home/"$username"/errors.log
su "$username" -c 'drush en libraries -y' > /dev/null 2> /home/"$username"/errors.log
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

echo -e "restarting nginx... \c"
service nginx restart > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "restarting php... \c"
service php7.0-fpm restart > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"

echo -e "owning site folder... \c"
chown -R "$username":"$username" /home/"$username"/"$sitename"/httpdocs/sites/
echo -e "done!"

case $memcached in
  'y')
    echo -e "installing memcached..."
    source "$DIR"/memcached_install.sh
    ;;
  'n')
    ;;
  *)
    echo "y for memcached or n for regular server installation: "
    ;;
esac

case $sass_compass in
  'y')
    echo -e "installing sass and compass..."
    source "$DIR"/sass_compass_install.sh
    ;;
  'n')
    ;;
  *)
    echo "y for sass or n for regular server installation: "
    ;;
esac

echo -e "\n\n"
