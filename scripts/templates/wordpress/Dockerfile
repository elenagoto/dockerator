# WordPress with FrankenPHP
FROM dunglas/frankenphp:latest-php8.3

# Install WordPress dependencies
RUN install-php-extensions \
    mysqli \
    pdo_mysql \
    gd \
    zip \
    intl \
    opcache \
    exif \
    imagick

# Set working directory
WORKDIR /app

# Expose port
EXPOSE 80

# Start FrankenPHP
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]