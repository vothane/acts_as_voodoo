require 'digest/sha2'
require 'base64'

ROUND_UP_TIME = 300

module OOYALA
   def self.generate_signature(secret, http_method, request_path, query_string_params, request_body = nil)
      string_to_sign      = "#{secret}#{http_method}#{request_path}"
      sorted_query_string = query_string_params.sort { |pair1, pair2| pair1[0] <=> pair2[0] }
      string_to_sign      += sorted_query_string.map { |key, value| "#{key}=#{value}" }.join
      string_to_sign      += request_body.to_s
      signature           = Base64::encode64(Digest::SHA256.digest(string_to_sign))[0..42].chomp("=")
      return signature
   end

   def self.expires(expiration_window = 15)
      expiration = Time.now.to_i + expiration_window
      expiration + ROUND_UP_TIME - (expiration%ROUND_UP_TIME)
   end
end