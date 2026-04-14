FROM debian:bullseye

# Mettre à jour et installer NGINX ainsi que OpenSSL pour générer le certificat
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Créer le dossier où sera stocké le certificat SSL
RUN mkdir -p /etc/nginx/ssl

# Générer un certificat SSL auto-signé avec OpenSSL (sans mot de passe, valable 365 jours)
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=eel-abed.42.fr/UID=eel-abed"

# Créer le répertoire pour les fichiers de l'application et ajuster les droits
RUN mkdir -p /var/run/nginx && \
    mkdir -p /var/www/wordpress && \
    chmod -R 755 /var/www/wordpress && \
    chown -R www-data:www-data /var/www/wordpress

# Copier notre fichier de configuration custom NGINX pour écraser celui par défaut
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Seul le port 443 (HTTPS) doit être exposé selon le sujet
EXPOSE 443

# Commande pour démarrer le démon NGINX au premier plan
CMD ["nginx", "-g", "daemon off;"]
