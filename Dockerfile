FROM php:7.3-apache

# 1. Install dependencies & PHP Extensions
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libpq-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd pdo pdo_pgsql pdo_mysql zip

# 2. Fix Apache MPM Error & Enable Rewrite
# Kita pastikan hanya mpm_prefork yang jalan (standar untuk PHP-Apache)
RUN a2dismod mpm_event || true && a2enmod mpm_prefork rewrite

# 3. Set DocumentRoot ke /public (Sangat Penting untuk Laravel)
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# 4. Copy Project
WORKDIR /var/www/html
COPY . .

# 5. Permissions & Optimization
# Kita buat folder storage/cache kalau belum ada agar tidak error chmod
RUN mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Railway menggunakan variable PORT secara dinamis
# Kita biarkan Apache mengikuti port default Railway (80 atau sesuai variable PORT)
EXPOSE 8080

CMD ["apache2-foreground"]