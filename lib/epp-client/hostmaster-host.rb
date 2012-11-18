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

  end
end