#FROM php:5.6.31-apache
FROM php:5.6.40-apache

RUN apt-get -o Acquire::Check-Valid-Until=false update \
    && apt-get install --yes --no-install-recommends \
    libssl-dev \
    wget \
    vim \
    mutt gpgsm gnupg-agent \
    #php5-mysql \
    && apt-get clean

RUN docker-php-ext-install mbstring \
    && docker-php-ext-install mysql

RUN wget https://pecl.php.net/get/mongo-1.6.16.tgz \
    && tar xzf mongo-1.6.16.tgz \
    && cd mongo-1.6.16 \
    && phpize \
    && ./configure \
    && make \
    && make install \
    #&& echo "extension=mongo.so" > /usr/local/etc/php/php.ini \
    && docker-php-ext-enable mongo

COPY phantomjs-2.1.1-linux-x86_64.tar.bz2 /tmp
# install phantomjs
RUN apt-get install --yes --no-install-recommends \
    libfreetype6 \
    libfontconfig1 \
    && apt-get clean \
    && cd /tmp \
    && tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 \
    && mv phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin \
    && rm -rf phantomjs*

RUN mkdir /var/www/.mutt \
    && chmod 777 /var/log
COPY colors /var/www/.mutt/
COPY .muttrc /var/www/
COPY .htaccess /var/www/html/

RUN chown -R www-data:www-data /var/www/.mutt /var/www/.muttrc

WORKDIR /var/www/html

COPY index.php .

RUN mkdir -p /data/src /data/discuz /data/share \
    && ln -s /data/src/forum . \
    && ln -s /data/src/ottawa . \
    && ln -s /data/discuz . \
    && ln -s /data/discuz upload \
    && ln -s /data/share .
