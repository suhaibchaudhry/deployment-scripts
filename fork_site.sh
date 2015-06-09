#!/bin/bash
echo -e "What is the sitename (e.g. uitoux): \c"
read sitename

echo -e "Enter the preferred DB name: \c"
read dbname

echo -e "Enter the preferred DB username: \c"
read dbuser

echo -e "Enter the preferred DB password: \c"
read dbpass

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