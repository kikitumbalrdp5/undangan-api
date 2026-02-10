FROM php:8.2-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    libpq-dev \
    libzip-dev \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo pdo_pgsql pgsql zip

# Copy project
WORKDIR /var/www
COPY . .

# Install composer
RUN curl -sS https://getcomposer.org/installer | php \
    -- --install-dir=/usr/local/bin --filename=composer

RUN composer install --no-dev --optimize-autoloader --no-interaction

# Copy nginx config
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Fix permission
RUN chown -R www-data:www-data /var/www

EXPOSE 8000

CMD service nginx start && php-fpm
