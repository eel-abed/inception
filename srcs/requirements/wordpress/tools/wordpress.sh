#!/bin/bash
set -e

# Lecture des secrets (mots de passe) injectés
DB_PASS=$(cat /run/secrets/db_password 2>/dev/null || echo $MYSQL_PASSWORD)
ADMIN_PASS=$(cat /run/secrets/credentials.txt 2>/dev/null || echo $WP_ADMIN_PASSWORD)
# Si pas de password pre-défini pour l'user author, on en attribue un basique
USER_PASS=${WP_USER_PASS:-"userpassword42"}

cd /var/www/wordpress

# On ne peut pas commencer l'installation de WordPress tant que MariaDB n'est pas prêt.
# Ce "while loop" avec un sleep 2 attend patiemment la base de données.
echo "Attente de la connexion à MariaDB..."
until mysql -h mariadb -u "${MYSQL_USER}" -p"${DB_PASS}" -e "SELECT 1;" >/dev/null 2>&1; do
    echo "MariaDB n'est pas encore prêt. On attend..."
    sleep 3
done
echo "MariaDB est Prêt !"

# Installation automatique de WordPress si wp-config.php n'est pas encore là
if [ ! -f "wp-config.php" ]; then
    echo "Téléchargement de WordPress Core..."
    wp core download --allow-root

    echo "Création de la configuration wp-config..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASS}" \
        --dbhost="mariadb:3306" \
        --allow-root

    echo "Installation du Core de WordPress..."
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    echo "Création du second utilisateur demandé dans le sujet..."
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" --role=author --user_pass="${USER_PASS}" --allow-root

    echo "WordPress a été installé et configuré avec succès !"
else
    echo "WordPress est déjà installé. On passe directement au lancement de PHP-FPM."
fi

# Changer les propriétaires de notre code pour que nginx/php aient tous les accès
chown -R www-data:www-data /var/www/wordpress
chmod -R 755 /var/www/wordpress

# Lancer proprement php-fpm en foreground (-F permet qu'il soit au 1er plan / PID 1)
# au lieu de "daemonize" (mode arrière plan)
echo "Lancement de PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F
