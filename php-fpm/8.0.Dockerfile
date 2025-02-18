FROM php:8.0-fpm

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG uid=1000
ARG user=app

ENV NVM_DIR=/home/${user}/.nvm
ENV NODE_VERSION=18.20.3

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    default-libmysqlclient-dev \
    default-mysql-client \
    g++ \
    git \
    libfreetype6-dev \
    libgmp-dev \
    libjpeg62-turbo-dev \
    libldap2-dev \
    libmagickwand-dev \
    libonig-dev \
    libpng-dev \
    libpq-dev \
    libwebp-dev \
    libxml2-dev \
    libzip-dev \
    unzip && \
    rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN pecl install imagick xdebug && \
    docker-php-ext-enable imagick xdebug

# Configure and install GD
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    cd /usr/src/php/ext/gd && make

# Configure and install PostgreSQL
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql

# Install PHP extensions
RUN docker-php-ext-install -j$(nproc) \
    bcmath \
    exif \
    gd \
    gettext \
    gmp \
    intl \
    ldap \
    mbstring \
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    sockets \
    zip

# Configure PHP
RUN echo 'memory_limit=2G' > /usr/local/etc/php/conf.d/memory-limit.ini

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create user and set up home directory
RUN useradd -G www-data,root -u $uid -d /home/$user $user && \
    mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

USER ${user}

# Install NVM and Node.js
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc && \
    . $HOME/.nvm/nvm.sh && \
    nvm install ${NODE_VERSION} && \
    nvm alias default ${NODE_VERSION}

ENV PATH="/home/${user}/.nvm/versions/node/v${NODE_VERSION}/bin:${PATH}"

WORKDIR /var/www/app

USER root

# Set up NVM wrapper script
RUN echo '#!/bin/bash' > /usr/local/bin/nvm && \
    echo 'export NVM_DIR="/home/'${user}'/.nvm"' >> /usr/local/bin/nvm && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /usr/local/bin/nvm && \
    echo 'nvm "$@"' >> /usr/local/bin/nvm && \
    chmod +x /usr/local/bin/nvm

USER ${user}