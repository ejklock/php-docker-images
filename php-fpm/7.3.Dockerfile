FROM php:7.3-fpm

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

RUN apt-get update && \
    apt-get update && apt-get upgrade -y && \ 
    apt-get install -y git curl libpq-dev libpng-dev \
    libonig-dev libzip-dev libldap2-dev libxml2-dev \
    unzip libwebp-dev libpng-dev libgmp-dev libfreetype6-dev \
    libmagickwand-dev libjpeg62-turbo-dev libpng-dev libzip-dev \
    g++ bash gettext autoconf make sudo && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-webp-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd gettext zip pgsql pdo_pgsql pdo_mysql mbstring intl exif pcntl bcmath gmp mysqli ldap opcache sockets

RUN pecl install imagick-3.4.4 && \
    docker-php-ext-enable imagick

RUN echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN useradd -u $uid -m -g www-data -G www-data -s /bin/bash $user && \
    usermod -aG sudo $user && \
    chsh -s /bin/bash $user

# Execute chown directly with uid
RUN mkdir -p /home/$user/.composer && chown -R $uid:$uid /home/$user

USER ${user}

WORKDIR /var/www/app
