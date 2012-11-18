module EPPClient
  module HostmasterContact
    def contact_check_xml(*contacts)
      command do |xml|
        xml.check do
          xml.contact :check, 'xmlns:contact' => EPPClient::SCHEMAS_URL['contact-1.1'] do
            contacts.each { |c| xml.contact :id, c }
          end
        end
      end
    end

    def contact_info_xml(args)
      command do |xml|
        xml.info do
          xml.contact :info, 'xmlns:contact' => EPPClient::SCHEMAS_URL['contact-1.1'] do
            xml.contact :id, args[:id]
            if args.key? :authInfo
              xml.contact :authInfo do
                xml.contact :pw, args[:authInfo]
              end
            end
          end
        end
      end
    end

    def contact_create_xml(contact)
      command do |xml|
        xml.create do
          xml.contact :create, 'xmlns:contact' => EPPClient::SCHEMAS_URL['contact-1.1'] do
            if contact.key?(:id)
              xml.contact :id, contact[:id]
            else
              xml.contact :id, 'autonic'
            end
            contact[:postalInfo].each do |type,infos|
              xml.contact :postalInfo, :type => type do
                xml.contact :name, infos[:name]
                xml.contact :org, infos[:org] if infos.key?(:org)
                xml.contact :addr do
                  infos[:addr][:street].each do |street|
                    xml.contact :street, street
                  end
                  xml.contact :city, infos[:addr][:city]
                  xml.contact :sp, infos[:addr][:sp] if infos[:addr].key? :sp
                  xml.contact :pc, infos[:addr][:pc] if infos[:addr].key? :pc
                  xml.contact :cc, infos[:addr][:cc]
                end
              end
            end
            xml.contact :voice, contact[:voice] if contact.key? :voice
            xml.contact :fax, contact[:fax] if contact.key? :fax
            xml.contact :email, contact[:email]
            xml.contact :authInfo do
              xml.contact :pw, contact[:authInfo]
            end
            if contact.key?(:disclose)
              xml.contact :disclose, flag: '1' do
                contact[:disclose].each do |disc|
                  if disc.key?(:type)
                    xml.contact disc[:name], :type => disc[:type]
                  else
                    xml.contact disc[:name]
                  end
                end
              end
            end
          end
        end
      end
    end

    def contact_delete_xml(contact)
      command do |xml|
        xml.delete do
          xml.contact :delete, 'xmlns:contact' => EPPClient::SCHEMAS_URL['contact-1.1'] do
            xml.contact :id, contact
          end
        end
      end
    end

  end
end