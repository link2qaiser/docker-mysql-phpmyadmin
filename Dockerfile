# Used for prod build.
FROM mysql:8.0 as mysql

# Install dependencies.
RUN apt-get update && apt-get install -y unzip libpq-dev libcurl4-gnutls-dev nginx libonig-dev

