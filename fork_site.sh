#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo -e "sitename (e.g. uitoux): \c"
read sitename

echo -e "db name: \c"
read dbname

echo -e "db username: \c"
read dbuser

echo -e "db password: \c"
read dbpass

echo -e "drupal username: \c"
read drupaluser

echo -e "drupal password: \c"
read drupalpass

echo -e "\n"

echo -e "MYSQL"
echo -e "------------------------------------------------------"

echo -e "creating MYSQL database..."
mysql --user="root" --password="DAxyz&*^" -e "CREATE DATABASE $dbname" > /dev/null 2> ~/errors.log
echo -e "creating MYSQL user for specified database..."
mysql --user="root" --password="DAxyz&*^" -e "GRANT USAGE ON *.* TO '$dbuser'@localhost IDENTIFIED BY '$dbpass'" > /dev/null 2> ~/errors.log
echo -e "granting privelages for user on database..."
mysql --user="root" --password="DAxyz&*^" -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@localhost" > /dev/null 2> ~/errors.log
echo -e "flushing privelages to reset users/databases..."
mysql --user="root" --password="DAxyz&*^" -e "FLUSH PRIVILEGES" > /dev/null 2> ~/errors.log

echo -e "\n"

echo -e "directory structure"
echo -e "------------------------------------------------------"

echo -e "creating site home folder..."
mkdir ~/"$sitename".com > /dev/null 2> ~/errors.log
echo -e "downloading latest drupal..."
drush dl drupal > /dev/null 2> ~/errors.log
echo -e "changing folder name to httpdocs..."
mv drupal* ~/"$sitename".com/httpdocs > /dev/null 2> ~/errors.log
echo -e "creating symbolic link for PHPMyAdmin..."
ln -s /usr/share/phpmyadmin ~/"$sitename".com/httpdocs/ > /dev/null 2> ~/errors.log
echo -e "renaming default to sitename in sites..."
mv ~/"$sitename".com/httpdocs/sites/default ~/"$sitename".com/httpdocs/sites/"$sitename".com > /dev/null 2> ~/errors.log
echo -e "creating symbolic link for sitename in sites..."
ln -s ~/"$sitename".com/httpdocs/sites/"$sitename".com ~/"$sitename".com/httpdocs/sites/default > /dev/null 2> ~/errors.log
echo -e "removing all files/folders inside all/themes..."
rm -rf ~/"$sitename".com/httpdocs/sites/all/themes/* > /dev/null 2> ~/errors.log
echo -e "getting ui to ux base theme..."
git clone https://suhaib_uitoux:underwater908@bitbucket.org/uitouxteam/ui-to-ux-theme-kit.git ~/"$sitename".com/httpdocs/sites/all/themes/ > /dev/null 2> ~/errors.log

echo -e "\n"

echo -e "subtheme directory"
echo -e "------------------------------------------------------"

echo -e "changing directory to run drush..."
cd ~/"$sitename".com/httpdocs/sites/"$sitename".com > /dev/null 2> ~/errors.log
echo -e "running drush to install site..."
drush site-install standard --account-name="$drupaluser" --account-pass="$drupalpass" --db-url=mysql://"$dbuser":"$dbpass"@localhost/"$dbname" -y > /dev/null 2> ~/errors.log
echo -e "changing permissions for site folder..."
chmod +w ~/"$sitename".com/httpdocs/sites/"$sitename".com > /dev/null 2> ~/errors.log
echo -e "creating themes directory..."
mkdir ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes > /dev/null 2> ~/errors.log
echo -e "copying over uitoux base theme..."
cp -R ~/"$sitename".com/httpdocs/sites/all/themes/uitoux_theme ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes > /dev/null 2> ~/errors.log
echo -e "changing uitoux base theme name to suit subtheme..."
mv ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/uitoux_theme ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename" > /dev/null 2> ~/errors.log
echo -e "renaming info file within subtheme..."
rename -v 's/uitoux_theme/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/*.* > /dev/null 2> ~/errors.log

rm -rf ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/js/*
cp "$DIR"/templates/js_template.js ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/js/"$sitename"_custom.js

sed -i 's/THEMENAME/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/js/"$sitename"_custom.js

echo -e "\n"

echo -e "file changes"
echo -e "------------------------------------------------------"

echo -e "changing all uitoux occurrances to match sitename..."

sed -i 's/.*jquery_browser.*//g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info
sed -i 's/.*omega_formalize.*//g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info

sed -i 's/uitoux_theme/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info
sed -i 's/omega_kickstart/uitoux_theme/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info > /dev/null 2> ~/errors.log
sed -i 's/UI To UX/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info > /dev/null 2> ~/errors.log
sed -i 's/UI To UX Theme/'"$sitename"' Theme/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info*** > /dev/null 2> ~/errors.log
sed -i 's/UI To UX Base Theme/'"$sitename"' Theme/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info > /dev/null 2> ~/errors.log
sed -i 's/UI To UX Theme/'"$sitename"' Theme/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info > /dev/null 2> ~/errors.log
sed -i 's/package = '"$sitename"'/package = UI To UX/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info > /dev/null 2> ~/errors.log
echo -e "changing all files within subdirectory to match sitename..."
rename -v 's/uitoux-theme/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/css/*.* > /dev/null 2> ~/errors.log
rename -v 's/uitoux_theme/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/css/*.* > /dev/null 2> ~/errors.log
rename -v 's/uitoux-theme/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/scss/*.* > /dev/null 2> ~/errors.log
rename -v 's/uitoux_theme/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/scss/*.* > /dev/null 2> ~/errors.log
rename -v 's/uitoux_theme/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/js/*.* > /dev/null 2> ~/errors.log
echo -e "removing default.settings.php file..."
rm ~/"$sitename".com/httpdocs/sites/"$sitename".com/default.settings.php > /dev/null 2> ~/errors.log
echo -e "replacing template.php with empty template.php..."
rm ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/template.php > /dev/null 2> ~/errors.log
touch ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/template.php > /dev/null 2> ~/errors.log
echo -e "setting up new theme for first time use..."
cd ~/"$sitename".com/httpdocs/sites/"$sitename".com/ > /dev/null 2> ~/errors.log
drush pm-enable uitoux_theme -y > /dev/null 2> ~/errors.log
drush pm-enable "$sitename" -y > /dev/null 2> ~/errors.log
drush vset theme_default "$sitename" > /dev/null 2> ~/errors.log

echo -e "\n\n"
echo -e "done!"