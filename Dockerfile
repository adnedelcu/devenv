################################################################################
# Base image
################################################################################

FROM nginx

################################################################################
# Build instructions
################################################################################
COPY conf/apt.conf /etc/apt/apt.conf.d/

# Arguments
ARG http_proxy
ARG https_proxy

# Remove default nginx configs.
RUN rm -f /etc/nginx/conf.d/*

# Install PHP 7 Repo
RUN apt-get update && apt-get install -my wget gnupg2
RUN sh -c "echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list"
RUN sh -c "echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list"
RUN wget -e use_proxy=yes -e https_proxy="$https_proxy" "https://www.dotdeb.org/dotdeb.gpg" -O - | apt-key add -
RUN wget -e use_proxy=yes -e https_proxy="$https_proxy" "https://nginx.org/keys/nginx_signing.key" -O - | apt-key add -

# Install packages
RUN apt-get update && apt-get install -my \
  supervisor \
  curl \
  php7.0-common \
  php7.0-curl \
  php7.0-fpm \
  php7.0-gd \
  php7.0-memcached \
  php7.0-mysql \
  php7.0-mcrypt \
  php7.0-mbstring \
  php7.0-sqlite \
  php7.0-xdebug \
  php7.0-xml \
  php7.0-xsl

# Ensure that PHP7 FPM is run as root.
RUN sed -i "s/user = www-data/user = root/" /etc/php/7.0/fpm/pool.d/www.conf
RUN sed -i "s/group = www-data/group = root/" /etc/php/7.0/fpm/pool.d/www.conf

# Pass all docker environment
RUN sed -i '/^;clear_env = no/s/^;//' /etc/php/7.0/fpm/pool.d/www.conf

# Get access to FPM-ping page /ping
RUN sed -i '/^;ping\.path/s/^;//' /etc/php/7.0/fpm/pool.d/www.conf
# Get access to FPM_Status page /status
RUN sed -i '/^;pm\.status_path/s/^;//' /etc/php/7.0/fpm/pool.d/www.conf

# Prevent PHP Warning: 'xdebug' already loaded.
# XDebug loaded with the core
RUN sed -i '/.*xdebug.so$/s/^/;/' /etc/php/7.0/mods-available/xdebug.ini

# Install HHVM
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
RUN echo deb http://dl.hhvm.com/debian jessie main | tee /etc/apt/sources.list.d/hhvm.list
RUN apt-get update && apt-get install -y hhvm

# Add configuration files
COPY conf/nginx.conf /etc/nginx/
COPY conf/supervisord.conf /etc/supervisor/conf.d/
COPY conf/php.ini /etc/php/7.0/fpm/conf.d/40-custom.ini
COPY conf/my.cnf /etc/mysql/my.cnf

################################################################################
# Volumes
################################################################################

VOLUME ["/var/www", "/etc/nginx/conf.d"]

################################################################################
# Ports
################################################################################

EXPOSE 80 443

################################################################################
# Entrypoint
################################################################################

ENTRYPOINT ["/usr/bin/supervisord"]
