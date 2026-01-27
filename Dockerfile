FROM php:7.3-apache

# ===============================
# System dependencies
# ===============================
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libpq-dev \
    unzip \
    git \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
    && docker-php-ext-install \
        pdo \
        pdo_pgsql \
        gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ===============================
# Apache modules
# ===============================
RUN a2enmod rewrite headers mime

# ===============================
# Set DocumentRoot to /public
# ===============================
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri \
    -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf

# ===============================
# Workdir & source
# ===============================
WORKDIR /var/www/html
COPY . .

# ===============================
# Permissions (Laravel)
# ===============================
RUN chown -R www-data:www-data storage bootstrap/cache \
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
# Laravel optimize
# ===============================
RUN php artisan config:clear \
 && php artisan route:clear \
 && php artisan view:clear

# ===============================
EXPOSE 8080
CMD ["apache2-foreground"]
