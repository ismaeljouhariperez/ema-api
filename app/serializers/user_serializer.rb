class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :nickname, :created_at
  
  # Ne pas inclure les aventures par défaut pour éviter les réponses trop volumineuses
  # Les aventures seront chargées séparément via l'API des aventures
end 