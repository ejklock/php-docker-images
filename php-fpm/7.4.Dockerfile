FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

# Install system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    libpq-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    libldap2-dev \
    libxml2-dev \
    unzip \
    libwebp-dev \
    libgmp-dev \
    libfreetype6-dev \
    libmagickwand-dev \
    libjpeg62-turbo-dev \
    g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN pecl install imagick xdebug-3.1.5 redis && \
    docker-php-ext-enable imagick xdebug redis

# Configure and install GD
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install -j$(nproc) gd

# Configure and install PostgreSQL
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && \
    docker-php-ext-install pgsql pdo_pgsql

# Install remaining PHP extensions
RUN docker-php-ext-install -j$(nproc) \
    gettext \
    zip \
    pdo_mysql \
    mbstring \
    intl \
    exif \
    pcntl \
    bcmath \
    gmp \
    mysqli \
    ldap \
    opcache \
    sockets

# Set PHP memory limit
RUN echo 'memory_limit=2G' > /usr/local/etc/php/conf.d/memory-limit.ini

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create user
RUN useradd -G www-data,root -u $uid -d /home/$user $user && \
    mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

WORKDIR /var/www/app

USER ${user}