FROM alpine:3.23.3

ENV COMPOSER_VERSION=2.9.7

COPY ./fs/docker-entrypoint.sh /usr/sbin/docker-entrypoint.sh

RUN \
    # Upgrade
    apk upgrade --update --no-cache && \
    #
    # Required deps
    apk add --update --no-cache bash git inotify-tools wget curl python3 jq nano less groff py-pip xz aws-cli aws-cli-bash-completion && \
    #
    # Cleanup
    rm -rf /var/cache/apk/*

RUN \
    # PHP 8.4 core + extensions
    apk add --update --no-cache \
        php84 php84-fpm php84-opcache php84-mbstring \
        php84-session php84-soap php84-openssl php84-gmp php84-pdo_odbc php84-dom php84-pdo php84-zip \
        php84-mysqli php84-sqlite3 php84-pdo_pgsql php84-bcmath php84-gd php84-odbc php84-pdo_mysql php84-pdo_sqlite \
        php84-gettext php84-xmlreader php84-xmlwriter php84-xml php84-simplexml php84-bz2 php84-iconv php84-xsl php84-sodium \
        php84-pdo_dblib php84-curl php84-ctype php84-pcntl php84-posix php84-phar \
        php84-fileinfo php84-tokenizer php84-sockets php84-intl php84-ldap php84-phpdbg && \
    #
    # PHP 8.4 PECL extensions
    apk add --update --no-cache php84-pecl-xdebug php84-pecl-igbinary php84-pecl-memcached && \
    #
    # Database clients
    apk add --update --no-cache postgresql-client mariadb-connector-c && \
    #
    # Media tools
    apk add --update --no-cache exiftool mediainfo && \
    #
    # Cleanup
    rm -rf /var/cache/apk/* && \
    #
    # Symlinks not created automatically by php84 packages
    rm -f /usr/bin/phar /usr/bin/phar.phar && \
    ln -s /usr/bin/phar84.phar /usr/bin/phar && \
    ln -s /usr/bin/phar84.phar /usr/bin/phar.phar && \
    ln -s /usr/sbin/php-fpm84 /usr/sbin/php-fpm && \
    ln -s /etc/php84 /etc/php && \
    #
    # Composer 2.x
    curl -sS https://getcomposer.org/installer | php84 -- --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} && \
    #
    # Make scripts executable
    chmod +x /usr/sbin/docker-entrypoint.sh

COPY fs/ /

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 9000

WORKDIR /app