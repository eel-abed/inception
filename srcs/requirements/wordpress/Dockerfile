FROM debian:bullseye

# Mise à jour et installation des packages nécessaires (PHP-FPM, mariaDB client pour tester la connexion, etc.)
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y curl wget php7.4 php7.4-fpm php-mysql mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Installation de wp-cli (Outil en ligne de commande pour WordPress)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copie des configurations et du script d'initialisation
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/wordpress.sh /usr/local/bin/wordpress.sh

# Rendre le script exécutable
RUN chmod +x /usr/local/bin/wordpress.sh

# Créer les dossiers nécessaires pour PHP-FPM et WordPress
RUN mkdir -p /run/php /var/www/wordpress && \
    chown -R www-data:www-data /var/www/wordpress

# Le dossier de travail sera la racine de WordPress
WORKDIR /var/www/wordpress

# Exposer le port de PHP-FPM (9000 par défaut en général pour ce projet)
EXPOSE 9000

# Script de lancement principal
ENTRYPOINT ["/usr/local/bin/wordpress.sh"]
