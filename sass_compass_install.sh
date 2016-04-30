#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo -e "adding brightbox/ruby ppa... \c"
apt-add-repository ppa:brightbox/ruby-ng -y > /dev/null 2> /home/"$username"/errors.log
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
echo -e "installing ruby2.2 and ruby2.2dev packages... \c"
apt-get install ruby2.2 ruby2.2-dev -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing build essentials if not already installed ... \c"
apt-get install build-essentials -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "using gem to install sass... \c"
gem install sass > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "using gem to install compass... \c"
gem install compass > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"

echo -e "\n\n"
