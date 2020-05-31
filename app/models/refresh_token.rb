class RefreshToken < ApplicationRecord
  validates :key, presence: true 
end
