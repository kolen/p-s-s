require 'spec_helper'

describe 'Login' do
  let(:user) { create :user, password: 's00p3rh4x0r' }

  it 'redirects to /login if not authenticated' do
    get '/'
    expect(last_response).to be_redirect
    expect(last_response['Location']).to match(%r{/login/?$})
  end

  context 'with valid credentials' do
    before do
      post '/login', username: user.name, password: 's00p3rh4x0r'
    end

    it 'redirects' do
      expect(last_response).to be_redirect
    end

    it "doesn't redirect on '/' after that" do
      get '/'
      expect(last_response).to be_ok
    end
  end
end
