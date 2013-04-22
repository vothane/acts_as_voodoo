module Acts
   module Voodoo # Video tOOlkit & Data for OOyala
      def self.included(base)
         base.extend ClassMethods
      end

      module ClassMethods
         def acts_as_voodoo(credentials = { })
            @primary_key = 'embed_code' if element_name == 'asset'
            cattr_accessor :credentials
            self.credentials = Credentials.new(api_key: credentials[:api_key], api_secret: credentials[:api_secret])

            class << self
               def find_with_voodoo(*args, &block)
                  find_without_voodoo(:all, OOYALA::find_params(*args, self, &block))
               end
               alias_method_chain :find, :voodoo

               def collection_path_with_voodoo(prefix_options = { }, query_options = nil)
                  check_prefix_options(prefix_options)
                  prefix_options, query_options = split_options(prefix_options) if query_options.nil?
                  "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
               end
               alias_method_chain :collection_path, :voodoo

               def element_path_with_voodoo(id, prefix_options = {}, query_options = nil)
                  check_prefix_options(prefix_options)
                  prefix_options, query_options = split_options(prefix_options) if query_options.nil?
                  "#{prefix(prefix_options)}#{collection_name}/#{URI.parser.escape id.to_s}#{query_string(query_options)}"
               end
               alias_method_chain :element_path, :voodoo

            end
            include InstanceMethods
         end
      end

      module InstanceMethods

         def update
            params = OOYALA::update_params(encode, self)
            run_callbacks :update do
              connection.patch(params.url, params.body, self.class.headers).tap do |response|
                load_attributes_from_response(response)
              end
            end
         end

         def create
            params = OOYALA::create_params(encode, self)
            run_callbacks :create do
              connection.post(params.url, params.body, self.class.headers).tap do |response|
                self.id = id_from_response(response)
                load_attributes_from_response(response)
              end
            end
         end

         def destroy
            params = OOYALA::destroy_params(element_path, self)
            run_callbacks :destroy do
              connection.delete(params.url, self.class.headers)
            end
         end

         def put(method_name, options = {}, body = '')
            connection.put(custom_method_element_url(method_name, options), body, self.class.headers)
         end

         def get(method_name, options = {})
            self.class.format.decode(connection.get(custom_method_element_url(method_name, options), self.class.headers).body)
         end

         def post(method_name, options = {}, body = nil)
            request_body = body.blank? ? encode : body
            if new?
              connection.post(custom_method_new_element_url(method_name, options), request_body, self.class.headers)
            else
              connection.post(custom_method_element_url(method_name, options), request_body, self.class.headers)
            end
         end

         def patch(method_name, options = {}, body = '')
            connection.patch(custom_method_element_url(method_name, options), body, self.class.headers)
         end

         def delete(method_name, options = {})
            connection.delete(custom_method_element_url(method_name, options), self.class.headers)
         end

         private

         def custom_method_element_url(method_name, options = {})
            "#{self.class.prefix(prefix_options)}#{self.class.collection_name}/#{id}/#{method_name}#{self.class.__send__(:query_string, options)}"
         end
      end
   end
end

ActiveResource::Base.send :include, Acts::Voodoo