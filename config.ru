require_relative 'app'
require_relative 'api'

whole_app = Rack::Builder.new do
  use Rack::Session::Cookie, secret: 'dkclsdkcdcjskdc'

  use Warden::Manager do |config|
    config.serialize_into_session(&:id)
    config.serialize_from_session { |id| User[id] }
    config.scope_defaults :default,
                          strategies: [:password],
                          action: '/unauthenticated'
    config.failure_app = Webapp
  end

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

  map '/api' do
    run API.new
  end

  run Webapp.new
end

run whole_app
