# EMA API (Rails 8)

## 🚀 Overview

EMA API is the backend of the EMA project, developed in **Rails 8**. It manages adventure creation and retrieval, user authentication, and provides the REST API consumed by the frontend and the AI service.

## 🛠️ Tech Stack

- **Ruby on Rails 8** (API-only mode)
- **PostgreSQL** (Primary database, job processing, and caching)
- **Solid Queue** (Background job processing)
- **Solid Cache** (Database-backed caching)
- **Devise Token Auth** (JWT-based authentication)
- **Pundit** (Authorization management)
- **Geocoder** (Adventure geolocation)
- **PgSearch** (Advanced search)
- **Faraday** (HTTP client for AI service integration)
- **Docker** (Containerization)

## 📌 Features

- ✅ RESTful API for adventures with proper versioning (v1)
- ✅ User authentication with JWT (Devise Token Auth)
- ✅ Fine-grained authorization with Pundit
- ✅ Adventure storage and retrieval with geolocation
- ✅ Advanced search with PgSearch
- ✅ Asynchronous processing with Solid Queue
- ✅ Database-backed caching with Solid Cache
- ✅ Integration with the AI service (FastAPI) for content generation
- ✅ Docker and docker-compose setup for easy development and deployment

## 🏗️ Installation

### **Option 1: Local Development**

#### **1. Clone the repository**

```sh
git clone https://github.com/your-repo/ema-api.git
cd ema-api
```

#### **2. Configure environment variables**

```sh
cp .env.example .env
# Edit .env with your configuration
```

#### **3. Install dependencies**

```sh
bundle install
```

#### **4. Configure the database**

```sh
rails db:create db:migrate db:seed
```

#### **5. Start the server and Solid Queue**

```sh
# In one terminal
rails s

# In another terminal
bundle exec solid_queue --config-file=config/solid_queue.yml
```

The API will be accessible at `http://localhost:3000`

### **Option 2: Docker Development**

```sh
# Copy and configure environment variables
cp .env.example .env
# Edit .env with your configuration

# Start all services
docker-compose up

# Run migrations (first time only)
docker-compose exec api rails db:migrate db:seed
```

The API will be accessible at `http://localhost:3000`

## 🔧 Main Endpoints

### Authentication

| Method | Endpoint          | Description              |
| ------ | ----------------- | ------------------------ |
| POST   | `/auth/sign_in`   | User login               |
| POST   | `/auth/sign_up`   | User registration        |
| DELETE | `/auth/sign_out`  | User logout              |
| GET    | `/api/v1/profile` | Get current user profile |

### Adventures

| Method | Endpoint                    | Description                |
| ------ | --------------------------- | -------------------------- |
| GET    | `/api/v1/adventures`        | List all adventures        |
| GET    | `/api/v1/adventures/:id`    | Retrieve adventure details |
| POST   | `/api/v1/adventures`        | Create a new adventure     |
| PUT    | `/api/v1/adventures/:id`    | Update an adventure        |
| DELETE | `/api/v1/adventures/:id`    | Delete an adventure        |
| GET    | `/api/v1/adventures/search` | Search adventures          |

### AI Integration

| Method | Endpoint                               | Description                |
| ------ | -------------------------------------- | -------------------------- |
| POST   | `/api/v1/ai_adventures/generate`       | Generate adventure with AI |
| GET    | `/api/v1/ai_adventures/search_similar` | Find similar adventures    |
| GET    | `/api/v1/ai_adventures/status/:job_id` | Check AI generation status |

## 🚀 Deployment

### **1. Environment Variables**

Make sure to set these environment variables in your production environment:

```
EMA_API_DATABASE_USERNAME=db_username
EMA_API_DATABASE_PASSWORD=secure_password
EMA_API_DATABASE_HOST=your-db-host
EMA_API_SECRET_KEY=your-secret-key
EMA_AI_API_URL=https://your-ai-service-url
SOLID_QUEUE_ENABLED=true
SOLID_QUEUE_CONCURRENCY=10
ALLOWED_ORIGINS=https://your-frontend-domain.com
```

### **2. Deploy with Docker**

```sh
# Build the image
docker build -t ema-api .

# Run the container
docker run -p 80:80 \
  -e RAILS_ENV=production \
  -e EMA_API_DATABASE_USERNAME=db_username \
  -e EMA_API_DATABASE_PASSWORD=secure_password \
  -e EMA_API_DATABASE_HOST=your-db-host \
  -e EMA_AI_API_URL=https://your-ai-service-url \
  -e ALLOWED_ORIGINS=https://your-frontend-domain.com \
  -e SOLID_QUEUE_ENABLED=true \
  ema-api
```

### **3. Deploy with Kamal**

This project is configured for deployment with Kamal:

```sh
# Set up Kamal
kamal setup

# Deploy the application
kamal deploy
```

## 📬 Contributing

Contributions are welcome! Fork the repository and open a PR.

## 📚 Documentation

Comprehensive documentation is available for developers:

- **Developer Guide**: See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for a complete guide to the project architecture, setup, and development workflow.

- **Technical Documentation**: See [docs/TECHNICAL.md](docs/TECHNICAL.md) for detailed technical information about the API architecture, data models, and integration points.

- **API Testing Guide**: See [docs/API_TESTING.md](docs/API_TESTING.md) for examples of curl commands to test the API endpoints and authentication information.

- **Code Documentation**: Generated from YARD comments in the code. To generate the documentation, run:

  ```sh
  # Install YARD if needed
  bundle install

  # Generate documentation
  bin/generate_docs

  # View in browser
  open doc/yard/index.html
  ```

- **API Documentation**: The API endpoints are documented in the [API Endpoints](#-main-endpoints) section above.

## 📝 License

MIT License.

## 💬 Contact

Email: `ismael.jouhari@gmail.com`
