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

#
# Função para dar feedback ao usuário sobre o que está acontecendo no script
#
feedback()
{
	echo
	echo "----------------------------------------------------------------"
	echo "$1"
	echo "----------------------------------------------------------------"
	echo 
}

# Verifica se há dependencias necessárias para rodar o script corretamente
curl --version
if ! [ $? -eq 0 ];
then
	feedback "Curl não instalado. Instalando as dependencias necessárias para o script."
	sudo apt-get update
	sudo apt-get -y install curl
fi

#Repositório nodejs LTS mais recente
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -

# Atualiza a lista de pacotes
sudo apt-get update

# Array de pacotes para instalar (Na ordem de importancia)
PROGRAMAS=(
build-essential
zlib1g-dev
libssl-dev
libreadline-dev
libyaml-dev
libcurl4-openssl-dev
python-software-properties
libsqlite3-dev
libxml2-dev
libxslt1-dev
libffi-dev
git
sqlite3
apache2
memcached
mysql-server
mysql-client
mysql-utilities
libmysql++-dev
php7.0 
libapache2-mod-php7.0
php7.0-cgi
php7.0-cli
php7.0-common
php7.0-curl
php7.0-dev
php7.0-gd
php7.0-gmp
php7.0-json
php7.0-ldap
php7.0-mysql
php7.0-odbc
php7.0-opcache
php7.0-pgsql
php7.0-pspell
php7.0-readline
php7.0-recode
#php7.0-snmp
php7.0-sqlite3
php7.0-tidy
php7.0-xml
php7.0-xmlrpc
libphp7.0-embed
php7.0-bcmath
php7.0-bz2
php7.0-enchant
php7.0-fpm
php7.0-imap
php7.0-interbase
php7.0-intl
php7.0-mbstring
php7.0-mcrypt
php7.0-phpdbg
php7.0-soap
php7.0-sybase
php7.0-xsl
php7.0-zip
php-pear
php-imagick
php-gettext
nodejs
npm
)

#instala cada uma das aplicações
feedback "Instalando lista de programas"
for i in "${PROGRAMAS[@]}"
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
feedback "Reiniciando apache2"
sudo service apache2 restart

#ativa o mod_rewrite
feedback "Ativando o mod_rewrite no apache"
sudo a2enmod rewrite

#restart o apache novamente
feedback "Reiniciando apache2"
sudo service apache2 restart

if ! [ -d /var/www/test.local ];
then
	#cria estrutura de diretorio e concede permissão para o usuário logado
	feedback "Criando estrutura de diretório para test.local"
	sudo mkdir -p /var/www/test.local/public_html
	sudo chown -R $USER:$USER /var/www/test.local

	#permissão para o diretório web
	sudo chmod -R 755 /var/www

	#cria um arquivo index
	touch /var/www/test.local/public_html/index.php

	#phpinfo
	echo '<?php phpinfo();' > /var/www/test.local/public_html/index.php

	#cria o virtualhost
	feedback "Criando virtualhost para test.local"
	sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/test.local.conf

	echo "
	<Directory /var/www/test.local/public_html/>
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
	" | sudo tee /etc/apache2/sites-available/test.local.conf

	#Ativa os novos arquivos de virtual host
	feedback "Ativando virtual host de test.local"
	sudo a2ensite test.local.conf

	#restart o apache novamente
	feedback "Reiniciando apache2"
	sudo service apache2 restart

	#Atualiza o arquivo hosts
	feedback "Atualizando arquivo hosts"
	echo "127.0.1.1   test.local www.test.local" | sudo tee --append /etc/hosts
else
	echo "Estrutura de test.local já existe"
fi

#Instala o composer
feedback "Instalando o composer"
if [ -e /usr/local/bin/composer ]; 
then
	echo "Composer já esta instalado"
else
	curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
fi

#Cria o alias pra o node
feedback "Criando alias para nodejs > node"
sudo ln -s /usr/bin/nodejs /usr/bin/node

#Atualiza o npm
sudo npm install npm -g
 
#Instala o grunt
feedback "Instalando o grunt-cli globalmente"
sudo npm install grunt-cli -g

feedback "Instalando o bower globalmente"
sudo npm install bower -g


#Instala o ruby
#see https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rbenv-on-ubuntu-14-04
#see http://www.leonardteo.com/2012/11/install-ruby-on-rails-on-ubuntu-server/
feedback "Verificando se Ruby está instalado"
ruby -v
if [ $? -eq 0 ];
then
	echo "Ruby já está instalado"
else
	feedback "Instalando Ruby"
	wget -O ruby-stable.tar.gz https://cache.ruby-lang.org/pub/ruby/stable-snapshot.tar.gz
	tar -zxf ruby-stable.tar.gz
	mv ./stable-snapshot ./ruby-stable
	cd ruby-stable
	./configure
	make
	sudo make install
	echo "gem: --no-ri --no-rdoc" >> ~/.gemrc
	cd ..
	rm -R --force ruby-stable ruby-stable.tar.gz

	#Instala o bundle
	feedback "Instalando o bundler"
	sudo gem install bundler

	#Instala o SASS
	feedback "Instalando o sass"
	sudo gem install sass
fi

feedback "Todas as instalações foram realizadas!"

#Espera interação do usuário
echo -n "Pressione qualquer tecla para sair..."
read
exit
