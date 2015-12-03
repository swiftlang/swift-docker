# docker-swift

![swift](https://raw.githubusercontent.com/hamin/EventSource.Swift/master/swift-logo.png)


### An Ubuntu 14.04 Docker image for [Swift](https://swift.forg). 

#### You can find the Docker Hub repo here: [https://hub.docker.com/r/harisamin/docker-swift/](https://hub.docker.com/r/harisamin/docker-swift/)


### Docker Instructions

You can open a connection to your faye server.

##### Pull the Docker Image From Docker Hub:

```bash
docker pull swiftdocker/swift
```

##### Create a container from the Image and attach it:

```bash
docker run -i -t --name swiftfun swiftdocker/swift:latest /bin/bash
```

##### To start your and attach your image later:

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

docker-swift is licensed under the [MIT License.](LICENSE.md)
