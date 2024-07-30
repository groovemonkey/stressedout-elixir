# Stressedout

A small web application that is designed to be stress-tested on various infrastructures, to measure performance.

## Setup

Run the postgres container:

```bash
docker run --rm --name pg_stressedout \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=stressedout \
  # this way of setting max connections doesn't work
  # -e POSTGRES_MAX_CONNECTIONS=1000 \
  # but using -N max_conns does
  -d -p 5432:5432 postgres -N 400
```

Connect to pg with `psql -h localhost -p 5432 -U postgres -d stressedout`

Delete with `docker kill pg_stressedout`

### Seeding

```bash
curl http://localhost:4000/seed
```

## Routes

* [Static pages](http://localhost:4000/static)
* [Dynamic pages (no DB)](http://localhost:4000/dynamic)
* [Dynamic pages (db reads)](http://localhost:4000/db-read)
* [Dynamic pages (db writes)](http://localhost:4000/db-write)

## Features

Just the basics, for now! (see above)
