
ENV['RACK_ENV'] = 'test'

require 'changelogrb'
require 'rspec'
require 'rack/test'
require 'support/fakeredis'
require 'json'

describe "ChangeLogRb Queue" do
  before do
    @queue = ChangeLogRb::Queue.new({})
  end
  
  describe "#add" do
    it "takes a JSON changelog" do
      cl_json = { "foo1" => "bar1", 
                  "foo2" => "bar2",
                  "foo23" => "bar3",
                }.to_json
      @queue.add(cl_json)
    end
  end
end