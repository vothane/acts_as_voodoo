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