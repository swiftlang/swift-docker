# docker-swift

![swift](https://raw.githubusercontent.com/hamin/EventSource.Swift/master/swift-logo.png)


### An Ubuntu 14.04 Docker image for [Swift](https://swift.forg). 

#### You can find the Docker Hub repo here: [https://hub.docker.com/r/harisamin/docker-swift/](https://hub.docker.com/r/harisamin/docker-swift/)


### Docker Instructions

You can open a connection to your faye server.

##### Pull the Docker Image From Docker Hub:

```bash
docker pull harisamin/docker-swift
```

##### Create a container from the Image and attach it:

```bash
docker run -i -t --name swiftfun harisamin/docker-swift:latest /bin/bash
```

##### To start your and attach your image later:

Start your image with name `swiftfun`

```bash
docker start swiftfun
```

and then attach it

```bash
docker start swiftfun
```


## Contributions

Contributions via pull requests are welcome and encouraged :)

## License

docker-swift is licensed under the MIT License.

Copyright (C) 2015 by Haris Amin

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
