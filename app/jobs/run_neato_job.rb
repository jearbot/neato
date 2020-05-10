class RunNeatoJob < ApplicationJob
  queue_as :default
  require 'openssl'
  require 'net/http'
  require 'uri'
  require 'json'

  # SERIAL = Rails.application.config.serial_number.freeze
  # SECRET = Rails.application.config.secret.freeze

  SERIAL = Rails.application.config.serial_number.freeze
  SECRET = Rails.application.config.secret.freeze
  API_ENDPOINT = "https://nucleo.neatocloud.com:4443".freeze
  URL = "https://nucleo.neatocloud.com:4443/vendors/neato/robots/"
  CLIENT_ID = Rails.application.config.client_id.freeze
  CLIENT_SECRET_KEY = Rails.application.config.client_secret_key.freeze

  def perform
    authenticate
    oauth_token

    response = HTTParty.post("#{URL}#{SERIAL}/messages",
      headers: {
        'Accept' => 'application/vnd.neato.nucleo.v1',
        'Name' => SERIAL,
        'Date' => Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT"),
        'Authorization' =>  "NEATOAPP " + @token
      },
      body: '{"reqId":"1","cmd":"startCleaning","params":{"category":2,"mode":2,"navigationMode":1}}'
    )




    # uri = URI.parse("https://nucleo.neatocloud.com:4443/vendors/neato/robots/#{RunNeatoJob::SERIAL}/messages")
    # request = Net::HTTP::Post.new(uri)
    # request.content_type = "application/x-www-form-urlencoded; charset=UTF-8"
    # request["Connection"] = "keep-alive"
    # request["Accept"] = "application/vnd.neato.nucleo.v1"
    # request["Authorization"] = "NEATOAPP " + @token
    # request["X-Date"] = "Sat, 02 May 2020 01:36:39 GMT"
    # request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36"
    # request["Origin"] = "https://developers.neatorobotics.com"
    # request["Sec-Fetch-Site"] = "cross-site"
    # request["Sec-Fetch-Mode"] = "cors"
    # request["Sec-Fetch-Dest"] = "empty"
    # request["Referer"] = "https://developers.neatorobotics.com/demo/sdk-js/index.html"
    # request["Accept-Language"] = "en-US,en;q=0.9"
    request.body = JSON.dump({
      "reqId" => "1",
      "cmd" => "startCleaning",
      "params" => {
        "category" => 2,
        "mode" => 2,
        "navigationMode" => 1
      }
    })

    # req_options = {
    #   use_ssl: uri.scheme == "https",
    # }

    # response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    #   http.request(request)
    # end

    # puts response.body
  end

  private

  def authenticate
    # request params
    robot_serial = RunNeatoJob::SERIAL
    date = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")
    # => "Fri, 03 Apr 2015 09:12:31 GMT"
    body = '{"reqId":"77", "cmd":"getRobotState"}'
    robot_secret_key = RunNeatoJob::SECRET

    # build string to be signed
    string_to_sign = "#{robot_serial.downcase}\n#{date}\n#{body}"
    # create signature with SHA256
    @token = OpenSSL::HMAC.hexdigest('sha256', robot_secret_key, string_to_sign)
  end

  def oauth_token
    @client = OAuth::Consumer.new(CLIENT_ID, CLIENT_SECRET_KEY, { :site=> API_ENDPOINT })
    @access_token = OAuth::AccessToken.new(@client, @client.key, @client.secret)
  end
end
