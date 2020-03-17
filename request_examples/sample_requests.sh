http PUT localhost:3001/albums/1 album:=@album.json
http POST localhost:3001/albums album:=@album.json

http PUT localhost:3001/artists/1 name:=@artist.json
http POST localhost:3001/artists name="Burgercube"
http DELETE localhost:3001/artists/1
