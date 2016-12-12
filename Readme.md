# Docker-based Personal Cloud / NAS images

Contains several extensible images for providing personal cloud services:

- MySQL database (for services that depend on it);
- Nginx frontend (reverse proxy for other services);
- TinyTinyRSS (web-based RSS reader);
- Seafile (file synchronization application) - TODO;

## Requirements

- [Docker](https://www.docker.com/) >= 1.10
- [Docker Compose](https://docs.docker.com/compose/install/) >= 1.8.0
- [Docker Local Persist Volume Plugin](https://github.com/CWSpear/local-persist)

## Installation

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
docker-compose run mysql mysql-init.sh
# TinyTinyRSS installation
docker-compose run -u www-data ttrss bash
> ttrss-update-git.sh
> cd /var/www/rss/
> cp config.php-dist config.php
> vim config.php  # enter database credentials (user/db created automatically)
> # and other config parameters
> DB_SU_PASS=<mysql root password> ttrss-install-db.php
```

4. Test and deploy!

```
docker-compose up
```

Optionally, create an init script for automatically starting the containers at boot time.


