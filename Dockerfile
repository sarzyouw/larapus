FROM php:7.3-apache

# ===============================
# 1. Install system dependencies
# ===============================
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libpq-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_pgsql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ===============================
# 2. Apache config
# ===============================
RUN a2enmod rewrite

# Fix MPM conflict (INI PENTING)
RUN a2dismod mpm_event mpm_worker || true \
    && a2enmod mpm_prefork

# ===============================
# 3. Set DocumentRoot ke /public
# ===============================
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri \
    -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf

# ===============================
# 4. Copy project
# ===============================
COPY . /var/www/html
WORKDIR /var/www/html

# ===============================
# 5. Permission Laravel
# ===============================
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# ===============================
# 6. Expose & start
# ===============================
EXPOSE 80
CMD ["apache2-foreground"]
