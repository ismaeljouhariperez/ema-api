# Configuration de Sidekiq
require 'sidekiq'
require 'sidekiq/web'

# Configuration du serveur Redis pour Sidekiq
redis_config = { url: ENV['REDIS_URL'] || 'redis://localhost:6379/0' }

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end

# Configuration de l'interface web Sidekiq
# En production, vous voudrez probablement protéger cette route avec une authentification
Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  # Comparaison sécurisée pour éviter les attaques timing
  ActiveSupport::SecurityUtils.secure_compare(user, ENV['SIDEKIQ_WEB_USER'] || 'admin') &
    ActiveSupport::SecurityUtils.secure_compare(password, ENV['SIDEKIQ_WEB_PASSWORD'] || 'password')
end 