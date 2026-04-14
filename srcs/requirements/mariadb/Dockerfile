FROM debian:bullseye

# Mettre à jour les paquets et installer mariadb-server
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Copier la configuration custom et le script de lancement
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/mariadb.sh /usr/local/bin/

# Assurer que le script est bien exécutable
RUN chmod +x /usr/local/bin/mariadb.sh

# Créer les dossiers nécessaires pour que mysqld tourne correctement
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

# Exposer le port de la DB
EXPOSE 3306

# Lancer notre script en tant qu'entrée principale
ENTRYPOINT ["/usr/local/bin/mariadb.sh"]
