# Guide de Développement - EMA API (Rails 8)

Ce document fournit une vue d'ensemble technique et un guide pour les développeurs travaillant sur l'API EMA.

## Table des matières

1. [Architecture du projet](#architecture-du-projet)
2. [Configuration de l'environnement](#configuration-de-lenvironnement)
3. [Modèles et relations](#modèles-et-relations)
4. [API Endpoints](#api-endpoints)
5. [Authentification et autorisation](#authentification-et-autorisation)
6. [Intégration avec l'IA](#intégration-avec-lia)
7. [Traitement asynchrone](#traitement-asynchrone)
8. [Tests API](#tests-api)
9. [Déploiement](#déploiement)
10. [Bonnes pratiques](#bonnes-pratiques)

## Architecture du projet

EMA API est structuré selon une architecture RESTful avec versionnement d'API. Le projet est divisé en trois parties distinctes :

1. **ema-api (Rails 8)** - Ce repository

   - Gère les utilisateurs, l'authentification, le stockage des aventures
   - Expose une API REST pour le frontend

2. **ema-ai (FastAPI/Python)** - Service séparé

   - Utilise LangChain et OpenAI pour le traitement IA
   - Développé en Python avec FastAPI
   - S'occupe de la génération des recommandations d'aventures

3. **ema-frontend (React/TypeScript)** - Interface utilisateur

### Structure des dossiers

```
app/
├── controllers/
│   ├── api/
│   │   └── v1/                  # Contrôleurs API versionnés
│   │       ├── base_controller.rb
│   │       ├── adventures_controller.rb
│   │       ├── users_controller.rb
│   │       └── ai_adventures_controller.rb
├── models/
│   ├── user.rb
│   └── adventure.rb
├── policies/                    # Politiques d'autorisation Pundit
│   ├── application_policy.rb
│   ├── adventure_policy.rb
│   ├── user_policy.rb
│   └── ai_adventure_policy.rb
├── serializers/                 # Sérialiseurs pour les réponses JSON
│   ├── adventure_serializer.rb
│   └── user_serializer.rb
├── services/                    # Services métier
│   └── ema_ai_service.rb
└── jobs/                        # Jobs asynchrones
    └── generate_adventure_job.rb
```

## Configuration de l'environnement

### Prérequis

- Ruby 3.3.6
- Rails 8.0.1
- PostgreSQL 15+
- Redis 7+

### Installation locale

1. Cloner le repository

   ```bash
   git clone https://github.com/your-repo/ema-api.git
   cd ema-api
   ```

2. Configurer les variables d'environnement

   ```bash
   cp .env.example .env
   # Éditer .env avec vos configurations
   ```

3. Installer les dépendances

   ```bash
   bundle install
   ```

4. Configurer la base de données

   ```bash
   rails db:create db:migrate db:seed
   ```

5. Démarrer le serveur et Sidekiq

   ```bash
   # Dans un terminal
   rails s

   # Dans un autre terminal
   bundle exec sidekiq
   ```

### Installation avec Docker

1. Cloner le repository et configurer l'environnement

   ```bash
   git clone https://github.com/your-repo/ema-api.git
   cd ema-api
   cp .env.example .env
   # Éditer .env avec vos configurations
   ```

2. Démarrer les services avec Docker Compose

   ```bash
   docker-compose up
   ```

3. Exécuter les migrations (première fois uniquement)
   ```bash
   docker-compose exec api rails db:migrate db:seed
   ```

## Modèles et relations

### User

Le modèle `User` gère l'authentification et est lié aux aventures.

```ruby
class User < ActiveRecord::Base
  # Authentification avec Devise Token Auth
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  # Relations
  has_many :adventures, dependent: :destroy
end
```

### Adventure

Le modèle `Adventure` représente une micro-aventure avec géolocalisation.

```ruby
class Adventure < ApplicationRecord
  belongs_to :user

  # Géolocalisation
  geocoded_by :location
  after_validation :geocode, if: ->(obj) { obj.location.present? && obj.location_changed? }

  # Recherche
  include PgSearch::Model
  pg_search_scope :search_by_title_and_description,
                  against: {
                    title: 'A',
                    description: 'B',
                    location: 'C',
                    tags: 'D'
                  },
                  using: {
                    tsearch: { prefix: true }
                  }

  # Validations
  validates :title, presence: true
  validates :description, presence: true
  validates :location, presence: true

  # Méthodes
  def tags_array
    tags.split(',').map(&:strip) if tags.present?
  end
end
```

## API Endpoints

### Authentification

| Méthode | Endpoint          | Description             | Authentification |
| ------- | ----------------- | ----------------------- | ---------------- |
| POST    | `/auth/sign_in`   | Connexion utilisateur   | Non              |
| POST    | `/auth/sign_up`   | Inscription utilisateur | Non              |
| DELETE  | `/auth/sign_out`  | Déconnexion utilisateur | Oui              |
| GET     | `/api/v1/profile` | Profil utilisateur      | Oui              |

### Aventures

| Méthode | Endpoint                    | Description              | Authentification   |
| ------- | --------------------------- | ------------------------ | ------------------ |
| GET     | `/api/v1/adventures`        | Liste des aventures      | Non                |
| GET     | `/api/v1/adventures/:id`    | Détails d'une aventure   | Non                |
| POST    | `/api/v1/adventures`        | Créer une aventure       | Oui                |
| PUT     | `/api/v1/adventures/:id`    | Modifier une aventure    | Oui (propriétaire) |
| DELETE  | `/api/v1/adventures/:id`    | Supprimer une aventure   | Oui (propriétaire) |
| GET     | `/api/v1/adventures/search` | Rechercher des aventures | Non                |

### Intégration IA

| Méthode | Endpoint                               | Description                         | Authentification |
| ------- | -------------------------------------- | ----------------------------------- | ---------------- |
| POST    | `/api/v1/ai_adventures/generate`       | Générer une aventure avec l'IA      | Oui              |
| GET     | `/api/v1/ai_adventures/search_similar` | Trouver des aventures similaires    | Non              |
| GET     | `/api/v1/ai_adventures/status/:job_id` | Vérifier le statut d'une génération | Oui              |

## Authentification et autorisation

### Authentification

L'API utilise Devise Token Auth pour l'authentification JWT. Les tokens sont envoyés dans les en-têtes HTTP :

```
access-token: <token>
client: <client-id>
uid: <user-email>
```

### Autorisation

L'autorisation est gérée par Pundit avec des politiques pour chaque ressource :

- `AdventurePolicy` : Contrôle l'accès aux aventures
- `UserPolicy` : Contrôle l'accès aux données utilisateur
- `AiAdventurePolicy` : Contrôle l'accès aux fonctionnalités IA

Exemple d'utilisation dans les contrôleurs :

```ruby
# Vérifier l'autorisation pour une action
authorize @adventure

# Filtrer une collection selon les règles d'autorisation
@adventures = policy_scope(Adventure)
```

## Intégration avec l'IA

L'API communique avec le service ema-ai (Python/FastAPI) via HTTP :

```ruby
# app/services/ema_ai_service.rb
class EmaAiService
  def generate_adventure(prompt)
    # Appel à l'API ema-ai pour générer une aventure
    response = Faraday.post("#{@api_url}/api/generate") do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = { prompt: prompt }.to_json
    end

    # Traitement de la réponse
    JSON.parse(response.body)
  end
end
```

## Traitement asynchrone

Les tâches intensives comme la génération d'aventures sont traitées de manière asynchrone avec Solid Queue :

```ruby
# Exemple de job pour générer une aventure
class GenerateAdventureJob < ApplicationJob
  queue_as :ai_generation

  retry_on Faraday::Error, wait: :exponentially_longer, attempts: 3

  def perform(user_id, prompt, callback_url = nil)
    # Appel au service ema-ai et création de l'aventure
  end
end

# Lancement du job depuis un contrôleur
job = GenerateAdventureJob.perform_later(current_user.id, prompt, callback_url)
```

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

### Vérification du statut des jobs

```ruby
# Dans le contrôleur
def status
  job_id = params[:job_id]
  job = SolidQueue::Job.find_by(id: job_id)

  status = case job.scheduled_at
  when nil
    if job.finished_at.present?
      "completed"
    else
      "processing"
    end
  else
    "scheduled"
  end

  render json: {
    job_id: job_id,
    status: status,
    scheduled_at: job.scheduled_at,
    finished_at: job.finished_at
  }
end
```

## Mise en cache

L'application utilise Solid Cache pour la mise en cache, qui est basé sur la base de données PostgreSQL :

```ruby
# Configuration dans config/environments/production.rb
config.cache_store = :solid_cache_store, { expires_in: 1.day }

# Exemple d'utilisation
Rails.cache.fetch("adventure_#{id}", expires_in: 1.hour) do
  Adventure.find(id)
end
```

## Tests API

Pour tester manuellement l'API, consultez le document [API_TESTING.md](docs/API_TESTING.md) qui contient des exemples de commandes curl et des informations d'authentification pour les tests.

Ce document inclut :

- Des exemples de commandes curl pour chaque endpoint
- Des instructions pour obtenir des jetons d'authentification
- Des instructions pour tester les fonctionnalités asynchrones (Redis/Sidekiq)

### Jetons d'authentification pour les tests

Pour des raisons de sécurité, les jetons d'authentification réels ne sont pas inclus dans le dépôt Git. Pour stocker vos propres jetons d'authentification, créez un fichier `docs/API_TOKENS.local` qui sera ignoré par Git. Vous pouvez y stocker vos jetons et commandes curl avec les vrais jetons.

Pour obtenir des jetons d'authentification :

```bash
curl -i -X POST -H "Content-Type: application/json" -d '{
  "email": "test@example.com",
  "password": "password123"
}' http://localhost:3000/auth/sign_in
```

Extrayez les valeurs des en-têtes `access-token`, `client` et `uid` de la réponse.

### Exemples de tests automatisés

Les tests automatisés sont implémentés avec RSpec. Voici un exemple de test pour l'endpoint de création d'aventure :

```ruby
# spec/requests/api/v1/adventures_spec.rb
require 'rails_helper'

RSpec.describe "Api::V1::Adventures", type: :request do
  describe "POST /api/v1/adventures" do
    let(:user) { create(:user) }
    let(:auth_headers) { user.create_new_auth_token }
    let(:valid_attributes) do
      {
        adventure: {
          title: "Randonnée au Lac Bleu",
          description: "Une belle randonnée avec vue panoramique",
          location: "Lac Bleu, Pyrénées",
          tags: "randonnée,nature,montagne",
          difficulty: "modérée",
          duration: 180,
          distance: 12.5
        }
      }
    end

    context "avec un utilisateur authentifié" do
      it "crée une nouvelle aventure" do
        expect {
          post api_v1_adventures_path,
               params: valid_attributes,
               headers: auth_headers
        }.to change(Adventure, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response["title"]).to eq("Randonnée au Lac Bleu")
      end
    end
  end
end
```

## Déploiement

### Variables d'environnement

Les variables d'environnement requises sont documentées dans `.env.example` :

```
EMA_API_DATABASE_USERNAME=db_username
EMA_API_DATABASE_PASSWORD=secure_password
EMA_API_DATABASE_HOST=your-db-host
EMA_API_SECRET_KEY=your-secret-key
REDIS_URL=redis://your-redis-host:6379/0
EMA_AI_API_URL=https://your-ai-service-url
ALLOWED_ORIGINS=https://your-frontend-domain.com
```

### Déploiement avec Docker

```bash
# Construire l'image
docker build -t ema-api .

# Exécuter le conteneur
docker run -p 80:80 \
  -e RAILS_ENV=production \
  -e EMA_API_DATABASE_USERNAME=db_username \
  -e EMA_API_DATABASE_PASSWORD=secure_password \
  -e EMA_API_DATABASE_HOST=your-db-host \
  -e REDIS_URL=redis://your-redis-host:6379/0 \
  -e EMA_AI_API_URL=https://your-ai-service-url \
  -e ALLOWED_ORIGINS=https://your-frontend-domain.com \
  -e SIDEKIQ_ENABLED=true \
  ema-api
```

### Déploiement avec Kamal

```bash
# Configurer Kamal
kamal setup

# Déployer l'application
kamal deploy
```

## Bonnes pratiques

1. **Versionnement d'API** : Toujours préfixer les routes avec la version (`/api/v1/`)
2. **Sérialiseurs** : Utiliser les sérialiseurs pour formater les réponses JSON
3. **Politiques d'autorisation** : Vérifier les autorisations avec Pundit
4. **Traitement asynchrone** : Utiliser Sidekiq pour les tâches longues
5. **Tests** : Écrire des tests pour les modèles, contrôleurs et services
6. **Documentation** : Documenter les endpoints API et les changements importants
7. **Variables d'environnement** : Ne jamais stocker de secrets dans le code
