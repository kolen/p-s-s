require 'rack/test'
require 'rspec'
require 'database_cleaner'
require 'factory_girl'
require 'pry'
require 'sequel'
require_relative './factories.rb'

ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'

module RSpecMixin
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end
end

DatabaseCleaner[:sequel, { connection: Sequel::Model.db }]

RSpec.configure do |c|
  c.include RSpecMixin
  c.include Rack::Test::Methods
  c.include FactoryGirl::Syntax::Methods

  c.before(:each) do
  end

  c.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  c.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
