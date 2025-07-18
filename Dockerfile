FROM python:3.9-slim

# Install Nginx and supervisor
RUN apt-get update && \
    apt-get install -y nginx supervisor && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY app/ app/
COPY nginx/f1-racing.conf /etc/nginx/conf.d/default.conf
COPY supervisor/supervisord.conf /etc/supervisor/conf.d/
COPY start.sh .

# Remove default nginx config
RUN rm -f /etc/nginx/sites-enabled/default

# Set permissions
RUN chmod +x start.sh && \
    chown -R www-data:www-data /app && \
    chmod -R 755 /app

EXPOSE 80 5000

# Start supervisor
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
