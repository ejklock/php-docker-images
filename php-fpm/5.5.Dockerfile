FROM php:5.5-fpm

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libxml2-dev \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install \
    pdo_mysql \
    mbstring \
    mysqli \
    mysql \
    exif \
    pcntl \
    bcmath

# Set PHP memory limit
RUN echo 'memory_limit=2G' > /usr/local/etc/php/conf.d/memory-limit.ini

# Install composer
COPY --from=composer:1.10 /usr/bin/composer /usr/bin/composer

# Create user and set permissions
RUN useradd -G www-data,root -u $uid -d /home/$user $user && \
    mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

WORKDIR /var/www/app

USER ${user}