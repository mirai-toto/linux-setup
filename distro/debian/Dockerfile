FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
# Required for Homebrew to install non-interactively
ENV NONINTERACTIVE=1

# Minimal Homebrew prerequisites — distro-specific deps are handled by install.sh
RUN apt-get update && apt-get install -y \
    sudo git curl file procps \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user with passwordless sudo (mirrors WSL setup)
RUN useradd -m -s /bin/bash testuser \
    && echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER testuser
ENV USER=testuser
WORKDIR /home/testuser

COPY --chown=testuser:testuser . /home/testuser/linux-setup
RUN cd /home/testuser/linux-setup && bash install.sh

CMD ["/home/linuxbrew/.linuxbrew/bin/zsh"]
