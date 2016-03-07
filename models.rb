require 'sequel'
require 'bcrypt'
require 'logger'
require_relative 'config'

Sequel::Model.db = Sequel.connect(settings.database, encoding: 'utf-8')
Sequel::Model.db.loggers << Logger.new($stderr)
Sequel::Model.raise_on_save_failure = true
Sequel::Model.plugin :json_serializer

if settings.run_migrations
  Sequel.extension :migration
  Sequel::Migrator.run(Sequel::Model.db,
                       File.expand_path('../migrations', __FILE__))
end

class User < Sequel::Model
  include BCrypt
  one_to_many :categories

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def authenticate!(password)
    self.password == password
  end
end

class UserPair < Sequel::Model
  many_to_many :users
end

class Round < Sequel::Model
  many_to_one :user, key: :words_by
  many_to_one :user, key: :story_by
  one_to_many :words

  def validate
    super
    if words.count != words_count
      errors.add(:words, 'must contain #{words_count} words')
    end
  end

  def words_count
    5
  end
end

class Word < Sequel::Model
  many_to_one :round
  many_to_one :category
end

class Category < Sequel::Model
  many_to_one :user
  one_to_many :words

  def to_json(*_)
    super(include: :words)
  end
end
