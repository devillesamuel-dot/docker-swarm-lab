# Docker Swarm Lab - Environnement de Test et Apprentissage

![Docker Swarm](https://img.shields.io/badge/Docker-Swarm-2496ED?style=flat&logo=docker&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420?style=flat&logo=ubuntu&logoColor=white)
![VMware](https://img.shields.io/badge/VMware-Workstation-607078?style=flat&logo=vmware&logoColor=white)

## 📋 Table des matières

- [Introduction](#introduction)
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation rapide](#installation-rapide)
- [Documentation détaillée](#documentation-détaillée)
- [Tests et validation](#tests-et-validation)
- [Troubleshooting](#troubleshooting)
- [Commandes utiles](#commandes-utiles)
- [Évolutions possibles](#évolutions-possibles)
- [Ressources](#ressources)

## 🎯 Introduction

Ce projet est un environnement de laboratoire Docker Swarm complet, conçu pour apprendre et tester les fonctionnalités de clustering et d'orchestration de conteneurs.

**Objectifs pédagogiques :**
- Comprendre l'architecture distribuée de Docker Swarm
- Maîtriser le déploiement de services conteneurisés
- Tester la haute disponibilité et le scaling
- Préparer l'administration de systèmes en production (ex: Teamcenter PLM)

## 🏗️  Architecture

Le lab est composé de 3 machines virtuelles Ubuntu Server 22.04 LTS :

```
┌─────────────────────────────────────────────────────────┐
│                    VMware Workstation                   │
│                      (vmnet2 - NAT)                     │
│                    192.168.100.0/24                     │
└─────────────────────────────────────────────────────────┘
           │                  │                  │
           │                  │                  │
    ┌──────▼──────┐    ┌──────▼──────┐    ┌──────▼──────┐
    │   Manager   │    │   Worker 1  │    │   Worker 2  │
    │  .100.10    │    │   .100.11   │    │   .100.12   │
    │             │    │             │    │             │
    │  4 GB RAM   │    │  3 GB RAM   │    │  3 GB RAM   │
    │  2 vCPU     │    │  2 vCPU     │    │  2 vCPU     │
    └─────────────┘    └─────────────┘    └─────────────┘
         ★                  ○                  ○
    (Manager Node)      (Worker Node)     (Worker Node)
```

**Caractéristiques :**
- **1 Manager** : Orchestration, planification, état du cluster
- **2 Workers** : Exécution des conteneurs applicatifs
- **Réseau overlay** : Communication inter-conteneurs sécurisée
- **Load balancing** : Distribution automatique du trafic

## 📦 Prérequis

### Logiciels requis

- **VMware Workstation** (version 15+ ou Workstation Pro)
- **Ubuntu Server 22.04 LTS ISO** (environ 1.5 GB)
- **Minimum 10 GB RAM** disponible sur l'hôte
- **20 GB d'espace disque** par VM

### Connaissances recommandées

- Bases Linux (ligne de commande)
- Notions de virtualisation
- Concepts Docker de base

## 🚀 Installation rapide

### 1. Configuration VMware

```bash
# Créer le réseau vmnet2 dans VMware
# Edit → Virtual Network Editor → Add Network
# Type: NAT
# Subnet: 192.168.100.0/24
# Gateway: 192.168.100.1
```

### 2. Création des VMs

Créer 3 VMs identiques avec :
- OS : Ubuntu Server 22.04 LTS
- RAM : 4 GB (manager), 3 GB (workers)
- CPU : 2 vCPU
- Disque : 20 GB
- Réseau : Custom (vmnet2)

### 3. Installation automatisée

Sur chaque VM après installation d'Ubuntu :

```bash
# Télécharger le script d'installation
curl -fsSL https://raw.githubusercontent.com/devillesamuel-dot/docker-swarm-lab/main/scripts/install-docker.sh -o install-docker.sh

# Rendre exécutable et lancer
chmod +x install-docker.sh
./install-docker.sh
```

### 4. Configuration réseau

**Sur le Manager (192.168.100.10) :**
```bash
sudo cp configs/netplan-manager.yaml /etc/netplan/00-installer-config.yaml
sudo netplan apply
```

**Sur Worker 1 (192.168.100.11) :**
```bash
sudo cp configs/netplan-worker1.yaml /etc/netplan/00-installer-config.yaml
sudo netplan apply
```

**Sur Worker 2 (192.168.100.12) :**
```bash
sudo cp configs/netplan-worker2.yaml /etc/netplan/00-installer-config.yaml
sudo netplan apply
```

### 5. Initialisation du Swarm

**Sur le Manager :**
```bash
docker swarm init --advertise-addr 192.168.100.10
```

Copier la commande `docker swarm join` affichée.

**Sur Worker 1 et Worker 2 :**
```bash
# Coller la commande copiée, exemple :
docker swarm join --token SWMTKN-1-xxxxx 192.168.100.10:2377
```

### 6. Vérification

**Sur le Manager :**
```bash
docker node ls
```

Vous devriez voir :
```
ID                            HOSTNAME           STATUS    AVAILABILITY   MANAGER STATUS
xxx *                         swarm-manager      Ready     Active         Leader
yyy                           swarm-worker1      Ready     Active        
zzz                           swarm-worker2      Ready     Active        
```

## 📚 Documentation détaillée

Pour une installation pas à pas avec explications, consultez :

1. [Configuration de l'infrastructure](docs/01-infrastructure-setup.md)
2. [Configuration réseau](docs/02-network-configuration.md)
3. [Installation de Docker](docs/03-docker-installation.md)
4. [Initialisation du Swarm](docs/04-swarm-initialization.md)
5. [Déploiement de services](docs/05-service-deployment.md)

## ✅ Tests et validation

### Test 1 : Déploiement d'un service simple

```bash
# Créer un service nginx avec 3 réplicas
docker service create --name web --replicas 3 -p 8080:80 nginx

# Vérifier le déploiement
docker service ls
docker service ps web

# Accéder au service
curl http://192.168.100.10:8080
```

### Test 2 : Interface de visualisation

```bash
# Déployer le visualizer
docker service create \
  --name viz \
  --publish 8081:8080 \
  --constraint node.role==manager \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  dockersamples/visualizer

# Accéder à l'interface web
# http://192.168.100.10:8081
```

### Test 3 : Scaling

```bash
# Augmenter le nombre de réplicas
docker service scale web=6

# Observer la distribution
docker service ps web

# Réduire
docker service scale web=2
```

### Test 4 : Haute disponibilité

```bash
# Noter les nœuds où tournent les containers
docker service ps web

# Éteindre un worker (depuis VMware)
# Observer la migration automatique
docker service ps web

# Rallumer le worker
# Forcer le rééquilibrage
docker service update --force web
```

### Test 5 : Stack complète

```bash
# Déployer une stack depuis un fichier YAML
docker stack deploy -c configs/stack-example.yml demo

# Vérifier
docker stack services demo
docker stack ps demo

# Supprimer
docker stack rm demo
```

## 🔧 Troubleshooting

### Problème : Impossible de ping 8.8.8.8

**Symptôme :** La VM ne peut pas accéder à Internet

**Solution :**
```bash
# Vérifier les DNS
cat /etc/resolv.conf

# Forcer les DNS Google
sudo nano /etc/systemd/resolved.conf
# Ajouter : DNS=8.8.8.8 8.8.4.4

sudo systemctl restart systemd-resolved
```

### Problème : Interface réseau DOWN

**Symptôme :** `ip a` montre l'interface ens33 en état DOWN

**Solution :**
```bash
sudo ip link set ens33 down
sudo ip link set ens33 up
sudo netplan apply
```

### Problème : "No such image: nginx:latest"

**Symptôme :** Les workers ne peuvent pas télécharger les images

**Solutions possibles :**

1. **Vérifier la connectivité :**
```bash
ping registry-1.docker.io
docker pull nginx:latest
```

2. **Problème de filtre DNS (AdGuard, Pi-hole, etc.) :**
   - Désactiver temporairement le filtrage DNS
   - Ou ajouter `get.docker.com` et `registry-1.docker.io` à la whitelist

3. **Problème de DNS :**
```bash
# Forcer les DNS dans Docker
sudo mkdir -p /etc/docker
sudo nano /etc/docker/daemon.json
```
Ajouter :
```json
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
```
```bash
sudo systemctl restart docker
```

### Problème : Worker ne rejoint pas le Swarm

**Symptôme :** Erreur lors du `docker swarm join`

**Solution :**
```bash
# Sur le manager, régénérer le token
docker swarm join-token worker

# Copier la nouvelle commande et l'exécuter sur le worker
```

### Problème : Container ne démarre pas après reboot

**Symptôme :** Services en état "Pending" ou "Starting"

**Solution :**
```bash
# Vérifier l'état de Docker
sudo systemctl status docker

# Redémarrer Docker si nécessaire
sudo systemctl restart docker

# Vérifier l'état du Swarm
docker node ls
```

## 📝 Commandes utiles

### Gestion du cluster

```bash
# Lister les nœuds
docker node ls

# Inspecter un nœud
docker node inspect swarm-worker1

# Promouvoir un worker en manager
docker node promote swarm-worker1

# Rétrograder un manager en worker
docker node demote swarm-worker1

# Drainer un nœud (maintenance)
docker node update --availability drain swarm-worker1

# Réactiver un nœud
docker node update --availability active swarm-worker1

# Supprimer un nœud (doit être down)
docker node rm swarm-worker1
```

### Gestion des services

```bash
# Créer un service
docker service create --name mon-service nginx

# Lister les services
docker service ls

# Inspecter un service
docker service inspect mon-service

# Voir les logs
docker service logs mon-service

# Scaler un service
docker service scale mon-service=5

# Mettre à jour un service
docker service update --image nginx:alpine mon-service

# Supprimer un service
docker service rm mon-service

# Lister les tâches d'un service
docker service ps mon-service
```

### Gestion des stacks

```bash
# Déployer une stack
docker stack deploy -c stack.yml ma-stack

# Lister les stacks
docker stack ls

# Lister les services d'une stack
docker stack services ma-stack

# Lister les tâches d'une stack
docker stack ps ma-stack

# Supprimer une stack
docker stack rm ma-stack
```

### Gestion des réseaux

```bash
# Lister les réseaux
docker network ls

# Créer un réseau overlay
docker network create --driver overlay mon-reseau

# Inspecter un réseau
docker network inspect mon-reseau

# Supprimer un réseau
docker network rm mon-reseau
```

### Diagnostic

```bash
# État global du Swarm
docker info

# Événements en temps réel
docker events

# Logs système Docker
sudo journalctl -u docker -f

# Statistiques des containers
docker stats
```

## 🚀 Évolutions possibles

### 1. Monitoring avec Prometheus + Grafana

```yaml
# Ajouter à votre stack
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
```

### 2. Logging centralisé avec ELK Stack

- Elasticsearch : Stockage des logs
- Logstash : Collecte et transformation
- Kibana : Visualisation

### 3. Registre Docker privé

```bash
# Déployer un registry local
docker service create \
  --name registry \
  --publish 5000:5000 \
  registry:2
```

### 4. Secrets management

```bash
# Créer un secret
echo "mon_mot_de_passe" | docker secret create db_password -

# Utiliser dans un service
docker service create \
  --name db \
  --secret db_password \
  mysql
```

### 5. Intégration CI/CD

- Jenkins pour l'automatisation
- GitLab CI/CD
- GitHub Actions

### 6. Simulation d'architecture Teamcenter

Créer une stack simulant l'architecture 4-tiers de Teamcenter :
- Pool Manager
- Server Manager
- Dispatcher
- FSC/FMS
- Gateway services

### 7. Réseau multi-datacenter

Expérimenter avec plusieurs Swarms connectés pour simulation de DR (Disaster Recovery).

## 📖 Ressources

### Documentation officielle

- [Docker Swarm Documentation](https://docs.docker.com/engine/swarm/)
- [Docker Service Documentation](https://docs.docker.com/engine/swarm/services/)
- [Docker Stack Documentation](https://docs.docker.com/engine/swarm/stack-deploy/)

### Tutoriels recommandés

- [Docker Swarm Tutorial - Docker Labs](https://github.com/docker/labs/tree/master/swarm-mode)
- [Play with Docker](https://labs.play-with-docker.com/) - Environnement en ligne

### Communauté

- [Docker Community Slack](https://dockercommunity.slack.com)
- [Stack Overflow - Docker Swarm](https://stackoverflow.com/questions/tagged/docker-swarm)

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🤝 Contributions

Les contributions sont les bienvenues ! N'hésitez pas à :
- Ouvrir une issue pour signaler un bug
- Proposer des améliorations via Pull Request
- Partager vos retours d'expérience

## ✍️ Auteur

**Deville Samuel** - IT systèmes réseaux en recherche d'emploi agglomération Grenoble   

⭐ Si ce projet vous a été utile, n'hésitez pas à lui donner une étoile sur GitHub !
