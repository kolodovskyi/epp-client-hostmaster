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
    # [<tt>:addr</tt>] array with IP addresses (4 and 6 versions).
    #   representing the IP address. The value is a array with IP addresses.
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

      if (value = host.xpath('host:addr', EPPClient::SCHEMAS_URL)).size > 0
        ret[:addr] = value.map {|ip| IPAddr.new(ip.text)}
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
            xml.host :name, args[:name]
            if host.key? :addr
              host[:addr].each {|ip| xml.host :addr, ip}
            end
          end
        end
      end
    end

    # TODO: doc
    def host_create(contact)
      response = send_request(host_create_xml(contact))
      get_result(:xml => response, :callback => :host_create_process)
    end

    # TODO: continue...
  end
end