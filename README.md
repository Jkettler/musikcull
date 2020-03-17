# README

## Musikcull Album API

### Requirements:
1. [Docker Desktop](https://docs.docker.com/get-started/#download-and-install-docker-desktop) version 19.03.5, build 633a0ea (or compatible) 
2. [docker-compose](https://docs.docker.com/compose/install/) version 1.25.4, build 8d51620a (or compatible)
3. (optional) [HTTPie](https://httpie.org/) if you want to use some of the test/helper scripts I've included (and used to test portions of the API). http-pie is powerful command line utility that does `curl`-like things, but is a bit friendlier to use.

### Setup Instructions:
1. Clone the project from a repo, or have somebody send you a .zip of the files
2. From the root project directory, run `./build.sh`.* This script will run `docker-compose` and then two `docker exec` commands to migrate/setup the database. After Docker does its thing, you should have downloaded images for ruby 2.6.2, postgres 12, automatically installed rails and other required gems. Docker should have also created a local network and a shared volume resource.  

*This script is just for convenience. If you don't like executing unexamined bash scripts, you can achieve the same effects by running:*
1. `docker-compose up -d --build`
2. `docker exec backend-con bash -c "RAILS_ENV=development bundle exec rails db:migrate" `
3. `source env; docker exec -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD backend-con bash -c "RAILS_ENV=test bundle exec rails db:create"`



To verify that the installation went okay, typing `docker ps` should produce something like:
```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
a341761cb6be        musikcull_backend   "bash -c 'rm -f tmp/…"   2 days ago          Up 18 hours         0.0.0.0:3001->3001/tcp   backend-con
a261e9a2fba9        postgres:11         "docker-entrypoint.s…"   2 days ago          Up 2 days           5432/tcp                 postgres-con
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

If any of that doesn't work, please contact me directly at jimmy.kettler@gmail.com for support.

Otherwise, point your web browser, httpie/curl scripts at http://localhost:3001/albums and enjoy!

## Interacting with the Rails container
Running this project in containers does all the setup work for you, but some point you might want to get an interactive terminal to perform rails or bundle tasks. To achieve this, you can type 
```
docker exec -it backend-con bash
```

After doing so, you may, for example run `RAILS_ENV=development bundle exec rails db:seed` to seed the database with random artists and albums. Similarly, tests can be run from this environment via ` RAILS_ENV=test bundle exec rails test`.  

Without creating an interactive terminal, you may run standalone commands into the container like 
``` 
docker exec backend-con bash -c "RAILS_ENV=test bundle exec rails test"
```

# API Documentation
This API supports CRUD (and a few other) behaviors on two main routes: `/albums` and `/artists`.

You may access these endpoints with a web browser, command line tool (such as `curl` or `httpie`), or with a client library such as `nodejs`, though, using a browser with `nodejs` has not been tested and might encounter issues with `CORS`, which would require additional configuration to work properly. 

Here is an example using [HTTPie](https://httpie.org/):
 
```http DELETE localhost:3001/artists/1```

This will delete the artist with `id` of `1`

If you navigate bash-like console to the `musikcull/request_examples/` directory of the project, you can then type things such as:  
```http POST localhost:3001/albums album:=@album.json```   
which will create a new album (and artists, if they don't exist already). However, this example references the `album.json` file in that same directory, so must be run from there.

Creating complicated objects in the command line can get unwieldy, but a simple example to update an album's title might look like:  
```http PUT localhost:3001/albums/2 title="Burgercube"```

The following endpoints are available for either `/albums` or `/artists` (shown here with `/albums`):
```
  Verb   URI Pattern

   GET    /albums/search      
   GET    /albums/page        # No page argument returns the first page
   GET    /albums(/page/:page)
   GET    /albums             
   POST   /albums             
   GET    /albums/:id         
   PUT    /albums/:id         
   DELETE /albums/:id  
```

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


# Testing
1. Testing could be more robust.


 #\# End of README
  
### Side notes/Requirements clarifications/questions I would typically ask Greg in the real world:
1. Do record conditions adhere to some standard/industry grading scale, or does Greg want a text field? (Determines validation strategy)
2. Regarding pagination, how big should should the page size be? 
3. Searching and filtering are different things, but the reqs are ambiguous. Should a filter/search query respond with all matches, or just those on the current page? 
    - If the former, should search results be paginated as well? 
    - If the latter, wouldn't that be better suited as a frontend task? Why ask the server for less data than you currently already have?
    - What fields to search on?
4. Should artist names be unique? What about stopwords (Are 'Beatles' and 'The Beatles' the same artist?)
5. The project reqs do not mention creating records, only updating them. How to create data? 
    - One at a time? 
    - Batches? 
    - Imported CSV? 
    - OCR bulk import delayed job from handwritten notes using AWS lambda?? //maybe next sprint
    
#### Since Greg wasn't around to ask, I went with the following:
1. No limitations on what record conditions are. Easier, more flexible
2. 10, but can be adjusted by modifying `config.default_per_page` value in `config/initializers/kaminari_config.rb` (Note: This configuration is set during initialization, so you must restart the rails server after modifying it. You can restart it with the command: `docker-compose restart backend-con`)
3. The most straightforward thing. Search album titles and artists names through separate endpoints
4. For a V1 and since Greg isn't responding to Slack messages (maybe someone should check on him?), I went with a simple uniqueness constraint on artist names only. I thought about unique combined indexes on albums like `[:title, :year]` or `[:title, :condition]` but since the presence of a `condition` field on an album implies an album entry per physical copy, it just didn't make sense to constrain any of those fields.
5. I added CREATE/DELETE endpoints for both albums and artists, even though they weren't specifically requested. Deleting an artist won't delete associated albums, or vice versa.


Thanks, this was fun!

Jimmy
