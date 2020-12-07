#!/usr/bin/env bash
register_developer_credential="
export DOCKER_HOST_ID=\$(id -u)
export DOCKER_HOST_GID=\$(id -g)
export DOCKER_HOST_USERNAME=\$(id -un)
"

export DOCKER_HOST_ID=$(id -u)
export DOCKER_HOST_GID=$(id -g)
export DOCKER_HOST_USERNAME=$(id -un)

ZSH_BASH="/usr/bin/zsh"

if [ $SHELL==$ZSH_BASH ]
    then
        BASH_PATH="/home/$USER/.zshrc"
    else
        BASH_PATH="/home/$USER/.bashrc"
fi


if ! grep -Fxq "DOCKER_HOST_ID" $BASH_PATH
 then
 echo "$register_developer_credential" | tee -a $BASH_PATH
fi
