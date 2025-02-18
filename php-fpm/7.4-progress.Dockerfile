FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
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
    unixodbc \
    unixodbc-dev \
    unzip \
    xterm && \
    rm -rf /var/lib/apt/lists/*

# Install PECL extensions
RUN pecl install imagick-3.4.4 && \
    docker-php-ext-enable imagick

# Configure and compile GD
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    cd /usr/src/php/ext/gd && make && \
    cp /usr/src/php/ext/gd/modules/gd.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/gd.so

# Configure PostgreSQL
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
    obdc \
    opcache \
    pcntl \
    pdo_mysql \
    pdo_obdc \
    pdo_pgsql \
    pgsql \
    sockets \
    zip

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