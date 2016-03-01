#!/usr/bin/env bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo -e "is this a new server? (y/n) \c"
read newServerAnswer

case $newServerAnswer in
  'y')
    echo -e "launching server setup...\n"
    source create_server.sh
    ;;
  'n')
    read username=$(who | awk '{ print $1; exit}') > /dev/null 2> /home/"$username"/errors.log
    ;;
  *)
    echo "y for memcached or n for regular server installation: "
    ;;
esac

repeatAnswer="y"

while [ $repeatAnswer = "y" ];
do
  echo -e "what would you like to do"
  echo -e "1) install sass"
  echo -e "2) install memcached"
  echo -e "3) update/upgrade server"
  echo -e "4) fork a website"
  echo -e "5) backup database (under developement)"
  read todo

  case $todo in
    '1')
      echo -e "launching sass setup...\n"
      source sass_compass_install.sh
      ;;
    '2')
      echo -e "launching memcached setup...\n"
      source memcached_install.sh
      ;;
    '3')
      apt-get update -y && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove -y > /dev/null 2> /home/"$username"/errors.log
      ;;
    '4')
      echo -e "launching website fork setup...\n"
      source fork_site.sh
      ;;
    '5')
      echo -e "launching database dump...\n"
      echo -e "under developement, check back again later! \n"
      ;;
    *)
      echo "y for memcached or n for regular server installation: "
      ;;
  esac

  echo -e "do you want to return to the main menu? (y/n)"
  read repeatAnswer
done
