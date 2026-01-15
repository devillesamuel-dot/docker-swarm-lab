#!/bin/bash

###############################################################################
# Script d'installation automatique de Docker et Docker Compose
# Compatible avec Ubuntu Server 22.04 LTS
# Usage: ./install-docker.sh
###############################################################################

set -e  # Arrêter en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERREUR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

# Vérifier que le script est exécuté en tant que root ou avec sudo
if [ "$EUID" -ne 0 ] && [ -z "$SUDO_USER" ]; then 
    print_error "Ce script doit être exécuté avec sudo ou en tant que root"
    exit 1
fi

print_message "=== Installation de Docker sur Ubuntu Server 22.04 ==="

# Mise à jour du système
print_message "Mise à jour des paquets système..."
apt update
apt upgrade -y

# Installation des prérequis
print_message "Installation des prérequis..."
apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Suppression des anciennes versions de Docker (si présentes)
print_message "Suppression des anciennes versions de Docker..."
apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Téléchargement et exécution du script officiel Docker
print_message "Téléchargement du script d'installation Docker..."
curl -fsSL https://get.docker.com -o /tmp/get-docker.sh

print_message "Installation de Docker..."
sh /tmp/get-docker.sh

# Nettoyage
rm /tmp/get-docker.sh

# Activation et démarrage de Docker
print_message "Activation du service Docker..."
systemctl enable docker
systemctl start docker

# Ajout de l'utilisateur au groupe docker
if [ -n "$SUDO_USER" ]; then
    print_message "Ajout de l'utilisateur $SUDO_USER au groupe docker..."
    usermod -aG docker $SUDO_USER
    print_warning "Déconnectez-vous et reconnectez-vous pour que les changements prennent effet"
else
    print_warning "Impossible de déterminer l'utilisateur. Ajoutez manuellement votre utilisateur au groupe docker:"
    print_warning "  sudo usermod -aG docker \$USER"
fi

# Configuration des DNS Docker (pour éviter les problèmes de résolution)
print_message "Configuration des DNS Docker..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "dns": ["8.8.8.8", "8.8.4.4"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

# Redémarrage de Docker pour appliquer la configuration
systemctl restart docker

# Vérification de l'installation
print_message "Vérification de l'installation..."
DOCKER_VERSION=$(docker --version)
print_message "Docker installé : $DOCKER_VERSION"

# Test de Docker
print_message "Test de Docker avec hello-world..."
if docker run --rm hello-world > /dev/null 2>&1; then
    print_message "${GREEN}✓ Docker fonctionne correctement !${NC}"
else
    print_error "Le test Docker a échoué"
    exit 1
fi

# Affichage des informations finales
echo ""
print_message "=== Installation terminée avec succès ! ==="
echo ""
print_message "Prochaines étapes :"
echo "  1. Déconnectez-vous et reconnectez-vous (ou faites: newgrp docker)"
echo "  2. Testez Docker : docker run hello-world"
echo "  3. Pour initialiser Swarm (sur le manager) :"
echo "     docker swarm init --advertise-addr <VOTRE_IP>"
echo ""
print_warning "Note : Si vous avez des problèmes de connexion à Docker Hub,"
print_warning "       vérifiez votre configuration DNS/pare-feu (AdGuard, etc.)"
echo ""
