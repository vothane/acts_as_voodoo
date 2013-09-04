require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'acts_as_voodoo for querying assets' do
  
  it "should find every video in ooyala account" do
    http_data = objectize_yaml('find_video')        
    ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/assets?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=ClzQGSks95XkKXcGig5StzjtjGLlzAuD3ZtIT0TQReA", {"Accept"=>"application/json"}, http_data.response_body }
       
    results = Asset.find(:all)
    results.count.should > 0
  end

  it "should correctly query a video by substring in description text" do
    http_data = objectize_yaml('query_by_description')        
    ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/assets?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=qIJSWnyLjbS6zDEvfzlWDRwRIfpd2DKgNG2nRuoco4U&where=description%3D%27Iron+Man%2C+Thor%2C+Captain+America%2C+and+the+Hulk%27", {"Accept"=>"application/json"}, http_data.response_body }
       
    results = Asset.find(:all) do |vid|
      vid.description == "Iron Man, Thor, Captain America, and the Hulk"
    end
    results.count.should == 1
    results.first.name.should == "Avengers"
  end

  it "should correctly query by embed code" do
    http_data = objectize_yaml('query_by_description')        
    ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/assets?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=5nf6aqCBuXmXmdG7aNsSC8dlbGOKXN%2FODHUysJ7GqEo&where=embed_code+IN+%28%27U3NmdxMzrJe_3B_8VLs1ZlrlIJfSID-9%27%2C%27g1YzBnMjrEWdqX0gNdtKwTwQREhEkf9e%27%29", {"Accept"=>"application/json"}, http_data.response_body }
           
    results = Asset.find(:all) do |vid|
      vid.embed_code * "('U3NmdxMzrJe_3B_8VLs1ZlrlIJfSID-9','g1YzBnMjrEWdqX0gNdtKwTwQREhEkf9e')"
    end
    results.count.should == 1
    results.first.name.should == "Avengers"
  end

  it "should correctly query by label" do
    http_data = objectize_yaml('query_by_label')        
    ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/assets?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=1%2BKn7G5U9a%2FrBwnbHOiW%2FQGix6YrLZQaB%2FaIIp4iWnY&where=labels+INCLUDES+%27TV+Commercial%27", {"Accept"=>"application/json"}, http_data.response_body }
    
    results = Asset.find(:all) do |vid|
      vid.labels =~ "TV Commercial"
    end
    results.count.should == 1
    results.first.name.should == "The Force Volkswagen Commercial"
  end

  it "should correctly query a video by duration" do
    http_data = objectize_yaml('query_by_duration')        
    ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/assets?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=rkbPLgqJ%2FAcXBIChtxTAcrlAlTE8zQ9c%2BoHlWRGuulM&where=duration%3C600", {"Accept"=>"application/json"}, http_data.response_body }
    
    results = Asset.find(:all) do |vid|
      vid.duration < 600
    end
    results.count.should == 1
  end

  it "should correctly query by union of criterias, or joining with AND" do
    http_data = objectize_yaml('query_by_union')        
    ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/assets?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=W%2Fu%2B4lm2HHr5cMDXhkyJXZTQgPjOY2bdyTWbvkgn4jM&where=description%3D%27Thor%27+AND+labels+INCLUDES+%27Movie+Trailer%27", {"Accept"=>"application/json"}, http_data.response_body }
    
    results = Asset.find(:all) do |vid|
      vid.description == "Thor"
      vid.labels =~ "Movie Trailer"
    end
    results.count.should == 1
  end

  it "should find none when a criteria is FALSEY in union of criterias" do
    http_data = objectize_yaml('query_by_union_but_falsey')        
    ActiveResource::HttpMock.respond_to { |mock| mock.get "/v2/assets?api_key=JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb&expires=1577898300&signature=yf4dMwO%2BUOIyDKLMwNENVrDoeix3A%2FDNOVtZYIXKE2s&where=description%3D%27Thor%27+AND+labels+INCLUDES+%27TV+Commercial%27", {"Accept"=>"application/json"}, http_data.response_body }
    
    results = Asset.find(:all) do |vid|
      vid.description == "Thor"
      vid.labels =~ "TV Commercial"
    end
    results.count.should == 0
  end
end