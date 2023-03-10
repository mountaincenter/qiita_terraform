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