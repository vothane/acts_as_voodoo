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

  context "when assets are videos" do
    context "when updating an attribute of an existing video" do
      
      let(:video) do
        VCR.use_cassette('find_video') do
          results = Asset.find(:one) do |vid|
            vid.description == "Thor"
            vid.duration > 600
          end
          results.first
        end
      end

      it "should update the name attribute through ooyala api" do
        video.name = "Hear Me Roar!"

        VCR.use_cassette('update_video') do
          video.save.should be_true
        end
      end
    end
    
    context "when checking to see that the name attribute was actually updated" do 
      
      let(:video_with_updated_name) do
        VCR.use_cassette('find_video_with_updated_name') do
          results = Asset.find(:one) do |vid|
            vid.description == "Thor"
            vid.duration > 600
          end
          results.first
        end
      end

      it "should have updated the name attribute on ooyala servers" do
        video_with_updated_name.name.should == "Hear Me Roar!" 
      end  
    end

    context "when deleting an existing video" do 

      let(:video_to_be_deleted) do  
        VCR.use_cassette('find_video_to_delete') do
          results = Asset.find(:one) do |vid|
            vid.description == "Mongoid"
            vid.duration > 600
          end
          results.first
        end
      end

      it "should delete an existing video" do
        VCR.use_cassette('delete_video') do
          video_to_be_deleted.destroy.should be_true
        end
      end
    end  
  end

  context "when assets are channels" do
    context "when creating new channels" do

      let(:new_channel) do
        channel            = Asset.new
        channel.asset_type = "channel"
        channel.name       = "new channel"
        channel
      end

      it "should create a new channel" do
        VCR.use_cassette('create_channel') do
          new_channel.save.should be_true
        end
      end
    end
  end  
end 