
class Puppet::Provider::Rcconf < Puppet::Provider
  # Prefetch method 
  #  - called with hash (which is a listing of keys (rcconf names) to value (rcconf config hash))
  #   - hash format  { "keyname" => confighash, .. }
  #  - calls self.instances (returns array of hashes) and then matches on that.

  def self.prefetch(userkeys)
    Puppet.debug ("rcconf.prefetch: called (#{userkeys.count} items in list})")
    instances.each do |foundhash|
      if matchresource = userkeys[foundhash[:name]]
        # resource object to be configured.
        Puppet.debug ("rcconf.prefetch: matched item in instances: #{foundhash[:provider]}: #{foundhash[:name]}")
        matchresource.provider = foundhash[:provider]
      end   # if
    end   # eachloop
  end   # def method

end   # class
