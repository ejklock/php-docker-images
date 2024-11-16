FROM php:7.4.33-fpm

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

RUN apt-get update && apt upgrade -y && apt-get install -y --no-install-recommends \
    libldap2-dev libpq-dev git curl libpng-dev libonig-dev libzip-dev \
    libxml2-dev unzip libfreetype6-dev libwebp-dev \
    libjpeg62-turbo-dev libpng-dev libgmp-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pecl install xdebug-2.9.8 && docker-php-ext-enable xdebug
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-webp-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install gd gettext zip pgsql pdo_pgsql pdo_mysql mbstring intl exif pcntl bcmath gmp mysqli ldap opcache sockets

RUN echo 'memory_limit=2G' > /usr/local/etc/php/conf.d/memory-limit.ini

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && chown -R $user:$user /home/$user

WORKDIR /var/www/app

USER ${user}
