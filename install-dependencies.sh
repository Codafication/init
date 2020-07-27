#!/bin/bash

set -e

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    *)          machine="UNKNOWN:${unameOut}"
esac

echo "Machine=$machine"

if [ "$machine" == "Linux" ]; then
  ./install-dependencies-linux.sh
elif [ "$machine" == "Mac" ]; then
  ./install-dependencies-osx.sh
else
    echo "Error: The machine does not appear to be Mac or Linux, found $machine"
    exit 1
fi


