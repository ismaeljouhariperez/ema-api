# Guide de Test de l'API EMA

Ce document fournit des exemples de commandes curl pour tester l'API EMA, ainsi que des informations d'authentification pour les tests.

## Informations d'authentification

Pour les requêtes nécessitant une authentification, utilisez les en-têtes suivants :

```
access-token: <VOTRE_ACCESS_TOKEN>
client: <VOTRE_CLIENT_ID>
uid: <VOTRE_EMAIL>
```

Ces informations sont obtenues lors de la connexion d'un utilisateur. Voir la section "Se connecter" ci-dessous pour savoir comment obtenir ces jetons.

## Exemples de commandes curl

### Authentification

#### Créer un utilisateur

```bash
curl -X POST -H "Content-Type: application/json" -d '{
  "email": "test@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "name": "Test User"
}' http://localhost:3000/auth
```

#### Se connecter

```bash
curl -i -X POST -H "Content-Type: application/json" -d '{
  "email": "test@example.com",
  "password": "password123"
}' http://localhost:3000/auth/sign_in
```

L'option `-i` permet d'afficher les en-têtes de la réponse, qui contiennent les jetons d'authentification. Vous devrez extraire les valeurs des en-têtes suivants de la réponse :

- `access-token`
- `client`
- `uid`

### Gestion des aventures

#### Récupérer la liste des aventures

```bash
curl -X GET -H "Content-Type: application/json" http://localhost:3000/api/v1/adventures
```

#### Récupérer les détails d'une aventure

```bash
curl -X GET -H "Content-Type: application/json" http://localhost:3000/api/v1/adventures/1
```

#### Rechercher des aventures par mot-clé

```bash
curl -X GET -H "Content-Type: application/json" "http://localhost:3000/api/v1/adventures/search?query=lac"
```

#### Créer une aventure (authentifié)

```bash
curl -X POST -H "Content-Type: application/json" \
  -H "access-token: <VOTRE_ACCESS_TOKEN>" \
  -H "client: <VOTRE_CLIENT_ID>" \
  -H "uid: <VOTRE_EMAIL>" \
  -d '{
    "adventure": {
      "title": "Randonnée au Lac Bleu",
      "description": "Une belle randonnée avec vue panoramique",
      "location": "Lac Bleu, Pyrénées",
      "tags": "randonnée,nature,montagne",
      "difficulty": "modérée",
      "duration": 180,
      "distance": 12.5
    }
  }' http://localhost:3000/api/v1/adventures
```

#### Mettre à jour une aventure (authentifié)

```bash
curl -X PUT -H "Content-Type: application/json" \
  -H "access-token: <VOTRE_ACCESS_TOKEN>" \
  -H "client: <VOTRE_CLIENT_ID>" \
  -H "uid: <VOTRE_EMAIL>" \
  -d '{
    "adventure": {
      "title": "Randonnée au Lac Bleu - Mise à jour",
      "description": "Une belle randonnée avec vue panoramique sur les montagnes",
      "difficulty": "facile"
    }
  }' http://localhost:3000/api/v1/adventures/1
```

#### Supprimer une aventure (authentifié)

```bash
curl -X DELETE -H "Content-Type: application/json" \
  -H "access-token: <VOTRE_ACCESS_TOKEN>" \
  -H "client: <VOTRE_CLIENT_ID>" \
  -H "uid: <VOTRE_EMAIL>" \
  http://localhost:3000/api/v1/adventures/1
```

### Fonctionnalités IA

#### Générer une aventure avec l'IA (authentifié)

```bash
curl -X POST -H "Content-Type: application/json" \
  -H "access-token: <VOTRE_ACCESS_TOKEN>" \
  -H "client: <VOTRE_CLIENT_ID>" \
  -H "uid: <VOTRE_EMAIL>" \
  -d '{
    "prompt": "Je cherche une randonnée près de Bordeaux"
  }' http://localhost:3000/api/v1/ai_adventures/generate
```

**Note** : Cette fonctionnalité nécessite Redis et Sidekiq pour fonctionner correctement.

#### Vérifier le statut d'une génération (authentifié)

```bash
curl -X GET -H "Content-Type: application/json" \
  -H "access-token: <VOTRE_ACCESS_TOKEN>" \
  -H "client: <VOTRE_CLIENT_ID>" \
  -H "uid: <VOTRE_EMAIL>" \
  http://localhost:3000/api/v1/ai_adventures/status/JOB_ID
```

Remplacez `JOB_ID` par l'identifiant du job retourné lors de la génération.

## Prérequis pour les fonctionnalités avancées

### Redis et Sidekiq

Pour tester les fonctionnalités asynchrones (génération d'aventures avec l'IA), vous devez avoir Redis installé et démarré :

```bash
# Installation avec Homebrew (macOS)
brew install redis

# Démarrer Redis
brew services start redis

# Démarrer Sidekiq
bundle exec sidekiq
```
