require "typhoeus"
require "builder"
require "base64"

class DigiFi
  attr_reader :host
  def initialize(host = ENV["DIGI_FI_HOST"], username = ENV["DIGI_FI_USERNAME"], password = ENV["DIGI_FI_PASSWORD"])
    @host = host
    @username = username
    @password = password
  end

  def send_message(message)
    body = sci_request(set_color(message).to_json).to_xml
    Typhoeus::Request.post(
      "#{host}/ws/sci",
      :body    => body,
      :headers => {
        "Content-Type" => "text/xml; charset=utf-8",
        "Content-length" => body.size,
        "Authorization" => "Basic #{auth_base64}"
      }
    )
  end

  def client
    @client ||= HTTPClient.new
  end

  def sci_request(message)
    builder = Builder::XmlMarkup.new
    builder.sci_request(version: "1.0") do |sci_request|
      sci_request.send_message do |send_message|
        send_message.targets do |targets|
          targets.device(id: "all")
        end
      end
      sci_request.rci_request(version: "1.1") do |rci_request|
        rci_request.do_command(message, target: "set_color")
      end
    end
  end

  def set_color(message)
    [{
      srcLoc: message.location_on_wall,
      srcTime: Time.now.to_i,
      targetColor: [message.red, message.green, message.blue],
      blob: message.animation_data
    }]
  end

  def auth_base64
    Base64.encode("#{username}:#{password}")
  end
end
