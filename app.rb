require 'sinatra'
require 'sinatra/flash'
require 'warden'
require_relative 'models'

enable :sessions

Warden::Manager.before_failure do |env, _opts|
  env['REQUEST_METHOD'] = 'POST'
end

Warden::Strategies.add(:password) do
  def valid?
    params['username'] && params['password']
  end

  def authenticate!
    user = User.first(name: params['username'])

    if !user.nil? && user.authenticate!(params['password'])
      success!(user)
    else
      throw(:warden, message: 'Invalid login/password combination')
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
  session[:return_to] ||= env['warden.options'][:attempted_path]
  flash[:error] = env['warden.options'][:message] || 'You must log in'
  redirect '/login'
end

get '/login/?' do
  haml :login
end

post '/login/?' do
  env['warden'].authenticate!
  flash[:success] = env['warden'].message
  redirect session[:return_to]
end

get '/logout/?' do
  flash[:success] = 'Successfully logged out'
  env['warden'].logout
  redirect '/'
end
