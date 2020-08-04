#!/bin/bash -x

set -o errexit

mkdir -p ~/.log.io
mkdir -p ~/.log.io/inputs

if [ "$1" = 'logio' ]; then
  source /opt/logio/serversetup.sh
  sleep 1
  log.io-server
elif [ "$1" = 'fileinput' ]; then
  source /opt/logio/fileinputsetup.sh
  printFileInputConfigFile
  log.io-file-input
else
  exec "$@"
fi
