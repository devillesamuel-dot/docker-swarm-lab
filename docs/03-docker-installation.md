# 03 - Installation de Docker

## Objectif

Installer Docker Engine sur les 3 machines virtuelles pour préparer le déploiement du cluster Swarm.

## Méthodes d'installation

Nous allons utiliser le **script officiel Docker** qui détecte automatiquement la distribution et installe la version appropriée.

## Étape 1 : Installation sur toutes les VMs

### 1.1 Méthode automatique (recommandée)

Utiliser le script fourni dans le dépôt :

```bash
# Télécharger le script
curl -fsSL https://raw.githubusercontent.com/VOTRE_USERNAME/docker-swarm-lab/main/scripts/install-docker.sh -o install-docker.sh

# Rendre exécutable
chmod +x install-docker.sh

# Exécuter avec sudo
sudo ./install-docker.sh
```

Le script va :
- Mettre à jour le système
- Supprimer les anciennes versions de Docker
- Installer Docker via le script officiel
- Configurer les DNS Docker
- Ajouter l'utilisateur au groupe docker
- Tester l'installation

### 1.2 Méthode manuelle

Si vous préférez installer manuellement :

```bash
# Mise à jour du système
sudo apt update && sudo apt upgrade -y

# Installation des prérequis
sudo apt install -y ca-certificates curl gnupg lsb-release

# Téléchargement du script officiel Docker
curl -fsSL https://get.docker.com -o get-docker.sh

# Installation
sudo sh get-docker.sh

# Nettoyage
rm get-docker.sh

# Ajout de l'utilisateur au groupe docker
sudo usermod -aG docker $USER

# Activation du service
sudo systemctl enable docker
sudo systemctl start docker
```

### 1.3 Redémarrage de la session

**IMPORTANT :** Déconnectez-vous et reconnectez-vous pour que l'ajout au groupe docker prenne effet :

```bash
# Option 1 : Déconnexion/reconnexion
exit
# Puis reconnectez-vous en SSH

# Option 2 : Nouvelle session de groupe (temporaire)
newgrp docker
```

## Étape 2 : Configuration de Docker

### 2.1 Configuration des DNS Docker

Pour éviter les problèmes de résolution DNS (notamment avec AdGuard ou Pi-hole) :

```bash
sudo mkdir -p /etc/docker

sudo nano /etc/docker/daemon.json
```

Contenu :
```json
{
  "dns": ["8.8.8.8", "8.8.4.4"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

**Explications :**
- `dns` : Force l'utilisation des DNS Google dans les conteneurs
- `log-driver` : Format de logs JSON
- `log-opts` : Rotation des logs (max 10 MB par fichier, 3 fichiers conservés)

### 2.2 Appliquer la configuration

```bash
sudo systemctl restart docker
```

## Étape 3 : Vérification de l'installation

### 3.1 Vérifier la version

```bash
docker --version
```

Devrait afficher quelque chose comme :
```
Docker version 24.0.x, build xxxxx
```

### 3.2 Vérifier le statut du service

```bash
sudo systemctl status docker
```

Devrait afficher `Active: active (running)`.

### 3.3 Test avec hello-world

```bash
docker run hello-world
```

Si tout fonctionne, vous verrez :
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

### 3.4 Informations Docker

```bash
docker info
```

Vérifiez notamment :
- `Server Version` : Version de Docker
- `Storage Driver` : overlay2 (recommandé)
- `Swarm` : inactive (normal à ce stade)

## Étape 4 : Tests supplémentaires

### 4.1 Téléchargement d'une image

```bash
# Télécharger nginx
docker pull nginx:alpine

# Vérifier les images
docker images
```

### 4.2 Lancer un conteneur simple

```bash
# Lancer nginx en arrière-plan
docker run -d --name test-nginx -p 8080:80 nginx:alpine

# Vérifier qu'il tourne
docker ps

# Tester l'accès
curl http://localhost:8080

# Nettoyer
docker stop test-nginx
docker rm test-nginx
```

## Étape 5 : Répéter sur toutes les VMs

Exécuter les étapes 1 à 4 sur :
- ✅ swarm-manager (192.168.100.10)
- ✅ swarm-worker1 (192.168.100.11)
- ✅ swarm-worker2 (192.168.100.12)

## Problèmes courants

### "Got permission denied while trying to connect to the Docker daemon"

**Cause :** L'utilisateur n'est pas dans le groupe docker

**Solution :**
```bash
# Vérifier les groupes
groups

# Si docker n'apparaît pas
sudo usermod -aG docker $USER

# Déconnexion/reconnexion obligatoire
exit
```

### "Cannot connect to the Docker daemon"

**Cause :** Le service Docker n'est pas démarré

**Solution :**
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### Erreur lors du téléchargement d'images

**Symptôme :**
```
Error response from daemon: Get "https://registry-1.docker.io/v2/": dial tcp: lookup registry-1.docker.io: no such host
```

**Causes possibles :**

1. **Problème DNS :**
   ```bash
   # Tester
   ping registry-1.docker.io
   
   # Si échec, vérifier /etc/resolv.conf
   cat /etc/resolv.conf
   ```

2. **Filtrage DNS (AdGuard, Pi-hole) :**
   - Ajouter `registry-1.docker.io`, `*.docker.io`, `*.docker.com` à la whitelist
   - Ou désactiver temporairement

3. **Configuration DNS Docker :**
   ```bash
   # Vérifier /etc/docker/daemon.json
   cat /etc/docker/daemon.json
   
   # Si absent ou incorrect, créer/modifier
   sudo nano /etc/docker/daemon.json
   ```

### Script get-docker.com ne se télécharge pas

**Symptôme :**
```bash
curl: (6) Could not resolve host: get.docker.com
```

**Solutions :**

1. **Vérifier la connectivité Internet :**
   ```bash
   ping 8.8.8.8
   ping google.com
   ```

2. **Utiliser le script copié depuis une autre VM :**
   ```bash
   # Sur la VM qui fonctionne
   curl -fsSL https://get.docker.com -o get-docker.sh
   
   # Copier vers les autres VMs
   scp get-docker.sh samuel@192.168.100.11:~
   scp get-docker.sh samuel@192.168.100.12:~
   ```

3. **Installation via les dépôts Ubuntu (moins récent) :**
   ```bash
   sudo apt update
   sudo apt install -y docker.io docker-compose
   sudo systemctl enable docker
   sudo systemctl start docker
   ```

### Version Docker trop ancienne

Si vous avez installé via `apt install docker.io`, la version peut être plus ancienne.

**Vérifier :**
```bash
docker --version
```

Pour Swarm, minimum Docker 17.03+ requis (normalement OK avec Ubuntu 22.04).

## Commandes Docker utiles

### Gestion des images

```bash
# Lister les images
docker images

# Supprimer une image
docker rmi nginx:alpine

# Nettoyer les images non utilisées
docker image prune -a
```

### Gestion des conteneurs

```bash
# Lister les conteneurs actifs
docker ps

# Lister tous les conteneurs
docker ps -a

# Arrêter un conteneur
docker stop <container-id>

# Supprimer un conteneur
docker rm <container-id>

# Nettoyer les conteneurs arrêtés
docker container prune
```

### Inspection et logs

```bash
# Logs d'un conteneur
docker logs <container-id>

# Suivre les logs en temps réel
docker logs -f <container-id>

# Inspecter un conteneur
docker inspect <container-id>

# Exécuter une commande dans un conteneur
docker exec -it <container-id> /bin/sh
```

### Nettoyage système

```bash
# Nettoyer tout (conteneurs, images, volumes, réseaux)
docker system prune -a

# Voir l'utilisation du disque
docker system df
```

## Validation finale

Avant de passer à l'étape suivante, vérifier sur **chaque VM** :

✅ Docker est installé (version 20.10+ ou supérieure)  
✅ Le service Docker est actif  
✅ L'utilisateur peut exécuter `docker ps` sans sudo  
✅ Le test `docker run hello-world` fonctionne  
✅ Les images peuvent être téléchargées (ex: `docker pull nginx`)  

## Prochaine étape

→ [04 - Initialisation du Swarm](04-swarm-initialization.md)
