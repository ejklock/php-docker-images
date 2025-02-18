FROM php:7.0-fpm

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

# Install system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    libldap2-dev \
    libxml2-dev \
    unzip \
    libfreetype6-dev \
    libwebp-dev \
    libjpeg62-turbo-dev \
    libgmp-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install and configure PHP extensions
RUN pecl install xdebug-2.7.2 && \
    docker-php-ext-enable xdebug

# Configure GD and LDAP
RUN if [ "$(uname -m)" = "aarch64" ]; then \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-webp-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-configure ldap --with-libdir=lib/aarch64-linux-gnu/; \
    else \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-webp-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/; \
    fi

# Install PHP extensions
RUN docker-php-ext-install \
    gettext \
    zip \
    pdo_mysql \
    mbstring \
    intl \
    exif \
    pcntl \
    bcmath \
    gd \
    gmp \
    ldap \
    opcache \
    sockets

# Set PHP memory limit
RUN echo 'memory_limit=2G' > /usr/local/etc/php/conf.d/memory-limit.ini

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create user and set permissions
RUN useradd -G www-data,root -u $uid -d /home/$user $user && \
    mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

WORKDIR /var/www/app

USER ${user}