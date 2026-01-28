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

# ... (bagian atas tetap sama)

WORKDIR /app
COPY . .

# 1. Pastikan Composer install sudah selesai
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# 2. Paksa izin akses folder public agar bisa dibaca server (PENTING)
RUN chmod -R 755 /app/public

EXPOSE 8080


# 3. Gunakan server.php sebagai gerbang utama
# Jalankan server dengan flag -t agar folder 'public' dianggap sebagai root aset
CMD ["php", "-S", "0.0.0.0:8080", "-t", "public", "server.php"]