require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Asset' do

  before(:all) do
    WebMock.disable_net_connect!
  end

  after(:all) do
    WebMock.allow_net_connect!
    puts "\e[33mPlease run this test as rspec spec/act_as_voodoo_spec.rb. Using rspec spec will break tests.\e[0m"
  end

  class Asset < ActiveResource::Base
    my_api_key = 'JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb'
    my_api_secret = 'nU2WjeYoEY0MJKtK1DRpp1c6hNRoHgwpNG76dJkX'

    acts_as_voodoo :api_key => my_api_key, :api_secret => my_api_secret

    self.site = "https://api.ooyala.com/v2"
  end

  context "when including acts_as_voodoo" do

    it "should included acts_as_voodoo method" do
      Asset.should respond_to(:acts_as_voodoo)
      Asset.primary_key.should == 'embed_code'
    end

    it "should have correct initial url configs" do
      Asset.site.host.should == "api.ooyala.com"
      expect(Asset.site.path).to start_with("/v2")
      Asset.collection_path.should == "/v2/assets"
    end
  end

  context "when using Asset model find assets" do

    before(:each) do
      stub_request(:get, /.*/).to_return(:response => {:body => {}, :status => {:code => 200}})
    end

    it "should call get request with correct params for finding by name" do
      Asset.should_receive(:find_without_voodoo) do |arg1, arg2|
        (arg1.to_s).should eq("all")
        arg2[:params].should include("where" => "name='Iron Sky'")
      end
      Asset.find(:first) { |asset| asset.name == "Iron Sky" }
    end

    it "should call get request with correct params for finding by description AND duration" do
      Asset.should_receive(:find_without_voodoo) do |arg1, arg2|
        (arg1.to_s).should eq("all")
        arg2[:params].should include("where" => "description='and, with it, great responsibility.' AND duration>600")
      end
      Asset.find(:all) do |asset|
        asset.description == "and, with it, great responsibility."
        asset.duration > 600
      end
    end

    it "should call get request with correct params for all find" do
      Asset.should_receive(:find_without_voodoo) do |arg1, arg2|
        (arg1.to_s).should eq("all")
        arg2.keys.should_not include("where")
      end
      Asset.all
    end
  end

  context "when updating existing assets" do

    let(:video) do
      result = nil
      WebMock.allow_net_connect!
      VCR.turned_off do
        result = Asset.find(:first) { |asset| asset.name == "Iron Sky" }
      end
      WebMock.disable_net_connect!
      result
    end

    before(:each) do
      stub_request(:patch, /.*/).to_return(:response => {:body => {}, :status => {:code => 200}})
    end

    it "should call update" do
      video.should_receive(:update)
      video.name = "updated name"
      video.save
    end
  end

  context "when deleting existing assets" do

    let(:video) do
      result = nil
      WebMock.allow_net_connect!
      VCR.turned_off do
        result = Asset.find(:first) { |asset| asset.name == "Iron Sky" }
      end
      WebMock.disable_net_connect!
      result
    end

    before(:each) do
      stub_request(:delete, /.*/).to_return(:response => {:body => {}, :status => {:code => 200}})
    end

    it "should call destroy" do
      video.should_receive(:destroy)
      video.destroy
    end
  end
end

describe 'Player' do

  class Player < ActiveResource::Base
    my_api_key = 'JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb'
    my_api_secret = 'nU2WjeYoEY0MJKtK1DRpp1c6hNRoHgwpNG76dJkX'

    acts_as_voodoo :api_key => my_api_key, :api_secret => my_api_secret

    self.site = "https://api.ooyala.com/v2"
  end

  let(:player) do
    players = nil
    WebMock.allow_net_connect!
    VCR.turned_off do
      players = Player.find(:all)
    end
    WebMock.disable_net_connect!
    players.first
  end

  context "when including acts_as_voodoo" do

    it "should included acts_as_voodoo method" do
      Player.should respond_to(:acts_as_voodoo)
    end

    it "should have correct initial url configs" do
      Player.site.host.should == "api.ooyala.com"
      expect(Player.site.path).to start_with("/v2")
      Player.collection_path.should == "/v2/players"
    end
  end

  context "when creating players" do

    before(:each) do
      stub_request(:post, /.*/).to_return(:response => {:body => {}, :status => {:code => 200}})
    end

    it "should call create" do
      new_player = Player.new
      new_player.name = "new player"
      new_player.should_receive(:create)
      new_player.save
    end
  end

  context "when updating existing players" do

    before(:each) do
      stub_request(:patch, /.*/).to_return(:response => {:body => {}, :status => {:code => 200}})
    end

    it "should call update" do
      player.should_receive(:update)
      player.name = "updated name"
      player.save
    end
  end

  context "when deleting existing players" do

    before(:each) do
      stub_request(:delete, /.*/).to_return(:response => {:body => {}, :status => {:code => 200}})
    end

    it "should call destroy" do
      player.should_receive(:destroy)
      player.destroy
    end
  end
end

describe 'Label' do

  class Label < ActiveResource::Base
    my_api_key = 'JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb'
    my_api_secret = 'nU2WjeYoEY0MJKtK1DRpp1c6hNRoHgwpNG76dJkX'

    acts_as_voodoo :api_key => my_api_key, :api_secret => my_api_secret

    self.site = "https://api.ooyala.com/v2"
  end

  let(:label) do
    labels = nil
    WebMock.allow_net_connect!
    VCR.turned_off do
      labels = Label.find(:all)
    end
    WebMock.disable_net_connect!
    labels.first
  end

  context "when including acts_as_voodoo" do

    it "should included acts_as_voodoo method" do
      Label.should respond_to(:acts_as_voodoo)
    end

    it "should have correct initial url configs" do
      Label.site.host.should == "api.ooyala.com"
      expect(Label.site.path).to start_with("/v2")
      Label.collection_path.should == "/v2/labels"
    end
  end

  context "when creating labels" do

    before(:each) do
      stub_request(:post, /.*/).to_return(:response => {:body => {}, :status => {:code => 200}})
    end

    it "should call create" do
      new_label = Label.new
      new_label.name = "new label"
      new_label.should_receive(:create)
      new_label.save
    end
  end

  context "when updating existing labels" do

    before(:each) do
      stub_request(:patch, /.*/).to_return(:response => {:body => {}, :status => {:code => 200}})
    end

    it "should call update" do
      label.should_receive(:update)
      label.name = "updated name"
      label.save
    end
  end

  context "when deleting existing labels" do

    before(:each) do
      stub_request(:delete, /.*/).to_return(:response => {:body => {}, :status => {:code => 200}})
    end

    it "should call destroy" do
      label.should_receive(:destroy)
      label.destroy
    end
  end
end