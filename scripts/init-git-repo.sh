#!/bin/bash

###############################################################################
# Script pour initialiser le dépôt Git et pousser sur GitHub
# Usage: ./init-git-repo.sh
###############################################################################

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Initialisation du dépôt Git ===${NC}"
echo ""

# Vérifier que nous sommes dans le bon dossier
if [ ! -f "README.md" ]; then
    echo -e "${RED}Erreur : README.md non trouvé${NC}"
    echo "Assurez-vous d'être dans le dossier docker-swarm-lab"
    exit 1
fi

# Demander le nom d'utilisateur GitHub
echo -e "${YELLOW}Entrez votre nom d'utilisateur GitHub :${NC}"
read -r GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo -e "${RED}Nom d'utilisateur requis${NC}"
    exit 1
fi

# Demander le nom du dépôt
echo -e "${YELLOW}Entrez le nom du dépôt (par défaut: docker-swarm-lab) :${NC}"
read -r REPO_NAME
REPO_NAME=${REPO_NAME:-docker-swarm-lab}

echo ""
echo -e "${GREEN}Configuration :${NC}"
echo "  GitHub Username : $GITHUB_USERNAME"
echo "  Repository Name : $REPO_NAME"
echo ""

# Initialiser Git si nécessaire
if [ ! -d ".git" ]; then
    echo -e "${GREEN}Initialisation du dépôt Git...${NC}"
    git init
    git branch -M main
else
    echo -e "${YELLOW}Dépôt Git déjà initialisé${NC}"
fi

# Configurer Git (optionnel)
echo -e "${YELLOW}Voulez-vous configurer votre nom et email Git ? (y/N)${NC}"
read -r CONFIGURE_GIT

if [[ "$CONFIGURE_GIT" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${YELLOW}Entrez votre nom :${NC}"
    read -r GIT_NAME
    echo -e "${YELLOW}Entrez votre email :${NC}"
    read -r GIT_EMAIL
    
    git config user.name "$GIT_NAME"
    git config user.email "$GIT_EMAIL"
    echo -e "${GREEN}Configuration Git mise à jour${NC}"
fi

# Ajouter tous les fichiers
echo -e "${GREEN}Ajout des fichiers au dépôt...${NC}"
git add .

# Premier commit
echo -e "${GREEN}Création du commit initial...${NC}"
git commit -m "Initial commit - Docker Swarm Lab

- Configuration VMware et réseau
- Scripts d'installation automatique
- Documentation complète
- Exemples de stacks
- Cheat sheet des commandes"

# Afficher les instructions pour créer le dépôt GitHub
echo ""
echo -e "${GREEN}=== Instructions pour pousser sur GitHub ===${NC}"
echo ""
echo "1. Créez un nouveau dépôt sur GitHub :"
echo "   https://github.com/new"
echo ""
echo "2. Nom du dépôt : ${REPO_NAME}"
echo "   Description : Docker Swarm Lab - Environnement de test et d'apprentissage"
echo "   Visibilité : Public (recommandé pour le partage)"
echo ""
echo "3. NE PAS initialiser avec README, .gitignore ou LICENSE (déjà présents)"
echo ""
echo -e "${YELLOW}4. Une fois le dépôt créé, exécutez ces commandes :${NC}"
echo ""
echo "   git remote add origin https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
echo "   git push -u origin main"
echo ""
echo -e "${GREEN}Ou avec SSH :${NC}"
echo ""
echo "   git remote add origin git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git"
echo "   git push -u origin main"
echo ""

# Proposer d'ajouter le remote automatiquement
echo -e "${YELLOW}Voulez-vous ajouter le remote maintenant ? (y/N)${NC}"
read -r ADD_REMOTE

if [[ "$ADD_REMOTE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${YELLOW}Choisissez le protocole :${NC}"
    echo "1) HTTPS (recommandé pour débuter)"
    echo "2) SSH (si vous avez configuré une clé SSH)"
    read -r PROTOCOL
    
    if [ "$PROTOCOL" = "1" ]; then
        REMOTE_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
    else
        REMOTE_URL="git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git"
    fi
    
    # Vérifier si le remote existe déjà
    if git remote | grep -q "^origin$"; then
        echo -e "${YELLOW}Remote 'origin' existe déjà. Remplacer ? (y/N)${NC}"
        read -r REPLACE_REMOTE
        if [[ "$REPLACE_REMOTE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            git remote remove origin
            git remote add origin "$REMOTE_URL"
            echo -e "${GREEN}Remote 'origin' remplacé${NC}"
        fi
    else
        git remote add origin "$REMOTE_URL"
        echo -e "${GREEN}Remote 'origin' ajouté : $REMOTE_URL${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}Pour pousser vos changements :${NC}"
    echo "   git push -u origin main"
fi

echo ""
echo -e "${GREEN}=== Configuration terminée ! ===${NC}"
echo ""
echo -e "${YELLOW}Prochaines étapes :${NC}"
echo "1. Créer le dépôt sur GitHub"
echo "2. Pousser avec : git push -u origin main"
echo "3. Ajouter des screenshots dans screenshots/"
echo "4. Personnaliser le README.md si nécessaire"
echo ""
echo -e "${GREEN}Bon partage ! 🚀${NC}"
