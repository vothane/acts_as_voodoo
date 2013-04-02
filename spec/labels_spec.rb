require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'acts_as_voodoo for labels' do

  class Label < ActiveResource::Base
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

  context "when labels" do
    context "when saving new labels" do
      let(:new_label) do
        label      = Label.new
        label.name = "new label"
        label
      end

      it "should create a new label" do
        VCR.use_cassette('create_label') do
          new_label.save.should be_true
        end
      end
    end

    context "when finding that label that was just saved and then destroy it" do
      let(:labels) do
        VCR.use_cassette('find_all_labels') do
          labels = Label.find(:all)
        end
      end

      let(:label_to_be_destroyed) do
        labels.each do |label|
          if label.name == "new label"
            return label
          end
        end
      end

      it "should find newly created label" do
        labels.collect { |label| label.name }.should include( "new label" )
      end

      it "should destroy newly created label" do
        VCR.use_cassette('destroy_label') do
          label_to_be_destroyed.destroy.should be_true
        end
      end
    end
  end
end 