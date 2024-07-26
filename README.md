# swift-docker

<img src="https://swift.org/assets/images/swift.svg" alt="Swift logo" height="70" >

### Docker images for [Swift](https://swift.org).

#### You can find the Docker Hub repo here: [https://hub.docker.com/_/swift/](https://hub.docker.com/_/swift/)

#### Nightly image tags are published here: [https://hub.docker.com/r/swiftlang/swift](https://hub.docker.com/r/swiftlang/swift)


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
# If running Docker on Linux:
docker run --security-opt seccomp=unconfined -it swift

# If running Docker on macOS:
docker run --privileged -it swift
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
CMD [".build/release/docker-test"]
```

## Contributing 
Welcome to the Swift community!

Contributions to swift-docker are welcomed and encouraged! Please see the [Contributing to Swift guide](swift.org/contributing) and check out the [structure of the community](https://www.swift.org/community/#community-structure).

To be a truly great community, Swift needs to welcome developers from all walks of life, with different backgrounds, and with a wide range of experience. A diverse and friendly community will have more great ideas, more unique perspectives, and produce more great code. We will work diligently to make the Swift community welcoming to everyone.

To give clarity of what is expected of our members, Swift has adopted the code of conduct defined by the Contributor Covenant. This document is used across many open source communities, and we think it articulates our values well. For more, see the [Code of Conduct](https://www.swift.org/code-of-conduct/).

## License

swift-docker is licensed under the [Apache License, Version 2.0](LICENSE.md).
