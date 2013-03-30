require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'acts_as_voodoo for assets' do

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

  it "should create a new channel" do
    VCR.use_cassette('create_channel') do
      new_channel            = Asset.new
      new_channel.asset_type = "channel"
      new_channel.name       = "new channel"
      new_channel.save.should be_true
    end
  end

  it "should update an existing video" do
    video = nil

    VCR.use_cassette('find_video') do
      results = Asset.find(:one) do |vid|
        vid.description == "Thor"
        vid.duration > 600
      end

      video = results.first
    end

    VCR.use_cassette('update_video') do
      video.name = "update name"
      video.save.should be_true
    end
  end

  it "should delete a video" do
    video = nil

    VCR.use_cassette('find_video_to_delete') do
      results = Asset.find(:one) do |vid|
        vid.description == "Bootstrap"
        vid.duration > 600
      end

      video = results.first
    end

    VCR.use_cassette('delete_video') do
      video.destroy.should be_true
    end
  end
end 