# swift-docker

<img src="https://swift.org/assets/images/swift.svg" alt="Swift logo" height="70" >

### An Ubuntu 16.04 and Ubuntu 18.04 Docker image for [Swift](https://swift.org).

#### You can find the Docker Hub repo here: [https://hub.docker.com/_/swift/](https://hub.docker.com/_/swift/)


### Docker Instructions

##### Pull the Docker Image From Docker Hub:

```bash
docker pull swift
```

##### Create a Container from the Image and Attach It:

```bash
docker run --privileged -i -t --name swiftfun swift:latest /bin/bash
```

##### To Start and Attach Your Image Later:

Start your image with name `swiftfun`

```bash
docker start swiftfun
```

and then attach it

```bash
docker attach swiftfun
```


## Contributions

Contributions via pull requests are welcome and encouraged :)

## License

docker-swift is licensed under the [Apache License, Version 2.0](LICENSE.md).
