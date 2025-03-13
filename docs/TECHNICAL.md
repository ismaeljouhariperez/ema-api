# Documentation Technique - EMA API

## Architecture technique

### Vue d'ensemble

EMA API est une application Rails 8 en mode API qui sert de backend pour la plateforme EMA (Exploration de Micro-Aventures). L'application suit une architecture microservices, où elle interagit avec un service d'IA séparé (ema-ai) développé en Python/FastAPI.

### Diagramme d'architecture

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│                 │      │                 │      │                 │
│  ema-frontend   │◄────►│    ema-api      │◄────►│     ema-ai      │
│  (React/TS)     │      │   (Rails 8)     │      │  (Python/FastAPI)│
│                 │      │                 │      │                 │
└─────────────────┘      └─────────────────┘      └─────────────────┘
                                 ▲
                                 │
                         ┌───────┴───────┐
                         │               │
                         │  PostgreSQL   │
                         │  (DB/Jobs/Cache)│
                         │               │
                         └───────────────┘
```

### Composants principaux

1. **API RESTful** : Endpoints versionnés pour les aventures, utilisateurs et fonctionnalités IA
2. **Authentification JWT** : Gestion des sessions utilisateur avec Devise Token Auth
3. **Autorisation** : Contrôle d'accès granulaire avec Pundit
4. **Traitement asynchrone** : Jobs en arrière-plan avec Solid Queue
5. **Mise en cache** : Caching basé sur PostgreSQL avec Solid Cache
6. **Géolocalisation** : Fonctionnalités de localisation avec Geocoder
7. **Recherche avancée** : Recherche textuelle avec pg_search
8. **Intégration IA** : Communication HTTP avec le service ema-ai

## Modèles de données

### Schéma de base de données

```
┌─────────────────┐       ┌─────────────────┐
│      User       │       │    Adventure    │
├─────────────────┤       ├─────────────────┤
│ id              │       │ id              │
│ email           │       │ title           │
│ encrypted_pass  │       │ description     │
│ name            │       │ location        │
│ tokens          │       │ latitude        │
│ created_at      │       │ longitude       │
│ updated_at      │       │ tags            │
└─────────────────┘       │ difficulty      │
        │                 │ duration        │
        │                 │ distance        │
        │                 │ user_id         │
        └────────────────►│ created_at      │
                          │ updated_at      │
                          └─────────────────┘
```

### Migrations

Les migrations principales incluent :

1. `devise_token_auth_create_users.rb` - Crée la table des utilisateurs avec authentification
2. `create_adventures.rb` - Crée la table des aventures avec géolocalisation

## API Endpoints

### Format de réponse

Toutes les réponses API sont au format JSON et suivent cette structure :

```json
// Réponse réussie (collection)
{
  "data": [
    {
      "id": 1,
      "type": "adventure",
      "attributes": {
        "title": "Randonnée au Lac Bleu",
        "description": "Une belle randonnée...",
        // autres attributs
      }
    }
  ]
}

// Réponse d'erreur
{
  "error": "Message d'erreur",
  "status": 400,
  "details": ["Détail de l'erreur 1", "Détail de l'erreur 2"]
}
```

### En-têtes d'authentification

Pour les endpoints authentifiés, les en-têtes suivants sont requis :

```
access-token: <token>
client: <client-id>
uid: <user-email>
```

Ces en-têtes sont fournis lors de la connexion et doivent être inclus dans les requêtes ultérieures.

## Intégration avec ema-ai

### Flux de communication

1. L'utilisateur envoie une requête à `/api/v1/ai_adventures/generate` avec un prompt
2. ema-api lance un job Sidekiq en arrière-plan
3. Le job appelle l'API ema-ai via Faraday
4. ema-ai génère une aventure avec OpenAI/LangChain
5. ema-api reçoit la réponse et crée une nouvelle aventure
6. L'utilisateur peut vérifier le statut via `/api/v1/ai_adventures/status/:job_id`

### Format des données échangées

**Requête à ema-ai :**

```json
{
  "prompt": "Je cherche une randonnée près de Bordeaux"
}
```

**Réponse de ema-ai :**

```json
{
  "title": "Randonnée dans les vignobles de Saint-Émilion",
  "description": "Une magnifique randonnée à travers les vignobles...",
  "location": "Saint-Émilion, Bordeaux",
  "tags": ["nature", "vignoble", "patrimoine"],
  "difficulty": "facile",
  "duration": 120,
  "distance": 8.5
}
```

## Traitement asynchrone

### Configuration de Solid Queue

Solid Queue est configuré avec plusieurs files d'attente dans `config/solid_queue.yml` :

```yaml
default: &default
  concurrency: <%= ENV.fetch("SOLID_QUEUE_CONCURRENCY", 5) %>
  polling_interval: 1
  queues:
    - [ai_generation, 3]
    - [mailers, 2]
    - [default, 1]
```

L'interface web de Solid Queue est accessible à `/solid_queue` et protégée par une authentification HTTP Basic.

### Jobs principaux

- `GenerateAdventureJob` : Génère une aventure via l'API ema-ai

### Gestion des erreurs

Les jobs implémentent une stratégie de retry avec backoff exponentiel :

```ruby
retry_on Faraday::Error, wait: :exponentially_longer, attempts: 3
discard_on StandardError do |job, error|
  Rails.logger.error("Échec de la génération d'aventure: #{error.message}")
end
```

## Sécurité

### Authentification

L'authentification est gérée par Devise Token Auth avec JWT :

1. L'utilisateur s'authentifie via `/auth/sign_in`
2. Le serveur génère un token JWT et le renvoie dans les en-têtes
3. Le client stocke ce token et l'inclut dans les requêtes ultérieures

### Autorisation

L'autorisation est gérée par Pundit avec des politiques pour chaque ressource :

```ruby
# Exemple de politique pour les aventures
class AdventurePolicy < ApplicationPolicy
  def update?
    user_is_owner?
  end

  private

  def user_is_owner?
    user.present? && record.user_id == user.id
  end
end
```

### CORS

CORS est configuré pour permettre les requêtes depuis le frontend :

```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['ALLOWED_ORIGINS'].split(',')
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['access-token', 'expiry', 'token-type', 'uid', 'client']
  end
end
```

## Déploiement

### Configuration Docker

Le projet inclut un `Dockerfile` et un `docker-compose.yml` pour faciliter le déploiement :

```dockerfile
# Dockerfile (extrait)
FROM ruby:3.3.6-slim AS base
WORKDIR /rails
# ...
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
```

### Variables d'environnement

Les variables d'environnement requises sont documentées dans `.env.example` et doivent être configurées dans l'environnement de production.

### Surveillance et logging

- Les logs Rails sont disponibles dans `log/production.log`
- Sidekiq fournit une interface web à `/sidekiq` pour surveiller les jobs
- Les erreurs d'application sont enregistrées dans les logs Rails

## Performance

### Optimisations

1. **Mise en cache** : Utilisation de Solid Cache pour la mise en cache
2. **Traitement asynchrone** : Utilisation de Solid Queue pour les tâches longues
3. **Indexation** : Indexes sur les colonnes fréquemment recherchées
4. **Sérialiseurs** : Contrôle précis des données renvoyées par l'API

### Points d'attention

1. **Appels à l'API ema-ai** : Peuvent être lents, d'où l'utilisation de Solid Queue
2. **Recherche géospatiale** : Peut être intensive en ressources sur de grands ensembles de données
3. **Authentification JWT** : Vérification des tokens à chaque requête

## Bonnes pratiques

1. **Mise en cache** : Utilisation de Solid Cache pour la mise en cache des données fréquemment accédées
2. **Traitement asynchrone** : Utilisation de Solid Queue pour les tâches longues
3. **Gestion des erreurs** : Capture et journalisation des erreurs, avec retry pour les opérations critiques
4. **Sécurité** : Validation des entrées, protection CSRF, et authentification JWT
