FROM php:7.3-apache

# 1. Install dependencies
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

# 2. FIX: Delete all MPM configs and force prefork only
RUN echo 'Mutex posixsem' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule mpm_prefork_module modules/mod_mpm_prefork.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule authn_file_module modules/mod_authn_file.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule authn_core_module modules/mod_authn_core.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule authz_host_module modules/mod_authz_host.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule authz_groupfile_module modules/mod_authz_groupfile.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule authz_user_module modules/mod_authz_user.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule authz_core_module modules/mod_authz_core.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule access_compat_module modules/mod_access_compat.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule auth_basic_module modules/mod_auth_basic.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule reqtimeout_module modules/mod_reqtimeout.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule filter_module modules/mod_filter.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule mime_module modules/mod_mime.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule log_config_module modules/mod_log_config.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule env_module modules/mod_env.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule headers_module modules/mod_headers.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule setenvif_module modules/mod_setenvif.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule version_module modules/mod_version.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule unixd_module modules/mod_unixd.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule status_module modules/mod_status.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule autoindex_module modules/mod_autoindex.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule dir_module modules/mod_dir.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule alias_module modules/mod_alias.so' >> /etc/apache2/apache2.conf && \
    echo 'LoadModule rewrite_module modules/mod_rewrite.so' >> /etc/apache2/apache2.conf && \
    rm -f /etc/apache2/mods-enabled/*.load /etc/apache2/mods-enabled/*.conf

# 3. Set DocumentRoot
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# 4. Copy project
WORKDIR /var/www/html
COPY . .

# 5. Set permissions
RUN mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 80

CMD ["apache2-foreground"]