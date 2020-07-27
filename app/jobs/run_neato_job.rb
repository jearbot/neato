class RunNeatoJob < ApplicationJob
  # THese are the available services for running commands
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
    @date = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")

    get_signature
    response = HTTParty.post("https://nucleo.neatocloud.com:4443/vendors/neato/robots/#{AccessToken::ROBOT_SERIAL}/messages",
      headers: {
        'Accept' => 'application/vnd.neato.nucleo.v1',
        'Date' => @date,
        'Authorization' =>  "NEATOAPP " + @signature,
      },
      body: JSON.dump({ reqId: "13", cmd: "startCleaning", params: { category: 4, mode: 2, navigationMode: 1, mapId: '2020-03-08T15:36:19Z' }})
    )
  end

  private

  def get_signature
    body = JSON.dump({ reqId: "13", cmd: "startCleaning", params: { category: 4, mode: 2, navigationMode: 1, mapId: '2020-03-08T15:36:19Z' }})

    string_to_sign = "#{AccessToken::ROBOT_SERIAL.downcase}\n#{@date}\n#{body}"

    @signature = OpenSSL::HMAC.hexdigest('sha256', AccessToken::ROBOT_SECRET, string_to_sign)
  end
end
