class AccessToken < ApplicationRecord
  acts_as_paranoid

  validates :key, presence: true

  scope :needs_renewal, -> { where('expires_at <= ?', Time.zone.now) }

  ACCESS_TOKEN = AccessToken.last&.key
end
