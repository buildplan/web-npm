# Dockerfile for the generic-nginx image

# Stage 1: The "builder" stage to get Nginx files
FROM nginx:1.29-alpine-slim AS builder


# Stage 2: The final, distroless image
FROM gcr.io/distroless/static-debian12

# Create a non-root user (e.g., uid/gid 101)
USER 0
RUN groupadd --system --gid=101 nginx && \
    useradd --system --uid=101 --gid=nginx nginx
USER nginx

# Copy the Nginx binary and configurations from the builder stage
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx

# Create necessary directories as root, then switch back to non-root user
USER 0
RUN mkdir -p /var/cache/nginx /usr/share/nginx/html && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/cache/nginx /var/run/nginx.pid /var/log /usr/share/nginx/html
USER nginx

EXPOSE 80
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
