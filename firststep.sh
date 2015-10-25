#!/bin/bash
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

echo -e "db name: \c"
read databasename
dbname="$databasename"

echo -e "db username: \c"
read databaseuser
dbuser="$databaseuser"

echo -e "db password: \c"
read databasepass
dbpass="$databasepass"

echo -e "changing password for root... \c"
echo root:"$rootpass" | /usr/sbin/chpasswd > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"

echo -e "creating new group for "$username"... \c"
groupadd "$username" > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "creating user "$username"... \c"
useradd -s /bin/bash -m "$username" -d /home/"$username" -g "$username" > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo "$username":"$userpass" | /usr/sbin/chpasswd > /dev/null 2> /home/"$username"/errors.log
