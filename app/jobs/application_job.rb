class ApplicationJob < ActiveJob::Base
  ROBOT_SERIAL = Rails.application.config.serial_number.freeze
  ROBOT_SECRET = Rails.application.config.secret.freeze
  HEADER_URL = "application/vnd.neato.beehive.v1+json".freeze
  BEEHIVE_API_ENDPOINT = "https://beehive.neatocloud.com/oauth2/token".freeze
  CLIENT_ID = Rails.application.config.client_id.freeze
  CLIENT_SECRET_KEY = Rails.application.config.client_secret_key.freeze
  REDIRECT_URI = "https://atx.luac.es".freeze
  SCOPE = 'control_robots public_profile maps'.freeze
  NEATO_API_ENDPOINT = "https://apps.neatorobotics.com/".freeze
  ACCESS_TOKEN = AccessToken.last.key
  REFRESH_TOKEN = RefreshToken.last.key
end
