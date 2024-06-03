# Dockerfile-based build for Swift Static Linux SDK

## What is this?

This is a Dockerfile-based build set-up for the Swift Static Linux SDK.

To use it, you need to build the Docker image with

```shell
$ docker build -t static-swift-linux .
```

then you can check-out the sources somewhere using

```shell
$ scripts/fetch-source.sh --clone-with-ssh --source-dir /path/to/source
```

and finally use the Docker image to do your build

```shell
$ mkdir /path/to/products
$ docker run -it --rm  \
             -v /path/to/source:/source \
             -v /path/to/products:/products \
             static-swift-linux \
             /scripts/build.sh --source-dir /source --products-dir /products
```

The artifact bundle should appear at `/path/to/products`.

The `scripts/build.sh` script has a number of options you may wish to
investigate.  Similarly with the `scripts/fetch-source.sh` script.
