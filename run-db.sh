#!/bin/bash

docker run -d --rm \
  --name petclinic-db \
  -p 5432:5432 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  postgres:13.2