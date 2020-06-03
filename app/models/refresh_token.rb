class RefreshToken < ApplicationRecord
  acts_as_paranoid

  validates :key, presence: true
end
