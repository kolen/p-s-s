require 'grape'

class API < Grape::API
  format :json

  before do
    env['warden'].authenticate!
  end

  get :hello do
    require 'pry'
    { hello: env['warden'].user }
  end
end
