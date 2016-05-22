# Nuvi News Parser

**Nuvi news parser** is a parser, written in Ruby, that automate the action of downloading zip files from a web page and index its content in Redis.

## Dependencies

This project depends on:

* Ruby v2.3.1 or above;
* Redis v3.2.0 or above;
* [Docker](https://docs.docker.com/engine/installation/) v1.9.1 or above;
* [Docker Compose](https://docs.docker.com/compose/install/) v1.2.0 or above;

## Architecture

The whole work performed in a zip file (donwload, extraction and news processing) is performed asynchronously, using *Sidekiq* workers.

The Redis related operations (news insertion, content duplication recognition, etc) is wrapped in a singleton service.

So, the basic workflow is:

1. Parser reads the HTML page and fetch all zip entries;
2. For each zip entry, Parser send a new job request to Sidekiq queue;
3. A free Sidekiq worker will process the next job on queue, performing:
  1. Zip file download;
  2. Zip extraction;
  3. News file processing;
  4. Mark zip and news file as processed (avoid reprocessing and reinsertion in Redis);

## Environment

The whole environment is prepared using *Docker*.

This choice was made aiming an easy way to lift all necessary dependencies, without needing to deal with version and configuration related problems.

So, to lift the project + Redis server, go to project root path and run:

```sh
$ docker-compose run app bash
```

The command above will prepare and start the necessary containers and put you in a shell inside the root folder of parser container.

Once inside the container, let's install necessary gems, running:

```sh
$ bundle install
```

After bundler is done, we're ready to use the system.

## Testing

The project uses RSpec framework to test the system.

To run the test suite:

```sh
$ rspec
```

## Running

First we need to start the Sidekiq server, responsable to control the jobs queue and workers lifecycle.

So, to start Sidekiq server in background mode:

```sh
$ bundle exec sidekiq -r ./config/sidekiq.rb -L logs/sidekiq.log -d
```

Sidekiq logs will be saved in *logs/sidekiq.log*.

> By default, Sidekiq starts with **25 workers**. This number can be adjusted with the argument *-c [number of workers]*

And finally, to run the parser, dispatch a new IRB session...

```sh
$ irb
```

... require parser and run it:

```ruby
$ require_relative 'nuvi-news-parser'

$ NewsParser.run('http://bitly.com/nuvi-plz')
```
