# Configuration de Solid Queue
require 'solid_queue'

# Configuration de l'interface web Solid Queue avec authentification
Rails.application.config.to_prepare do
  SolidQueue::ApplicationController.class_eval do
    http_basic_authenticate_with(
      name: ENV.fetch('SOLID_QUEUE_WEB_USER', 'admin'),
      password: ENV.fetch('SOLID_QUEUE_WEB_PASSWORD', 'password')
    )
  end
end

# Configuration des files d'attente
SolidQueue.configure do |config|
  # Charger la configuration depuis le fichier YAML
  config.polling_interval = Rails.application.config_for(:solid_queue)[Rails.env.to_sym][:polling_interval]
  
  # Définir les files d'attente prioritaires
  config.queues = [
    { name: 'ai_generation', priority: 3 },
    { name: 'mailers', priority: 2 },
    { name: 'default', priority: 1 }
  ]
end 