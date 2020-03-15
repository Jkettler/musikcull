FROM ruby:2.6.2

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

ENV APP_ROOT=/musikcull
WORKDIR ${APP_ROOT}

RUN gem install bundler

COPY . .

RUN bundle install

RUN RAILS_ENV=development bundle exec rails db:migrate

