require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'acts_as_voodoo for labels' do
  
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

         new_label.should_receive(:create).and_return(true)
        new_label.save.should be_true
      end
    end

    context "when finding that label that was just saved and then destroy it" do
      it "should find newly created label" do
        http_data = objectize_yaml('find_all_labels')
        ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/labels?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=KVpWAHBa3B5v3m3jWPafX0cSi36t7Fw%2ByYdqZeXPtyw", {"Accept"=>"application/json"}, http_data.response_body }
       
        labels = Label.find(:all)
        labels.collect { |label| label.name }.should include("test label")
      end

      it "should destroy newly created label" do
        http_data = objectize_yaml('find_all_labels')
        ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/labels?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=KVpWAHBa3B5v3m3jWPafX0cSi36t7Fw%2ByYdqZeXPtyw", {"Accept"=>"application/json"}, http_data.response_body }
        label_to_be_destroyed = Label.find(:all)
        
        label_to_be_destroyed.should_receive(:destroy).and_return(true)
        label_to_be_destroyed.destroy.should be_true
      end
    end
  end
end