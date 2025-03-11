# @author EMA Team
# @since 0.1.0
#
# Représente une micro-aventure dans le système EMA.
# Une aventure appartient à un utilisateur et contient des informations
# géographiques et descriptives sur une activité de plein air.
#
# @example Création d'une nouvelle aventure
#   adventure = Adventure.new(
#     title: "Randonnée au Lac Bleu",
#     description: "Une belle randonnée avec vue panoramique",
#     location: "Lac Bleu, Pyrénées",
#     tags: "randonnée,nature,montagne",
#     difficulty: "modérée",
#     duration: 180,
#     distance: 12.5,
#     user: current_user
#   )
#   adventure.save
class Adventure < ApplicationRecord
  # @!attribute [r] id
  #   @return [Integer] L'identifiant unique de l'aventure
  
  # @!attribute [rw] title
  #   @return [String] Le titre de l'aventure
  
  # @!attribute [rw] description
  #   @return [String] La description détaillée de l'aventure
  
  # @!attribute [rw] location
  #   @return [String] L'emplacement textuel de l'aventure
  
  # @!attribute [rw] latitude
  #   @return [Float] La latitude géographique de l'aventure
  
  # @!attribute [rw] longitude
  #   @return [Float] La longitude géographique de l'aventure
  
  # @!attribute [rw] tags
  #   @return [String] Les tags associés à l'aventure, séparés par des virgules
  
  # @!attribute [rw] difficulty
  #   @return [String] Le niveau de difficulté de l'aventure (facile, modérée, difficile)
  
  # @!attribute [rw] duration
  #   @return [Integer] La durée estimée de l'aventure en minutes
  
  # @!attribute [rw] distance
  #   @return [Float] La distance de l'aventure en kilomètres
  
  # @!attribute [rw] user_id
  #   @return [Integer] L'identifiant de l'utilisateur propriétaire
  
  # @!attribute [r] created_at
  #   @return [DateTime] La date de création de l'aventure
  
  # @!attribute [r] updated_at
  #   @return [DateTime] La date de dernière modification de l'aventure
  
  # @!association
  #   @return [User] L'utilisateur propriétaire de cette aventure
  belongs_to :user
  
  # Configuration de la géolocalisation
  # @note Utilise la gem Geocoder pour convertir l'adresse en coordonnées
  geocoded_by :location
  after_validation :geocode, if: ->(obj) { obj.location.present? && obj.location_changed? }
  
  # Configuration de la recherche plein texte
  # @note Utilise la gem pg_search pour la recherche dans PostgreSQL
  include PgSearch::Model
  pg_search_scope :search_by_title_and_description,
                  against: {
                    title: 'A',
                    description: 'B',
                    location: 'C',
                    tags: 'D'
                  },
                  using: {
                    tsearch: { prefix: true }
                  }
  
  # Validations des données
  validates :title, presence: true
  validates :description, presence: true
  validates :location, presence: true
  
  # Convertit la chaîne de tags en tableau
  # @return [Array<String>, nil] Un tableau de tags ou nil si aucun tag n'est présent
  # @example
  #   adventure.tags = "randonnée,nature,montagne"
  #   adventure.tags_array # => ["randonnée", "nature", "montagne"]
  def tags_array
    tags.split(',').map(&:strip) if tags.present?
  end
end
