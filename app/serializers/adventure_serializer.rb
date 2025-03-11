class AdventureSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :location, :latitude, :longitude, 
             :tags, :difficulty, :duration, :distance, :created_at, :updated_at
  
  belongs_to :user
  
  def tags
    object.tags_array
  end
  
  def user
    {
      id: object.user.id,
      email: object.user.email,
      name: object.user.name
    }
  end
end 