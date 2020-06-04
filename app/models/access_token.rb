class AccessToken < ApplicationRecord
  acts_as_paranoid

  validates :key, presence: true

  scope :needs_renewal, -> { where('expires_at <= ?', Time.zone.now) }

  ROBOT_SERIAL = Rails.application.config.serial_number.freeze
  ROBOT_SECRET = Rails.application.config.secret.freeze
  HEADER_URL = "application/vnd.neato.beehive.v1+json".freeze
  BEEHIVE_API_ENDPOINT = "https://beehive.neatocloud.com/oauth2/token".freeze
  CLIENT_ID = Rails.application.config.client_id.freeze
  CLIENT_SECRET_KEY = Rails.application.config.client_secret_key.freeze
  REDIRECT_URI = "https://atx.luac.es".freeze
  SCOPE = 'control_robots public_profile maps'.freeze
  NEATO_API_ENDPOINT = "https://apps.neatorobotics.com/".freeze
  ACCESS_TOKEN = AccessToken.last&.key
  REFRESH_TOKEN = RefreshToken.last&.key

  def self.oauth
    @client = OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET_KEY, :site => NEATO_API_ENDPOINT)

    response = @client.auth_code.authorize_url(:redirect_uri => REDIRECT_URI, :scope => "control_robots public_profile maps")

    response = response.gsub!('/oauth/','/oauth2/')
  end

  def self.get_access_token(auth_key)
    response = HTTParty.post(BEEHIVE_API_ENDPOINT,
      body: {
        "grant_type": "authorization_code",
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET_KEY,
        "redirect_uri": REDIRECT_URI,
        "code": auth_key
      }
    )
  end

  def self.get_robot_secret_key
    response = HTTParty.get("#{NEATO_API_ENDPOINT}/users/me/robots",
      headers: {
        'Accept' => HEADER_URL,
        'Authorization' =>  "Bearer " + "#{ACCESS_TOKEN}",
      }
    )
    body = '{"reqId":"1", "cmd":"getRobotState"}'
  end

  def self.get_public_profile
    response = HTTParty.get("#{NEATO_API_ENDPOINT}/users/me",
      headers: {
        'Accept' => HEADER_URL,
        'Authorization' =>  "Bearer " + "#{ACCESS_TOKEN}",
      }
    )
  end

  def self.get_persistent_map_id
    response = HTTParty.get("#{NEATO_API_ENDPOINT}/users/me/robots/#{ROBOT_SERIAL}/persistent_maps",
      headers: {
        'Accept' => HEADER_URL,
        'Authorization' =>  "Bearer " + "#{ACCESS_TOKEN}",
      }
    )
  end

  def self.get_general_info
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
