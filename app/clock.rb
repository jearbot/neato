require 'clockwork'
require_relative './boot'
require_relative './environment'

# IMPORTANT! Please, set a minutes explicitly for every hourly/daily task to
# pevent multiple run with each deploy in a suitable time inverval.

module Clockwork
  configure do |config|
    config[:sleep_timeout] = 10
  end

  every(1.day, 'RunNeatoJob', at: '04:00') do
    RunNeatoJob.perform_now
  end
end
