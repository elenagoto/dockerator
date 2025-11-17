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

# Install Node.js and npm (Debian-based)
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Expose port
EXPOSE 80

# Start FrankenPHP
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]