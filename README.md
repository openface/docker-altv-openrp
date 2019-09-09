# AltV Docker Image + OpenRP
A docker stack for running AltV+OpenRP.

## Compose-File
The file "docker_compose.yml" creates the containers. Configure it as
needed, and run with:

```
docker-compose -f docker-compose.yml up
```

To build the container, simply pass --build option to the above command.

The template files in this repo should not need modification, as the values
are passed down from the docker-compose environment variables.

## References
- https://altv.mp
- https://github.com/team-stuyk-alt-v/altV-Open-Roleplay
