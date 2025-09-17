# Dockerfile for the generic-nginx image

# Stage 1: The "builder" stage to get Nginx files
FROM nginx:1.29-alpine-slim AS builder

# Set permissions for the directories Nginx needs to write to
RUN mkdir -p /var/cache/nginx && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/cache/nginx /var/run/nginx.pid /var/log

# ---

# Stage 2: The final, secure distroless image
FROM gcr.io/distroless/static-debian12

# Copy the pre-existing user and group definitions from the builder
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Copy the pre-permissioned directories
COPY --from=builder /var/cache/nginx /var/cache/nginx
COPY --from=builder /var/run /var/run

# Copy the Nginx binary and its configurations
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx

# Copy the default webroot directory structure
COPY --from=builder /usr/share/nginx/html /usr/share/nginx/html

# Switch to the non-root user that we copied over
USER nginx

EXPOSE 80
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
