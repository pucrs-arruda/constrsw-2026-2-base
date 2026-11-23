FROM ubuntu:24.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DOCKER_VERSION=5:28.5.2-1~ubuntu.24.04~noble
ARG CONTAINERD_VERSION=2.2.3-1~ubuntu.24.04~noble
ARG DOCKER_BUILDX_VERSION=0.33.0-1~ubuntu.24.04~noble
ARG DOCKER_COMPOSE_VERSION=5.1.3-1~ubuntu.24.04~noble

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      bash \
      ca-certificates \
      curl \
      fuse-overlayfs \
      git \
      gnupg \
      iptables \
      jq \
      openssh-server \
      sudo && \
    rm -rf /var/lib/apt/lists/*

RUN install -m 0755 -d /etc/apt/keyrings && \
    curl --retry 3 --retry-delay 5 -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      docker-ce=${DOCKER_VERSION} \
      docker-ce-cli=${DOCKER_VERSION} \
      containerd.io=${CONTAINERD_VERSION} \
      docker-buildx-plugin=${DOCKER_BUILDX_VERSION} \
      docker-compose-plugin=${DOCKER_COMPOSE_VERSION} && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/docker && \
    printf '%s\n' \
      '{' \
      '  "storage-driver": "fuse-overlayfs"' \
      '}' > /etc/docker/daemon.json && \
    update-alternatives --set iptables /usr/sbin/iptables-legacy && \
    update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

RUN install -m 0755 -d /var/run/sshd && \
    printf '%s\n' \
      'PasswordAuthentication no' \
      'ChallengeResponseAuthentication no' \
      'UsePAM no' > /etc/ssh/sshd_config.d/disable_password_auth.conf && \
    if ! id -u ubuntu >/dev/null 2>&1; then useradd -m -s /bin/bash ubuntu; fi && \
    groupadd -f docker && \
    usermod -aG docker,sudo ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu && \
    echo "ubuntu:ubuntu" | chpasswd

WORKDIR /home/ubuntu
USER ubuntu
