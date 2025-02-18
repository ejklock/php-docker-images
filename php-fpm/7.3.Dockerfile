FROM php:7.3-fpm

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    autoconf \
    bash \
    curl \
    g++ \
    gettext \
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
    make \
    sudo \
    unzip && \
    rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ \
    --with-webp-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) \
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

# Install PECL extensions
RUN pecl install imagick-3.4.4 && \
    docker-php-ext-enable imagick

# Configure PHP
RUN echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create user and set permissions
RUN useradd -u $uid -m -g www-data -G www-data -s /bin/bash $user && \
    usermod -aG sudo $user && \
    chsh -s /bin/bash $user && \
    mkdir -p /home/$user/.composer && \
    chown -R $uid:$uid /home/$user

WORKDIR /var/www/app

USER ${user}