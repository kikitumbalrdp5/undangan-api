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

# Install MongoDB extension
RUN pecl install mongodb \
    && docker-php-ext-enable mongodb

# Set working directory
WORKDIR /var/www

# Copy project
COPY . .

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    -- --install-dir=/usr/local/bin --filename=composer

RUN composer install --no-dev --optimize-autoloader --no-interaction

# Remove default nginx config
RUN rm /etc/nginx/sites-enabled/default || true

# Copy nginx config
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Set permission
RUN chown -R www-data:www-data /var/www

EXPOSE 8000

CMD php-fpm -D && nginx -g "daemon off;"
