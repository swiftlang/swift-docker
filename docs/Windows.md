
## Installing and configuring docker

### Prerequisites

1. Open the Windows Features panel (search for `Turn Windows features on or off`) and enable the `Containers`. Reboot if needed. 

### Install Docker and associated extensions

1. Download the latest docker engine binaries from [Install Docker Engine from binaries | Docker Documentation](https://docs.docker.com/engine/install/binaries/#install-server-and-client-binaries-on-windows) and extract them into `%ProgramFiles%\Docker`

    > **NOTE**: The install directory _must_ be `%ProgramFiles%\Docker` as CLI plugins require that location.

1. Install Docker Compose v2 by downloading the latest docker compose binaries from [Docker Compose Releases](https://github.com/docker/compose/releases) and renaming the `docker-compose-windows-x86_64.exe` to `docker-compose.exe` in `%ProgramFiles%\Docker\cli-plugins`

1. From the start menu, search for and open `Edit the system environment variables` and click the `Environment variables...` button, then:

    - Edit the `Path` environment variable (user or system) and add an entry for `%ProgramFiles%\Docker`
    - Add a variable (user or system) with the name `DOCKER_HOST` and the value `tcp://127.0.0.1:2375`

1. Open a Command Prompt as Administrator and execute the following:

    ~~~cmd
    cd %ProgramFiles%\Docker
    rem Register the Docker Service
    .\dockerd --register-service
    rem Create %ProgramData%\docker
    net start docker
    net stop docker
    ~~~

### Configure Docker

1. Create `%ProgramData%\docker\config\daemon.json` with this content (you might have to create the `config` directory):

    ```json
    {
      "features": {
        "buildkit": false
      },
      "hosts": [
        "tcp://127.0.0.1:2375",
        "npipe://"
      ],
      "tls": false
    }
    ```

1. Optionally, you can add the following key value pair to the configuration to place all the docker storage into the S drive:

    ```json
    {
      "data-root": "S:\\ProgramData\\docker",
    }
    ```

### Start Docker

1. Open a Command Prompt as Administrator and execute the following:

    ~~~cmd
    net start docker
    ~~~

### Verify Installation

1. Verify that docker is running by executing:

    ~~~cmd
    docker ps
    ~~~
    
    You should see an empty list of containers.

### Using Docker

1. Open a command prompt and execute:

    ~~~cmd
    git clone https://github.com/apple/swift-docker
    rem Select the appropriate version for your kernel
    cd swift-docker\nightly-5.8\windows\10.0.20348.1487
    docker build -m 16G -t swift:nightly .
    ~~~

    You may adjust the 16G to a different value for the memory that you wish to allocate to the container.

    > **NOTE**<br/>
    > This will download ~3GB of data and may take a while.

1. Launch the freshly created container:

    ~~~cmd
    rem replace <local> with the path to the local source directory and <remote> with the path to be mounted in the container.
    docker run --rm -it -v <local>:<remote> swift:nightly
    ~~~
