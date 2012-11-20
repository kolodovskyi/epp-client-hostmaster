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

    def contact_disclose_xml(xml, disclose)
      [:show, :hide].each do |operation|
        next unless disclose.key? operation
        xml.contact :disclose, flag: operation == :show ? '1' : '0' do
          disclose[operation].each do |element|
            if element.key? :type
              xml.contact element[:name].to_sym, type: element[:type]
            else
              xml.contact element[:name].to_sym
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
              xml.contact :postalInfo, type: type do
                xml.contact :name, infos[:name]
                xml.contact :org, infos[:org] if infos.key?(:org)
                xml.contact :addr do
                  if infos[:addr].key? :street
                    infos[:addr][:street].each do |street|
                      xml.contact :street, street
                    end
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
            contact_disclose_xml(xml, contact[:disclose]) if contact.key?(:disclose)
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

    def contact_update_xml(args)
      command do |xml|
        xml.update do
          xml.contact :update, 'xmlns:contact' => EPPClient::SCHEMAS_URL['contact-1.1'] do
            xml.contact :id, args[:id]
            if args.key?(:add) && args[:add].key?(:status)
              xml.contact :add do
                args[:add][:status].each do |s|
                  xml.contact :status, s: s
                end
              end
            end
            if args.key?(:rem) && args[:rem].key?(:status)
              xml.contact :rem do
                args[:rem][:status].each do |s|
                  xml.contact :status, s: s
                end
              end
            end
            if args.key?(:chg)
              contact = args[:chg]
              xml.contact :chg do
                if contact.key?(:postalInfo)
                  contact[:postalInfo].each do |type,infos|
                    xml.contact :postalInfo, type: type do
                      xml.contact :name, infos[:name]
                      xml.contact :org, infos[:org] if infos.key? :org
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
                end
                [:voice, :fax, :email].each do |val|
                  xml.contact val, contact[val] if contact.key? val
                end
                if contact.key?(:authInfo)
                  xml.contact :authInfo do
                    xml.contact :pw, contact[:authInfo]
                  end
                end
                contact_disclose_xml(xml, contact[:disclose]) if contact.key?(:disclose)
              end
            end
          end
        end
      end
    end
  end
end