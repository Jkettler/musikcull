#!/bin/bash
source .env

docker-compose up -d --build &&
sleep 5 # wait for docker to finish spinning up
docker exec backend-con bash -c "RAILS_ENV=development bundle exec rails db:migrate" &&
sleep 5
docker exec -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD backend-con bash -c "RAILS_ENV=test bundle exec rails db:create"




