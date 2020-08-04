#!/bin/bash

set -o errexit

if [ -n "${DELAYED_START}" ]; then
  sleep ${DELAYED_START}
fi

if [ -n "${LOGIO_FILEINPUT_CONFIG_PATH}" ] ; then
  cp ${LOGIO_FILEINPUT_CONFIG_PATH} ~/.log.io/inputs/file.json
  return 0
fi

function resolveMasterSetting() {
  logio_master="logio";
  if [ -n "${LOGIO_FILEINPUT_MASTER_HOST}" ]; then
    logio_master=${LOGIO_FILEINPUT_MASTER_HOST}
  fi
  logio_master_port="6689";
  if [ -n "${LOGIO_FILEINPUT_MASTER_PORT}" ]; then
    logio_master_port=${LOGIO_FILEINPUT_MASTER_PORT}
  fi
}

function crawlEnumeratedConfiguration() {
  local i=1
  for (( i; ; i++ ))
  do
    VAR_LOGIO_FILEINPUT_SOURCENAME="LOGIO_FILEINPUT${i}_SOURCE"
#    echo -e "${!VAR_LOGIO_FILEINPUT_SOURCENAME}"
    if [ ! -n "${!VAR_LOGIO_FILEINPUT_SOURCENAME}" ]; then
      break
    fi
    crawlParameterizedLogFiles ${i}
  done
}

function crawlParameterizedLogFiles() {
  local idx=$1
  local DEPTH

  VAR_LOGIO_FILEINPUT_LOGSOURCE="LOGIO_FILEINPUT${idx}_SOURCE"
  VAR_LOGIO_FILEINPUT_LOGSTREAM="LOGIO_FILEINPUT${idx}_STREAM"
  VAR_LOGIO_FILEINPUT_FILEPATHREG="LOGIO_FILEINPUT${idx}_PATH"
  VAR_LOGIO_FILEINPUT_DEPTH="LOGIO_FILEINPUT${idx}_DEPTH"
  VAR_LOGIO_FILEINPUT_IGNOREFILE="LOGIO_FILEINPUT${idx}_IGNOREFILE"

  local SOURCE=${!VAR_LOGIO_FILEINPUT_LOGSOURCE}
  local STREAM=${!VAR_LOGIO_FILEINPUT_LOGSTREAM}
  local FILE_PATH=${!VAR_LOGIO_FILEINPUT_FILEPATHREG}

  if [ ! -n "${!VAR_LOGIO_FILEINPUT_DEPTH}" ]; then
    DEPTH=${LOG_FILE_SEARCH_DEPTH}
  else
    DEPTH=${!VAR_LOGIO_FILEINPUT_DEPTH}
  fi

  if [ -n "${SOURCE}" ] && [ -n "${STREAM}" ] && [ -n "${FILE_PATH}" ]; then
    cat >> ~/.log.io/inputs/file.json << _EOF_
    {
      "source": "${SOURCE}",
      "stream": "${STREAM}",
      "config": {
        "path": $FILE_PATH,
        "watcherOptions": {
          "depth": ${DEPTH}
        }
      }
    },
_EOF_
  fi

  if [ -z "${SOURCE}" ]; then
    echo -e "Missing parameter: LOGIO_FILEINPUT${i}_SOURCE";
  elif [ -z "${STREAM}" ]; then
    echo -e "Missing parameter: LOGIO_FILEINPUT${i}_STREAM";
  elif [ -z "${FILE_PATH}" ]; then
    echo -e "Missing parameter: LOGIO_FILEINPUT${i}_PATH";
  fi
}

function printFileInputConfigFile() {
  resolveMasterSetting
  cat > ~/.log.io/inputs/file.json <<_EOF_
{
  "messageServer": {
    "host": "${logio_master}",
    "port": ${logio_master_port}
  },
  "inputs": [
_EOF_

  crawlEnumeratedConfiguration

  cat ~/.log.io/inputs/file.json

  # remove last line containing extra comma
  sed -i '$ d' ~/.log.io/inputs/file.json
  cat >> ~/.log.io/inputs/file.json <<_EOF_
    }
  ]
}
_EOF_
  cat ~/.log.io/inputs/file.json
}
