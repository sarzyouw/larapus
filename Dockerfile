FROM php:7.3-apache

# 1. Install dependencies sistem & PHP Extensions
# Ditambahkan libzip-dev agar extension zip bisa terinstall sempurna
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

# 2. FIX: Atasi error "More than one MPM loaded"
# Kita matikan mpm_event dan paksa pakai mpm_prefork (standar PHP)
RUN a2dismod mpm_event || true && a2enmod mpm_prefork rewrite

# 3. Set DocumentRoot ke folder /public (Wajib untuk Laravel)
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# 4. Copy seluruh project ke dalam container
WORKDIR /var/www/html
COPY . .

# 5. Permission & Struktur Folder
# Railway butuh folder storage lengkap agar Laravel tidak crash saat nulis log/session
RUN mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# 6. Railway mendeteksi port secara otomatis dari EXPOSE
EXPOSE 80

CMD ["apache2-foreground"]