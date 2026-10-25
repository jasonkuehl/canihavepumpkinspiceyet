# syntax=docker/dockerfile:1
# Serves the static site with nginx. Everything not listed in .dockerignore is published.
#   docker build -t site . && docker run -p 8080:80 site

ARG NGINX_VERSION=1.30

FROM nginx:${NGINX_VERSION}-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY . /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s CMD wget -q -O /dev/null http://127.0.0.1/healthz || exit 1
