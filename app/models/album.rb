class Album < ApplicationRecord
  has_and_belongs_to_many :artists
  include PgSearch::Model

  scope :with_artists, -> {Kaminari.paginate_array(connection.execute(QUERY).to_a)}


  QUERY =  <<-SQL
          SELECT albums.*, json_agg(artists.name) AS artists
          FROM "albums" INNER JOIN "albums_artists" ON "albums_artists"."album_id" = "albums"."id" INNER JOIN "artists" ON "artists"."id" = "albums_artists"."artist_id"
          group by albums.id;
  SQL


  pg_search_scope(
      :search,
      against: %i(
      title
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
