module Helper
  def self.deroot(json_hash, root)
    hash          = ActiveSupport::JSON.decode(json_hash)
    derooted_hash = hash[root]
    jsonify_hash  = ActiveSupport::JSON.encode(derooted_hash)
    jsonify_hash
  end
end