# Nginx version
ARG NGINX_VERSION=1.29-alpine-slim

# Stage 1: The "builder" stage
FROM nginx:${NGINX_VERSION} AS builder

RUN mkdir -p /var/cache/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/cache/nginx /var/run/nginx.pid /var/log


# Stage 2: distroless image
FROM gcr.io/distroless/static-debian12

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /var/cache/nginx /var/cache/nginx
COPY --from=builder /var/run /var/run
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/share/nginx/html /usr/share/nginx/html

USER nginx

EXPOSE 80
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
