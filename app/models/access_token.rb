class AccessToken < ApplicationRecord
  validates :key, presence: true
end
