require 'sequel'
require 'bcrypt'
require_relative 'config'

# rubocop:disable Style/Documentation

Sequel::Model.db = Sequel.connect(settings.database, encoding: 'utf-8')

class User < Sequel::Model
  include BCrypt

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def authenticate!(password)
    puts "authenticate"
    true
  end
end

class UserPair < Sequel::Model
  many_to_many :users
end

class Round < Sequel::Model
  many_to_one :user, key: :words_by
  many_to_one :user, key: :story_by
  one_to_many :words
end

class Word < Sequel::Model
  many_to_one :round
  many_to_one :category
end

class Category < Sequel::Model
  many_to_one :user
  one_to_many :words
end
