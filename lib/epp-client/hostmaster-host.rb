require "ipaddr"

module EPPClient
  module HostmasterHost
    def host_check_xml(*hosts) #:nodoc:
      command do |xml|
        xml.check do
          xml.host :check, 'xmlns:host' => EPPClient::SCHEMAS_URL['host-1.1'] do
            hosts.each { |host| xml.host :name, host }
          end
        end
      end
    end

    # Check the availability of hosts
    #
    # takes list of hosts as arguments
    #
    # returns an array of hashes containing three fields :
    # [<tt>:name</tt>] the host name
    # [<tt>:avail</tt>] availability
    # [<tt>:reason</tt>]
    #   the server-specific text to help explain why the object cannot be
    #   provisioned.
    #
    def host_check(*hosts)
      hosts.flatten!

      response = send_request(host_check_xml(*hosts))
      get_result(:xml => response, :callback => :host_check_process)
    end

    def host_check_process(xml) #:nodoc:
      xml.xpath('epp:resData/host:chkData/host:cd', EPPClient::SCHEMAS_URL).map do |dom|
        ret = {
          name: dom.xpath('host:name', EPPClient::SCHEMAS_URL).text,
          avail: dom.xpath('host:name', EPPClient::SCHEMAS_URL).attr('avail').value == '1',
        }
        unless (reason = dom.xpath('host:reason', EPPClient::SCHEMAS_URL).text).empty?
          ret[:reason] = reason
        end
        ret
      end
    end

    def host_info_xml(args) #:nodoc:
      command do |xml|
        xml.info do
          xml.host :info, 'xmlns:host' => EPPClient::SCHEMAS_URL['host-1.1'] do
            xml.host :name, args[:name]
          end
        end
      end
    end

    # Returns the informations about a host
    #
    # Takes either a unique argument, either
    # a string, representing the host name
    # or a hash with the following keys :
    # [<tt>:name</tt>] the host name
    #
    # Returned is a hash mapping:
    # [<tt>:name</tt>] host name.
    # [<tt>:roid</tt>]
    #   the Repository Object IDentifier assigned to the host object when
    #   the object was created.
    # [<tt>:status</tt>] the status or array of statuses of the host object.
    # [<tt>:addrv4</tt>] array with IPv4 addresses.
    # [<tt>:addrv6</tt>] array with IPv6 addresses.
    # [<tt>:clID</tt>] the identifier of the sponsoring client.
    # [<tt>:crID</tt>]
    #   the identifier of the client that created the host object.
    # [<tt>:crDate</tt>] the date and time of host object creation.
    # [<tt>:upID</tt>]
    #   the optional identifier of the client that last updated the host
    #   object.
    # [<tt>:upDate</tt>]
    #   the optional date and time of the most recent host object
    #   modification.
    # [<tt>:trDate</tt>]
    #   the optional date and time of the most recent successful host object
    #   transfer.
    def host_info(args)
      args = { name: args } if args.is_a? String
      response = send_request(host_info_xml(args))
      get_result(:xml => response, :callback => :host_info_process)
    end

    def host_info_process(xml) #:nodoc:
      host = xml.xpath('epp:resData/host:infData', EPPClient::SCHEMAS_URL)
      ret = {
        name: host.xpath('host:name', EPPClient::SCHEMAS_URL).text,
        roid: host.xpath('host:roid', EPPClient::SCHEMAS_URL).text,
      }
      if (status = host.xpath('host:status', EPPClient::SCHEMAS_URL)).size > 0
        ret[:status] = status.map {|s| s.attr('s')}
      end

      if (value = host.xpath('host:addr', EPPClient::SCHEMAS_URL, ip: 'v4')).size > 0
        ret[:addrv4] = value.map {|ip| IPAddr.new(ip.text)}
      end
      if (value = host.xpath('host:addr', EPPClient::SCHEMAS_URL, ip: 'v6')).size > 0
        ret[:addrv6] = value.map {|ip| IPAddr.new(ip.text)}
      end

      %w(clID crID upID).each do |val|
        if (value = host.xpath("host:#{val}", EPPClient::SCHEMAS_URL)).size > 0
          ret[val.to_sym] = value.text
        end
      end
      %w(crDate upDate trDate).each do |val|
        if (date = host.xpath("host:#{val}", EPPClient::SCHEMAS_URL)).size > 0
          ret[val.to_sym] = DateTime.parse(date.text)
        end
      end
      ret
    end

    def host_create_xml(host) #:nodoc:
      command do |xml|
        xml.create do
          xml.host :create, 'xmlns:host' => EPPClient::SCHEMAS_URL['host-1.1'] do
            xml.host :name, host[:name]
            if host.key? :addrv4
              host[:addrv4].each { |ip| xml.host :addr, { ip: 'v4' }, ip }
            end
            if host.key? :addrv6
              host[:addrv6].each { |ip| xml.host :addr, { ip: 'v6' }, ip }
            end
          end
        end
      end
    end

    # Creates a host
    #
    # Takes a hash as an argument containing the following keys :
    # [<tt>:name</tt>] host name.
    # [<tt>:addrv4</tt>] array with IPv4 addresses.
    # [<tt>:addrv6</tt>] array with IPv6 addresses.
    def host_create(host)
      %w(addrv4 addrv6).each do |type|
        next unless host.key? type
        host[type] = [ host[type] ] unless host[type].is_a? Array
      end
      response = send_request(host_create_xml(host))
      get_result(:xml => response, :callback => :host_create_process)
    end

    def host_create_process(xml) #:nodoc:
      host = xml.xpath('epp:resData/host:creData', EPPClient::SCHEMAS_URL)
      {
        name: host.xpath('host:name', EPPClient::SCHEMAS_URL).text,
        crDate: DateTime.parse(host.xpath('host:crDate', EPPClient::SCHEMAS_URL).text)
      }
    end

    def host_delete_xml(host) #:nodoc:
      command do |xml|
        xml.delete do
          xml.host :delete, 'xmlns:host' => EPPClient::SCHEMAS_URL['host-1.1'] do
            xml.host :name, host
          end
        end
      end
    end

    # Deletes a host
    #
    # Takes a single host for argument.
    #
    # Returns true on success, or raises an exception.
    def host_delete(host)
      response = send_request(host_delete_xml(host))
      get_result(response)
    end

    def host_update_xml(args) #:nodoc:
      command do |xml|
        xml.update do
          xml.host :update, 'xmlns:host' => EPPClient::SCHEMAS_URL['host-1.1'] do
            xml.host :name, args[:name]
            [:add, :rem].each do |operation|
              if args.key? operation
                xml.host operation do
                  args[operation][:status].each {|s| xml.host :status, s: s} if args[operation].key? :status
                  if args[operation].key? :addrv4
                    args[operation][:addrv4].each { |ip| xml.host :addr, { ip: 'v4' }, ip }
                  end
                  if args[operation].key? :addrv6
                    args[operation][:addrv6].each { |ip| xml.host :addr, { ip: 'v6' }, ip }
                  end
                end
              end
            end
          end
        end
      end
    end

    # Updates a host
    #
    # Takes a hash with the name, and at least one of the following keys :
    # [<tt>:name</tt>]
    #   the server-unique identifier of the host object to be updated.
    # [<tt>:add</tt>/<tt>:rem</tt>]
    #   adds or removes the following data from the host object :
    #   [<tt>:addrv4</tt>] an array of IPv4 addresses.
    #   [<tt>:addrv6</tt>] an array of IPv6 addresses.
    #   [<tt>:status</tt>] an array of status to add to/remove from the object.
    #
    # Returns true on success, or raises an exception.
    def host_update(args)
      [:add, :rem].each do |operation|
        next unless args.key?(operation)
        %w(addrv4 addrv6).each do |type|
          next unless args[operation].key? type
          args[operation][type] = [ args[operation[type]] ] unless args[operation][type].is_a? Array
        end
      end
      response = send_request(host_update_xml(args))
      get_result(response)
    end

  end
end