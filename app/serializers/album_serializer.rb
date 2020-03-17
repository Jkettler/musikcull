class AlbumSerializer
  include FastJsonapi::ObjectSerializer

  set_type :album  # optional
  attributes :id, :title, :year, :condition
  has_many :artists

  cache_options enabled: true, cache_length: 12.hours
end
