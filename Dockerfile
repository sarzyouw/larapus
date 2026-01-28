# Tetap gunakan PHP 7.3 CLI
FROM php:7.3-cli

# Install dependencies sistem
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libpq-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd pdo pdo_pgsql zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer Versi 1 (Penting untuk Laravel 5.3)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --1

WORKDIR /app
COPY . .

# Jalankan composer install
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# Set permissions agar folder storage bisa ditulis
RUN chmod -R 775 storage bootstrap/cache public

# Railway biasanya butuh port 8080 atau 80
EXPOSE 8080

# PERBAIKAN UTAMA: Gunakan server.php sebagai entry point
# server.php di root Laravel berfungsi untuk meniru 'mod_rewrite' Apache
CMD ["php", "-S", "0.0.0.0:8080", "server.php"]