################################################################################
# Base image
################################################################################

FROM php:7.1-fpm

################################################################################
# Build instructions
################################################################################
COPY conf/apt.conf /etc/apt/apt.conf.d/

# Arguments
ARG http_proxy
ARG https_proxy

# Remove default nginx configs.
RUN rm -f /etc/nginx/conf.d/*

# Install PHP packages
RUN apt-get update && apt-get install -my \
        wget \
        gnupg2 \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libmemcached-dev \
        libxml2-dev \
        libxslt-dev \
        zlib1g-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt mbstring pdo_mysql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include \
    && docker-php-ext-configure xml --with-libxml-dir=/usr/include \
    && docker-php-ext-install -j$(nproc) gd xml xsl zip pcntl

RUN pear config-set http_proxy ${http_proxy}

RUN pecl install redis \
    && pecl install xdebug \
    && pecl install memcached \
    && docker-php-ext-enable redis xdebug memcached

################################################################################
# Volumes
################################################################################

# VOLUME []

################################################################################
# Ports
################################################################################

# EXPOSE 80 443

################################################################################
# Entrypoint
################################################################################

# ENTRYPOINT ["/usr/bin/supervisord"]
