require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'acts_as_voodoo for players' do

  class Player < ActiveResource::Base
    my_api_key = 'JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb'
    my_api_secret = 'nU2WjeYoEY0MJKtK1DRpp1c6hNRoHgwpNG76dJkX'

    acts_as_voodoo :api_key => my_api_key, :api_secret => my_api_secret

    self.site = "https://api.ooyala.com/v2"
  end

  context "when assets are playerss" do
    context "when creating new players" do

      let(:new_player) do
        player = Player.new
        player.name = "test player"
        player
      end

      xit "should create a new player" do
        http_data = objectize_yaml('create_player') 
        ActiveResource::HttpMock.respond_to { |mock| mock.post "/v2/players?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=j6vRx5iR1zmQeQcxqcJCr1twaqgrkFejXPLgT%2B9ptvc", {"Content-Type"=>"application/json"}, http_data.request_body }

        new_player.save.should be_true
      end
    end

    context "when finding that player that was just saved and then destroy it" do

      let(:player_to_be_destroyed) do
        players.each do |player|
          if player.name == "test player"
            return player
          end
        end
      end

      xit "should find newly created player" do
        http_data = objectize_yaml('find_all_players') 
        ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/labels?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=KVpWAHBa3B5v3m3jWPafX0cSi36t7Fw%2ByYdqZeXPtyw", {"Accept"=>"application/json"}, http_data.response_body }
       
        player_to_be_destroyed.name.should == "test player"
      end

      xit "should destroy newly created player" do
        VCR.use_cassette('destroy_player') do
          player_to_be_destroyed.destroy.should be_true
        end
      end
    end
  end
end