class ArtistSerializer
  include FastJsonapi::ObjectSerializer

  # cache_options enabled: true, cache_length: 12.hours
  attributes :name
  # has_many :albums
end
