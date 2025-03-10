# EMA API (Rails 8)

## 🚀 Overview

EMA API is the backend of the EMA project, developed in **Rails 8**. It manages adventure creation and retrieval, user authentication, and provides the REST API consumed by the frontend and the AI service.

## 🛠️ Tech Stack

- **Ruby on Rails 8** (API-only mode)
- **PostgreSQL** (Primary database)
- **Devise** (User authentication)
- **Pundit** (Authorization management)
- **Geocoder** (Adventure geolocation)
- **PgSearch** (Advanced search)
- **ActiveStorage** (Image management with Cloudinary/S3)
- **Sidekiq** (Asynchronous jobs)

## 📌 Features

- ✅ RESTful API for adventures
- ✅ User authentication with JWT (Devise Token Auth)
- ✅ Adventure storage and retrieval
- ✅ Advanced search with PgSearch
- ✅ Adventure geolocation
- ✅ Integration with the AI service (FastAPI) for content generation

## 🏗️ Installation

### **1. Clone the repository**

```sh
git clone https://github.com/your-repo/ema-api.git
cd ema-api
```

### **2. Install dependencies**

```sh
bundle install
```

### **3. Configure the database**

```sh
rails db:create db:migrate
```

### **4. Start the server**

```sh
rails s
```

The API will be accessible at `http://localhost:3000`

## 🔧 Main Endpoints

| Method | Endpoint          | Description                |
| ------ | ----------------- | -------------------------- |
| GET    | `/adventures`     | List all adventures        |
| GET    | `/adventures/:id` | Retrieve adventure details |
| POST   | `/adventures`     | Create a new adventure     |
| POST   | `/users/sign_in`  | User login                 |
| POST   | `/users/sign_up`  | User registration          |

## 🚀 Deployment

### **1. Deploy with Docker**

```sh
docker build -t ema-api .
docker run -p 3000:3000 ema-api
```

### **2. Deploy to Render/Fly.io**

- Add `DATABASE_URL` and `RAILS_ENV=production`
- Run migrations with `rails db:migrate`

## 📬 Contributing

Contributions are welcome! Fork the repository and open a PR.

## 📝 License

MIT License.

## 💬 Contact

Email: `ismael.jouhari@gmail.com`
