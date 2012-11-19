module EPPClient
  module HostmasterRGP
    def domain_restore_xml(domain)
      command do |xml|
        xml.update do
          xml.domain :update, 'xmlns:domain' => EPPClient::SCHEMAS_URL['domain-1.1'] do
            xml.domain :name, domain
          end
        end
        xml.extension do
          xml.rgp :update, 'xmlns:rgp' => EPPClient::SCHEMAS_URL['rgp-1.1'] do
            xml.rgp :restore, op: 'request'
          end
        end
      end
    end

    # Restore a domain
    # Takes a single fully qualified domain name for argument.:
    #
    # Returns an array of rgpStatus.
    def domain_restore(domain)
      response = send_request(domain_restore_xml(domain))
      get_result(:xml => response)
    end
  end
end