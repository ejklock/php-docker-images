FROM php:7.3-fpm

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

RUN apt-get update && \
    apt-get install -y git curl libpq-dev libpng-dev libonig-dev libzip-dev libldap2-dev libxml2-dev unzip libwebp-dev libpng-dev libgmp-dev libfreetype6-dev libmagickwand-dev libjpeg62-turbo-dev libpng-dev libzip-dev g++ bash gettext autoconf make sudo

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

# Install NVM
ENV NVM_DIR /home/$user/.nvm

# Execute chown directly with uid
RUN mkdir -p $NVM_DIR && chown -R $uid:$uid $NVM_DIR

USER $user

# Install NVM and Node.js
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    . $NVM_DIR/nvm.sh && \
    nvm install 12.22.7 && \
    nvm use 12.22.7 && \
    npm config set unsafe-perm true && \
    echo -e 'export NVM_DIR="$HOME/.nvm"\n[ -s "$NVM_DIR/nvm.sh" ] && \\. "$NVM_DIR/nvm.sh"' >> ~/.bashrc && \
    echo -e '# NVM hook to set unsafe-perm on every version switch\nnvm_hook() {\n  if [ -n "$BASH_COMMAND" ] && [[ "$BASH_COMMAND" =~ ^nvm ]]; then\n    npm config set unsafe-perm true\n  fi\n}\ntrap nvm_hook DEBUG' >> ~/.bashrc

# Update PATH to include NVM and Node.js
ENV PATH=$NVM_DIR/versions/node/v12.22.7/bin:$PATH

USER root

# Create NVM initialization script in /etc/profile.d
RUN echo 'export NVM_DIR="/home/'$user'/.nvm"' >> /etc/profile.d/nvm.sh && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /etc/profile.d/nvm.sh && \
    chmod +x /etc/profile.d/nvm.sh

USER $user

WORKDIR /var/www/app
