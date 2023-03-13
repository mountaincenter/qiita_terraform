FROM ruby:3.2.1
ENV LANG C.UTF-8

ENV APP_PATH /sample


RUN mkdir $APP_PATH
WORKDIR $APP_PATH

ADD Gemfile $APP_PATH/Gemfile
ADD Gemfile.lock $APP_PATH/Gemfile.lock

RUN gem install bundler
RUN bundle install

ADD . $APP_PATH

RUN mkdir -p tmp/sockets
RUN mkdir -p tmp/pids

VOLUME $APP_PATH/public
VOLUME $APP_PATH/tmp

# RUN SECRET_KEY_BASE=placeholder bundle exec rails assets:precompile