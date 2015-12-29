#!/usr/bin/env bash
echo -e "installing memcached... \c"
apt-get install memcached -y
echo -e "done!"
echo -e "installing php5 dev... \c"
apt-get install php5-dev -y
echo -e "done!"
echo -e "intalling libmemcached (dev)... \c"
apt-get install libmemcached-dev -y
echo -e "done!"
echo -e "installing package config... \c"
apt-get install pkg-config -y
echo -e "done!"
echo -e "installing igbinary...\c"
pecl install igbinary
echo -e "done!"
echo -e "adding igbinary.so to ini file... \c"
<<<<<<< HEAD
echo 'extension="igbinary.so"' > /etc/php5/mods-available/igbinary.ini
=======
echo 'extension="igbinary.so"' > /etc/php5/mods-available/igbinary.ini > /dev/null 2> /home/"$username"/errors.log
>>>>>>> 2a57af1cd246360da04833685c1ddfb2fbce9806
echo -e "done!"
echo -e "making symbolic links to ini... \c"
cd /etc/php5/fpm/conf.d && ln -s ../../mods-available/igbinary.ini 05-igbinary.ini
cd /etc/php5/cli/conf.d && ln -s ../../mods-available/igbinary.ini 05-igbinary.ini
echo -e "done!"
echo -e "making temporary memcached directory... \c"
cd ~ && mkdir memcached_tmp && cd memcached_tmp
echo -e "done!"
echo -e "dowlnoad memcached... \c"
pecl download memcached
echo -e "done!"
echo -e "extract memcached... \c"
tar -xvzf memcached*.t*gz
echo -e "done!"
cd memcached*/
echo -e "phpizing... \c"
phpize
echo -e "done!"
echo -e "configuring memcached before install.. \c"
./configure --enable-memcached-igbinary --disable-memcached-sasl
echo -e "done!"
echo -e "making make file... \c"
make
echo -e "done!"
echo -e "installing... \c"
make install
echo -e "done!"
echo -e "copying memcached ini to mods available... \c"
cp -f memcached.ini /etc/php5/mods-available/
echo -e "done!"
echo -e "making symbolic links to ini... \c"
cd /etc/php5/fpm/conf.d && ln -s ../../mods-available/memcached.ini 10-memcached.ini
cd /etc/php5/cli/conf.d && ln -s ../../mods-available/memcached.ini 10-memcached.ini
echo -e "done!"
echo -e "setting extension to memcached.so... \c"
cd /etc/php5/mods-available/ && sed -i '1iextension="memcached.so"' memcached.ini
echo -e "done!"
echo -e "restarting php5... \c"
service php5-fpm restart
echo -e "done!"
echo -e "removing memcached temporary directory... \c"
cd ~ && rm -rf memcached_tmp
echo -e "done!"

echo -e "\n\n"
