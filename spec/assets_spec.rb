require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'acts_as_voodoo for assets' do

  class Asset < ActiveResource::Base
     my_api_key    = 'JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb'
     my_api_secret = 'nU2WjeYoEY0MJKtK1DRpp1c6hNRoHgwpNG76dJkX'

     acts_as_voodoo :api_key => my_api_key, :api_secret => my_api_secret

     self.site = "https://api.ooyala.com/v2"
  end

  before :all do
    Timecop.freeze(Time.local(2013, 1, 1, 10, 0, 0))
  end

  after :all do
    Timecop.return
  end

  it "should do it" do
    VCR.use_cassette('assets') do
      results = Asset.find(:all) do |vid|
         vid.duration > 0
      end
      binding.pry
      results.should_not be_empty
    end
  end  
end  
