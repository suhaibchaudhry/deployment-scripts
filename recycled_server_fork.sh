#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo -e "what is the domain name (e.g. uitoux): \c"
read site
sitename="$site.com"

echo -e "setting site root directory..."
rootdir="/home/$username/$sitename/httpdocs"

echo -e "\ndo you want to install memcached on the server (y/n): \c"
read memcached

echo -e "\ndo you want to install sass on the server (y/n): \c"
read sass_compass

echo -e "which drupal:"
echo -e "1) commerce"
echo -e "2) d7"
read version

echo -e "what is the root password for your database: \c"
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

echo -e "\n"

echo -e "MYSQL"
echo -e "------------------------------------------------------"

echo -e "creating MYSQL database..."
mysql --user="root" --password="$dbrootpass" -e "CREATE DATABASE $dbname" > /dev/null 2> /home/"$username"/errors.log
echo -e "creating MYSQL user for specified database..."
mysql --user="root" --password="$dbrootpass" -e "GRANT USAGE ON *.* TO '$dbuser'@localhost IDENTIFIED BY '$dbpass'" > /dev/null 2> /home/"$username"/errors.log
echo -e "granting privelages for user on database..."
mysql --user="root" --password="$dbrootpass" -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@localhost" > /dev/null 2> /home/"$username"/errors.log
echo -e "flushing privelages to reset users/databases..."
mysql --user="root" --password="$dbrootpass" -e "FLUSH PRIVILEGES" > /dev/null 2> /home/"$username"/errors.log

echo -e "\n"

echo -e "directory structure"
echo -e "------------------------------------------------------"

echo -e "creating site home folder..."
mkdir /home/"$username"/"$sitename".com > /dev/null 2> /home/"$username"/errors.log
case $version in
  '1')
    echo -e "downloading commerce kickstart..."
    drush dl commerce_kickstart > /dev/null 2> /home/"$username"/errors.log
    echo -e "changing folder name to httpdocs..."
    mv commerce* /home/"$username"/"$sitename".com/httpdocs > /dev/null 2> /home/"$username"/errors.log
    ;;
  '2')
    echo -e "downloading drupal 7 core..."
    drush dl drupal-7 > /dev/null 2> /home/"$username"/errors.log
    echo -e "changing folder name to httpdocs..."
    mv drupal* /home/"$username"/"$sitename".com/httpdocs > /dev/null 2> /home/"$username"/errors.log
    ;;
  *)
    echo "1 for commerce or 2 for d7: "
    ;;
esac

echo -e "creating symbolic link for PHPMyAdmin..."
ln -s /usr/share/phpmyadmin /home/"$username"/"$sitename".com/httpdocs/ > /dev/null 2> /home/"$username"/errors.log
echo -e "renaming default to sitename in sites..."
mv /home/"$username"/"$sitename".com/httpdocs/sites/default /home/"$username"/"$sitename".com/httpdocs/sites/"$sitename".com > /dev/null 2> /home/"$username"/errors.log
echo -e "creating symbolic link for sitename in sites..."
ln -s /home/"$username"/"$sitename".com/httpdocs/sites/"$sitename".com /home/"$username"/"$sitename".com/httpdocs/sites/default > /dev/null 2> /home/"$username"/errors.log
echo -e "removing all files/folders inside all/themes..."
rm -rf /home/"$username"/"$sitename".com/httpdocs/sites/all/themes/* > /dev/null 2> /home/"$username"/errors.log
echo -e "getting ui to ux base theme..."
git clone https://suhaib_uitoux:underwater908@bitbucket.org/uitouxteam/ui-to-ux-theme-kit.git /home/"$username"/"$sitename".com/httpdocs/sites/all/themes/ > /dev/null 2> /home/"$username"/errors.log

echo -e "\n"

echo -e "subtheme directory"
echo -e "------------------------------------------------------"

echo -e "changing directory to run drush..."
cd /home/"$username"/"$sitename".com/httpdocs/sites/"$sitename".com > /dev/null 2> /home/"$username"/errors.log
echo -e "running drush to install site..."
drush site-install standard --account-name="$drupaluser" --account-pass="$drupalpass" --db-url=mysql://"$dbuser":"$dbpass"@localhost/"$dbname" -y > /dev/null 2> /home/"$username"/errors.log
echo -e "changing permissions for site folder..."
chmod +w /home/"$username"/"$sitename".com/httpdocs/sites/"$sitename".com > /dev/null 2> /home/"$username"/errors.log
echo -e "creating themes directory..."
mkdir /home/"$username"/"$sitename".com/httpdocs/sites/"$sitename".com/themes > /dev/null 2> /home/"$username"/errors.log

echo -e "which theme do you want? (enter full theme name):"
n=1
for i in $(ls templates/themes/); do
  echo $n")" $i
  ((n++))
done

echo -e "\n"
read userTheme

case $userTheme in
  '1')
    echo -e "copying awpurology theme..."
    cp -R "$DIR"/templates/themes/awpurology /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes > /dev/null 2> /home/"$username"/errors.log
    ;;
  *)
    echo "enter a valid thene name: "
    ;;
esac

echo -e "changing uitoux base theme name to suit subtheme..."
mv /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$userTheme" /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site" > /dev/null 2> /home/"$username"/errors.log
echo -e "renaming info file within subtheme..."
rename -v 's/'"$userTheme"'/'"$site"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/*.* > /dev/null 2> /home/"$username"/errors.log

cp "$DIR"/templates/js_template.js /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/js/"$site"_custom.js

sed -i 's/THEMENAME/'"$sitename"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/js/"$site"_custom.js

echo -e "\n"

echo -e "file changes"
echo -e "------------------------------------------------------"

echo -e "changing all uitoux occurrances to match sitename..."

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
echo -e "changing all files within subdirectory to match sitename..."
rename -v 's/uitoux-theme/'"$site"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/css/*.* > /dev/null 2> /home/"$username"/errors.log
rename -v 's/uitoux_theme/'"$site"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/css/*.* > /dev/null 2> /home/"$username"/errors.log
rename -v 's/uitoux-theme/'"$site"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/scss/*.* > /dev/null 2> /home/"$username"/errors.log
rename -v 's/uitoux_theme/'"$site"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/scss/*.* > /dev/null 2> /home/"$username"/errors.log
rename -v 's/uitoux_theme/'"$site"'/g' /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/js/*.* > /dev/null 2> /home/"$username"/errors.log
echo -e "removing default.settings.php file..."
rm /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/default.settings.php > /dev/null 2> /home/"$username"/errors.log
echo -e "replacing template.php with empty template.php..."
rm /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/template.php > /dev/null 2> /home/"$username"/errors.log
touch /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/themes/"$site"/template.php > /dev/null 2> /home/"$username"/errors.log
echo -e "setting up new theme for first time use..."
cd /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/ > /dev/null 2> /home/"$username"/errors.log
drush pm-enable uitoux_theme -y > /dev/null 2> /home/"$username"/errors.log
drush pm-enable "$site" -y > /dev/null 2> /home/"$username"/errors.log
drush vset theme_default "$site" > /dev/null 2> /home/"$username"/errors.log

echo -e "\n\n"
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

echo -e "\n\n"

echo -e "restarting nginx... \c"
service nginx restart > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "restarting php5... \c"
service php5-fpm restart > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"

echo -e "\n\n"

case $memcached in
  'y')
    echo -e "installing memcached...\c"
    source memcached_install.sh
    ;;
  'n')
    ;;
  *)
    echo "y for memcached or n for regular server installation: "
    ;;
esac

echo -e "\n\n"

case $sass_compass in
  'y')
    echo -e "installing sass and compass...\c"
    source sass_compass_install.sh
    ;;
  'n')
    ;;
  *)
    echo "y for sass or n for regular server installation: "
    ;;
esac

echo -e "\n\n"
