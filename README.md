Boogaloo Docker Image
=====================

This repository contains the ``DockerFile`` and other associated
files for building [Boogaloo](https://bitbucket.org/nadiapolikarpova/boogaloo/wiki/Home)
inside a container.


Building
--------

```
$ docker build -t "boogaloo" .
```

Alternatively you can obtain the pre-built image from the [Docker Hub](https://registry.hub.docker.com/u/delcypher/boogaloo-docker/)
by running

```
$ docker pull delcypher/boogaloo-docker
```

Running
-------

This will create a new temporary container (``--rm``) using the
image and give you shell access to it.

```
$ docker run -ti --rm boogaloo /bin/bash
```

The boogaloo tool is available in PATH in the container.
