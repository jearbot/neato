class RunNeatoJob < ApplicationJob
  queue_as :default
  require 'oauth2'

  SERIAL = Rails.application.config.serial_number.freeze
  SECRET = Rails.application.config.secret.freeze
  HEADER_URL = "application/vnd.neato.beehive.v1+json".freeze
  API_ENDPOINT = "https://beehive.neatocloud.com/oauth2/token".freeze
  CLIENT_ID = Rails.application.config.client_id.freeze
  CLIENT_SECRET_KEY = Rails.application.config.client_secret_key.freeze
  REDIRECT_URI = "https://atx.luac.es".freeze
  SCOPE = 'control_robots'.freeze
  STATE = SecureRandom.uuid.freeze
  NEATO_URL = "https://apps.neatorobotics.com/".freeze


  def perform
    oauth2
    use_authorization_grant
    get_token

    response = HTTParty.get("#{URL}/users/me",
      headers: {
        'Accept' => HEADER_URL,
        'Authorization' =>  "Bearer " + @token
      },
      # body: '{"reqId":"1","cmd":"startCleaning","params":{"category":2,"mode":2,"navigationMode":1}}'
    )
  end

  private

  def oauth2
    @client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET_KEY, :site => URL)

    response = @client.auth_code.authorize_url(:redirect_uri => REDIRECT_URI, :scope => SCOPE)

    @response = response.gsub!('/oauth/','/oauth2/')
  end

  def use_authorization_grant

  end

  def get_token
    response = HTTParty.post(API_ENDPOINT,
      body: {
        "grant_type": "authorization_code",
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET_KEY,
        "redirect_uri": REDIRECT_URI,
        "code": @authorization_code
        }
    )

    @token = response["access_token"]
  end
end

# 'Name' => SERIAL,
# 'Date' => Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT"),