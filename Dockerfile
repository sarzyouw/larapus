# ===============================
# Base Image
# ===============================
FROM php:7.3-apache

# ===============================
# System Dependencies
# ===============================
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libpq-dev \
    unzip \
    git \
    && docker-php-ext-install \
    pdo \
    pdo_pgsql \
    gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ===============================
# Apache Configuration
# ===============================

# Enable Apache modules
RUN a2enmod rewrite mime headers

# Ensure mime types loaded (FIX CSS TEXT ISSUE)
RUN echo "Include /etc/apache2/mime.types" >> /etc/apache2/apache2.conf

# Set Apache DocumentRoot to Laravel /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri \
    -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf

# ===============================
# PHP Configuration
# ===============================
RUN echo "upload_max_filesize=50M" > /usr/local/etc/php/conf.d/uploads.ini \
 && echo "post_max_size=50M" >> /usr/local/etc/php/conf.d/uploads.ini

# ===============================
# App Source
# ===============================
WORKDIR /var/www/html
COPY . .

# ===============================
# Permissions
# ===============================
RUN chown -R www-data:www-data \
    storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# ===============================
# Composer
# ===============================
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction

# ===============================
# Laravel Optimization
# ===============================
RUN php artisan key:generate || true \
 && php artisan config:clear \
 && php artisan route:clear \
 && php artisan view:clear

# ===============================
# Expose Port
# ===============================
EXPOSE 80

# ===============================
# Start Apache
# ===============================
CMD ["apache2-foreground"]
