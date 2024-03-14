FROM php:8.2-alpine

# Install system dependencies
RUN apk update && \
    apk add --no-cache \
    bash \
    curl \
    freetype-dev \
    g++ \
    gcc \
    git \
    libc-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libtool \
    libxml2-dev \
    libzip-dev \
    linux-headers \
    make \
    mysql-client \
    nodejs \
    npm \
    openssh-client \
    postgresql-dev \
    postgresql-libs \
    rsync \
    sqlite-dev \
    zlib-dev \
    autoconf \
    curl-dev \
    $PHPIZE_DEPS

# Install libcurl package
RUN apk add --no-cache libcurl

# Download and install Xdebug manually
RUN pecl download xdebug && \
    tar -xf xdebug-*.tgz && \
    cd xdebug-* && \
    phpize && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf xdebug* && \
    docker-php-ext-enable xdebug

# Configure Xdebug
RUN echo "xdebug.mode=coverage" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Install PHP extensions
RUN docker-php-ext-install \
    bcmath \
    calendar \
    exif \
    gd \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pdo_sqlite \
    pcntl \
    xml \
    zip

# Install Composer
ENV COMPOSER_HOME /composer
ENV PATH ./vendor/bin:/composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

# Install PHPCS
RUN composer global require "squizlabs/php_codesniffer=*"

# Install openssh and set root password
RUN apk add --no-cache openssh \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && echo "root:root" | chpasswd

# Set PHP memory limit
RUN echo 'memory_limit = 1024M' >> /usr/local/etc/php/conf.d/docker-php-ext-memlimit.ini

# Install sshpass
RUN apk add --no-cache sshpass

# Set working directory
WORKDIR /var/www/html
