require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Asset' do
  
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
    before :all do
      ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/assets?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=qIJSWnyLjbS6zDEvfzlWDRwRIfpd2DKgNG2nRuoco4U&where=description%3D%27Iron+Man%2C+Thor%2C+Captain+America%2C+and+the+Hulk%2", {"Accept"=>"application/json"}, {} }
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

    it "should call update" do
      http_data = objectize_yaml('query_by_description')        
      ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/assets?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=Hgu%2FWVDUOLK7E7V1NTIh62TOISPfjLvuKzIlbFr6rlo&where=name%3D%27Iron+Sky%27", {"Accept"=>"application/json"}, http_data.response_body }
  
      result = Asset.find(:first) { |asset| asset.name == "Iron Sky" }
      
      video = result.first
      video.should_receive(:update)
      video.name = "updated name"
      video.save
    end
  end

  context "when deleting existing assets" do

    it "should call destroy" do
      http_data = objectize_yaml('query_by_description')        
      ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/assets?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=Hgu%2FWVDUOLK7E7V1NTIh62TOISPfjLvuKzIlbFr6rlo&where=name%3D%27Iron+Sky%27", {"Accept"=>"application/json"}, http_data.response_body }
  
      result = Asset.find(:first) { |asset| asset.name == "Iron Sky" }
      
      video = result.first
      video.should_receive(:destroy)
      video.destroy
    end

  end
end

describe 'Player' do

  before :all do
    http_data = objectize_yaml('find_all_players')        
    ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/players?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=wT%2B3hoVYlrRv8A%2FG23G%2BTQF7P5nYPDvOTFiau0kSYaY", {"Accept"=>"application/json"}, http_data.response_body }
  
    players = Player.find(:all)
    @player = players.first
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
    it "should call create" do
      new_player = Player.new
      new_player.name = "new player"
      new_player.should_receive(:create)
      new_player.save
    end
  end

  context "when updating existing players" do
    it "should call update" do
      @player.should_receive(:update)
      @player.name = "updated name"
      @player.save
    end
  end

  context "when deleting existing players" do
    it "should call destroy" do
      @player.should_receive(:destroy)
      @player.destroy
    end
  end
end

describe 'Label' do

  before :all do
    http_data = objectize_yaml('find_all_labels')        
    ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/labels?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=KVpWAHBa3B5v3m3jWPafX0cSi36t7Fw%2ByYdqZeXPtyw", {"Accept"=>"application/json"}, http_data.response_body }
  
    labels = Label.find(:all)
    @label = labels.first
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
    it "should call create" do
      new_label = Label.new
      new_label.name = "new label"
      new_label.should_receive(:create)
      new_label.save
    end
  end

  context "when updating existing labels" do
    it "should call update" do
      @label.should_receive(:update)
      @label.name = "updated name"
      @label.save
    end
  end

  context "when deleting existing labels" do
    it "should call destroy" do
      @label.should_receive(:destroy)
      @label.destroy
    end
  end
end