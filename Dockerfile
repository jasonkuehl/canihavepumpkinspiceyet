# syntax=docker/dockerfile:1
# Serves the static site with nginx. Everything not listed in .dockerignore is published.
#   docker build -t site . && docker run -p 8080:80 site

ARG NGINX_VERSION=1.30

FROM nginx:${NGINX_VERSION}-alpine
# Base images lag behind Alpine security fixes; apply them so the Trivy scan passes
# hadolint ignore=DL3017
RUN apk upgrade --no-cache
# Run as the unprivileged nginx user. It can still listen on port 80: Docker lets
# containers bind low ports without root (net.ipv4.ip_unprivileged_port_start=0).
RUN sed -i -e '/^user /d' -e 's#^pid .*#pid /tmp/nginx.pid;#' /etc/nginx/nginx.conf \
    && chown -R nginx:nginx /var/cache/nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY . /usr/share/nginx/html
# nginx.conf is part of the build context (copied above as config), not a page to serve
RUN rm -f /usr/share/nginx/html/nginx.conf
USER nginx
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -q -O /dev/null http://127.0.0.1/healthz || exit 1
