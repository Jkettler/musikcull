require 'test_helper'

class AlbumTest < ActiveSupport::TestCase

  test 'should return album word frequency' do
    assert_equal("Monsters", Album.title_frequency.first.first)
  end
end
