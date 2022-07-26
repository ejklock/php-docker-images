FROM php:5.5-fpm

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

RUN docker-php-ext-install pdo_mysql mbstring mysqli mysql exif pcntl bcmath

RUN echo 'memory_limit=2G' > /usr/local/etc/php/conf.d/memory-limit.ini

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN useradd -G www-data,root -u $uid -d /home/$user $user

RUN mkdir -p /home/$user/.composer && chown -R $user:$user /home/$user

WORKDIR /var/www/app

USER app
