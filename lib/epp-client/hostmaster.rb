require "epp-client/base"
require "#{File.dirname(__FILE__)}/hostmaster-xml"
require "#{File.dirname(__FILE__)}/hostmaster-connection"
require "#{File.dirname(__FILE__)}/hostmaster-domain"
require "#{File.dirname(__FILE__)}/hostmaster-contact"
require "#{File.dirname(__FILE__)}/hostmaster-host"
require "#{File.dirname(__FILE__)}/hostmaster-rgp"
require "#{File.dirname(__FILE__)}/hostmaster-transfer"

module EPPClient
  class Hostmaster < Base
    VERSION = '0.2.4'

    SCHEMAS = %w(domain-1.1 host-1.1 contact-1.1 rgp-1.1)

    EPPClient::SCHEMAS_URL.merge!(SCHEMAS.inject({}) do |a,s|
      a[s.sub(/-1\.1$/, '')] = "http://hostmaster.ua/epp/#{s}" if s =~ /-1\.1$/
      a[s] = "http://hostmaster.ua/epp/#{s}"
      a
    end)

    include EPPClient::HostmasterXML
    include EPPClient::HostmasterConnection
    include EPPClient::HostmasterDomain
    include EPPClient::HostmasterContact
    include EPPClient::HostmasterHost
    include EPPClient::HostmasterRGP
    include EPPClient::HostmasterTransfer

    def initialize(attrs)
      unless attrs.key?(:client_id) && attrs.key?(:password) && attrs.key?(:ssl_cert) && attrs.key?(:ssl_key)
        raise ArgumentError, "client_id, password, ssl_cert and ssl_key are required"
      end
      attrs[:server] ||= 'epp.hostmaster.ua'
      attrs[:port] ||= 700
      attrs[:version] ||= '1.0'
      @services = EPPClient::SCHEMAS_URL.values_at('domain', 'host', 'contact')
      super(attrs)
    end
  end
end