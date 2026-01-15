# 🚀 Guide de Démarrage Rapide - Docker Swarm Lab

## En 5 minutes

### 1️⃣ Prérequis
- VMware Workstation installé
- ISO Ubuntu Server 22.04 téléchargé
- 10 GB RAM disponible

### 2️⃣ Configuration VMware
```bash
# Dans VMware → Edit → Virtual Network Editor
# Créer vmnet2 (NAT) : 192.168.100.0/24
# Gateway : 192.168.100.1
```

### 3️⃣ Créer les VMs

**Manager :** 4 GB RAM, 2 CPU, IP: 192.168.100.10  
**Worker1 :** 3 GB RAM, 2 CPU, IP: 192.168.100.11  
**Worker2 :** 3 GB RAM, 2 CPU, IP: 192.168.100.12

### 4️⃣ Configuration réseau (sur chaque VM)

**Manager :**
```bash
sudo nano /etc/netplan/00-installer-config.yaml
```
Copier le contenu de `configs/netplan-manager.yaml`

**Workers :**
Même chose avec `netplan-worker1.yaml` et `netplan-worker2.yaml`

Puis sur chaque VM :
```bash
sudo netplan apply
ping 8.8.8.8  # Vérifier internet
```

### 5️⃣ Installer Docker (sur chaque VM)

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
exit  # Se reconnecter
```

### 6️⃣ Initialiser le Swarm

**Sur le Manager :**
```bash
docker swarm init --advertise-addr 192.168.100.10
# Copier la commande join affichée
```

**Sur Worker1 et Worker2 :**
```bash
# Coller la commande join copiée
docker swarm join --token SWMTKN-xxx 192.168.100.10:2377
```

### 7️⃣ Vérifier

**Sur le Manager :**
```bash
docker node ls
```

Vous devriez voir 3 nœuds : 1 manager + 2 workers ✅

### 8️⃣ Premier déploiement

```bash
# Service web
docker service create --name web --replicas 3 -p 8080:80 nginx

# Visualizer
docker service create \
  --name viz \
  --publish 8081:8080 \
  --constraint node.role==manager \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  dockersamples/visualizer
```

### 9️⃣ Accéder aux services

**Web :** http://192.168.100.10:8080  
**Visualizer :** http://192.168.100.10:8081

### 🎉 C'est terminé !

Votre cluster Swarm est opérationnel. Consultez le [README complet](README.md) pour aller plus loin.

---

## 🆘 Problèmes courants

**Pas d'internet dans les VMs ?**
```bash
sudo ip link set ens33 down
sudo ip link set ens33 up
sudo netplan apply
```

**Docker ne télécharge pas les images ?**
→ Vérifier AdGuard/filtrage DNS ou utiliser :
```bash
sudo nano /etc/docker/daemon.json
# Ajouter : {"dns": ["8.8.8.8", "8.8.4.4"]}
sudo systemctl restart docker
```

**Token perdu ?**
```bash
# Sur le manager
docker swarm join-token worker
```

---

📚 **Documentation complète :** Voir le dossier `docs/` pour les guides détaillés.
