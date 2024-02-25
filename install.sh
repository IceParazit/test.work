#!/bin/bash

    screen
    # Установка Apache и PHP 
    sudo apt update
    sudo apt install -y apache2 php libapache2-mod-php php-mysql php-cli php-common php-mbstring php-gd php-intl php-xml php-mysql php-zip php-curl php-xmlrpc wget unzip nginx mysql-server

    # Переменные для mysql
    DBuser="DB""$USER"
    DBname="DB""$(shuf -i 1-100 -n 1)"

    echo $DBuser >> /home/lin-admin/info.txt
    echo $DBname >> /home/lin-admin/info.txt
    DBuserPwd=$(sha256sum /home/lin-admin/info.txt | head -c 32)
    echo $DBuserPwd >> /home/lin-admin/info.txt
    Create_DBuser="CREATE USER '${DBuser}'@'localhost' IDENTIFIED BY '${DBuserPwd}';"
    Creat_DB="CREATE DATABASE $DBname"
    Grant_DB="GRANT ALL PRIVILEGES ON $DBname.* TO '${DBuser}'@'localhost' WITH GRANT OPTION;"

    # Переменные
    Site_ip='192.168.1.147'
    Port_apache='8080'
    Site_Name='test.work'
    CMS_name='cms.test.work'
    Git_Url='https://github.com/IceParazit/test.work.git'
    CMS_path="/var/www/joomla/"
    WP_path='/var/www/wordpress/'
    CMS_path_apache='\/var\/www\/joomla'
    WP_path_apache='\/var\/www\/wordpress'
    Apache_port_conf='ports.conf'
    TOKEN="6274025966:AAFlmK5dZTF5RxDd8UFkC3lJ49xJahOkWqg"
    CHAT_ID="-1002126724548"
    MESSAGE="script done"
    URL="https://api.telegram.org/bot$TOKEN/sendMessage"


    #
    sudo chown -R $USER:$USER /var/www
    cd /tmp
    git clone $Git_Url

    sudo cp /tmp/$Site_Name/nginx.conf /etc/nginx/sites-available/"${Site_Name}".conf
    sudo sed -i "s/enter_name_here/"$Site_Name"/g" /etc/nginx/sites-available/"$Site_Name".conf
    sudo sed -i "s/enter_ip_here/"$Site_ip"/g" /etc/nginx/sites-available/"$Site_Name".conf
    sudo sed -i "s/enter_port_here/"$Port_apache"/g" /etc/nginx/sites-available/"$Site_Name".conf
    sudo ln -s /etc/nginx/sites-available/"${Site_Name}".conf /etc/nginx/sites-enabled/"${Site_Name}".conf

    sudo cp /tmp/$Site_Name/nginx.conf /etc/nginx/sites-available/"${CMS_name}".conf
    sudo sed -i "s/enter_name_here/"$CMS_name"/g" /etc/nginx/sites-available/"$CMS_name".conf
    sudo sed -i "s/enter_ip_here/"$Site_ip"/g" /etc/nginx/sites-available/"$CMS_name".conf
    sudo sed -i "s/enter_port_here/"$Port_apache"/g" /etc/nginx/sites-available/"$CMS_name".conf
    sudo ln -s /etc/nginx/sites-available/"${CMS_name}".conf /etc/nginx/sites-enabled/"${CMS_name}".conf

    sudo cp /tmp/$Site_Name/apache2.conf /etc/apache2/sites-available/"${Site_Name}".conf
    sudo sed -i "s/enter_name_here/"$Site_Name"/g" /etc/apache2/sites-available/"$Site_Name".conf
    sudo sed -i "s/enter_port_here/"$Port_apache"/g" /etc/apache2/sites-available/"$Site_Name".conf
    sudo sed -i "s/enter_path_here/"$WP_path_apache"/g" /etc/apache2/sites-available/"$Site_Name".conf
    

    sudo cp /tmp/$Site_Name/apache2.conf /etc/apache2/sites-available/"${CMS_name}".conf
    sudo sed -i "s/enter_name_here/"$CMS_name"/g" /etc/apache2/sites-available/"$CMS_name".conf
    sudo sed -i "s/enter_port_here/"$Port_apache"/g" /etc/apache2/sites-available/"$CMS_name".conf
    sudo sed -i "s/enter_path_here/"$CMS_path_apache"/g" /etc/apache2/sites-available/"$CMS_name".conf

    sudo cp /tmp/$Site_Name/port.conf /etc/apache2/"${Apache_port_conf}"
    sudo sed -i "s/enter_port_here/"$Port_apache"/g" /etc/apache2/"$Apache_port_conf"

    sudo a2dissite 000-default.conf

    

    # Установка Joomla
    cd /tmp
    wget https://downloads.joomla.org/ru/cms/joomla5/5-0-2/Joomla_5-0-2-Stable-Full_Package.zip
    sudo mkdir /var/www/joomla/
    sudo cp /tmp/$Site_Name/.htaccess $CMS_path
    sudo unzip Joomla_5-0-2-Stable-Full_Package.zip -d $CMS_path
    sudo chown -R www-data.www-data $CMS_path
    sudo chmod -R 755 $CMS_path

   # Создание базы данных MySQL для WordPress
    sudo mysql -e "${Create_DBuser}"
    sudo mysql -e "${Creat_DB}"
    sudo mysql -e "${Grant_DB}"
    sudo mysql -e "FLUSH PRIVILEGES;"


    # Установка WordPress
    cd /tmp
    wget https://wordpress.org/latest.tar.gz
    tar -xzvf latest.tar.gz
    sudo mkdir $WP_path
    sudo cp /tmp/$Site_Name/wp-config.php $WP_path
    sudo sed -i "s/database_name_here/"$DBname"/g" /var/www/wordpress/wp-config.php
    sudo sed -i "s/username_here/"$DBuser"/g" /var/www/wordpress/wp-config.php
    sudo sed -i "s/password_here/"$DBuserPwd"/g" /var/www/wordpress/wp-config.php
    sudo cp --recursive wordpress/* $WP_path
    sudo chown -R www-data:www-data $WP_path
    sudo chmod -R 755 $WP_path

 

    # Конфигурация Apache для WordPress
    sudo rm /etc/nginx/sites-enabled/default
    sudo systemctl restart nginx
    sudo a2ensite "$Site_Name"
    sudo a2ensite "$CMS_name"
    sudo a2enmod rewrite
    sudo systemctl restart apache2
    sudo chown -R $USER:$USER /etc/hosts
    echo ""$Site_ip" "$Site_Name" www."$Site_Name"" >> /etc/hosts
    echo ""$Site_ip" "$CMS_name" www."$CMS_name"" >> /etc/hosts
    sudo chown -R root:root /etc/hosts



    curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE"

