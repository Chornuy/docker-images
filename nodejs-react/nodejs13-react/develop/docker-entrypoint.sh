#!/usr/bin/env bash

printenv
CONTAINER_ALREADY_STARTED="/var/started"

if ! getent group "$MADIGICX_DOCKER_HOST_GID"; then
  groupadd -g "${GROUPID}" "$USER_NAME"
else
  echo "group exists"
fi

if ! id "$MADIGICX_DOCKER_HOST_ID"  >/dev/null 2>&1; then
  useradd -l -u "${USERID}" -g "$USER_NAME" "$USER_NAME"
  apt-get update && apt-get install -y sudo && \
    adduser ${USER_NAME} sudo
  echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" | EDITOR='tee -a' visudo
  echo "user does not exist"
fi

set -- gosu "$USER_NAME" "$@"

if [ ! -d "venv" ]; then
    virualenv -p python3.6 venv
fi

if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"
    source venv/bin/activate
    pip install --no-cache-dir -r requirements.txt
else
    echo "-- Not first container startup --"
fi

exec "$@"
