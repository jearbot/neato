class RunNeatoJob < ApplicationJob
  queue_as :default
  require 'openssl'
  require 'net/http'
  require 'uri'
  require 'json'

  # SERIAL = Rails.application.config.serial_number.freeze
  # SECRET = Rails.application.config.secret.freeze

  SERIAL = "GPC45618-3403DEB66B1C".freeze
  SECRET = "CD81C9E22A24A6A50F899D7E223D3D6BD4FCE8023B8F817B4945A451CC9D4DCA8D374C593791601B283ACF294EB6FDCF36E1FA62859243FC88358E604DBBBC4F6B2EAAC38364B6618A38905DF09B3A609D0A06043FAB00F11D8FEFF213333AAE5270AABB5F7435B039B6B9DC56BC393CBB4D93B9479085A28EF7ABA0B73BD631".freeze

  def perform
    binding.pry
    authenticate

    uri = URI.parse("https://nucleo.neatocloud.com:4443/vendors/neato/robots/#{RunNeatoJob::SERIAL}/messages")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/x-www-form-urlencoded; charset=UTF-8"
    request["Connection"] = "keep-alive"
    request["Accept"] = "application/vnd.neato.nucleo.v1"
    request["Authorization"] = "NEATOAPP " + @signature
    request["X-Date"] = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")
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

    puts response.body
  end

  private

  def authenticate
    # request params
    robot_serial = RunNeatoJob::SERIAL
    date = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")
    # => "Fri, 03 Apr 2015 09:12:31 GMT"
    body = '{"reqId":"77", "cmd":"getRobotState"}'
    robot_secret_key = RunNeatoJob::SECRET

    # build string to be signed
    string_to_sign = "#{robot_serial.downcase}\n#{date}\n#{body}"
    binding.pry
    # create signature with SHA256
    @signature = OpenSSL::HMAC.hexdigest('sha256', robot_secret_key, string_to_sign)
  end
end
