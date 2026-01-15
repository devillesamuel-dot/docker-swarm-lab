# Docker Swarm - Cheat Sheet

## 🚀 Initialisation du cluster

```bash
# Initialiser un Swarm (manager)
docker swarm init --advertise-addr <IP>

# Obtenir le token worker
docker swarm join-token worker

# Obtenir le token manager
docker swarm join-token manager

# Rejoindre en tant que worker
docker swarm join --token <TOKEN> <MANAGER-IP>:2377

# Quitter le Swarm
docker swarm leave
docker swarm leave --force  # Pour un manager
```

## 📊 Gestion des nœuds

```bash
# Lister les nœuds
docker node ls

# Inspecter un nœud
docker node inspect <NODE>

# Promouvoir un worker en manager
docker node promote <NODE>

# Rétrograder un manager en worker
docker node demote <NODE>

# Drainer un nœud (maintenance)
docker node update --availability drain <NODE>

# Réactiver un nœud
docker node update --availability active <NODE>

# Ajouter un label
docker node update --label-add <KEY>=<VALUE> <NODE>

# Supprimer un nœud
docker node rm <NODE>
```

## 🐳 Gestion des services

### Création

```bash
# Service simple
docker service create --name <NAME> <IMAGE>

# Service avec réplicas
docker service create --name <NAME> --replicas 3 <IMAGE>

# Service avec port exposé
docker service create --name <NAME> -p 8080:80 <IMAGE>

# Service avec contrainte de placement
docker service create --name <NAME> \
  --constraint 'node.role==worker' <IMAGE>

# Service global (1 par nœud)
docker service create --name <NAME> --mode global <IMAGE>

# Service avec variables d'environnement
docker service create --name <NAME> \
  --env KEY=VALUE <IMAGE>

# Service avec volumes
docker service create --name <NAME> \
  --mount type=volume,src=<VOLUME>,dst=<PATH> <IMAGE>
```

### Gestion

```bash
# Lister les services
docker service ls

# Inspecter un service
docker service inspect <SERVICE>
docker service inspect --pretty <SERVICE>

# Voir les tâches d'un service
docker service ps <SERVICE>

# Logs d'un service
docker service logs <SERVICE>
docker service logs -f <SERVICE>  # Follow

# Scaler un service
docker service scale <SERVICE>=<REPLICAS>

# Mettre à jour un service
docker service update --image <NEW-IMAGE> <SERVICE>

# Rollback
docker service rollback <SERVICE>

# Forcer le redéploiement
docker service update --force <SERVICE>

# Supprimer un service
docker service rm <SERVICE>
```

## 📦 Gestion des stacks

```bash
# Déployer une stack
docker stack deploy -c <COMPOSE-FILE> <STACK>

# Lister les stacks
docker stack ls

# Services d'une stack
docker stack services <STACK>

# Tâches d'une stack
docker stack ps <STACK>

# Supprimer une stack
docker stack rm <STACK>
```

## 🔐 Gestion des secrets

```bash
# Créer un secret
echo "secret-value" | docker secret create <NAME> -
docker secret create <NAME> <FILE>

# Lister les secrets
docker secret ls

# Inspecter un secret
docker secret inspect <SECRET>

# Supprimer un secret
docker secret rm <SECRET>

# Utiliser dans un service
docker service create --name <NAME> \
  --secret <SECRET> <IMAGE>
```

## 🌐 Gestion des réseaux

```bash
# Créer un réseau overlay
docker network create --driver overlay <NETWORK>

# Lister les réseaux
docker network ls

# Inspecter un réseau
docker network inspect <NETWORK>

# Supprimer un réseau
docker network rm <NETWORK>

# Attacher un service à un réseau
docker service update --network-add <NETWORK> <SERVICE>
```

## 💾 Gestion des volumes

```bash
# Créer un volume
docker volume create <VOLUME>

# Lister les volumes
docker volume ls

# Inspecter un volume
docker volume inspect <VOLUME>

# Supprimer un volume
docker volume rm <VOLUME>

# Nettoyer les volumes inutilisés
docker volume prune
```

## 📝 Exemple de fichier stack (docker-compose.yml)

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
      placement:
        constraints:
          - node.role == worker
    networks:
      - frontend

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: secret
    volumes:
      - db-data:/var/lib/postgresql/data
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
    networks:
      - backend

networks:
  frontend:
    driver: overlay
  backend:
    driver: overlay

volumes:
  db-data:
```

## 🔍 Diagnostic et monitoring

```bash
# Informations Swarm
docker info | grep -A 10 Swarm

# Événements en temps réel
docker events --filter type=service

# Stats des containers
docker stats

# Inspecter l'état d'un service
docker service ps --no-trunc <SERVICE>

# Voir les logs détaillés
docker service logs --timestamps --since 30m <SERVICE>
```

## 🛠️ Mise à jour et maintenance

```bash
# Mise à jour rolling avec délai
docker service update \
  --image <NEW-IMAGE> \
  --update-parallelism 2 \
  --update-delay 10s \
  --update-failure-action rollback \
  <SERVICE>

# Health check
docker service update \
  --health-cmd "curl -f http://localhost/ || exit 1" \
  --health-interval 30s \
  --health-timeout 10s \
  --health-retries 3 \
  <SERVICE>

# Limites de ressources
docker service update \
  --limit-cpu 0.5 \
  --limit-memory 512M \
  --reserve-cpu 0.25 \
  --reserve-memory 256M \
  <SERVICE>
```

## 🧹 Nettoyage

```bash
# Supprimer tous les services
docker service rm $(docker service ls -q)

# Nettoyer les réseaux inutilisés
docker network prune

# Nettoyer les volumes inutilisés
docker volume prune

# Nettoyage complet (containers, images, volumes, réseaux)
docker system prune -a --volumes
```

## 🔥 Raccourcis utiles

```bash
# Alias pour lister les nœuds
alias dnls='docker node ls'

# Alias pour lister les services
alias dsls='docker service ls'

# Alias pour voir les tâches d'un service
alias dsps='docker service ps'

# Fonction pour scaler rapidement
scale() { docker service scale "$1"="$2"; }
# Usage: scale web 5

# Fonction pour suivre les logs d'un service
slogs() { docker service logs -f "$1"; }
# Usage: slogs web
```

## 📌 Ports Swarm à connaître

- **2377/tcp** : Cluster management communications
- **7946/tcp** et **7946/udp** : Container network discovery
- **4789/udp** : Overlay network traffic

## 🚨 Dépannage rapide

```bash
# Service ne démarre pas
docker service ps --no-trunc <SERVICE>
docker service logs <SERVICE>

# Nœud injoignable
docker node inspect <NODE>
ping <NODE-IP>
nc -zv <NODE-IP> 2377

# Réinitialiser un nœud
docker swarm leave --force
docker swarm init --force-new-cluster  # Sur le manager
```

---

**💡 Astuce :** Gardez ce fichier sous la main ou créez un alias pour l'afficher rapidement !

```bash
alias swarm-help='cat ~/docker-swarm-lab/CHEATSHEET.md | less'
```
