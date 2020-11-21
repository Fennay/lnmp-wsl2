#! /bin/bash

### 说明
### php  7.4.12
### nginx 1.18.0
### redis 6.0.9
### 此脚本需要切换root用户执行

### 更换国内源
mv /etc/apt/sources.list /etc/apt/sources.list.backup

echo "deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list

# ### 这部分是测试代码

apt-get -y update
apt-get -y upgrade
apt-get install -y wget make

# ### 创建目录
mkdir -p /webser/{src,www,logs,redis/conf,redis/bin}

### 定义变量
nginx="nginx-1.18.0"
php="php-7.4.12"
redis="redis-6.0.9"

### 下载文件
# cd /webser/src
# wget -O $php.tar.gz https://www.php.net/distributions/$php.tar.gz
# wget -O $nginx.tar.gz http://nginx.org/download/$nginx.tar.gz
# wget -O $redis.tar.gz https://download.redis.io/releases/$redis.tar.gz


### 解压
cp ./src/* /webser/src
cd /webser/src 
tar zxvf $nginx.tar.gz
tar zxvf $php.tar.gz
tar zxvf $redis.tar.gz

### 删除垃圾文件
rm -rf ./*.tar.gz


### 安装必要软件
apt-get install -y openssl libssl-dev libpcre3 libpcre3-dev zlib1g-dev libzip-dev bison autoconf build-essential pkg-config git-core libltdl-dev libbz2-dev libxml2-dev libxslt1-dev libicu-dev libpspell-dev libenchant-dev libmcrypt-dev libpng-dev libjpeg8-dev libfreetype6-dev libmysqlclient-dev libreadline-dev libcurl4-openssl-dev librecode-dev libsqlite3-dev libonig-dev

### 安装nginx
cd /webser/src/$nginx && ./configure --prefix=/webser/nginx
make && make install
### 安装redis
cd /webser/src/$redis &&  make install prefix=/webser/redis
cp src/redis-* /webser/redis/bin
cp *.conf /webser/redis/conf/
rm -rf /webser/redis/bin/{*.c,*.d,*.o,*.rb}

### 安装php
cd /webser/src/$php
./configure --prefix=/webser/php74 \
--enable-mysqlnd \
--with-mysqli \
--with-pdo-mysql \
--enable-fpm \
--with-gd \
--with-iconv \
--with-zlib \
--enable-xml \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--enable-mbregex \
--enable-mbstring \
--enable-gd-native-ttf \
--with-openssl \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--without-pear \
--with-gettext \
--enable-session \
--with-curl \
--with-jpeg-dir \
--with-freetype-dir \
--enable-bcmath \
--without-sqlite3
make && make install

## 添加到环境变量
export $PATH:/webser/php74/bin/php >> ~/.bashrc

## 安装composer
/webser/php74/bin/php -r "copy('https://install.phpcomposer.com/installer', 'composer-setu
p.php');"
/webser/php74/bin/php composer-setup.php
/webser/php74/bin/php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer


## nginx PHP 绑定
touch /dev/shm/fpm-cgi.sock
chown www-data:www-data /dev/shm/fpm-cgi.sock
chmod 666 /dev/shm/fpm-cgi.sock

