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
    @date = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")

    get_signature
    response = HTTParty.post("https://nucleo.neatocloud.com:4443/vendors/neato/robots/#{ROBOT_SERIAL}/messages",
      headers: {
        'Accept' => 'application/vnd.neato.nucleo.v1',
        'Date' => @date,
        'Authorization' =>  "NEATOAPP " + @signature,
      },
      body: JSON.dump({ reqId: "13", cmd: "startCleaning", params: { category: 2, mode: 2, modifier: 1 }})
    )
  end

  def get_signature
    body = JSON.dump({ reqId: "13", cmd: "startCleaning", params: { category: 2, mode: 2, modifier: 1 }})

    string_to_sign = "#{ROBOT_SERIAL.downcase}\n#{@date}\n#{body}"

    @signature = OpenSSL::HMAC.hexdigest('sha256', ROBOT_SECRET, string_to_sign)
  end

  def get_robot_secret_key
    response = HTTParty.get("#{NEATO_ENDPOINT}/users/me/robots",
      headers: {
        'Accept' => HEADER_URL,
        'Authorization' =>  "Bearer " + "#{ACCESS_TOKEN}",
      }
    )
    body = '{"reqId":"1", "cmd":"getRobotState"}'
  end

  def get_map_id
    response = HTTParty.get("#{NEATO_ENDPOINT}/users/me/robots/#{ROBOT_SERIAL}/maps",
      headers: {
        'Accept' => HEADER_URL,
        'Authorization' =>  "Bearer " + "#{ACCESS_TOKEN}",
      }
    )
  end
end







  # private

  # def oauth2
  #   @client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET_KEY, :site => NEATO_ENDPOINT)

  #   response = @client.auth_code.authorize_url(:redirect_uri => REDIRECT_URI, :scope => SCOPE)

  #   response = response.gsub!('/oauth/','/oauth2/')
  # end
  # # move to a new job to refresh every x days
  # # put expiration on token and run this job
  # def refresh_token
  #   response = HTTParty.post(API_ENDPOINT,
  #   body: {
  #     "grant_type": "refresh_token",
  #     "refresh_token": REFRESH_TOKEN
  #     }
  #   )
  # end

  # # move to a new utility maybe or to the access token model

  # def get_access_token
  #   response = HTTParty.post(API_ENDPOINT,
  #     body: {
  #       "grant_type": "authorization_code",
  #       "client_id": CLIENT_ID,
  #       "client_secret": CLIENT_SECRET_KEY,
  #       "redirect_uri": REDIRECT_URI,
  #       "code": "a9b217c5825b25809f4c4298ad3a42806e8bd42c603bda569b490a7cc7a43004"
  #     }
  #   )
  # end