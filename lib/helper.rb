require 'rest_client'

module Helper
  def self.deroot(json_hash, root)
    hash          = ActiveSupport::JSON.decode(json_hash)
    derooted_hash = hash[root]
    jsonify_hash  = ActiveSupport::JSON.encode(derooted_hash)
    jsonify_hash
  end

  def self.send_request(http_method, url, request_body = nil)
    request = RestClient::Request.new\
    :method  => http_method.to_s.downcase.to_sym,
    :url     => url,
    :payload => request_body
    
    response = request.execute
    return response
  end
end