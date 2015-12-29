#!/bin/bash
#echo -e "who are you"
#read -s who

#source /home/suhaib/bitbucket/deployment_scripts/test2.sh
echo -e "is this a new server or a recycled server? (y/n) \c"
read servertype


case $servertype in
  'y'|'Y')
    echo -e "yes"
    ;;
  'n'|'N')
    echo -e "no"
    ;;
  *)
    echo "what"
    ;;
esac
