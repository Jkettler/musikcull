http POST localhost:3001/albums album:=@album.json
http PUT localhost:3001/albums/1 album:=@album.json

http POST localhost:3001/artists name="Burgercube"
http POST localhost:3001/artists name:=@artist.json
