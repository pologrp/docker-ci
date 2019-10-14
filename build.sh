#!/usr/bin/env sh
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

docker run --rm --privileged multiarch/qemu-user-static:register --reset

for lapack in lapack openblas; do
  if [ ${lapack} == 'lapack' ]; then
    tag="latest"
  else
    tag="openblas"
  fi

  for arch in amd64 arm32 arm64; do
    case ${arch} in
      amd64 )
        image_arch="amd64"
        qemu_arch="x86_64"
        ;;
      arm32 )
        image_arch="arm32v7"
        openblas_arch="ARMV6"
        qemu_arch="arm"
        ;;
      arm64 )
        image_arch="arm64v8"
        openblas_arch="ARMV8"
        qemu_arch="aarch64"
        ;;
    esac

    if [ ! -f "qemu-${qemu_arch}-static" ]; then
      wget -N https://github.com/multiarch/qemu-user-static/releases/download/v4.1.0-1/x86_64_qemu-${qemu_arch}-static.tar.gz
      tar -xvf x86_64_qemu-${qemu_arch}-static.tar.gz
    fi

    cp Dockerfile.${lapack} Dockerfile.${lapack}.${arch}
    sed -i "s|__IMAGE_ARCH__|${image_arch}|g" Dockerfile.${lapack}.${arch}
    sed -i "s|__QEMU_ARCH__|${qemu_arch}|g" Dockerfile.${lapack}.${arch}

    if [ ${arch} == 'amd64' ]; then
      sed -i "/__CROSS_COPY__/d" Dockerfile.${lapack}.${arch}
    else
      sed -i "s/__CROSS_COPY__/COPY/g" Dockerfile.${lapack}.${arch}
      if [ ${lapack} == 'openblas' ]; then
        sed -i "s/DYNAMIC_ARCH=ON/DYNAMIC_ARCH=OFF -D TARGET=${openblas_arch}/" Dockerfile.${lapack}.${arch}
      fi
    fi

    docker build -f Dockerfile.${lapack}.${arch} -t pologrp/polo-ci:${lapack}-${arch} .
    docker push pologrp/polo-ci:${lapack}-${arch}
    docker manifest create --amend pologrp/polo-ci:${tag} pologrp/polo-ci:${lapack}-${arch}
  done

  docker manifest push --purge pologrp/polo-ci:${tag}
done
