#!/bin/bash
echo -e "What is the sitename (e.g. uitoux): \c"
read sitename

echo -e "Enter the preferred DB name: \c"
read dbname

echo -e "Enter the preferred DB username: \c"
read dbuser

echo -e "Enter the preferred DB password: \c"
read dbpass

echo -e "Enter Drupal username: \c"
read drupaluser

echo -e "Enter Drupal password: \c"
read drupalpass

echo -e "\n\n\n"

mysql --user="root" --password="DAxyz&*^" -e "CREATE DATABASE $dbname"
mysql --user="root" --password="DAxyz&*^" -e "GRANT USAGE ON *.* TO '$dbuser'@localhost IDENTIFIED BY '$dbpass'"
mysql --user="root" --password="DAxyz&*^" -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@localhost"
mysql --user="root" --password="DAxyz&*^" -e "FLUSH PRIVILEGES"

mkdir ~/"$sitename".com
drush dl drupal
mv drupal* ~/"$sitename".com/httpdocs
ln -s /usr/share/phpmyadmin ~/"$sitename".com/httpdocs/
mv ~/"$sitename".com/httpdocs/sites/default ~/"$sitename".com/httpdocs/sites/"$sitename".com
ln -s ~/"$sitename".com/httpdocs/sites/"$sitename".com ~/"$sitename".com/httpdocs/sites/default
rm -rf ~/"$sitename".com/httpdocs/sites/all/themes/*
git clone https://suhaib_uitoux:underwater908@bitbucket.org/uitouxteam/ui-to-ux-theme-kit.git ~/"$sitename".com/httpdocs/sites/all/themes/

cd ~/"$sitename".com/httpdocs/sites/"$sitename".com
drush site-install standard --account-name="$drupaluser" --account-pass="$drupalpass" --db-url=mysql://"$dbuser":"$dbpass"@localhost/"$dbname" -y
chmod +w ~/"$sitename".com/httpdocs/sites/"$sitename".com
mkdir ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes
cp -R ~/"$sitename".com/httpdocs/sites/all/themes/uitoux_theme ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes
mv ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/uitoux_theme ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"
rename -v 's/uitoux_theme/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/*.*

sed -i 's/uitoux_theme/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info
sed -i 's/omega_kickstart/uitoux_theme/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info
sed -i 's/UI To UX/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info
sed -i 's/UI To UX Theme/'"$sitename"' Theme/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info***
sed -i 's/UI To UX Base Theme/'"$sitename"' Theme/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info
sed -i 's/UI To UX Theme/'"$sitename"' Theme/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info
sed -i 's/package = '"$sitename"'/package = UI To UX/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/"$sitename".info

rename -v 's/uitoux-theme/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/css/*.*
rename -v 's/uitoux_theme/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/css/*.*
rename -v 's/uitoux-theme/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/scss/*.*
rename -v 's/uitoux_theme/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/scss/*.*
rename -v 's/uitoux_theme/'"$sitename"'/g' ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/js/*.*

rm ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/template.php
touch ~/"$sitename".com/httpdocs/sites/"$sitename".com/themes/"$sitename"/template.php