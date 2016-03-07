require 'rack/test'
require 'rspec'
require 'database_cleaner'
require 'factory_girl'
require 'pry'
require 'sequel'
require_relative './factories.rb'

ENV['RACK_ENV'] = 'test'

OUTER_APP = Rack::Builder.parse_file('config.ru').first

module RSpecMixin
  include Rack::Test::Methods
  def app
    OUTER_APP
  end
end

DatabaseCleaner[:sequel, { connection: Sequel::Model.db }]

RSpec.configure do |c|
  c.include RSpecMixin
  c.include Rack::Test::Methods
  c.include FactoryGirl::Syntax::Methods

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
