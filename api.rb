require 'grape'

class API < Grape::API
  prefix :api

  get :hello do
    [{ hello: 'world' }]
  end
end
