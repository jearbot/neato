class RunNeatoJob < ApplicationJob
  # These are the available services for running commands
  #   "findMe"=>"basic-1"
  #   "generalInfo"=>"basic-1"
  #   "houseCleaning"=>"basic-3"
  #   "IECTest"=>"advanced-1"
  #   "logCopy"=>"basic-1"
  #   "maps"=>"macro-1"
  #   "preferences"=>"basic-2"
  #   "schedule"=>"basic-1"
  #   "softwareUpdate"=>"basic-1"
  #   "spotCleaning"=>"basic-3"
  #   "wifi"=>"basic-1"

  def perform
    set_map_id
    get_signature
    response = HTTParty.post("https://nucleo.neatocloud.com:4443/vendors/neato/robots/#{AccessToken::ROBOT_SERIAL}/messages",
      headers: {
        'Accept' => 'application/vnd.neato.nucleo.v1',
        'Date' => date,
        'Authorization' =>  "NEATOAPP " + @signature,
      },
      body: JSON.dump({ reqId: "13", cmd: "startCleaning", params: { category: 4, mode: 2, navigationMode: 1, mapId: "#{@map_id}" }}),
      timeout: 10
    )

    response = response = JSON.parse(response.body)

    Rails.logger.info("ERROR REPORT FOR #{self.class}:::#{response}")
  end

  private

  def get_signature
    body = JSON.dump({ reqId: "13", cmd: "startCleaning", params: { category: 4, mode: 2, navigationMode: 1, mapId: "#{@map_id}" }})

    string_to_sign = "#{AccessToken::ROBOT_SERIAL.downcase}\n#{date}\n#{body}"

    @signature = OpenSSL::HMAC.hexdigest('sha256', AccessToken::ROBOT_SECRET, string_to_sign)
  end

  def set_map_id
    response = AccessToken.get_persistent_map_id
    response = JSON.parse(response.body)
    @map_id = response.first['id']
  end

  def date
    @date ||= Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")
  end
end
