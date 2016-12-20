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

```bash
# Configure MySQL:
host$ docker-compose run mysql mysql-init.sh
# TinyTinyRSS:
host$ docker-compose run -u www-data ttrss bash
ttrss$ ttrss-update-git.sh
ttrss$ cd /var/www/rss/
ttrss$ cp config.php-dist config.php
# enter database credentials (user/db created automatically)
ttrss$ vim config.php
# and other config parameters
ttrss$ DB_SU_PASS="mysql root password" ttrss-install-db.php
```

4. Test and deploy!

```
docker-compose up
```

Optionally, create an init script for automatically starting the containers at boot time.

## Configuration

To further customize the containers, please see each separate service's documentation page:

- [Frontend](docs/Frontend.md)


