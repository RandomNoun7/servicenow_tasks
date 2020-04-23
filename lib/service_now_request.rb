require_relative '../../ruby_task_helper/files/task_helper.rb'
require 'base64'
require 'json'
require 'net/http'
require 'openssl'

# This class organizes ruby http code used by all of the tasks.
class ServiceNowRequest
  def initialize(uri, http_verb, body, user, password)
    @uri = URI.parse(uri)
    @http_verb = http_verb.capitalize
    @body = body.to_json
    @user = user
    @password = password
  end

  def print_response
    Net::HTTP.start(@uri.host,
                    @uri.port,
                    use_ssl: @uri.scheme == 'https',
                    verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      header = { 'Content-Type' => 'application/json' }
      # Interpolate the HTTP verb and constantize to a class name.
      request_class_string = "Net::HTTP::#{@http_verb}"
      request_class = Object.const_get(request_class_string)
      # Add uri, fields and authentication to request
      request = request_class.new("#{@uri.path}?#{@uri.query}", header)
      request.body = @body
      request.basic_auth(@user, @password)
      # Make request to ServiceNow
      response = http.request(request)
      # Parse and print response
      json_response = JSON.parse(response.body)
      pretty_response = JSON.pretty_unparse(json_response)
      puts [pretty_response]
    end
  rescue => e
    raise TaskHelper::Error.new('Failure!', 'servicenow_integration.print_response', e)
  end
end
