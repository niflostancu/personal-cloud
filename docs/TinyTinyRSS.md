# TinyTinyRSS Container

[TinyTinyRSS](https://tt-rss.org) is a open-source, self-hosted, web-based news feed reader.

## Usage

Add the following to your *docker-compose.yml* file:

```yaml
services:
  ttrss:
    build: images/ttrss-nginx/
    volumes:
      - ttrss:/var/www/
    links:
      - mysql
```

Note that it depends on the [MySQL container](MySQL.md), so make sure to include it too.

It also requires a persistent volume for storing the *.php* files and its configuration:
```yaml
volumes:
  ttrss:
    driver: local-persist
    driver_opts: { mountpoint: /var/nas-data/ttrss }
```

You will also probably want to reverse-proxy it using the [Frontend container](Frontend.md).
Don't forget to activate the *ttrss* snippet and add it as link dependency:

```yaml
services:
  frontend:
    links:
     - ttrss
    environment:
     - "DEFAULT_SNIPPETS=... ttrss"
```

## Initialization

TinyTinyRSS needs to be installed (it also needs its database initialized, a MySQL account configured
etc.). For this, follow the steps:

1. Run it for the first time:

```bash
docker-compose run -p 80 ttrss
```

It should display a message that you need to go to an URL to complete the installation.

2. Access the URL and install it.

You may need to manually create MariaDB database and user.

For this, open a bash session on your mysql container:

```bash
docker-compose run mysql bash
```

Inside the shell, run the mysql client and create the required database:

```bash
mysql -u root -p
# enter your password
MariaDB> CREATE DATABASE ttrss CHARSET 'UTF8';
```

## Customization

Since TinyTinyRSS is installed persistenly inside a volume, you can freely edit any files in
`/var/www` (e.g. install plugins / themes).

You may also want to periodically upgrade the installation.
The official way to do this is by using git:
```bash
git fetch
git merge origin/master  # or rebase
```

