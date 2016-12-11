= Docker-based Personal Cloud / NAS images

Contains several extensible images for providing personal cloud services:

- MySQL database (for services that depend on it);
- Nginx frontend (reverse proxy for other services);
- TinyTinyRSS + nginx image;
- Seafile (file synchronization application) - TODO;

=== Requirements ===

- Docker >= 1.10
- Docker Compose >= 1.8.0
- Docker Local Persist Volume Plugin

=== Installation ===

1. Clone the docker-compose file and edit it to fit your needs:
```
cp docker-compose.example.yml docker-compose.yml
vim docker-compose.yml
```

2. Build the docker images:
```
docker-compose build
```

3. Initialize the services:

```
# MySQL data directory:
docker-compose run mysql /opt/container/scripts/init.sh
# TinyTinyRSS installation
docker-compose run ttrss bash
> cd /var/www/rss/ && cp config.php-dist config.php
> vim config.php  # enter database credentials and other config parameters
> ttrss-update-git.sh
> docker-compose run -e DB_SU_PASS=<password> ttrss ttrss-install-db.php
```


