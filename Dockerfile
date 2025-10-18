FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y certbot openssh-client openssl curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
