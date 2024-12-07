FROM php:8.4.1-fpm

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG uid=1000
ARG user=app

ENV NVM_DIR=/home/${user}/.nvm
ENV NODE_VERSION=18.20.3

RUN apt-get update && apt-get upgrade -y &&  apt-get install -y --no-install-recommends \
    git curl libpq-dev libpng-dev libonig-dev libmagickwand-dev\
    libzip-dev libldap2-dev libxml2-dev unzip libwebp-dev libpng-dev \
    libgmp-dev libfreetype6-dev libmagickwand-dev libjpeg62-turbo-dev \
    libpng-dev libzip-dev default-mysql-client default-libmysqlclient-dev g++ && apt-get clean && rm -rf /var/lib/apt/lists/*

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
RUN id -u ${user} &>/dev/null || useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user && chown -R $user:$user /home/$user

USER ${user}

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

RUN . $HOME/.nvm/nvm.sh && nvm install ${NODE_VERSION} && nvm alias default ${NODE_VERSION}

ENV PATH="/home/${user}/.nvm/versions/node/v${NODE_VERSION}/bin:${PATH}"

WORKDIR /var/www/app

USER root

RUN echo '#!/bin/bash' > /usr/local/bin/nvm && \
    echo 'export NVM_DIR="/home/'${user}'/.nvm"' >> /usr/local/bin/nvm && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /usr/local/bin/nvm && \
    echo 'nvm "$@"' >> /usr/local/bin/nvm && \
    chmod +x /usr/local/bin/nvm

USER ${user}