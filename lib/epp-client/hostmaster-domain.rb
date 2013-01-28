module EPPClient
  module HostmasterDomain
    def domain_check_xml(*domains) # :nodoc:
      command do |xml|
        xml.check do
          xml.domain :check, 'xmlns:domain' => EPPClient::SCHEMAS_URL['domain-1.1'] do
            domains.each {|domain| xml.domain :name, domain}
          end
        end
      end
    end

    def domain_info_xml(args)
      command do |xml|
        xml.info do
          xml.domain :info, 'xmlns:domain' => EPPClient::SCHEMAS_URL['domain-1.1'] do
            xml.domain :name, args[:name]
            if args.key? :authInfo
              xml.domain :authInfo do
                xml.domain :pw, args[:authInfo]
              end
            end
          end
        end
      end
    end

    def domain_nss_xml(xml, nss)
      xml.domain :ns do
        nss.each do |ns|
          if ns.is_a? Hash
            xml.domain :hostAttr do
              xml.domain :hostName, ns[:hostName]
              if ns.key?(:hostAddrv4)
                ns[:hostAddrv4].each do |v4|
                  xml.domain :hostAddr, {:ip => :v4}, v4
                end
              end
              if ns.key?(:hostAddrv6)
                ns[:hostAddrv6].each do |v6|
                  xml.domain :hostAddr, {:ip => :v6}, v6
                end
              end
            end
          else
            xml.domain :hostObj, ns
          end
        end
      end
    end

    def domain_contacts_xml(xml, args)
      args.each do |type,contacts|
        contacts.each do |c|
          xml.domain :contact, { type: type }, c
        end
      end
    end

    def domain_period_xml(xml, period)
      xml.domain :period, { unit: period[:unit] }, period[:number]
    end

    def domain_create_xml(args) #:nodoc:
      command do |xml|
        xml.create do
          xml.domain :create, 'xmlns:domain' => EPPClient::SCHEMAS_URL['domain-1.1'] do
            xml.domain :name, args[:name]
            domain_period_xml(xml, args[:period]) if args.key?(:period)
            domain_nss_xml(xml, args[:ns]) if args.key? :ns
            xml.domain :registrant, args[:registrant]
            domain_contacts_xml(xml, args[:contacts]) if args.key? :contacts
            xml.domain :license, args[:license] if args.key? :license
          end
        end
      end
    end

    def domain_create_process(xml) #:nodoc:
      dom = xml.xpath('epp:resData/domain:creData', EPPClient::SCHEMAS_URL)
      ret = {
        name: dom.xpath('domain:name', EPPClient::SCHEMAS_URL).text,
        crDate: DateTime.parse(dom.xpath('domain:crDate', EPPClient::SCHEMAS_URL).text),
        exDate: DateTime.parse(dom.xpath('domain:exDate', EPPClient::SCHEMAS_URL).text),
      }
    end


    def domain_delete_xml(domain) #:nodoc:
      command do |xml|
        xml.delete do
          xml.domain :delete, 'xmlns:domain' => EPPClient::SCHEMAS_URL['domain-1.1'] do
            xml.domain :name, domain
          end
        end
      end
    end

    def domain_renew_xml(domain)
      command do |xml|
        xml.renew do
          xml.domain :renew, 'xmlns:domain' => EPPClient::SCHEMAS_URL['domain-1.1'] do
            xml.domain :name, domain[:name]
            xml.domain :curExpDate, domain[:curExpDate].strftime('%Y-%m-%d')
            domain_period_xml(xml, domain[:period])
          end
        end
      end
    end

    # Renew a domain
    #
    # Takes a hash as an argument, containing the following keys :
    #
    # [<tt>:name</tt>] the domain name
    # [<tt>:period</tt>]
    #   an optionnal hash containing the period for withch the domain is
    #   registered with the following keys :
    #   [<tt>:unit</tt>] the unit of time, either "m"onth or "y"ear.
    #   [<tt>:number</tt>] the number of unit of time.
    # [<tt>:curExpDate</tt>]
    #   the date identifying the current end of the domain object
    #   registration period.
    # Returns a hash with the following keys :
    #
    # [<tt>:name</tt>] the fully qualified name of the domain object.
    # [<tt>:exDate</tt>]
    #   the date and time identifying the end of the domain object's
    #   registration period.
    def domain_renew(domain)
      domain[:curExpDate] = DateTime.parse(domain[:curExpDate]) unless domain[:curExpDate].is_a? DateTime
      response = send_request(domain_renew_xml(domain))
      get_result(:xml => response, :callback => :domain_renew_process)
    end

    def domain_renew_process(xml) #:nodoc:
      dom = xml.xpath('epp:resData/domain:renData', EPPClient::SCHEMAS_URL)
      ret = {
        name: dom.xpath('domain:name', EPPClient::SCHEMAS_URL).text,
        exDate: DateTime.parse(dom.xpath('domain:exDate', EPPClient::SCHEMAS_URL).text)
      }
    end

    def domain_update_xml(args) #:nodoc:
      command do |xml|
        xml.update do
          xml.domain :update, 'xmlns:domain' => EPPClient::SCHEMAS_URL['domain-1.1'] do
            xml.domain :name, args[:name]
            [:add, :rem].each do |ar|
              next unless args.key?(ar) && (args[ar].key?(:ns) || args[ar].key?(:contacts) || args[ar].key?(:status))
              xml.domain ar do
                domain_nss_xml(xml, args[ar][:ns]) if args[ar].key? :ns
                domain_contacts_xml(xml, args[ar][:contacts]) if args[ar].key? :contacts
                if args[ar].key? :status
                  args[ar][:status].each do |st,text|
                    if text.nil?
                      xml.domain :status, s: st
                    else
                      xml.domain :status, { s: st }, text
                    end
                  end
                end
              end
            end
            if args.key?(:chg) && (args[:chg].key?(:registrant) || args[:chg].key?(:authInfo))
              xml.domain :chg do
                xml.domain :registrant, args[:chg][:registrant] if args[:chg].key? :registrant
                if args[:chg].key? :authInfo
                  xml.domain :authInfo do
                    xml.domain :pw, args[:chg][:authInfo]
                  end
                end
              end
            end
          end
        end
      end
    end

  end
end