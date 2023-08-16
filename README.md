# irsl_system

## Using on browser

### Preparing
- Install docker (linux, windows-wsl) or docker-destkop (windows)
- Download a file for docker compose
  - Linux, Windows-WSL
    - https://github.com/IRSL-tut/irsl_docker_irsl_system/raw/main/files/docker-compose-linux.yaml
  - Linux with GPU(nvidia and using nvidia-docker)
    - https://github.com/IRSL-tut/irsl_docker_irsl_system/raw/main/files/docker-compose-linux-gpu.yaml
  - Windows(Docker-desktop)
    - https://github.com/IRSL-tut/irsl_docker_irsl_system/raw/main/files/docker-compose-win.yaml

### Run

```bash
docker compose -f <downloaded-compose>.yaml [ -p name ] up
```
  - Access Jupyter
    - http://localhost:8888
  - Access Window
    - http://localhost:9999/code.html

- Arguments (using environment variables)
  - USER_DIR=~/docker_userdir
  - DOCKER_USER  = 0 # not working on windows(docker-desktop)
  - DOCKER_GROUP = 0 # not working on windows(docker-desktop)
  - VNC_PORT     = 9999 # port number of browser_vnc
  - JUPYTER_PORT = 8888 # port number of jupyter
  - JUPYTER_TOKEN = ''  # token (password) to login jupyter
  - DOCKER_DISPLAY = 10 #internal use
  - VGL_DISPLAY    = :0 #GPU only
  - REPO=irslrepo/
 
- Example
  - Changing VNC port
```bash
VNC_PORT=11111 docker compose -f <downloaded-compose>.yaml [ -p name ] up
```

## Run at local (linux, windows-wsl)

- all options
```
run.sh [OPTIONS] [ choreonoid (-- args) | assembler | jypyter | choreonoid-console | python (-- args) | ipython (-- args) ] [ -- args ] "
```

- bash

```
$ ./run.sh
```

- using devel build

```
$ ./run.sh --devel
```

- choreonoid

```
$ ./run.sh choreonoid
```

- robot assembler

```
$ ./run.sh assembler
```

- jupyter

```
$ ./run.sh jupyter
```

connect http://localhost:8888 with your browser

- choreonoid-console

```
$ ./run.sh choreonoid-console 
```

launch choreonoid and open console(jupyter-console) connected to launched choreonoid


## Build docker image at local

### Build base libraries

Please build docker images described below.

- https://github.com/IRSL-tut/irsl_docker_base
- https://github.com/IRSL-tut/irsl_docker_xeus

### Build irsl_system

```
[ NO_CACHE=yes ] ./build.sh
```

```
BUILD_DEVEL=yes ./build.sh
```

- Development branch
  - https://github.com/IRSL-tut/choreonoid/tree/devel
  - https://github.com/IRSL-tut/choreonoid_ros/tree/devel
  - https://github.com/IRSL-tut/robot_assembler_plugin/tree/devel
  - https://github.com/IRSL-tut/jupyter_plugin/tree/devel
  - https://github.com/IRSL-tut/irsl_choreonoid_ros/tree/devel

## Related repositories

### choreonoid
https://github.com/IRSL-tut/choreonoid
( forked from https://github.com/choreonoid/choreonoid )

### choreonoid_ros
https://github.com/IRSL-tut/choreonoid_ros
( forked from https://github.com/choreonoid/choreonoid_ros )

### irsl_choreonoid
https://github.com/IRSL-tut/irsl_choreonoid

### irsl_choreonoid_ros
https://github.com/IRSL-tut/irsl_choreonoid_ros

### robot_assembler_plugin
https://github.com/IRSL-tut/robot_assembler_plugin

### jupyter_plugin
https://github.com/IRSL-tut/jupyter_plugin
