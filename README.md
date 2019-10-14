### Description

This repository hosts two `Dockerfile`s and an accompanying `build.sh` script to
build multi-architecture Docker images. The images are intended to be used as
isolated environments that contain dependencies of [`POLO`][polo].

[polo]: https://github.com/pologrp/polo

### Image Details

All images use the `stretch-slim` [Debian][debian] image as the base and build

  - [`cmake v3.9.0`][cmake],
  - [`libzmq v4.3.2`][libzmq],
  - [`cereal v1.2.2`][cereal], and,
  - [`gtest v1.10.0`][gtest]

from source. `Dockerfile.lapack` and `Dockerfile.openblas` differ from each
other in the LAPACK implementation they install. `Dockerfile.lapack` installs
the [reference LAPACK][lapack] (`v3.8.0`) implementation, whereas
`Dockerfile.openblas` installs the [OpenBLAS][openblas] (`v0.3.6`) variant.

All images support `amd64`, `arm32v6` and `arm64v8` architectures.

[debian]: https://hub.docker.com/_/debian
[cmake]: https://cmake.org/
[libzmq]: https://github.com/zeromq/libzmq
[cereal]: https://github.com/USCilab/cereal
[gtest]: https://github.com/google/googletest
[lapack]: https://github.com/Reference-LAPACK/lapack-release
[openblas]: https://github.com/xianyi/OpenBLAS

### How to Use the Images

As an end user, you do **NOT** need to build the images. On a system with Docker
properly installed, you can simply run

```bash
docker pull pologrp/polo-ci
docker run --tty --interactive --rm pologrp/polo-ci
```

or

```bash
docker pull pologrp/polo-ci:openblas
docker run --tty --interactive --rm pologrp/polo-ci:openblas
```

to pull and run the corresponding Docker image for your architecture that
contains the reference LAPACK or OpenBLAS implementations, respectively.

### How to Build the Images

The accompanying `build.sh` script uses [`qemu-user-static`][qemu] to build
Docker images for different architectures on an `amd64` host. Then, it uses
Docker's experimental `manifest` functionality to build manifest lists. For this
reason, you need to have a Docker client that is installed with experimental
features enabled. To enable the experimental features, you need to have
the following in your `$HOME/.docker/config.json` file:

```json
{
  "experimental": "enabled"
}
```

Finally, `build.sh` pushes the images and the manifest lists to
[`pologrp/polo-ci`][pologrphub]. Hence, you need to provide `build.sh` with a
Docker Hub `username` and `password` combination, which has write access to the
repository.

```bash
git clone https://github.com/pologrp/docker-ci /tmp/docker-ci
cd /tmp/docker-ci
DOCKER_USERNAME='username' DOCKER_PASSWORD='password' ./build.sh
```

[qemu]: https://github.com/multiarch/qemu-user-static
[pologrphub]: https://hub.docker.com/r/pologrp/polo-ci
