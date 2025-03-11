# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # En développement, autoriser toutes les origines si aucune n'est spécifiée
    # En production, utiliser uniquement les origines spécifiées
    if ENV['ALLOWED_ORIGINS'].present?
      origins ENV['ALLOWED_ORIGINS'].split(',')
    else
      origins '*'  # Uniquement pour le développement
    end

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['access-token', 'expiry', 'token-type', 'uid', 'client'],
      max_age: 0
  end
end
