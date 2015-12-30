#!/bin/bash
echo -e "adding brightbox/ruby ppa... \c"
apt-add-repository ppa:brightbox/ruby-ng -y
echo -e "done!"
echo -e "updating and upgrading the distro... \c"
apt-get update -y && apt-get dist-upgrade -y
echo -e "done!"
echo -e "installing ruby2.2 and ruby2.2dev packages... \c"
apt-get install ruby2.2 ruby2.2-dev -y
echo -e "done!"
echo -e "installing build essentials if not already installed ... \c"
apt-get install build-essentials -y
echo -e "done!"
echo -e "using gem to install sass... \c"
gem install sass
echo -e "done!"
echo -e "using gem to install compass... \c"
gem install compass
echo -e "done!"

echo -e "\n\n"
