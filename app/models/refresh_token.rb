class RefreshToken < ApplicationRecord
  acts_as_paranoid

  validates :key, presence: true

  REFRESH_TOKEN = RefreshToken.last&.key
end
