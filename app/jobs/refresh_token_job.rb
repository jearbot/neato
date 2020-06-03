class RefreshTokenJob < ApplicationJob
  def perform
    return unless AccessToken.needs_renewal.present?
    response = HTTParty.post(AccessToken::BEEHIVE_API_ENDPOINT,
      body: {
      "grant_type": "refresh_token",
      "refresh_token": AccessToken::REFRESH_TOKEN
      }
    )

    AccessToken.last.destroy
    AccessToken.create(key: key, expires_at: Time.zone.now + 4000.hours)
  end
end
