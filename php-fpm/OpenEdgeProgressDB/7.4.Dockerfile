# This image includes the ODBC driver for the Progress database using the PROGRESS_DATADIRECT_ODBC_OE_LINUX.

FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

RUN apt-get update && apt-get install -y ksh unixodbc unixodbc-dev xterm git curl libpq-dev libpng-dev libonig-dev libzip-dev libldap2-dev libxml2-dev unzip libwebp-dev libpng-dev  libgmp-dev libfreetype6-dev libmagickwand-dev libjpeg62-turbo-dev libpng-dev libzip-dev g++
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN pecl install imagick-3.4.4
RUN docker-php-ext-enable imagick
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN cd /usr/src/php/ext/gd && make
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN cp /usr/src/php/ext/gd/modules/gd.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/gd.so

RUN docker-php-ext-install -j$(nproc) gd gettext zip pgsql pdo_pgsql pdo_mysql mbstring intl exif pcntl bcmath gmp mysqli ldap opcache sockets

RUN docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr && docker-php-ext-install pdo_odbc


COPY PROGRESS_DATADIRECT_ODBC_OE_LINUX_64.tar.gz silent.cfg /tmp/

# Descompactando o arquivo tar.gz
RUN tar -xvf /tmp/PROGRESS_DATADIRECT_ODBC_OE_LINUX_64.tar.gz -C /tmp/

# Tornando o script executável
RUN chmod +x /tmp/unixmi.ksh

# Executando o script unixmi.ksh
RUN cd /tmp && ./unixmi.ksh -f /tmp/silent.cfg

# Limpando os arquivos temporários
RUN rm -rf /tmp/PROGRESS_DATADIRECT_ODBC_OE_LINUX_64.tar.gz /tmp/silent.cfg /tmp/unixmi.ksh

RUN echo 'memory_limit=2G' > /usr/local/etc/php/conf.d/memory-limit.ini

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN useradd -G www-data,root -u $uid -d /home/$user $user

RUN mkdir -p /home/$user/.composer && chown -R $user:$user /home/$user

COPY odbc.ini /etc/odbc.ini
COPY odbcinst.ini /etc/odbcinst.ini

# Sets the LD_LIBRARY_PATH environment variable
 
ENV LD_LIBRARY_PATH /opt/connectforodbc/lib:$LD_LIBRARY_PATH

WORKDIR /var/www/app

USER app
