FROM ruby:2.4.5
RUN apt-get update -qq && apt-get install build-essential libpq-dev nodejs -y
RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app

