FROM php:7.3-apache

# Install system deps
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libpq-dev \
    unzip \
    git \
    mime-support \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_pgsql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable required apache modules ONLY
RUN a2enmod rewrite headers mime

# Copy Laravel
WORKDIR /var/www/html
COPY . .

# Apache vhost (SAFE WAY)
RUN printf '%s\n' \
'<VirtualHost *:80>' \
'  DocumentRoot /var/www/html/public' \
'  <Directory /var/www/html/public>' \
'    AllowOverride All' \
'    Require all granted' \
'  </Directory>' \
'</VirtualHost>' \
> /etc/apache2/sites-available/000-default.conf

# Permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

EXPOSE 8080
CMD ["apache2-foreground"]
