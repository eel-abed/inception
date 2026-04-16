# 🐳 Inception - Infrastructure System Administration

**Auteur :** eel-abed
**Projet :** Inception (École 42)

Ce document centralise toutes les exigences techniques (Product Requirements Document), l'architecture de l'infrastructure Docker, ainsi que les procédures de lancement et de tests spécifiques à l'environnement 42.

---

## 🎯 Objectifs du Projet
Le projet Inception vise à élargir nos connaissances en administration système en virtualisant plusieurs images Docker, le tout tournant à l'intérieur d'une Machine Virtuelle personnelle. L'objectif est de mettre en place une petite infrastructure web fonctionnelle et sécurisée.

## 🏗️ Architecture Technique (3-Tiers)

L'infrastructure repose sur **3 conteneurs distincts** (règle stricte d'un service par conteneur), communiquant via un réseau intra-conteneurs Docker dédié (`inception`).

| Service | Image de base | Port Interne | Rôle |
|:---|:---|:---:|:---|
| **NGINX** | Debian Bullseye | `443` | Reverse-proxy, unique point d'entrée (TLSv1.2/1.3 uniquement). |
| **WordPress** | Debian Bullseye | `9000` | Exécute le code PHP via PHP-FPM (v7.4) et gère le site. |
| **MariaDB** | Debian Bullseye | `3306` | Base de données hébergeant la data de WordPress. |

### Contraintes Imposées
* Aucun conteneur ne doit être lié à `latest` (les images sont construites manuellement depuis `debian:bullseye`).
* NGINX doit être le **seul** conteneur exposé à l'extérieur.
* Sécurité totale : TLS obligatoire (auto-signé), pas d'accès direct au port 9000 ou 3306 depuis l'hôte.
* Les mots de passe et configurations critiques doivent être gérés de manière sécurisée (Docker Secrets & .env).
* Utilisation d'un volume physique persistant pour la Base de Données (`/var/lib/mysql`) et pour les fichiers du site (`/var/www/wordpress`).

---

## 📂 Structure du Répertoire
```text
inception/
├── Makefile
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   └── requirements/
│       ├── mariadb/
│       ├── nginx/
│       └── wordpress/
└── secrets/
```

---

## 🚀 Commandes de Déploiement (Makefile)

Le lancement du projet est automatisé via `Make` :
- `make` ou `make all` : Construit les dossiers pour les volumes locaux, build les images Docker et lance les conteneurs en background.
- `make down` : Arrête proprement les conteneurs (`docker compose down`).
- `make clean` : Arrête les conteneurs et supprime les réseaux/images liées au projet.
- `make fclean` : Fait tout ce que fait `clean` **ET** supprime toutes les datas physiques (Base de données et fichiers WordPress) en faisant appel à `sudo rm -rf`.
- `make re` : Fait un `fclean` suivi d'un `all`.

---

## 🛠️ Comment tester à l'école 42 (Sans accès à /etc/hosts)

À l'école 42, nous n'avons pas les droits `sudo` pour modifier le fichier `/etc/hosts` sur les ordinateurs du cluster. De plus, les ports inférieurs à 1024 (comme le port 443) ne peuvent pas être écoutés depuis l'hôte vers la VirtualBox de manière standard.

### 1. Configuration de la Machine Virtuelle (VirtualBox)
- Le projet tourne dans une VM Debian (où on a les pleins pouvoirs et où l'on lance `make`).
- Une **redirection de port (Port Forwarding)** a été configurée dans VirtualBox :
  - IP Hôte : `127.0.0.1`
  - Port Hôte (Mac) : `4443`  => Port Invité (VM Debian) : `443`

### 2. Le "Hack" DNS pour Chrome
Pour forcer le navigateur à associer le nom de domaine intra-scolaire (`eel-abed.42.fr`) à `127.0.0.1` sans toucher au fichier `/etc/hosts`, ouvrez un terminal sur l'ordinateur physique (hôte) et lancez la commande correspondante à votre système pour ouvrir une session isolée de Chrome :

**Sur Linux Fedora (Postes 42 actuels via Flatpak) :**
```bash
flatpak run com.google.Chrome --user-data-dir=/tmp/chrome_dev_test --host-resolver-rules="MAP eel-abed.42.fr 127.0.0.1" --ignore-certificate-errors
```

**Sur anciens iMac 42 ou Ubuntu :**
```bash
google-chrome --user-data-dir=/tmp/chrome_dev_test --host-resolver-rules="MAP eel-abed.42.fr 127.0.0.1" --ignore-certificate-errors
```
*(Remplacez `google-chrome` par `chromium` ou le vrai chemin `/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome` sur iMac 42).*

### 3. Validation de l'Interface
Dans la page Chrome "développeur" qui vient de s'ouvrir, tapez avec le port de redirection :
👉 **`https://eel-abed.42.fr:4443`**

*(Comme le certificat `inception.crt` créé dans le Dockerfile NGINX est auto-signé, cliquez sur "Paramètres avancés" puis "Continuer vers le site").*
Le site WordPress, propulsé par la VM, s'affichera correctement.
