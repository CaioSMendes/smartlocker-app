FROM ruby:3.1.2
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    tzdata \
    nodejs \
    yarn \
    postgresql-client
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN gem install rails bundler
RUN bundle install
COPY . .
EXPOSE 3000
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0"]