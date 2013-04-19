require 'digest/sha2'
require 'base64'

ROUND_UP_TIME = 300

module OOYALA
  def self.generate_signature(secret, http_method, request_path, query_string_params, request_body = nil)
    string_to_sign      = "#{secret}#{http_method}#{request_path}"
    sorted_query_string = query_string_params.sort { |pair1, pair2| pair1[0].to_s <=> pair2[0].to_s }
    string_to_sign      += sorted_query_string.map { |key, value| "#{key}=#{value}" }.join
    string_to_sign      += request_body.to_s
    signature           = Base64::encode64(Digest::SHA256.digest(string_to_sign))[0..42].chomp("=")
    return signature
  end

  def self.expires(expiration_window = 25)
    expiration = Time.now.to_i + expiration_window
    expiration + ROUND_UP_TIME - (expiration%ROUND_UP_TIME)
  end

  def self.find_params(*args, asset, &block)
    scope        = args.slice!(0)
    scope        = :all if scope.instance_of? Integer
    options      = args.slice!(0)
    path         = "/v2/#{asset.collection_name}"
    path         = "#{path}/#{scope}" if scope.instance_of? String
    this_params  = { 'api_key' => asset.api_key, 'expires' => OOYALA::expires }

    if block_given?
       conditions = Query::Conditions.new(&block)

       this_params.merge(options) if options.instance_of? Hash
       this_params['where']     = conditions.to_where_conditions
       this_params['signature'] = OOYALA::generate_signature(self.api_secret, "GET", path, this_params, nil)
       return this_params
    else   
      if options && options[:from]
        this_params['signature'] = OOYALA::generate_signature( asset.api_secret, "GET", "#{path}#{options[:from]}", this_params)
        return this_params
      elsif options
        this_params['signature'] = OOYALA::generate_signature( asset.api_secret, "GET", path, this_params)
        return this_params
      else
        this_params['signature'] = OOYALA::generate_signature( asset.api_secret, "GET", path, this_params)
        return this_params
      end
    end
  end  
end