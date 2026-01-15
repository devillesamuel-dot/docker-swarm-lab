# 05 - Déploiement de Services dans Docker Swarm

## Objectif

Apprendre à déployer, gérer et monitorer des services dans le cluster Docker Swarm.

## Concepts de base

### Service vs Container

- **Container** : Une instance unique d'une image
- **Service** : Un ou plusieurs containers (réplicas) gérés par Swarm
- **Task** : Une instance individuelle d'un service sur un nœud

### Types de services

**Replicated** (par défaut) :
- Nombre fixe de réplicas
- Distribués sur les nœuds disponibles
- Ex: `--replicas 3` → 3 containers

**Global** :
- 1 container par nœud
- Automatique sur les nouveaux nœuds
- Ex: agents de monitoring, logs

## Étape 1 : Déploiement simple

### 1.1 Service web avec Nginx

```bash
docker service create \
  --name web \
  --replicas 3 \
  --publish 8080:80 \
  nginx:alpine
```

**Paramètres :**
- `--name` : Nom du service
- `--replicas` : Nombre de containers
- `--publish` : Port exposé (host:container)
- Image : nginx:alpine (légère)

### 1.2 Vérification

```bash
# Liste des services
docker service ls

# État des tâches
docker service ps web

# Logs du service
docker service logs web

# Détails du service
docker service inspect web
```

### 1.3 Test d'accès

```bash
# Depuis n'importe quel nœud ou l'hôte
curl http://192.168.100.10:8080
curl http://192.168.100.11:8080
curl http://192.168.100.12:8080
```

Grâce au **routing mesh**, les 3 IPs fonctionnent même si le container ne tourne pas sur ce nœud.

## Étape 2 : Scaling et mise à jour

### 2.1 Augmenter le nombre de réplicas

```bash
# Scaler à 6 réplicas
docker service scale web=6

# Vérifier la distribution
docker service ps web
```

### 2.2 Réduire le nombre de réplicas

```bash
docker service scale web=2
```

### 2.3 Mise à jour rolling

```bash
# Mettre à jour l'image
docker service update --image nginx:1.25-alpine web

# Avec paramètres de mise à jour
docker service update \
  --image nginx:1.25-alpine \
  --update-parallelism 1 \
  --update-delay 10s \
  web
```

**Paramètres :**
- `--update-parallelism` : Nombre de tâches mises à jour en parallèle
- `--update-delay` : Délai entre chaque mise à jour

### 2.4 Rollback

Si la mise à jour pose problème :

```bash
docker service rollback web
```

## Étape 3 : Service avec contraintes de placement

### 3.1 Placer sur les workers uniquement

```bash
docker service create \
  --name app-worker \
  --replicas 3 \
  --constraint 'node.role==worker' \
  nginx:alpine
```

### 3.2 Placer sur le manager uniquement

```bash
docker service create \
  --name app-manager \
  --constraint 'node.role==manager' \
  nginx:alpine
```

### 3.3 Utiliser des labels personnalisés

```bash
# Ajouter des labels aux nœuds (sur le manager)
docker node update --label-add environment=production swarm-worker1
docker node update --label-add environment=staging swarm-worker2

# Créer un service avec contrainte de label
docker service create \
  --name app-prod \
  --constraint 'node.labels.environment==production' \
  nginx:alpine
```

## Étape 4 : Déployer le Visualizer

Le Visualizer offre une interface web pour voir le cluster en temps réel.

```bash
docker service create \
  --name viz \
  --publish 8081:8080 \
  --constraint node.role==manager \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  dockersamples/visualizer:latest
```

**Accès :**
```
http://192.168.100.10:8081
```

Vous verrez une représentation graphique de votre cluster avec les services déployés.

## Étape 5 : Service avec variables d'environnement

```bash
docker service create \
  --name db \
  --env POSTGRES_PASSWORD=mysecretpassword \
  --env POSTGRES_USER=admin \
  --env POSTGRES_DB=mydb \
  postgres:15-alpine
```

## Étape 6 : Service global

Déployer un container sur **chaque nœud** :

```bash
docker service create \
  --name monitoring-agent \
  --mode global \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  prom/node-exporter
```

Vérifier :
```bash
docker service ps monitoring-agent
```

Vous devriez voir 1 tâche par nœud.

## Étape 7 : Déploiement avec Docker Stack

### 7.1 Créer un fichier docker-compose.yml

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
      placement:
        constraints:
          - node.role == worker

  visualizer:
    image: dockersamples/visualizer:latest
    ports:
      - "8081:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager

networks:
  default:
    driver: overlay
```

### 7.2 Déployer la stack

```bash
docker stack deploy -c docker-compose.yml myapp
```

### 7.3 Gérer la stack

```bash
# Lister les stacks
docker stack ls

# Services de la stack
docker stack services myapp

# Tâches de la stack
docker stack ps myapp

# Supprimer la stack
docker stack rm myapp
```

## Étape 8 : Réseaux overlay

### 8.1 Créer un réseau overlay

```bash
docker network create --driver overlay my-network
```

### 8.2 Attacher des services au réseau

```bash
docker service create \
  --name frontend \
  --network my-network \
  nginx:alpine

docker service create \
  --name backend \
  --network my-network \
  redis:alpine
```

Les services peuvent maintenant communiquer via leur nom.

### 8.3 Vérifier

```bash
# Lister les réseaux
docker network ls

# Inspecter le réseau
docker network inspect my-network
```

## Étape 9 : Gestion des secrets

### 9.1 Créer un secret

```bash
echo "my_super_secret_password" | docker secret create db_password -
```

### 9.2 Utiliser le secret dans un service

```bash
docker service create \
  --name db \
  --secret db_password \
  --env POSTGRES_PASSWORD_FILE=/run/secrets/db_password \
  postgres:15-alpine
```

Le secret sera monté dans `/run/secrets/db_password`.

### 9.3 Gérer les secrets

```bash
# Lister les secrets
docker secret ls

# Inspecter un secret (ne montre pas le contenu)
docker secret inspect db_password

# Supprimer un secret
docker secret rm db_password
```

## Étape 10 : Volumes et persistance

### 10.1 Créer un volume

```bash
docker volume create db-data
```

### 10.2 Service avec volume

```bash
docker service create \
  --name postgres \
  --mount type=volume,src=db-data,dst=/var/lib/postgresql/data \
  --env POSTGRES_PASSWORD=mysecretpassword \
  postgres:15-alpine
```

## Tests de haute disponibilité

### Test 1 : Arrêt d'un worker

```bash
# Noter les nœuds où tournent les containers
docker service ps web

# Éteindre swarm-worker2 (depuis VMware ou avec shutdown)

# Observer la migration automatique
docker service ps web

# Rallumer swarm-worker2
# Forcer le rééquilibrage
docker service update --force web
```

### Test 2 : Simulation de panne

```bash
# Supprimer manuellement un container
docker ps  # Sur un worker
docker rm -f <container-id>

# Swarm va automatiquement recréer le container
docker service ps web
```

### Test 3 : Drain d'un nœud

```bash
# Mettre un nœud en maintenance
docker node update --availability drain swarm-worker1

# Les containers migrent automatiquement
docker service ps web

# Réactiver
docker node update --availability active swarm-worker1
```

## Monitoring et debugging

### Voir les événements

```bash
# Événements du Swarm
docker events --filter type=service

# Événements d'un service
docker service ps web --no-trunc
```

### Logs détaillés

```bash
# Logs d'un service
docker service logs --follow web

# Logs avec timestamps
docker service logs --timestamps web

# Logs depuis un temps donné
docker service logs --since 30m web
```

### Statistiques

```bash
# Stats des containers (sur un nœud)
docker stats

# Info d'un service
docker service inspect --pretty web
```

## Commandes de nettoyage

```bash
# Supprimer un service
docker service rm web

# Supprimer tous les services
docker service rm $(docker service ls -q)

# Supprimer une stack
docker stack rm myapp

# Nettoyer les réseaux inutilisés
docker network prune

# Nettoyer les volumes inutilisés
docker volume prune
```

## Exemples de stacks complètes

### Stack WordPress + MySQL

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppassword
    volumes:
      - mysql-data:/var/lib/mysql
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager

  wordpress:
    image: wordpress:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppassword
      WORDPRESS_DB_NAME: wordpress
    deploy:
      replicas: 2
      placement:
        constraints:
          - node.role == worker

volumes:
  mysql-data:
```

### Stack avec load balancer

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    deploy:
      replicas: 5
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3

  lb:
    image: traefik:v2.10
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    deploy:
      placement:
        constraints:
          - node.role == manager
```

## Bonnes pratiques

### Sizing des services

- **Réplicas** : Minimum 3 pour la haute disponibilité
- **Resources** : Limiter CPU et mémoire
  ```bash
  docker service create \
    --name web \
    --replicas 3 \
    --limit-cpu 0.5 \
    --limit-memory 512M \
    --reserve-cpu 0.25 \
    --reserve-memory 256M \
    nginx:alpine
  ```

### Mise à jour sans downtime

```bash
docker service update \
  --update-parallelism 1 \
  --update-delay 30s \
  --update-failure-action rollback \
  --rollback-parallelism 1 \
  --image nginx:1.25-alpine \
  web
```

### Health checks

```bash
docker service create \
  --name web \
  --health-cmd "curl -f http://localhost/ || exit 1" \
  --health-interval 30s \
  --health-timeout 10s \
  --health-retries 3 \
  nginx:alpine
```

## Validation finale

✅ Créer et gérer des services  
✅ Scaler dynamiquement  
✅ Déployer des stacks avec Docker Compose  
✅ Utiliser le Visualizer  
✅ Tester la haute disponibilité  
✅ Gérer les réseaux overlay  
✅ Utiliser les secrets  

## Ressources supplémentaires

- [Docker Service CLI Reference](https://docs.docker.com/engine/reference/commandline/service/)
- [Docker Stack Reference](https://docs.docker.com/engine/reference/commandline/stack/)
- [Compose file reference](https://docs.docker.com/compose/compose-file/)

---

**Félicitations !** Vous maîtrisez maintenant les bases de Docker Swarm. Vous pouvez passer aux évolutions avancées comme le monitoring, le logging centralisé, ou la simulation d'architectures complexes.
