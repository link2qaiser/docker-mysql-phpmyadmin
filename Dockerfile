# Used for prod build.
FROM mysql:8.0-debian

COPY ./docker/mysql/my.cnf /etc/mysql/my.cnf
# Install dependencies.
RUN apt-get update

# Dockerfile for phpMyAdmin
FROM phpmyadmin/phpmyadmin

COPY ./docker/php/php.ini /usr/local/etc/php/conf.d/php.ini