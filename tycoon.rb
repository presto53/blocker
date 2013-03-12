require 'net/http'
require 'uri'

class Tycoon
  def initialize(host, port)
    @ktserver = 'KyotoTycoon\/([0-9]{1,}\.){1,}[0-9]{1,}'
    @url = "http://#{host}:#{port}"
    uri = URI.parse("#{@url}/rpc/report")
    response = Net::HTTP.get_response(uri)
    server_field = response.get_fields('Server').join
    raise "Server http://#{@url} is not Kyoto Tycoon" if server_field.nil? or not server_field.match(@ktserver)
  end

  def get_value(key)
    uri = URI.parse("#{@url}/#{key}")
    response = Net::HTTP.get_response(uri)
    if response.code == '200'
      response.body
    else
      nil
    end
  end

  def set_value(key, value, expiration_timeout)
    uri = URI.parse("#{@url}/rpc/set?key=#{key}&value=#{value}&xt=#{expiration_timeout}")
    response = Net::HTTP.get_response(uri)
    if response.code == '200'
      response.code
    else
      nil
    end
  end
end