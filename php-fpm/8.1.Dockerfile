FROM php:8.1-fpm

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

RUN apt-get update && apt-get upgrade -y &&  apt-get install --no-install-recommends -y \
    git curl libpq-dev libpng-dev libonig-dev libmagickwand-dev\
    libzip-dev libldap2-dev libxml2-dev unzip libwebp-dev libpng-dev \
    libgmp-dev libfreetype6-dev libmagickwand-dev libjpeg62-turbo-dev \
    libpng-dev libzip-dev g++ && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pecl install imagick xdebug
RUN docker-php-ext-enable imagick xdebug
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp
RUN cd /usr/src/php/ext/gd && make
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql

RUN docker-php-ext-install -j$(nproc) gd gettext zip pgsql pdo_pgsql pdo_mysql mbstring intl exif pcntl bcmath gmp mysqli ldap opcache sockets

RUN echo 'memory_limit=2G' > /usr/local/etc/php/conf.d/memory-limit.ini

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN useradd -G www-data,root -u $uid -d /home/$user $user

RUN mkdir -p /home/$user/.composer && chown -R $user:$user /home/$user

WORKDIR /var/www/app

USER app
