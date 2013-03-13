require 'net/http'
require 'uri'

class Tycoon
  def initialize(host, port)
    @ktserver = 'KyotoTycoon\/([0-9]{1,}\.){1,}[0-9]{1,}'
    @url = "http://#{host}:#{port}"
    uri = URI.parse(URI.escape("#{@url}/rpc/report"))
    response = Net::HTTP.get_response(uri)
    if response.nil?
      raise "Server #{@url} is unreachable."
    else
      server_field = response.get_fields('Server').join
      raise "Server #{@url} is not Kyoto Tycoon" if server_field.nil? or not server_field.match(@ktserver)
    end
  end

  def get_value(key)
    uri = URI.parse(URI.escape("#{@url}/#{key}"))
    response = Net::HTTP.get_response(uri)
    if response.code == '200'
      response.body
    elsif response.code == '404'
      ''
    else
      nil
    end
  end

  def set_value(key, value, expiration_timeout)
    uri = URI.parse(URI.escape("#{@url}/rpc/set"))
    response = Net::HTTP.post_form(uri,{'key' => key, 'value' => value, 'xt' => expiration_timeout})
    if response.code == '200'
      response.code
    else
      nil
    end
  end
end