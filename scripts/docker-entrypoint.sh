#!/bin/bash
#
# docker-entrypoint for tarpn-docker

set -e

if [[ "$VERBOSE" = "yes" ]]; then
    set -x
fi

exec "$@"
