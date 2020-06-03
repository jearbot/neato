require 'clockwork'
require_relative './boot'
require_relative './environment'

module Clockwork
  configure do |config|
    config[:sleep_timeout] = 10
  end

  every(1.day, 'RunNeatoJob', at: '23:23') do # 04:00
    Rails.logger.info("Running RunNeatoJob")

    RunNeatoJob.perform_now
  end

  every(1.day, 'RefreshTokenJob', at: '09:00') do
    RefreshTokenJob.perform_now
  end
end
