require 'rubygems'
require 'active_resource'
require 'active_support'
require 'digest/sha2'
require 'base64'

module Acts
   module Voodoo # Video tOOlkit & Data for OOyala
      def self.included(base)
         base.extend ClassMethods
      end

      module ClassMethods
         def acts_as_voodoo(credentials = { })
            cattr_accessor :api_key
            self.api_key = credentials[:api_key]
            cattr_accessor :api_secret
            self.api_secret = credentials[:api_secret]

            class << self
               def find_with_voodoo(*args, &block)
                  if block_given?
                     conditions = Query::Conditions.new(&block)
                     sub_set    = args.first
                     options    = args.last || { }
                     params     = { }
                     params.merge(options) if options.instance_of? Hash
                     params['where']     = conditions.to_where_conditions
                     params              = params.merge('api_key' => self.api_key, 'expires' => OOYALA::expires)
                     signature           = OOYALA::generate_signature(self.api_secret, "GET", "/v2/assets", params, nil)
                     params['signature'] = signature
                     find_without_voodoo(sub_set, :params => params)
                  else
                     find_without_voodoo(*args)
                  end
               end

               alias_method :find_without_voodoo, :find
               alias_method :find, :find_with_voodoo

               def collection_path_with_voodoo(prefix_options = { }, query_options = nil)
                  check_prefix_options(prefix_options)
                  prefix_options, query_options = split_options(prefix_options) if query_options.nil?
                  "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
               end

               alias_method :collection_path_without_voodoo, :collection_path
               alias_method :collection_path, :collection_path_with_voodoo
            end
         end
      end
      module Query
         class Conditions
            def initialize(&block)
               @columns = []
               block.call(self) unless block.nil?
            end

            def to_where_conditions
               query_strings = []
               arguments     = []

               @columns.each do |column|
                  # Get the conditions of each column
                  query_string, *column_arguments = column.to_query_condition

                  # Append them to the rest
                  query_strings << query_string
                  arguments << column_arguments
               end

               # Build them up into the right format
               full_query_string = query_strings.join(" AND ")
               full_query_string
            end

            def method_missing(name, *args)
               column = Column.new(name)
               @columns << column
               column
            end
         end

         class Column
            attr_reader :name, :operator, :operand

            def initialize(name)
               @name = name
            end

            OPERATOR_MAP = {
               :== => "=",
               :>= => ">=",
               :<= => "<=",
               :>  => ">",
               :<  => "<",
               :^  => "!=",
               :*  => "IN",
               :=~ => "INCLUDES"
            }

            [:==, :>=, :<=, :>, :<, :^, :*, :=~].each do |operator|
               define_method(operator) do |operand|
                  @operator = operator
                  if operand.instance_of? String
                     operand = "'#{operand}'"
                  end
                  @operand = operand
               end

               def to_query_condition
                  "#{name}#{OPERATOR_MAP[operator]}#{operand}"
               end
            end
         end
      end
      module OOYALA
         def self.generate_signature(secret, http_method, request_path, query_string_params, request_body = nil)
            string_to_sign      = secret + http_method + request_path
            sorted_query_string = query_string_params.sort { |pair1, pair2| pair1[0] <=> pair2[0] }
            string_to_sign      += sorted_query_string.map { |key, value| "#{key}=#{value}" }.join
            string_to_sign      += request_body.to_s
            signature           = Base64::encode64(Digest::SHA256.digest(string_to_sign))[0..42].chomp("=")
            return signature
         end

         def self.expires
            t = Time.now
            Time.local(t.year, t.mon, t.day, t.hour + 1).to_i
         end
      end
   end
end

ActiveResource::Base.send :include, Acts::Voodoo

ActiveResource::Formats[:json]

class Asset < ActiveResource::Base
   my_api_key    = 'JkN2w61tDmKgPl4y395Rp1vAdlcq.IqBgb'
   my_api_secret = 'nU2WjeYoEY0MJKtK1DRpp1c6hNRoHgwpNG76dJkX'

   acts_as_voodoo :api_key => my_api_key, :api_secret => my_api_secret

   self.site = "https://api.ooyala.com/v2"
end

# ActiveResource::HttpMock.respond_to do |mock|
# mock.post "/videos.json", {"Accept" => "application/json"}, {:video => {:id => 1, :name => "Matz"}}.to_json, 201, "Location" => "/stories/1.json"
# mock.get "/videos.json", {"Accept" => "application/json"}, {:video => {:id => 1, :name => "eZYMTFMWC9TzcemOyKxFN64H9Tx3gzYYeLD1ir6hfzU= "}}.to_json
# mock.put "/videos/1.json", {"Accept" => "application/json"}, nil, 204
# mock.delete "/stories/1.json", {}, nil, 200
# end

results = Asset.find(:all) do |vid|
   vid.description == "Under the sea."
   vid.duration > 600
end
puts results

puts "done"
