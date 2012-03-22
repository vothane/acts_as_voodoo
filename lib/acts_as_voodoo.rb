require 'rubygems'
require 'active_resource'
require 'active_support'
require 'digest/sha2'
require 'base64'
require 'query'
require 'ooyala'

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
                  scope        = args.slice!(0)
                  options      = args.slice!(0)
                  path         = "/v2/#{collection_name}"
                  path         = "#{path}/#{scope}" if scope.instance_of? String
                  this_params  = { 'api_key' => self.api_key, 'expires' => OOYALA::expires }
            
                  if block_given?
                     conditions = Query::Conditions.new(&block)

                     this_params.merge(options) if options.instance_of? Hash                     
                     this_params['where']     = conditions.to_where_conditions
                     this_params['signature'] = OOYALA::generate_signature(self.api_secret, "GET", path, this_params, nil)
                     
                     if scope.instance_of? Integer
                        unless scope == 1
                           scope = :all
                        else
                           scope = :one   
                        end
                     end                     
                     
                     find_without_voodoo(scope, :params => this_params)
                  else                                          
                    if options
                       if options[:from]
                          this_params['signature'] = OOYALA::generate_signature( self.api_secret, "GET", "#{path}#{options[:from]}", this_params) 
                          find_without_voodoo( scope, :from => "#{path}#{options[:from]}", :params => this_params )
                       elsif
                          this_params['signature'] = OOYALA::generate_signature( self.api_secret, "GET", path, this_params) 
                          find_without_voodoo( scope, this_params.merge({:params => options}) )
                       end
                    else
                       this_params['signature'] = OOYALA::generate_signature( self.api_secret, "GET", path, this_params) 
                       find_without_voodoo( scope, :params => this_params )
                    end
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
            
               def element_path_with_voodoo(id, prefix_options = {}, query_options = nil)
                  check_prefix_options(prefix_options)
                  prefix_options, query_options = split_options(prefix_options) if query_options.nil?
                  "#{prefix(prefix_options)}#{collection_name}/#{URI.parser.escape id.to_s}#{query_string(query_options)}"
               end
          
               alias_method :element_path_without_voodoo, :element_path
               alias_method :element_path, :element_path_with_voodoo
            end
            include InstanceMethods
         end
      end
      
      module InstanceMethods
         def update
            patch_hash          = ActiveSupport::JSON.decode(encode)
            root                = ActiveSupport::Inflector.singularize self.class.collection_name
            patch_hash          = patch_hash[root]
            patch_body          = ActiveSupport::JSON.encode(patch_hash)
            params              = { 'api_key' => self.api_key, 'expires' => OOYALA::expires }
            path                = "#{collection_path[0..-1]}" 
            params['signature'] = OOYALA::generate_signature( self.api_secret, "PATCH", path, params, patch_body)

            connection.put("#{element_path(prefix_options)[0..-1]}?#{params.to_query}", post_body, self.class.headers).tap do |response|
               load_attributes_from_response(response)
            end
         end

         def create
            post_hash           = ActiveSupport::JSON.decode(encode)
            root                = ActiveSupport::Inflector.singularize self.class.collection_name
            post_hash           = post_hash[root]
            post_body           = ActiveSupport::JSON.encode(post_hash)
            params              = { 'api_key' => self.api_key, 'expires' => OOYALA::expires }
            path                = "#{collection_path[0..-1]}" 
            params['signature'] = OOYALA::generate_signature( self.api_secret, "POST", path, params, post_body)
            
            connection.post("#{collection_path[0..-1]}?#{params.to_query}", post_body, self.class.headers).tap do |response|
               self.id = id_from_response(response)
               load_attributes_from_response(response)
            end
         end      
      end
   end
end

ActiveResource::Base.send :include, Acts::Voodoo