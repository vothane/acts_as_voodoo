$:.unshift(File.join(File.dirname(__FILE__), ".", "lib"))
require 'acts_as_voodoo'
#require 'em-http-request'

class Asset < ActiveResource::Base
  my_api_key    = 'JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb'
  my_api_secret = 'nU2WjeYoEY0MJKtK1DRpp1c6hNRoHgwpNG76dJkX'

  acts_as_voodoo :api_key => my_api_key, :api_secret => my_api_secret

  self.site = "https://api.ooyala.com/v2"
end

results1 = Asset.find(:all) do |vid|
  vid.description == "Under the sea."
  vid.duration > 600
end

results2 = Asset.find(:one) do |vid|
  vid.embed_code * "('g0YzBnMjoGiHUtGoWW4pFzzhTZpKLZUi','hzZm8xMjp1GYiOpj2WDS4TtC7b2st1MW')"
end

results3 = Asset.find(:all) do |vid|
  vid.labels =~ "Case Study"
end

results4 = Asset.find(:all, :params => { 'orderby' => "duration descending", 'limit' => 5 }) do |vid|
  vid.duration > 600
end

results5 = Asset.find('dxZGdxMzomq2HVFWgXFDXnQ7hx5NpxJY')
class Label < ActiveResource::Base
  my_api_key    = 'JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb'
  my_api_secret = 'nU2WjeYoEY0MJKtK1DRpp1c6hNRoHgwpNG76dJkX'

  acts_as_voodoo :api_key => my_api_key, :api_secret => my_api_secret

  self.site = "https://api.ooyala.com/v2"
end

patch = Asset.find('Rxb3I5NDoppIz3iDJ7oQjtdJNa650jqw')

patch.name = "patch vvv"
patch.save

all_labels = Label.find(:all)
all_labels.each do |label|
  if label.name == "title"
    label.destroy
  end
end

class Player < ActiveResource::Base
  my_api_key    = 'JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb'
  my_api_secret = 'nU2WjeYoEY0MJKtK1DRpp1c6hNRoHgwpNG76dJkX'

  acts_as_voodoo :api_key => my_api_key, :api_secret => my_api_secret

  self.site = "https://api.ooyala.com/v2"
end

all_players = Player.find(:all)
player = Player.find('718720520c141eab49a7044f3a3f9fe')

unREST = Label.find(:all, :from => '/9459731df17043a08055fcc3e401ef9e/assets')

res = Asset.new
res.asset_type = "channel"
res.name       = "new channel test"
test_save = res.save

new_label = Label.new
new_label.name = "my new label"
new_label.save

all_labels = Label.find(:all)
all_labels.each do |label|
  if label.name == "my new label"
  label.destroy
  end
end

all_assets = Asset.find(:all)
all_assets.each do |asset|
  if asset.name == "new channel test"
    asset.destroy
  end
end

api_key    = 'JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb'
api_secret = 'nU2WjeYoEY0MJKtK1DRpp1c6hNRoHgwpNG76dJkX'

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

# EventMachine.run {
  # get_upload_url = EventMachine::HttpRequest.new(path).get :query => params
# 
  # get_upload_url.callback {
    # upload_url   = get_upload_url.response
    # upload_video = EventMachine::HttpRequest.new(upload_url).post :file => video.file_name
    # upload_video.callback {
# #      video.put("#{video.embed_code}/upload_status", { :status => "uploaded" })
    # }
    # upload_video.errback {
    # # notify user that upload failed
      # puts "upload failed"
    # }
  # }
  # get_upload_url.errback {
  # # notify user that upload failed
    # puts "upload failed"
  # }
# }

puts "done"