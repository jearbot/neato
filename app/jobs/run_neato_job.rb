class RunNeatoJob < ApplicationJob
  require 'oauth2'
  require 'openssl'

  ROBOT_SERIAL = Rails.application.config.serial_number.freeze
  ROBOT_SECRET = Rails.application.config.secret.freeze
  HEADER_URL = "application/vnd.neato.beehive.v1+json".freeze
  API_ENDPOINT = "https://beehive.neatocloud.com/oauth2/token".freeze
  CLIENT_ID = Rails.application.config.client_id.freeze
  CLIENT_SECRET_KEY = Rails.application.config.client_secret_key.freeze
  REDIRECT_URI = "https://atx.luac.es".freeze
  SCOPE = 'control_robots public_profile maps'.freeze
  NEATO_ENDPOINT = "https://apps.neatorobotics.com/".freeze
  ACCESS_TOKEN = AccessToken.last.key
  REFRESH_TOKEN = RefreshToken.last.key

  def perform
    @date = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")

    get_signature
    response = HTTParty.post("https://nucleo.neatocloud.com:4443/vendors/neato/robots/#{ROBOT_SERIAL}/messages",
      headers: {
        'Accept' => 'application/vnd.neato.nucleo.v1',
        'Date' => @date,
        'Authorization' =>  "NEATOAPP " + @signature,
      },
      body: JSON.dump({ reqId: "13", cmd: "startCleaning", params: { category: 4, mode: 2, navigationMode: 1, mapId: '2020-03-08T15:36:19Z' }})
    )
  end

  private

  def get_signature
    body = JSON.dump({ reqId: "13", cmd: "startCleaning", params: { category: 4, mode: 2, navigationMode: 1, mapId: '2020-03-08T15:36:19Z' }})

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

  def get_public_profile
    response = HTTParty.get("#{NEATO_ENDPOINT}/users/me",
      headers: {
        'Accept' => HEADER_URL,
        'Authorization' =>  "Bearer " + "#{ACCESS_TOKEN}",
      }
    )
  end

  def get_persistent_map_id
    response = HTTParty.get("#{NEATO_ENDPOINT}/users/me/robots/#{ROBOT_SERIAL}/persistent_maps",
      headers: {
        'Accept' => HEADER_URL,
        'Authorization' =>  "Bearer " + "#{ACCESS_TOKEN}",
      }
    )
  end

  def get_general_info
    @date = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")

    body = JSON.dump({ reqId: "13", cmd: "getGeneralInfo"})

    string_to_sign = "#{ROBOT_SERIAL.downcase}\n#{@date}\n#{body}"

    @signature = OpenSSL::HMAC.hexdigest('sha256', ROBOT_SECRET, string_to_sign)

    response = HTTParty.post("https://nucleo.neatocloud.com:4443/vendors/neato/robots/#{ROBOT_SERIAL}/messages",
      headers: {
        'Accept' => 'application/vnd.neato.nucleo.v1',
        'Date' => @date,
        'Authorization' =>  "NEATOAPP " + @signature,
      },
      body: JSON.dump({ reqId: "13", cmd: "getGeneralInfo"})
    )
  end
end

  # private

  def oauth2
    @client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET_KEY, :site => NEATO_ENDPOINT)

    response = @client.auth_code.authorize_url(:redirect_uri => REDIRECT_URI, :scope => "control_robots public_profile maps")

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

  # move to a new utility maybe or to the access token model

  def get_access_token
    response = HTTParty.post(API_ENDPOINT,
      body: {
        "grant_type": "authorization_code",
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET_KEY,
        "redirect_uri": REDIRECT_URI,
        "code": "c91ff2124eab9b399350ecc9adc04a113209ff01eba0af43245d6f95f41ca12d"
      }
    )
  end


  def perform
    @date = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")

    get_signature
    response = HTTParty.post("https://nucleo.neatocloud.com:4443/vendors/neato/robots/#{ROBOT_SERIAL}/messages",
      headers: {
        'Accept' => 'application/vnd.neato.nucleo.v1',
        'Date' => @date,
        'Authorization' =>  "NEATOAPP " + @signature,
      },
      body: JSON.dump({ reqId: "13", cmd: "startCleaning", params: { category: 2, mode: 2, modifier: 1, mapId: "2020-03-08T15:36:19Z" }})
    )
  end

  def get_signature
    body = JSON.dump({ reqId: "13", cmd: "startCleaning", params: { category: 2, mode: 2, modifier: 1, mapId: "2020-03-08T15:36:19Z" }})

    string_to_sign = "#{ROBOT_SERIAL.downcase}\n#{@date}\n#{body}"

    @signature = OpenSSL::HMAC.hexdigest('sha256', ROBOT_SECRET, string_to_sign)
  end