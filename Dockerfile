FROM php:7.3-apache

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git

# Enable Apache rewrite
RUN a2enmod rewrite

# Fix MPM conflict (aman walau tidak ada)
RUN a2dismod mpm_event mpm_worker || true
RUN a2enmod mpm_prefork

# Set Apache DocumentRoot ke /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri \
    -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf

# Copy project
COPY . /var/www/html

# Permission
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

EXPOSE 80

CMD ["apache2-foreground"]
