
require 'spec_helper'
require 'auth/none'

describe Sinatra::NoneAuth do
  
  def setup_app
    @authapp = nil
    mock_app do
      register Sinatra::NoneAuth
      set :sessions, true
      @authapp = self
      @authapp.get('/foo') { authorize! }
    end
  end
  
  before(:each) do
    setup_app
  end
  
  it 'should return true' do
    get '/foo'
    expect(last_response).to be_ok
    expect(last_request.env['rack.session']['user_id']).to eq('user')
    expect(last_request.env['rack.session']['authorized']).to eq(true)
  end
end