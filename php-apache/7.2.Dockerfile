FROM php:7.2-apache

ARG uid=1000
ARG user=app
ENV APACHE_DOCUMENT_ROOT /var/www/app

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf


RUN apt-get update && apt-get install -y git curl libpng-dev libonig-dev libzip-dev libxml2-dev unzip libfreetype6-dev libwebp-dev libjpeg62-turbo-dev libpng-dev libgmp-dev
RUN pecl install xdebug-2.9.2 && docker-php-ext-enable xdebug
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-webp-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install gettext zip pdo_mysql mbstring intl exif pcntl bcmath gd gmp opcache
RUN echo 'memory_limit=2G' > /usr/local/etc/php/conf.d/memory-limit.ini

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN useradd -G www-data,root -u $uid -d /home/$user $user

RUN mkdir -p /home/$user/.composer && chown -R $user:$user /home/$user

RUN a2enmod rewrite

WORKDIR /var/www/app

USER app
