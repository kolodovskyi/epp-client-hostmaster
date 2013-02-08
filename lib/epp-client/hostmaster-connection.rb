module EPPClient
  module HostmasterConnection
    def send_frame(xml)
      @sent_frame = xml
      @socket.write [xml.bytesize + 4].pack("N")
      @socket.write xml
      sent_frame_to_xml
    end

    def close_connection
      log.close unless log.nil?
      super
    end
  end
end