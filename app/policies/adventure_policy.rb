class AdventurePolicy < ApplicationPolicy
  # Tous les utilisateurs peuvent voir la liste des aventures
  def index?
    true
  end
  
  # Tous les utilisateurs peuvent voir une aventure spécifique
  def show?
    true
  end
  
  # Tous les utilisateurs authentifiés peuvent créer une aventure
  def create?
    user.present?
  end
  
  # Seul le propriétaire de l'aventure peut la mettre à jour
  def update?
    user_is_owner?
  end
  
  # Seul le propriétaire de l'aventure peut la supprimer
  def destroy?
    user_is_owner?
  end
  
  # Tous les utilisateurs peuvent rechercher des aventures
  def search?
    true
  end
  
  class Scope < Scope
    # Par défaut, montrer toutes les aventures à tous les utilisateurs
    def resolve
      scope.all
    end
    
    # Pour obtenir uniquement les aventures d'un utilisateur spécifique
    def user_adventures
      scope.where(user_id: user.id)
    end
  end
  
  private
  
  def user_is_owner?
    user.present? && record.user_id == user.id
  end
end 