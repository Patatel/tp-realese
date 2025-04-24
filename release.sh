#!/bin/bash

# Script de release simple pour projets Node.js
# Usage: ./release.sh [tool] [version-type]
# Example: ./release.sh standard-version minor

TOOL=${1:-"menu"}
VERSION_TYPE=${2:-"patch"}

# Vérifier que tous les tests passent
function run_tests() {
  echo "Exécution des tests..."
  npm test
  npm run test:integration
  
  if [ $? -ne 0 ]; then
    echo "❌ Les tests ont échoué. Release annulée."
    exit 1
  fi
  echo "✅ Tous les tests sont passés!"
}

# Fonctions pour chaque outil
function use_standard_version() {
  echo "📦 Utilisation de standard-version pour une release ${VERSION_TYPE}..."
  npx standard-version --release-as ${VERSION_TYPE}
  
  # Pousser les changements et les tags
  git push --follow-tags origin main
  
  echo "✅ Release standard-version terminée!"
}

function use_semantic_release() {
  echo "📦 Utilisation de semantic-release..."
  # Semantic-release détermine automatiquement le type de version
  npx semantic-release
  
  echo "✅ Release semantic-release terminée!"
}

function use_release_it() {
  echo "📦 Utilisation de release-it pour une release ${VERSION_TYPE}..."
  npx release-it ${VERSION_TYPE} --ci
  
  echo "✅ Release release-it terminée!"
}

# Menu interactif
function show_menu() {
  echo "Sélectionnez l'outil de release:"
  echo "1) standard-version"
  echo "2) semantic-release"
  echo "3) release-it"
  read -p "Votre choix (1-3): " choice
  
  case $choice in
    1) TOOL="standard-version" ;;
    2) TOOL="semantic-release" ;;
    3) TOOL="release-it" ;;
    *) echo "Choix invalide"; exit 1 ;;
  esac
  
  if [ "$TOOL" != "semantic-release" ]; then
    echo "Type de version (patch/minor/major):"
    read VERSION_TYPE
  fi
}

# Point d'entrée principal
function main() {
  run_tests
  
  if [ "$TOOL" = "menu" ]; then
    show_menu
  fi
  
  case $TOOL in
    "standard-version") use_standard_version ;;
    "semantic-release") use_semantic_release ;;
    "release-it") use_release_it ;;
    *) echo "Outil non supporté: $TOOL"; exit 1 ;;
  esac
}

main