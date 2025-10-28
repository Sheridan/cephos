# source: Dockerfile
FROM debian:bookworm

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        cpio \
        curl \
        debootstrap \
        fdisk \
        fonts-noto-mono \
        git \
        gpg \
        imagemagick \
        iproute2 \
        iputils-arping \
        iputils-ping \
        iputils-tracepath \
        live-build \
        make \
        rsync \
        squashfs-tools \
        sudo \
        syslinux \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g ${GROUP_ID} worker && \
    useradd -m -u ${USER_ID} -g ${GROUP_ID} -s /bin/bash worker && \
    echo "worker ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/worker && \
    chmod 0440 /etc/sudoers.d/worker

COPY files/gai.conf /etc/gai.conf

USER worker
WORKDIR /home/worker/work


COPY --chown=worker:worker entrypoint.sh /home/worker/entrypoint.sh
RUN chmod +x /home/worker/entrypoint.sh

ENTRYPOINT ["/home/worker/entrypoint.sh"]
