require 'sinatra'
require 'warden'
require_relative 'models'

enable :sessions

Warden::Manager.before_failure do |env, _opts|
  env['REQUEST_METHOD'] = 'POST'
end

Warden::Strategies.add(:password) do
  def valid?
    params['email'] && params['password']
  end

  def authenticate!
    u = User.authenticate!(params['email'], params['password'])
    u.nil? ? fail!('Could not log in') : success!(u)
  end
end

class PSSApp < Sinatra::Base

use Warden::Manager do |config|
  config.serialize_into_session(&:id)
  config.serialize_from_session { |id| User.get(id) }
  config.scope_defaults :default,
                        strategies: [:password],
                        action: '/unauthenticated'
  config.failure_app = self
end

get '/' do
  env['warden'].authenticate!
  # Album.db.fetch('SELECT 1+1;') do |row|
  #   puts row
  # end
end

post '/unauthenticated/?' do
  status 401
  haml :login
end

get '/login/?' do
  puts "Login!"
  haml :login
end

post '/login/?' do
  env['warden'].authenticate!
  redirect '/'
end

get '/logout/?' do
  env['warden'].logout
  redirect '/'
end

end
