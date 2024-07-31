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

## Perf test output

```bash
➜  perf git:(main) ✗ wrk -t12 -c400 -d30s -s ./test_endpoints.lua http://localhost:4000
Running 30s test @ http://localhost:4000
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    23.51ms   35.13ms 239.94ms   74.80%
    Req/Sec   701.47      1.75k   11.44k    90.89%
  251084 requests in 30.10s, 2.01GB read
  Socket errors: connect 157, read 29839, write 0, timeout 0
  Non-2xx or 3xx responses: 251084
Requests/sec:   8341.74
```

## TODO

* test container build to see if it holds up better
* secret gen is not working during `docker compose up`?
* use bandit instead of cowboy: <https://github.com/mtrudel/bandit?tab=readme-ov-file> (is it faster? My guess is "not really" since I don't think that the web serving is a huge part of the time spent by the app.)
