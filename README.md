### Requirements clarification/questions I would typically ask Greg in the real world:
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


# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
