#require 'sinatra/sequel'
require 'sqlite3'

configure :development do
  set :session_secret, 'grob666'
  set :database, 'sqlite://development.sqlite'
end

configure :test do
  set :session_secret, 'testtest'
  set :database, 'sqlite::memory:'
end
