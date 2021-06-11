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
    sudo ln -sf /dev/stderr /var/log/mysqld.log
    chown mysql:mysql /var/log/mysqld.log
    echo "linked"

    
    if [ -z "$MYSQL_INITDB_SKIP_TZINFO" ]; then
       mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql -p$MYSQL_ROOT_PASSWORD
    fi

echo "ensure tokudb..."
ps-admin --docker --enable-tokudb -u root -p$MYSQL_ROOT_PASSWORD
tail -f /var/log/mysqld.log
