#!/bin/bash

###############################################################################
# Script d'initialisation du cluster Docker Swarm
# Usage: ./init-swarm.sh [manager|worker] [manager-ip] [join-token]
###############################################################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERREUR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}    $1"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
}

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    print_error "Docker n'est pas installé. Installez-le d'abord avec install-docker.sh"
    exit 1
fi

# Déterminer l'IP principale de la machine
get_main_ip() {
    ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1
}

MAIN_IP=$(get_main_ip)

# Fonction d'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  manager                    Initialiser ce nœud en tant que manager"
    echo "  worker <ip> <token>       Joindre ce nœud en tant que worker"
    echo "  status                     Afficher l'état du cluster"
    echo "  leave                      Quitter le cluster"
    echo ""
    echo "Exemples:"
    echo "  $0 manager                 # Sur le nœud manager"
    echo "  $0 worker 192.168.100.10 SWMTKN-xxx  # Sur un worker"
    echo "  $0 status                  # Vérifier l'état"
    echo ""
}

# Initialiser en tant que manager
init_manager() {
    print_header "Initialisation du Manager Swarm"
    
    print_message "IP détectée : $MAIN_IP"
    print_message "Initialisation du Swarm..."
    
    docker swarm init --advertise-addr $MAIN_IP
    
    echo ""
    print_message "${GREEN}✓ Manager initialisé avec succès !${NC}"
    echo ""
    print_message "Pour ajouter des workers, exécutez sur chaque worker :"
    docker swarm join-token worker | grep "docker swarm join"
    echo ""
    print_message "Pour voir l'état du cluster :"
    echo "  docker node ls"
    echo ""
}

# Joindre en tant que worker
join_worker() {
    local MANAGER_IP=$1
    local TOKEN=$2
    
    if [ -z "$MANAGER_IP" ] || [ -z "$TOKEN" ]; then
        print_error "IP du manager et token requis"
        echo "Usage: $0 worker <manager-ip> <join-token>"
        exit 1
    fi
    
    print_header "Connexion au Swarm en tant que Worker"
    
    print_message "Manager IP : $MANAGER_IP"
    print_message "Connexion au cluster..."
    
    docker swarm join --token $TOKEN ${MANAGER_IP}:2377
    
    echo ""
    print_message "${GREEN}✓ Worker connecté avec succès !${NC}"
    echo ""
    print_message "Vérifiez sur le manager avec : docker node ls"
    echo ""
}

# Afficher le statut
show_status() {
    print_header "État du Cluster Swarm"
    
    if docker info 2>/dev/null | grep -q "Swarm: active"; then
        print_message "Ce nœud fait partie d'un cluster Swarm actif"
        echo ""
        
        # Si c'est un manager, afficher les nœuds
        if docker node ls &>/dev/null; then
            echo "Liste des nœuds :"
            docker node ls
            echo ""
            echo "Services déployés :"
            docker service ls
        else
            print_message "Ce nœud est un worker"
            docker info | grep -A 10 "Swarm:"
        fi
    else
        print_warning "Ce nœud ne fait pas partie d'un cluster Swarm"
    fi
}

# Quitter le cluster
leave_swarm() {
    print_header "Quitter le Cluster Swarm"
    
    if docker info 2>/dev/null | grep -q "Swarm: active"; then
        print_warning "Êtes-vous sûr de vouloir quitter le cluster ? (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            docker swarm leave --force
            print_message "${GREEN}✓ Nœud retiré du cluster${NC}"
        else
            print_message "Annulé"
        fi
    else
        print_warning "Ce nœud ne fait pas partie d'un cluster"
    fi
}

# Menu principal
case "${1:-}" in
    manager)
        init_manager
        ;;
    worker)
        join_worker "$2" "$3"
        ;;
    status)
        show_status
        ;;
    leave)
        leave_swarm
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        print_error "Option inconnue : $1"
        show_help
        exit 1
        ;;
esac
