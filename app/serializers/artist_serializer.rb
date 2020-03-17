class ArtistSerializer
  include FastJsonapi::ObjectSerializer
  set_type :artist
  cache_options enabled: true, cache_length: 12.hours
  attribute :name
  meta do |artist|
    {
        albums_by_year: artist.albums_by_year
    }
  end
end
