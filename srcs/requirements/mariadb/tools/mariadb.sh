#!/bin/bash

set -e

DB_PASS=$(cat /run/secrets/db_password 2>/dev/null || echo $MYSQL_PASSWORD)
DB_ROOT_PASS=$(cat /run/secrets/db_root_password 2>/dev/null || echo $MYSQL_ROOT_PASSWORD)

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation de MariaDB System Tables..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Création de la base de données ${MYSQL_DATABASE} et des utilisateurs..."
    
    mysqld_safe --datadir=/var/lib/mysql &
    MY_PID=$!
    
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done

    mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${DB_PASS}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';"
    mysql -e "FLUSH PRIVILEGES;"
    
    echo "Base de données configurée avec succès !"
    
    mysqladmin -u root -p${DB_ROOT_PASS} shutdown
    
    wait $MY_PID
fi

echo "Démarrage de MariaDB..."
exec mysqld_safe --datadir=/var/lib/mysql
