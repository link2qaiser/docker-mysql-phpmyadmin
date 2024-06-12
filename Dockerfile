# Used for prod build.
FROM mysql:8.0-debian

COPY ./docker/mysql/my.cnf /etc/mysql/my.cnf
# Install dependencies.
RUN apt-get update

