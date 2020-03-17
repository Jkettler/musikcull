require 'test_helper'

class ArtistTest < ActiveSupport::TestCase

  setup do
    @artist = Artist.create(name: "Buck Cherry", albums: [albums(:one), albums(:two)])
  end

  test 'should count and group albums by year' do
    assert_equal({2002 => 1, 2003 => 1}, @artist.albums_by_year)
  end
end
