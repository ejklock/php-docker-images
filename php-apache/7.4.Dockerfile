FROM php:7.4-apache

ARG uid=1000
ARG user=app
ENV APACHE_DOCUMENT_ROOT /var/www/app

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN apt-get update && apt-get install -y git curl libpng-dev libonig-dev build-essential libmagickwand-dev libmagickwand-dev libzip-dev libldap2-dev libxml2-dev unzip libwebp-dev libpng-dev libgmp-dev libfreetype6-dev libmagickwand-dev libjpeg62-turbo-dev libpng-dev libzip-dev g++

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pecl install imagick 
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN cd /usr/src/php/ext/gd && make
RUN cp /usr/src/php/ext/gd/modules/gd.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/gd.so
RUN docker-php-ext-install -j$(nproc) gd gettext zip pdo_mysql mbstring intl exif pcntl bcmath gmp mysqli ldap
RUN echo 'memory_limit=2G' > /usr/local/etc/php/conf.d/memory-limit.ini
RUN a2enmod rewrite

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

WORKDIR /var/www/app

USER $user
