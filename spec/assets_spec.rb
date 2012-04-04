require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Assets API" do

  before :all do
    class Asset < ActiveResource::Base
      my_api_key    = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
      my_api_secret = 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ'

      acts_as_voodoo :api_key => my_api_key, :api_secret => my_api_secret

      self.site = "https://api.ooyala.com/v2"
    end

    response = '{ "asset_type": "channel",
                    "duration": 0,
                    "name": "My new channel",
                    "preview_image_url": null,
                    "embed_code": "djeTZhNDrEoA30mrtp_sZ12_hENdAcQi",
                    "created_at": "2012-03-28T00:59:23+00:00",
                    "updated_at": "2012-03-28T00:59:23+00:00",
                    "time_restrictions": null,
                    "hosted_at": null,
                    "external_id": null,
                    "original_file_name": null,
                    "description": null,
                    "status": "live"
                  }'

    ActiveResource::HttpMock.respond_to do |asset|
      asset.post "/v2/assets", { "Accept" => "application/json" }, response, 201
      asset.get "/v2/assets", { "Accept" => "application/json" }, response
      asset.put "/v2/assets", { }, nil, 204
      asset.delete "/v2/assets", { }, nil, 200
    end
  end

  before :each do
    @it = Mock.find(1)
  end

  it "should not raise an error" do
    @it.datum.should_not be_empty
    lambda {
      @it.save
    }.should_not raise_error
  end

  it "should save correct data" do
    @it.datum = "new"
    @it.should be_valid
    @it.should_receive(:save).and_return(true)
    @it.save
  end

  it "should save correct data" do
    @it.should_receive(:destroy).and_return(true)
    @it.destroy
  end

  it "should recieve simple_for_save" do
    @it.datum = "new"
    @it.should_receive(:test_for_save).and_return(true)
    @it.save
  end

  it "should recieve simple_for_save" do
    @it.datum = "new"
    @it.should_receive(:test_for_destroy).and_return(true)
    @it.destroy
  end
end

describe "before_save callbacks with ActiveResource" do
  include HelperMethods

  before :all do
    class Mock < ActiveResource::Base
      acts_with_callbacks

      self.site = 'http://localhost:3000'
    end

    response = {:id => 1, :datum => "blah"}.to_json

    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/mocks.json", {"Accept" => "application/json"}, response, 201
      mock.get "/mocks/1.json", {"Accept" => "application/json"}, response
      mock.put "/mocks/1.json", {}, nil, 204
      mock.delete "/mocks/1.json", {}, nil, 200
    end
  end

  before :each do
    @it = Mock.find(1)
  end

  it "should call before_save callbacks before save" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "ordering", logger, "first")

    Mock.instance_eval do
      before_save :ordering
    end

    @it.save { logger.call("second") }

    log.should eql(["first", "second"])
    log.should_not eql(["second", "first"])
  end

  it "should call after_save callbacks after save" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "ordering", logger, "second")

    Mock.instance_eval do
      after_save :ordering
    end

    @it.save { logger.call("first") }

    log.should eql(["first", "second"])
    log.should_not eql(["second", "first"])
  end

  it "should call before_destroy callbacks before destroy" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "ordering", logger, "first")

    Mock.instance_eval do
      before_destroy :ordering
    end

    @it.destroy { logger.call("second") }

    log.should eql(["first", "second"])
    log.should_not eql(["second", "first"])
  end

  it "should call after_destroy callbacks after destroy" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "ordering", logger, "second")

    Mock.instance_eval do
      after_destroy :ordering
    end

    @it.destroy { logger.call("first") }

    log.should eql(["first", "second"])
    log.should_not eql(["second", "first"])
  end

  it "should call multiple callbacks for before_save" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "one", logger, "one was called")
    define_helper_method(Mock, "two", logger, "two was called")
    define_helper_method(Mock, "three", logger, "three was called")

    Mock.instance_eval do
      before_save :one, :two, :three
    end

    @it.save

    log.should include("one was called", "two was called", "three was called")
  end

  it "should call multiple callbacks for after_save" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "one", logger, "one was called")
    define_helper_method(Mock, "two", logger, "two was called")
    define_helper_method(Mock, "three", logger, "three was called")

    Mock.instance_eval do
      after_save :one, :two, :three
    end

    @it.save

    log.should include("one was called", "two was called", "three was called")
  end

  it "should call multiple callbacks for before_destroy" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "one", logger, "one was called")
    define_helper_method(Mock, "two", logger, "two was called")
    define_helper_method(Mock, "three", logger, "three was called")

    Mock.instance_eval do
      before_destroy :one, :two, :three
    end

    @it.destroy

    log.should include("one was called", "two was called", "three was called")
  end

  it "should call multiple callbacks for after_destroy" do
    log = []

    logger = lambda do |message|
      log << message
    end

    define_helper_method(Mock, "one", logger, "one was called")
    define_helper_method(Mock, "two", logger, "two was called")
    define_helper_method(Mock, "three", logger, "three was called")

    Mock.instance_eval do
      after_destroy :one, :two, :three
    end

    @it.destroy

    log.should include("one was called", "two was called", "three was called")
  end
end