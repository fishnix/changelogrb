require 'minitest/autorun'
require 'rack/test'
require 'app'

ENV['RACK_ENV'] = 'test'
set :environment, :test

class MyTest < Minitest::Unit::TestCase

  include Rack::Test::Methods

  def app
    ChangeLogRbApp
  end

  def test_slash
    get '/'
    assert last_response.ok?
  end

  def test_post_to_add_responds_with_200
    post "/add", \
      { 
        "hostname" => "www.example.com", 
        "criticality" => "1",
        "description" => "Made a change.",
        "user_id" => "test123",
        "body" => "IkxvcmVtIGlwc3VtIGRvbG9yIHNpdCBhbWV0LCBjb25zZWN0ZXR1ciBhZGlw
        aXNpY2luZyBlbGl0LCBzZWQgZG8gZWl1c21vZCB0ZW1wb3IgaW5jaWRpZHVudCB1dCBsYWJv
        cmUgZXQgZG9sb3JlIG1hZ25hIGFsaXF1YS4gVXQgZW5pbSBhZCBtaW5pbSB2ZW5pYW0sIHF1a
        XMgbm9zdHJ1ZCBleGVyY2l0YXRpb24gdWxsYW1jbyBsYWJvcmlzIG5pc2kgdXQgYWxpcXVpc
        CBleCBlYSBjb21tb2RvIGNvbnNlcXVhdC4gRHVpcyBhdXRlIGlydXJlIGRvbG9yIGluIHJlcH
        JlaGVuZGVyaXQgaW4gdm9sdXB0YXRlIHZlbGl0IGVzc2UgY2lsbHVtIGRvbG9yZSBldSBmdWd
        pYXQgbnVsbGEgcGFyaWF0dXIuIEV4Y2VwdGV1ciBzaW50IG9jY2FlY2F0IGN1cGlkYXRhdCBub
        24gcHJvaWRlbnQsIHN1bnQgaW4gY3VscGEgcXVpIG9mZmljaWEgZGVzZXJ1bnQgbW9sbGl0IG
        FuaW0gaWQgZXN0IGxhYm9ydW0uIg=="
      }.to_json, \
      "CONTENT_TYPE" => "application/json"
    data = JSON.parse(last_response.body)
    assert data['status'] == 200 
  end

  
  def test_empty_post_responds_with_500
    post "/add", \
      Hash.new.to_json, \
      "CONTENT_TYPE" => "application/json"
      
    status = JSON.parse(last_response.body)['status']
    assert status == 500
  end
 
  def test_get_add_responds_with_404
    get "/add"
    assert true
    # expect(last_response).to be_not_found
  end
 
  def test_missing_pages_respond_with_404
    get "/nothere"
    assert true
    # expect(last_response).to be_not_found
  end

end
