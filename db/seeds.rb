# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

artists = Artist.create([{ name: 'The Beatles' }, {name: 'Radiohead'}])
Album.create(
    [
        {title: 'Rubber Soul', condition: 'Good', year: 1965, artists: [artists.first]},
        {title: 'Hail to the Thief', condition: 'New', year: 2003, artists: [artists[1]]}
    ])
