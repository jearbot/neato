class RunNeatoJob < ApplicationJob
  queue_as :default
  require 'openssl'
  require 'net/http'
  require 'uri'
  require 'json'
  require 'oauth2'

  SERIAL = Rails.application.config.serial_number.freeze
  SECRET = Rails.application.config.secret.freeze
  API_ENDPOINT = "application/vnd.neato.beehive.v1+json".freeze
  URL = "https://beehive.neatocloud.com".freeze
  CLIENT_ID = Rails.application.config.client_id.freeze
  CLIENT_SECRET_KEY = Rails.application.config.client_secret_key.freeze
  REDIRECT_URI = "https://atx.luac.es".freeze

  def perform
    # authenticate
    oauth

    response = HTTParty.get("#{URL}/users/me",
      headers: {
        'Accept' => API_ENDPOINT,
        # 'Name' => SERIAL,
        # 'Date' => Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT"),
        'Authorization' =>  "Bearer " + ""
      },
      # body: '{"reqId":"1","cmd":"startCleaning","params":{"category":2,"mode":2,"navigationMode":1}}'
    )
  end

  private

  # def authenticate
  #   # request params
  #   robot_serial = RunNeatoJob::SERIAL
  #   date = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")
  #   # => "Fri, 03 Apr 2015 09:12:31 GMT"
  #   body = '{"reqId":"77", "cmd":"getRobotState"}'
  #   robot_secret_key = RunNeatoJob::SECRET

  #   # build string to be signed
  #   string_to_sign = "#{robot_serial.downcase}\n#{date}\n#{body}"
  #   # create signature with SHA256
  #   @token = OpenSSL::HMAC.hexdigest('sha256', robot_secret_key, string_to_sign)
  # end

  def oauth
    @client = OAuth::Consumer.new(CLIENT_ID, CLIENT_SECRET_KEY, { :site=> API_ENDPOINT })
    @access_token = OAuth::AccessToken.new(@client, @client.key, @client.secret)
  end

  def oauth2
    client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET_KEY, :site => URL)

    client.auth_code.authorize_url(:redirect_uri => REDIRECT_URI)

    token = client.auth_code.get_token('authorization_code_value', :redirect_uri => REDIRECT_URI, :headers => {'Authorization' => 'Basic some_password'})
    response = token.get('/api/resource', :params => { 'query_foo' => 'bar' })
    response.class.name
  end
end
