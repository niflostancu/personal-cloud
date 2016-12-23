# Docker-based Personal Cloud / NAS images

Contains several extensible images for providing personal cloud services:

- MySQL database (for services that depend on it);
- Nginx frontend (reverse proxy for other services);
- TinyTinyRSS (web-based RSS reader);
- Seafile (file synchronization application);

## Requirements

- [Docker](https://www.docker.com/) >= 1.10
- [Docker Compose](https://docs.docker.com/compose/install/) >= 1.8.0
- [Docker Local Persist Volume Plugin](https://github.com/CWSpear/local-persist)

## Available Containers

In order to initialize and configure the desired containers, please read through their separate
documentation pages:

- [Frontend](docs/Frontend.md)
- [MySQL](docs/MySQL.md)
- [TinyTinyRSS](docs/TinyTinyRSS.md)
- [Seafile](docs/Seafile.md)

## Installation and Usage

1. Clone the sample docker-compose file and edit it to fit your needs:
```bash
cp docker-compose.example.yml docker-compose.yml
vim docker-compose.yml
```

2. Build the docker images:

```bash
docker-compose build
```

3. Initialize the services:

Some services need to be initialized before running them.

You need to do this in topological order of their dependencies, e.g. if you want to use a container
that uses MySQL, you must first initialize the MySQL container.

Please check their respective documentations.

4. Test and deploy!

After you successfully initialized and tested each container individually, the final step is to
run them all and enjoy:

```bash
docker-compose up
```

Optionally, create an init script for automatically starting the containers at boot time.
Check the *distrib/* directory for script examples.

