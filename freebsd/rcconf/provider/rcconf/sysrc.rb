require 'puppet/provider/rcconf'

Puppet::Type.type(:rcconf).provide :sysrc, :parent => Puppet::Provider::Rcconf do
  desc "Provider for rcconf configuration items using sysrc application
    from http://druidbsd.sourceforge.net/"

  confine     :operatingsystem => :freebsd
  defaultfor  :operatingsystem => :freebsd

  commands :sysrc => "sysrc"      # dont specify full path so path gets searched.

  ##### Method: self.instances
      # Returns a pre-populated list of hashs already on the system (for pre-caching)
      #

  def self.instances
    Puppet.debug ("sysrc.instances called")

    # exec: "sysrc -a -v"   output: "<rcfile>: <key>: <value>\n"
    cmdline = ["-a", "-v"]
    begin

      output = sysrc(*cmdline)

    rescue Puppet::ExecutionFailure
      # Failure in execution
      raise Puppet::Error.new(output)
      return nil
    end

    # Scan the output and create the array of hashs to return
    keyin    = Hash.new
    keysall = []
    regex   = %r{^(\S+): (\S+): (.+)$}
    fields  = [:rcfile, :name, :value]
    linecount = output.split("\n").count
    output.split("\n").each do |line|
      if match = regex.match(line)
        # Data match, save to array
        fields.zip(match.captures) do |field, value|
          keyin[field] = value
          # Puppet.debug "sysrc.instances - found: #{field} = #{value} = #{keyin[field]}"
        end   # fields.zip  

        # Additional hardcoded items
        keyin[:ensure] = :present
        keyin[:provider] = self.name
        # Use dup, not "new"!
        keysall << keyin.dup
        keyin.clear
      else
        # incorrect output - log to debug
        Puppet.debug ("sysrc.instances - Unparsable output line: #{output}")
      end   # if
    end   # output.split

    # All done, return array
    Puppet.debug ("sysrc.instances completed - found #{keysall.count} keys among #{linecount} output lines")
    keysall

  end   # self.instances def
 
  ##### Ensurable methods:
      #   exists?    = check to see if value is set
      #   enable      = create the key/value pair
      #   disable     = delete the key/value pair

  ### Method: exists?
    # returns boolean style :true/:false if the key exists.

  def exists?  
    Puppet.debug ("sysrc.exists? called")
    # Call self.value (code reuse)
    retval = self.value
    Puppet.debug ("sysrc.exists? - called self.value which returned: #{retval}")

    if retval == :absent
      Puppet.debug("sysrc.exists? - completed. Returning false")
      false
    else
      Puppet.debug("sysrc.exists? - completed. Returning true")
      true
    end
  end   # def exists?



  ### Method: create
    # sets the key to the value

  def create
    # Just call self.value since it will create the key (:value is defaulted to :nil)
    Puppet.debug("sysrc.create - called")

    self.value(@resource[:value])
 
    Puppet.debug("sysrc.create - completed")
  end   # def enable

  ### Method: destroy
    # Deletes the key/value in question

  def destroy
    # Remove the corresponding key
    # exec: "sysrc -x [-f ":rcfile"] key
    Puppet.debug("sysrc.destroy - called")

    cmdline = ["-x"]
    begin
      if not ((@resource[:rcfile] == :system) or (@resource[:rcfile] == :default))
        cmdline << [ "-f", "#{@resource[:rcfile]}" ]
      end

      cmdline << @resource[:name]

      output = sysrc(*cmdline)

    rescue Puppet::ExecutionFailure
      # Failure in execution
      raise Puppet::Error.new(output)
      return nil
    end

    Puppet.debug("sysrc.destroy - completed")
  end   # def

  ### Method: value
    # Sets the key to value (same as enable)
    # Getter method

  def value
    Puppet.debug ("sysrc.value (getter) - called")
    # exec: "sysrc -e -i :name" - return value means it's there
    cmdline = ["-e", "-i"]
    begin
      if not ((@resource[:rcfile] == :system) or (@resource[:rcfile] == :default))
        cmdline << [ "-f", "#{@resource[:rcfile]}" ]
      end

      cmdline << @resource[:name]
      output = sysrc(*cmdline)

    rescue Puppet::ExecutionFailure
      # Failure in execution
      raise Puppet::Error.new("Error executing sysrc: #{output}")
      :absent
    end

    if output =~ /^(.+)="(.*)"$/
      if $2 == ""
        Puppet.debug("sysrc.value (getter) - completed: parsed value = :nil")
        :nil
      else
        Puppet.debug("sysrc.value (getter) - completed: parsed value = (#{$2})")
        $2
      end
    else
      Puppet.debug("sysrc.value (getter) - didn't find the key #{@resource[:name]}")
      :absent
    end
  end   # def value

  ### Method: value=(val)
    # Setter method

  def value=(val)
    Puppet.debug ("sysrc.value (setter) - called")
    # exec: "sysrc :name=:val" - return value means it's there
    cmdline = []
    begin
      if not ((@resource[:rcfile] == :system) or (@resource[:rcfile] == :default))
        cmdline << [ "-f", "#{@resource[:rcfile]}" ]
      end
      if @resource[:value] == :nil
        cmdline << [ "#{@resource[:name]}=" ]
      else
        cmdline << [ "#{@resource[:name]}=#{val}" ]
      end

      output = sysrc(*cmdline)

    rescue Puppet::ExecutionFailure
      # Failure in execution
      raise Puppet::Error.new("Error executing sysrc: #{output}")
      :absent
    end

    Puppet.info ("sysrc.value changed config key \"#{@resource[:name]}\" to: \"#{val}\"")
    Puppet.debug ("sysrc.value (setter) - completed.")
  end   # def value


end   # provider
