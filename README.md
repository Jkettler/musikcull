# README

## Musikcull Album API

### Requirements:
1. [Docker Desktop](https://docs.docker.com/get-started/#download-and-install-docker-desktop) version 19.03.5, build 633a0ea (or compatible) 
2. [docker-compose](https://docs.docker.com/compose/install/) version 1.25.4, build 8d51620a (or compatible)
3. (optional) [HTTPie](https://httpie.org/) if you want to use some of the test/helper scripts I've included to create sample data through the API. http-pie is powerful command line utility that does `curl`-like things, but is a bit friendlier to use.

### Setup Instructions:
1. Clone the project from a repo, or have somebody send you a .zip of the files
    - 1.5. **(Required if pulled remotely)** Create a file named `.env` in the top `musikcull/` directory and set a database password for the containers to use. Syntax is: `POSTGRES_PASSWORD=yourpasswordgoeshere`  
2. From the root project directory, run `./build.sh`.* This script will run `docker-compose` and then two `docker exec` commands to migrate/setup the database. After Docker does its thing, you should have downloaded images for postgres 12, ruby 2.6.2, automatically installed rails and other required gems, and booted the server running on localhost, port 3001. Docker should have also created a local network and a shared volume resource.  


**This script is just for convenience. If you don't like executing unexamined bash scripts, you can achieve the same effects by running:*
1. `docker-compose up -d --build`
2. `docker exec backend-con bash -c "RAILS_ENV=development bundle exec rails db:migrate" `
3. `source env; docker exec -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD backend-con bash -c "RAILS_ENV=test bundle exec rails db:create"`


To verify that the installation went okay, the command `docker ps` should produce something like:
```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
a341761cb6be        musikcull_backend   "bash -c 'rm -f tmp/…"   2 days ago          Up 18 hours         0.0.0.0:3001->3001/tcp   backend-con
a261e9a2fba9        postgres:12         "docker-entrypoint.s…"   2 days ago          Up 2 days           5432/tcp                 postgres-con
```
Typing `docker network ls` should produce a list with an entry like:
```
...
a31beaeca44e        musikcull_musikcull_net   bridge              local
...
```

And typing `docker volume ls` should produce a list with an entry like:
```
...
local               musikcull_db_data
...
```

The command `docker exec backend-con bash -c "RAILS_ENV=test bundle exec rails test"` should run the test suite in the rails container.


If any of that doesn't work, please contact me directly at jimmy.kettler@gmail.com for support.

Otherwise, point your web browser/httpie/curl/whatever at http://localhost:3001/albums and enjoy!

## Interacting with the Rails container
There are many benefits to running this project in Docker containers, such as doing all the setup work for you, but some point you might want to interact with the Rails environment itself to run rails or bundle tasks. To achieve this, you can execute the command:  
```
docker exec -it backend-con bash
```

After doing so, you'll have an interactive terminal inside the container named `backend-con` where you may, (for example) run `RAILS_ENV=development bundle exec rails db:seed` to seed the database with random artists and albums. Similarly, tests can be run from this environment via `RAILS_ENV=test bundle exec rails test`.  

Without creating an interactive terminal, you may run standalone commands into the container like:  
``` 
docker exec backend-con bash -c "RAILS_ENV=test bundle exec rails test"
```

# API Documentation
This API supports CRUD (and a few other) behaviors on two main routes: `/albums` and `/artists`.

You can access these endpoints with a web browser, command line tool (such as `curl` or `httpie`), or with a client library such as `nodejs`, though, using a browser with `nodejs` has not been tested and might encounter issues with `CORS`, which may require additional configuration to work properly. 

Here is an example using [HTTPie](https://httpie.org/):
 
```http DELETE localhost:3001/artists/1```

This will delete the artist with `id` of `1`

If you navigate bash-like console to the `musikcull/request_examples/` directory of the project, you can then type things such as:  
```http POST localhost:3001/albums album:=@album.json```   
which will create a new album (and artists, if they don't exist already). This command references the `album.json` file in that same directory, so must be run from there.

Creating complicated objects in the command line can get unwieldy, but a simple example to update an album's title might look like:  
```http PUT localhost:3001/albums/2 title="Burgercube"```

The following endpoints are available for either `/albums` or `/artists` (shown here with `/albums`):
```
  Verb   URI Pattern                Notes                               Example

   GET    /albums/search            # Must provide search_term          /search?search_term=Monster
   GET    /albums/page              # No arg returns the first page
   GET    /albums(/page/:page)      # Provide page number               /albums/page/5
   GET    /albums             
   POST   /albums             
   GET    /albums/:id         
   PUT    /albums/:id         
   DELETE /albums/:id  
```

`POST`ing to create a new album will accept nested parameters for artist(s) as well. If the provided string artist names don't exist already, they will be created.
## Collection Results
Requests that return a collection return the results quickly by minimizing the number of queries and the amount of processing required. As such, the format for albums, which contains nested artist data, contains two top-level `json` objects, `"data"` and `"included"`, organized like this:

```json
{
    "data":
      [{"id":"27","type":"album","attributes":{"id":27,"title":"Brand New Eyes","year":2009,"condition":"Good"},
        "relationships":
          {"artists":
            {"data":
            [{"id":"23","type":"artist"}]}}}],
    
    "included":
      [{"id":"23","type":"artist","attributes":{"name":"Paramore"},
        "relationships":{},
        "meta":{"albums_by_year":{"2009":1}}}]
}
```  

To minimize response time on the API's part, it is up to the consumer of this API to combine these data, relevant to their use case.  


## Searching/Filtering

Either albums or artists can be searched by their names or titles respectively by `GET`ting `/search` and providing a `search_term` parameter.

For example visiting:  `http://localhost:3001/albums/search?search_term=pep`, will partially match any album titles containing "Pep", "pep", "pepp", "Pepper", "Sgt. Pepper's Lonely Hearts Club Band", etc.

In this way, live filtering of results can be achieved by sending new requests as the user types, e.g. `search_term=pep`, then `search_term=pepp`, then `search_term=pepper`, etc., narrowing the results each time.

Search results are not paginated.


## Artist and Album special features
Extra info detailing how many albums each artist released in each year is available and included as `meta` in all artist results. It is nested in the result like:

```json
{
  "meta":{
    "albums_by_year":
      {"1962":1,"2001":1}}
}
```
This could also be available as a separate endpoint, but it was decided it would be more interesting/useful to do it like this.

Extra info about the frequency of words in album titles can be access via the endpoint: `/albums/title_frequency`. 

A `GET` request to this endpoint will return a sorted array of values, each value itself being an array containing the word and the frequency, e.g.:

```json
[["Of",8],["Monsters",6],["Rock",6],["V.",6]]
```
This means that `Of` is the most frequent word appearing in album titles, with a frequency of 8. In the context of this feature, all words are called with ruby's `String#capitalize`, so "Rock", "ROCK", and "rOcK" are all considered the same word ("Rock"). 


## Paginated Results
Requests to `/albums` or `/artists` return paginated results, except when searching. The default number of results per page is 10, but that can be changed by modifying the `default_per_page` option in `config/initializers/kaminari_config.rb` and then restarting the rails server.

Pages can be traversed by appending `/page/[number]` to the end of the URL, e.g.: `/albums/page/4`.

