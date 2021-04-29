FROM ruby:2.7
WORKDIR /app

COPY kakasi.sh ./
RUN apt-get update && apt-get install -y imagemagick libsqlite3-dev
RUN sh ./kakasi.sh

COPY Gemfile ./
COPY Gemfile.lock ./
RUN bundle config --local set path 'vendor/bundle'
RUN bundle install

EXPOSE 5000