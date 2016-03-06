require 'grape'

class API < Grape::API
  format :json
  prefix :api

  before do
    env['warden'].authenticate!
  end

  use Warden::Manager do |manager|
    manager.failure_app = ->(_) { [401, {}, ['Not authorized']] }
  end

  get :hello do
    { hello: 'world' }
  end
end
