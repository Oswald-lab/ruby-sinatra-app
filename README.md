# Ruby Sinatra sample (happy path)

Small Sinatra 3 JSON + HTML service (in-memory todos).

- Install: `bundle install`
- Test: `bundle exec rake test`
- Run: `bundle exec rackup -p 4567` (or `bundle exec puma`) then `curl localhost:4567/health`

Detection hints: `Gemfile` with `sinatra`, `config.ru`, `app.rb`.
