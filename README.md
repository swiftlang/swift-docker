# swift-docker

<img src="https://swift.org/assets/images/swift.svg" alt="Swift logo" height="70" >

### An Ubuntu 16.04 and Ubuntu 18.04 Docker image for [Swift](https://swift.org).

#### You can find the Docker Hub repo here: [https://hub.docker.com/_/swift/](https://hub.docker.com/_/swift/)


### Usage

##### Pull the Docker image from Docker Hub:

```bash
docker pull swift
```

##### Create a container from the image and run it:

```bash
docker run -it swift /bin/bash
```

If you want to run the Swift REPL you will need to run the container with additional privileges:

```bash
docker run --security-opt seccomp=unconfined -it swift
```

We also provide a "slim" image. Slim images are images designed just for running an already built Swift program. Consequently, they do not contain the Swift compiler.

The normal and slim images can be combined via a multi-stage Dockerfile to produce a lighter-weight image ready for deployment. For example:

```dockerfile
FROM swift:latest as builder
WORKDIR /root
COPY . .
RUN swift build -c release

FROM swift:slim
WORKDIR /root
COPY --from=builder /root .
CMD [".build/x86_64-unknown-linux/release/docker-test"]
```

## Contributions

Contributions via pull requests are welcome and encouraged :)

## License

docker-swift is licensed under the [Apache License, Version 2.0](LICENSE.md).
