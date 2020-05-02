class RunNeatoJob < ApplicationJob
  queue_as :default

  SERIAL = Rails.application.config.serial_number.freeze
  SECRET = Rails.application.config.secret.freeze

  def perform
    require 'net/http'
    require 'uri'
    require 'json'

    uri = URI.parse("https://nucleo.neatocloud.com:4443/vendors/neato/robots/#{SERIAL}/messages")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/x-www-form-urlencoded; charset=UTF-8"
    request["Connection"] = "keep-alive"
    request["Accept"] = "application/vnd.neato.nucleo.v1"
    request["Authorization"] = "NEATOAPP 462ef2e25e0cdead874de26d9b06c2fe547be9c1d04b51a79ce17fd34465125c"
    request["X-Date"] = Time.zone.now
    request["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36"
    request["Origin"] = "https://developers.neatorobotics.com"
    request["Sec-Fetch-Site"] = "cross-site"
    request["Sec-Fetch-Mode"] = "cors"
    request["Sec-Fetch-Dest"] = "empty"
    request["Referer"] = "https://developers.neatorobotics.com/demo/sdk-js/index.html"
    request["Accept-Language"] = "en-US,en;q=0.9"
    request.body = JSON.dump({
      "reqId" => "1",
      "cmd" => "startCleaning",
      "params" => {
        "category" => 2,
        "mode" => 2,
        "navigationMode" => 1
      }
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end
end
