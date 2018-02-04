# Phabricator Container

[Phabricator](https://www.phacility.com/) is a open, self-hosted software
development web application for project / task management, VCS repositories,
code review etc.

## Usage

Add the following to your *docker-compose.yml* file:

```yaml
services:
  phabricator:
    image: nicloud/phabricator:latest
    volumes:
      - phabricator-conf:/srv/phabricator/conf/
      - phabricator-repo:/var/repo/
    ports: # remove if you want to use a Frontend container
     - "8000:80"
    links:
      - mysql
```

Note that it depends on the [MySQL service](MySQL.md), so make sure to configure
it too.

You will probably want to reverse-proxy it using the [Frontend
container](Frontend.md).

Note that Phabricator doesn't support using non-root web paths, so you'll need
to dedicate an entire domain / subdomain.

## Initialization

For the first time, just run the Phabricator instance using an interactive
terminal:

```bash
docker-compose run --service-ports phabricator
```

The initialization script will start and ask for some configuration options
(like MySQL credentials).

After the database is successfully configured, you can then test it right away,
by going to _localhost.localdomain:8000_ (NOTE: you need to have a dot inside
your domain name; if you don't own a domain, you can map one e.g.
localhost.localdomain inside your _/etc/hosts_).

## Customization

For further customization, you can inherit the container and modify it to your
needs.

## Administration

To administer the container, make sure to run all tools as the _phabricator_
user:

```bash
docker-compose exec -u phabricator phabricator bash
```

