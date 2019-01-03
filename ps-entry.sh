#!/bin/bash
set -e
export LD_PRELOAD=/usr/lib64/libjemalloc.so.1

# if command starts with an option, prepend mysqld
if [ "${1:0:1}" = '-' ]; then
    CMDARG="$@"
fi

    # Get config
    DATADIR="$("mysqld" --verbose --help 2>/dev/null | awk '$1 == "datadir" { print $2; exit }')"
    if [ ! -e "$DATADIR/init.ok" ]; then
        if [ -z "$MYSQL_ROOT_PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" -a -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
                        echo >&2 'error: database is uninitialized and password option is not specified '
                        echo >&2 '  You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD'
                        exit 1
        fi

        mkdir -p "$DATADIR"
        echo 'Running mysql initialize'
        mysqld --initialize-insecure --datadir="$DATADIR"
        chown -R mysql:mysql "$DATADIR"
        echo 'Finished mysql initialize'

    	service mysql restart

        # GENERATE RANDOM PASSWORD
        if [ ! -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
            MYSQL_ROOT_PASSWORD="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24 ; echo '')"
            echo "GENERATED ROOT PASSWORD: $MYSQL_ROOT_PASSWORD"
        fi

	echo "adding users..."

        mysql -u root -e "DELETE FROM mysql.user;"
        mysql -u root -e "CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
        mysql -u root -e "GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;"
        mysql -u root -e "DROP DATABASE IF EXISTS test ; FLUSH PRIVILEGES;"

        if [ "$MYSQL_DATABASE" ]; then
            echo "adding database..."
            mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;"
        fi

        if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then

            mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;"

            if [ "$MYSQL_DATABASE" ]; then
                mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL ON \`"$MYSQL_DATABASE"\`.* TO '"$MYSQL_USER"'@'%' ;"
            fi

            mysql -u root -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"
        fi

    fi

    echo "lets go..."
    service mysql restart
    touch $DATADIR/init.ok
    chown -R mysql:mysql "$DATADIR"
    
    if [ -z "$MYSQL_INITDB_SKIP_TZINFO" ]; then
       mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql -p$MYSQL_ROOT_PASSWORD
    fi

echo "ensure tokudb..."
ps_tokudb_admin --enable -u root -p$MYSQL_ROOT_PASSWORD
tail -f /var/log/mysqld.log
