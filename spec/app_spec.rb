
ENV['RACK_ENV'] = 'test'

require 'app'
require 'spec_helper'
require 'support/fakeredis'

describe "The ChangeLogRb App" do
  include Rack::Test::Methods

  def app
    ChangeLogRbApp
  end

  before(:each) do
    app.any_instance.stub(:authorize!).and_return(true)
    app.any_instance.stub(:token_valid?).and_return(true)
  end

  it "responds to slash" do
    get '/'
    expect(last_response).to be_redirect
  end

  it "responds with 200 to GET against /ui/add" do
    get '/ui/add'
    expect(last_response).to be_ok
  end

  it "responds with 200 to GET against /ui/list" do
    get '/ui/list'
    expect(last_response).to be_ok
  end

  it "responds with 200 to a valid post to /api/add" do
    post "/api/add", \
      {
        "hostname" => "www.example.com",
        "criticality" => 1,
        "description" => "Made a change.",
        "user" => "test123",
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
    expect(data['status']).to eq(200)
  end

  it "responds with 500 to an invalid post to /api/add" do
    post "/api/add", \
      {
        "invalid_key1" => "something not valid",
        "invalid_key2" => "something else not valid"
      }.to_json, \
    "CONTENT_TYPE" => "application/json"
    data = JSON.parse(last_response.body)
    expect(data['status']).to eq(500)
  end


  it "responds with 500 for empty posts to /api/add" do
    post "/api/add", Hash.new.to_json, "CONTENT_TYPE" => "application/json"
    status = JSON.parse(last_response.body)['status']
    expect(status).to eq(500)
  end

  it "responds with 404 for GET against /api/add" do
    get "/api/add"
    expect(last_response).to be_not_found
  end

  it "responds with 404 for non-existent pages" do
    get "/nothere"
    expect(last_response).to be_not_found
  end
end
