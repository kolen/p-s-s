require 'spec_helper'
require 'pry'

describe 'API' do
  let(:user) { create :user, password: 'h4ckmel0l' }

  before do
    post '/login', username: user.name, password: 'h4ckmel0l'
  end

  describe 'GET /categories' do
    before do
      create_list :category_with_words, 4, word_prefix: 'word1', user: user
    end

    it 'returns 4 categories with words' do
      get '/api/categories'
      expect(result.length).to eq(4)
      expect(result).to all(satisfy { |c| c['words'].length > 0 })
    end
  end

  describe 'POST /categories' do
    before do
      create :category_with_words, user: user
    end

    it 'creates category' do
      get '/api/categories'
      expect(result.length).to eq(1)
      post '/api/categories'
      expect(last_response).to be_created
      expect(result).to have_key 'id'
      expect(result['name']).to eq('')
      get '/api/categories'
      expect(result.length).to eq(2)
    end
  end

  describe 'POST /words/:id' do
    let(:category) { create :category, user: user }
    let(:word) { create :word, category: category }

    it 'changes word' do
      put "/api/words/#{word.id}", word: 'lolza', category_id: category.id
      expect(result['word']).to eq('lolza')
      get "/api/categories/#{word.category_id}"
      expect(result['words'].first['word']).to eq('lolza')
    end
  end

  def result
    fail 'Response is not successful' unless last_response.successful?
    JSON.parse(last_response.body)
  end
end
