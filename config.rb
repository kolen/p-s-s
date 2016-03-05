require 'sqlite3'

configure :development do
  set :session_secret, 'grob666'
  set :database, 'sqlite://development.sqlite'

  set :run_migrations, false
end

configure :test do
  set :session_secret, 'testtest'
  set :database, 'sqlite::memory:'

  set :run_migrations, true
end
