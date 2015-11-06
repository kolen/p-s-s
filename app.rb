require 'sinatra'
require 'warden'
require_relative 'models'

enable :sessions

Warden::Manager.before_failure do |env, _opts|
  env['REQUEST_METHOD'] = 'POST'
end

Warden::Strategies.add(:password) do
  def valid?
    puts "params: #{params['email']}, #{params['password']}"
    params['username'] && params['password']
  end

  def authenticate!
    user = User.first(name: params['username'])

    if user.nil?
      puts "user nil"
      throw(:warden, message: "The username you entered does not exist.")
    elsif user.authenticate!(['password'])
      success!(user)
    else
      throw(:warden, message: "The username and password combination ")
    end
  end
end

use Warden::Manager do |config|
  config.serialize_into_session(&:id)
  config.serialize_from_session { |id| User.get(id) }
  config.scope_defaults :default,
                        strategies: [:password],
                        action: '/unauthenticated'
  config.failure_app = Sinatra::Application
end

get '/' do
  env['warden'].authenticate!
end

post '/unauthenticated/?' do
  redirect '/login'
end

get '/login/?' do
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

#u = User.new
#u.name='test'
#u.password='qwerty'
#u.save
