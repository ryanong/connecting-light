require "typhoeus"
require "builder"
require "base64"

class DigiFi
  attr_reader :host, :username, :password
  def initialize(host = "http://my.idigi.co.uk", username = "yesyesno", password = "olympic#2012")
    @host = host
    @username = username
    @password = password
  end

  def send_message(message)
    body = sci_request(
      "set_color",
      set_color_params(message).to_json
    )
    send_request(body)
  end

  def set_color_params(message)
    [{
      srcLoc: message.location_on_wall,
      srcTime: message.created_at.to_i,
      targetColor: [message.red, message.green, message.blue],
      blob: message.animation_data
    }.merge(AdminSetting.fetch)]
  end

  def reload_json_settings
    body = sci_request("reload_json_settings")
    send_request(body)
  end

  def send_hello_world_ping
    body = sci_request("send_hello_world_ping")
    send_request(body)
  end

  def send_admin_settings
    body = sci_request(
      "admin_settings",
      AdminSetting.fetch.to_json
    )
    send_request(body)
  end

  COORDINATORS = {
    connectinglight_a: "00409DFF-FF6A6A37",
    connectinglight_b: "00409DFF-FF6A6A35",
    connectinglight_c: "00409DFF-FF6A6A33",
    connectinglight_d: "00409DFF-FF6A6A2F",
    connectinglight_e: "00409DFF-FF6A6A2E",
    connectinglight_f: "00409DFF-FF6B0889",
    connectinglight_g: "00409DFF-FF6A6A2C",
    connectinglight_h: "00409DFF-FF6A6A2B",
    connectinglight_i: "00409DFF-FF6A6A29",
    connectinglight_j: "00409DFF-FF6B0888",
    connectinglight_k: "00409DFF-FF6A6A2A",
    connectinglight_l: "00409DFF-FF6A6A30",
    connectinglight_m: "00409DFF-FF6B0886",
    connectinglight_o: "00409DFF-FF6A6A32",
    connectinglight_n: "00409DFF-FF6A6A36"
  }

  def sci_request(command, params = nil)
    Builder::XmlMarkup.new.sci_request(version: "1.0") do |sci_request|
      sci_request.send_message(synchronous: "false") do |send_message|
        send_message.targets do |targets|
          COORDINATORS.values.each do |id|
            targets.device(id: id)
          end
        end
        sci_request.rci_request(version: "1.1") do |rci_request|
          if params
            rci_request.do_command(params, target: command)
          else
            rci_request.do_command(target: command)
          end
        end
      end
    end
  end

  def send_request(body)
    Rails.logger.info(body)
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

  private

  def auth_base64
    Base64.encode64("#{username}:#{password}").strip
  end
end
