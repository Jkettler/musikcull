class Artist < ApplicationRecord
  has_many :album_artists
  has_and_belongs_to_many :albums
end
