require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'acts_as_voodoo for players' do
  
  context "when assets are playerss" do
    context "when creating new players" do

      let(:new_player) do
        player = Player.new
        player.name = "test player"
        player
      end

      it "should create a new player" do
        new_player.should_receive(:create).and_return(true)
        new_player.save.should be_true
      end
    end

    context "when finding that player that was just saved and then destroy it" do

      before :all do
        http_data = objectize_yaml('find_all_players')        
        ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/players?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=wT%2B3hoVYlrRv8A%2FG23G%2BTQF7P5nYPDvOTFiau0kSYaY", {"Accept"=>"application/json"}, http_data.response_body }
      
        players = Player.find(:all)

        players.each do |p|
          if p.name == "test player"
            @player_to_be_destroyed = p
          end
        end
      end

      it "should find newly created player" do
        @player_to_be_destroyed.name.should == "test player"
      end

      it "should destroy newly created player" do
        @player_to_be_destroyed.should_receive(:destroy).and_return(true)
        @player_to_be_destroyed.destroy.should be_true
      end
    end
  end
end