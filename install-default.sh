#!/bin/bash
#
# Procedimento para instalação dos principais programas para um servidor web
# Data: 23/02/2016
# Por: Douglas Cabral
#

# Executa como sudo
sudo -v

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

echo -n "Pressione qualquer tecla para sair..."
read
exit
                                                                                                     70,1          Fim
