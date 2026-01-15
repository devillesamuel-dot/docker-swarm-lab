# 04 - Initialisation du Cluster Docker Swarm

## Objectif

Initialiser le cluster Docker Swarm en définissant un nœud manager et en ajoutant les workers.

## Architecture du Swarm

```
┌─────────────────────────────────────────────────────┐
│              Docker Swarm Cluster                   │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Manager Node (192.168.100.10)                      │
│  ├─ Orchestration                                   │
│  ├─ Scheduling                                      │
│  ├─ Cluster state (Raft consensus)                  │
│  └─ API endpoints                                   │
│                                                     │
│  Worker Node 1 (192.168.100.11)                     │
│  └─ Execute tasks                                   │
│                                                     │
│  Worker Node 2 (192.168.100.12)                     │
│  └─ Execute tasks                                   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Étape 1 : Initialisation du Manager

### 1.1 Sur swarm-manager (192.168.100.10)

```bash
docker swarm init --advertise-addr 192.168.100.10
```

**Explication des paramètres :**
- `swarm init` : Initialise un nouveau cluster Swarm
- `--advertise-addr` : IP que les autres nœuds utiliseront pour joindre le cluster

### 1.2 Sortie attendue

```
Swarm initialized: current node (abc123xyz) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-yyyyyyyyyyyyyyyyyyyy 192.168.100.10:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

### 1.3 Points importants

- Le **token** généré est unique et sert d'authentification
- Le port **2377** est le port de management du Swarm
- Ce token doit être gardé **confidentiel** en production
- La commande complète doit être copiée pour les workers

### 1.4 Vérification

```bash
docker node ls
```

Sortie attendue :
```
ID                            HOSTNAME           STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
abc123xyz *                   swarm-manager      Ready     Active         Leader           24.0.x
```

L'astérisque (*) indique le nœud actuel.

## Étape 2 : Ajouter les Workers

### 2.1 Récupérer le token (si perdu)

Si vous n'avez pas copié la commande, sur le manager :

```bash
docker swarm join-token worker
```

Cela affiche à nouveau la commande complète avec le token.

### 2.2 Sur swarm-worker1 (192.168.100.11)

Coller la commande récupérée, par exemple :

```bash
docker swarm join --token SWMTKN-1-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-yyyyyyyyyyyyyyyyyyyy 192.168.100.10:2377
```

Sortie attendue :
```
This node joined a swarm as a worker.
```

### 2.3 Sur swarm-worker2 (192.168.100.12)

Même commande :

```bash
docker swarm join --token SWMTKN-1-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-yyyyyyyyyyyyyyyyyyyy 192.168.100.10:2377
```

## Étape 3 : Vérification du cluster

### 3.1 Liste des nœuds

Sur le **manager** :

```bash
docker node ls
```

Sortie attendue :
```
ID                            HOSTNAME           STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
abc123xyz *                   swarm-manager      Ready     Active         Leader           24.0.x
def456uvw                     swarm-worker1      Ready     Active                          24.0.x
ghi789rst                     swarm-worker2      Ready     Active                          24.0.x
```

**Vérifications :**
- ✅ 3 nœuds présents
- ✅ Tous en status "Ready"
- ✅ Tous en availability "Active"
- ✅ Un seul "Leader" (le manager)

### 3.2 Informations détaillées

```bash
# Information sur le cluster
docker info | grep -A 10 Swarm

# Inspecter un nœud spécifique
docker node inspect swarm-worker1
```

### 3.3 État du Swarm sur les workers

Sur un worker, la commande `docker node ls` ne fonctionne pas (réservée aux managers).

Pour vérifier qu'un worker est bien dans le Swarm :

```bash
docker info | grep Swarm
```

Devrait afficher :
```
Swarm: active
  NodeID: def456uvw
  Is Manager: false
  Node Address: 192.168.100.11
```

## Étape 4 : Configuration avancée (optionnel)

### 4.1 Labels sur les nœuds

Ajouter des labels pour le placement futur de services :

```bash
# Sur le manager
docker node update --label-add environment=production swarm-manager
docker node update --label-add environment=production swarm-worker1
docker node update --label-add environment=production swarm-worker2

# Ajouter un rôle spécifique
docker node update --label-add role=frontend swarm-worker1
docker node update --label-add role=backend swarm-worker2
```

Vérifier :
```bash
docker node inspect swarm-worker1 | grep -A 5 Labels
```

### 4.2 Promotion/Rétrogradation

**Promouvoir un worker en manager (haute disponibilité) :**

```bash
docker node promote swarm-worker1
```

**Rétrograder un manager en worker :**

```bash
docker node demote swarm-worker1
```

> **Note :** Pour un cluster de production, il est recommandé d'avoir 3 ou 5 managers (nombre impair) pour la haute disponibilité du plan de contrôle.

### 4.3 Disponibilité des nœuds

**Drainer un nœud (maintenance) :**

```bash
# Les conteneurs seront migrés vers d'autres nœuds
docker node update --availability drain swarm-worker1
```

**Réactiver un nœud :**

```bash
docker node update --availability active swarm-worker1
```

## Étape 5 : Premier test de déploiement

### 5.1 Déployer un service simple

```bash
# Sur le manager
docker service create --name test-web --replicas 3 -p 8080:80 nginx:alpine
```

### 5.2 Vérifier le déploiement

```bash
# Liste des services
docker service ls

# Détails du service
docker service ps test-web
```

Vous devriez voir 3 réplicas distribués sur les différents nœuds.

### 5.3 Tester l'accès

Depuis votre machine hôte ou n'importe quel nœud :

```bash
curl http://192.168.100.10:8080
curl http://192.168.100.11:8080
curl http://192.168.100.12:8080
```

Les 3 IPs devraient fonctionner grâce au **routing mesh** de Swarm.

### 5.4 Nettoyer

```bash
docker service rm test-web
```

## Problèmes courants

### Erreur "Error response from daemon: This node is already part of a swarm"

**Cause :** Le nœud a déjà rejoint un Swarm (peut-être lors d'un test précédent)

**Solution :**

```bash
# Quitter le Swarm
docker swarm leave --force

# Puis réessayer l'initialisation ou le join
```

### Les workers ne peuvent pas joindre le manager

**Symptômes :**
```
Error response from daemon: rpc error: code = Unavailable desc = connection error
```

**Vérifications :**

1. **Connectivité réseau :**
   ```bash
   # Depuis un worker
   ping 192.168.100.10
   telnet 192.168.100.10 2377
   ```

2. **Firewall :**
   
   Swarm utilise ces ports :
   - **2377/tcp** : Cluster management
   - **7946/tcp** et **7946/udp** : Communication entre nœuds
   - **4789/udp** : Overlay network traffic

   Sur Ubuntu, ufw est généralement désactivé par défaut. Vérifier :
   ```bash
   sudo ufw status
   ```

   Si actif, autoriser :
   ```bash
   sudo ufw allow 2377/tcp
   sudo ufw allow 7946/tcp
   sudo ufw allow 7946/udp
   sudo ufw allow 4789/udp
   ```

3. **IP incorrecte :**
   
   Vérifier que l'IP du manager est correcte :
   ```bash
   # Sur le manager
   ip a | grep 192.168.100
   ```

### Token expiré ou invalide

**Symptôme :**
```
Error response from daemon: invalid join token
```

**Solution :**

Régénérer le token sur le manager :

```bash
docker swarm join-token --rotate worker
```

Puis utiliser le nouveau token.

### "docker node ls" ne fonctionne pas

**Cause :** Cette commande fonctionne uniquement sur les managers

**Solution :** 

Se connecter au manager pour exécuter cette commande.

## Concepts clés du Swarm

### Manager vs Worker

**Manager :**
- Gère l'état du cluster (via Raft consensus)
- Planifie l'exécution des services
- Maintient l'état souhaité
- Peut aussi exécuter des conteneurs (sauf si contraint)

**Worker :**
- Exécute les tâches assignées
- Rapporte son état au manager
- N'a pas accès aux commandes de gestion du cluster

### Haute disponibilité

Pour un cluster de production :
- **3 managers** : Tolère la perte de 1 manager
- **5 managers** : Tolère la perte de 2 managers
- **7 managers** : Tolère la perte de 3 managers

Toujours un nombre **impair** pour éviter les split-brain.

### Tokens

- **Token worker** : Pour ajouter des workers
- **Token manager** : Pour ajouter des managers (plus sensible)
- Peuvent être régénérés sans casser le cluster existant

### État du cluster

- Stocké dans une base de données Raft distribuée
- Répliquée sur tous les managers
- Sauvegardée automatiquement

## Commandes utiles

```bash
# Afficher les tokens
docker swarm join-token worker
docker swarm join-token manager

# Régénérer un token
docker swarm join-token --rotate worker

# Quitter le Swarm (worker)
docker swarm leave

# Quitter le Swarm (manager)
docker swarm leave --force

# Inspecter le Swarm
docker swarm ca
docker swarm unlock-key  # Si l'autolock est activé

# Mettre à jour le Swarm
docker swarm update --task-history-limit 10
```

## Validation finale

✅ Manager initialisé et fonctionnel  
✅ 2 workers ont rejoint le cluster  
✅ `docker node ls` affiche 3 nœuds Ready/Active  
✅ Un service test se déploie correctement sur les 3 nœuds  
✅ Le routing mesh fonctionne (accès via n'importe quelle IP)  

## Prochaine étape

→ [05 - Déploiement de services](05-service-deployment.md)
