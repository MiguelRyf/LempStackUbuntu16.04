#!/bin/bash

# Script author: Miguel Emmara
# Script site: https://www.miguelemmara.me
# One Click LEMP Ubunti 16.4 Installation Script
#--------------------------------------------------
# Software version:
# 1. OS: Ubuntu 16.04.6 LTS (Xenial Xerus)
# 2. Nginx: 1.10.3 (Ubuntu)
# 3. MariaDB: 10.0.38-MariaDB-0ubuntu0.16.04.1
# 4. PHP 7:  7.0.33-0ubuntu0.16.04.12
#--------------------------------------------------

set -e

# Colours
red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

    # Function update os
    clear
    echo "${grn}Starting update os ...${end}"
    echo ""
    sleep 3
    apt-get update >/dev/null 2>&1
	DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq >/dev/null 2>&1
    echo ""
    sleep 1

    # Allow openSSH UFW
    echo "${grn}Allow openSSH UFW ...${end}"
    echo "" 
    sleep 2
    ufw allow OpenSSH >/dev/null 2>&1
    echo ""
    sleep 1

    # Enabling UFW
    echo "${grn}Enabling UFW ...${end}"
    echo ""
    sleep 2
    yes | ufw enable >/dev/null 2>&1
    echo "y"
    echo ""
    sleep 1

    # Install MariaDB server
    echo "${grn}Installing MariaDB ...${end}"
    echo "" 
    sleep 2
    MARIADB_VERSION='10.1'
    debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password password $1" >/dev/null 2>&1
    debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password_again password $1" >/dev/null 2>&1
    apt-get install -qq mariadb-server >/dev/null 2>&1
    echo ""
    sleep 1

    echo "${grn}Installing PHP 7.0 ...${end}"
    echo ""
    sleep 2
    apt install php7.0-fpm php-mysql -y >/dev/null 2>&1
    apt-get install php7.0 php7.0-common php7.0-gd php7.0-mysql php7.0-imap php7.0-cli php7.0-cgi php-pear mcrypt imagemagick libruby php7.0-curl php7.0-intl php7.0-pspell php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl memcached php-memcache php-imagick php-gettext php7.0-zip php7.0-mbstring memcached php7.0-soap php7.0-fpm php7.0-opcache php-apcu -y >/dev/null 2>&1
    echo ""
    sleep 1

    # Install and start nginx
    echo "${grn}Installing NGINX ...${end}"
    echo ""
    sleep 3
    apt-get install nginx -y >/dev/null 2>&1
    ufw allow 'Nginx HTTP' >/dev/null 2>&1
    systemctl start nginx >/dev/null 2>&1

        # Configure PHP FPM
    sed -i "s/max_execution_time = 30/max_execution_time = 360/g" /etc/php/7.0/fpm/php.ini
    sed -i "s/error_reporting = .*/error_reporting = E_ALL \& ~E_NOTICE \& ~E_STRICT \& ~E_DEPRECATED/" /etc/php/7.0/fpm/php.ini
    sed -i "s/display_errors = .*/display_errors = Off/" /etc/php/7.0/fpm/php.ini
    sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.0/fpm/php.ini
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 256M/" /etc/php/7.0/fpm/php.ini
    sed -i "s/post_max_size = .*/post_max_size = 256M/" /etc/php/7.0/fpm/php.ini
    echo ""
    sleep 1

    # Installing Memcached
    echo "${grn}Installing Memcached ...${end}"
    echo ""
    sleep 2
    apt install memcached -y >/dev/null 2>&1
    echo ""
    sleep 1
    apt install php-memcached -y >/dev/null 2>&1
    sleep 1

    # Installing IONCUBE
    echo "${grn}Installing IONCUBE ...${end}"
    echo ""
    sleep 2
    # PHP Modules folder
    MODULES=$(php -i | grep ^extension_dir | awk '{print $NF}')
 
    # PHP Version
    PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
 
    # Download ioncube
    wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz >/dev/null 2>&1
    tar -xvzf ioncube_loaders_lin_x86-64.tar.gz >/dev/null 2>&1
    rm -f ioncube_loaders_lin_x86-64.tar.gz >/dev/null 2>&1
    # Copy files to modules folder
    sudo cp "ioncube/ioncube_loader_lin_${PHP_VERSION}.so" $MODULES >/dev/null 2>&1
    echo "zend_extension=$MODULES/ioncube_loader_lin_${PHP_VERSION}.so" >> /etc/php/7.0/fpm/php.ini
    echo "zend_extension=$MODULES/ioncube_loader_lin_${PHP_VERSION}.so" >> /etc/php/7.0/cli/php.ini

    rm -rf ioncube
    systemctl restart php7.0-fpm.service >/dev/null 2>&1
    systemctl restart nginx >/dev/null 2>&1

    # Mcrypt
    apt-get install php-dev libmcrypt-dev php-pear -y >/dev/null 2>&1
    pecl channel-update pecl.php.net >/dev/null 2>&1
    apt-get install mcrypt php7.0-mcrypt -y >/dev/null 2>&1
    systemctl restart php7.0-fpm.service >/dev/null 2>&1
    systemctl restart nginx >/dev/null 2>&1
    echo ""
    sleep 1

    # Install and start nginx
    echo "${grn}Installing HTOP ...${end}"
    echo ""
    sleep 2
    apt-get install htop >/dev/null 2>&1
    echo ""
    sleep 1

    # Install netstat
    echo "${grn}Installing netstat ...${end}"
    echo ""
    sleep 2
    apt install net-tools -y >/dev/null 2>&1
    netstat -ptuln >/dev/null 2>&1
    echo ""
    sleep 1

    # Install OPENSSL
    echo "${grn}Installing OPENSSL${end}"
    echo ""
    sleep 2
    cd /etc/ssl/certs/
    openssl dhparam -dsaparam -out dhparam.pem 4096 >/dev/null 2>&1
    cd
    ufw allow 'Nginx Full' >/dev/null 2>&1
    ufw delete allow 'Nginx HTTP' >/dev/null 2>&1
    echo ""
    sleep 1

    # Install AB BENCHMARKING TOOL
    echo "${grn}Installing AB BENCHMARKING TOOL ...${end}"
    echo ""
    sleep 2
    apt-get install apache2-utils -y >/dev/null 2>&1
    echo ""
    sleep 1

    # Install ZIP AND UNZIP
    echo "${grn}Installing ZIP AND UNZIP ...${end}"
    echo ""
    sleep 2
    apt-get install unzip >/dev/null 2>&1
    apt-get install zip >/dev/null 2>&1
    echo ""
    sleep 1

    # Install FFMPEG and IMAGEMAGICK
    echo "${grn}Installing FFMPEG AND IMAGEMAGICK...${end}"
    echo ""
    sleep 2
    apt-get install imagemagick -y >/dev/null 2>&1
    apt-get install ffmpeg -y >/dev/null 2>&1
    echo ""
    sleep 1

    # Tuning Nginx Configurartion
    echo "${grn}Tuning Nginx Configurartion...${end}"
    echo ""
    sleep 2
    rm -rf /etc/nginx/nginx.conf >/dev/null 2>&1
    cd /etc/nginx/
    wget https://raw.githubusercontent.com/MiguelRyf/LempStackUbuntu16.04/master/scripts/nginx.conf -O nginx.conf >/dev/null 2>&1
    dos2unix /etc/nginx/nginx.conf >/dev/null 2>&1
    cd
    echo ""
    sleep 1

    # Change Login Greeting
    echo "${grn}Change Login Greeting ...${end}"
    echo ""
    sleep 2
    cat > .bashrc << EOF
echo "########################### SERVER CONFIGURED BY MIGUEL EMMARA ###########################"
echo " ######################## FULL INSTRUCTIONS GO TO MIGUELEMMARA.ME ####################### "
echo ""
echo " __  __ _                  _   ______"                                    
echo "|  \/  (_)                | | |  ____|                                    "
echo "| \  / |_  __ _ _   _  ___| | | |__   _ __ ___  _ __ ___   __ _ _ __ __ _ "
echo "| |\/| | |/ _  | | | |/ _ \ | |  __| | '_   _ \| '_   _ \ / _  | '__/ _  |"
echo "| |  | | | (_| | |_| |  __/ | | |____| | | | | | | | | | | (_| | | | (_| |"
echo "|_|  |_|_|\__, |\__,_|\___|_| |______|_| |_| |_|_| |_| |_|\__,_|_|  \__,_|"
echo "           __/ |"                                                        
echo "          |___/"
echo ""
./menu.sh
EOF
echo ""
sleep 1

    # PHP POOL SETTING
    echo "${grn}Configuring to make PHP-FPM working with Nginx ...${end}"
    echo ""
    sleep 3
    php7_dotdeb="https://raw.githubusercontent.com/MiguelRyf/LempStackUbuntu16.04/master/scripts/php7dotdeb"
    wget -q $php7_dotdeb -O /etc/php/7.0/fpm/pool.d/$domain.conf >/dev/null 2>&1
    sed -i "s/domain.com/$domain/g" /etc/php/7.0/fpm/pool.d/$domain.conf
    echo "" >> /etc/php/7.0/fpm/pool.d/$domain.conf
    dos2unix /etc/php/7.0/fpm/pool.d/$domain.conf >/dev/null 2>&1
    service php7.0-fpm reload >/dev/null 2>&1

        # Restart nginx and php-fpm
    echo "R${grn}estart Nginx & PHP-FPM ...${end}"
    echo ""
    sleep 1
    systemctl restart nginx >/dev/null 2>&1
    systemctl restart php7.0-fpm.service >/dev/null 2>&1

     # Menu Script
    cd
    wget https://raw.githubusercontent.com/MiguelRyf/LempStackUbuntu16.04/master/scripts/menu.sh -O menu.sh >/dev/null 2>&1
    dos2unix menu.sh >/dev/null 2>&1
    chmod +x menu.sh

    # Success Prompt
    #clear
    echo "LEMP Auto Installer BY Miguel Emmara `date`"
    echo "*******************************************************************************************"
    echo ""
    echo " __  __ _                  _   ______"                                    
    echo "|  \/  (_)                | | |  ____|                                    "
    echo "| \  / |_  __ _ _   _  ___| | | |__   _ __ ___  _ __ ___   __ _ _ __ __ _ "
    echo "| |\/| | |/ _  | | | |/ _ \ | |  __| | '_   _ \| '_   _ \ / _  | '__/ _  |"
    echo "| |  | | | (_| | |_| |  __/ | | |____| | | | | | | | | | | (_| | | | (_| |"
    echo "|_|  |_|_|\__, |\__,_|\___|_| |______|_| |_| |_|_| |_| |_|\__,_|_|  \__,_|"
    echo "           __/ |"                                                        
    echo "          |___/"
    echo ""
    echo "********************* OPEN MENU BY TYPING ${grn}./menu.sh${end} ******************************"
    echo ""

rm -f /root/lemp-ubuntu-16.04.sh
exit