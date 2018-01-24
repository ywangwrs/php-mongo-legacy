#FROM php:5-apache
FROM php:5.6.12-apache

RUN apt-get update && apt-get install --yes --no-install-recommends \
    libssl-dev \
    wget \
    vim \
    php5-mysql

RUN docker-php-ext-install mbstring \
    && docker-php-ext-install mysql

WORKDIR /var/www/html

COPY index.php .

RUN mkdir -p /data/src /data/discuz /data/phpbb /data/share \
    && ln -s /data/src/forum . \
    && ln -s /data/src/ottawa . \
    && ln -s /data/discuz . \
    && ln -s /data/share . \
    && ln -s /data/phpbb .

RUN wget https://pecl.php.net/get/mongo-1.6.11.tgz \
    && tar xzf mongo-1.6.11.tgz \
    && cd mongo-1.6.11 \
    && phpize \
    && ./configure \
    && make \
    && make install \
    #&& echo "extension=mongo.so" > /usr/local/etc/php/php.ini \
    && docker-php-ext-enable mongo
