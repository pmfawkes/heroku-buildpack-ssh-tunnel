#!/bin/bash

function log {
  echo "ssh-tunnel	event=$1"
}

function is_configured {
  [[ \
    -v SSHTUNNEL_PRIVATE_KEY && \
    -v SSHTUNNEL_FORWARDING_PORT && \
    -v SSHTUNNEL_REMOTE_USER && \
    -v SSHTUNNEL_REMOTE_HOST
  ]] && return 0 || return 1
}

function deploy_key {
  mkdir -p ${HOME}/.ssh
  chmod 700 ${HOME}/.ssh

  echo "${SSHTUNNEL_PRIVATE_KEY}" > ${HOME}/.ssh/ssh-tunnel-key
  chmod 600 ${HOME}/.ssh/ssh-tunnel-key

  ssh-keyscan ${SSHTUNNEL_REMOTE_HOST} > ${HOME}/.ssh/known_hosts
}

function spawn_tunnel {
  while true; do
    log "Initialising tunnelling of port ${SSHTUNNEL_FORWARDING_PORT} via ${SSHTUNNEL_REMOTE_USER}@${SSHTUNNEL_REMOTE_HOST}"
    ssh -i ${HOME}/.ssh/ssh-tunnel-key -NT -L 127.0.0.1:${SSHTUNNEL_FORWARDING_PORT}:127.0.0.1:${SSHTUNNEL_FORWARDING_PORT} ${SSHTUNNEL_REMOTE_USER}@${SSHTUNNEL_REMOTE_HOST}
    log "Tunnel closed"
    sleep 5;
  done &
}

if is_configured; then
  deploy_key
  spawn_tunnel

  log "Spawned";
else
  log "Missing configuration, please ensure SSHTUNNEL_PRIVATE_KEY, SSHTUNNEL_FORWARDING_PORT, SSHTUNNEL_REMOTE_USER & SSHTUNNEL_REMOTE_HOST environment variables are specified"
fi
