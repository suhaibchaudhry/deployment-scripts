#!/usr/bin/env bash
apt-get install memcached -y
apt-get install php5-dev -y
apt-get install libmemcached-dev -y
apt-get install pkg-config -y
pecl install igbinary
echo extension="igbinary.so" > /etc/php5/mods-available/igbinary.ini 
cd /etc/php5/fpm/conf.d && ln -s ../../mods-available/igbinary.ini 05-igbinary.ini
cd /etc/php5/cli/conf.d && ln -s ../../mods-available/igbinary.ini 05-igbinary.ini
cd ~ && mkdir memcached_tmp && cd memcached_tmp
pecl download memcached
tar -xvzf memcached*.t*gz
cd memcached*/
phpize
./configure --enable-memcached-igbinary --disable-memcached-sasl
make
make install
cp -f memcached.ini /etc/php5/mods-available/
cd /etc/php5/fpm/conf.d && ln -s ../../mods-available/memcached.ini 10-memcached.ini
cd /etc/php5/cli/conf.d && ln -s ../../mods-available/memcached.ini 10-memcached.ini
cd /etc/php5/mods-available/ && sed -i '1iextension="memcached.so"' memcached.ini
service php5-fpm restart
cd ~ && rm -rf memcached_tmp
