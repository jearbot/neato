class RunNeatoJob < ApplicationJob
  queue_as :default
  require 'oauth2'
  require 'openssl'

  ROBOT_SERIAL = Rails.application.config.serial_number.freeze
  ROBOT_SECRET = Rails.application.config.secret.freeze
  HEADER_URL = "application/vnd.neato.beehive.v1+json".freeze
  API_ENDPOINT = "https://beehive.neatocloud.com/oauth2/token".freeze
  CLIENT_ID = Rails.application.config.client_id.freeze
  CLIENT_SECRET_KEY = Rails.application.config.client_secret_key.freeze
  REDIRECT_URI = "https://atx.luac.es".freeze
  SCOPE = 'control_robots'.freeze
  NEATO_ENDPOINT = "https://apps.neatorobotics.com/".freeze
  ACCESS_TOKEN = AccessToken.last.key.freeze
  REFRESH_TOKEN = RefreshToken.last.key.freeze

  def perform
    # oauth2
    # get_token

    response = HTTParty.get("#{NEATO_ENDPOINT}/users/me/robots",
      headers: {
        'Accept' => HEADER_URL,
        'Authorization' =>  "Bearer " + "#{ACCESS_TOKEN}",
      }
    )
    body = '{"reqId":"77", "cmd":"getRobotState"}'

    response = HTTParty.post("https://nucleo.neatocloud.com:4443/vendors/neato/robots/#{ROBOT_SERIAL}/messages",
      headers: {
        'Accept' => 'application/vnd.neato.nucleo.v1',
        'Date' => date = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT"),
        'Authorization' =>  "NEATOAPP " + signature,
      },
      body: '{"reqId":"77", "cmd":"getRobotState"}'
    )
  end

  private

  def oauth2
    @client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET_KEY, :site => NEATO_ENDPOINT)

    response = @client.auth_code.authorize_url(:redirect_uri => REDIRECT_URI, :scope => SCOPE)

    response = response.gsub!('/oauth/','/oauth2/')
  end
  # move to a new job to refresh every x days
  # put expiration on token and run this job
  def refresh_token
    response = HTTParty.post(API_ENDPOINT,
    body: {
      "grant_type": "refresh_token",
      "refresh_token": REFRESH_TOKEN
      }
    )
  end

  def signature
    robot_serial = ROBOT_SERIAL
    date = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")

    robot_secret_key = ROBOT_SECRET

    body = '{"reqId":"77", "cmd":"getRobotState"}'

    string_to_sign = "#{robot_serial.downcase}\n#{date}\n#{body}"

    signature = OpenSSL::HMAC.hexdigest('sha256', robot_secret_key, string_to_sign)
  end

  # move to a new utility maybe or to the access token model

  def get_access_token
    response = HTTParty.post(API_ENDPOINT,
      body: {
        "grant_type": "authorization_code",
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET_KEY,
        "redirect_uri": REDIRECT_URI,
        "code": "5625ed0445c3698b6cf9bac7e9070de7a93694c3f27f4f0d64fdfe8a3683b665"
      }
    )
  end
end
