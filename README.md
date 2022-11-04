# TopScoreRanking

This application provides a simple api to:
* register scores for a given player
* search the scores by players and dates
* get score history and basic stats for a given player

It is built using:
* Ruby 3.0.1
* Rails 6.1.3.2
* sqlite3

It uses Kaminari to provide pagination support to Active Record queries and Swagger Blocks for rest api documentation generation

Getting started
---------------

To get the application up and running:
* clone this repository
* make sure you have installed Ruby 3.* and it is being used in your terminal shell
    * you can verify the version by executing `ruby -v`
* run `bundle install` to install all the required gems
* run `bundle exec rails db:migrate` to prepare the local database
* run `bundle exec rails s` to start the server
    * the server will be available at http://localhost:3000/

Alternatively if you have docker installed simply run: `docker-compose up` from the root of the repository, this will:
* create an image if missing by:
    * create an image starting from Ruby:3.0.1 image
    * copy the Gemfile and install the dependencies
    * copy the sources over to the image
    * run db:migrate to initialize the sqllite3 local database
    * setup to start the rails server when the container is started
* run the service and expose the port 3000
* access the api via http://localhost:3000 as you would if you had started it locally.

N.B. If you run bundle install locally, before creating the docker image, make sure you're using the same cpu architecture as the image.
If you compile on a M1 Mac mini, delete Gemfile.lock before creating the docker image as it might reference some Arm64 specific dependencies that will not work with the base ruby image.

    

Executing the Specs
-------------------

This application uses RSpec to test the functionality of the modules and the api

To execute the specs run:
`bundle exec rspec`

You can execute `bundle exec rspec --format documentation` to get a more verbose output.


Project Structure
-----------------

The project has one single model: `score` which also provides additional class methods for composable ActiveRecord::Relation:
* `Score.by_players(players)` where players can be a string or a list, 
* `Score.before(datetime)` and `Score.after(datetime)` to filter the scores by a given DateTime object

The JSON API is divided across two controllers:
* `ScoresController` which provides the basic CRUD (minus Update) and Search functionality for the scores
  * `POST /api/scores` to submit a score
  * `GET /api/scores/{id}` to retrieve a score object by id
  * `DELETE /api/scores/{id}` to delete a score
  * `GET /api/scores?page=1&size=10&players=player1&before=2021-05-15T20:18:22Z&after=2021-05-14T20:18:22Z` to search for scores
    * for `before` and `after` parameters, use ISO8601 DateTime format
    * when using a timezone with the [+-]00:00 format, make sure to encode the URI
* `HistoryController` which provides the Player score history and statistics
  * `GET /api/player/{player_id}/history` to retrieve the player's scores and statistics
    * if the player ID is not found, it will simply return empty statistics with a 200 status code.
  
The statistics aggregation is implemented in the util class `HistoryUtils`.
The method `aggregate_scores` takes a list of scores, and returns an object with the following properties:
* `high_score` for the first highest score encountered in the list, respecting the order given in input
* `low_score` for the first lowest score encountered in the list, respecting the order given in input
* `avg_score` calculated across the entire list of scores
* `scores` the given list.

N.B. The `aggregate_scores` method will ignore and remove the player and the id from the score objects in the list. 
If a list is passed that contains scores of multiple players, the aggregations will not be split by player.

Run the application and open http://localhost:3000/ in the browser to get a homepage with links to:
* [RDoc documentation](http://localhost:3000/docs/index.html)
* [Swagger JSON API documentation](http://localhost:3000/swagger/index.html)


Documentation
-------------

* Swagger api documentation is automatically generated at runtime
* To Re-generate RDoc documentation run `./generate_rdocs.sh` to generate the docs and place them unter /public/docs so that they will be served by the application directly.
