require 'grape'

class API < Grape::API
  format :json

  before do
    env['warden'].authenticate!
  end

  helpers do
    def current_user
      env['warden'].user
    end

    def current_category
      @current_category ||=
        current_user.categories_dataset[id: params[:category_id]]
    end
  end

  resource :categories do
    desc 'List all current user categories with word'
    get do
      current_user.categories_dataset
    end

    desc 'Create category'
    params do
      optional :name, type: String
    end
    post do
      current_user.add_category name: params[:name]
    end

    route_param :category_id do
      get do
        current_category
      end

      desc 'Set category name'
      params do
        optional :name, type: String
      end
      put do
        current_category.name = params[:name]
        current_category.save_changes
        current_category
      end
    end
  end

  resource :words do
    desc 'Create word'
    params do
      requires :word, type: String
      requires :category_id, type: Integer
    end
    post do
      puts params[:category_id]
      category = current_user.categories_dataset[params[:category_id]]
      puts category.id
      category.add_word word: params[:word], created_at: Time.now.utc
    end

    route_param :word_id do
      desc 'Modify word'
      params do
        requires :word, type: String
        requires :category_id, type: Integer
      end
      put do
        word = Word.where(user: current_user, id: params[:word_id])
        word.category_id = current_user.categories[:category_id]
        word.word = params[:word]
        word.save_changes
      end
    end
  end
end
