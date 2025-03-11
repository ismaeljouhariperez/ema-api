class Adventure < ApplicationRecord
  belongs_to :user
  
  # Géolocalisation
  geocoded_by :location
  after_validation :geocode, if: ->(obj) { obj.location.present? && obj.location_changed? }
  
  # Recherche
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
  
  # Validations
  validates :title, presence: true
  validates :description, presence: true
  validates :location, presence: true
  
  # Méthodes
  def tags_array
    tags.split(',').map(&:strip) if tags.present?
  end
end
