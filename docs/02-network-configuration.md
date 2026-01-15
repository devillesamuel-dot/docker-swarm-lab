# 02 - Configuration Réseau avec Netplan

## Objectif

Configurer des adresses IP statiques sur les 3 VMs pour assurer une connectivité stable dans le cluster Swarm.

## Architecture réseau

```
192.168.100.0/24 (vmnet2 - NAT)
│
├─ 192.168.100.1    : Gateway VMware (NAT)
├─ 192.168.100.10   : swarm-manager
├─ 192.168.100.11   : swarm-worker1
└─ 192.168.100.12   : swarm-worker2
```

## Étape 1 : Comprendre Netplan

Ubuntu Server 22.04 utilise **Netplan** pour la configuration réseau. Les fichiers de config sont en YAML dans `/etc/netplan/`.

### 1.1 Identifier l'interface réseau

Sur chaque VM :
```bash
ip a
```

L'interface principale est généralement **ens33** (peut varier selon la version de VMware).

## Étape 2 : Configuration du Manager

### 2.1 Éditer la configuration Netplan

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

### 2.2 Contenu du fichier

```yaml
network:
  version: 2
  ethernets:
    ens33:
      addresses:
        - 192.168.100.10/24
      routes:
        - to: default
          via: 192.168.100.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

**Points importants :**
- **Indentation** : 2 espaces (pas de tabulations)
- **addresses** : IP du manager avec le masque /24
- **routes** : Route par défaut vers la gateway VMware
- **nameservers** : DNS Google (8.8.8.8 et 8.8.4.4)

### 2.3 Appliquer la configuration

```bash
# Tester la configuration (sans l'appliquer)
sudo netplan try

# Si OK, appliquer définitivement
sudo netplan apply
```

### 2.4 Validation

```bash
# Vérifier l'IP
ip a

# Tester la gateway
ping 192.168.100.1

# Tester Internet
ping 8.8.8.8
ping google.com
```

## Étape 3 : Configuration Worker 1

Sur swarm-worker1, même procédure avec l'IP **192.168.100.11** :

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

```yaml
network:
  version: 2
  ethernets:
    ens33:
      addresses:
        - 192.168.100.11/24
      routes:
        - to: default
          via: 192.168.100.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

Appliquer :
```bash
sudo netplan apply
```

## Étape 4 : Configuration Worker 2

Sur swarm-worker2, même procédure avec l'IP **192.168.100.12** :

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

```yaml
network:
  version: 2
  ethernets:
    ens33:
      addresses:
        - 192.168.100.12/24
      routes:
        - to: default
          via: 192.168.100.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

Appliquer :
```bash
sudo netplan apply
```

## Étape 5 : Tests de connectivité inter-VMs

### 5.1 Depuis le manager

```bash
ping 192.168.100.11  # worker1
ping 192.168.100.12  # worker2
```

### 5.2 Depuis worker1

```bash
ping 192.168.100.10  # manager
ping 192.168.100.12  # worker2
```

### 5.3 Depuis worker2

```bash
ping 192.168.100.10  # manager
ping 192.168.100.11  # worker1
```

Toutes les VMs doivent pouvoir se pinger mutuellement.

## Étape 6 : Configuration SSH (optionnel mais recommandé)

### 6.1 Générer des clés SSH sur l'hôte

Sur votre machine hôte (Ubuntu Desktop) :
```bash
ssh-keygen -t ed25519 -C "swarm-lab"
```

### 6.2 Copier la clé publique vers les VMs

```bash
ssh-copy-id samuel@192.168.100.10
ssh-copy-id samuel@192.168.100.11
ssh-copy-id samuel@192.168.100.12
```

### 6.3 Test de connexion sans mot de passe

```bash
ssh samuel@192.168.100.10
```

Vous devriez vous connecter sans entrer de mot de passe.

### 6.4 Créer des alias SSH (optionnel)

Sur l'hôte, éditer `~/.ssh/config` :
```bash
nano ~/.ssh/config
```

Contenu :
```
Host manager
    HostName 192.168.100.10
    User samuel

Host worker1
    HostName 192.168.100.11
    User samuel

Host worker2
    HostName 192.168.100.12
    User samuel
```

Puis connexion simplifiée :
```bash
ssh manager
ssh worker1
ssh worker2
```

## Problèmes courants

### Interface réseau DOWN après netplan apply

**Symptôme :**
```bash
2: ens33: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
```

**Solution :**
```bash
sudo ip link set ens33 down
sudo ip link set ens33 up
sudo netplan apply
```

### Pas d'accès Internet (ping 8.8.8.8 échoue)

**Causes possibles :**

1. **Gateway incorrecte**
   ```bash
   # Vérifier la route par défaut
   ip route
   # Devrait montrer : default via 192.168.100.1 dev ens33
   ```

2. **Problème de NAT VMware**
   - Sur l'hôte Linux :
   ```bash
   sudo systemctl restart vmware-networks.service
   ```

3. **Filtrage DNS (AdGuard, Pi-hole)**
   - Désactiver temporairement le filtrage DNS
   - Ou utiliser d'autres DNS (1.1.1.1, Cloudflare)

4. **Firewall sur l'hôte**
   ```bash
   # Vérifier les règles iptables
   sudo iptables -L -n -v
   ```

### Erreur "ovsdb-server.service is not running"

**Nature :** Avertissement, pas une erreur critique

**Explication :** Open vSwitch n'est pas installé (et n'est pas nécessaire)

**Action :** Ignorer ce message

### Nom d'interface différent de ens33

Si votre interface s'appelle différemment (ex: enp0s3, eth0), adaptez la configuration :

```yaml
network:
  version: 2
  ethernets:
    enp0s3:  # Remplacer par le bon nom
      addresses:
        - 192.168.100.10/24
      # ...
```

### DNS ne fonctionnent pas (ping google.com échoue)

**Vérifier /etc/resolv.conf :**
```bash
cat /etc/resolv.conf
```

Devrait contenir :
```
nameserver 8.8.8.8
nameserver 8.8.4.4
```

**Si vide ou incorrect :**
```bash
sudo nano /etc/systemd/resolved.conf
```

Ajouter :
```
[Resolve]
DNS=8.8.8.8 8.8.4.4
```

Puis :
```bash
sudo systemctl restart systemd-resolved
```

## Commandes utiles

### Diagnostic réseau

```bash
# Afficher toutes les interfaces
ip a

# Afficher les routes
ip route

# Afficher les DNS
systemd-resolve --status

# Tester un port spécifique
nc -zv 192.168.100.10 22

# Tracer le chemin réseau
traceroute 8.8.8.8

# Statistiques réseau
ifconfig ens33  # ou ip -s link show ens33
```

### Gestion Netplan

```bash
# Générer la configuration
sudo netplan generate

# Tester (60 secondes pour valider)
sudo netplan try

# Appliquer la configuration
sudo netplan apply

# Debug (affiche la config générée)
sudo netplan --debug apply
```

## Validation finale

Avant de passer à l'étape suivante, vérifier :

✅ Les 3 VMs ont des IPs statiques configurées  
✅ Chaque VM peut pinger les deux autres  
✅ Chaque VM peut accéder à Internet (ping 8.8.8.8)  
✅ La résolution DNS fonctionne (ping google.com)  
✅ SSH fonctionne depuis l'hôte vers les 3 VMs  

## Prochaine étape

→ [03 - Installation de Docker](03-docker-installation.md)
