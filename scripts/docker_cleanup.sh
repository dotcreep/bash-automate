#!/bin/bash

# Docker image cleanup
docker image prune -f

# Docker system cleanup
docker system prune -f