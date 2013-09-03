require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'acts_as_voodoo for labels' do

  class Label < ActiveResource::Base
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
  end

  context "when labels" do
    context "when saving new labels" do
      let(:new_label) do
        label = Label.new
        label.name = "test label"
        label
      end

      it "should create a new label" do
        http_data = objectize_yaml('create_label')
        ActiveResource::HttpMock.respond_to { |mock| mock.post "/v2/labels?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=ZV%2Bv1dkG43jF4FNeOj%2Fn2XSeYzkgMotEjWD2VuqSOq8", {"Content-Type"=>"application/json"}, http_data.request_body }

        new_label.save.should == "test label"
      end
    end

    context "when finding that label that was just saved and then destroy it" do
      it "should find newly created label" do
        http_data = objectize_yaml('find_all_labels')
        ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/labels?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=KVpWAHBa3B5v3m3jWPafX0cSi36t7Fw%2ByYdqZeXPtyw", {"Accept"=>"application/json"}, http_data.response_body }
       
        labels = Label.find(:all)
        labels.collect { |label| label.name }.should include("test label")
      end

      xit "should destroy newly created label" do
        http_data = objectize_yaml('destroy_label')
        ActiveResource::HttpMock.respond_to { |mock| mock.delete "/people/1/addresses/1.json", {}, nil, 200 }
     
        label_to_be_destroyed.destroy.should be_true
      end
    end
  end
end