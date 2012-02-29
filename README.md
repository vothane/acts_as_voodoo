Ooyala API V2 wrapper for Ruby (using ActiveResource) 
====================================================

VOODOO - V<del>IDEO</del> <del>T</del>OO<del>LKIT</del> and D<del>ATA</del> for OO<del>YALA</del>
 
This is a Ruby wrapper for the [OOYALA V2 API](http://api.ooyala.com/docs/v2) API that leverages ActiveResource.

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

Right now, functionality is limited to the The Query API can be used to request detailed information about your assets.

Queries are built using a SQL-like interface.

A sample query might look like:

	/v2/assets?where=description='Under the sea.' AND duration < 600

So using acts_as_voodoo, you would do this

``` ruby
results = Asset.find(:all) do |vid|
   vid.description == "Under the sea."
   vid.duration > 600
end
```
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
results = Asset.find(:all) do |vid|
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