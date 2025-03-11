class UserPolicy < ApplicationPolicy
  # Seul l'utilisateur lui-même peut voir son profil complet
  def show?
    user.present? && user.id == record.id
  end
  
  # Seul l'utilisateur lui-même peut mettre à jour son profil
  def update?
    user.present? && user.id == record.id
  end
  
  # Tout le monde peut voir les aventures d'un utilisateur
  def adventures?
    true
  end
  
  # Seul l'utilisateur lui-même peut voir son profil
  def profile?
    user.present? && user.id == record.id
  end
  
  class Scope < Scope
    def resolve
      # Par défaut, les utilisateurs ne peuvent voir que leur propre profil
      scope.where(id: user.id)
    end
  end
end 