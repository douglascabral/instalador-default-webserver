#!/bin/bash
#
# Procedimento para instalação dos principais programas para um servidor web
# Data: 23/02/2016
# Por: Douglas Cabral
#

# Executa como sudo
sudo -v

# Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
#see https://gist.github.com/cowboy/3118588
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Atualiza a lista de pacotes
sudo apt-get update

# Array de pacotes para instalar
programas=(
apache2
mysql-server
mysql-client
php5
libapache2-mod-php5
php5-mysql
php5-curl
php5-gd
php5-idn
php-pear
php5-imagick
php5-imap
php5-mcrypt
php5-memcache
php5-mhash
php5-ming
php5-ps
php5-pspell
php5-recode
php5-snmp
php5-sqlite
php5-tidy
php5-xmlrpc
php5-xsl
php5-json
)

#instala cada uma das aplicações
for i in "${programas[@]}"
do
    pacote=$(dpkg --get-selections | grep "$i")
    if [ -n "$pacote" ];
    then
        echo "Pacote $i já instalado"
    else
        echo "Instalando $i"
        sudo apt-get -y install "$i"
    fi
done

#restart o apache
echo "Reiniciando apache2"
sudo service apache2 restart

#ativa o mod_rewrite
echo "Ativando o mod_rewrite no apache"
sudo a2enmod rewrite

#restart o apache novamente
echo "Reiniciando apache2"
sudo service apache2 restart

#cria estrutura de diretorio e concede permissão para o usuário logado
sudo mkdir -p /var/www/test.local/public_html
sudo chown -R $USER:$USER /var/www/test.local/public_html

#permissão para o diretório web
sudo chmod -R 755 /var/www

#cria um arquivo index
touch /var/www/test.local/public_html/index.php

#phpinfo
echo '<?php phpinfo();' >> /var/www/test.local/public_html/index.php

#cria o virtualhost
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/test.local.conf

echo "
<Directory /var/www/test.local/>
	Options Indexes FollowSymLinks MultiViews
	AllowOverride All
	Order allow,deny
	allow from all
</Directory>
<VirtualHost *:80>
	ServerAdmin admin@example.com
	ServerName test.local
	ServerAlias www.test.local
	DocumentRoot /var/www/test.local/public_html
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" > /etc/apache2/sites-available/test.local.conf

#Ativa os novos arquivos de virtual host
echo "Ativando virtual host de test.local"
sudo a2ensite test.local.conf

#restart o apache novamente
echo "Reiniciando apache2"
sudo service apache2 restart

echo -n "Pressione qualquer tecla para sair..."
read
exit
                                                                                                     70,1          Fim
