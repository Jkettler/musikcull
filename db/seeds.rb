require 'faker'

# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# https://support.discogs.com/hc/en-us/articles/360001566193-How-To-Grade-Items
conditions = ['Mint', 'Near Mint', 'Very Good Plus', 'Very Good', 'Good', 'Fair', 'Generic']
years = 1950.upto(2020).map{|n| n}

artists = []
50.times do
  artists << Artist.create({name: Faker::Music.unique.band}) rescue nil
end

artists.compact!

30.times do |i|
  album_artists = [artists.sample]
  # 10% of all fake albums are collaborations
  album_artists << artists.sample if (i % 10 == 0)
  Album.create({title: Faker::Music.unique.album, year: years.sample, condition: conditions.sample, artists: album_artists})
end

