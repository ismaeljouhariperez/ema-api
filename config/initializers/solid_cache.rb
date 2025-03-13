# Configuration de Solid Cache
require 'solid_cache'

# Configuration globale de Solid Cache
SolidCache.configure do |config|
  # Durée d'expiration par défaut (1 jour)
  config.expires_in = 1.day
  
  # Intervalle de nettoyage des entrées expirées (1 heure)
  config.cleanup_interval = 1.hour
  
  # Taille maximale du cache en nombre d'entrées (10 000 par défaut)
  config.max_entries = ENV.fetch('SOLID_CACHE_MAX_ENTRIES', 10_000).to_i
end 