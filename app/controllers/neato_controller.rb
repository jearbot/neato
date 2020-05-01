class NeatoController < ApplicationController
  SERIAL = Rails.application.config.serial_number.freeze
  SECRET = Rails.application.config.secret.freeze
end
