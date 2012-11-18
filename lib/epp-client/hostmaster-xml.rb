module EPPClient
  module HostmasterXML
    def hello
      send_request(builder {|xml| xml.hello})
    end
  end
end
