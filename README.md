# dev-container
Repo to maintain base Github dev containers and codespaces

## File structure

* ./devcontainer.json
  * This is the main container config file for developing the specific dev container images. This environment supports Docker in Docker (DinD).

│   ├── base
│   │   ├── Dockerfile
│   │   └── devcontainer.json
│   └── devcontainer.json

## nRF Connect SDK - Zephyr Build image
Based on this [repo from Nordic](https://github.com/NordicPlayground/nrf-docker)

## Resources
https://github.com/devcontainers
https://devzone.nordicsemi.com/guides/nrf-connect-sdk-guides/b/getting-started/posts/build-ncs-application-firmware-images-using-docker
