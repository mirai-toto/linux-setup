FROM fedora:40 AS base

# Required for Homebrew to install non-interactively
ENV NONINTERACTIVE=1

RUN dnf install -y sudo && dnf clean all

# Create a non-root user with passwordless sudo (mirrors WSL setup).
# USER_UID/USER_GID default to 1000 but dev-env.sh overrides them with the
# invoking host user's ids so bind-mounted files share the same owner on both
# sides (no chowning needed). Free the target uid/gid first: some bases (e.g.
# ubuntu) ship a default user already occupying 1000.
ARG USER_UID=1000
ARG USER_GID=1000
RUN if getent passwd "$USER_UID" >/dev/null; then userdel -r "$(getent passwd "$USER_UID" | cut -d: -f1)" 2>/dev/null || true; fi \
  && if getent group "$USER_GID" >/dev/null; then groupdel "$(getent group "$USER_GID" | cut -d: -f1)" 2>/dev/null || true; fi \
  && groupadd -g "$USER_GID" testuser \
  && useradd -m -u "$USER_UID" -g "$USER_GID" -s /bin/bash testuser \
  && echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER testuser
ENV USER=testuser
WORKDIR /home/testuser

FROM base AS install

COPY --chown=testuser:testuser . /home/testuser/linux-setup
# never fails: exit code is recorded in the log, not propagated
RUN cd /home/testuser/linux-setup \
  && (bash install.sh 2>&1; echo "install.sh exit=$?") | tee /tmp/install.log

FROM scratch AS logs
COPY --from=install /tmp/install.log /

FROM install AS final
RUN test -x /home/linuxbrew/.linuxbrew/bin/zsh || { echo "zsh missing"; exit 1; }
CMD ["/home/linuxbrew/.linuxbrew/bin/zsh"]
