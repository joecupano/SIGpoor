#!/usr/bin/env sh

echo "$ $@"
eval $@

USER=${USER:-$(whoami)}
SHELL=${SHELL:-$(getent passwd $USER | cut -d: -f7)}
${SHELL:-bash} -i