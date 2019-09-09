# AltV Docker Image + OpenRP
A docker stack for running AltV+OpenRP.

## Compose-File
The file "docker-compose.yml" creates the containers. Configure it as
needed, and run with docker-compose.

```
docker-compose up [--build]
```

To build the container, simply pass the `--build` option or to rebuild
completely at any time:

```
docker-compose build --no-cache
```

The template files in this repo should not need modification, as the values
are passed down from the docker-compose environment variables.

## References
- https://altv.mp
- https://github.com/team-stuyk-alt-v/altV-Open-Roleplay
