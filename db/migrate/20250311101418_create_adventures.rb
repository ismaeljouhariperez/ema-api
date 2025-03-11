class CreateAdventures < ActiveRecord::Migration[8.0]
  def change
    create_table :adventures do |t|
      t.string :title
      t.text :description
      t.string :location
      t.float :latitude
      t.float :longitude
      t.references :user, null: false, foreign_key: true
      t.string :tags
      t.string :difficulty
      t.integer :duration
      t.float :distance

      t.timestamps
    end
  end
end
