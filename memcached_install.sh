#!/usr/bin/env bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo -e "installing memcached package... \c"
apt-get install memcached -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing php5 dev... \c"
apt-get install php5-dev -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "intalling libmemcached (dev)... \c"
apt-get install libmemcached-dev -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing package config... \c"
apt-get install pkg-config -y > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing igbinary...\c"
pecl install igbinary > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "adding igbinary.so to ini file... \c"
echo 'extension="igbinary.so"' > /etc/php5/mods-available/igbinary.ini
echo -e "done!"
echo -e "making symbolic links to ini... \c"
cd /etc/php5/fpm/conf.d && ln -s ../../mods-available/igbinary.ini 05-igbinary.ini > /dev/null 2> /home/"$username"/errors.log
cd /etc/php5/cli/conf.d && ln -s ../../mods-available/igbinary.ini 05-igbinary.ini > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "making temporary memcached directory... \c"
cd ~ && mkdir memcached_tmp && cd memcached_tmp > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "download memcached... \c"
pecl download memcached > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "extract memcached... \c"
tar -xvzf memcached*.t*gz > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
cd memcached*/ > /dev/null 2> /home/"$username"/errors.log
echo -e "phpizing... \c"
phpize > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "configuring memcached before install.. \c"
./configure --enable-memcached-igbinary --disable-memcached-sasl > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "making make file... \c"
make > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "installing... \c"
make install > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "copying memcached ini to mods available... \c"
cp -f memcached.ini /etc/php5/mods-available/ > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "making symbolic links to ini... \c"
cd /etc/php5/fpm/conf.d && ln -s ../../mods-available/memcached.ini 10-memcached.ini > /dev/null 2> /home/"$username"/errors.log
cd /etc/php5/cli/conf.d && ln -s ../../mods-available/memcached.ini 10-memcached.ini > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "setting extension to memcached.so... \c"
cd /etc/php5/mods-available/ && sed -i '1iextension="memcached.so"' memcached.ini > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "restarting php5... \c"
service php5-fpm restart > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"
echo -e "removing memcached temporary directory... \c"
cd ~ && rm -rf memcached_tmp > /dev/null 2> /home/"$username"/errors.log
echo -e "done!"

echo -e "\n\n"
