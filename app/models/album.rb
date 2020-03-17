class Album < ApplicationRecord
  has_and_belongs_to_many :artists
  accepts_nested_attributes_for :artists
  include PgSearch::Model

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

  def update_nested_attributes(params)
    update(Album.objectify_string_params(params))
  end


  class << self

    def objectify_string_params(params)
      if (artists = params[:artists])
        map = artists.map do |artist_name|
          Artist.find_or_create_by(artist_name)
        end
        return params.merge({artists: map}) if map.any?
      end
      params
    end

    def create_with_nested_attributes(params)
      Album.new(objectify_string_params(params))
    end

    def search_with_artists(term)
      Album.includes(:artists).search(term)
    end

    def title_frequency
      # If Greg wanted stopwords removed, he should have said so
      Album
        .pluck(:title)
        .flat_map{|t| t.split(' ')}
        .each_with_object(Hash.new(0)){ |value, hash| hash[value.capitalize] += 1}
        .sort_by{|_,v| -v}
    end
  end
end
