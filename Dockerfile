# 1. Gunakan PHP 7.3 CLI karena Laravel 5.3 butuh versi PHP lama
FROM php:7.3-cli

# 2. Install dependencies sistem & PostgreSQL
# Ditambahkan --fix-missing untuk mengatasi masalah koneksi saat build
RUN apt-get update && apt-get install -y --fix-missing \
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

# 3. Pengaturan Composer agar bisa jalan sebagai root di Docker
ENV COMPOSER_ALLOW_SUPERUSER 1

# 4. Install Composer Versi 1 (Wajib untuk Laravel lama agar tidak bentrok)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --1

# 5. Set Working Directory
WORKDIR /app

# 6. Copy seluruh project
COPY . .

# 7. Jalankan Composer Install
# --ignore-platform-reqs digunakan agar tidak error jika ada ketidakcocokan versi minor PHP
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# 8. Set Permissions untuk Laravel
RUN chmod -R 775 storage bootstrap/cache public

# 9. Railway menggunakan port dinamis, namun kita ekspos 8080 sebagai standar
EXPOSE 8080

# 10. Jalankan server dengan server.php sebagai entry point
# Ini membantu menangani file statis (CSS/JS) di folder public tanpa Apache
CMD ["php", "-S", "0.0.0.0:8080", "server.php"]