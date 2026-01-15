# 01 - Configuration de l'Infrastructure VMware

## Objectif

Créer l'environnement de virtualisation pour héberger les 3 machines virtuelles du cluster Docker Swarm.

## Prérequis

- VMware Workstation 15+ ou VMware Workstation Pro
- Ubuntu Server 22.04 LTS ISO (téléchargeable depuis [ubuntu.com](https://ubuntu.com/download/server))
- 10 GB RAM disponible minimum
- 60 GB d'espace disque disponible

## Étape 1 : Configuration du réseau virtuel vmnet2

### 1.1 Ouvrir l'éditeur de réseau virtuel

1. Ouvrir VMware Workstation
2. Menu **Edit** → **Virtual Network Editor**
3. Cliquer sur **Change Settings** (droits administrateur requis)

### 1.2 Créer le réseau vmnet2

1. Cliquer sur **Add Network...**
2. Sélectionner **vmnet2**
3. Type : **NAT**
4. Configuration :
   - **Subnet IP** : `192.168.100.0`
   - **Subnet mask** : `255.255.255.0` (ou /24)

### 1.3 Configurer le NAT

1. Sélectionner vmnet2 dans la liste
2. Cliquer sur **NAT Settings...**
3. Vérifier/modifier :
   - **Gateway IP** : `192.168.100.1`
   - Laisser les autres paramètres par défaut
4. Cliquer **OK**

### 1.4 Options recommandées

- ✅ **Connect a host virtual adapter to this network** : COCHÉ
- ❌ **Use local DHCP service** : DÉCOCHÉ (nous utilisons des IPs statiques)

### 1.5 Validation

1. Cliquer **Apply** puis **OK**
2. Sur l'hôte Linux, vérifier que vmnet2 existe :
   ```bash
   ip a | grep vmnet2
   ```
   Devrait afficher une interface avec l'IP 192.168.100.1

## Étape 2 : Création des machines virtuelles

### 2.1 Spécifications des VMs

| VM            | Hostname       | IP             | RAM   | CPU  | Disque |
|---------------|----------------|----------------|-------|------|--------|
| Manager       | swarm-manager  | 192.168.100.10 | 4 GB  | 2    | 20 GB  |
| Worker 1      | swarm-worker1  | 192.168.100.11 | 3 GB  | 2    | 20 GB  |
| Worker 2      | swarm-worker2  | 192.168.100.12 | 3 GB  | 2    | 20 GB  |

### 2.2 Créer la première VM (Manager)

1. **Fichier** → **New Virtual Machine**
2. Sélectionner **Typical**
3. **Installer disc image file (iso)** : Sélectionner l'ISO Ubuntu Server 22.04
4. Configuration facile Ubuntu :
   - **Full name** : Samuel (ou votre nom)
   - **Username** : samuel
   - **Password** : [votre mot de passe]
5. **Virtual machine name** : swarm-manager
6. **Location** : Choisir un emplacement avec suffisamment d'espace
7. **Maximum disk size** : 20 GB
   - Sélectionner **Store virtual disk as a single file**
8. **Customize Hardware** :
   - **Memory** : 4096 MB (4 GB)
   - **Processors** : 2
   - **Network Adapter** : Custom (vmnet2)
   - **CD/DVD** : ISO Ubuntu Server
9. Cliquer **Finish**

### 2.3 Installer Ubuntu sur la première VM

1. Démarrer la VM
2. Suivre l'installation Ubuntu :
   - **Langue** : Français ou English
   - **Keyboard** : Français ou approprié
   - **Type d'installation** : Ubuntu Server
   - **Configuration réseau** : Ignorer pour l'instant (sera configuré plus tard)
   - **Proxy** : Laisser vide
   - **Mirror** : Par défaut
   - **Stockage** : Utiliser tout le disque
   - **Profil** :
     - Name : Samuel
     - Server name : **swarm-manager**
     - Username : samuel
     - Password : [votre mot de passe]
   - **SSH** : ✅ **Install OpenSSH server** (IMPORTANT)
   - **Snaps** : Aucun nécessaire
3. Attendre la fin de l'installation
4. **Reboot** quand demandé

### 2.4 Cloner pour créer Worker 1 et Worker 2

**Méthode rapide avec clonage :**

1. Éteindre swarm-manager proprement :
   ```bash
   sudo shutdown now
   ```

2. Dans VMware, clic droit sur swarm-manager → **Manage** → **Clone**
3. Suivre l'assistant :
   - **Clone from** : Current state
   - **Clone type** : Full clone
   - **Name** : swarm-worker1
4. Répéter pour créer swarm-worker2

5. **Modifier les ressources** :
   - Pour worker1 et worker2 :
     - **Memory** : 3072 MB (3 GB)
     - **Processors** : 2 (inchangé)
     - **Network** : Custom (vmnet2) - vérifier

### 2.5 Changer les hostnames des workers

**Sur swarm-worker1 :**
```bash
sudo hostnamectl set-hostname swarm-worker1
sudo nano /etc/hosts
# Modifier la ligne 127.0.1.1 pour mettre swarm-worker1
sudo reboot
```

**Sur swarm-worker2 :**
```bash
sudo hostnamectl set-hostname swarm-worker2
sudo nano /etc/hosts
# Modifier la ligne 127.0.1.1 pour mettre swarm-worker2
sudo reboot
```

## Étape 3 : Validation

### 3.1 Vérifier les VMs

Sur l'hôte VMware, toutes les VMs doivent être visibles et démarrables.

### 3.2 Connexion SSH

Depuis l'hôte, tester la connexion (après configuration réseau) :
```bash
ssh samuel@192.168.100.10  # manager
ssh samuel@192.168.100.11  # worker1
ssh samuel@192.168.100.12  # worker2
```

## Étape 4 : Optimisations (optionnel)

### 4.1 Snapshots

Créer un snapshot de chaque VM après installation de base :
- VMware → VM → Snapshot → Take Snapshot
- Nom : "Fresh Ubuntu Install"

Cela permet de revenir facilement à un état propre.

### 4.2 VMware Tools

Les VMware Tools open-vm-tools sont installés automatiquement avec Ubuntu Server 22.04.

Vérifier :
```bash
systemctl status open-vm-tools
```

Si absent :
```bash
sudo apt install open-vm-tools
```

## Problèmes courants

### La VM ne démarre pas

- Vérifier que la virtualisation est activée dans le BIOS
- Vérifier l'espace disque disponible
- Vérifier les logs VMware

### Impossible de créer vmnet2

- Redémarrer VMware en tant qu'administrateur
- Sur Linux : vérifier les permissions et modules kernel

### Clone ne fonctionne pas

- Créer manuellement les 2 autres VMs avec les mêmes paramètres
- Simplement changer le nom et refaire l'installation

## Prochaine étape

→ [02 - Configuration réseau](02-network-configuration.md)
