require 'digest/sha2'
require 'base64'
require 'ostruct'

ROUND_UP_TIME = 300

module OOYALA
  def self.generate_signature(secret, http_method, request_path, query_string_params, request_body = nil)
    string_to_sign = "#{secret}#{http_method}#{request_path}"
    sorted_query_string = query_string_params.sort { |pair1, pair2| pair1[0].to_s <=> pair2[0].to_s }
    string_to_sign += sorted_query_string.map { |key, value| "#{key}=#{value}" }.join
    string_to_sign += request_body.to_s
    signature = Base64::encode64(Digest::SHA256.digest(string_to_sign))[0..42].chomp("=")
    return signature
  end

  def self.expires(expiration_window = 25)
    expiration = Time.now.to_i + expiration_window
    expiration + ROUND_UP_TIME - (expiration%ROUND_UP_TIME)
  end

  def self.find_params(*args,
    asset, &block)

    find_params = Parameters.new(*args, asset)

    if block_given?
      conditions = Query::Conditions.new(&block)
      return find_params.params_with_block(conditions)
    else
      return find_params.params_without_block
    end

  end

  def self.get_params(*args,
    asset, request_type)
    ParamsBuilder.build(*args, asset, request_type)
  end

end

class Credentials < OpenStruct
end

class Generic < OpenStruct
end

class Parameters
  def initialize(*args,
    asset)
    @args = args
    @asset = asset
  end

  def params_with_block(conditions)
    this_params = self.parametrize_credentials
    this_params.merge(options) if find_options.instance_of? Hash
    this_params['where'] = conditions.to_where_conditions
    this_params['signature'] = OOYALA::generate_signature(@asset.credentials.api_secret, "GET", self.find_path, this_params, nil)
    return {:params => this_params}
  end

  def params_without_block
    this_params = self.parametrize_credentials
    options = self.find_options
    path = self.find_path

    if options && options[:from]
      this_params['signature'] = OOYALA::generate_signature(@asset.credentials.api_secret, "GET", "#{path}#{options[:from]}", this_params)
      return {:from => "#{path}#{options[:from]}", :params => this_params}
    elsif options
      this_params['signature'] = OOYALA::generate_signature(@asset.credentials.api_secret, "GET", path, this_params)
      return this_params.merge({:params => options})
    else
      this_params['signature'] = OOYALA::generate_signature(@asset.credentials.api_secret, "GET", path, this_params)
      return {:params => this_params}
    end
  end

  def params_for_update
    params = self.parametrize_credentials
    path = "/v2/#{@asset.class.collection_name}/#{@asset.id}"
    params['signature'] = OOYALA::generate_signature(@asset.credentials.api_secret, "PATCH", "#{path}", params, self.body_for_update)
    "#{path}?#{params.to_query}"
  end

  def params_for_create
    params = self.parametrize_credentials
    path = "/v2/#{@asset.class.collection_name}"
    params['signature'] = OOYALA::generate_signature(@asset.credentials.api_secret, "POST", path, params, self.body_for_create)
    "#{path}?#{params.to_query}"
  end

  def params_for_destroy
    params = self.parametrize_credentials
    params['signature'] = OOYALA::generate_signature(@asset.credentials.api_secret, "DELETE", self.element_path, params)
    "#{self.element_path}?#{params.to_query}"
  end

  def find_scope
    scope = @args.slice(0)
    scope = :all if scope.instance_of? Integer
    scope
  end

  def find_path
    path = "/v2/#{@asset.collection_name}"
    scope = self.find_scope
    path = "#{path}/#{scope}" if scope.instance_of? String
    path
  end

  def find_options
    @args.slice(1)
  end

  def body_for_update
    patch_body = @args.slice(0)
    patch_hash = ActiveSupport::JSON.decode(patch_body)
    patch_hash.delete_if { |key, value| ['created_at', 'updated_at', 'embed_code', 'id', 'duration', 'parent_id'].include? key.to_s }
    body = ActiveSupport::JSON.encode(patch_hash)
    body
  end

  def body_for_create
    @args.slice(0)
  end

  def element_path
    @args.slice(0)
  end

  def parametrize_credentials
    {'api_key' => @asset.credentials.api_key, 'expires' => OOYALA::expires}
  end
end

class ParamsBuilder

  def self.build(*args,
    asset, request_type)
    http_params = Parameters.new(*args, asset)
    params_hash = {}
    params_hash[:url] = http_params.send("params_for_#{request_type}".to_sym)
    params_hash[:body] = http_params.send("body_for_#{request_type}".to_sym) unless request_type == "destroy"
    Generic.new(params_hash)
  end

end    