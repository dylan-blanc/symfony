FROM php:8.3-fpm AS app

WORKDIR /var/www/html

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        unzip \
        libicu-dev \
        libzip-dev \
    && docker-php-ext-install \
        intl \
        opcache \
        pdo_mysql \
        zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

COPY composer.json composer.lock symfony.lock ./
RUN composer install --no-dev --prefer-dist --no-scripts --no-progress --no-interaction

COPY . .

RUN composer dump-autoload --classmap-authoritative --no-dev \
    && mkdir -p var/cache var/log \
    && chown -R www-data:www-data var

FROM nginx:stable AS webserver

WORKDIR /var/www/html

COPY --from=app /var/www/html/public ./public
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
