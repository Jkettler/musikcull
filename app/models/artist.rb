class Artist < ApplicationRecord
  has_and_belongs_to_many :albums
  include PgSearch::Model
  validates_uniqueness_of :name

  pg_search_scope(
  :search,
        against: %i( name ),
        using: {
          tsearch: {
            prefix: true,
            any_word: true,
            dictionary: "simple",
          }
        }
  )

  def albums_by_year
    self.albums.group(:year).count
  end
end
