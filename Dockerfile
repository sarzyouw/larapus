FROM php:7.3-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libpq-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-install pdo pdo_pgsql gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite
RUN a2enmod rewrite

# Fix Apache MPM conflict
RUN a2dismod mpm_event mpm_worker || true
RUN a2enmod mpm_prefork

# Set DocumentRoot ke Laravel public
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri \
    -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf

# Copy project
COPY . /var/www/html

# Permission
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Laravel optimize (INI PENTING)
RUN php artisan key:generate || true \
    && php artisan config:clear \
    && php artisan config:cache \
    && php artisan route:clear

EXPOSE 80
CMD ["apache2-foreground"]
