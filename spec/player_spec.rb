require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'acts_as_voodoo for players' do

  class Player < ActiveResource::Base
    my_api_key = 'JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb'
    my_api_secret = 'nU2WjeYoEY0MJKtK1DRpp1c6hNRoHgwpNG76dJkX'

    acts_as_voodoo :api_key => my_api_key, :api_secret => my_api_secret

    self.site = "https://api.ooyala.com/v2"
  end

  before :all do
    Timecop.freeze(Time.local(2020, 1, 1, 10, 0, 0))
  end

  after :all do
    Timecop.return
    puts "\e[33mPlease run this test as rspec spec/player_spec.rb. Using rspec spec will break tests.\e[0m"
  end

  context "when assets are playerss" do
    context "when creating new players" do

      let(:new_player) do
        player = Player.new
        player.name = "test player"
        player
      end

      it "should create a new player" do
        VCR.use_cassette('create_player') do
          new_player.save.should be_true
        end
      end
    end

    context "when finding that player that was just saved and then destroy it" do
      let(:players) do
        VCR.use_cassette('find_all_players') do
          players = Player.find(:all)
        end
      end

      let(:player_to_be_destroyed) do
        players.each do |player|
          if player.name == "test player"
            return player
          end
        end
      end

      it "should find newly created player" do
        player_to_be_destroyed.name.should == "test player"
      end

      it "should destroy newly created player" do
        VCR.use_cassette('destroy_player') do
          player_to_be_destroyed.destroy.should be_true
        end
      end
    end
  end
end