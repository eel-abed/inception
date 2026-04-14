#!/bin/bash

# Sécurité: s'arrête si une erreur survient
set -e

# Lecture des mots de passe depuis les secrets Docker (meilleure pratique)
# ou depuis les variables d'environnement (fallback)
DB_PASS=$(cat /run/secrets/db_password 2>/dev/null || echo $MYSQL_PASSWORD)
DB_ROOT_PASS=$(cat /run/secrets/db_root_password 2>/dev/null || echo $MYSQL_ROOT_PASSWORD)

# Vérifier que le dossier racine de mariadb existe (l'installation basique), sinon l'initialiser
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialisation de MariaDB System Tables..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

# Si le dossier de NOTRE base de données n'existe pas encore, on la crée
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Création de la base de données ${MYSQL_DATABASE} et des utilisateurs..."
    
    # Lancement du demon de manière silencieuse juste le temps de configurer
    mysqld_safe --datadir=/var/lib/mysql &
    MY_PID=$!
    
    # On attend que MariaDB soit prêt à recevoir des commandes
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done

    # Exécution des commandes SQL pour initialiser la DB, l'utilisateur et le Root
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${DB_PASS}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';"
    mysql -e "FLUSH PRIVILEGES;"
    
    echo "Base de données configurée avec succès !"
    
    # Extinction du Daemon temporaire
    mysqladmin -u root -p${DB_ROOT_PASS} shutdown
    
    # On s'assure que le process temporaire est bien fini
    wait $MY_PID
fi

echo "Démarrage de MariaDB..."
# Remplacer le shell par mysqld_safe avec exec pour qu'il devienne le PID 1 du conteneur
exec mysqld_safe --datadir=/var/lib/mysql
