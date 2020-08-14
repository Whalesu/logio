#!/bin/bash -x

set -o errexit

mkdir -p ~/.log.io
mkdir -p ~/.log.io/inputs

if [ "$1" = 'logio' ]; then
  source /opt/logio/serversetup.sh
  sleep 1
  exec log.io-server
elif [ "$1" = 'fileinput' ]; then
  source /opt/logio/fileinputsetup.sh
  printFileInputConfigFile
  exec log.io-file-input
else
  exec "$@"
fi
