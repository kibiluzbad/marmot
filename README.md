# Marmot API

## Run using docker

> You must have docker and docker-compose installed.

Run the folowing code on your terminal:

```bash
docker-compose up rethinkdb redis marmot buildworker
```

Following ports must be available:
* 3000
* 8080

Your docker sock file must exist at:

```bash
/var/run/docker.sock
```

You can access [http://localhost:3000/sidekiq/](http://localhost:3000/sidekiq/) to access sidekiq frontend.