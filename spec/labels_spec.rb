require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'acts_as_voodoo for assets' do

  class Label < ActiveResource::Base
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

  it "should create a new label" do
    VCR.use_cassette('create_label') do
      new_label = Label.new
      new_label.name = "new label"
      new_label.save.should be_true
      labels = Label.find(:all)
      labels.collect { |label| label.name }.should include( "new label" ) 
    end
  end 

  it "should destroy label" do
    VCR.use_cassette('destroy_label') do
      labels = Label.find(:all)

      labels.each do |label|
        if label.name == "new label"
          label.destroy.should be_true
        end
      end
    end
  end
end 