class Artist < ApplicationRecord
  has_and_belongs_to_many :albums
  include PgSearch::Model

  pg_search_scope(
      :search,
      against: %i(
      name
    ),
      using: {
          tsearch: {
              prefix: true,
              any_word: true,
              dictionary: "simple",
          }
      }
  )
end
