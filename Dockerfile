FROM ruby:3.0.1

WORKDIR .

COPY Gemfile ./
RUN bundle install

COPY . .
RUN bundle exec rails db:migrate

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]