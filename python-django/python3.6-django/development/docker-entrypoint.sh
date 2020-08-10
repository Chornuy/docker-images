#!/usr/bin/env bash

printenv
CONTAINER_ALREADY_STARTED="/var/started"


if ! getent group "$GROUPID"; then
  
  echo "group does not exist"
  groupadd -g "${GROUPID}" "$USER_NAME"
else
  echo "group exists"
fi

if ! id -u "$USERID"  >/dev/null 2>&1; then
  echo "user does not exist"
  useradd -m -l -u "${USERID}" -g "$USER_NAME" "$USER_NAME"
  adduser ${USER_NAME} sudo
  adduser ${USER_NAME} docker
  
  echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" | EDITOR='tee -a' visudo
else
  echo "user exists"
fi


if [ ! -d "/var/app/venv" ]; then
    virtualenv -p python3.6 /var/venv
fi

if [ ! -d "/var/app/venv" ]; then
      echo "add venv"
      su - $USER_NAME -c "python3 -m venv /var/app/venv"
else
      echo "FOUND EXISTING VENV"
fi

BASH_PATH="/home/$USER_NAME/.bashrc"
VIRTUAL_ENV=/var/venv/bin

export PATH="$VIRTUAL_ENV:$PATH"


if ! grep -Fxq "PATH=\"${VIRTUAL_ENV}:${PATH}\"" $BASH_PATH; then
    echo "$PATH" | tee -a $BASH_PATH
    echo "MODIFY PATH VAIRIABLE"
else
    echo "ALREADY MODIFYITED BASH"
fi

if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"
    su - $USER_NAME -c "/var/app/venv/bin/pip install --upgrade pip"
    su - $USER_NAME -c ". /var/app/venv/bin/activate && pip install --no-cache-dir -r /var/app/project/requirements.txt"
else
    echo "-- Not first container startup --"
fi

set -- gosu "$USER_NAME" "$@"


su - $USER_NAME
whoami
echo "{$CURRENT_USER}"
echo "$@"
# exec gosu "$USER_NAME" "/bin/bash && source sand_box_projects/google_ad_duplicator/venv/bin/activate && ${@}"
# source /var/venv/bin/activate
exec $@

