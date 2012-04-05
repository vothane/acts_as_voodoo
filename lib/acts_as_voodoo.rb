require 'rubygems'
require 'active_resource'
require 'active_support'
require 'query'
require 'ooyala'
require 'helper'

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
            @primary_key = 'embed_code' if element_name == 'asset'
            
            class << self
               def find_with_voodoo(*args, &block)
                  scope        = args.slice!(0)
                  scope        = :all if scope.instance_of? Integer
                  options      = args.slice!(0)
                  path         = "/v2/#{collection_name}"
                  path         = "#{path}/#{scope}" if scope.instance_of? String
                  this_params  = { 'api_key' => self.api_key, 'expires' => OOYALA::expires }
            
                  if block_given?
                     conditions = Query::Conditions.new(&block)

                     this_params.merge(options) if options.instance_of? Hash                     
                     this_params['where']     = conditions.to_where_conditions
                     this_params['signature'] = OOYALA::generate_signature(self.api_secret, "GET", path, this_params, nil)
                                          
                     find_without_voodoo(scope, :params => this_params)
                  else                                          
                    if options && options[:from]
                      this_params['signature'] = OOYALA::generate_signature( self.api_secret, "GET", "#{path}#{options[:from]}", this_params) 
                      find_without_voodoo( scope, :from => "#{path}#{options[:from]}", :params => this_params )
                    elsif options
                      this_params['signature'] = OOYALA::generate_signature( self.api_secret, "GET", path, this_params) 
                      find_without_voodoo( scope, this_params.merge({:params => options}) )
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
            patch_body          = Helper::deroot(encode, ActiveSupport::Inflector.singularize( self.class.collection_name ))
            params              = { 'api_key' => self.api_key, 'expires' => OOYALA::expires }
            path                = "/v2/#{self.class.collection_name}/#{id}" 
            params['signature'] = OOYALA::generate_signature( self.api_secret, "PATCH", path, params, patch_body )
            url                 = "#{self.class.site.scheme}://#{self.class.site.host}#{path}?#{URI.parser.escape params.to_query}"
            
            response = Helper::send_request('PATCH', url, patch_body)
            
            load_attributes_from_response(response)
         end

         def create
            post_body           = Helper::deroot(encode, ActiveSupport::Inflector.singularize( self.class.collection_name ))
            params              = { 'api_key' => self.api_key, 'expires' => OOYALA::expires }
            path                = "/v2/#{self.class.collection_name}" 
            params['signature'] = OOYALA::generate_signature( self.api_secret, "POST", path, params, post_body)
            
            connection.post("#{path}?#{params.to_query}", post_body, self.class.headers).tap do |response|
               self.id = id_from_response(response)
               load_attributes_from_response(response)
            end
         end  
         
         def destroy
            params              = { 'api_key' => self.api_key, 'expires' => OOYALA::expires }
            params['signature'] = OOYALA::generate_signature( self.api_secret, "DELETE", element_path, params)
            
            connection.delete("#{element_path}?#{params.to_query}", self.class.headers)
         end    
      end
   end
end

ActiveResource::Base.send :include, Acts::Voodoo