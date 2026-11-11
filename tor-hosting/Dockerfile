FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    tor nginx php8.2-fpm php8.2-cli ca-certificates curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 1000 container \
    && useradd -u 1000 -g container -d /home/container -s /bin/bash container \
    && mkdir -p /opt/tor-hosting /home/container/public_html /home/container/.tor \
    && chown -R container:container /home/container

COPY start.sh /opt/tor-hosting/start.sh
COPY nginx.conf /opt/tor-hosting/nginx.conf
COPY php-fpm.conf /opt/tor-hosting/php-fpm.conf

RUN chmod 755 /opt/tor-hosting/start.sh

WORKDIR /home/container
EXPOSE 8080
CMD ["bash", "/opt/tor-hosting/start.sh"]
