require 'sequel'

Sequel.migration do
  change do
    create_table(:user_pairs) do
      primary_key :id
    end

    create_table(:user_pairs_users) do
      foreign_key :user_pair_id, :user_pairs
      foreign_key :user_id, :users
    end

    create_table(:users) do
      primary_key :id
      String :name, null: false
      String :password_hash, null: true
    end

    create_table(:rounds) do
      primary_key :id
      foreign_key :words_by, :users, null: false
      foreign_key :story_by, :users, null: false
      DateTime :created_at, null: false
    end

    create_table(:words) do
      primary_key :id
      foreign_key :category_id, :categories, null: true
      foreign_key :round_id, :rounds, null: true
      String :word, null: false
      DateTime :created_at, null: false
    end

    create_table(:categories) do
      primary_key :id
      foreign_key :user_id, :users, null: false
      String :name, null: true
    end
  end
end
