# Structure du Projet Docker Swarm Lab

## Vue d'ensemble

```
docker-swarm-lab/
├── README.md                          # Documentation principale du projet
├── QUICKSTART.md                      # Guide de démarrage rapide (5 minutes)
├── CHEATSHEET.md                      # Antisèche des commandes Docker Swarm
├── CONTRIBUTING.md                    # Guide pour contribuer au projet
├── LICENSE                            # Licence MIT
├── .gitignore                         # Fichiers à ignorer par Git
│
├── docs/                              # Documentation détaillée
│   ├── 01-infrastructure-setup.md     # Configuration VMware et création des VMs
│   ├── 02-network-configuration.md    # Configuration réseau avec Netplan
│   ├── 03-docker-installation.md      # Installation de Docker
│   ├── 04-swarm-initialization.md     # Initialisation du cluster Swarm
│   └── 05-service-deployment.md       # Déploiement et gestion des services
│
├── configs/                           # Fichiers de configuration
│   ├── netplan-manager.yaml           # Config réseau pour le manager
│   ├── netplan-worker1.yaml           # Config réseau pour worker1
│   ├── netplan-worker2.yaml           # Config réseau pour worker2
│   └── stack-example.yml              # Exemple de stack Docker Compose
│
├── scripts/                           # Scripts d'automatisation
│   ├── install-docker.sh              # Installation automatique de Docker
│   ├── init-swarm.sh                  # Initialisation du Swarm
│   └── init-git-repo.sh               # Initialisation du dépôt Git
│
└── screenshots/                       # Captures d'écran du lab
    └── README.md                      # Guide pour ajouter des screenshots
```

## Description des fichiers

### 📖 Documentation

| Fichier | Description | Taille |
|---------|-------------|--------|
| `README.md` | Documentation principale avec installation complète | ~45 KB |
| `QUICKSTART.md` | Guide rapide pour démarrer en 5 minutes | ~3 KB |
| `CHEATSHEET.md` | Référence rapide des commandes Swarm | ~7 KB |
| `CONTRIBUTING.md` | Guide pour contribuer au projet | ~6 KB |

### 📚 Documentation détaillée (`docs/`)

| Fichier | Sujet | Contenu |
|---------|-------|---------|
| `01-infrastructure-setup.md` | Infrastructure | VMware, création des VMs, clonage |
| `02-network-configuration.md` | Réseau | Netplan, IPs statiques, DNS, troubleshooting |
| `03-docker-installation.md` | Docker | Installation, configuration, vérification |
| `04-swarm-initialization.md` | Swarm | Init manager, ajout workers, concepts clés |
| `05-service-deployment.md` | Services | Déploiement, scaling, HA, stacks, monitoring |

### ⚙️ Configurations (`configs/`)

| Fichier | Usage | IP |
|---------|-------|-----|
| `netplan-manager.yaml` | Configuration réseau du manager | 192.168.100.10 |
| `netplan-worker1.yaml` | Configuration réseau du worker1 | 192.168.100.11 |
| `netplan-worker2.yaml` | Configuration réseau du worker2 | 192.168.100.12 |
| `stack-example.yml` | Stack complète (web + DB + visualizer) | - |

### 🔧 Scripts (`scripts/`)

| Script | Fonction | Plateforme |
|--------|----------|------------|
| `install-docker.sh` | Installe Docker automatiquement | Ubuntu 22.04 |
| `init-swarm.sh` | Aide à l'initialisation du Swarm | Manager & Workers |
| `init-git-repo.sh` | Configure Git et GitHub | Développement |

## Utilisation rapide

### 1. Cloner le projet

```bash
git clone https://github.com/devillesamuel-dot/docker-swarm-lab.git
cd docker-swarm-lab
```

### 2. Suivre le QUICKSTART

```bash
cat QUICKSTART.md
```

### 3. Ou suivre la documentation complète

```bash
# Lire dans l'ordre
cat docs/01-infrastructure-setup.md
cat docs/02-network-configuration.md
cat docs/03-docker-installation.md
cat docs/04-swarm-initialization.md
cat docs/05-service-deployment.md
```

### 4. Utiliser les scripts

```bash
# Sur chaque VM après installation Ubuntu
./scripts/install-docker.sh

# Pour initialiser le Swarm
./scripts/init-swarm.sh manager           # Sur le manager
./scripts/init-swarm.sh worker <ip> <token>  # Sur les workers
```

### 5. Consulter la cheat sheet

```bash
cat CHEATSHEET.md | less
```

## Tailles des fichiers

```
Total du projet : ~150 KB (sans screenshots)

Documentation : ~75 KB
- README.md : 45 KB
- docs/ : 25 KB
- Autres .md : 5 KB

Scripts : ~10 KB
Configs : ~2 KB
```

## Compatibilité

| Composant | Version testée | Versions compatibles |
|-----------|---------------|---------------------|
| Ubuntu Server | 22.04 LTS | 20.04+, 22.04+ |
| Docker | 24.0.x | 20.10+, 23.x, 24.x |
| VMware Workstation | Pro 17 | 15+, 16+, 17+ |
| Docker Swarm | Intégré | Docker 17.03+ |

## Prérequis système

### Machine hôte

- **OS** : Linux (Ubuntu Desktop recommandé), Windows, macOS
- **RAM** : 10 GB disponible minimum, 16 GB recommandé
- **CPU** : 4 cœurs minimum, 8 cœurs recommandé
- **Disque** : 60 GB disponible

### Connaissances

- ✅ Bases Linux (ligne de commande)
- ✅ Notions de virtualisation
- ✅ Concepts Docker de base
- ⚠️ Pas besoin d'être expert en réseau ou Docker Swarm

## Évolutions futures

- [ ] Support VirtualBox et KVM
- [ ] Scripts de monitoring (Prometheus + Grafana)
- [ ] Stack de logging (ELK)
- [ ] Simulation architecture Teamcenter
- [ ] CI/CD avec Jenkins/GitLab
- [ ] Multi-datacenter simulation
- [ ] Traductions (EN, ES)

## Contribuer

Voir [CONTRIBUTING.md](CONTRIBUTING.md) pour savoir comment contribuer au projet.

## Licence

MIT License - Voir [LICENSE](LICENSE)

## Auteur

**Deville Samuel** - IT systèmes et réseaux

---

📅 Dernière mise à jour : Janvier 2025  
⭐ N'oubliez pas de star le projet sur GitHub si vous le trouvez utile !
