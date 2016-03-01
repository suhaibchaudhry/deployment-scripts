#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo -e "what site do you want to backup? (uitoux.com)"
read site
sitename=$site.com

timestamp=$(date +"%m-%d-%Y_%H-%M")

echo -e "changing directory to run drush... \c"
cd /home/"$username"/"$sitename"/httpdocs/sites/"$sitename"/ > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "creating mysql dump... \c"
drush sql-dump --result-file=/home/"$username"/"$sitename"/"$sitename"-dump-$timestamp.sql > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "changing ownership of dump... \c"
chown -R $username:$username /home/"$username"/"$sitename"/ > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "returning to main directory... \c"
cd $DIR
echo -e "done!"
