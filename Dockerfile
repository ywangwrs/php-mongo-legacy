FROM php:5.6.40-apache

COPY sources.list /etc/apt/

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    libssl-dev \
    wget \
    vim \
    ffmpeg \
    mutt gpgsm gnupg-agent \
    && DEBIAN_FRONTEND=noninteractive apt-get --yes --assume-yes install cyrus-common \
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

# Python3.9, google-api-python-client and pyshorteners
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    build-essential libreadline-gplv2-dev libncursesw5-dev \
    libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev \
    && apt-get clean \
    && wget --progress dot:giga https://www.python.org/ftp/python/3.9.16/Python-3.9.16.tgz \
    && tar xzf Python-3.9.16.tgz \
    && cd Python-3.9.16 \
    && ./configure --enable-optimizations \
    && make altinstall \
    && cd .. && rm -rf Python-3.9.16* \
    && apt-get purge --yes build-essential \
    && apt-get --yes autoremove \
    && pip3.9 install --upgrade google-api-python-client \
    && python3.9 -m pip install --upgrade pip \
    && pip3.9 install --upgrade pyshorteners

# youtube-dl
ADD yt-dlp /usr/bin/youtube-dl

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
