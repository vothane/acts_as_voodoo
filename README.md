Ooyala API V2 wrapper for Ruby (using ActiveResource) 
====================================================

VOODOO - V<del>IDEO</del> <del>T</del>OO<del>LKIT</del> and D<del>ATA</del> for OO<del>YALA</del>
 
This is a Ruby wrapper for the [OOYALA V2 API](http://api.ooyala.com/docs/v2) API that leverages ActiveResource.

It allows you to interface with the Ooyala v2 API using simple ActiveRecord-like syntax, i.e.:

``` ruby
class Asset < ActiveResource::Base
   my_api_key    = '<API KEY HERE>'
   my_api_secret = '<API SECRET HERE>'

   acts_as_voodoo :api_key => my_api_key, :api_secret => my_api_secret

   self.site = "https://api.ooyala.com/v2"
   
   # if your class is not name Asset 
   # then you define element name as 'asset'
   # self.element_name = "asset"
end

results = Asset.find(:one) do |vid|
   vid.description == "Under the sea."
   vid.duration > 600
end
```

See the `examples` directory for more usage examples.

### Installation

beta only, not yet published as a gem.

### Usage

The Query API can be used to request detailed information about your assets.

Queries are built using a SQL-like interface.

A sample query might look like:

	/v2/assets?where=description='Under the sea.' AND duration < 600

So using acts_as_voodoo, you would do this

``` ruby
results = Asset.find(:one) do |vid|
   vid.description == "Under the sea."
   vid.duration > 600
end
```

### Query API Examples

The first 5 movies where the description is "Under the sea." that are greater than ten minutes long. The videos are ordered by created_at in ascending order.

SELECT * WHERE description = 'Under the sea.' AND duration > 600 ORDER BY created_at descending

/v2/assets?where=description='Under the sea.' AND duration > 600&orderby=created_at descending&limit=5

``` ruby
results = Asset.find(:all, :params => { 'orderby' => "created_at descending", 'limit' => 5 }) do |vid|
   vid.description == "Under the sea."
   vid.duration > 600
end
```

Get assets given a list of embed codes

SELECT * WHERE embed_code IN ('g0YzBnMjoGiHUtGoWW4pFzzhTZpKLZUi',
                              'g1YzBnMjrEWdqX0gNdtKwTwQREhEkf9e')

/v2/assets?where=embed_code IN ('g0YzBnMjoGiHUtGoWW4pFzzhTZpKLZUi','g1YzBnMjrEWdqX0gNdtKwTwQREhEkf9e')

``` ruby
results = Asset.find(:one) do |vid|
   vid.embed_code * "('g0YzBnMjoGiHUtGoWW4pFzzhTZpKLZUi','g1YzBnMjrEWdqX0gNdtKwTwQREhEkf9e')"
end
```

All assets tagged with the label "Case Study"

SELECT * WHERE labels INCLUDES 'Case Study'

/v2/assets?where=labels INCLUDES 'Case Study'	

``` ruby
results = Asset.find(:all) do |vid|
   vid.labels =~ "Case Study"
end
```

### Asset API Examples

Create a channel or channel set

Required fields: name, asset_type.

Use an asset type of "channel_set" to create a channel set.

``` ruby
new_channel            = Asset.new
new_channel.asset_type = "channel"
new_channel.name       = "new channel test"
new_channel.save
```

Delete an asset

``` ruby
# find by video embed code
video = Asset.find('g2cXI5NDpVyT8R0xlrun8tfzDB_d3rLc')
video.destroy
```

### Label API Examples

``` ruby
class Label < ActiveResource::Base
   my_api_key    = '<API KEY HERE>'
   my_api_secret = '<API SECRET HERE>'

   acts_as_voodoo :api_key => my_api_key, :api_secret => my_api_secret

   self.site = "https://api.ooyala.com/v2"
   
   # if your class is not name Label 
   # then you define element name as 'label'
   # self.element_name = "label"
end
```
Create a label

Required parameters: name.

``` ruby
new_label = Label.new
new_label.name = "my new label"
new_label.save
```

Note: The name cannot contain hidden characters. Hidden characters are those with ascii values between 0 and 31, except for 10 (newline) and 13 (carriage return).

Delete labels

Deleting a label will automatically delete all its children.

``` ruby
all_labels = Label.find(:all)

all_labels.each do |label|
  if label.name == "my new label"
    label.destroy
  end
end
```

View all labels

``` ruby
all_labels = Label.find(:all)
```

View one label

``` ruby
# find by label id
label = Label.find('9459731df17043a08055fcc3e401ef9e')
```

### Uploading Videos

One way to upload videos.

``` ruby
video            = Asset.new
video.name       = 'vid'
video.file_name  = 'vid.flv'
video.asset_type = 'video'
video.file_size  = '2795138'
video.post_processing_status = 'live'
video.save

path                = "https://api.ooyala.com/v2/assets/#{video.embed_code}/uploading_urls"
params              = { 'api_key' => api_key, 'expires' => OOYALA::expires }
params['signature'] = OOYALA::generate_signature(api_secret, "GET", "/v2/assets/#{video.embed_code}/uploading_urls", params, nil)

EventMachine.run {
  get_upload_url = EventMachine::HttpRequest.new(path).get :query => params

  get_upload_url.callback {
    upload_url   = get_upload_url.response
    upload_video = EventMachine::HttpRequest.new(upload_url).post :file => video.file_name
    upload_video.callback {
      video.put(:upload_status,\
        { :api_key => api_key, :expires => api_secret, :signature => params['signature'] },\
        "'status':'uploaded'")
    }
    upload_video.errback {
    # notify user that upload failed
      puts "upload failed"
    }
  }
  get_upload_url.errback {
  # notify user that upload failed
    puts "upload failed"
  }
}
```