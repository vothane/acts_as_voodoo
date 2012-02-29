Ooyala API V2 wrapper for Ruby (using ActiveResource) 
====================================================

This is a Ruby wrapper for the [OOYALA V2 API](http://http://api.ooyala.com/docs/v2) API that leverages ActiveResource.

It allows you to interface with the Ooyala v2 API using simple ActiveRecord-like syntax, i.e.:

``` ruby
class Asset < ActiveResource::Base
   my_api_key    = 'JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb'
   my_api_secret = 'nU2WjeYoEY0MJKtK1DRpp1c6hNRoHgwpNG76dJkX'

   acts_as_voodoo :api_key => my_api_key, :api_secret => my_api_secret

   self.site = "https://api.ooyala.com/v2"
end

results = Asset.find(:all) do |vid|
   vid.description == "Under the sea."
   vid.duration > 600
end
```

See the `examples` directory for more usage examples.

### Installation

beta only, not yet published as a gem.

### Usage