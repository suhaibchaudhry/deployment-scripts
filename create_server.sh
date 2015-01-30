#!/bin/bash
echo "Setting variables"
echo "What name do you want for your account? "
read name
name="$name"
echo "What username do you want to create? "
read user
username="$user"
echo "What sitename do you want to create? "
read site
sitename="$site"
echo "What password do you want for root? "
read rootpassword
rootpass="$rootpassword"
echo "What password do you want for your username? "
read usernamepassword
userpass="$usernamepassword"

echo "Changing password for root"
echo root:$rootpass | /usr/sbin/chpasswd

echo "Creating a new user"
useradd -s /bin/bash -m "$username" -d /home/"$username" -g "$username"
echo $username:$userpass | /usr/sbin/chpasswd

echo "Installing LEMP stack"
apt-add-repository ppa:nginx/stable -y
apt-get install nginx -y
apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
echo "deb http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list
echo "deb-src http://repo.percona.com/apt trusty main" >> /etc/apt/sources.list
apt-get update -y
apt-get dist-upgrade -y
sudo debconf-set-selections <<< 'percona-server-server-5.5 percona-server-server-5.5/$rootpass password $rootpass'
sudo debconf-set-selections <<< 'percona-server-server-5.5 percona-server-server-5.5/$rootpass password $rootpass'
apt-get install percona-server-server-5.5 percona-server-client-5.5 -y
apt-get install php5-fpm -y
debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean true'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password $rootpass'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect lighttpd'
apt-get install phpmyadmin -y
apt-get install drush -y
apt-get install php5-cli -y
apt-get install php5-mcrypt -y
apt-get install php5-curl -y
php5enmod mcrypt

echo "Create filesystem"
sudo "$username" -c "mkdir ~/$sitename"
sudo "$username" -c "wget http://ftp.drupal.org/files/projects/drupal-7.34.tar.gz -P ~/$sitename/"
sudo "$username" -c "tar -xvzf ~/$sitename/drupal-7.34.tar.gz"
sudo "$username" -c "rm ~/$sitename/drupal-7.34.tar.gz"
sudo "$username" -c "mv ~/$sitename/drupal-7.34.tar.gz ~/$sitename/httpdocs"
sudo "$username" -c "sed -i 's/www-data/"$username"/g' /etc/nginx/nginx.conf"
sudo "$username" -c "rm /etc/nginx/sites-enabled/default"
sudo "$username" -c "rsync -azPK -e "ssh -p 2222" suhaib@96.88.40.226:/home/suhaib/backups/nginx_conf/sample_se.com /etc/nginx/sites-enabled/"
sudo "$username" -c "mv ~/etc/nginx/sites-enabled/sample_se.com ~/etc/nginx/sites-enabled/"$sitename".com"
sudo "$username" -c "sed -i 's/suhaib/$username/g' /etc/nginx/sites-enabled/"$sitename".com"
sudo "$username" -c "sed -i 's/uitoux/$sitename/g' /etc/nginx/sites-enabled/"$sitename".com"
sudo "$username" -c "sed -i 's/www-data/$username/g' /etc/php5/fpm/pool.d/www.conf"
sudo "$username" -c "sed -i 's/www-data/$username/g' /etc/php5/fpm/php-fpm.conf"
sudo "$username" -c "ln -s /usr/share/phpmyadmin ~/"$sitename"/httpdocs"
sudo "$username" -c "mv ~/"$sitename"/httpdocs/sites/default ~/"$sitename"/httpdocs/sites/"$sitename".com"
sudo "$username" -c "ln -s ~/"$sitename"/httpdocs/sites/"$sitename".com ~/"$sitename"/httpdocs/sites/default"
#sudo "$username"
#cd ~
#mkdir "$sitename"
#cd "$sitename"
#wget http://ftp.drupal.org/files/projects/drupal-7.34.tar.gz
#tar -xvzf drupal-7.34.tar.gz
#rm drupal-7.34.tar.gz
#mv drupal-7.34 httpdocs
#sed -i 's/www-data/"$username"/g' /etc/nginx/nginx.conf
#cd /etc/nginx/sites-enabled/
#rm default
#rsync -azPK -e "ssh -p 2222" suhaib@96.88.40.226:/home/suhaib/backups/nginx_conf/sample_se.com /etc/nginx/sites-enabled/
#mv sample_se.com "$sitename".com
#sed -i 's/suhaib/$username/g' /etc/nginx/sites-enabled/"$sitename".com
#sed -i 's/uitoux/$sitename/g' /etc/nginx/sites-enabled/"$sitename".com
#sed -i 's/www-data/$username/g' /etc/php5/fpm/pool.d/www.conf
#sed -i 's/www-data/$username/g' /etc/php5/fpm/php-fpm.conf
#cd ~/"$sitename"/httpdocs
#ln -s /usr/share/phpmyadmin .
#cd sites
#mv default "$sitename".com
#ln -s "$sitename".com default
#exit

echo "Restart all services"
service nginx restart
service php5-fpm restart

echo "Installing ZSH and Oh-My-Zsh Packages"
apt-get install zsh -y
apt-get install git-core -y
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
chsh -s 'which zsh'

echo "Changing username shell to ZSH"
sudo "$username" -c "wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh"
sudo "$username" -c "chsh -s 'which zsh'"
#wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
#chsh -s 'which zsh'
#exit
reboot