
Puppet::Type.newtype(:rcconf) do
    @doc = "Manages freebsd rc.conf style (ie: key=value) configuration files.
            :name   = the key name (eg: hostname)
            :value  = the stored key value (:nil = defined but blank)
            :rcfile = a specific file to modify/store the value in (eg: /etc/rc.conf.local)"

    ##### Properties (ie: must have correponding methods [getter+setter] in the provider)
        #

    # Ensurable Property: forces 3 methods to be needed: create, destroy, exists?
    ensurable

    # :value property - method gets called when the :value isn't correct
    newproperty (:value) do
      desc "Value of the key - :nil is a blank value (but key exists)"
      newvalues(:nil, /.+/)
      defaultto(:nil)
    end   # newproperty
 
    ##### Parameters (ie: non-interactive value storage)
        #

    newparam(:name) do
      desc "The name of the configuration key to manage (alphanumeric)"
      isnamevar
      validate do |val|
        unless val =~ /^\w+$/ 
          raise Puppet::Error, "AlphaNumeric characters only for name"
        end   # unless
      end   # validate
    end   # newparam

    newparam(:rcfile) do
      desc "Location of the file to modify (:system = system default, :default = provider default[*], <filename> = full path)"
      newvalues(:default, :system, /\/.+/)
      defaultto(:default) 
    end   # newparam

end   # type
