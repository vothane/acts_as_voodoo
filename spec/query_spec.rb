require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'acts_as_voodoo for querying assets' do

  class Asset < ActiveResource::Base
     my_api_key    = 'JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb'
     my_api_secret = 'nU2WjeYoEY0MJKtK1DRpp1c6hNRoHgwpNG76dJkX'

     acts_as_voodoo :api_key => my_api_key, :api_secret => my_api_secret

     self.site = "https://api.ooyala.com/v2"
  end

  before :all do
    Timecop.freeze(Time.local(2014, 1, 1, 10, 0, 0))
  end

  after :all do
    Timecop.return
  end

  it "should find every video in ooyala account" do
    results = nil
    VCR.use_cassette('query_all') do
      results = Asset.find(:all) 
    end
    results.count.should == 14
  end 

  it "should correctly query a video by substring in description text" do
    results = nil
    VCR.use_cassette('query_by_description') do
      results = Asset.find(:all) do |vid|
                  vid.description == "Iron Man, Thor, Captain America, and the Hulk"
                end
    end
    results.count.should == 1
    results.first.name.should == "Avengers"
  end

  it "should correctly query by embed code" do
    results = nil
    VCR.use_cassette('query_by_embed_code"') do
      results = Asset.find(:all) do |vid|
                  vid.embed_code * "('U3NmdxMzrJe_3B_8VLs1ZlrlIJfSID-9','g1YzBnMjrEWdqX0gNdtKwTwQREhEkf9e')"
                end
    end
    results.count.should == 1
    results.first.name.should == "Iron Sky"
  end

  it "should correctly query by label" do
    results = nil
    VCR.use_cassette('query_by_label') do
      results = Asset.find(:all) do |vid|
                  vid.labels =~ "TV Commercial"
                end  
    end
    results.count.should == 1
    results.first.name.should == "The Force Volkswagen Commercial"
  end

  it "should correctly query a video by duration" do
    results = nil
    VCR.use_cassette('query_by_duration') do
      results = Asset.find(:all) do |vid|
                  vid.duration < 600
                end
    end
    results.count.should == 1
  end  

  it "should correctly query by union of criterias, or joining with AND" do
    results = nil
    VCR.use_cassette('query_by_union') do
      results = Asset.find(:all) do |vid|
                  vid.description == "Thor"
                  vid.labels =~ "Movie Trailer"
                end     
    end
    results.count.should == 2
  end 

  it "should find none when a criteria is FALSEY in union of criterias" do
    results = nil
    VCR.use_cassette('query_by_union_but_falsey') do
      results = Asset.find(:all) do |vid|
                  vid.description == "Thor"
                  vid.labels =~ "TV Commercial"
                end     
    end
    results.count.should == 0
  end        
end 