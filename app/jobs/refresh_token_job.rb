class RefreshTokenJob < ApplicationJob
  def perform
    return unless AccessToken.needs_renewal.present?
    response = HTTParty.post(AccessToken::BEEHIVE_API_ENDPOINT,
      body: {
      "grant_type": "refresh_token",
      "refresh_token": AccessToken::REFRESH_TOKEN
      }
    )

    # expires_in returns seconds
    # dividing by 60 60 and 24 to get days
    # subtracting one to be safe
    access_token = response["access_token"]
    refresh_token = response["refresh_token"]
    expires_in = response["expires_in"] / 60 / 60 / 24 - 1

    AccessToken.last.destroy
    RefreshToken.last.destroy

    AccessToken.create(key: access_token, expires_at: Time.zone.now + expires_in.days)
    RefreshToken.create(key: refresh_token)
  end
end
