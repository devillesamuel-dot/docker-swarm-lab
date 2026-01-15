# Guide de Contribution

Merci de votre intérêt pour contribuer au projet Docker Swarm Lab ! 🎉

## Comment contribuer

### 🐛 Signaler un bug

1. Vérifier que le bug n'a pas déjà été signalé dans les [Issues](https://github.com/devillesamuel-dot/docker-swarm-lab/issues)
2. Créer une nouvelle issue avec :
   - Un titre clair et descriptif
   - Une description détaillée du problème
   - Les étapes pour reproduire
   - Votre environnement (OS, version VMware, version Docker)
   - Logs ou captures d'écran si pertinent

### 💡 Proposer une amélioration

1. Ouvrir une issue pour discuter de votre idée
2. Attendre les retours avant de commencer le développement
3. Créer une Pull Request en référençant l'issue

### 📝 Améliorer la documentation

La documentation est cruciale ! N'hésitez pas à :
- Corriger les fautes de frappe
- Clarifier des explications
- Ajouter des exemples
- Traduire la documentation
- Ajouter des screenshots

### 🔧 Contribuer du code

#### Prérequis

- Git installé
- Connaissances en Docker et Swarm
- Environnement de test (lab fonctionnel)

#### Processus

1. **Fork** le projet
2. **Clone** votre fork
   ```bash
   git clone https://github.com/devillesamuel-dot/docker-swarm-lab.git
   cd docker-swarm-lab
   ```

3. **Créer une branche** pour votre fonctionnalité
   ```bash
   git checkout -b feature/ma-nouvelle-fonctionnalite
   ```

4. **Faire vos modifications**
   - Respecter la structure existante
   - Ajouter des commentaires si nécessaire
   - Tester vos modifications

5. **Commit** avec un message clair
   ```bash
   git add .
   git commit -m "Ajout de [description courte]"
   ```

6. **Push** vers votre fork
   ```bash
   git push origin feature/ma-nouvelle-fonctionnalite
   ```

7. **Créer une Pull Request** vers la branche `main`

### 📋 Checklist avant Pull Request

- [ ] Le code fonctionne et a été testé
- [ ] La documentation est à jour
- [ ] Les scripts sont exécutables (`chmod +x`)
- [ ] Les fichiers YAML sont correctement indentés
- [ ] Les messages de commit sont clairs
- [ ] Pas de données sensibles (mots de passe, tokens)

## Standards de code

### Scripts Bash

```bash
#!/bin/bash

###############################################################################
# Description du script
# Usage: ./script.sh [options]
###############################################################################

set -e  # Arrêter en cas d'erreur

# Fonctions avec commentaires
fonction_exemple() {
    # Description de la fonction
    echo "Exemple"
}
```

### Fichiers YAML

- Indentation : **2 espaces** (pas de tabulations)
- Commentaires explicatifs pour les sections complexes
- Validation avec `yamllint` si possible

### Documentation Markdown

- Titres hiérarchisés (H1, H2, H3)
- Blocs de code avec syntaxe highlighting
- Liens relatifs pour la navigation interne
- Emojis pour améliorer la lisibilité (avec modération)

## Types de contributions recherchées

### 🎯 Priorité haute

- Corrections de bugs critiques
- Améliorations de sécurité
- Corrections de la documentation
- Scripts d'automatisation additionnels

### 🌟 Améliorations souhaitées

- Support d'autres hyperviseurs (VirtualBox, KVM)
- Scripts de monitoring (Prometheus, Grafana)
- Exemples de stacks applicatives
- Intégration CI/CD
- Support multi-plateforme (Windows, macOS)

### 📚 Documentation

- Traductions (anglais, espagnol, etc.)
- Vidéos tutoriels
- Diagrammes d'architecture
- FAQ étendue

## Structure du projet

```
docker-swarm-lab/
├── README.md              # Documentation principale
├── QUICKSTART.md          # Guide de démarrage rapide
├── CHEATSHEET.md          # Antisèche des commandes
├── LICENSE                # Licence MIT
├── .gitignore             # Fichiers ignorés
├── docs/                  # Documentation détaillée
│   ├── 01-infrastructure-setup.md
│   ├── 02-network-configuration.md
│   ├── 03-docker-installation.md
│   ├── 04-swarm-initialization.md
│   └── 05-service-deployment.md
├── configs/               # Fichiers de configuration
│   ├── netplan-manager.yaml
│   ├── netplan-worker1.yaml
│   ├── netplan-worker2.yaml
│   └── stack-example.yml
├── scripts/               # Scripts d'automatisation
│   ├── install-docker.sh
│   └── init-swarm.sh
└── screenshots/           # Captures d'écran
    └── README.md
```

## Conventions de nommage

### Branches

- `feature/nom-fonctionnalite` : Nouvelles fonctionnalités
- `fix/nom-bug` : Corrections de bugs
- `docs/sujet` : Améliorations documentation
- `refactor/composant` : Refactoring

### Commits

Utiliser des messages clairs et descriptifs :

```
✅ Bon : "Ajout du script d'installation automatique de Docker"
❌ Mauvais : "update"

✅ Bon : "Fix : Correction du problème de DNS dans netplan"
❌ Mauvais : "fix bug"
```

### Fichiers

- Scripts : `kebab-case.sh`
- Configs : `kebab-case.yaml` ou `.yml`
- Docs : `kebab-case.md`

## Code de conduite

- Être respectueux et courtois
- Accepter les critiques constructives
- Se concentrer sur ce qui est meilleur pour la communauté
- Faire preuve d'empathie envers les autres membres

## Questions ?

- Ouvrir une [Discussion](https://github.com/devillesamuel-dot/docker-swarm-lab/discussions)
- Contacter via [Issues](https://github.com/devillesamuel-dot/docker-swarm-lab/issues)

## Licence

En contribuant, vous acceptez que vos contributions soient sous [licence MIT](LICENSE).

---

Merci pour votre contribution ! 🙏
