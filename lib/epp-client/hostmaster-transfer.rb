module EPPClient
  module HostmasterTransfer
    def transfer_xml(domain, op)
      command do |xml|
        xml.transfer op: op do
          xml.domain :transfer, 'xmlns:domain' => EPPClient::SCHEMAS_URL['domain-1.1'] do
            xml.domain :name, domain[:name]
            domain_period_xml(xml, domain[:period]) if domain.key? :period
            if domain.key? :authInfo
              xml.domain :authInfo do
                xml.domain :pw, domain[:authInfo]
              end
            end
          end
        end
      end
    end

    def transfer(domain, op)
      domain = { name: domain } if domain.is_a? String
      response = send_request(transfer_xml(domain, op))
      get_result(:xml => response, :callback => :transfer_process)
    end

    %w(request cancel approve reject query).each do |op|
      define_method("transfer_#{op}") { |domain| transfer(domain, op.to_sym) }
    end

    def transfer_process(xml)
      trn = xml.xpath('epp:resData/domain:trnData', EPPClient::SCHEMAS_URL)
      {
        name: trn.xpath('domain:name', EPPClient::SCHEMAS_URL).text,
        trStatus: trn.xpath('domain:trStatus', EPPClient::SCHEMAS_URL).text,
        reID: trn.xpath('domain:reID', EPPClient::SCHEMAS_URL).text,
        reDate: DateTime.parse(trn.xpath('domain:reDate', EPPClient::SCHEMAS_URL).text),
        acID: trn.xpath('domain:acID', EPPClient::SCHEMAS_URL).text,
        acDate: DateTime.parse(trn.xpath('domain:acDate', EPPClient::SCHEMAS_URL).text),
        exDate: DateTime.parse(trn.xpath('domain:exDate', EPPClient::SCHEMAS_URL).text)
      }
    end
  end
end