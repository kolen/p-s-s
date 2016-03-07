require 'sinatra'
require 'sinatra/flash'
require 'warden'
require_relative 'models'

class Webapp < Sinatra::Base
  register Sinatra::Flash

  get '/' do
    env['warden'].authenticate!

    haml :index
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
end
