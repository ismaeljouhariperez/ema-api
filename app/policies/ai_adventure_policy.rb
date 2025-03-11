class AiAdventurePolicy < ApplicationPolicy
  # Seuls les utilisateurs authentifiés peuvent générer des aventures
  def generate?
    user.present?
  end
  
  # Tout le monde peut rechercher des aventures similaires
  def search_similar?
    true
  end
  
  # Seul l'utilisateur qui a lancé le job peut vérifier son statut
  # Note: cette méthode n'est pas utilisée actuellement car nous n'avons pas de moyen
  # de stocker l'utilisateur qui a lancé un job spécifique
  def status?
    user.present?
  end
end 