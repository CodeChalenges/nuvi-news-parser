[![Build Status](https://travis-ci.org/mauricioklein/nuvi-news-parser.svg?branch=master)](https://travis-ci.org/mauricioklein/nuvi-news-parser)
[![Code Climate](https://codeclimate.com/github/mauricioklein/nuvi-news-parser/badges/gpa.svg)](https://codeclimate.com/github/mauricioklein/nuvi-news-parser)
[![Test Coverage](https://codeclimate.com/github/mauricioklein/nuvi-news-parser/badges/coverage.svg)](https://codeclimate.com/github/mauricioklein/nuvi-news-parser/coverage)
[![Issue Count](https://codeclimate.com/github/mauricioklein/nuvi-news-parser/badges/issue_count.svg)](https://codeclimate.com/github/mauricioklein/nuvi-news-parser)
[![Dependency Status](https://gemnasium.com/badges/github.com/mauricioklein/nuvi-news-parser.svg)](https://gemnasium.com/github.com/mauricioklein/nuvi-news-parser)

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

Sidekiq and workers logs will be saved in *logs/sidekiq.log*.

Sidekiq PID, as well the number of busy and total workers, can be found with *ps* command:

```sh
$ ps aux | grep sidekiq | grep -v grep
```

> By default, Sidekiq starts with **25 workers**. This number can be adjusted with the argument *-c [number of workers]*

Since parser is built as a Ruby module, we need a Ruby environment to dispatch it. So:

```sh
$ irb
```

Redis server can be refered by the hostname **redis**, port **6379**. So, to connect to Redis using [Redis Ruby client](https://github.com/redis/redis-rb):

```ruby
$ require 'redis'

# Redis will hold a connection to Redis server
$ redis = Redis.new(host: 'redis', port: 6379)
```

And finally, to run the parser:

```ruby
$ require_relative 'nuvi-news-parser'

$ NewsParser.run('http://bitly.com/nuvi-plz')
```

## Future Works

* Running locally, with 25 workers, i7 processor and 4Gb RAM, the parser is able to process ~1k news/second. However, to acquire a more reliable metric, benchmark tests must be added;
* Since HTTP folder content is dynamic, a nice enhancement would be to transform the parser module in a daemon, which will be pooling the HTTP folder for new zip files and sending them automatically to Sidekiq;
