module EPPClient
  module HostmasterXML
    def hello
      send_request(builder {|xml| xml.hello})
    end

    def recv_frame_to_xml
      recv_xml = super
      log.write recv_xml.to_s.gsub(/^/, '>> ') if log
      recv_xml
    end

    def sent_frame_to_xml
      send_xml = super
      log.write send_xml.to_s.gsub(/^/, '>> ') if log
      send_xml
    end
  end
end
