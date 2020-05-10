class RunNeatoJob < ApplicationJob
  queue_as :default
  require 'openssl'
  require 'net/http'
  require 'uri'
  require 'json'
  require 'oauth'

  # Helpful website
  # https://forum.logicmachine.net/showthread.php?tid=660

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
