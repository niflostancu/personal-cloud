# Docker-based Personal Cloud / NAS images

Contains several extensible images for providing personal cloud services:

- MySQL database (for services that depend on it);
- Nginx frontend (reverse proxy for other services);
- TinyTinyRSS (web-based RSS reader);
- Seafile (file synchronization application);

## Requirements

- [Docker](https://www.docker.com/) >= 1.13
- [Docker Compose](https://docs.docker.com/compose/install/) >= 1.10.0

## Available Containers

In order to initialize and configure the desired containers, please read through their separate
documentation pages:

- [Frontend](docs/Frontend.md)
- [MySQL](docs/MySQL.md)
- [TinyTinyRSS](docs/TinyTinyRSS.md)
- [Seafile](docs/Seafile.md)


## Installation and usage

You can use the images by creating a compose file and declaring the services you
need, e.g.:

1. Copy the sample [docker-compose.yml](docker-compose.example.yml) file and
   edit it to fit your needs.

2. Initialize the services:

  Some services need to be initialized before running them.

  You need to do this in topological order of their dependencies, e.g. if you
  want to use a container that depends on MySQL, you must first initialize the
  MySQL container.

  Please check the documentation for the services you want to use!

3. Test and deploy!

  After you successfully initialized and tested each container individually,
  the final step is to run them all and enjoy:

  ```bash
  docker-compose up
  ```

  Optionally, create an init script for automatically starting the containers
  at boot time. Check the *distrib/* directory for script examples.

## Building your own images

If you want to build your own images, just use the supplied Makefile:

```bash
make IMAGE_PREFIX=your-prefix/ NO_CACHE=1 all
make push  # push them to docker hub (if you need)
```

Don't forget to change the docker-compose file image prefixes if you decided to
change it!

