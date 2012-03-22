$:.unshift(File.join(File.dirname(__FILE__), ".", "lib"))
require 'acts_as_voodoo'

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

all_labels = Label.find(:all)
label = Label.find('9459731df17043a08055fcc3e401ef9e')

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

puts "done"