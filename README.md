# irsl_system

## Using on browser

- Install docker (linux, windows-wol) or docker-destkop (windows)

- Download a file for docker compose

- RUN

```bash
docker compose -f <downloaded-compose>.yaml [ -p name ] up
```

## Run at local (linux, windows-wol)

- all options
```
run.sh [-D | --devel] [-p | --port port] [ choreonoid (-- args) | assembler | jypyter | choreonoid-console | python (-- args) | ipython (-- args) ]"
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
( https://github.com/choreonoid/choreonoid )

### choreonoid_ros
https://github.com/IRSL-tut/choreonoid_ros
( https://github.com/choreonoid/choreonoid_ros )

### irsl_choreonoid
https://github.com/IRSL-tut/irsl_choreonoid

### irsl_choreonoid_ros
https://github.com/IRSL-tut/irsl_choreonoid_ros

### robot_assembler_plugin
https://github.com/IRSL-tut/robot_assembler_plugin

### jupyter_plugin
https://github.com/IRSL-tut/jupyter_plugin
