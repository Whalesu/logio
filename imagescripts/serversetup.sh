#!/bin/bash -x

set -o errexit

if [ -n "${DELAYED_START}" ]; then
  sleep ${DELAYED_START}
fi

if [ -n "${LOGIO_SERVER_CONFIG_PATH}" ] ; then
  cp ${LOGIO_SERVER_CONFIG_PATH}  ~/.log.io/server.json
  return 0
fi

cat > ~/.log.io/server.json <<_EOF_
{
  "messageServer": {
    "host": ${LOGIO_TCP_MASTER_HOST},
    "port": ${LOGIO_TCP_MASTER_PORT}
  },
_EOF_

cat >> ~/.log.io/server.json <<_EOF_
  "httpServer": {
    "host": "0.0.0.0",
    "port":  6688
  },
_EOF_

if [ -n "${SERVER_DEBUG_MODE}" ]; then
  cat >> ~/.log.io/server.json <<_EOF_
  "debug": ${SERVER_DEBUG_MODE},
_EOF_
fi

if [ -n "${LOGIO_ADMIN_USER}" ] && [ -n "${LOGIO_ADMIN_PASSWORD}" ] && [ -n "${LOGIO_ADMIN_REALM}" ]; then
  cat >> ~/.log.io/server.json <<_EOF_
  "basicAuth": {
    "realm": "${LOGIO_ADMIN_REALM}",
    "users": {
      "${LOGIO_ADMIN_USER}": "${LOGIO_ADMIN_PASSWORD}"
    }
  },
_EOF_
fi

cat >> ~/.log.io/server.json <<_EOF_
  "eof": true
}
_EOF_
cat  ~/.log.io/server.json
