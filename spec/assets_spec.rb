require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'acts_as_voodoo for querying assets' do

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

  it "should create a new channel" do
    VCR.use_cassette('create_channel') do
      new_channel            = Asset.new
      new_channel.asset_type = "channel"
      new_channel.name       = "new channel"
      new_channel.save.should be_true
    end
  end 

  # TODO: FIX
  # delete by video embed code
  xit "should delete a video" do
    VCR.use_cassette('delete_video') do
      video = Asset.find('RzeGdxMzrD6xa0Vv1pm42qN3gHEVQLCR')
      video.destroy.should be_true
    end
  end
end 