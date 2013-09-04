require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'acts_as_voodoo for assets' do
  
  context "when assets are videos" do
    context "when updating an attribute of an existing video" do       
      it "should update the name attribute through ooyala api" do 
        http_data = objectize_yaml('find_video')        
        ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/assets?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=2zxqmCePTsIUmafwuJjSJ%2FBLkwHZvZfpAEmE5ZPDbHk&where=description%3D%27This+is+the+video%27+AND+duration%3E5", {"Accept"=>"application/json"}, http_data.response_body }
       
        results = Asset.find(:all) do |vid|
          vid.description == "This is the video"
          vid.duration > 5
        end

        video = results.first
        video.name = "zample1"

        http_data = objectize_yaml('update_video')
        ActiveResource::HttpMock.respond_to { |mock| mock.patch "/v2/assets/poYXgzYjri-57mxxMADjcv8M4C2B63Cz?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=kSo89gtmfhTwNs3p6QzXPH8o23XAUy20hBwqISWwOXE", {"Content-Type"=>"application/json"}, http_data.request_body }
  
        video.save.should be_true
      end
    end

    context "when checking to see that the name attribute was actually updated" do
      it "should have updated the name attribute on ooyala servers" do
        http_data = objectize_yaml('find_video_with_updated_name')
        ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/assets?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=QngZTIX3ZwrhVv3sG4lhl1WksDUwUnU9RplhIUjCZn0&where=description%3D%27named+changed.%27+AND+duration%3E5", {"Accept"=>"application/json"}, http_data.response_body }

        results = Asset.find(:all) do |vid|
          vid.description == "named changed."
          vid.duration > 5
        end

        video_with_updated_name = results.first
        video_with_updated_name.name.should == "zample1"
      end
    end

    context "when deleting an existing video" do
      it "should delete an existing video" do
        http_data = objectize_yaml('find_video_to_delete')
        ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/assets?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=ia0bSqGlKmQhZc1siT3b2EcCnPfjbZGbR1LdZidvrls&where=description%3D%27will+be+deleted.%27+AND+duration%3E5", {"Accept"=>"application/json"}, http_data.response_body }

        results = Asset.find(:all) do |vid|
          vid.description == "will be deleted."
          vid.duration > 5
        end

        video_to_be_deleted = results.first

        http_data = objectize_yaml('find_video_to_delete')
        ActiveResource::HttpMock.respond_to { |mock| mock.delete "/v2/assets/pqYXgzYjoCaPfZqTDXOZLuB2bptKvHZI?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=TNa4YHVePgHwDKEgWy24%2FAgTqPoPEI6Y7Kgui4erRKc", {}, nil, 200 }

        video_to_be_deleted.destroy.should be_true
      end
    end
  end

  context "when assets are channels" do
    context "when creating new channels" do

      let(:new_channel) do
        channel = Asset.new
        channel.asset_type = "channel"
        channel.name = "new channel"
        channel
      end

      it "should create a new channel" do
        new_channel.should_receive(:create).and_return(true)
        new_channel.save.should be_true
      end
    end
  end
end