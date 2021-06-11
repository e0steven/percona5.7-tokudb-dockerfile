#!/bin/bash
set -e
export LD_PRELOAD=/usr/lib64/libjemalloc.so.1

# if command starts with an option, prepend mysqld
if [ "${1:0:1}" = '-' ]; then
    CMDARG="$@"
fi

    # Get config
    echo 'Engines starting'
    DATADIR="$("mysqld" --verbose --help 2>/dev/null | awk '$1 == "datadir" { print $2; exit }')"
    echo $DATADIR
    echo "lets go...linking logs"
    echo "linked"

echo "ensure tokudb..."

mysqld
