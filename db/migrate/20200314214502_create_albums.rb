class CreateAlbums < ActiveRecord::Migration[6.0]
  def change
    create_table :albums do |t|
      t.string :title, null: false
      t.integer :year
      t.string :condition
      t.index [:year, :title], unique: true
      t.timestamps
    end

    create_table :artists do |t|
      t.string :name, null: false
      t.index :name, unique: true
      t.timestamps
    end

    create_join_table :albums, :artists do |t|
      t.index [:album_id, :artist_id]
      t.index [:artist_id, :album_id]
    end
  end
end

